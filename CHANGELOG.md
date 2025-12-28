# Changelog - Claude Code Custom Status Line

## Version 1.6 - Current (2024-12-28)

### Changed
- **Removed OAuth token authentication**: Simplified to use only sessionKey authentication
  - OAuth tokens are not supported for usage tracking endpoints
  - Only sessionKey method works reliably for individual organizations
- **Interactive credential setup**: Installation script now prompts for credentials interactively
  - No need to manually edit `.env` after installation
  - Guides users through extracting sessionKey from browser
  - Suggests organization ID automatically

### Added
- `setup-env.sh` - Interactive credential configuration script
  - Can be run standalone or called by install.sh
  - Prompts for sessionKey and organization ID
  - Creates `.env` file with proper formatting
- `GET_SESSION_KEY.md` - Comprehensive guide for extracting browser credentials
  - Step-by-step instructions for Chrome, Firefox, Safari
  - Screenshots and detailed explanations
  - Security notes and best practices

### Removed
- All references to `CLAUDE_CODE_OAUTH_TOKEN` from codebase
- OAuth-related test scripts (10 files)
- `.credentials.json` OAuth credential file

### Documentation
- Updated all documentation to reflect sessionKey-only authentication
- Removed OAuth references from:
  - README.md
  - INSTALLATION.md
  - PRO-USAGE-SETUP.md
  - STATUS_LINE_DOCUMENTATION.md
  - .env.example
- Enhanced installation documentation with interactive setup flow

## Version 1.5 (2024-12-28)

### Added
- Context usage icon (󰍛) before percentage
- Visual example screenshot (`docs/example.png`) showcasing the status line
- Comprehensive documentation suite:
  - `STATUS_LINE_DOCUMENTATION.md` - Complete technical reference
  - `STATUS_LINE_QUICK_REFERENCE.md` - Common operations guide
  - `EXAMPLES.md` - Visual examples with detailed segment breakdown
  - `INSTALLATION.md` - Comprehensive installation guide
  - `PRO-USAGE-SETUP.md` - Pro usage tracking setup guide
  - `INDEX.md` - Documentation navigation index
  - `CLAUDE.md` - Architecture guide for developers
  - `README.md` - Overview and getting started
  - `CHANGELOG.md` - This file

### Enhanced
- All documentation files now include the visual example with detailed segment explanations
- README features screenshot at the top with segment breakdown table
- EXAMPLES.md includes detailed color codes, icons, and real-world workflow examples

## Version 1.4 (2024-12-27)

### Changed
- Reordered segments for better workflow visibility:
  1. Directory (most dynamic)
  2. Git branch + status
  3. Context usage
  4. Session & weekly limits
  5. Model (most static)
- Previous order was: Model → Directory → Git → Context → Usage

### Rationale
- Left-to-right flow from most dynamic to most static information
- Context-specific info (where you are, what you're working on) comes first
- Resource warnings visible but not dominant
- Model reference info moved to the end as it rarely changes

## Version 1.3 (2024-12-27)

### Added
- Absolute token counts alongside percentages in usage segment
- Format: `5h:XX% (YYM/ZZM) W:XX% (YYM/ZZM)`
- Example: `5h:76% (12.2M/16M) W:17% (12.4M/72M)`

### Changed
- Updated cache format to include token counts and limits
- Cache format: `session_pct:weekly_pct:session_tokens:weekly_tokens:five_hour_limit:weekly_limit`

### Technical
- Added token formatting logic (converts to millions with 1 decimal place)
- Modified `update-usage.sh` to include all 6 values in cache
- Modified `statusline.sh` to parse and format extended cache data

## Version 1.2 (2024-12-27)

### Added
- Git branch detection and display
- Git clean/dirty status indicators:
  - `✓` - Clean repository (all changes committed)
  - `●` - Dirty repository (uncommitted changes present)
- Green segment with git information

### Technical
- Uses `git branch --show-current` to get branch name
- Falls back to `git rev-parse --short HEAD` for detached HEAD state
- Uses `git status --porcelain` to detect uncommitted changes
- Only visible when inside a git repository

## Version 1.1 (2024-12-27)

### Added
- Automatic token usage tracking via ccusage
- 5-hour session usage percentage and weekly usage percentage
- Configurable token limits via `usage-limits.conf`
- Background update script (`update-usage.sh`)
- Usage cache system (`.usage_cache`)
- Orange segment displaying usage information

### Configuration Files
- `usage-limits.conf` - User-configurable token limits:
  - `FIVE_HOUR_LIMIT` - 5-hour session token limit
  - `WEEKLY_LIMIT` - Weekly token limit

### Technical Details
- Uses `npx ccusage blocks --active --json` for session data
- Uses `npx ccusage weekly --json` for weekly data
- Caches results for 60 seconds to avoid excessive API calls
- Background updates (non-blocking)
- Automatic percentage calculation based on configured limits

### Dependencies
- Introduced dependency on ccusage (via npx)
- Requires jq for JSON parsing

## Version 1.0 (2024-12-27)

### Initial Implementation
- Basic status line with oh-my-posh integration
- Four segments:
  1. Model (purple) -  icon
  2. Directory (blue) -  icon
  3. Output style (cyan) -  icon
  4. Context usage (pink) -  icon

### Features
- Powerline-style diamond segments with  separators
- Color-coded segments with Nerd Font icons
- Real-time context window usage tracking
- Displays model name and current directory
- Shows output style (markdown/plain)

### Technical Setup
- Main script: `statusline.sh`
- Oh-my-posh theme: `claude-statusline.omp.json`
- Integration via Claude settings.json
- Receives JSON input from Claude Code with:
  - Model information
  - Workspace/directory
  - Output style
  - Context window usage

### Dependencies
- oh-my-posh (for rendering)
- bash (for scripting)
- jq (for JSON parsing)

## Removed Features

### v1.1 → v1.2
- **Removed**: Output style segment (cyan)
- **Reason**: Not useful for daily workflow, static information

## Performance Metrics

### Current Performance (v1.5)
- **Status line render**: ~50ms
- **Git status check**: ~10-50ms (only when in git repo)
- **Usage update**: ~2-5s (background, every 60s)
- **Total overhead**: Negligible for user experience

### Optimization History
- v1.1: Usage updates ran synchronously (blocked for 2-5s) ❌
- v1.2: Moved to background updates with caching ✅
- v1.3: No performance impact (cache format change only)
- v1.4: No performance impact (reordering only)
- v1.5: No performance impact (documentation only)

## Breaking Changes

### None
All versions are backward compatible. Cache format changes are handled gracefully with fallbacks.

## Migration Notes

If upgrading from an older version:

### From v1.0 → v1.1+
1. Create `~/.claude/usage-limits.conf` with your token limits
2. Add `update-usage.sh` script
3. Usage data will auto-populate on first refresh

### From v1.1 → v1.3+
- Cache will auto-update to new format
- Old cache format still works (shows percentages only)

### From v1.2 → v1.4+
- No migration needed, just reordered segments

## Known Issues

### Current
- None

### Resolved
- ✅ v1.1: Usage updates blocked status line rendering → Fixed in v1.2 with background updates
- ✅ v1.2: Cache could become stale if update script failed → Fixed with better error handling

## Future Considerations

### Potential Enhancements
- Color-coded usage warnings (red when >80%)
- Additional git information (ahead/behind remote)
- Cost tracking alongside token usage
- Multiple cache timeout configs (different for git vs usage)
- Export metrics to external monitoring

### Performance Optimizations
- Install ccusage globally to remove npx overhead
- Parallel git and usage checks
- Incremental cache updates (only changed data)

## Credits

Developed for Claude Code with:
- **oh-my-posh** - Theme rendering engine
- **ccusage** - Token usage tracking
- **Nerd Fonts** - Icons and symbols
- **Git Bash** - Shell environment

---

**Maintained**: December 2024
**Last Updated**: 2024-12-28
