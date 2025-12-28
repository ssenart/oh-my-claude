# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a custom status line implementation for Claude Code featuring real-time token usage tracking, git status, context window monitoring, and oh-my-posh theming. The system uses a multi-script architecture with caching to provide fast, non-blocking updates.

## Core Architecture

### Three-Script System

1. **statusline.sh** - Main entry point called by Claude Code
   - Parses JSON input from stdin containing model, workspace, and context data
   - Extracts git status by directly calling `git` commands in the workspace directory
   - Reads cached usage data (never blocks waiting for updates)
   - Exports environment variables for oh-my-posh
   - Calls oh-my-posh to render the final status line

2. **update-usage.sh** - Background updater (runs async)
   - Called by statusline.sh when cache is >60s old
   - Runs `npx ccusage blocks --active --json` for current session tokens only
   - Runs `bash fetch-pro-usage.sh` for Claude Pro web usage percentages
   - Writes to `.usage_cache` in JSON format with timestamp

3. **fetch-pro-usage.sh** - Pro usage fetcher (optional)
   - Uses curl to call Claude web API
   - Authenticates with sessionKey cookie from .env
   - Fetches from `https://claude.ai/api/organizations/{ORG_ID}/usage`
   - Returns Pro usage percentages for 5-hour and 7-day windows

4. **claude-statusline.omp.json** - Oh-my-posh theme configuration
   - Defines powerline-style segments with colors and icons
   - Reads data from `CLAUDE_*` environment variables
   - Uses diamond and powerline styles for visual separation

### Key Design Decisions

- **Non-blocking updates**: statusline.sh never waits for ccusage/API calls (which take 2-5s). It always reads cached data immediately, triggering background updates only when cache is stale.
- **Cache format**: JSON with timestamp for clarity and easy inspection/debugging.
- **Git detection**: Uses both `.git` directory check and `git rev-parse` to handle normal repos and worktrees.
- **Simplified metrics**: Only shows current session tokens from Code (no percentages/limits - they were inaccurate) and Pro percentages from web API.
- **Pure bash Pro fetching**: Uses curl with browser-like headers to fetch Pro usage, no Node.js/Puppeteer needed.

## Common Commands

### Testing and Development

```bash
# Test the status line with mock data
echo '{"model":{"display_name":"Test"},"workspace":{"current_dir":"'$PWD'"},"output_style":{"name":"markdown"},"context_window":{"current_usage":{"input_tokens":1000},"context_window_size":200000}}' | bash ~/.claude/statusline.sh

# Force update usage cache
bash ~/.claude/update-usage.sh

# View current cache contents
cat ~/.claude/.usage_cache

# Test ccusage manually
npx ccusage blocks --active --json
npx ccusage weekly --json
```

### Configuration

```bash
# Edit token limits (REQUIRED after installation)
nano ~/.claude/usage-limits.conf

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
- `CLAUDE_USAGE` - Full usage string or empty (e.g., "5h:76% (12.2M/16M) W:17% (12.4M/72M)")

Empty values hide the corresponding segments in the status line.

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

## File Dependencies

- **oh-my-posh**: Must be in PATH or at `/c/Program Files (x86)/oh-my-posh/bin/oh-my-posh`
- **ccusage**: Runs via `npx` (no global install required, but global install improves performance)
- **jq**: Required for JSON parsing in both scripts
- **git**: Required for git status detection
- **bc or awk**: At least one required for percentage calculations

## Troubleshooting Workflow

1. **Status line not appearing**: Check `~/.claude/settings.json` has correct `statusLine.command` path
2. **Usage shows empty**: Run `bash ~/.claude/update-usage.sh` manually and check for errors
3. **Git status not showing**: Ensure you're in a git repository directory
4. **Percentages incorrect**: Verify limits in `usage-limits.conf` match actual subscription (use `/usage` command)
5. **Slow rendering**: Install ccusage globally: `npm install -g ccusage` and change script to use `ccusage` instead of `npx ccusage`

## Configuration File Locations

All files install to `~/.claude/`:
- Scripts: `statusline.sh`, `update-usage.sh`
- Config: `usage-limits.conf`, `claude-statusline.omp.json`
- Cache: `.usage_cache` (auto-generated, don't edit)
- Docs: `README.md`, `docs/` directory

## Performance Characteristics

- Status line render time: ~50ms (depends on oh-my-posh)
- Cache read: <1ms (simple file read + string parsing)
- Background update: 2-5s (ccusage API calls)
- Cache refresh frequency: Every 60s (when statusline.sh is called)
