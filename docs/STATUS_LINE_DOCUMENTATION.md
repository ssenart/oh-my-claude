# Claude Code Custom Status Line Documentation

This document describes the custom status line implementation for Claude Code, featuring oh-my-posh integration, automatic usage tracking via ccusage, and git status indicators.

## Visual Example

![Status Line Example](example.png)

The screenshot above shows all segments in action: Path (orange), Git (yellow), Context (teal), Pro Usage (pink), Reset Times (purple), and Model (blue).

## Overview

The custom status line displays:
1. **Path** - Current working directory name
2. **Git Branch + Status** - Git branch with clean/dirty indicator (when in a git repo)
3. **Context Usage** - Conversation context window usage percentage
4. **Code Usage** - Session token count (optional, cyan)
5. **Pro Usage** - 5-hour and 7-day usage percentages (pink)
6. **Reset Times** - Countdown timers for usage limit resets (purple)
7. **Model** - Current Claude model being used

## Architecture

### Components

```
┌─────────────────────────────────────────────────────────────┐
│ Claude Code                                                 │
│   └─> Calls statusline.sh every refresh                    │
│       └─> Renders with oh-my-posh                          │
│           └─> Triggers update-usage.sh (every 60s)         │
│               └─> Uses ccusage to fetch token data         │
│                   └─> Writes to .usage_cache               │
└─────────────────────────────────────────────────────────────┘
```

### Files

| File | Purpose |
|------|---------|
| `~/.claude/statusline.sh` | Main status line script that processes JSON input and calls oh-my-posh |
| `~/.claude/update-usage.sh` | Background script that fetches usage data from Code and Pro APIs |
| `~/.claude/fetch-code-usage.sh` | Fetches Code session tokens using ccusage |
| `~/.claude/fetch-pro-usage.sh` | Fetches Pro usage percentages from Claude web API |
| `~/.claude/claude-statusline.omp.json` | Oh-my-posh theme configuration defining segments and colors |
| `~/.claude/.env` | API credentials (sessionKey, orgId) for Pro usage |
| `~/.claude/.usage_cache` | JSON cache file storing Code tokens and Pro percentages |

## Status Line Segments

### 1. Path (Orange)
- **Icon**: `` (folder icon)
- **Color**: `#ff6b35` (orange)
- **Style**: Diamond with leading/trailing powerline arrows
- **Shows**: Current working directory path (folder name)
- **Example**: ` oh-my-claude`

### 2. Git Status (Yellow/Orange/Red - Dynamic)
- **Type**: Full oh-my-posh git segment with rich status information
- **Base Color**: `#fffb38` (yellow)
- **Dynamic Colors**:
  - `#ff9248` (orange) - Working or staging changes present
  - `#f26d50` (red) - Both ahead and behind remote
  - `#f17c37` (orange-red) - Ahead of remote
  - `#89d1dc` (cyan) - Behind remote
- **Shows**:
  - Upstream icon (arrows showing ahead/behind status)
  - Branch name or commit hash
  - Branch status (ahead/behind counts)
  - Staging changes with  icon and count
  - Working changes with  icon and count
  - Stash count with  icon (if stashes exist)
- **Example**: ` main` or ` feature  +2 ~1`
- **Note**: Only visible when inside a git repository
- **Features**:
  - `fetch_status: true` - Shows file change statistics
  - `fetch_upstream_icon: true` - Shows sync status with remote

### 3. Context Usage (Teal)
- **Icon**: `󰍛` (memory/RAM symbol)
- **Color**: `#00897b` (teal)
- **Style**: Powerline
- **Shows**: Conversation context window usage percentage
- **Example**: `󰍛 24.7%`
- **Calculation**: `(input_tokens + cache_creation_tokens + cache_read_tokens) / context_window_size * 100`

### 4. Code Usage (Cyan) - Optional
- **Icon**: `#` (token count indicator)
- **Color**: `#00bcd4` (cyan)
- **Style**: Powerline
- **Shows**: Claude Code session token count
- **Format**: `# XX.XM`
- **Example**: `# 14.3M`
- **Updates**: Every 60 seconds via background process
- **Note**: Displays current session token count from Claude Code

### 5. Pro Usage (Pink)
- **Icon**: `󰓅` (gauge/meter icon)
- **Color**: `#ff8c94` (pink)
- **Style**: Powerline
- **Shows**: Claude Pro usage percentages for 5-hour and 7-day windows
- **Format**: `5h:XX% 7d:YY%`
- **Example**: `󰓅 5h:90% 7d:27%`
- **Updates**: Every 60 seconds via background process
- **Note**: Requires `CLAUDE_SESSION_KEY` and `CLAUDE_ORG_ID` in `.env`

### 6. Reset Times (Purple)
- **Icon**: `󰔛` (clock/timer icon)
- **Color**: `#9d4edd` (purple)
- **Style**: Powerline
- **Shows**: Countdown timers for when Pro usage limits reset
- **Format**: `5h:XXhYYmin 7d:DayHH:MM`
- **Example**: `󰔛 5h:2h1min 7d:Thu09:59`
- **Updates**: Every 60 seconds via background process
- **Note**: Shows time remaining for 5h window and absolute reset time for 7d window

### 7. Model (Blue)
- **Icon**: `󰯉` (AI/brain icon)
- **Color**: `#3a86ff` (blue)
- **Style**: Diamond with transparent leading powerline
- **Shows**: Current Claude model name
- **Example**: `󰯉 Sonnet 4.5`

## Installation & Setup

### Prerequisites

1. **npm** - Required for ccusage
2. **jq** - JSON parsing (usually pre-installed on Git Bash)
3. **oh-my-posh** - Installed at `/c/Program Files (x86)/oh-my-posh/bin/oh-my-posh`
4. **ccusage** - Can use via npx (no global install needed)

### Configuration

#### 1. Claude Settings (`~/.claude/settings.json`)

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash C:/Users/steph/.claude/statusline.sh",
    "padding": 0
  }
}
```

## How It Works

### Status Line Execution Flow

1. **Claude Code calls statusline.sh** - On every status line refresh
2. **statusline.sh receives JSON** - Contains model, directory, context window data
3. **Extract data**:
   - Model name
   - Current working directory
   - Context usage (input tokens, cache tokens)
   - Git branch and status (if in a git repo)
4. **Check usage cache**:
   - If cache is older than 60 seconds → trigger update-usage.sh in background
   - Read cached usage data immediately (no blocking)
5. **Export environment variables** - For oh-my-posh to consume
6. **Call oh-my-posh** - Renders the status line with configured theme
7. **Return rendered output** - Displayed by Claude Code

### Usage Tracking Flow

1. **update-usage.sh triggered** - Every 60 seconds (runs in background)
2. **Fetch Code usage** - Calls `fetch-code-usage.sh` (runs ccusage)
3. **Fetch Pro usage** - Calls `fetch-pro-usage.sh` (calls Claude web API)
   - Returns percentages and reset times for 5-hour and 7-day windows
4. **Write to cache** - JSON format with timestamps

### Cache Format

The `.usage_cache` file is in JSON format:

```json
{
  "code": {
    "session_tokens": 14363079
  },
  "pro": {
    "five_hour_pct": 73,
    "five_hour_resets_at": "2025-12-28T13:00:00.013344+00:00",
    "seven_day_pct": 24,
    "seven_day_resets_at": "2026-01-01T09:00:00.013357+00:00"
  },
  "updated_at": "2025-12-28T10:11:46Z"
}
```

## Customization

### Changing Segment Order

Edit `~/.claude/claude-statusline.omp.json` and reorder the `segments` array.

Current order (left to right):
1. Path
2. Git Status
3. Context Usage
4. Session & Weekly Usage
5. Model

### Changing Colors

Edit the `background` property in each segment:

```json
{
  "background": "#3a86ff",  // Hex color code
  "foreground": "#ffffff"   // Text color (usually white)
}
```

**Current color scheme:**
- Path: `#ff6b35` (orange)
- Git Status: `#fffb38` (yellow base, with dynamic color templates)
- Context Usage: `#00897b` (teal)
- Session & Weekly Usage: `#ff8c94` (pink)
- Model: `#3a86ff` (blue)

### Changing Icons

Edit the `template` property in the segment. Use [Nerd Fonts](https://www.nerdfonts.com/cheat-sheet) for icons.

Example:
```json
{
  "template": " {{ if .Env.CLAUDE_GIT_BRANCH }}{{ .Env.CLAUDE_GIT_STATUS }} {{ .Env.CLAUDE_GIT_BRANCH }}{{ end }} "
}
```

### Adjusting Cache Timeout

Edit `~/.claude/statusline.sh` and change:

```bash
cache_timeout=60  # Change to desired seconds (e.g., 120, 300)
```

**Trade-offs:**
- **Lower timeout** (30s): More up-to-date usage data, more CPU usage
- **Higher timeout** (300s): Less frequent updates, lower CPU usage

### Adding New Segments

1. **Extract data** in `statusline.sh`:
   ```bash
   export MY_NEW_DATA="value"
   ```

2. **Pass to oh-my-posh**:
   ```bash
   env -i \
     MY_NEW_DATA="$MY_NEW_DATA" \
     ...
   ```

3. **Add segment** to `claude-statusline.omp.json`:
   ```json
   {
     "type": "text",
     "style": "diamond",
     "leading_diamond": "",
     "trailing_diamond": "",
     "foreground": "#ffffff",
     "background": "#color",
     "template": " {{ .Env.MY_NEW_DATA }} "
   }
   ```

## Troubleshooting

### Status line not showing

1. Check Claude settings:
   ```bash
   cat ~/.claude/settings.json
   ```

2. Test the script manually:
   ```bash
   echo '{"model":{"display_name":"Test"},"workspace":{"current_dir":"'$PWD'"},"output_style":{"name":"markdown"},"context_window":{"current_usage":{"input_tokens":1000},"context_window_size":200000}}' | bash ~/.claude/statusline.sh
   ```

### Usage data not updating

1. Check if ccusage works:
   ```bash
   npx ccusage blocks --active --json
   ```

2. Manually run the update script:
   ```bash
   bash ~/.claude/update-usage.sh
   cat ~/.claude/.usage_cache
   ```

3. Check cache file permissions:
   ```bash
   ls -la ~/.claude/.usage_cache
   ```

### Git status not showing

- Only appears when inside a git repository
- Navigate to a git repo: `cd ~/source/your-project`
- Verify: `git status` should work

### Usage not showing

1. Check Pro usage setup (if using Pro tracking): See `PRO-USAGE-SETUP.md`
2. Manually trigger update:
   ```bash
   bash ~/.claude/update-usage.sh
   cat ~/.claude/.usage_cache | jq .
   ```
3. Test fetch scripts:
   ```bash
   bash ~/.claude/fetch-code-usage.sh --debug
   bash ~/.claude/fetch-pro-usage.sh --debug
   ```

## Performance Considerations

### CPU Usage

- **Status line refresh**: ~50ms (oh-my-posh rendering)
- **Git status check**: ~10-50ms (only when in git repo)
- **Usage update**: ~2-5 seconds (runs in background every 60s, doesn't block)

### Optimization Tips

1. **Install ccusage globally** to avoid npx overhead:
   ```bash
   npm install -g ccusage
   ```
   Then replace `npx ccusage` with `ccusage` in `fetch-code-usage.sh`

2. **Increase cache timeout** to reduce background updates:
   ```bash
   cache_timeout=120  # Update every 2 minutes instead of 1
   ```

3. **Disable git status** if in a large repo (edit claude-statusline.omp.json to remove git segment)

## Technical Details

### Environment Variables Passed to oh-my-posh

```bash
CLAUDE_MODEL="Sonnet 4.5"
CLAUDE_CONTEXT="45%"
CLAUDE_USAGE="5h:76% (12.2M/16M) W:17% (12.4M/72M)"
PATH="$PATH"  # For oh-my-posh to find itself and git
```

**Note**: Git status is now handled natively by oh-my-posh's git segment, which automatically detects the repository and status when oh-my-posh is called with the `--pwd` parameter.

### Oh-my-posh Segment Styles

The status line uses a mix of "diamond" and "powerline" styles:
- **Path segment**: Diamond style with `leading_diamond: "\ue0b6"` and `trailing_diamond: "\ue0b0"`
- **Git segment**: Powerline style with `powerline_symbol: "\ue0b0"`
- **Context segment**: Powerline style with `leading_powerline_symbol: "\uE0D6"` and `powerline_symbol: "\uE0B0"`
- **Usage segment**: Powerline style with empty `powerline_symbol`
- **Model segment**: Diamond style with transparent leading diamond and `trailing_diamond: "\ue0b4"`

This creates smooth transitions between colored segments.

### Git Status Detection

Git status is now handled entirely by oh-my-posh's built-in git segment type. Oh-my-posh automatically:
- Detects if the current directory is in a git repository
- Shows the current branch name or commit hash (if detached HEAD)
- Displays upstream status (ahead/behind remote)
- Shows staging area changes with file counts
- Shows working directory changes with file counts
- Displays stash count if stashes exist
- Dynamically changes background color based on repository state

The git segment is configured with:
```json
{
  "type": "git",
  "options": {
    "fetch_status": true,
    "fetch_upstream_icon": true
  }
}
```

## Credits & Resources

- **Claude Code**: https://claude.com/claude-code
- **oh-my-posh**: https://ohmyposh.dev/
- **ccusage**: https://ccusage.com/
- **Nerd Fonts**: https://www.nerdfonts.com/

## Version History

See [CHANGELOG.md](../CHANGELOG.md) for complete version history and changes.
