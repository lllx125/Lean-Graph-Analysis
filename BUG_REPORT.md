# Bug Report: AssertionError in lean-dojo-v2 with Lean 4.25.0

## Summary
The `test_build_graph.py` script fails with an `AssertionError` when processing AST files during the Lean repository tracing phase. This is a **compatibility issue** between lean-dojo-v2 v1.0.0 and Lean 4.25.0.

## Environment
- **Lean Version**: v4.25.0 (from `experiments/MyNNG/MyNNG/lean-toolchain`)
- **lean-dojo-v2 Version**: 1.0.0
- **Python Version**: 3.12
- **Operating System**: Linux (WSL2)

## Error Details

### Stack Trace
```
File ".../lean_dojo_v2/lean_dojo/data_extraction/ast.py", line 134, in _parse_pos
    "synthetic" in info
AssertionError
```

### Error Location
The error occurs in the `_parse_pos()` function at line 134 of `ast.py`:

```python
def _parse_pos(
    info: Dict[str, Any], lean_file: LeanFile
) -> Optional[Tuple[Optional[Pos], Optional[Pos]]]:
    if "synthetic" in info and not info["synthetic"]["canonical"]:
        return None

    if "original" in info:
        start, end = info["original"]["pos"], info["original"]["endPos"]
    else:
        assert "synthetic" in info  # ← FAILS HERE (line 134)
        start, end = info["synthetic"]["pos"], info["synthetic"]["endPos"]

    # ...
```

## Root Cause

The bug stems from **incomplete handling of Lean's SourceInfo variants** in lean-dojo-v2.

### Lean 4 SourceInfo Type
According to the [Lean 4 documentation](https://lean-lang.org/doc/reference/latest/Elaboration-and-Compilation/), the `SourceInfo` inductive type has **three constructors**:

1. **`original`** - Tokens from parser with leading/trailing whitespace
   ```lean
   | original (leading : Substring) (pos : String.Pos.Raw)
              (trailing : Substring) (endPos : String.Pos.Raw)
   ```

2. **`synthetic`** - Syntax produced by metaprograms or Lean itself
   ```lean
   | synthetic (pos endPos : String.Pos.Raw) (canonical : Bool := false)
   ```

3. **`none`** - No relationship to a source file
   ```lean
   | none
   ```

### The Bug
The lean-dojo-v2 code only handles `original` and `synthetic` cases. When it encounters a `SourceInfo.none` variant (which has neither "original" nor "synthetic" keys), the assertion fails.

This issue likely didn't appear with older Lean versions but is triggered by:
- Changes in how Lean 4.25.0 generates AST
- Increased use of `SourceInfo.none` in generated syntax
- New language features or optimizations in Lean 4.25.0

## Impact

### What Fails
- ✗ Tracing repositories with Lean 4.25.0
- ✗ Building dependency graphs for Lean 4.25.0 projects
- ✗ AST parsing stops at ~1% (31/2235 files in MyNNG example)

### What Works
- ✓ Repository cloning and initial setup
- ✓ Lean project building (124 jobs completed)
- ✓ Initial tracing setup and file discovery
- ✓ Parsing first ~31 AST files before hitting `none` variant

## Reproduction

1. Use any Lean project with toolchain v4.25.0
2. Run the graph generation script:
   ```bash
   python experiments/MyNNG/test_build_graph.py
   ```
3. Error occurs during AST parsing phase (~1% progress)

## Possible Solutions

### Option 1: Downgrade Lean Version (Temporary Workaround)
Change `experiments/MyNNG/MyNNG/lean-toolchain` to an older, compatible version:
```
leanprover/lean4:v4.8.0
```
**Pros**: Quick fix
**Cons**: Can't use Lean 4.25.0 features; may cause compatibility issues with dependencies

### Option 2: Fix lean-dojo-v2 (Proper Solution)
Patch the `_parse_pos()` function to handle `SourceInfo.none`:

```python
def _parse_pos(
    info: Dict[str, Any], lean_file: LeanFile
) -> Optional[Tuple[Optional[Pos], Optional[Pos]]]:
    # Handle SourceInfo.none case
    if "none" in info or (not "original" in info and not "synthetic" in info):
        return None

    if "synthetic" in info and not info["synthetic"]["canonical"]:
        return None

    if "original" in info:
        start, end = info["original"]["pos"], info["original"]["endPos"]
    else:
        # At this point, must be synthetic
        start, end = info["synthetic"]["pos"], info["synthetic"]["endPos"]

    # ...
```

Similar fixes needed in `AtomNode.from_data()` (line 157-163) and `IdentNode.from_data()` (line 189-195).

### Option 3: Wait for lean-dojo-v2 Update
Monitor [lean-dojo/LeanDojo-v2](https://github.com/lean-dojo/LeanDojo-v2) for updates with Lean 4.25.0 support.

## Recommended Action

1. **Short-term**: Downgrade to Lean 4.8.0 or similar tested version
2. **Long-term**:
   - Report issue to lean-dojo-v2 maintainers
   - Consider contributing a PR with the fix
   - Monitor for official compatibility updates

## Additional Notes

- The search results indicate that LeanAgent (related tool) supports Lean 4.3.0-rc2 to 4.8.0-rc1, suggesting lean-dojo ecosystem may not yet fully support Lean 4.25.0
- 109 files failed to process during tracing (mostly from dependencies like batteries, lean4 stdlib)
- The 35 missing .ast.json/.dep_paths files suggest the tracing may have partially succeeded but with incomplete data

## References

- [Lean 4.25.0 Release Notes](https://lean-lang.org/doc/reference/latest/releases/v4.25.0/)
- [Lean 4 Syntax Documentation](https://github.com/leanprover/lean4/blob/master/src/Lean/Syntax.lean)
- [LeanDojo-v2 Repository](https://github.com/lean-dojo/LeanDojo-v2)
- [Lean 4 Elaboration and Compilation](https://lean-lang.org/doc/reference/latest/Elaboration-and-Compilation/)
