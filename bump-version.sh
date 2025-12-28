#!/bin/bash
# Version bump helper script
# Updates VERSION file, README.md, and CHANGELOG.md

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="$SCRIPT_DIR/VERSION"
README_FILE="$SCRIPT_DIR/README.md"
CHANGELOG_FILE="$SCRIPT_DIR/CHANGELOG.md"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Read current version
if [ ! -f "$VERSION_FILE" ]; then
    echo -e "${RED}ERROR: VERSION file not found${NC}"
    exit 1
fi

CURRENT_VERSION=$(cat "$VERSION_FILE")
echo "Current version: $CURRENT_VERSION"
echo ""

# Parse version parts (assumes semantic versioning: MAJOR.MINOR.PATCH)
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Show menu
echo "Select version bump type:"
echo "  1) Major (${MAJOR}.x.x -> $((MAJOR+1)).0.0) - Breaking changes"
echo "  2) Minor (x.${MINOR}.x -> ${MAJOR}.$((MINOR+1)).0) - New features"
echo "  3) Patch (x.x.${PATCH} -> ${MAJOR}.${MINOR}.$((PATCH+1))) - Bug fixes"
echo "  4) Custom version"
echo "  5) Cancel"
echo ""
echo -n "Choice [1-5]: "
read -r choice

case $choice in
    1)
        NEW_VERSION="$((MAJOR+1)).0.0"
        ;;
    2)
        NEW_VERSION="${MAJOR}.$((MINOR+1)).0"
        ;;
    3)
        NEW_VERSION="${MAJOR}.${MINOR}.$((PATCH+1))"
        ;;
    4)
        echo -n "Enter new version (e.g., 2.0.0): "
        read -r NEW_VERSION
        # Validate format
        if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo -e "${RED}ERROR: Invalid version format. Use MAJOR.MINOR.PATCH${NC}"
            exit 1
        fi
        ;;
    5)
        echo "Cancelled."
        exit 0
        ;;
    *)
        echo -e "${RED}ERROR: Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${YELLOW}Bumping version: $CURRENT_VERSION -> $NEW_VERSION${NC}"
echo ""

# Update VERSION file
echo "$NEW_VERSION" > "$VERSION_FILE"
echo -e "${GREEN}✓ Updated VERSION file${NC}"

# Update README.md
if [ -f "$README_FILE" ]; then
    # Update the version line (e.g., "**Version**: 1.6")
    sed -i "s/\*\*Version\*\*: [0-9]\+\.[0-9]\+/\*\*Version\*\*: ${NEW_VERSION%.*}/" "$README_FILE"
    echo -e "${GREEN}✓ Updated README.md${NC}"
fi

# Prompt to update CHANGELOG.md
echo ""
echo -e "${YELLOW}Don't forget to update CHANGELOG.md manually!${NC}"
echo "Add a new section for version $NEW_VERSION with:"
echo "  - Date ($(date +%Y-%m-%d))"
echo "  - List of changes"
echo ""

# Offer to create git tag
echo -n "Create git tag v$NEW_VERSION? (y/n): "
read -r create_tag

if [ "$create_tag" = "y" ]; then
    if git rev-parse --git-dir >/dev/null 2>&1; then
        echo ""
        echo -n "Enter tag message (or press Enter for default): "
        read -r tag_message

        if [ -z "$tag_message" ]; then
            tag_message="Release version $NEW_VERSION"
        fi

        git tag -a "v$NEW_VERSION" -m "$tag_message"
        echo -e "${GREEN}✓ Created git tag v$NEW_VERSION${NC}"
        echo ""
        echo "To push the tag to remote, run:"
        echo "  git push origin v$NEW_VERSION"
    else
        echo -e "${RED}ERROR: Not a git repository${NC}"
    fi
fi

echo ""
echo -e "${GREEN}Version bump complete!${NC}"
echo ""
echo "Summary:"
echo "  Old version: $CURRENT_VERSION"
echo "  New version: $NEW_VERSION"
echo ""
echo "Next steps:"
echo "  1. Update CHANGELOG.md with changes for v$NEW_VERSION"
echo "  2. Review changes: git diff"
echo "  3. Commit: git add . && git commit -m 'Bump version to $NEW_VERSION'"
if [ "$create_tag" != "y" ]; then
    echo "  4. Create tag: git tag -a v$NEW_VERSION -m 'Release version $NEW_VERSION'"
    echo "  5. Push: git push && git push origin v$NEW_VERSION"
else
    echo "  4. Push: git push && git push origin v$NEW_VERSION"
fi
