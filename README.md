# Claude Code Custom Status Line

![Example Status Line](docs/example.png)

A fully customized status line for Claude Code featuring:
- 🎨 Oh-my-posh powered theming with powerline separators
- 📊 Automatic token usage tracking (Code session + Pro web usage)
- 🔄 Advanced git status with staging, working changes, and upstream tracking
- 💾 Context window usage monitoring
- ⚡ Non-blocking background updates with JSON caching
- 🕐 Reset time countdowns for Pro usage limits

## Installation

> **📖 Full Installation Guide**: See [docs/INSTALLATION.md](docs/INSTALLATION.md) for detailed installation instructions, troubleshooting, and platform-specific notes.

### Quick Install (Recommended)

Install directly from GitHub without cloning:

```bash
curl -s https://raw.githubusercontent.com/ssenart/oh-my-claude/main/install.sh | bash
```

**Custom installation directory:**
```bash
curl -s https://raw.githubusercontent.com/ssenart/oh-my-claude/main/install.sh | bash -s -- -d ~/.custom/location
```

This will:
- ✅ Check for required dependencies (oh-my-posh, jq, git, npx)
- ✅ Download and install all scripts to `~/.claude/oh-my-claude/`
- ✅ Backup and update your `~/.claude/settings.json`
- ✅ Make all scripts executable

Pro usage tracking is automatic - no credentials needed!

**Security Note**: The installer only writes to your home directory and never requests sudo access. You can review the script before running: [View install.sh](https://github.com/ssenart/oh-my-claude/blob/main/install.sh)

### Alternative: Local Installation

For development or if you prefer to clone the repository:

```bash
git clone https://github.com/ssenart/oh-my-claude.git
cd oh-my-claude
bash local-install.sh
```

### After Installation

You're ready to use Claude Code with your custom status line! The installation script already configured everything.

See [docs/INSTALLATION.md](docs/INSTALLATION.md) for detailed installation guide.

## Status Line Display

Your status line displays information-rich segments with powerline separators. See the image at the top for a visual example, or check [docs/EXAMPLES.md](docs/EXAMPLES.md) for detailed breakdowns.

### Segments (left to right)

| # | Segment | Color | Description | Example |
|---|---------|-------|-------------|---------|
| 1 | **Path** | Orange | Current directory | `oh-my-claude` |
| 2 | **Git** | Yellow* | Branch and status | `main ` |
| 3 | **Context** | Teal | Window usage percentage | `󰍛 24.7%` |
| 4 | **Code** | Cyan | Session tokens (optional) | `# 14.3M` |
| 5 | **Pro** | Pink | 5h/7d usage percentages (auto) | `󰓅 5h:90% 7d:27%` |
| 6 | **Reset** | Purple | Time until limits reset (auto) | `󰔛 5h:2h1min 7d:Thu09:59` |
| 7 | **Model** | Blue | Current AI model | `󰯉 Sonnet 4.5` |

*Git segment color changes dynamically based on repository status (clean, dirty, ahead, behind, diverged)

## Project Structure

```
oh-my-claude/
├── install.sh                    # Web installer (downloads from GitHub)
├── local-install.sh              # Local installer (for development)
├── src/                          # Source files
│   ├── statusline.sh             # Main status line script
│   ├── update-usage.sh           # Background usage updater
│   ├── fetch-code-usage.sh       # Code session token fetcher
│   ├── fetch-pro-usage.sh        # Pro usage fetcher
│   └── claude-statusline.omp.json # Oh-my-posh theme
├── docs/                         # Documentation
│   ├── PRO-USAGE-SETUP.md        # Pro usage setup guide
│   ├── STATUS_LINE_DOCUMENTATION.md # Technical reference
│   ├── STATUS_LINE_QUICK_REFERENCE.md # Common operations
│   ├── EXAMPLES.md               # Visual examples
│   ├── INDEX.md                  # Documentation index
│   └── CLAUDE.md                 # Architecture guide
├── README.md                     # This file
└── CHANGELOG.md                  # Version history
```

**Installed files** (in `~/.claude/oh-my-claude/`):
- All scripts from `src/`
- `.usage_cache` - Auto-generated cache (JSON format)

## Common Tasks

### Check Version
```bash
bash ~/.claude/oh-my-claude/statusline.sh --version
bash ~/.claude/oh-my-claude/update-usage.sh --version
bash ~/.claude/oh-my-claude/fetch-code-usage.sh --version
bash ~/.claude/oh-my-claude/fetch-pro-usage.sh --version
```

### Update Usage Data
```bash
bash ~/.claude/oh-my-claude/update-usage.sh
```

### View Current Usage Cache
```bash
cat ~/.claude/oh-my-claude/.usage_cache | jq .
```

### Test Code Usage Fetcher
```bash
bash ~/.claude/oh-my-claude/fetch-code-usage.sh --debug
```

### Test Pro Usage Fetcher
```bash
bash ~/.claude/oh-my-claude/fetch-pro-usage.sh --debug
```

### Change How Often Usage Updates
Edit `~/.claude/oh-my-claude/statusline.sh` and change:
```bash
cache_timeout=60  # Seconds (default: 60)
```

### Test the Status Line
```bash
echo '{"model":{"display_name":"Test"},"workspace":{"current_dir":"'$PWD'"},"output_style":{"name":"markdown"},"context_window":{"current_usage":{"input_tokens":1000},"context_window_size":200000}}' | bash ~/.claude/oh-my-claude/statusline.sh
```

## Customization

- **Colors**: Edit `~/.claude/oh-my-claude/claude-statusline.omp.json` → change `background` values
- **Icons**: Edit `~/.claude/oh-my-claude/claude-statusline.omp.json` → change `template` values
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
| `󰍛` | Context usage indicator (microchip) |
| `#` | Code token count indicator |
| `󰓅` | Pro usage gauge indicator |
| `󰔛` | Reset timer indicator |
| `󰯉` | Model indicator |

## How It Works

1. **Claude Code** calls `statusline.sh` on every refresh
2. **statusline.sh**:
   - Extracts data (model, directory, context, git status)
   - Reads usage cache (JSON format, instant, no blocking)
   - If cache is old (>60s), triggers `update-usage.sh` in background
   - Exports environment variables for oh-my-posh
   - Passes data to oh-my-posh
3. **oh-my-posh** renders the colored powerline segments
4. **update-usage.sh** (background, every 60s):
   - Calls `fetch-code-usage.sh` for session token count
   - Calls `fetch-pro-usage.sh` for Pro usage percentages and reset times
   - Writes JSON cache with timestamps

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

## Version Management

### Checking Version
All scripts support the `--version` flag:
```bash
bash ~/.claude/oh-my-claude/statusline.sh --version
```

### For Developers: Bumping Version
To update the project version, use the included helper script:
```bash
bash bump-version.sh
```

This will:
- Update the `VERSION` file
- Update `README.md` with the new version
- Optionally create a git tag
- Guide you through the process

The script supports semantic versioning (MAJOR.MINOR.PATCH):
- **Major**: Breaking changes (e.g., 1.6.0 → 2.0.0)
- **Minor**: New features (e.g., 1.6.0 → 1.7.0)
- **Patch**: Bug fixes (e.g., 1.6.0 → 1.6.1)

## Support

If you need to modify the status line:
1. Check `docs/STATUS_LINE_QUICK_REFERENCE.md` for common tasks
2. See `docs/STATUS_LINE_DOCUMENTATION.md` for advanced customization
3. Browse `docs/EXAMPLES.md` for visual references
4. All scripts are in `~/.claude/` and well-commented

---

**Created**: December 2024
**Version**: 1.7.0
**Tools**: oh-my-posh, ccusage, bash

For version history and detailed changes, see [CHANGELOG.md](CHANGELOG.md).
