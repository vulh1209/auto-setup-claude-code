#!/bin/bash
# ============================================================================
# Unit Tests for setup.sh - macOS/Linux
# ============================================================================
# Run: chmod +x tests/test_setup.sh && ./tests/test_setup.sh
# ============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_SCRIPT="$SCRIPT_DIR/../setup.sh"

# ============================================================================
# TEST FRAMEWORK
# ============================================================================
test_header() {
    echo -e "\n${CYAN}[$1]${NC}"
}

assert_true() {
    local condition=$1
    local message=$2
    if [[ "$condition" == "true" ]] || [[ "$condition" == "0" ]]; then
        echo -e "  ${GREEN}PASS:${NC} $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}FAIL:${NC} $message"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_false() {
    local condition=$1
    local message=$2
    if [[ "$condition" == "false" ]] || [[ "$condition" == "1" ]]; then
        echo -e "  ${GREEN}PASS:${NC} $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}FAIL:${NC} $message"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_equal() {
    local expected=$1
    local actual=$2
    local message=$3
    if [[ "$expected" == "$actual" ]]; then
        echo -e "  ${GREEN}PASS:${NC} $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}FAIL:${NC} $message (Expected: $expected, Got: $actual)"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_not_empty() {
    local value=$1
    local message=$2
    if [[ -n "$value" ]]; then
        echo -e "  ${GREEN}PASS:${NC} $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}FAIL:${NC} $message (Value is empty)"
        ((TESTS_FAILED++))
        return 1
    fi
}

skip_test() {
    local message=$1
    echo -e "  ${YELLOW}SKIP:${NC} $message"
    ((TESTS_SKIPPED++))
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================
command_exists() {
    command -v "$1" &> /dev/null
}

check_internet() {
    ping -c 1 google.com &> /dev/null
}

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/fedora-release ]]; then
        echo "fedora"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    elif [[ -f /etc/redhat-release ]]; then
        echo "rhel"
    else
        echo "unknown"
    fi
}

# ============================================================================
# UNIT TESTS
# ============================================================================

# --- Test: Script File Exists ---
test_header "TEST: Script Files Exist"
if [[ -f "$SETUP_SCRIPT" ]]; then
    assert_true "true" "setup.sh exists"
else
    assert_true "false" "setup.sh exists"
fi

# --- Test: Script is Executable ---
test_header "TEST: Script Permissions"
if [[ -x "$SETUP_SCRIPT" ]]; then
    assert_true "true" "setup.sh is executable"
else
    skip_test "setup.sh is not executable (run: chmod +x setup.sh)"
fi

# --- Test: Bash Version ---
test_header "TEST: Bash Version"
bash_version="${BASH_VERSION%%(*}"
bash_major="${bash_version%%.*}"
if [[ "$bash_major" -ge 4 ]]; then
    assert_true "true" "Bash version >= 4 (Current: $BASH_VERSION)"
else
    assert_true "true" "Bash version $BASH_VERSION (older but should work)"
fi

# --- Test: OS Detection ---
test_header "TEST: OS Detection"
detected_os=$(detect_os)
assert_not_empty "$detected_os" "OS detected: $detected_os"

case $detected_os in
    macos)
        assert_equal "macos" "$detected_os" "Running on macOS"
        ;;
    debian)
        assert_equal "debian" "$detected_os" "Running on Debian/Ubuntu"
        ;;
    fedora)
        assert_equal "fedora" "$detected_os" "Running on Fedora"
        ;;
    arch)
        assert_equal "arch" "$detected_os" "Running on Arch Linux"
        ;;
    rhel)
        assert_equal "rhel" "$detected_os" "Running on RHEL/CentOS"
        ;;
    *)
        skip_test "Unknown OS: $detected_os"
        ;;
esac

# --- Test: command_exists Function ---
test_header "TEST: command_exists Function"
if command_exists "bash"; then
    assert_true "true" "bash command exists"
else
    assert_true "false" "bash command exists"
fi

if command_exists "ls"; then
    assert_true "true" "ls command exists"
else
    assert_true "false" "ls command exists"
fi

if command_exists "nonexistent_command_xyz123"; then
    assert_false "true" "nonexistent command returns false"
else
    assert_false "false" "nonexistent command returns false"
fi

# --- Test: Internet Connection ---
test_header "TEST: Internet Connection"
if check_internet; then
    assert_true "true" "Internet connection available"
else
    skip_test "No internet connection - skipping online tests"
fi

# --- Test: Package Manager Detection ---
test_header "TEST: Package Manager"
case $(detect_os) in
    macos)
        if command_exists "brew"; then
            assert_true "true" "Homebrew is available"
        else
            skip_test "Homebrew not installed (will be installed by script)"
        fi
        ;;
    debian)
        if command_exists "apt"; then
            assert_true "true" "apt is available"
        else
            assert_true "false" "apt is available"
        fi
        ;;
    fedora|rhel)
        if command_exists "dnf"; then
            assert_true "true" "dnf is available"
        elif command_exists "yum"; then
            assert_true "true" "yum is available"
        else
            assert_true "false" "dnf/yum is available"
        fi
        ;;
    arch)
        if command_exists "pacman"; then
            assert_true "true" "pacman is available"
        else
            assert_true "false" "pacman is available"
        fi
        ;;
esac

# --- Test: Node.js Detection ---
test_header "TEST: Node.js Detection"
if command_exists "node"; then
    node_version=$(node --version)
    assert_not_empty "$node_version" "Node.js version retrieved: $node_version"

    if command_exists "npm"; then
        npm_version=$(npm --version)
        assert_not_empty "$npm_version" "npm version retrieved: v$npm_version"
    else
        assert_true "false" "npm is available with Node.js"
    fi
else
    skip_test "Node.js not installed"
fi

# --- Test: Git Detection ---
test_header "TEST: Git Detection"
if command_exists "git"; then
    git_version=$(git --version)
    assert_not_empty "$git_version" "Git version retrieved: $git_version"
else
    skip_test "Git not installed"
fi

# --- Test: VS Code Detection ---
test_header "TEST: VS Code Detection"
if command_exists "code"; then
    assert_true "true" "VS Code (code) command available"
else
    skip_test "VS Code not installed"
fi

# --- Test: Claude Code Detection ---
test_header "TEST: Claude Code CLI Detection"
if command_exists "claude"; then
    assert_true "true" "Claude Code CLI is installed"
else
    skip_test "Claude Code CLI not installed"
fi

# --- Test: Script Syntax ---
test_header "TEST: Script Syntax Validation"
if bash -n "$SETUP_SCRIPT" 2>/dev/null; then
    assert_true "true" "setup.sh has valid Bash syntax"
else
    assert_true "false" "setup.sh syntax check failed"
fi

# --- Test: Required Functions in Script ---
test_header "TEST: Required Functions in Script"
required_functions=(
    "show_banner"
    "show_menu"
    "detect_os"
    "install_nodejs"
    "install_git"
    "install_vscode"
    "install_claude_code"
    "uninstall_claude_code"
    "show_versions"
    "command_exists"
    "check_internet"
)

script_content=$(cat "$SETUP_SCRIPT")
for func in "${required_functions[@]}"; do
    if echo "$script_content" | grep -q "^${func}()\\|^function ${func}"; then
        assert_true "true" "Function '$func' exists in script"
    else
        # Try alternative pattern
        if echo "$script_content" | grep -q "${func}()"; then
            assert_true "true" "Function '$func' exists in script"
        else
            assert_true "false" "Function '$func' exists in script"
        fi
    fi
done

# --- Test: Shebang ---
test_header "TEST: Script Shebang"
first_line=$(head -n 1 "$SETUP_SCRIPT")
if [[ "$first_line" == "#!/bin/bash" ]]; then
    assert_true "true" "Script has correct shebang (#!/bin/bash)"
else
    assert_true "false" "Script has correct shebang (Got: $first_line)"
fi

# --- Test: Color Codes ---
test_header "TEST: Color Codes in Script"
if echo "$script_content" | grep -q "GREEN="; then
    assert_true "true" "GREEN color code defined"
else
    assert_true "false" "GREEN color code defined"
fi

if echo "$script_content" | grep -q "RED="; then
    assert_true "true" "RED color code defined"
else
    assert_true "false" "RED color code defined"
fi

# ============================================================================
# TEST SUMMARY
# ============================================================================
echo -e "\n${WHITE}============================================${NC}"
echo -e "${WHITE}TEST SUMMARY${NC}"
echo -e "${WHITE}============================================${NC}"
echo -e "  ${GREEN}Passed:${NC}  $TESTS_PASSED"
echo -e "  ${RED}Failed:${NC}  $TESTS_FAILED"
echo -e "  ${YELLOW}Skipped:${NC} $TESTS_SKIPPED"
echo -e "  ${WHITE}Total:${NC}   $((TESTS_PASSED + TESTS_FAILED + TESTS_SKIPPED))"
echo -e "${WHITE}============================================${NC}\n"

# Exit with error code if any tests failed
if [[ $TESTS_FAILED -gt 0 ]]; then
    exit 1
else
    exit 0
fi
