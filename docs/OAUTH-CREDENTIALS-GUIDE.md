# OAuth Credentials for Pro Usage Tracking

## How It Works

Claude Code automatically manages OAuth credentials at `~/.claude/.credentials.json`. **No manual setup is required** - Pro usage tracking works automatically!

## What Changed

Previously, Pro usage tracking required:
- Manually extracting a browser cookie (`sessionKey`)
- Finding your organization ID
- Storing both in a `.env` file

Now it's automatic:
- Claude Code manages OAuth credentials
- Pro usage tracking uses the same credentials
- No `.env` file needed

## Verification

To verify your credentials are set up:

```bash
cat ~/.claude/.credentials.json | jq '.claudeAiOauth'
```

You should see:
```json
{
  "accessToken": "sk-ant-oat01-...",
  "refreshToken": "sk-ant-ort01-...",
  "expiresAt": 1766988267120,
  "scopes": ["user:inference", "user:profile", "user:sessions:claude_code"],
  "subscriptionType": "pro",
  "rateLimitTier": "default_claude_ai"
}
```

## Troubleshooting

### Pro usage not showing?

1. Check credentials exist:
```bash
ls -la ~/.claude/.credentials.json
```

2. Verify it contains OAuth data:
```bash
jq '.claudeAiOauth.accessToken' ~/.claude/.credentials.json
```

3. Force cache refresh:
```bash
bash ~/.claude/oh-my-claude/src/update-usage.sh
```

4. Check the cache file:
```bash
cat ~/.claude/oh-my-claude/.usage_cache | jq '.pro'
```

### Credentials expired?

OAuth tokens auto-refresh when you use Claude Code. If you encounter auth errors:

1. Re-authenticate with Claude Code (sign in again)
2. OAuth credentials will be updated automatically
3. Run update-usage.sh to refresh cache:
```bash
bash ~/.claude/oh-my-claude/src/update-usage.sh
```

### HTTP 401 or 403 errors?

Run the fetch script in debug mode to see the full error:

```bash
bash ~/.claude/oh-my-claude/src/fetch-pro-usage.sh --debug
```

If you see authentication errors:
- Ensure you're logged into Claude Code
- Try logging out and back in
- Verify your subscription is active at https://claude.ai/settings

### No Pro subscription?

Pro usage tracking only works if you have:
- Claude Pro subscription
- Claude Enterprise subscription

Free tier users won't see Pro usage data (only Code usage tokens).

## Technical Details

### API Endpoint

The script queries: `https://api.anthropic.com/api/oauth/usage`

### Response Format

```json
{
  "five_hour": {
    "utilization": 25.0,
    "resets_at": "2025-12-28T23:00:00.126845+00:00"
  },
  "seven_day": {
    "utilization": 40.0,
    "resets_at": "2026-01-01T09:00:00.126862+00:00"
  }
}
```

### Cache Location

Usage data is cached at: `~/.claude/oh-my-claude/.usage_cache`

Cache updates every 60 seconds when the status line is displayed.

### Implementation

See [../src/fetch-pro-usage.sh](../src/fetch-pro-usage.sh) for the full implementation.

## Migrating from Session Keys

If you previously used session keys, see [MIGRATION-GUIDE.md](MIGRATION-GUIDE.md) for migration information.

Your old `~/.claude/.env` file is no longer used and can be safely deleted.
