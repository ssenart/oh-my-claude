# OAuth Migration Guide

## What Changed

Pro usage tracking now uses OAuth credentials instead of session keys.

**Before**: Required manual extraction of `sessionKey` cookie and organization ID from browser
**After**: Uses OAuth credentials automatically managed by Claude Code

## For Existing Users

**No action needed!** Simply update to the latest version and Pro tracking continues working seamlessly.

Your old `~/.claude/.env` file is no longer used. You can delete it if you prefer:

```bash
rm ~/.claude/.env
```

## Why This Change

### Simplicity
- **Before**: Open browser DevTools → Find cookies → Extract sessionKey → Copy org ID → Paste into .env
- **After**: Works automatically - no manual steps

### Reliability
- **Before**: Session keys expire, requiring periodic re-extraction from browser
- **After**: OAuth tokens auto-refresh - no manual maintenance

### Security
- **Before**: Browser cookies repurposed for API auth
- **After**: Standard OAuth 2.0 bearer tokens designed for API usage

### Maintainability
- **Before**: Custom endpoint with browser-like headers to bypass CORS
- **After**: Official OAuth API endpoint with standard authentication

## Technical Details

### Authentication Method

**Old**:
```bash
curl -H "Cookie: sessionKey=$SESSION_KEY" \
     -H "User-Agent: Mozilla/5.0..." \
     -H "Referer: https://claude.ai/settings/usage" \
     [8+ browser-like headers] \
     "https://claude.ai/api/organizations/{ORG_ID}/usage"
```

**New**:
```bash
curl -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Accept: application/json" \
     -H "User-Agent: claude-code/2.0.32" \
     -H "anthropic-beta: oauth-2025-04-20" \
     "https://api.anthropic.com/api/oauth/usage"
```

### Credential Storage

**Old**:
- Location: `~/.claude/.env` (user-created)
- Format: Plain text key-value pairs
- Fields: `CLAUDE_SESSION_KEY`, `CLAUDE_ORG_ID`

**New**:
- Location: `~/.claude/.credentials.json` (auto-managed)
- Format: JSON with OAuth structure
- Fields: `accessToken`, `refreshToken`, `expiresAt`, `scopes`

### API Endpoints

| Aspect | Old (Session Key) | New (OAuth) |
|--------|------------------|-------------|
| **Endpoint** | `https://claude.ai/api/organizations/{ORG_ID}/usage` | `https://api.anthropic.com/api/oauth/usage` |
| **Auth Type** | Cookie-based | Bearer token |
| **Credentials** | 2 values (sessionKey + org ID) | 1 value (accessToken) |
| **Expiration** | Manual refresh required | Auto-refreshes |
| **Setup** | Manual extraction | Automatic |

### Response Format

Both endpoints return the same JSON structure (no breaking changes):

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

## Backward Compatibility

### Cache Format
**No changes** - The cache file format remains identical:
```json
{
  "code": { "session_tokens": 8932659 },
  "pro": {
    "five_hour_pct": 25,
    "five_hour_resets_at": "2025-12-28T23:00:00.126845+00:00",
    "seven_day_pct": 40,
    "seven_day_resets_at": "2026-01-01T09:00:00.126862+00:00"
  },
  "updated_at": "2025-12-28T09:36:41Z"
}
```

### Status Line Display
**No changes** - The oh-my-posh status line displays the same information in the same format.

### Upgrade Path
1. Pull latest code
2. OAuth credentials already exist at `~/.claude/.credentials.json`
3. Pro tracking works immediately
4. Old `.env` file ignored (can be deleted manually)

## Files Removed

The following files are no longer needed:

- `src/setup-env.sh` - Interactive credential setup script (deleted)
- `.env.example` - Environment variable template (deleted)
- `~/.claude/.env` - User credential file (no longer used)

## Documentation Updates

**New**:
- [`docs/OAUTH-CREDENTIALS-GUIDE.md`](docs/OAUTH-CREDENTIALS-GUIDE.md) - OAuth credentials guide

**Updated**:
- [`docs/PRO-USAGE-SETUP.md`](docs/PRO-USAGE-SETUP.md) - Simplified setup guide
- [`docs/INSTALLATION.md`](docs/INSTALLATION.md) - Removed credential prompts
- [`README.md`](README.md) - Updated to reflect automatic OAuth tracking

**Removed**:
- `docs/GET_SESSION_KEY.md` - Session key extraction guide (no longer needed)

## Troubleshooting

### Pro usage stopped working after update?

1. Verify OAuth credentials exist:
```bash
cat ~/.claude/.credentials.json | jq '.claudeAiOauth.accessToken'
```

2. Force refresh:
```bash
bash ~/.claude/oh-my-claude/src/update-usage.sh
```

3. Check for errors in debug mode:
```bash
bash ~/.claude/oh-my-claude/src/fetch-pro-usage.sh --debug
```

### Still have questions?

See the [OAuth Credentials Guide](docs/OAUTH-CREDENTIALS-GUIDE.md) for detailed troubleshooting.

## Benefits Summary

| Benefit | Impact |
|---------|--------|
| **Zero manual setup** | Installation is fully automatic |
| **No credential extraction** | No browser DevTools needed |
| **Auto-refresh** | Never need to update credentials |
| **Single credential** | Simpler than session key + org ID |
| **Standard OAuth** | Uses official Anthropic OAuth API |
| **Better errors** | Clearer troubleshooting guidance |

Welcome to simpler Pro usage tracking!
