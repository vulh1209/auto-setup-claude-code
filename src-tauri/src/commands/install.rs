use serde::{Deserialize, Serialize};
use tauri::AppHandle;
use tauri_plugin_shell::ShellExt;

use super::detect::detect_os;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct InstallResult {
    pub success: bool,
    pub message: String,
    pub output: Option<String>,
}

impl InstallResult {
    fn success(message: &str, output: Option<String>) -> Self {
        Self {
            success: true,
            message: message.to_string(),
            output,
        }
    }

    fn error(message: &str) -> Self {
        Self {
            success: false,
            message: message.to_string(),
            output: None,
        }
    }
}

async fn run_shell_command(app: &AppHandle, shell: &str, command: &str) -> Result<String, String> {
    let shell_plugin = app.shell();

    let output = if shell == "powershell" {
        shell_plugin
            .command("powershell")
            .args(["-Command", command])
            .output()
            .await
    } else {
        shell_plugin
            .command("bash")
            .args(["-c", command])
            .output()
            .await
    };

    match output {
        Ok(out) => {
            let stdout = String::from_utf8_lossy(&out.stdout).to_string();
            let stderr = String::from_utf8_lossy(&out.stderr).to_string();

            if out.status.success() {
                Ok(format!("{}\n{}", stdout, stderr).trim().to_string())
            } else {
                Err(format!("Command failed: {}\n{}", stdout, stderr))
            }
        }
        Err(e) => Err(format!("Failed to execute command: {}", e)),
    }
}

#[tauri::command]
pub async fn install_nodejs(app: AppHandle) -> InstallResult {
    let os = detect_os();

    let command = match os.as_str() {
        "windows" => {
            "winget install -e --id OpenJS.NodeJS --accept-package-agreements --accept-source-agreements"
        }
        "macos" => "brew install node",
        "debian" => {
            "curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && sudo apt-get install -y nodejs"
        }
        "fedora" | "rhel" => "sudo dnf install -y nodejs npm",
        "arch" => "sudo pacman -Sy --noconfirm nodejs npm",
        _ => return InstallResult::error("Unsupported operating system"),
    };

    let shell = if os == "windows" { "powershell" } else { "bash" };

    match run_shell_command(&app, shell, command).await {
        Ok(output) => InstallResult::success("Node.js installed successfully", Some(output)),
        Err(e) => InstallResult::error(&e),
    }
}

#[tauri::command]
pub async fn install_claude_code(app: AppHandle) -> InstallResult {
    let os = detect_os();
    let shell = if os == "windows" { "powershell" } else { "bash" };
    let command = "npm install -g @anthropic-ai/claude-code";

    match run_shell_command(&app, shell, command).await {
        Ok(output) => InstallResult::success("Claude Code installed successfully", Some(output)),
        Err(e) => InstallResult::error(&e),
    }
}

#[tauri::command]
pub async fn install_git(app: AppHandle) -> InstallResult {
    let os = detect_os();

    let command = match os.as_str() {
        "windows" => {
            "winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements"
        }
        "macos" => "brew install git",
        "debian" => "sudo apt-get install -y git",
        "fedora" | "rhel" => "sudo dnf install -y git",
        "arch" => "sudo pacman -Sy --noconfirm git",
        _ => return InstallResult::error("Unsupported operating system"),
    };

    let shell = if os == "windows" { "powershell" } else { "bash" };

    match run_shell_command(&app, shell, command).await {
        Ok(output) => InstallResult::success("Git installed successfully", Some(output)),
        Err(e) => InstallResult::error(&e),
    }
}

#[tauri::command]
pub async fn install_vscode(app: AppHandle) -> InstallResult {
    let os = detect_os();

    let command = match os.as_str() {
        "windows" => {
            "winget install -e --id Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements"
        }
        "macos" => "brew install --cask visual-studio-code || brew reinstall --cask visual-studio-code",
        "debian" => {
            r#"wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
               sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && \
               echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null && \
               rm -f packages.microsoft.gpg && \
               sudo apt-get update && sudo apt-get install -y code"#
        }
        "fedora" | "rhel" => {
            r#"sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
               echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null && \
               sudo dnf install -y code"#
        }
        "arch" => "yay -S --noconfirm visual-studio-code-bin || paru -S --noconfirm visual-studio-code-bin",
        _ => return InstallResult::error("Unsupported operating system"),
    };

    let shell = if os == "windows" { "powershell" } else { "bash" };

    match run_shell_command(&app, shell, command).await {
        Ok(output) => InstallResult::success("VS Code installed successfully", Some(output)),
        Err(e) => InstallResult::error(&e),
    }
}

#[tauri::command]
pub async fn install_bun(app: AppHandle) -> InstallResult {
    let os = detect_os();

    let command = match os.as_str() {
        "windows" => "powershell -c \"irm bun.sh/install.ps1 | iex\"",
        _ => "curl -fsSL https://bun.sh/install | bash",
    };

    let shell = if os == "windows" { "powershell" } else { "bash" };

    match run_shell_command(&app, shell, command).await {
        Ok(output) => InstallResult::success("Bun installed successfully", Some(output)),
        Err(e) => InstallResult::error(&e),
    }
}
