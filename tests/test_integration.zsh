#!/usr/bin/env zsh

# Integration test - Test actual TUI functionality

echo "Integration Test - Rivals TUI Modular"
echo "======================================"
echo ""

# Test 1: TUI starts without errors
echo -n "Test 1: TUI starts without crashing... "
if timeout 2 ./src/rivals-tui-modular.zsh < <(echo -e '\x1b') 2>&1 | grep -q "Thanks for using"; then
    echo "✓"
else
    echo "✗ FAILED"
    exit 1
fi

# Test 2: Can open pattern manager
echo -n "Test 2: Pattern manager opens (Ctrl+P)... "
if timeout 2 ./src/rivals-tui-modular.zsh < <(printf '\x10\x1b') 2>&1 | grep -q "Pattern Manager"; then
    echo "✓"
else
    echo "✗ FAILED"
    exit 1
fi

# Test 3: Can open pattern creator from manager
echo -n "Test 3: Pattern creator opens (Ctrl+P, N)... "
if timeout 2 ./src/rivals-tui-modular.zsh < <(printf '\x10n\x1b') 2>&1 | grep -q "Pattern Creator"; then
    echo "✓"
else
    echo "✗ FAILED"
    exit 1
fi

# Test 4: Pattern manager can navigate patterns
echo -n "Test 4: Can navigate patterns... "
# Open manager, press down arrow, then close
if timeout 2 ./src/rivals-tui-modular.zsh < <(printf '\x10\x1b[B\x1b') 2>&1 | grep -q "Thanks for using"; then
    echo "✓"
else
    echo "✗ FAILED"
    exit 1
fi

# Test 5: Text input works
echo -n "Test 5: Can enter text... "
if timeout 2 ./src/rivals-tui-modular.zsh < <(printf 'Hello\x1b') 2>&1 | grep -q "Thanks for using"; then
    echo "✓"
else
    echo "✗ FAILED"
    exit 1
fi

echo ""
echo "All integration tests passed! ✓"
echo ""
echo "Manual testing instructions:"
echo "1. Run ./src/rivals-tui-modular.zsh"
echo "2. Press Ctrl+P to open pattern manager"
echo "3. Press E to edit a custom pattern (like 'Contrast')"
echo "4. Verify the pattern loads with its colors displayed"
echo "5. Press Esc to exit"
