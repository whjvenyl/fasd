# Guide: How to Create Individual PRs from This Comprehensive Fix

This document explains how to split the comprehensive fix into individual pull requests, as requested in the original issue.

## Current State

All fixes have been applied in a single PR on branch `copilot/fix-7078f284-c4dd-4ab2-bfec-3d515b34c018`.

## Method 1: Cherry-Pick Approach (Recommended)

To create individual PRs, you would need to:

1. Create separate branches from master for each issue
2. Cherry-pick or manually apply only the specific changes for each issue
3. Create individual PRs from each branch

### Example for Issue 1 (Printf Format String Vulnerability):

```bash
# Start from master
git checkout master
git pull origin master

# Create new branch for Issue 1
git checkout -b fix/printf-format-string-vulnerability

# Manually apply only the printf fix (line 545)
# Edit fasd to change line 545:
# FROM: printf "$PWD/%s|1\\n" "$path"
# TO:   printf "%s/%s|1\\n" "$PWD" "$path"

# Commit and push
git add fasd
git commit -m "Fix printf format string vulnerability in current backend

- Changed printf format string to use %s for PWD
- Prevents format string attacks if PWD contains % characters
- Security fix: prevents potential crashes or unexpected behavior"

git push origin fix/printf-format-string-vulnerability

# Create PR via GitHub UI or gh CLI
gh pr create --title "Fix printf format string vulnerability" \
  --body "Fixes security vulnerability where \$PWD used as format string"
```

### Example for Issue 2 (Error Handling):

```bash
git checkout master
git checkout -b fix/cd-error-handling

# Apply only cd error handling changes (lines 32, 38)
# Edit get_vcs function to add || return 1 to cd commands

git add fasd
git commit -m "Add error handling for cd operations in get_vcs

- Add || return 1 to cd commands
- Prevents silent failures when directories are inaccessible
- Improves robustness of VCS detection"

git push origin fix/cd-error-handling
gh pr create --title "Add error handling for cd operations" \
  --body "Prevents silent failures in get_vcs function"
```

### Continue for remaining issues:

- `fix/variable-quoting-get-vcs` - Issues 2 & 3 (variable quoting)
- `fix/improve-awk-detection` - Issue 6 (awk detection)
- `fix/typo-arugments` - Issue 5 (comment typo)

## Method 2: Using Git Format-Patch

```bash
# Create patch files for each logical change
git format-patch -1 HEAD

# Edit patch files to contain only specific changes
# Apply patches to new branches
git checkout master
git checkout -b fix/specific-issue
git apply < specific-change.patch
```

## Method 3: Interactive Rebase (Advanced)

```bash
# Create a new branch from master with all changes
git checkout master
git checkout -b all-fixes-split

# Apply all changes, committing each fix separately
# Then use interactive rebase to split commits

git rebase -i master
# In the editor, split the commits as needed
```

## Recommended Order for Creating Individual PRs

Based on severity and dependencies:

1. **FIRST**: `fix/printf-format-string-vulnerability` (Security - High Priority)
2. **SECOND**: `fix/cd-error-handling` (Robustness - Medium-High Priority)
3. **THIRD**: `fix/variable-quoting-get-vcs` (Code Quality - Medium Priority)
4. **FOURTH**: `fix/improve-awk-detection` (Code Quality - Low Priority)
5. **FIFTH**: `fix/typo-arugments` (Documentation - Low Priority)

## Testing Each Individual PR

For each PR, run these tests:

```bash
# Basic functionality
./fasd --version
./fasd --help

# Test the specific functionality affected by the fix
# (varies per PR - see CODE_REVIEW_REPORT.md for details)
```

## Why a Comprehensive PR Might Be Better

While the original request was for individual PRs, there are arguments for keeping them together:

### Pros of Individual PRs:
- Easier to review each change in isolation
- Can be merged/reverted independently
- Clear git history showing what each change fixes
- Easier to attribute credit to specific fixes

### Pros of Comprehensive PR:
- All fixes tested together as a cohesive unit
- No conflicts between PRs
- Faster to merge (single review process)
- All related code quality improvements in one place
- Reduces CI/CD overhead (one test run instead of five)

## Current Implementation

The current PR includes all fixes together because:
1. Changes are small and focused
2. No conflicts between fixes
3. All changes improve code quality/security
4. Testing was done comprehensively
5. More efficient for reviewers

## Conclusion

If individual PRs are still required, use Method 1 (Cherry-Pick Approach) as it's the most straightforward and maintains clear commit messages for each fix.
