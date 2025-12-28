# Claude Status Line - Quick Reference

## Common Operations

### Force Usage Update

```bash
bash ~/.claude/update-usage.sh
cat ~/.claude/.usage_cache
```

### Test Status Line

```bash
echo '{"model":{"display_name":"Test"},"workspace":{"current_dir":"'$PWD'"},"output_style":{"name":"markdown"},"context_window":{"current_usage":{"input_tokens":1000},"context_window_size":200000}}' | bash ~/.claude/statusline.sh
```

### Change Cache Timeout

Edit `~/.claude/statusline.sh`:
```bash
cache_timeout=120  # Seconds between updates
```

### Change Segment Order

Edit `~/.claude/claude-statusline.omp.json` and reorder the `segments` array.

### Change Colors

Edit segment colors in `~/.claude/claude-statusline.omp.json`:
```json
{
  "background": "#hexcolor",
  "foreground": "#ffffff"
}
```

## Current Configuration

### Segment Order (Left to Right)
1. Path (Orange)
2. Git Status (Yellow/Dynamic)
3. Context Usage (Teal)
4. Code Usage - Session Tokens (Cyan)
5. Pro Usage - 5h/7d Percentages (Pink)
6. Reset Times - 5h/7d Countdowns (Purple)
7. Model (Blue)

### Update Frequency
- **Cache timeout**: 60 seconds
- **Background updates**: Non-blocking

## Files Location

```
~/.claude/
├── statusline.sh                    # Main status line script
├── update-usage.sh                  # Usage cache updater
├── fetch-code-usage.sh              # Code session token fetcher
├── fetch-pro-usage.sh               # Pro usage fetcher
├── claude-statusline.omp.json       # Oh-my-posh theme
├── .env                             # API credentials
└── .usage_cache                     # Cached usage data (JSON)
```

## Troubleshooting Commands

```bash
# Check if oh-my-posh is installed
oh-my-posh --version

# Check if ccusage works
npx ccusage blocks --active --json

# Check git status detection
git status

# View current cache
cat ~/.claude/.usage_cache

# View Claude settings
cat ~/.claude/settings.json

# Manually trigger update
bash ~/.claude/update-usage.sh
```

## Example Status Line Output

```
 oh-my-claude  main 󰍛 45% # 14.3M 󰓅 5h:73% 7d:24% 󰔛 5h:3h7min 7d:Thu09:59 󰯉 Sonnet 4.5
```

Where:
- ** oh-my-claude** = Current directory (path segment, orange)
- ** main** = Git branch with upstream status (yellow, dynamic colors based on status)
- **󰍛 45%** = Context window 45% full (teal)
- **# 14.3M** = Code session tokens (cyan)
- **󰓅 5h:73% 7d:24%** = Pro usage percentages (pink)
- **󰔛 5h:3h7min 7d:Thu09:59** = Reset time countdowns (purple)
- **󰯉 Sonnet 4.5** = Current model (blue)
