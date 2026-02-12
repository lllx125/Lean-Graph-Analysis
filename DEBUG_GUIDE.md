# Debug Guide: How to Investigate and Fix the AST Parsing Bug

## Quick Diagnosis

### The Failing Code
**Location**: `.venv/lib/python3.12/site-packages/lean_dojo_v2/lean_dojo/data_extraction/ast.py:120-136`

```python
def _parse_pos(info: Dict[str, Any], lean_file: LeanFile) -> Optional[Tuple[Optional[Pos], Optional[Pos]]]:
    if "synthetic" in info and not info["synthetic"]["canonical"]:
        return None

    if "original" in info:
        # Branch 1: Handle original source positions
        start, end = info["original"]["pos"], info["original"]["endPos"]
    else:
        # Branch 2: Handle synthetic positions
        assert (
            "synthetic" in info  # <-- LINE 134: THIS FAILS
        )  # Expected: | synthetic (pos : String.Pos) (endPos : String.Pos) (canonical := false)
        start, end = info["synthetic"]["pos"], info["synthetic"]["endPos"]

    start = lean_file.convert_pos(start)
    end = lean_file.convert_pos(end)

    return start, end
```

### Why It Fails
The assertion expects `info` to contain either:
1. An `"original"` key, OR
2. A `"synthetic"` key

But in Lean v4.25.0, **`info` contains neither**, indicating a new position format.

## Investigation Steps

### Step 1: Capture the Actual Data Structure
Modify `_parse_pos()` to log what `info` actually contains:

```python
def _parse_pos(info: Dict[str, Any], lean_file: LeanFile) -> Optional[Tuple[Optional[Pos], Optional[Pos]]]:
    # ADD THIS DEBUG CODE:
    if "original" not in info and "synthetic" not in info:
        import json
        print("=" * 80)
        print("UNEXPECTED INFO FORMAT DETECTED:")
        print(f"Keys in info: {list(info.keys())}")
        print(f"Full info structure: {json.dumps(info, indent=2)}")
        print(f"Lean file: {lean_file.path}")
        print("=" * 80)

    # Original code continues...
    if "synthetic" in info and not info["synthetic"]["canonical"]:
        return None
    # ... etc
```

**Run the test again** and capture the output to see the actual format.

### Step 2: Compare Lean Versions
Generate AST files from both versions and compare:

```bash
# Setup v4.11.0
cd /tmp/lean-test-v4.11
echo "leanprover/lean4:v4.11.0" > lean-toolchain
# Create simple test file
echo 'def test : Nat := 42' > Test.lean
lake build
# Examine AST
cat .lake/build/ir/Test.ast.json

# Setup v4.25.0
cd /tmp/lean-test-v4.25
echo "leanprover/lean4:v4.25.0" > lean-toolchain
echo 'def test : Nat := 42' > Test.lean
lake build
# Examine AST
cat .lake/build/ir/Test.ast.json

# Compare
diff /tmp/lean-test-v4.11/.lake/build/ir/Test.ast.json \
     /tmp/lean-test-v4.25/.lake/build/ir/Test.ast.json
```

### Step 3: Review Lean Changelog
Check what changed in Lean's AST format:
- https://github.com/leanprover/lean4/blob/master/RELEASES.md
- Search for: "AST", "SourceInfo", "position", "syntax"
- Focus on versions v4.12.0 through v4.25.0

### Step 4: Check Lean Source Code
Look at Lean's SourceInfo definition:
```bash
# Clone Lean repository
git clone https://github.com/leanprover/lean4.git
cd lean4

# Check v4.11.0 definition
git checkout v4.11.0
# Look for SourceInfo definition in Lean/Data/Position.lean or similar

# Check v4.25.0 definition
git checkout v4.25.0
# Compare the same files
```

## Potential Fix Patterns

### Pattern 1: New Position Format Added
If Lean v4.25.0 added a **third position format**, update `_parse_pos()`:

```python
def _parse_pos(info: Dict[str, Any], lean_file: LeanFile) -> Optional[Tuple[Optional[Pos], Optional[Pos]]]:
    if "synthetic" in info and not info["synthetic"]["canonical"]:
        return None

    if "original" in info:
        start, end = info["original"]["pos"], info["original"]["endPos"]
    elif "synthetic" in info:
        start, end = info["synthetic"]["pos"], info["synthetic"]["endPos"]
    elif "NEW_FORMAT_KEY" in info:  # <-- ADD NEW BRANCH
        start, end = info["NEW_FORMAT_KEY"]["pos"], info["NEW_FORMAT_KEY"]["endPos"]
    else:
        raise ValueError(f"Unknown position format: {list(info.keys())}")

    start = lean_file.convert_pos(start)
    end = lean_file.convert_pos(end)
    return start, end
```

### Pattern 2: Format Structure Changed
If the format structure changed but still has pos/endPos:

```python
def _parse_pos(info: Dict[str, Any], lean_file: LeanFile) -> Optional[Tuple[Optional[Pos], Optional[Pos]]]:
    # Try to extract pos and endPos from wherever they are
    start = None
    end = None

    if "synthetic" in info and not info["synthetic"]["canonical"]:
        return None

    # Check all known formats
    for key in ["original", "synthetic", "OTHER_POSSIBLE_KEY"]:
        if key in info:
            data = info[key]
            if isinstance(data, dict) and "pos" in data and "endPos" in data:
                start, end = data["pos"], data["endPos"]
                break

    if start is None or end is None:
        raise ValueError(f"Could not find pos/endPos in info: {info}")

    start = lean_file.convert_pos(start)
    end = lean_file.convert_pos(end)
    return start, end
```

### Pattern 3: Position Info Now Optional
If position info is sometimes completely missing:

```python
def _parse_pos(info: Dict[str, Any], lean_file: LeanFile) -> Optional[Tuple[Optional[Pos], Optional[Pos]]]:
    # Return None if no position info available
    if not info:
        return None

    if "synthetic" in info and not info["synthetic"]["canonical"]:
        return None

    # ... rest of parsing logic with better error handling
```

## Testing the Fix

### Create a Minimal Test
```python
# test_ast_parsing.py
from pathlib import Path
from lean_dojo_v2.lean_dojo.data_extraction.lean import LeanGitRepo
from lean_dojo_v2.lean_dojo.data_extraction.trace import trace

# Create minimal Lean project
test_dir = Path("/tmp/lean_test")
test_dir.mkdir(exist_ok=True)

# Write minimal Lean file
(test_dir / "Test.lean").write_text("def test : Nat := 42")
(test_dir / "lakefile.lean").write_text("""
import Lake
open Lake DSL

package test

lean_lib Test
""")
(test_dir / "lean-toolchain").write_text("leanprover/lean4:v4.25.0")

# Try to trace
repo = LeanGitRepo.from_path(test_dir)
traced = trace(repo)
print(f"Success! Traced {len(traced.traced_files)} files")
```

### Validate Against Multiple Versions
Test the fix with:
- ✅ Lean v4.11.0 (known working)
- ✅ Lean v4.15.0 (intermediate)
- ✅ Lean v4.20.0 (intermediate)
- ✅ Lean v4.25.0 (current target)

## Error Message Improvement

Instead of a cryptic assertion, provide helpful errors:

```python
def _parse_pos(info: Dict[str, Any], lean_file: LeanFile) -> Optional[Tuple[Optional[Pos], Optional[Pos]]]:
    if "synthetic" in info and not info["synthetic"]["canonical"]:
        return None

    if "original" in info:
        start, end = info["original"]["pos"], info["original"]["endPos"]
    elif "synthetic" in info:
        start, end = info["synthetic"]["pos"], info["synthetic"]["endPos"]
    else:
        # BETTER ERROR MESSAGE:
        raise ValueError(
            f"Unsupported position info format in {lean_file.path}\n"
            f"Expected 'original' or 'synthetic' key, but got: {list(info.keys())}\n"
            f"Full info: {info}\n"
            f"This may indicate a Lean version incompatibility.\n"
            f"lean-dojo-v2 is tested with Lean v4.11.0. Current Lean version may be incompatible."
        )

    start = lean_file.convert_pos(start)
    end = lean_file.convert_pos(end)
    return start, end
```

## Submitting a Fix

If you fix this issue:

1. **Test thoroughly** with multiple Lean versions
2. **Update documentation** with supported Lean versions
3. **Add version detection** to warn users about incompatibilities
4. **Create regression tests** for each Lean version
5. **Submit PR** to lean-dojo-v2 with:
   - Clear description of the change
   - Evidence of testing (multiple Lean versions)
   - Updated compatibility matrix

## Resources
- lean-dojo-v2 repo: https://github.com/lean-dojo/LeanDojo
- Lean 4 repo: https://github.com/leanprover/lean4
- Lean 4 releases: https://github.com/leanprover/lean4/releases
- AST extraction code: `lean_dojo_v2/lean_dojo/data_extraction/ast.py`
