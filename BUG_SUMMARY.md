# Bug Summary: lean-dojo-v2 + Lean v4.25.0 Incompatibility

## The Problem
**lean-dojo-v2 v1.0.0 cannot parse AST files from Lean v4.25.0** - crashes with `AssertionError` at line 134 in `ast.py`

## Location
```
File: .venv/lib/python3.12/site-packages/lean_dojo_v2/lean_dojo/data_extraction/ast.py
Function: _parse_pos()
Line: 134
Error: AssertionError
```

## What's Broken
The `_parse_pos()` function expects position info in this format:
- **Format A**: `{ "original": { "pos": ..., "endPos": ... } }`
- **Format B**: `{ "synthetic": { "pos": ..., "endPos": ... } }`

**Lean v4.25.0 is producing a different format** that the parser doesn't recognize, causing the assertion to fail.

## When It Happens
- ✅ Lean build: SUCCESS (124 jobs)
- ✅ AST extraction: SUCCESS (2235 files extracted)
- ❌ AST parsing: CRASH at 1% progress (31/2081 files parsed)

## Impact
**Cannot use lean-dojo-v2 with Lean v4.25.0** - this blocks:
- Dependency graph generation
- Theorem extraction
- Any analysis requiring AST parsing

## Root Cause
**Version incompatibility**: Lean v4.25.0 has a different AST format than what lean-dojo-v2 expects (built for v4.11.0)

## Quick Fix
**Downgrade Lean to v4.11.0:**
```bash
cd experiments/MyNNG/MyNNG
echo "leanprover/lean4:v4.11.0" > lean-toolchain
lake update
```

## Versions
- ❌ Lean v4.25.0 (current - INCOMPATIBLE)
- ✅ Lean v4.11.0 (recommended - COMPATIBLE)
- lean-dojo-v2: v1.0.0

## See Also
- Full analysis: `BUG_REPORT_DETAILED.md`
- Test script: `experiments/MyNNG/test_build_graph.py`
