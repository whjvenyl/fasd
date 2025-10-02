# Visual Comparison: Before and After Fixes

This document shows the actual code changes made to fix each issue.

---

## Issue 1: Printf Format String Vulnerability (Line 545)

### ❌ Before (VULNERABLE)
```bash
current)
  for path in *; do
    printf "$PWD/%s|1\\n" "$path"
  done
  ;;
```

### ✅ After (FIXED)
```bash
current)
  for path in *; do
    printf "%s/%s|1\\n" "$PWD" "$path"
  done
  ;;
```

**Why this matters:** If `$PWD` contains `%` characters (e.g., `/home/user/my%20files`), the original code would interpret `%20` as a format specifier, causing printf to fail or produce unexpected output.

---

## Issue 2 & 3: Unquoted Variables in get_vcs (Lines 31, 35)

### ❌ Before (VULNERABLE)
```bash
get_vcs() {
    local begin_path=$1        # ← No quotes
    cd "$begin_path"
    while [ "$PWD" != "/" ]; do
        if { [ -d .git ] || [ -d .hg ] ;} then
            echo $PWD          # ← No quotes
            return
        fi
        cd ..
    done
    echo "$begin_path"
}
```

### ✅ After (FIXED)
```bash
get_vcs() {
    local begin_path="$1"      # ← Quoted
    cd "$begin_path" || return 1
    while [ "$PWD" != "/" ]; do
        if { [ -d .git ] || [ -d .hg ] ;} then
            echo "$PWD"        # ← Quoted
            return
        fi
        cd .. || return 1
    done
    echo "$begin_path"
}
```

**Why this matters:** 
- Line 31: Without quotes, `local begin_path=$1` fails if `$1` contains spaces
- Line 35: Without quotes, `echo $PWD` performs word splitting if path contains spaces

---

## Issue 4: Missing Error Handling (Lines 32, 38)

### ❌ Before (NO ERROR HANDLING)
```bash
get_vcs() {
    local begin_path="$1"
    cd "$begin_path"           # ← No error check
    while [ "$PWD" != "/" ]; do
        if { [ -d .git ] || [ -d .hg ] ;} then
            echo "$PWD"
            return
        fi
        cd ..                  # ← No error check
    done
    echo "$begin_path"
}
```

### ✅ After (WITH ERROR HANDLING)
```bash
get_vcs() {
    local begin_path="$1"
    cd "$begin_path" || return 1   # ← Returns on error
    while [ "$PWD" != "/" ]; do
        if { [ -d .git ] || [ -d .hg ] ;} then
            echo "$PWD"
            return
        fi
        cd .. || return 1          # ← Returns on error
    done
    echo "$begin_path"
}
```

**Why this matters:** If `cd` fails (directory doesn't exist or no permission), the function should fail gracefully rather than continuing with unexpected state.

---

## Issue 5: Typo in Comment (Line 490)

### ❌ Before
```bash
else # no query arugments
```

### ✅ After
```bash
else # no query arguments
```

**Why this matters:** Code clarity and professionalism.

---

## Issue 6: Inefficient AWK Detection (Line 97)

### ❌ Before (UNCLEAR)
```bash
if [ -z "$_FASD_AWK" ]; then
  # awk preferences
  local awk; for awk in mawk gawk original-awk nawk awk; do
    $awk "" && _FASD_AWK=$awk && break
  done
fi
```

### ✅ After (CLEAR)
```bash
if [ -z "$_FASD_AWK" ]; then
  # awk preferences
  local awk; for awk in mawk gawk original-awk nawk awk; do
    $awk 'BEGIN{exit}' < /dev/null && _FASD_AWK=$awk && break
  done
fi
```

**Why this matters:** 
- More explicit about what we're testing
- Uses proper AWK syntax with BEGIN block
- Reads from /dev/null instead of relying on empty string behavior
- Clearer intent for future maintainers

---

## Summary of Changes

| Line(s) | Issue | Characters Changed |
|---------|-------|-------------------|
| 31 | Unquoted assignment | Added quotes: `$1` → `"$1"` |
| 32 | Missing error handling | Added: `|| return 1` |
| 35 | Unquoted variable | Added quotes: `$PWD` → `"$PWD"` |
| 38 | Missing error handling | Added: `|| return 1` |
| 97 | Inefficient awk test | Changed: `""` → `'BEGIN{exit}' < /dev/null` |
| 490 | Typo | Fixed: `arugments` → `arguments` |
| 545 | Format string vuln | Changed: `"$PWD/%s|1\\n" "$path"` → `"%s/%s|1\\n" "$PWD" "$path"` |

**Total lines changed: 7**  
**Total characters changed: ~50**  
**Impact: Significant improvement in security and robustness**

---

## Testing Each Fix

### Test for Issue 1 (Printf)
```bash
# Create directory with % in path
mkdir -p "/tmp/test%20dir"
cd "/tmp/test%20dir"
fasd --backend current
# Should output: /tmp/test%20dir/...|1
# Not crash or produce %s in output
```

### Test for Issue 2 & 3 (Quoting)
```bash
# Test with space in path
bash -c '. ./fasd && get_vcs "/tmp/path with spaces"'
# Should handle gracefully, not split on spaces
```

### Test for Issue 4 (Error Handling)
```bash
# Test with non-existent directory
bash -c '. ./fasd && get_vcs "/nonexistent/path"'
echo $?  # Should return 1 (error)
```

### Test for Issue 6 (AWK)
```bash
# Test AWK detection
bash -c 'unset _FASD_AWK; . ./fasd; echo "AWK=$_FASD_AWK"'
# Should output: AWK=mawk (or gawk, nawk, etc.)
```
