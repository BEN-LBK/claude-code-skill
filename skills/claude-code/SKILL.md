---
name: claude-code
description: Run Anthropic Claude Code CLI for coding tasks, code reviews, bug fixes, and feature development via background process with full programmatic control.
metadata:
  {
    "openclaw": { "emoji": "🧑‍💻", "requires": { "bins": ["claude"] } },
  }
---

# Claude Code Skill

Use Anthropic's Claude Code CLI via OpenClaw for intelligent coding assistance. Claude Code can build features, fix bugs, review code, and automate tedious development tasks.

## Installation

Install Claude Code first:

```bash
# macOS / Linux / WSL
curl -fsSL https://claude.ai/install.sh | bash

# Windows PowerShell
irm https://claude.ai/install.ps1 | iex

# Homebrew
brew install --cask claude-code

# WinGet
winget install Anthropic.ClaudeCode
```

**Prerequisites:**
- Claude subscription (Pro, Max, Teams, or Enterprise) OR Claude Console account
- On first run, you'll be prompted to log in

---

## ⚠️ Critical: Use PTY Mode

Claude Code is an interactive terminal application. **Always use `pty: true`**:

```bash
# ✅ Correct - with PTY
bash pty: true command: "claude 'Build a REST API'"

# ❌ Wrong - will break or hang
bash command: "claude 'Build a REST API'"
```

---

## Quick Start Patterns

### One-Shot Task

For quick tasks in any directory:

```bash
bash pty: true workdir: ~/Projects/myapp command: "claude 'Add input validation to the login form'"
```

### Background Long-Running Task

```bash
# Start in background
bash pty: true workdir: ~/Projects/myapp background: true command: "claude 'Refactor the authentication module'"

# Monitor with sessionId
process action: log sessionId: <session-id>

# Check if still running
process action: poll sessionId: <session-id>

# Send input if Claude asks a question
process action: submit sessionId: <session-id> data: "yes"

# Kill if needed
process action: kill sessionId: <session-id>
```

---

## Common Use Cases

### 1. Build Features

```bash
bash pty: true workdir: ~/Projects/myapp command: "claude 'Create a dark mode toggle with system preference detection'"
```

### 2. Debug and Fix Bugs

```bash
# Describe the bug
bash pty: true workdir: ~/Projects/myapp command: "claude 'Fix the memory leak in the data processing module. The heap grows unbounded during batch operations.'"

# Or paste an error message
bash pty: true workdir: ~/Projects/myapp command: "claude 'Fix this error: TypeError: Cannot read property map of undefined at processData (src/utils.js:42)'"
```

### 3. Code Review

```bash
# Review current changes
bash pty: true workdir: ~/Projects/myapp command: "claude 'Review the changes in this branch. Check for bugs, security issues, and code quality.'"

# Review specific files
bash pty: true workdir: ~/Projects/myapp command: "claude 'Review src/auth.js and src/middleware.js for security best practices'"
```

### 4. Navigate and Understand Codebase

```bash
# Ask about project structure
bash pty: true workdir: ~/Projects/myapp command: "claude 'Explain how the routing system works in this project'"

# Find relevant code
bash pty: true workdir: ~/Projects/myapp command: "claude 'Where is user authentication handled? Show me the flow.'"
```

### 5. Automate Tedious Tasks

```bash
# Fix lint issues
bash pty: true workdir: ~/Projects/myapp command: "claude 'Fix all ESLint errors and warnings in the src/ directory'"

# Write tests
bash pty: true workdir: ~/Projects/myapp command: "claude 'Write unit tests for the UserService class using Jest'"

# Update documentation
bash pty: true workdir: ~/Projects/myapp command: "claude 'Update the README with the new API endpoints and environment variables'"
```

---

## Advanced Patterns

### Parallel Issue Fixing with Git Worktrees

Work on multiple issues simultaneously without conflicts:

```bash
# Create worktrees for each issue
git worktree add -b fix/auth-bug /tmp/fix-auth main
git worktree add -b fix/ui-glitch /tmp/fix-ui main

# Launch Claude Code in each (background + PTY)
bash pty: true workdir: /tmp/fix-auth background: true command: "claude 'Fix the authentication bug where tokens expire too quickly. Commit when done.'"
bash pty: true workdir: /tmp/fix-ui background: true command: "claude 'Fix the button alignment issue on mobile. Commit when done.'"

# Monitor progress
process action: list
process action: log sessionId: <auth-session-id>
process action: log sessionId: <ui-session-id>

# After fixes, create PRs
cd /tmp/fix-auth && git push -u origin fix/auth-bug
gh pr create --title "fix: auth token expiration" --body "Fixes token expiry bug"

# Cleanup
git worktree remove /tmp/fix-auth
git worktree remove /tmp/fix-ui
```

### Batch Code Reviews

Review multiple PRs in parallel:

```bash
# Fetch all PR refs
git fetch origin '+refs/pull/*/head:refs/remotes/origin/pr/*'

# Deploy review agents
bash pty: true workdir: ~/Projects/myapp background: true command: "claude 'Review PR #86. Run: git diff main...origin/pr/86 and analyze the changes'"
bash pty: true workdir: ~/Projects/myapp background: true command: "claude 'Review PR #87. Run: git diff main...origin/pr/87 and analyze the changes'"

# Check results
process action: log sessionId: <session-id-86>
process action: log sessionId: <session-id-87>
```

### Safe PR Review in Temp Directory

**Never review PRs in your main project folder!**

```bash
# Clone to temp for safe review
REVIEW_DIR=$(mktemp -d)
git clone https://github.com/user/repo.git $REVIEW_DIR
cd $REVIEW_DIR && gh pr checkout 130

bash pty: true workdir: $REVIEW_DIR command: "claude 'Review this PR against main. Check for bugs, security issues, and suggest improvements.'"

# Clean up after
trash $REVIEW_DIR
```

---

## Progress Notifications

Keep the user informed when running background tasks:

### Manual Updates

Send updates at key milestones:
- Task started
- Milestone completed (build finished, tests passed)
- Agent needs input
- Error occurred
- Task completed

### Auto-Notify on Completion

Add a wake trigger to your prompt for automatic notification:

```bash
bash pty: true workdir: ~/Projects/myapp background: true command: "claude 'Build a REST API for todos with CRUD endpoints, validation, and tests. When completely finished, run: openclaw gateway wake --text \"Done: Built todos REST API\" --mode now'"
```

---

## Claude Code CLI Reference

### Basic Syntax

```bash
claude [options] [prompt]
```

### Common Options

| Option | Description |
|--------|-------------|
| `--help` | Show help message |
| `--version` | Show version |
| `--verbose` | Enable verbose output |

### Claude Code Behaviors

- **Interactive Mode:** Default mode - Claude asks questions and waits for approval
- **Takes Action:** Can directly edit files, run commands, create commits
- **Context Aware:** Maintains awareness of your entire project structure
- **Web Search:** Can find up-to-date information from the web
- **MCP Support:** Can use external data sources (Google Drive, Figma, Slack, etc.)

---

## Best Practices

### Do's ✅

1. **Always use `pty: true`** - Claude Code needs a terminal
2. **Use `workdir`** to set the project context
3. **Be specific** in your prompts - include file names, function names, error messages
4. **Define success** - explain what "done" looks like
5. **Use git worktrees** for parallel tasks
6. **Monitor with `process:log`** - check progress without interfering
7. **Review PRs in temp directories** - never in your main project

### Don'ts ❌

1. **Never start Claude Code in `~/.openclaw/`** - it'll read internal files
2. **Don't kill sessions because they're "slow"** - coding takes time
3. **Never silently take over** if Claude Code fails - ask the user
4. **Don't run without PTY** - output will break

---

## Integration with MCP (Model Context Protocol)

Claude Code supports MCP servers for extended capabilities:

- **Google Drive:** Read design docs
- **Figma:** Access design specifications
- **Slack:** Pull context from conversations
- **Jira:** Update tickets
- **Custom tools:** Build your own MCP servers

Configure MCP in Claude Code settings at `~/.claude/config.json`.

---

## Troubleshooting

### "Not a git repository" Error

Claude Code requires a git repository. Initialize one:

```bash
cd ~/Projects/myapp
git init
git add .
git commit -m "Initial commit"
```

### Session Hangs

- Check with `process action: poll sessionId: <id>`
- Claude may be waiting for input - check logs
- Kill and restart if needed: `process action: kill sessionId: <id>`

### Permission Errors

Ensure you have:
- Claude subscription (Pro, Max, Teams, or Enterprise)
- Authenticated with `claude login`
- Proper file permissions in the project directory

---

## Examples

### Complete Feature Development Flow

```bash
# 1. Start with a clear task
bash pty: true workdir: ~/Projects/myapp background: true command: "claude 'Build a user profile page with avatar upload, bio editing, and social links. Include form validation and error handling.'"

# 2. Monitor progress
process action: log sessionId: <id>

# 3. When done, review changes
cd ~/Projects/myapp
git diff

# 4. Test the changes
npm test

# 5. Commit if satisfied
git add .
git commit -m "feat: add user profile page"
```

### Bug Fix Flow

```bash
# Describe the bug and let Claude investigate
bash pty: true workdir: ~/Projects/myapp command: "claude 'Users report that clicking \"Save\" sometimes doesn\'t work. The button appears to do nothing. Investigate and fix the issue in the save functionality.'"
```

### Code Review Flow

```bash
# Review before committing
bash pty: true workdir: ~/Projects/myapp command: "claude 'Review all uncommitted changes. Look for: 1) Bugs, 2) Security issues, 3) Performance problems, 4) Code style issues'"
```

---

## See Also

- [Claude Code Docs](https://code.claude.com/docs/)
- [Claude Code on the Web](https://claude.ai/code)
- [MCP Documentation](https://code.claude.com/docs/mcp)
- [GitHub Actions Integration](https://code.claude.com/docs/continuous-integration/github-actions)
- [Slack Integration](https://code.claude.com/docs/slack)

---

**Remember:** Claude Code is powerful - give it clear instructions and trust it to do the work, but always review the results before committing! 🚀
