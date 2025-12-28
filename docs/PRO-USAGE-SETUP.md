# Claude Pro Usage Tracking Setup

This guide explains how to set up automated tracking of your Claude Pro web usage alongside Claude Code usage.

## What You Get

Your status line will now show both Code and Pro usage:
```
Code: 7.0M | Pro 5h:36% 7d:20%
      ^^^^^      ^^^^^^^^^^^^^^
      Session    Pro usage from API
      tokens     (5-hour and 7-day windows)
```

Clean and simple - just what you need to know!

## How It Works

1. **fetch-pro-usage.sh** - Fetches Pro usage from Claude's web API
   - Uses sessionKey cookie for authentication
   - Calls `https://claude.ai/api/organizations/{ORG_ID}/usage`
   - Returns percentages: `five_hour%:seven_day%`

2. **update-usage.sh** - Updated to fetch both Code and Pro usage
   - Calls `ccusage` for Code usage (existing)
   - Calls `fetch-pro-usage.sh` for Pro usage (new)
   - Writes 8 fields to cache (was 6 fields)

3. **statusline.sh** - Updated to display both
   - Reads 8-field cache format
   - Shows Code usage with token counts
   - Shows Pro usage with percentages only

## Setup Steps

### 1. Get Your Credentials

You need two values from your browser when logged into claude.ai:

**sessionKey:**
1. Open claude.ai in your browser (while logged in)
2. Open DevTools (F12) → Application tab → Cookies
3. Find `sessionKey` cookie value (starts with `sk-ant-sid01-...`)

**Organization ID:**
1. Go to https://claude.ai/settings/usage
2. Open DevTools (F12) → Network tab → Refresh page
3. Find the request to `.../organizations/{ID}/usage`
4. Copy the organization ID (UUID format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)

### 2. Update .env File

Edit `.env` in the repository:

```bash
CLAUDE_CODE_OAUTH_TOKEN=sk-ant-oat01-...  # (existing, keep as is)
CLAUDE_SESSION_KEY=sk-ant-sid01-...       # (add this)
CLAUDE_ORG_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  # (add this)
```

### 3. Copy Files to ~/.claude

```bash
cd ~/Qsync/Workspace/oh-my-claude

# Copy updated scripts from src/
cp src/update-usage.sh ~/.claude/
cp src/statusline.sh ~/.claude/
cp src/fetch-pro-usage.sh ~/.claude/
cp src/fetch-code-usage.sh ~/.claude/
cp src/claude-statusline.omp.json ~/.claude/
cp .env ~/.claude/

# Make fetch scripts executable
chmod +x ~/.claude/fetch-pro-usage.sh
chmod +x ~/.claude/fetch-code-usage.sh
```

### 4. Test

```bash
# Test Pro usage fetching
bash ~/.claude/fetch-pro-usage.sh --debug

# Expected output:
# Fetching: https://claude.ai/api/organizations/.../usage
# HTTP 200
# Response: { "five_hour": { "utilization": 36.0 }, ... }
# 36:20

# Test cache update
bash ~/.claude/update-usage.sh
cat ~/.claude/.usage_cache

# Expected: JSON format
# {
#   "code": { "session_tokens": 7991282 },
#   "pro": { "five_hour_pct": 41, "seven_day_pct": 20 },
#   "updated_at": "2025-12-28T09:31:27Z"
# }
```

### 5. Verify in Status Line

Your next Claude Code prompt should show the updated status line with both Code and Pro usage.

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

### "ERROR: CLAUDE_SESSION_KEY not found in .env"

Solution: Add `CLAUDE_SESSION_KEY=sk-ant-sid01-...` to `.env` file

### "ERROR: HTTP 403"

Problem: Cloudflare is blocking the request or sessionKey is invalid

Solutions:
1. Update your sessionKey (they expire periodically)
2. Check browser headers match the script headers
3. Verify you can access claude.ai/settings/usage in your browser

### Pro usage not showing in status line

Check:
```bash
# Is cache valid JSON?
cat ~/.claude/.usage_cache | jq .
# Should output formatted JSON

# Are Pro fields populated?
cat ~/.claude/.usage_cache | jq '.pro'
# Should output: { "five_hour_pct": 41, "seven_day_pct": 20 }

# Is fetch-pro-usage.sh working?
bash ~/.claude/fetch-pro-usage.sh
# Should output: 41:20 (or similar)
```

### sessionKey expired

sessionKeys expire after a period of inactivity. When this happens:

1. Log into claude.ai in your browser
2. Get new sessionKey from cookies
3. Update `.env` with new sessionKey
4. Copy updated `.env` to `~/.claude/`

## Maintenance

**How often do sessionKeys expire?**
- Varies, but typically days to weeks
- You'll know it expired when Pro usage stops showing

**Updating sessionKey:**
```bash
# Edit .env in repo
nano .env

# Copy to ~/.claude
cp .env ~/.claude/

# Test
bash ~/.claude/fetch-pro-usage.sh --debug
```

## Security Notes

- `.env` contains authentication credentials - keep it secure
- Don't commit `.env` to git (it's in .gitignore)
- sessionKey gives access to your Claude account - treat it like a password
- Tokens are stored in plain text in `.env` - protect file permissions:
  ```bash
  chmod 600 ~/.claude/.env
  ```

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
    ├─→ Reads sessionKey and org ID from .env
    ├─→ curl https://claude.ai/api/organizations/{ORG_ID}/usage
    ├─→ Parses JSON response
    └─→ Outputs: five_hour_pct:seven_day_pct
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
mv ~/.claude/fetch-pro-usage.sh ~/.claude/fetch-pro-usage.sh.disabled
```

**Q: Does this use the OAuth token?**
A: No, the OAuth token is for Claude Code. Pro usage uses the sessionKey cookie.

**Q: Why percentages only for Pro (no token counts)?**
A: The Claude web API only returns percentage utilization, not absolute token counts.

**Q: Why no weekly Code usage or percentages?**
A: The ccusage weekly data was inaccurate. We now only show current session tokens, which is the most reliable metric.

**Q: Can I get monthly usage instead of weekly?**
A: The API returns both 5-hour and 7-day windows. There's no monthly endpoint currently.

**Q: Is this rate limited?**
A: Updates run every 60 seconds. Claude's API may have rate limits, but this frequency is conservative.

## Changelog

- **2025-12-28**: Initial implementation using sessionKey authentication and bash/curl
