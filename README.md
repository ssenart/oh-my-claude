# Claude Code Custom Status Line

A fully customized status line for Claude Code featuring:
- 🎨 Oh-my-posh powered theming with powerline separators
- 📊 Automatic token usage tracking (5-hour & weekly limits)
- 🔄 Advanced git status with staging, working changes, and upstream tracking
- 💾 Context window usage monitoring
- ⚡ Non-blocking background updates

## Quick Start

Your status line is already configured and running! It displays:

```
 path  branch-with-status 󰍛 XX%  5h:XX% (XM/YM) W:XX% (XM/YM) 󰯉 Model
```

## Files Overview

| File | Description |
|------|-------------|
| `statusline.sh` | Main script that renders the status line |
| `claude-statusline.omp.json` | Oh-my-posh theme configuration |
| `update-usage.sh` | Background script for usage tracking |
| `usage-limits.conf` | **EDIT THIS** - Your subscription token limits |
| `.usage_cache` | Auto-generated cache (don't edit) |
| `docs/STATUS_LINE_DOCUMENTATION.md` | Complete technical documentation |
| `docs/STATUS_LINE_QUICK_REFERENCE.md` | Common operations and commands |
| `docs/EXAMPLES.md` | Visual examples of all status line states |
| `docs/INDEX.md` | Documentation index and navigation guide |

## 📝 Important: Set Your Token Limits

Edit `~/.claude/usage-limits.conf` to match your subscription:

```bash
FIVE_HOUR_LIMIT=16000000   # Your 5-hour limit in tokens
WEEKLY_LIMIT=72000000      # Your weekly limit in tokens
```

Run `/usage` in Claude Code to see your actual limits, then update the config file.

## Common Tasks

### Update Usage Data
```bash
bash ~/.claude/update-usage.sh
```

### Change How Often Usage Updates
Edit `statusline.sh` and change:
```bash
cache_timeout=60  # Seconds (default: 60)
```

### Test the Status Line
```bash
echo '{"model":{"display_name":"Test"},"workspace":{"current_dir":"'$PWD'"},"output_style":{"name":"markdown"},"context_window":{"current_usage":{"input_tokens":1000},"context_window_size":200000}}' | bash ~/.claude/statusline.sh
```

## Customization

- **Colors**: Edit `claude-statusline.omp.json` → change `background` values
- **Icons**: Edit `claude-statusline.omp.json` → change `template` values
- **Segment order**: Rearrange `segments` array in `claude-statusline.omp.json`
- **Add segments**: See `docs/STATUS_LINE_DOCUMENTATION.md` for examples

## Status Indicators

| Symbol | Meaning |
|--------|---------|
| `` | Path/directory indicator |
| `` | Git upstream status indicator |
| `` | Staged files in git |
| `` | Modified files in git |
| `↑` | Commits ahead of remote |
| `↓` | Commits behind remote |
| `󰍛` | Memory/context usage indicator |
| `` | Usage statistics indicator |
| `󰯉` | Model indicator |

## How It Works

1. **Claude Code** calls `statusline.sh` on every refresh
2. **statusline.sh**:
   - Extracts data (model, directory, context, git status)
   - Checks usage cache (reads immediately, no waiting)
   - If cache is old (>60s), triggers `update-usage.sh` in background
   - Passes data to oh-my-posh
3. **oh-my-posh** renders the colored segments
4. **update-usage.sh** (background, every 60s):
   - Runs `npx ccusage` to get token usage
   - Calculates percentages based on your limits
   - Updates `.usage_cache`

## Performance

- **Status line render**: ~50ms (fast!)
- **Usage update**: ~2-5s (runs in background, doesn't block)
- **Cache**: Updates every 60 seconds automatically

## Optimization

To make usage updates faster, install ccusage globally:
```bash
npm install -g ccusage
```

Then edit `update-usage.sh` and replace `npx ccusage` with `ccusage`.

## Dependencies

- **oh-my-posh**: Already installed at `/c/Program Files (x86)/oh-my-posh/bin/oh-my-posh`
- **ccusage**: Runs via npx (no global install needed)
- **jq**: For JSON parsing (standard on Git Bash)
- **git**: For git status detection

## Troubleshooting

### Usage not updating?
```bash
# Test ccusage manually
npx ccusage blocks --active --json

# Check cache
cat ~/.claude/.usage_cache

# Force update
bash ~/.claude/update-usage.sh
```

### Git status not showing?
- Only visible when inside a git repository
- Navigate to a git repo and it will appear

### Status line not appearing?
```bash
# Check settings
cat ~/.claude/settings.json

# Should contain:
# "statusLine": {
#   "type": "command",
#   "command": "bash C:/Users/steph/.claude/statusline.sh",
#   "padding": 0
# }
```

## Documentation

- **Full docs**: `docs/STATUS_LINE_DOCUMENTATION.md` - Complete technical reference
- **Quick ref**: `docs/STATUS_LINE_QUICK_REFERENCE.md` - Common operations
- **Examples**: `docs/EXAMPLES.md` - Visual examples of all states
- **Index**: `docs/INDEX.md` - Documentation navigation guide
- **This file**: `README.md` - Overview and getting started

## Support

If you need to modify the status line:
1. Check `docs/STATUS_LINE_QUICK_REFERENCE.md` for common tasks
2. See `docs/STATUS_LINE_DOCUMENTATION.md` for advanced customization
3. Browse `docs/EXAMPLES.md` for visual references
4. All scripts are in `~/.claude/` and well-commented

---

**Created**: December 2024
**Version**: 1.5
**Tools**: oh-my-posh, ccusage, bash
