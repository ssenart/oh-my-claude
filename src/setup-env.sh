#!/usr/bin/env bash

# Helper script to set up .env file with sessionKey and org ID

# Allow override of installation directory (for use by install.sh)
if [ -n "$1" ]; then
    INSTALL_DIR="$1"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    INSTALL_DIR="$SCRIPT_DIR"
fi

ENV_FILE="$INSTALL_DIR/.env"

echo ""
echo "=========================================="
echo "Claude Session Key Setup"
echo "=========================================="
echo ""

# Check if .env exists
if [ -f "$ENV_FILE" ]; then
    echo "Found existing .env file:"
    echo ""
    cat "$ENV_FILE"
    echo ""
    echo -n "Do you want to update it? (y/n): "
    read -r response
    if [ "$response" != "y" ]; then
        echo "Cancelled."
        exit 0
    fi
    # Backup existing .env
    cp "$ENV_FILE" "$ENV_FILE.backup"
    echo "Backed up existing .env to .env.backup"
fi

echo ""
echo "Follow these steps to get your sessionKey:"
echo ""
echo "1. Open https://claude.ai in your browser (logged in)"
echo "2. Press F12 to open Developer Tools"
echo "3. Go to Application → Cookies → https://claude.ai"
echo "4. Find 'sessionKey' and copy its value (starts with sk-ant-sid01-)"
echo ""
echo -n "Paste your sessionKey here: "
read -r SESSION_KEY

if [ -z "$SESSION_KEY" ]; then
    echo "ERROR: No sessionKey provided"
    exit 1
fi

echo ""
echo "Now let's get your Organization ID:"
echo ""
echo "Your organization ID from OAuth was: 5c4876d6-541a-4464-97b9-30fd7a8418c9"
echo ""
echo -n "Use this org ID? (y/n): "
read -r use_oauth_org

if [ "$use_oauth_org" = "y" ]; then
    ORG_ID="5c4876d6-541a-4464-97b9-30fd7a8418c9"
else
    echo ""
    echo "To find your org ID:"
    echo "1. Go to https://claude.ai/settings/usage"
    echo "2. Look at the URL for 'organization=YOUR-ORG-ID'"
    echo ""
    echo -n "Paste your organization ID here: "
    read -r ORG_ID
fi

if [ -z "$ORG_ID" ]; then
    echo "ERROR: No organization ID provided"
    exit 1
fi

# Write to .env file
cat > "$ENV_FILE" <<EOF
# Claude Pro Session Authentication
CLAUDE_SESSION_KEY=$SESSION_KEY
CLAUDE_ORG_ID=$ORG_ID
EOF

echo ""
echo "✓ .env file created successfully!"
echo ""
echo "Contents:"
cat "$ENV_FILE"
echo ""
echo "You can now test your setup by running:"
echo "  ./src/fetch-pro-usage.sh --debug"
echo ""
