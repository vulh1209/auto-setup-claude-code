mod commands;

use commands::{detect, install};

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .invoke_handler(tauri::generate_handler![
            detect::detect_os,
            detect::detect_package_manager,
            detect::check_command,
            detect::get_system_info,
            install::install_nodejs,
            install::install_claude_code,
            install::install_git,
            install::install_vscode,
            install::install_bun,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
