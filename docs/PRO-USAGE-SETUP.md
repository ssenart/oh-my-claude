# Claude Pro Usage Tracking Setup

This guide explains automated tracking of your Claude Pro web usage alongside Claude Code usage. **No setup required** - it works automatically with OAuth credentials!

## What You Get

![Status Line Example](example.png)

The status line shows Pro usage percentages and reset times:
- **Pro Usage (pink)**: `󰓅 5h:90% 7d:27%` - Usage in 5-hour and 7-day windows
- **Reset Times (purple)**: `󰔛 5h:2h1min 7d:Thu09:59` - When limits reset

This gives you real-time visibility into your Claude Pro usage right in Claude Code!

## How It Works

1. **fetch-pro-usage.sh** - Fetches Pro usage from Anthropic's OAuth API
   - Uses OAuth credentials from `~/.claude/.credentials.json`
   - Calls `https://api.anthropic.com/api/oauth/usage`
   - Returns percentages and reset times

2. **update-usage.sh** - Fetches both Code and Pro usage
   - Calls `ccusage` for Code usage
   - Calls `fetch-pro-usage.sh` for Pro usage
   - Writes JSON to cache

3. **statusline.sh** - Displays both metrics
   - Reads JSON cache format
   - Shows Code usage with token counts
   - Shows Pro usage with percentages and reset times

## Setup (Automatic!)

Pro usage tracking is **fully automatic** - your OAuth credentials are managed by Claude Code at `~/.claude/.credentials.json`.

### Requirements

Just ensure:
1. You're logged into Claude Code
2. You have a Pro or Enterprise subscription
3. Pro usage will appear in your status line automatically!

### Verification

To verify OAuth credentials are available:

```bash
# Check OAuth credentials exist
cat ~/.claude/.credentials.json | jq '.claudeAiOauth.accessToken'
# Should output: "sk-ant-oat01-..."

# Test Pro usage fetching
bash ~/.claude/oh-my-claude/src/fetch-pro-usage.sh --debug

# Expected output:
# Fetching: https://api.anthropic.com/api/oauth/usage
# HTTP 200
# Response: { "five_hour": { "utilization": 25.0 }, ... }
# 25|40|2025-12-28T23:00:00...

# Test cache update
bash ~/.claude/oh-my-claude/src/update-usage.sh
cat ~/.claude/oh-my-claude/.usage_cache | jq .

# Expected: JSON format with both code and pro fields
# {
#   "code": { "session_tokens": 7991282 },
#   "pro": {
#     "five_hour_pct": 25,
#     "five_hour_resets_at": "2025-12-28T23:00:00...",
#     "seven_day_pct": 40,
#     "seven_day_resets_at": "2026-01-01T09:00:00..."
#   },
#   "updated_at": "2025-12-28T09:31:27Z"
# }
```

That's it! Your status line will automatically show Pro usage.

## Cache Format

The `.usage_cache` file is in JSON format for clarity:

```json
{
  "code": {
    "session_tokens": 8932659
  },
  "pro": {
    "five_hour_pct": 47,
    "five_hour_resets_at": "2025-12-28T13:00:00.422966+00:00",
    "seven_day_pct": 21,
    "seven_day_resets_at": "2026-01-01T09:00:00.422983+00:00"
  },
  "updated_at": "2025-12-28T09:36:41Z"
}
```

Fields:
- **code.session_tokens**: Total tokens used in current Code session
- **pro.five_hour_pct**: Pro usage percentage (5-hour window)
- **pro.five_hour_resets_at**: When 5-hour window resets (ISO 8601 timestamp)
- **pro.seven_day_pct**: Pro usage percentage (7-day window)
- **pro.seven_day_resets_at**: When 7-day window resets (ISO 8601 timestamp)
- **updated_at**: When cache was last updated (ISO 8601 timestamp)

**Example queries:**
```bash
# When does 5-hour window reset?
cat ~/.claude/.usage_cache | jq -r '.pro.five_hour_resets_at'
# Output: 2025-12-28T13:00:00.422966+00:00

# When does 7-day window reset?
cat ~/.claude/.usage_cache | jq -r '.pro.seven_day_resets_at'
# Output: 2026-01-01T09:00:00.422983+00:00
```

## Troubleshooting

### Pro usage not showing?

1. Check OAuth credentials exist:
```bash
cat ~/.claude/.credentials.json | jq '.claudeAiOauth'
```

2. Verify access token is present:
```bash
jq '.claudeAiOauth.accessToken' ~/.claude/.credentials.json
```

3. Force cache refresh:
```bash
bash ~/.claude/oh-my-claude/src/update-usage.sh
```

4. Check cache for Pro data:
```bash
cat ~/.claude/oh-my-claude/.usage_cache | jq '.pro'
# Should output Pro usage fields
```

5. Test fetch script directly:
```bash
bash ~/.claude/oh-my-claude/src/fetch-pro-usage.sh --debug
```

### "ERROR: Could not extract access token"

OAuth credentials file is missing or invalid.

Solutions:
1. Ensure you're logged into Claude Code
2. Try logging out and back in to refresh credentials
3. Verify file exists: `ls -la ~/.claude/.credentials.json`

### "ERROR: HTTP 401" or "HTTP 403"

Authentication failed.

Solutions:
1. Re-authenticate with Claude Code (sign out and back in)
2. OAuth tokens will auto-refresh
3. Force update: `bash ~/.claude/oh-my-claude/src/update-usage.sh`

### No Pro subscription?

Pro usage tracking only works with:
- Claude Pro subscription
- Claude Enterprise subscription

Free tier users will only see Code usage tokens.

## Security Notes

- OAuth credentials at `~/.claude/.credentials.json` are auto-managed by Claude Code
- Credentials give access to your Claude account - file permissions should be `600`
- Tokens auto-refresh - no manual credential management needed

## Performance

- **fetch-pro-usage.sh**: ~200ms per call (curl request)
- **Total update time**: Same as before (~2-5s) since it runs in parallel
- **Update frequency**: Every 60 seconds (configurable in statusline.sh)
- **No blocking**: All fetches happen in background

## Architecture

```
statusline.sh (every time Claude Code renders status)
    ├─→ Reads ~/.claude/.usage_cache (instant, non-blocking)
    └─→ If cache >60s old: triggers update-usage.sh in background

update-usage.sh (runs in background)
    ├─→ npx ccusage blocks --json (Code session tokens only)
    ├─→ bash fetch-pro-usage.sh (Pro usage percentages) ← NEW
    └─→ Writes JSON to .usage_cache with timestamp

fetch-pro-usage.sh (called by update-usage.sh)
    ├─→ Reads OAuth accessToken from ~/.claude/.credentials.json
    ├─→ curl https://api.anthropic.com/api/oauth/usage
    ├─→ Parses JSON response
    └─→ Outputs: five_hour_pct|seven_day_pct|five_hour_resets|seven_day_resets
```

## Display Format

You can customize the display in `statusline.sh` around line 95:

```bash
# Current format:
usage_display="Code: ${session_m}M | Pro 5h:${pro_five_hour_usage}% 7d:${pro_seven_day_usage}%"

# Code only:
usage_display="Code: ${session_m}M"

# Pro only:
usage_display="Pro 5h:${pro_five_hour_usage}% 7d:${pro_seven_day_usage}%"

# Compact format:
usage_display="C:${session_m}M P:${pro_five_hour_usage}%/${pro_seven_day_usage}%"
```

## FAQ

**Q: Will this work if I'm not a Pro subscriber?**
A: The scripts will try to fetch Pro usage but fail gracefully. Only Code usage will show.

**Q: Can I disable Pro tracking temporarily?**
A: Yes, rename `fetch-pro-usage.sh` to disable:
```bash
mv ~/.claude/oh-my-claude/src/fetch-pro-usage.sh ~/.claude/oh-my-claude/src/fetch-pro-usage.sh.disabled
```

**Q: Does this use OAuth authentication?**
A: Yes! Pro usage tracking now uses OAuth credentials automatically managed by Claude Code at `~/.claude/.credentials.json`.

**Q: Why percentages only for Pro (no token counts)?**
A: The Claude web API only returns percentage utilization, not absolute token counts.

**Q: Why no weekly Code usage or percentages?**
A: The ccusage weekly data was inaccurate. We now only show current session tokens, which is the most reliable metric.

**Q: Can I get monthly usage instead of weekly?**
A: The API returns both 5-hour and 7-day windows. There's no monthly endpoint currently.

**Q: Is this rate limited?**
A: Updates run every 60 seconds. Claude's API may have rate limits, but this frequency is conservative.

## Version History

See [../CHANGELOG.md](../CHANGELOG.md) for complete version history and changes.
