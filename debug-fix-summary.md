# Debug Output Fix Summary

## Problem
Every second, the program was outputting `char=''` at the bottom of the screen.

## Root Cause
The `local char` declaration in the main input loop was outputting debug information to stderr. This appears to be a behavior of zsh when some form of debugging or tracing is enabled in the shell environment.

## Solution
Changed line 1610 from:
```zsh
local char
```
to:
```zsh
unset char
```

This removes the local declaration that was causing the debug output, while still ensuring the variable is clean for each iteration.

## Testing
Confirmed that:
1. No more `char=''` output appears
2. The application still functions correctly
3. All features (pattern switching, modes, etc.) work as expected

The issue was particularly tricky to diagnose because:
- The output wasn't from an explicit echo statement
- It only happened with `local` declarations
- It was being sent to stderr, not stdout
- Standard grep searches couldn't find the source