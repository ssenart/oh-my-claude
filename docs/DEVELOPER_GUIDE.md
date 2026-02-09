# Developer Guide

This guide provides comprehensive information for developers working on oh-my-claude, including architecture, implementation details, and development workflows.

## Project Overview

This is a custom status line implementation for Claude Code featuring real-time token usage tracking, git status, context window monitoring, and oh-my-posh theming. The system uses a multi-script architecture with caching to provide fast, non-blocking updates.

## Core Architecture

### Multi-Script System

1. **common.sh** - Shared utility library (NEW in v1.9.0)
   - `get_script_dir()` - Returns script directory path
   - `get_version()` - Reads VERSION file from script or parent directory
   - `handle_version_flag()` - Standardized --version/-v handling
   - `get_file_mtime()` - Cross-platform file modification time (Linux/macOS)
   - `parse_date()` - ISO 8601 date parsing to Unix timestamp
   - `format_date()` - Date formatting with fallbacks
   - Sourced by all other scripts to eliminate code duplication

2. **statusline.sh** - Main entry point called by Claude Code
   - Parses JSON input from stdin containing model, workspace, and context data
   - Calculates context window percentage using awk (no bc dependency)
   - Reads cached usage data (never blocks waiting for updates)
   - Exports only used environment variables for oh-my-posh (CLAUDE_MODEL, CLAUDE_CONTEXT, etc.)
   - Calls oh-my-posh to render the final status line
   - **Note**: Git status is handled by oh-my-posh's built-in git segment, not by this script

3. **update-usage.sh** - Background updater (runs async)
   - Called by statusline.sh when cache is >60s old
   - Calls `fetch-code-usage.sh` for Claude Code session tokens
   - Calls `fetch-pro-usage.sh` for Claude Pro web usage percentages
   - Writes to `.usage_cache` in JSON format with timestamp

4. **fetch-code-usage.sh** - Code usage fetcher
   - Runs `npx ccusage blocks --active --json`
   - Extracts total session tokens
   - Returns raw token count

5. **fetch-pro-usage.sh** - Pro usage fetcher (optional)
   - Uses curl to call Anthropic OAuth API
   - Authenticates with OAuth access token from `~/.claude/.credentials.json`
   - Fetches from `https://api.anthropic.com/api/oauth/usage`
   - Returns Pro usage percentages and reset times for 5-hour and 7-day windows

6. **claude-statusline.omp.json** - Oh-my-posh theme configuration
   - Defines powerline-style segments with colors and icons
   - Reads data from `CLAUDE_*` environment variables
   - Uses oh-my-posh's built-in git segment type (not custom variables)
   - Uses diamond and powerline styles for visual separation

### Key Design Decisions

- **Non-blocking updates**: statusline.sh never waits for ccusage/API calls (which take 2-5s). It always reads cached data immediately, triggering background updates only when cache is stale.
- **Cache format**: JSON with timestamp for clarity and easy inspection/debugging. Cache is read once and parsed multiple times for efficiency.
- **Git handling**: Delegated to oh-my-posh's native git segment (faster, more features). Custom git parsing removed in v1.9.0.
- **Shared utilities**: common.sh eliminates code duplication across scripts (40 lines saved).
- **No bc dependency**: All math uses awk for better portability and consistency.
- **Simplified metrics**: Only shows current session tokens from Code (no percentages/limits - they were inaccurate) and Pro percentages from web API.
- **Pure bash Pro fetching**: Uses curl with browser-like headers to fetch Pro usage, no Node.js/Puppeteer needed.
- **LF line endings**: Enforced via .gitattributes for cross-platform compatibility (Linux, macOS, Windows Git Bash).

## Common Commands

### Testing and Development

```bash
# Run unit tests (requires bats-core)
./run-tests.sh

# Run specific test file
bats tests/common.bats

# Test the status line with mock data
echo '{"model":{"display_name":"Test"},"workspace":{"current_dir":"'$PWD'"},"output_style":{"name":"markdown"},"context_window":{"current_usage":{"input_tokens":1000},"context_window_size":200000}}' | bash ~/.claude/oh-my-claude/statusline.sh

# Force update usage cache
bash ~/.claude/oh-my-claude/update-usage.sh

# View current cache contents
cat ~/.claude/oh-my-claude/.usage_cache | jq .

# Test individual components
bash ~/.claude/oh-my-claude/fetch-code-usage.sh --debug
bash ~/.claude/oh-my-claude/fetch-pro-usage.sh --debug

# Check versions
bash ~/.claude/oh-my-claude/statusline.sh --version
bash ~/.claude/oh-my-claude/update-usage.sh --version
```

### Configuration

```bash
# Edit oh-my-posh theme (colors, icons, segment order)
nano ~/.claude/claude-statusline.omp.json

# View Claude Code settings
cat ~/.claude/settings.json
```

## Important Implementation Details

### Cache Timeout Behavior

The 60-second cache timeout (line 62 in statusline.sh) controls when background updates trigger. Lowering this increases API calls to ccusage; raising it reduces freshness. The cache is always read immediately even if stale—the timeout only controls when a background update spawns.

### Token Calculation

- Session tokens: `.blocks[0].totalTokens` from ccusage blocks
- Weekly tokens: `.weekly[-1].totalTokens` from ccusage weekly
- Percentages: `(tokens * 100 / limit)` rounded to whole numbers
- Token display: Formatted as millions (M) with `.1f` precision, removing trailing `.0`

### Environment Variable Contract

Oh-my-posh expects these exact variable names for custom segments:
- `CLAUDE_MODEL` - Model display name (e.g., "Sonnet 4.5")
- `CLAUDE_CONTEXT` - Context percentage with `%` suffix or empty
- `CLAUDE_CODE_USAGE` - Code session tokens formatted (e.g., "1.3M") or empty
- `CLAUDE_PRO_USAGE` - Pro usage percentages (e.g., "5h:76% 7d:17%") or empty
- `CLAUDE_RESET` - Reset time countdowns (e.g., "5h:4h23min 7d:Thu14:59") or empty

Empty values hide the corresponding segments in the status line.

**Removed in v1.9.0** (unused by oh-my-posh):
- `CLAUDE_DIR` - Directory name (oh-my-posh uses built-in `.Path`)
- `CLAUDE_GIT_BRANCH` - Git branch (oh-my-posh uses built-in `.HEAD`)
- `CLAUDE_GIT_STATUS` - Git status (oh-my-posh uses built-in `.Working.Changed`, etc.)
- `CLAUDE_STYLE` - Output style (never used)

**Important**: The path and git segments are handled natively by oh-my-posh:
- **Path segment**: Automatically reads from the `--pwd` parameter passed to oh-my-posh
- **Git segment**: Automatically detects git repository state when oh-my-posh runs in the directory
  - No environment variables needed
  - Oh-my-posh directly calls git commands for status, branch, upstream info
  - Configured via `"type": "git"` with `fetch_status` and `fetch_upstream_icon` options

### Oh-my-posh Segment Structure

Segments render left-to-right in order defined in `claude-statusline.omp.json`:
1. **Path segment** (type: path, diamond style)
   - Background: `#ff6b35` (orange)
   - Icon: `` (folder)
   - Shows current directory path using oh-my-posh's path segment
2. **Git segment** (type: git, powerline style)
   - Base background: `#fffb38` (yellow)
   - Dynamic backgrounds based on state (orange, red, cyan)
   - Oh-my-posh native git segment with full feature detection
   - Shows branch, upstream status, staging/working changes, stash count
   - Icons: `` (staged), `` (modified), `` (stash), `↑↓` (ahead/behind)
3. **Context segment** (type: text, powerline style)
   - Background: `#00897b` (teal)
   - Icon: `󰍛` (memory)
   - Reads `CLAUDE_CONTEXT` environment variable
4. **Usage segment** (type: text, powerline style)
   - Background: `#ff8c94` (pink)
   - Icon: `` (chart)
   - Reads `CLAUDE_USAGE` environment variable
5. **Model segment** (type: text, diamond style)
   - Background: `#3a86ff` (blue)
   - Icon: `󰯉` (AI/brain)
   - Reads `CLAUDE_MODEL` environment variable

Powerline symbols (`\ue0b0`, `\ue0b6`, etc.) create the connected appearance.

## Testing Infrastructure (v1.9.0+)

### Test Suite

Located in `tests/` directory, uses **bats-core** testing framework:
- **tests/common.bats** - Tests for shared utility functions (10 tests)
- **tests/statusline.bats** - Tests for main status line script (6 tests)
- **tests/fetch-code-usage.bats** - Tests for Code usage fetcher (4 tests)
- **tests/fetch-pro-usage.bats** - Tests for Pro usage fetcher (4 tests)
- **tests/update-usage.bats** - Tests for cache updater (3 tests)

### Running Tests

```bash
# Install bats-core
sudo apt install bats  # Ubuntu/Debian
brew install bats-core # macOS

# Run all tests
./run-tests.sh

# Run specific test file
bats tests/common.bats
```

### Test Coverage

- ✅ 27 total tests (22 passing, 5 skipped)
- ✅ All core functionality covered
- ✅ Cross-platform compatibility verified
- ✅ Version flag handling standardized
- ✅ Edge cases tested (missing files, null values, etc.)

## File Dependencies

### Runtime (Required)
- **oh-my-posh**: Must be in PATH (for status line rendering)
- **jq**: Required for JSON parsing
- **git**: Required for git segment (oh-my-posh native)
- **curl**: Required for Pro usage fetching
- **awk**: Required for math operations (no bc dependency since v1.9.0)

### Development (Optional)
- **bats-core**: For running unit tests
- **npx/npm**: For ccusage (Code usage tracking)
- **ccusage**: Can install globally for better performance

## Troubleshooting Workflow

1. **Status line not appearing**: Check `~/.claude/settings.json` has correct `statusLine.command` path
2. **Usage shows empty**: Run `bash ~/.claude/update-usage.sh` manually and check for errors
3. **Git status not showing**: Ensure you're in a git repository directory
4. **Slow rendering**: Install ccusage globally: `npm install -g ccusage` and change script to use `ccusage` instead of `npx ccusage`

## Configuration File Locations

All files install to `~/.claude/oh-my-claude/`:
- **Scripts**: `common.sh`, `statusline.sh`, `update-usage.sh`, `fetch-code-usage.sh`, `fetch-pro-usage.sh`
- **Config**: `claude-statusline.omp.json`
- **Cache**: `.usage_cache` (auto-generated, don't edit)
- **Version**: `VERSION` (current version number)

**Note:** OAuth credentials are auto-managed by Claude Code at `~/.claude/.credentials.json` (external to oh-my-claude).

## Performance Characteristics

- Status line render time: ~50ms (depends on oh-my-posh)
- Cache read: <1ms (simple file read + string parsing)
- Background update: 2-5s (ccusage API calls)
- Cache refresh frequency: Every 60s (when statusline.sh is called)
