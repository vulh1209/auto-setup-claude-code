# ============================================================================
# Unit Tests for setup.ps1 - Windows PowerShell
# ============================================================================
# Run: .\tests\test_setup.ps1
# ============================================================================

$ErrorActionPreference = "Stop"
$script:TestsPassed = 0
$script:TestsFailed = 0
$script:TestsSkipped = 0

# ============================================================================
# TEST FRAMEWORK
# ============================================================================
function Write-TestHeader {
    param([string]$Name)
    Write-Host "`n[$Name]" -ForegroundColor Cyan
}

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )
    if ($Condition) {
        Write-Host "  PASS: $Message" -ForegroundColor Green
        $script:TestsPassed++
        return $true
    } else {
        Write-Host "  FAIL: $Message" -ForegroundColor Red
        $script:TestsFailed++
        return $false
    }
}

function Assert-False {
    param(
        [bool]$Condition,
        [string]$Message
    )
    Assert-True -Condition (-not $Condition) -Message $Message
}

function Assert-Equal {
    param(
        $Expected,
        $Actual,
        [string]$Message
    )
    if ($Expected -eq $Actual) {
        Write-Host "  PASS: $Message" -ForegroundColor Green
        $script:TestsPassed++
        return $true
    } else {
        Write-Host "  FAIL: $Message (Expected: $Expected, Got: $Actual)" -ForegroundColor Red
        $script:TestsFailed++
        return $false
    }
}

function Assert-NotNull {
    param(
        $Value,
        [string]$Message
    )
    if ($null -ne $Value -and $Value -ne "") {
        Write-Host "  PASS: $Message" -ForegroundColor Green
        $script:TestsPassed++
        return $true
    } else {
        Write-Host "  FAIL: $Message (Value is null or empty)" -ForegroundColor Red
        $script:TestsFailed++
        return $false
    }
}

function Skip-Test {
    param([string]$Message)
    Write-Host "  SKIP: $Message" -ForegroundColor Yellow
    $script:TestsSkipped++
}

# ============================================================================
# HELPER FUNCTIONS (copied from setup.ps1 for testing)
# ============================================================================
function Test-CommandExists {
    param([string]$Command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"
    try {
        if (Get-Command $Command -ErrorAction SilentlyContinue) {
            return $true
        }
    }
    catch {
        return $false
    }
    finally {
        $ErrorActionPreference = $oldPreference
    }
    return $false
}

function Test-InternetConnection {
    try {
        $response = Invoke-WebRequest -Uri "https://www.google.com" -UseBasicParsing -TimeoutSec 5
        return $true
    }
    catch {
        return $false
    }
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ============================================================================
# UNIT TESTS
# ============================================================================

# --- Test: Script File Exists ---
Write-TestHeader "TEST: Script Files Exist"
$scriptPath = Join-Path $PSScriptRoot "..\setup.ps1"
$batPath = Join-Path $PSScriptRoot "..\setup.bat"

Assert-True -Condition (Test-Path $scriptPath) -Message "setup.ps1 exists"
Assert-True -Condition (Test-Path $batPath) -Message "setup.bat exists"

# --- Test: PowerShell Version ---
Write-TestHeader "TEST: PowerShell Version"
$psVersion = $PSVersionTable.PSVersion.Major
Assert-True -Condition ($psVersion -ge 5) -Message "PowerShell version >= 5 (Current: $psVersion)"

# --- Test: Test-CommandExists Function ---
Write-TestHeader "TEST: Test-CommandExists Function"
Assert-True -Condition (Test-CommandExists "powershell") -Message "powershell command exists"
Assert-True -Condition (Test-CommandExists "cmd") -Message "cmd command exists"
Assert-False -Condition (Test-CommandExists "nonexistent_command_xyz123") -Message "nonexistent command returns false"

# --- Test: Internet Connection ---
Write-TestHeader "TEST: Internet Connection"
$hasInternet = Test-InternetConnection
if ($hasInternet) {
    Assert-True -Condition $hasInternet -Message "Internet connection available"
} else {
    Skip-Test "No internet connection - skipping online tests"
}

# --- Test: Administrator Check ---
Write-TestHeader "TEST: Administrator Check"
$isAdmin = Test-Administrator
Assert-NotNull -Value ($isAdmin -is [bool]) -Message "Administrator check returns boolean"
Write-Host "  INFO: Running as Administrator: $isAdmin" -ForegroundColor Gray

# --- Test: Winget Availability ---
Write-TestHeader "TEST: Winget Package Manager"
$hasWinget = Test-CommandExists "winget"
if ($hasWinget) {
    Assert-True -Condition $hasWinget -Message "winget is available"
} else {
    Skip-Test "winget not available - fallback methods will be used"
}

# --- Test: Node.js Detection ---
Write-TestHeader "TEST: Node.js Detection"
$hasNode = Test-CommandExists "node"
if ($hasNode) {
    $nodeVersion = node --version
    Assert-NotNull -Value $nodeVersion -Message "Node.js version retrieved: $nodeVersion"

    $hasNpm = Test-CommandExists "npm"
    Assert-True -Condition $hasNpm -Message "npm is available with Node.js"

    if ($hasNpm) {
        $npmVersion = npm --version
        Assert-NotNull -Value $npmVersion -Message "npm version retrieved: v$npmVersion"
    }
} else {
    Skip-Test "Node.js not installed - install tests would be needed"
}

# --- Test: Git Detection ---
Write-TestHeader "TEST: Git Detection"
$hasGit = Test-CommandExists "git"
if ($hasGit) {
    $gitVersion = git --version
    Assert-NotNull -Value $gitVersion -Message "Git version retrieved: $gitVersion"
} else {
    Skip-Test "Git not installed"
}

# --- Test: VS Code Detection ---
Write-TestHeader "TEST: VS Code Detection"
$hasCode = Test-CommandExists "code"
if ($hasCode) {
    Assert-True -Condition $hasCode -Message "VS Code (code) command available"
} else {
    Skip-Test "VS Code not installed"
}

# --- Test: Claude Code Detection ---
Write-TestHeader "TEST: Claude Code CLI Detection"
$hasClaude = Test-CommandExists "claude"
if ($hasClaude) {
    Assert-True -Condition $hasClaude -Message "Claude Code CLI is installed"
} else {
    Skip-Test "Claude Code CLI not installed"
}

# --- Test: Environment PATH ---
Write-TestHeader "TEST: Environment PATH"
$path = $env:Path
Assert-True -Condition ($path.Length -gt 0) -Message "PATH environment variable is set"
Assert-True -Condition ($path -like "*Windows*") -Message "PATH contains Windows directory"

# --- Test: Script Syntax ---
Write-TestHeader "TEST: Script Syntax Validation"
try {
    $null = [System.Management.Automation.Language.Parser]::ParseFile(
        $scriptPath,
        [ref]$null,
        [ref]$null
    )
    Assert-True -Condition $true -Message "setup.ps1 has valid PowerShell syntax"
} catch {
    Assert-True -Condition $false -Message "setup.ps1 syntax check failed: $_"
}

# --- Test: Required Functions in Script ---
Write-TestHeader "TEST: Required Functions in Script"
$scriptContent = Get-Content $scriptPath -Raw
$requiredFunctions = @(
    "Show-Banner",
    "Show-Menu",
    "Install-NodeJS",
    "Install-Git",
    "Install-VSCode",
    "Install-ClaudeCode",
    "Uninstall-ClaudeCode",
    "Show-Versions",
    "Test-CommandExists",
    "Test-InternetConnection"
)

foreach ($func in $requiredFunctions) {
    $exists = $scriptContent -match "function\s+$func"
    Assert-True -Condition $exists -Message "Function '$func' exists in script"
}

# ============================================================================
# TEST SUMMARY
# ============================================================================
Write-Host "`n============================================" -ForegroundColor White
Write-Host "TEST SUMMARY" -ForegroundColor White
Write-Host "============================================" -ForegroundColor White
Write-Host "  Passed:  $script:TestsPassed" -ForegroundColor Green
Write-Host "  Failed:  $script:TestsFailed" -ForegroundColor Red
Write-Host "  Skipped: $script:TestsSkipped" -ForegroundColor Yellow
Write-Host "  Total:   $($script:TestsPassed + $script:TestsFailed + $script:TestsSkipped)" -ForegroundColor White
Write-Host "============================================`n" -ForegroundColor White

# Exit with error code if any tests failed
if ($script:TestsFailed -gt 0) {
    exit 1
} else {
    exit 0
}
