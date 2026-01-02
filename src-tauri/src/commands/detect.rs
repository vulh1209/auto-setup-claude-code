use serde::{Deserialize, Serialize};
use std::env;
use std::process::Command;

#[derive(Debug, Serialize, Deserialize)]
pub struct SystemInfo {
    pub os: String,
    pub arch: String,
    pub package_manager: Option<String>,
    pub installed_tools: InstalledTools,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct InstalledTools {
    pub nodejs: Option<String>,
    pub npm: Option<String>,
    pub git: Option<String>,
    pub vscode: Option<String>,
    pub bun: Option<String>,
    pub claude_code: Option<String>,
}

#[tauri::command]
pub fn detect_os() -> String {
    #[cfg(target_os = "windows")]
    return "windows".to_string();

    #[cfg(target_os = "macos")]
    return "macos".to_string();

    #[cfg(target_os = "linux")]
    {
        // Detect Linux distribution
        if std::path::Path::new("/etc/debian_version").exists() {
            return "debian".to_string();
        }
        if std::path::Path::new("/etc/fedora-release").exists() {
            return "fedora".to_string();
        }
        if std::path::Path::new("/etc/arch-release").exists() {
            return "arch".to_string();
        }
        if std::path::Path::new("/etc/redhat-release").exists() {
            return "rhel".to_string();
        }
        return "linux".to_string();
    }
}

#[tauri::command]
pub fn detect_package_manager() -> Option<String> {
    let os = detect_os();

    match os.as_str() {
        "windows" => {
            if command_exists("winget") {
                Some("winget".to_string())
            } else {
                None
            }
        }
        "macos" => {
            if command_exists("brew") {
                Some("brew".to_string())
            } else {
                None
            }
        }
        "debian" => Some("apt".to_string()),
        "fedora" | "rhel" => Some("dnf".to_string()),
        "arch" => Some("pacman".to_string()),
        _ => None,
    }
}

#[tauri::command]
pub fn check_command(cmd: String) -> bool {
    command_exists(&cmd)
}

fn command_exists(cmd: &str) -> bool {
    which::which(cmd).is_ok()
}

fn get_version(cmd: &str, args: &[&str]) -> Option<String> {
    Command::new(cmd)
        .args(args)
        .output()
        .ok()
        .and_then(|output| {
            if output.status.success() {
                String::from_utf8(output.stdout)
                    .ok()
                    .map(|s| s.trim().to_string())
            } else {
                None
            }
        })
}

fn check_vscode_installed() -> Option<String> {
    // First try the code command
    if let Some(version) = get_version("code", &["--version"]) {
        return Some(version.lines().next().unwrap_or(&version).to_string());
    }

    // On macOS, check if the app bundle exists
    #[cfg(target_os = "macos")]
    {
        if std::path::Path::new("/Applications/Visual Studio Code.app").exists() {
            // Try to get version from plist
            if let Ok(output) = Command::new("defaults")
                .args(["read", "/Applications/Visual Studio Code.app/Contents/Info", "CFBundleShortVersionString"])
                .output()
            {
                if output.status.success() {
                    if let Ok(version) = String::from_utf8(output.stdout) {
                        return Some(version.trim().to_string());
                    }
                }
            }
            return Some("installed".to_string());
        }
    }

    // On Windows, check Program Files
    #[cfg(target_os = "windows")]
    {
        let paths = [
            r"C:\Program Files\Microsoft VS Code\Code.exe",
            r"C:\Program Files (x86)\Microsoft VS Code\Code.exe",
        ];
        for path in paths {
            if std::path::Path::new(path).exists() {
                return Some("installed".to_string());
            }
        }
    }

    None
}

#[tauri::command]
pub fn get_system_info() -> SystemInfo {
    let os = detect_os();
    let arch = env::consts::ARCH.to_string();
    let package_manager = detect_package_manager();

    let installed_tools = InstalledTools {
        nodejs: get_version("node", &["--version"]),
        npm: get_version("npm", &["--version"]),
        git: get_version("git", &["--version"]),
        vscode: check_vscode_installed(),
        bun: get_version("bun", &["--version"]),
        claude_code: get_version("claude", &["--version"]),
    };

    SystemInfo {
        os,
        arch,
        package_manager,
        installed_tools,
    }
}
