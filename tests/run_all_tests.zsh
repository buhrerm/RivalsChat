#!/usr/bin/env zsh

# run_all_tests.zsh - Test runner
# Runs all unit and integration tests

echo "╔════════════════════════════════════════╗"
echo "║   Rivals TUI Test Suite Runner        ║"
echo "╚════════════════════════════════════════╝"
echo ""

TOTAL_PASSED=0
TOTAL_FAILED=0

# Run unit tests
echo "📦 Running Unit Tests..."
echo ""

for test_file in tests/unit/test_*.zsh; do
    if [[ -f "$test_file" ]]; then
        chmod +x "$test_file"
        if "$test_file"; then
            ((TOTAL_PASSED++))
        else
            ((TOTAL_FAILED++))
        fi
        echo ""
    fi
done

# Run integration tests
echo "🔗 Running Integration Tests..."
echo ""

for test_file in tests/integration/test_*.zsh; do
    if [[ -f "$test_file" ]]; then
        chmod +x "$test_file"
        if "$test_file"; then
            ((TOTAL_PASSED++))
        else
            ((TOTAL_FAILED++))
        fi
        echo ""
    fi
done

# Summary
echo "╔════════════════════════════════════════╗"
echo "║          Test Suite Summary            ║"
echo "╠════════════════════════════════════════╣"
echo "║ Test Files Passed: $TOTAL_PASSED"
echo "║ Test Files Failed: $TOTAL_FAILED"
echo "╚════════════════════════════════════════╝"

if [[ $TOTAL_FAILED -gt 0 ]]; then
    exit 1
else
    echo ""
    echo "✅ All tests passed!"
    exit 0
fi
