# Claude Status Line - Quick Reference

## Common Operations

### Update Token Limits

Edit `~/.claude/usage-limits.conf`:
```bash
FIVE_HOUR_LIMIT=16000000
WEEKLY_LIMIT=72000000
```

Then run:
```bash
bash ~/.claude/update-usage.sh
```

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
4. Session & Weekly Limits (Pink)
5. Model (Blue)

### Token Limits
- **5-hour**: 16M tokens
- **Weekly**: 72M tokens

### Update Frequency
- **Cache timeout**: 60 seconds
- **Background updates**: Non-blocking

## Files Location

```
~/.claude/
├── README.md                        # Getting started guide
├── CLAUDE.md                        # Guide for Claude Code
├── CHANGELOG.md                     # Version history
│
├── docs/                            # Documentation folder
│   ├── INDEX.md                     # Documentation index
│   ├── STATUS_LINE_DOCUMENTATION.md # Full technical docs
│   ├── STATUS_LINE_QUICK_REFERENCE.md # This file
│   └── EXAMPLES.md                  # Visual examples
│
├── statusline.sh                    # Main status line script
├── claude-statusline.omp.json       # Oh-my-posh theme
├── update-usage.sh                  # Usage updater script
├── usage-limits.conf                # Your token limits
└── .usage_cache                     # Cached usage data
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
 oh-my-claude  main 󰍛 45%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```

Where:
- ** oh-my-claude** = Current directory (path segment, orange)
- ** main** = Git branch with upstream status (yellow, dynamic colors based on status)
- **󰍛 45%** = Context window 45% full (teal)
- ** 5h:76% (12.2M/16M) W:17% (12.4M/72M)** = Session and weekly usage (pink)
- **󰯉 Sonnet 4.5** = Current model (blue)
