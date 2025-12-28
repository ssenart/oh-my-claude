#!/bin/bash
# Installation script for oh-my-claude status line
# Installs to ~/.claude/oh-my-claude/ and updates Claude Code settings

set -e

echo "================================================"
echo "   oh-my-claude Status Line Installation"
echo "================================================"
echo ""

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Copy scripts
echo "Copying scripts..."
cp "$SCRIPT_DIR/src/statusline.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/src/update-usage.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/src/fetch-code-usage.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/src/fetch-pro-usage.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/src/claude-statusline.omp.json" "$INSTALL_DIR/"

echo -e "${GREEN}✓ Copied all scripts to $INSTALL_DIR${NC}"
echo ""

# Make scripts executable
echo "Making scripts executable..."
chmod +x "$INSTALL_DIR/statusline.sh"
chmod +x "$INSTALL_DIR/update-usage.sh"
chmod +x "$INSTALL_DIR/fetch-code-usage.sh"
chmod +x "$INSTALL_DIR/fetch-pro-usage.sh"

echo -e "${GREEN}✓ Scripts are now executable${NC}"
echo ""

# Handle .env file
echo "Setting up .env file..."
if [ -f "$SCRIPT_DIR/.env" ]; then
    # Copy existing .env
    cp "$SCRIPT_DIR/.env" "$INSTALL_DIR/"
    chmod 600 "$INSTALL_DIR/.env"
    echo -e "${GREEN}✓ Copied existing .env file${NC}"
else
    # Create from .env.example
    cp "$SCRIPT_DIR/.env.example" "$INSTALL_DIR/.env"
    chmod 600 "$INSTALL_DIR/.env"
    echo -e "${YELLOW}⚠ Created .env from template${NC}"
    echo -e "${YELLOW}  You need to edit $INSTALL_DIR/.env with your credentials${NC}"
fi
echo ""

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

# Check if .env needs configuration
if grep -q "sk-ant-oat01-\.\.\." "$INSTALL_DIR/.env" 2>/dev/null; then
    echo -e "${YELLOW}⚠ NEXT STEPS:${NC}"
    echo ""
    echo "1. Edit your .env file with credentials:"
    echo "   nano $INSTALL_DIR/.env"
    echo ""
    echo "2. For Code usage tracking:"
    echo "   - Get OAuth token from: https://console.anthropic.com/settings/keys"
    echo "   - Add as CLAUDE_CODE_OAUTH_TOKEN in .env"
    echo ""
    echo "3. For Pro usage tracking (optional):"
    echo "   - See docs/PRO-USAGE-SETUP.md for detailed setup"
    echo "   - Add CLAUDE_SESSION_KEY and CLAUDE_ORG_ID to .env"
    echo ""
    echo "4. Test the status line:"
    echo "   echo '{\"model\":{\"display_name\":\"Test\"},\"workspace\":{\"current_dir\":\"$PWD\"},\"output_style\":{\"name\":\"markdown\"},\"context_window\":{\"current_usage\":{\"input_tokens\":1000},\"context_window_size\":200000}}' | bash $INSTALL_DIR/statusline.sh"
    echo ""
else
    echo -e "${GREEN}✓ Configuration looks complete${NC}"
    echo ""
    echo "You can now use Claude Code and see the status line!"
    echo ""
    echo "Optional: Run a test with:"
    echo "  echo '{\"model\":{\"display_name\":\"Test\"},\"workspace\":{\"current_dir\":\"$PWD\"},\"output_style\":{\"name\":\"markdown\"},\"context_window\":{\"current_usage\":{\"input_tokens\":1000},\"context_window_size\":200000}}' | bash $INSTALL_DIR/statusline.sh"
    echo ""
fi

echo "Documentation:"
echo "  • README.md - Getting started guide"
echo "  • docs/PRO-USAGE-SETUP.md - Pro usage setup (optional)"
echo "  • docs/STATUS_LINE_QUICK_REFERENCE.md - Common operations"
echo ""
echo "================================================"
