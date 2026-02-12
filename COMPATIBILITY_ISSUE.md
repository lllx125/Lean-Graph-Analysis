# lean-dojo-v2 Compatibility Issue Summary

## Problem
**lean-dojo-v2 v1.0.0 is fundamentally incompatible with Lean 4.8.0 and later versions.**

## Root Cause
The `ExtractData.lean` file in lean-dojo-v2 uses the `HashMap.get?` API, which was changed/removed in Lean 4.8+. This causes compilation failure:

```
ExtractData.lean:348:24: error: invalid field 'get?', the environment does not contain 'Lean.HashMap.get?'
```

## Versions Tested

| Lean Version | lakefile.toml Support | Build Status | lean-dojo-v2 Trace Status | Issue |
|--------------|----------------------|--------------|---------------------------|-------|
| v4.25.0 | ✅ Yes | ✅ Success | ❌ **Fails** | SourceInfo.none AssertionError |
| v4.11.0 | ✅ Yes | ✅ Success | ❌ **Fails** | HashMap.get? API error |
| v4.9.0 | ✅ Yes | ✅ Success | ❌ **Fails** | HashMap.get? API error |
| v4.8.0-rc1 | ✅ Yes | ❌ **Fails** | N/A | Qq.Macro and mathlib compile errors |
| v4.8.0 | ❌ No (lean only) | N/A | N/A | No lakefile.toml support |
| v4.7.0 | ❌ No (lean only) | N/A | N/A | No lakefile.toml support |

## Official Compatibility Range
According to the LeanAgent documentation (related project), the supported range is:
- **Lean 4.3.0-rc2 to 4.8.0-rc1**

However, our testing shows:
- Versions below v4.8.0 don't support `lakefile.toml` (only `lakefile.lean`)
- v4.8.0-rc1 has dependency compilation issues

## Available Solutions

### Option 1: Convert to lakefile.lean (Recommended for now)
Convert [lakefile.toml](experiments/MyNNG/MyNNG/lakefile.toml:1) to `lakefile.lean` format and use Lean v4.7.0:

```lean
-- lakefile.lean
import Lake
open Lake DSL

package MyNNG where
  leanOptions := #[
    ⟨`pp.unicode.fun, true⟩,
    ⟨`relaxedAutoImplicit, false⟩
  ]

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.7.0"

@[default_target]
lean_lib MyNNG
```

Then use Lean v4.7.0:
```
leanprover/lean4:v4.7.0
```

### Option 2: Wait for lean-dojo-v2 Update
Monitor the [lean-dojo/LeanDojo-v2](https://github.com/lean-dojo/LeanDojo-v2) repository for updates that support Lean 4.9+.

### Option 3: Patch lean-dojo-v2 Locally
Create a local patch to `ExtractData.lean` to use the updated HashMap API. This requires:
1. Forking lean-dojo-v2
2. Updating `ExtractData.lean` to use the new HashMap API
3. Installing from the patched version

### Option 4: Report to Maintainers
Open an issue at [https://github.com/lean-dojo/LeanDojo-v2/issues](https://github.com/lean-dojo/LeanDojo-v2/issues) reporting:
- The HashMap.get? API incompatibility with Lean 4.8+
- The SourceInfo.none AssertionError with Lean 4.25.0
- Request for official support of Lean 4.9+ with lakefile.toml

## Attempted Fixes

### What We Did
1. ✅ **Identified the bug**: SourceInfo.none handling in AST parser
2. ✅ **Downgraded Lean**: v4.25.0 → v4.11.0 → v4.9.0 → v4.8.0-rc1
3. ✅ **Fixed lakefile.toml**: Updated from `scope` to `git` URL format
4. ✅ **Removed incompatible options**: Removed `weak.linter.mathlibStandardSet`, `maxSynthPendingDepth`
5. ✅ **Renamed conflicting theorems**: Prefixed with `MyNat_` to avoid mathlib conflicts
6. ✅ **Committed changes**: All fixes committed to MyNNG repository

### What Didn't Work
- ❌ Any Lean version ≥ 4.8.0 fails at lean-dojo-v2 tracing stage
- ❌ ExtractData.lean compilation fails due to HashMap API changes
- ❌ v4.8.0-rc1 has too many dependency incompatibilities

## Recommended Next Steps

1. **Short-term**: Convert to lakefile.lean and use Lean v4.7.0
2. **Long-term**:
   - Report the issue to lean-dojo-v2 maintainers
   - Monitor for official Lean 4.9+ support
   - Consider contributing a PR with the HashMap API fix

## Files Modified

All changes committed to MyNNG repository:

- [lean-toolchain](experiments/MyNNG/MyNNG/lean-toolchain:1): Multiple version changes (now at v4.9.0)
- [lakefile.toml](experiments/MyNNG/MyNNG/lakefile.toml:1): Updated format and version
- [MyNNG/LessOrEqual.lean](experiments/MyNNG/MyNNG/MyNNG/LessOrEqual.lean:1): Renamed conflicting theorems
- [lake-manifest.json](experiments/MyNNG/MyNNG/lake-manifest.json:1): Regenerated for each version

## Key Learnings

1. **lean-dojo-v2 v1.0.0 lags behind Lean 4 releases**
2. **Breaking API changes in Lean 4.8.0+ affect data extraction tools**
3. **lakefile.toml support started in Lean 4.8.0**
4. **There's a compatibility gap**: toml support begins where lean-dojo support ends

## References

- Bug report: [BUG_REPORT.md](BUG_REPORT.md:1)
- LeanDojo-v2: https://github.com/lean-dojo/LeanDojo-v2
- Lean 4 Release Notes: https://lean-lang.org/doc/reference/latest/releases/
