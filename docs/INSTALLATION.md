# Installation Guide

Complete step-by-step guide to installing oh-my-claude status line for Claude Code.

## What You'll Get

![Status Line Example](example.png)

After installation, you'll have a rich status line showing:
- **Path** (orange) - Current directory
- **Git** (yellow) - Branch and repository status
- **Context** (teal) - Conversation window usage
- **Pro Usage** (pink) - 5-hour and 7-day usage percentages
- **Reset Times** (purple) - When usage limits reset
- **Model** (blue) - Current AI model

## Prerequisites

Before installing, ensure you have these dependencies:

### Required Dependencies

1. **oh-my-posh** - Powerline theme engine
   ```bash
   # Windows (PowerShell)
   winget install JanDeDobbeleer.OhMyPosh

   # macOS
   brew install jandedobbeleer/oh-my-posh/oh-my-posh

   # Linux
   curl -s https://ohmyposh.dev/install.sh | bash -s
   ```

2. **jq** - JSON processor
   ```bash
   # Windows (Git Bash/MSYS2)
   pacman -S jq

   # macOS
   brew install jq

   # Linux (Debian/Ubuntu)
   sudo apt-get install jq
   ```

3. **git** - Version control
   ```bash
   # Usually pre-installed, verify with:
   git --version
   ```

4. **Node.js/npx** - For ccusage tool
   ```bash
   # Windows
   winget install OpenJS.NodeJS

   # macOS
   brew install node

   # Linux
   sudo apt-get install nodejs npm
   ```

### Verify Dependencies

Run this command to check all dependencies:

```bash
# Check oh-my-posh
oh-my-posh --version

# Check jq
jq --version

# Check git
git --version

# Check npx
npx --version
```

All commands should return version numbers without errors.

## Installation

### Method 1: Automated Installation (Recommended)

1. **Clone the repository**:
   ```bash
   git clone https://github.com/ssenart/oh-my-claude.git
   cd oh-my-claude
   ```

2. **Run the installation script**:
   ```bash
   bash install.sh
   ```

3. **The script will**:
   - ✅ Check for required dependencies
   - ✅ Create `~/.claude/oh-my-claude/` directory
   - ✅ Copy all scripts and configuration files
   - ✅ Make scripts executable
   - ✅ Backup your existing `settings.json`
   - ✅ Update `settings.json` with new statusLine command
   - ✅ Create `.env` template for credentials

4. **Installation output**:
   ```
   ================================================
      oh-my-claude Status Line Installation
   ================================================

   Checking dependencies...
   ✓ All dependencies found

   Creating installation directory...
   ✓ Created /home/user/.claude/oh-my-claude

   Copying scripts...
   ✓ Copied all scripts to /home/user/.claude/oh-my-claude

   Making scripts executable...
   ✓ Scripts are now executable

   Setting up .env file...
   ✓ Created .env from template

   Updating Claude Code settings...
   ✓ Backed up settings to /home/user/.claude/settings.json.backup.20251228_123456
   ✓ Updated settings.json with new statusLine.command

   Testing installation...
   ✓ Code usage fetcher works

   ================================================
      Installation Complete!
   ================================================
   ```

### Method 2: Manual Installation

If you prefer manual installation or need to customize the process:

1. **Create installation directory**:
   ```bash
   mkdir -p ~/.claude/oh-my-claude
   ```

2. **Copy scripts**:
   ```bash
   cd oh-my-claude
   cp src/statusline.sh ~/.claude/oh-my-claude/
   cp src/update-usage.sh ~/.claude/oh-my-claude/
   cp src/fetch-code-usage.sh ~/.claude/oh-my-claude/
   cp src/fetch-pro-usage.sh ~/.claude/oh-my-claude/
   cp src/claude-statusline.omp.json ~/.claude/oh-my-claude/
   ```

3. **Make scripts executable**:
   ```bash
   chmod +x ~/.claude/oh-my-claude/statusline.sh
   chmod +x ~/.claude/oh-my-claude/update-usage.sh
   chmod +x ~/.claude/oh-my-claude/fetch-code-usage.sh
   chmod +x ~/.claude/oh-my-claude/fetch-pro-usage.sh
   ```

4. **Create .env file**:
   ```bash
   cp .env.example ~/.claude/oh-my-claude/.env
   chmod 600 ~/.claude/oh-my-claude/.env
   ```

5. **Backup and update settings.json**:
   ```bash
   # Backup existing settings
   cp ~/.claude/settings.json ~/.claude/settings.json.backup

   # Update settings (use your favorite editor)
   nano ~/.claude/settings.json
   ```

   Add or update the statusLine section:
   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "bash /home/user/.claude/oh-my-claude/statusline.sh",
       "padding": 0
     }
   }
   ```

## Post-Installation Configuration

### 1. Configure API Credentials

Edit `~/.claude/oh-my-claude/.env` and add your credentials:

```bash
nano ~/.claude/oh-my-claude/.env
```

#### For Code Usage Tracking (Required)

```bash
# Get from: https://console.anthropic.com/settings/keys
CLAUDE_CODE_OAUTH_TOKEN=sk-ant-oat01-YOUR_TOKEN_HERE
```

#### For Pro Usage Tracking (Optional)

See [PRO-USAGE-SETUP.md](PRO-USAGE-SETUP.md) for detailed instructions.

```bash
# Get from browser DevTools → Application → Cookies → sessionKey
CLAUDE_SESSION_KEY=sk-ant-sid01-YOUR_SESSION_KEY

# Get from: https://claude.ai/settings/usage → Network tab
CLAUDE_ORG_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

### 2. Verify Installation

Run a test to ensure everything is working:

```bash
# Test the status line
echo '{"model":{"display_name":"Test"},"workspace":{"current_dir":"'$PWD'"},"output_style":{"name":"markdown"},"context_window":{"current_usage":{"input_tokens":1000},"context_window_size":200000}}' | bash ~/.claude/oh-my-claude/statusline.sh
```

You should see a colorful status line output with all segments.

### 3. Test Individual Components

```bash
# Test Code usage fetcher
bash ~/.claude/oh-my-claude/fetch-code-usage.sh --debug

# Test Pro usage fetcher (if configured)
bash ~/.claude/oh-my-claude/fetch-pro-usage.sh --debug

# Test cache update
bash ~/.claude/oh-my-claude/update-usage.sh

# View cache
cat ~/.claude/oh-my-claude/.usage_cache | jq .
```

## What Gets Installed

### Directory Structure

```
~/.claude/oh-my-claude/
├── statusline.sh                    # Main status line script
├── update-usage.sh                  # Background usage updater
├── fetch-code-usage.sh              # Code session token fetcher
├── fetch-pro-usage.sh               # Pro usage fetcher
├── claude-statusline.omp.json       # Oh-my-posh theme configuration
├── .env                             # Your API credentials (created)
└── .usage_cache                     # Usage cache (auto-generated)
```

### Settings Changes

The installation updates your `~/.claude/settings.json`:

**Before:**
```json
{
  "model": "sonnet",
  "alwaysThinkingEnabled": true
}
```

**After:**
```json
{
  "model": "sonnet",
  "alwaysThinkingEnabled": true,
  "statusLine": {
    "type": "command",
    "command": "bash /home/user/.claude/oh-my-claude/statusline.sh",
    "padding": 0
  }
}
```

A backup is automatically created before any changes.

## Troubleshooting

### Installation Script Fails

#### Missing Dependencies

```
✗ Missing required dependencies:
  - oh-my-posh
  - jq
```

**Solution**: Install the missing dependencies (see Prerequisites section)

#### Permission Denied

```
bash: install.sh: Permission denied
```

**Solution**:
```bash
chmod +x install.sh
bash install.sh
```

### Status Line Not Appearing

#### Check settings.json

```bash
cat ~/.claude/settings.json | jq .statusLine
```

Should output:
```json
{
  "type": "command",
  "command": "bash /home/user/.claude/oh-my-claude/statusline.sh",
  "padding": 0
}
```

#### Verify script is executable

```bash
ls -la ~/.claude/oh-my-claude/statusline.sh
```

Should show `-rwxr-xr-x` (executable permissions)

#### Test manually

```bash
echo '{"model":{"display_name":"Test"},"workspace":{"current_dir":"'$PWD'"},"output_style":{"name":"markdown"},"context_window":{"current_usage":{"input_tokens":1000},"context_window_size":200000}}' | bash ~/.claude/oh-my-claude/statusline.sh
```

### Usage Data Not Showing

#### Check .env configuration

```bash
cat ~/.claude/oh-my-claude/.env
```

Verify credentials are set (not placeholder values).

#### Test fetch scripts

```bash
# Test Code usage (should return a number)
bash ~/.claude/oh-my-claude/fetch-code-usage.sh

# Test Pro usage (should return percentages)
bash ~/.claude/oh-my-claude/fetch-pro-usage.sh
```

#### Check cache file

```bash
# Does it exist?
ls -la ~/.claude/oh-my-claude/.usage_cache

# Is it valid JSON?
cat ~/.claude/oh-my-claude/.usage_cache | jq .
```

If cache doesn't exist, create it:
```bash
bash ~/.claude/oh-my-claude/update-usage.sh
```

### Config Error in Status Line

If you see "CONFIG ERROR" in the status line, it usually means:

1. **Cache file missing**: Run `bash ~/.claude/oh-my-claude/update-usage.sh`
2. **Invalid JSON in cache**: Delete cache and regenerate:
   ```bash
   rm ~/.claude/oh-my-claude/.usage_cache
   bash ~/.claude/oh-my-claude/update-usage.sh
   ```
3. **.env file misconfigured**: Check credentials in `.env`

### Oh-my-posh Not Found

```
bash: oh-my-posh: command not found
```

**Solution**: Install oh-my-posh or update PATH

```bash
# Find oh-my-posh
which oh-my-posh

# Add to PATH if needed
export PATH="$PATH:/path/to/oh-my-posh"
```

## Uninstallation

To completely remove oh-my-claude:

1. **Remove installed files**:
   ```bash
   rm -rf ~/.claude/oh-my-claude
   ```

2. **Restore original settings** (if you have a backup):
   ```bash
   # Find your backup
   ls ~/.claude/settings.json.backup*

   # Restore it
   cp ~/.claude/settings.json.backup.TIMESTAMP ~/.claude/settings.json
   ```

3. **Or manually remove statusLine from settings.json**:
   ```bash
   # Edit settings
   nano ~/.claude/settings.json

   # Remove the entire "statusLine" section
   ```

## Updating

To update to the latest version:

1. **Pull latest changes**:
   ```bash
   cd oh-my-claude
   git pull origin main
   ```

2. **Run installation script again**:
   ```bash
   bash install.sh
   ```

The script will backup your current settings and `.env` file before updating.

## Next Steps

After successful installation:

1. **Customize appearance**: Edit `~/.claude/oh-my-claude/claude-statusline.omp.json`
   - Change colors
   - Modify icons
   - Reorder segments

2. **Set up Pro usage** (optional): Follow [PRO-USAGE-SETUP.md](PRO-USAGE-SETUP.md)

3. **Explore documentation**:
   - [STATUS_LINE_QUICK_REFERENCE.md](STATUS_LINE_QUICK_REFERENCE.md) - Common operations
   - [STATUS_LINE_DOCUMENTATION.md](STATUS_LINE_DOCUMENTATION.md) - Full technical reference
   - [EXAMPLES.md](EXAMPLES.md) - Visual examples

## Getting Help

If you encounter issues:

1. Check this troubleshooting guide first
2. Review [STATUS_LINE_DOCUMENTATION.md](STATUS_LINE_DOCUMENTATION.md)
3. Open an issue: https://github.com/ssenart/oh-my-claude/issues

## Platform-Specific Notes

### Windows (Git Bash/MSYS2)

- Use Git Bash or MSYS2 terminal
- Path format: `/c/Users/username/.claude/oh-my-claude/`
- Install jq via MSYS2: `pacman -S jq`

### macOS

- Use Terminal or iTerm2
- Path format: `/Users/username/.claude/oh-my-claude/`
- Install via Homebrew recommended

### Linux

- Path format: `/home/username/.claude/oh-my-claude/`
- Most distributions include required tools
- Use package manager for dependencies

## Version Information

- Installation script version: 1.0
- Compatible with Claude Code: All versions
- Last updated: 2025-12-28
