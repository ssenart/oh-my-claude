# Documentation Index

Complete guide to the custom Claude Code status line implementation.

## Quick Links

| File | Purpose | Best For |
|------|---------|----------|
| **../README.md** | Overview and getting started | Quick start, project overview |
| **INSTALLATION.md** | Complete installation guide | Detailed setup, troubleshooting install issues |
| **PRO-USAGE-SETUP.md** | Pro usage tracking setup | Setting up Claude Pro usage monitoring |
| **STATUS_LINE_QUICK_REFERENCE.md** | Common operations | Day-to-day usage, quick commands |
| **STATUS_LINE_DOCUMENTATION.md** | Complete technical reference | Deep customization, understanding internals |
| **EXAMPLES.md** | Visual examples of all states | Understanding what you're seeing |
| **CLAUDE.md** | Architecture guide | Understanding the codebase structure |
| **../CHANGELOG.md** | Version history and changes | Tracking what's been implemented |
| **INDEX.md** | This file - documentation map | Finding the right document |

## File Structure

```
~/.claude/
├── statusline.sh                       ← Main script
├── update-usage.sh                     ← Usage cache updater
├── fetch-code-usage.sh                 ← Code session token fetcher
├── fetch-pro-usage.sh                  ← Pro usage fetcher
├── claude-statusline.omp.json          ← Oh-my-posh theme
├── .env                                ← API credentials (YOUR CONFIG)
└── .usage_cache                        ← Auto-generated cache (JSON)
```

## What to Read When

### 🚀 Just Getting Started
1. **../README.md** - Quick overview and quick install
2. **INSTALLATION.md** - Detailed installation instructions and troubleshooting
3. **PRO-USAGE-SETUP.md** - Set up Pro usage tracking (optional)
4. Test with command from **STATUS_LINE_QUICK_REFERENCE.md**

### 🔧 Want to Customize
1. **STATUS_LINE_QUICK_REFERENCE.md** - Common customizations
2. **STATUS_LINE_DOCUMENTATION.md** - Advanced customization
3. **EXAMPLES.md** - See what's possible

### 🐛 Troubleshooting
1. **INSTALLATION.md** - Installation issues and fixes
2. **STATUS_LINE_QUICK_REFERENCE.md** - Common operation fixes
3. **STATUS_LINE_DOCUMENTATION.md** - Detailed troubleshooting
4. **PRO-USAGE-SETUP.md** - Pro usage specific issues
5. **EXAMPLES.md** - Verify expected output

### 📚 Understanding the System
1. **STATUS_LINE_DOCUMENTATION.md** - How everything works
2. **../CHANGELOG.md** - What's been implemented
3. **EXAMPLES.md** - See all possible states

## Key Sections by Topic

### Configuration
- **Installation**: INSTALLATION.md, ../README.md
- **Pro usage setup**: PRO-USAGE-SETUP.md
- **Credentials setup**: INSTALLATION.md, PRO-USAGE-SETUP.md
- **Changing colors**: STATUS_LINE_QUICK_REFERENCE.md, STATUS_LINE_DOCUMENTATION.md
- **Segment order**: STATUS_LINE_QUICK_REFERENCE.md
- **Cache timeout**: STATUS_LINE_QUICK_REFERENCE.md

### Technical Details
- **Architecture**: STATUS_LINE_DOCUMENTATION.md, ../CLAUDE.md
- **How it works**: STATUS_LINE_DOCUMENTATION.md, ../README.md
- **Performance**: STATUS_LINE_DOCUMENTATION.md, ../CHANGELOG.md
- **Dependencies**: ../README.md, STATUS_LINE_DOCUMENTATION.md

### Examples & Reference
- **All visual states**: EXAMPLES.md
- **Icons reference**: EXAMPLES.md, STATUS_LINE_DOCUMENTATION.md
- **Color codes**: EXAMPLES.md, STATUS_LINE_DOCUMENTATION.md
- **Command examples**: STATUS_LINE_QUICK_REFERENCE.md

### Maintenance
- **Version history**: ../CHANGELOG.md
- **Common operations**: STATUS_LINE_QUICK_REFERENCE.md
- **Troubleshooting**: All docs have troubleshooting sections

## Documentation Conventions

### Code Blocks
```bash
# Bash commands to run
```

### File Paths
- `~/.claude/file.sh` - File locations
- Absolute paths when important

### Sections
- **Bold** - Important files or concepts
- `Code` - Filenames, commands, code
- *Italic* - Emphasis

## Quick Command Reference

See **STATUS_LINE_QUICK_REFERENCE.md** for the complete list, but here are the essentials:

```bash
# Test status line
echo '{"model":{"display_name":"Test"},"workspace":{"current_dir":"'$PWD'"},"output_style":{"name":"markdown"},"context_window":{"current_usage":{"input_tokens":1000},"context_window_size":200000}}' | bash ~/.claude/statusline.sh

# Update usage data
bash ~/.claude/update-usage.sh

# View cache
cat ~/.claude/.usage_cache | jq .

# Test Pro usage fetching
bash ~/.claude/fetch-pro-usage.sh --debug
```

## Getting Help

1. Check **STATUS_LINE_QUICK_REFERENCE.md** first
2. Search the relevant doc file using Ctrl+F
3. Check **EXAMPLES.md** to see if your issue is a normal state
4. Review **STATUS_LINE_DOCUMENTATION.md** troubleshooting section

## Documentation Versions

All documentation is version **1.5** as of 2024-12-27.

Last updated: December 27, 2024
