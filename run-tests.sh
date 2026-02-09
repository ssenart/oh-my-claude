#!/bin/bash
# Test runner for oh-my-claude
# Requires bats-core: https://github.com/bats-core/bats-core

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="$SCRIPT_DIR/tests"

# Check if bats is installed
if ! command -v bats >/dev/null 2>&1; then
    echo -e "${RED}Error: bats-core is not installed${NC}"
    echo ""
    echo "Install bats-core:"
    echo "  Ubuntu/Debian: sudo apt install bats"
    echo "  macOS: brew install bats-core"
    echo "  Manual: https://github.com/bats-core/bats-core#installation"
    exit 1
fi

echo -e "${GREEN}Running oh-my-claude tests...${NC}"
echo ""

# Run tests
if [ $# -eq 0 ]; then
    # Run all tests
    bats "$TESTS_DIR"/*.bats
else
    # Run specific test file(s)
    bats "$@"
fi

exit_code=$?

echo ""
if [ $exit_code -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
else
    echo -e "${RED}✗ Some tests failed${NC}"
fi

exit $exit_code
