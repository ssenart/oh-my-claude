#!/bin/bash
# Installation script for oh-my-claude status line
# Installs to ~/.claude/oh-my-claude/ and updates Claude Code settings

set -e

# Read version from VERSION file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION=$(cat "$SCRIPT_DIR/VERSION" 2>/dev/null || echo "unknown")

echo "================================================"
echo "   oh-my-claude Status Line Installation"
echo "   Version: $VERSION"
echo "================================================"
echo ""

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Installation directory
INSTALL_DIR="$HOME/.claude/oh-my-claude"
SETTINGS_FILE="$HOME/.claude/settings.json"

# Check dependencies
echo "Checking dependencies..."
missing_deps=()

if ! command -v oh-my-posh >/dev/null 2>&1; then
    missing_deps+=("oh-my-posh")
fi

if ! command -v jq >/dev/null 2>&1; then
    missing_deps+=("jq")
fi

if ! command -v git >/dev/null 2>&1; then
    missing_deps+=("git")
fi

if ! command -v npx >/dev/null 2>&1; then
    missing_deps+=("npx (Node.js)")
fi

if [ ${#missing_deps[@]} -ne 0 ]; then
    echo -e "${RED}✗ Missing required dependencies:${NC}"
    for dep in "${missing_deps[@]}"; do
        echo "  - $dep"
    done
    echo ""
    echo "Please install missing dependencies and try again."
    exit 1
fi

echo -e "${GREEN}✓ All dependencies found${NC}"
echo ""

# Create installation directory
echo "Creating installation directory..."
mkdir -p "$INSTALL_DIR"
echo -e "${GREEN}✓ Created $INSTALL_DIR${NC}"
echo ""

# Copy scripts and VERSION file
echo "Copying scripts..."
cp "$SCRIPT_DIR/src/statusline.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/src/update-usage.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/src/fetch-code-usage.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/src/fetch-pro-usage.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/src/setup-env.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/src/claude-statusline.omp.json" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/VERSION" "$INSTALL_DIR/"

echo -e "${GREEN}✓ Copied all scripts to $INSTALL_DIR${NC}"
echo ""

# Make scripts executable
echo "Making scripts executable..."
chmod +x "$INSTALL_DIR/statusline.sh"
chmod +x "$INSTALL_DIR/update-usage.sh"
chmod +x "$INSTALL_DIR/fetch-code-usage.sh"
chmod +x "$INSTALL_DIR/fetch-pro-usage.sh"
chmod +x "$INSTALL_DIR/setup-env.sh"

echo -e "${GREEN}✓ Scripts are now executable${NC}"
echo ""

# Skip .env file handling - will be done interactively at the end

# Backup and update settings.json
echo "Updating Claude Code settings..."

if [ -f "$SETTINGS_FILE" ]; then
    # Backup existing settings
    backup_file="$SETTINGS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$SETTINGS_FILE" "$backup_file"
    echo -e "${GREEN}✓ Backed up settings to $backup_file${NC}"

    # Update statusLine.command path
    # Use jq to update or add the statusLine configuration
    tmp_file=$(mktemp)
    jq --arg cmd "bash $INSTALL_DIR/statusline.sh" \
       '.statusLine.command = $cmd | .statusLine.type = "command" | .statusLine.padding = 0' \
       "$SETTINGS_FILE" > "$tmp_file"

    mv "$tmp_file" "$SETTINGS_FILE"
    echo -e "${GREEN}✓ Updated settings.json with new statusLine.command${NC}"
else
    # Create new settings.json
    mkdir -p "$(dirname "$SETTINGS_FILE")"
    cat > "$SETTINGS_FILE" <<EOF
{
  "statusLine": {
    "type": "command",
    "command": "bash $INSTALL_DIR/statusline.sh",
    "padding": 0
  }
}
EOF
    echo -e "${GREEN}✓ Created new settings.json${NC}"
fi
echo ""

# Test installation
echo "Testing installation..."
if bash "$INSTALL_DIR/fetch-code-usage.sh" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Code usage fetcher works${NC}"
else
    echo -e "${YELLOW}⚠ Code usage fetcher test failed (this is OK if ccusage isn't set up yet)${NC}"
fi
echo ""

# Print summary
echo "================================================"
echo -e "${GREEN}   Installation Complete!${NC}"
echo "================================================"
echo ""
echo "Installation summary:"
echo "  • Scripts installed to: $INSTALL_DIR"
echo "  • Settings updated in: $SETTINGS_FILE"
echo ""

# Setup .env interactively
echo ""
echo "================================================"
echo -e "${YELLOW}   Interactive .env Setup${NC}"
echo "================================================"
echo ""

# Check if .env already exists (user might be re-running install)
if [ -f "$INSTALL_DIR/.env" ]; then
    echo -e "${YELLOW}Found existing .env file.${NC}"
    echo ""
    echo -n "Do you want to reconfigure it? (y/n): "
    read -r reconfigure
    if [ "$reconfigure" != "y" ]; then
        echo ""
        echo -e "${GREEN}✓ Keeping existing .env file${NC}"
        echo ""
        echo "You can reconfigure it later by running:"
        echo "  bash $INSTALL_DIR/setup-env.sh"
        echo ""
    else
        # Run setup-env.sh
        bash "$INSTALL_DIR/setup-env.sh" "$INSTALL_DIR"
    fi
else
    # Run setup-env.sh for first-time setup
    bash "$INSTALL_DIR/setup-env.sh" "$INSTALL_DIR"
fi

echo ""
echo -e "${GREEN}✓ Configuration complete${NC}"
echo ""
echo "You can now use Claude Code and see the status line!"
echo ""
echo "Test the status line with:"
echo "  echo '{\"model\":{\"display_name\":\"Test\"},\"workspace\":{\"current_dir\":\"$PWD\"},\"output_style\":{\"name\":\"markdown\"},\"context_window\":{\"current_usage\":{\"input_tokens\":1000},\"context_window_size\":200000}}' | bash $INSTALL_DIR/statusline.sh"
echo ""

echo "Documentation:"
echo "  • README.md - Getting started guide"
echo "  • docs/PRO-USAGE-SETUP.md - Pro usage setup (optional)"
echo "  • docs/STATUS_LINE_QUICK_REFERENCE.md - Common operations"
echo ""
echo "================================================"
