# Documentation Index

Complete guide to the custom Claude Code status line implementation.

## Quick Links

| File | Purpose | Best For |
|------|---------|----------|
| **../README.md** | Overview and getting started | First-time setup, quick reference |
| **STATUS_LINE_QUICK_REFERENCE.md** | Common operations | Day-to-day usage, quick commands |
| **STATUS_LINE_DOCUMENTATION.md** | Complete technical reference | Deep customization, understanding internals |
| **EXAMPLES.md** | Visual examples of all states | Understanding what you're seeing |
| **../CHANGELOG.md** | Version history and changes | Tracking what's been implemented |
| **../CLAUDE.md** | Guide for Claude Code instances | Understanding the architecture |
| **INDEX.md** | This file - documentation map | Finding the right document |

## File Structure

```
~/.claude/
├── README.md                           ← Start here!
├── CLAUDE.md                           ← Guide for Claude Code
├── CHANGELOG.md                        ← Version history
│
├── docs/                               ← Documentation folder
│   ├── INDEX.md                        ← This file
│   ├── STATUS_LINE_QUICK_REFERENCE.md ← Common tasks
│   ├── STATUS_LINE_DOCUMENTATION.md   ← Full technical docs
│   └── EXAMPLES.md                     ← Visual examples
│
├── statusline.sh                       ← Main script
├── claude-statusline.omp.json          ← Oh-my-posh theme
├── update-usage.sh                     ← Usage updater
├── usage-limits.conf                   ← YOUR CONFIG (edit this!)
└── .usage_cache                        ← Auto-generated cache
```

## What to Read When

### 🚀 Just Getting Started
1. **../README.md** - Understand what you have
2. Edit **../usage-limits.conf** - Set your token limits
3. Test with command from **STATUS_LINE_QUICK_REFERENCE.md**

### 🔧 Want to Customize
1. **STATUS_LINE_QUICK_REFERENCE.md** - Common customizations
2. **STATUS_LINE_DOCUMENTATION.md** - Advanced customization
3. **EXAMPLES.md** - See what's possible

### 🐛 Troubleshooting
1. **STATUS_LINE_QUICK_REFERENCE.md** - Common fixes
2. **STATUS_LINE_DOCUMENTATION.md** - Detailed troubleshooting
3. **EXAMPLES.md** - Verify expected output

### 📚 Understanding the System
1. **STATUS_LINE_DOCUMENTATION.md** - How everything works
2. **../CHANGELOG.md** - What's been implemented
3. **EXAMPLES.md** - See all possible states

## Key Sections by Topic

### Configuration
- **Setting token limits**: ../README.md, STATUS_LINE_QUICK_REFERENCE.md
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
cat ~/.claude/.usage_cache

# Edit limits
nano ~/.claude/usage-limits.conf
```

## Getting Help

1. Check **STATUS_LINE_QUICK_REFERENCE.md** first
2. Search the relevant doc file using Ctrl+F
3. Check **EXAMPLES.md** to see if your issue is a normal state
4. Review **STATUS_LINE_DOCUMENTATION.md** troubleshooting section

## Documentation Versions

All documentation is version **1.5** as of 2024-12-27.

Last updated: December 27, 2024
