#!/bin/bash
#
# claude-code skill helper script
# Usage: ./scripts/claude-code.sh [command] [args]
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLAUDE_CMD="${CLAUDE_CMD:-claude}"

# Help message
show_help() {
    cat << EOF
Claude Code Skill Helper

Usage: $0 <command> [options]

Basic Commands:
    quick <prompt>        Run a quick one-shot task in current directory
    task <prompt>         Run a background task (returns session ID)
    review                Review current git changes
    fix <description>     Fix a bug or issue
    test                  Run tests via Claude Code
    explain <file>        Explain a file or code section

Spec-Driven Development:
    openspec-new <name>       Start new OpenSpec change
    openspec-ff               Fast-forward OpenSpec (create all docs)
    openspec-apply            Apply OpenSpec tasks
    openspec-archive          Archive OpenSpec change
    
    speckit-constitution      Create Spec Kit constitution
    speckit-specify <desc>    Create Spec Kit specification
    speckit-plan <desc>       Create Spec Kit plan
    speckit-tasks             Generate Spec Kit tasks
    speckit-implement         Implement Spec Kit tasks

Examples:
    $0 quick "Add input validation to login form"
    $0 task "Refactor authentication module"
    $0 review
    $0 fix "Memory leak in data processing"
    $0 explain src/auth.js
    
    # OpenSpec
    $0 openspec-new dark-mode
    $0 openspec-ff
    $0 openspec-apply
    
    # Spec Kit
    $0 speckit-constitution
    $0 speckit-specify "Build photo album app"
    $0 speckit-plan "Use React and Vite"
    $0 speckit-tasks
    $0 speckit-implement

Environment Variables:
    CLAUDE_CMD    Path to claude executable (default: claude)
    WORKDIR       Working directory (default: current directory)
EOF
}

# Check if claude is installed
check_claude() {
    if ! command -v "$CLAUDE_CMD" &> /dev/null; then
        echo -e "${RED}Error: Claude Code not found${NC}"
        echo "Install with: curl -fsSL https://claude.ai/install.sh | bash"
        exit 1
    fi
}

# Run quick task
run_quick() {
    local prompt="$1"
    local workdir="${WORKDIR:-$(pwd)}"
    
    echo -e "${BLUE}Running Claude Code in: $workdir${NC}"
    echo -e "${YELLOW}Prompt: $prompt${NC}"
    echo ""
    
    cd "$workdir"
    "$CLAUDE_CMD" "$prompt"
}

# Run background task
run_task() {
    local prompt="$1"
    local workdir="${WORKDIR:-$(pwd)}"
    local session_file="/tmp/claude-task-$(date +%s).session"
    
    echo -e "${BLUE}Starting background Claude Code task...${NC}"
    echo -e "${YELLOW}Prompt: $prompt${NC}"
    echo -e "${YELLOW}Working directory: $workdir${NC}"
    echo ""
    
    # Create a script to run the task
    cat > "$session_file" << 'SCRIPT'
#!/bin/bash
cd "WORKDIR_PLACEHOLDER"
claude "PROMPT_PLACEHOLDER"
SCRIPT
    
    sed -i.bak "s|WORKDIR_PLACEHOLDER|$workdir|g; s|PROMPT_PLACEHOLDER|$prompt|g" "$session_file"
    rm -f "${session_file}.bak"
    chmod +x "$session_file"
    
    # Run in background with nohup
    nohup "$session_file" > "${session_file}.log" 2>&1 &
    local pid=$!
    
    echo -e "${GREEN}Task started with PID: $pid${NC}"
    echo -e "${BLUE}Log file: ${session_file}.log${NC}"
    echo -e "${BLUE}To monitor: tail -f ${session_file}.log${NC}"
    echo ""
    echo "Session info saved to: $session_file"
}

# Review current changes
run_review() {
    local workdir="${WORKDIR:-$(pwd)}"
    
    echo -e "${BLUE}Reviewing changes in: $workdir${NC}"
    
    cd "$workdir"
    "$CLAUDE_CMD" "Review the current changes (git diff). Look for bugs, security issues, code quality problems, and suggest improvements."
}

# Fix a bug
run_fix() {
    local description="$1"
    local workdir="${WORKDIR:-$(pwd)}"
    
    if [ -z "$description" ]; then
        echo -e "${RED}Error: Please provide a bug description${NC}"
        echo "Usage: $0 fix \"description of the bug\""
        exit 1
    fi
    
    echo -e "${BLUE}Fixing bug in: $workdir${NC}"
    echo -e "${YELLOW}Description: $description${NC}"
    echo ""
    
    cd "$workdir"
    "$CLAUDE_CMD" "Fix this bug: $description. Investigate the codebase, identify the root cause, implement the fix, and verify it works."
}

# Run tests
run_test() {
    local workdir="${WORKDIR:-$(pwd)}"
    
    echo -e "${BLUE}Running tests via Claude Code in: $workdir${NC}"
    
    cd "$workdir"
    "$CLAUDE_CMD" "Run the test suite. If tests fail, analyze the failures and fix the issues. If tests pass, report the results."
}

# Explain code
run_explain() {
    local target="$1"
    local workdir="${WORKDIR:-$(pwd)}"
    
    if [ -z "$target" ]; then
        echo -e "${RED}Error: Please specify a file or code section${NC}"
        echo "Usage: $0 explain <file>"
        exit 1
    fi
    
    echo -e "${BLUE}Explaining in: $workdir${NC}"
    echo -e "${YELLOW}Target: $target${NC}"
    echo ""
    
    cd "$workdir"
    "$CLAUDE_CMD" "Explain $target in detail. Include: 1) What it does, 2) How it works, 3) Key components, 4) Any important patterns or design decisions."
}

# ==================== OpenSpec Commands ====================

# Start new OpenSpec change
run_openspec_new() {
    local name="$1"
    local workdir="${WORKDIR:-$(pwd)}"
    
    if [ -z "$name" ]; then
        echo -e "${RED}Error: Please provide a change name${NC}"
        echo "Usage: $0 openspec-new <change-name>"
        exit 1
    fi
    
    echo -e "${BLUE}Starting OpenSpec change in: $workdir${NC}"
    echo -e "${YELLOW}Change name: $name${NC}"
    echo ""
    
    cd "$workdir"
    "$CLAUDE_CMD" "/opsx:new $name"
}

# OpenSpec fast-forward
run_openspec_ff() {
    local workdir="${WORKDIR:-$(pwd)}"
    
    echo -e "${BLUE}Running OpenSpec fast-forward in: $workdir${NC}"
    echo ""
    
    cd "$workdir"
    "$CLAUDE_CMD" "/opsx:ff"
}

# OpenSpec apply
run_openspec_apply() {
    local workdir="${WORKDIR:-$(pwd)}"
    
    echo -e "${BLUE}Applying OpenSpec tasks in: $workdir${NC}"
    echo ""
    
    cd "$workdir"
    "$CLAUDE_CMD" "/opsx:apply"
}

# OpenSpec archive
run_openspec_archive() {
    local workdir="${WORKDIR:-$(pwd)}"
    
    echo -e "${BLUE}Archiving OpenSpec change in: $workdir${NC}"
    echo ""
    
    cd "$workdir"
    "$CLAUDE_CMD" "/opsx:archive"
}

# ==================== Spec Kit Commands ====================

# Spec Kit constitution
run_speckit_constitution() {
    local workdir="${WORKDIR:-$(pwd)}"
    
    echo -e "${BLUE}Creating Spec Kit constitution in: $workdir${NC}"
    echo ""
    
    cd "$workdir"
    "$CLAUDE_CMD" "/speckit.constitution Create principles focused on code quality, testing standards, user experience consistency, and performance requirements"
}

# Spec Kit specify
run_speckit_specify() {
    local description="$1"
    local workdir="${WORKDIR:-$(pwd)}"
    
    if [ -z "$description" ]; then
        echo -e "${RED}Error: Please provide a feature description${NC}"
        echo "Usage: $0 speckit-specify \"description of feature\""
        exit 1
    fi
    
    echo -e "${BLUE}Creating Spec Kit specification in: $workdir${NC}"
    echo -e "${YELLOW}Description: $description${NC}"
    echo ""
    
    cd "$workdir"
    "$CLAUDE_CMD" "/speckit.specify $description"
}

# Spec Kit plan
run_speckit_plan() {
    local description="$1"
    local workdir="${WORKDIR:-$(pwd)}"
    
    if [ -z "$description" ]; then
        echo -e "${RED}Error: Please provide plan details${NC}"
        echo "Usage: $0 speckit-plan \"tech stack and approach\""
        exit 1
    fi
    
    echo -e "${BLUE}Creating Spec Kit plan in: $workdir${NC}"
    echo -e "${YELLOW}Plan: $description${NC}"
    echo ""
    
    cd "$workdir"
    "$CLAUDE_CMD" "/speckit.plan $description"
}

# Spec Kit tasks
run_speckit_tasks() {
    local workdir="${WORKDIR:-$(pwd)}"
    
    echo -e "${BLUE}Generating Spec Kit tasks in: $workdir${NC}"
    echo ""
    
    cd "$workdir"
    "$CLAUDE_CMD" "/speckit.tasks"
}

# Spec Kit implement
run_speckit_implement() {
    local workdir="${WORKDIR:-$(pwd)}"
    
    echo -e "${BLUE}Implementing Spec Kit tasks in: $workdir${NC}"
    echo ""
    
    cd "$workdir"
    "$CLAUDE_CMD" "/speckit.implement"
}

# Main command dispatcher
main() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        quick)
            check_claude
            if [ $# -eq 0 ]; then
                echo -e "${RED}Error: Please provide a prompt${NC}"
                echo "Usage: $0 quick \"your prompt here\""
                exit 1
            fi
            run_quick "$*"
            ;;
        task)
            check_claude
            if [ $# -eq 0 ]; then
                echo -e "${RED}Error: Please provide a prompt${NC}"
                echo "Usage: $0 task \"your prompt here\""
                exit 1
            fi
            run_task "$*"
            ;;
        review)
            check_claude
            run_review
            ;;
        fix)
            check_claude
            run_fix "$*"
            ;;
        test)
            check_claude
            run_test
            ;;
        explain)
            check_claude
            run_explain "$1"
            ;;
        # OpenSpec commands
        openspec-new)
            check_claude
            run_openspec_new "$1"
            ;;
        openspec-ff)
            check_claude
            run_openspec_ff
            ;;
        openspec-apply)
            check_claude
            run_openspec_apply
            ;;
        openspec-archive)
            check_claude
            run_openspec_archive
            ;;
        # Spec Kit commands
        speckit-constitution)
            check_claude
            run_speckit_constitution
            ;;
        speckit-specify)
            check_claude
            if [ $# -eq 0 ]; then
                echo -e "${RED}Error: Please provide a feature description${NC}"
                echo "Usage: $0 speckit-specify \"description\""
                exit 1
            fi
            run_speckit_specify "$*"
            ;;
        speckit-plan)
            check_claude
            if [ $# -eq 0 ]; then
                echo -e "${RED}Error: Please provide plan details${NC}"
                echo "Usage: $0 speckit-plan \"tech stack\""
                exit 1
            fi
            run_speckit_plan "$*"
            ;;
        speckit-tasks)
            check_claude
            run_speckit_tasks
            ;;
        speckit-implement)
            check_claude
            run_speckit_implement
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo -e "${RED}Unknown command: $command${NC}"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
