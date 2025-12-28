# Status Line Examples

This document shows various states of the custom status line.

## Basic Examples

### Outside Git Repository
```
 oh-my-claude 󰍛 45%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```
- No git segment (not in a repository)
- All other segments visible

### Inside Clean Git Repository
```
 oh-my-claude  main 󰍛 45%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```
- Git segment shows: ` main` (clean repository on main branch, synced with remote)

### Inside Dirty Git Repository (Working Changes)
```
 oh-my-claude  main  ~2 󰍛 45%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```
- Git segment shows: ` main  ~2` (2 modified files in working directory)
- Background changes to orange (#ff9248) to indicate uncommitted changes

### Repository with Staged Changes
```
 oh-my-claude  main  +3 󰍛 45%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```
- Git segment shows: ` main  +3` (3 files staged for commit)
- Background changes to orange (#ff9248) to indicate changes ready to commit

## Different Usage Levels

### Low Usage (< 25%)
```
 oh-my-claude  main 󰍛 12%  5h:15% (2.4M/16M) W:8% (5.8M/72M) 󰯉 Sonnet 4.5
```
- Plenty of tokens remaining
- No immediate concerns

### Medium Usage (25-75%)
```
 oh-my-claude  main 󰍛 45%  5h:56% (9.0M/16M) W:42% (30.2M/72M) 󰯉 Sonnet 4.5
```
- Moderate usage levels
- Still comfortable range

### High Usage (> 75%)
```
 oh-my-claude  main 󰍛 82%  5h:89% (14.2M/16M) W:85% (61.2M/72M) 󰯉 Sonnet 4.5
```
- Approaching limits
- May need to watch usage carefully

## Different Context Levels

### Low Context (Early in conversation)
```
 oh-my-claude  main 󰍛 5%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```

### Medium Context (Mid conversation)
```
 oh-my-claude  main 󰍛 45%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```

### High Context (Long conversation)
```
 oh-my-claude  main 󰍛 92%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```
- Conversation nearing context limit
- May need to start new conversation soon

## Different Models

### Sonnet
```
 oh-my-claude  main 󰍛 45%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```

### Haiku (if switched)
```
 oh-my-claude  main 󰍛 45%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Haiku 4.5
```

### Opus (if available)
```
 oh-my-claude  main 󰍛 45%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Opus 4.5
```

## Different Git States

### Main Branch (Clean)
```
 oh-my-claude  main 󰍛 45%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```
- Clean repository, synced with remote

### Feature Branch (Clean)
```
 oh-my-claude  feature/add-auth 󰍛 45%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```
- Clean feature branch

### Detached HEAD (showing commit hash)
```
 oh-my-claude  a1b2c3d 󰍛 45%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```
- Detached HEAD state showing short commit hash

### With Uncommitted Working Changes
```
 oh-my-claude  main  ~3 󰍛 45%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```
- 3 modified files in working directory (not staged)
- Background changes to orange

### After Git Add (Staged Changes)
```
 oh-my-claude  main  +3 󰍛 45%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```
- 3 files staged for commit
- Background changes to orange

### After Git Commit (Now clean)
```
 oh-my-claude  main 󰍛 45%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```
- Clean repository after commit

### Branch Ahead of Remote
```
 oh-my-claude  main ↑2 󰍛 45%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```
- 2 commits ahead of remote (ready to push)
- Background changes to orange-red (#f17c37)

### Branch Behind Remote
```
 oh-my-claude  main ↓3 󰍛 45%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```
- 3 commits behind remote (need to pull)
- Background changes to cyan (#89d1dc)

### Branch Diverged (Both Ahead and Behind)
```
 oh-my-claude  main ↑2 ↓3 󰍛 45%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```
- 2 commits ahead and 3 commits behind remote (diverged, need to merge/rebase)
- Background changes to red (#f26d50)

### With Stashed Changes
```
 oh-my-claude  main  1 󰍛 45%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```
- 1 stash present

### Complex State (Staging + Working + Ahead)
```
 oh-my-claude  main ↑1  +2 |  ~3 󰍛 45%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```
- 1 commit ahead of remote
- 2 files staged
- 3 files modified in working directory

## Special Cases

### Very Long Directory Name
```
 very-long-project-name-here  main 󰍛 45%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```
- Full directory name is displayed

### Very Long Branch Name
```
 oh-my-claude  feature/implement-complex-authentication-system 󰍛 45%  5h:76% (12.2M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```
- Full branch name is displayed

### No Usage Data Yet (First load)
```
 oh-my-claude  main 󰍛 45%  󰯉 Sonnet 4.5
```
- Usage segment missing until first update completes (~60 seconds)

### Usage Exceeding Limits (>100%)
```
 oh-my-claude  main 󰍛 45%  5h:103% (16.5M/16M) W:17% (12.4M/72M) 󰯉 Sonnet 4.5
```
- Can happen if limits are set incorrectly in config
- Or if you're in grace period after limit

## Color Breakdown

Each segment has its own background color:

```
[Orange: Path] [Yellow/Dynamic: Git] [Teal: Context] [Pink: Usage] [Blue: Model]
```

### Actual Hex Colors
- **Path**: `#ff6b35` (orange)
- **Git**: `#fffb38` (yellow base) with dynamic templates:
  - `#ff9248` (orange) - Working or staging changes
  - `#f26d50` (red) - Ahead and behind remote
  - `#f17c37` (orange-red) - Ahead of remote
  - `#89d1dc` (cyan) - Behind remote
- **Context**: `#00897b` (teal)
- **Usage**: `#ff8c94` (pink)
- **Model**: `#3a86ff` (blue)

## Icon Reference

| Icon | Segment | Meaning |
|------|---------|---------|
| `` | Path | Folder/directory location |
| `` | Git | Upstream indicator (varies based on status) |
| `` | Git | Staged files icon |
| `` | Git | Modified files icon |
| `` | Git | Stash icon |
| `↑` | Git | Commits ahead of remote |
| `↓` | Git | Commits behind remote |
| `󰍛` | Context | Memory/RAM usage |
| `` | Usage | Chart/statistics icon |
| `󰯉` | Model | AI/brain model indicator |

## Segment Separators

Between each segment, you'll see the powerline arrow separator: ``

This creates the "flowing" visual effect between colored segments.

## Real-World Workflow Examples

### Starting Fresh Project
```
 new-project  main 󰍛 2%  5h:3% (0.5M/16M) W:5% (3.6M/72M) 󰯉 Sonnet 4.5
```
- New repository, clean
- Low token usage
- Fresh conversation

### Deep Debugging Session
```
 bug-fix  debug-branch  ~5 󰍛 78%  5h:85% (13.6M/16M) W:52% (37.4M/72M) 󰯉 Sonnet 4.5
```
- Working branch with 5 modified files
- Long debugging conversation (high context)
- Significant token usage from analysis

### Code Review
```
 project  main 󰍛 35%  5h:45% (7.2M/16M) W:25% (18.0M/72M) 󰯉 Sonnet 4.5
```
- On main branch (reviewing)
- Clean repository (just reading)
- Moderate conversation depth

### Before Committing Work
```
 feature  feature/new-ui  ~8 󰍛 62%  5h:71% (11.4M/16M) W:38% (27.4M/72M) 󰯉 Sonnet 4.5
```
- Feature branch with 8 uncommitted changes
- Ready to stage and commit

### After Staging Work
```
 feature  feature/new-ui  +8 󰍛 62%  5h:71% (11.4M/16M) W:38% (27.4M/72M) 󰯉 Sonnet 4.5
```
- 8 files staged, ready to commit

### After Committing Work
```
 feature  feature/new-ui ↑1 󰍛 62%  5h:71% (11.4M/16M) W:38% (27.4M/72M) 󰯉 Sonnet 4.5
```
- Clean working directory
- 1 commit ahead of remote, ready to push

### After Pushing
```
 feature  feature/new-ui 󰍛 62%  5h:71% (11.4M/16M) W:38% (27.4M/72M) 󰯉 Sonnet 4.5
```
- Fully synced with remote

## ASCII Representation (For Terminals Without Nerd Fonts)

If Nerd Fonts aren't available, the status line will show boxes or missing characters where icons should be:
```
[?] oh-my-claude [?] main [?] 45% [?] 5h:76% (12.2M/16M) W:17% (12.4M/72M) [?] Sonnet 4.5
```

Note: The custom icons won't render, but the information is still visible. Install a Nerd Font to see proper icons.

## Troubleshooting Visual Issues

### Icons Show as Boxes or Question Marks
- Install a Nerd Font (e.g., FiraCode Nerd Font, JetBrains Mono Nerd Font)
- Configure your terminal to use that font

### Colors Not Showing
- Your terminal must support 24-bit true color
- Git Bash on Windows supports this by default

### Segments Overlap or Misalign
- Try adjusting terminal width (make it wider)
- Oh-my-posh auto-adjusts but very narrow terminals may have issues

### Powerline Arrows Not Connecting
- This is usually a font rendering issue
- Install a proper Nerd Font with powerline glyphs
