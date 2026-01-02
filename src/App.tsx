import { useEffect, useState } from "react";
import { invoke } from "@tauri-apps/api/core";
import ToolSelector from "./components/ToolSelector";
import ProgressBar from "./components/ProgressBar";
import StatusLog from "./components/StatusLog";
import { useInstaller } from "./hooks/useInstaller";

interface SystemInfo {
  os: string;
  arch: string;
  package_manager: string | null;
  installed_tools: {
    nodejs: string | null;
    npm: string | null;
    git: string | null;
    vscode: string | null;
    bun: string | null;
    claude_code: string | null;
  };
}

export interface Tool {
  id: string;
  name: string;
  description: string;
  required?: boolean;
  dependsOn?: string[];
  installed: boolean;
  version?: string;
}

function App() {
  const [systemInfo, setSystemInfo] = useState<SystemInfo | null>(null);
  const [tools, setTools] = useState<Tool[]>([]);
  const [selectedTools, setSelectedTools] = useState<Set<string>>(new Set());

  const { isInstalling, progress, logs, installTools } = useInstaller();

  useEffect(() => {
    loadSystemInfo();
  }, []);

  async function loadSystemInfo() {
    try {
      const info: SystemInfo = await invoke("get_system_info");
      setSystemInfo(info);

      const toolsList: Tool[] = [
        {
          id: "nodejs",
          name: "Node.js",
          description: "Required for Claude Code",
          required: true,
          installed: !!info.installed_tools.nodejs,
          version: info.installed_tools.nodejs || undefined,
        },
        {
          id: "claude_code",
          name: "Claude Code CLI",
          description: "AI coding assistant",
          dependsOn: ["nodejs"],
          installed: !!info.installed_tools.claude_code,
          version: info.installed_tools.claude_code || undefined,
        },
        {
          id: "git",
          name: "Git",
          description: "Version control",
          installed: !!info.installed_tools.git,
          version: info.installed_tools.git || undefined,
        },
        {
          id: "vscode",
          name: "VS Code",
          description: "Code editor",
          installed: !!info.installed_tools.vscode,
          version: info.installed_tools.vscode || undefined,
        },
        {
          id: "bun",
          name: "Bun",
          description: "Fast JS runtime",
          installed: !!info.installed_tools.bun,
          version: info.installed_tools.bun || undefined,
        },
      ];

      setTools(toolsList);

      // Pre-select Node.js and Claude Code if not installed
      const preSelected = new Set<string>();
      if (!info.installed_tools.nodejs) preSelected.add("nodejs");
      if (!info.installed_tools.claude_code) preSelected.add("claude_code");
      setSelectedTools(preSelected);
    } catch (error) {
      console.error("Failed to load system info:", error);
    }
  }

  const handleToggleTool = (toolId: string) => {
    setSelectedTools((prev) => {
      const next = new Set(prev);
      if (next.has(toolId)) {
        next.delete(toolId);

        // Also deselect tools that depend on this one
        tools.forEach((t) => {
          if (t.dependsOn?.includes(toolId)) {
            next.delete(t.id);
          }
        });
      } else {
        next.add(toolId);
        // Auto-select dependencies
        const tool = tools.find((t) => t.id === toolId);
        tool?.dependsOn?.forEach((dep) => {
          const depTool = tools.find((t) => t.id === dep);
          if (depTool && !depTool.installed) {
            next.add(dep);
          }
        });
      }
      return next;
    });
  };

  const handleInstall = () => {
    const toolsToInstall = tools.filter(
      (t) => selectedTools.has(t.id) && !t.installed
    );
    installTools(toolsToInstall.map((t) => t.id));
  };

  const getOsLabel = (os: string) => {
    switch (os) {
      case "windows":
        return "Windows";
      case "macos":
        return "macOS";
      case "debian":
        return "Debian/Ubuntu";
      case "fedora":
        return "Fedora";
      case "arch":
        return "Arch Linux";
      case "rhel":
        return "RHEL/CentOS";
      default:
        return "Linux";
    }
  };

  const toolsToInstallCount = tools.filter(
    (t) => selectedTools.has(t.id) && !t.installed
  ).length;

  return (
    <div className="min-h-screen bg-neutral-950 flex flex-col">
      {/* Header */}
      <header className="bg-neutral-900 border-b border-neutral-800 px-6 py-4">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-claude-600 rounded-lg flex items-center justify-center">
            <svg
              className="w-6 h-6 text-white"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
              />
            </svg>
          </div>
          <div>
            <h1 className="text-lg font-semibold text-neutral-100">
              Claude Code Installer
            </h1>
            {systemInfo && (
              <p className="text-sm text-neutral-400">
                {getOsLabel(systemInfo.os)} • {systemInfo.arch}
                {systemInfo.package_manager &&
                  ` • ${systemInfo.package_manager}`}
              </p>
            )}
          </div>
        </div>
      </header>

      {/* Main content */}
      <main className="flex-1 p-6">
        <div className="mb-4">
          <h2 className="text-sm font-medium text-neutral-300 mb-3">
            Select tools to install:
          </h2>
          <ToolSelector
            tools={tools}
            selectedTools={selectedTools}
            onToggle={handleToggleTool}
            disabled={isInstalling}
          />
        </div>

        {/* Progress section */}
        {(isInstalling || logs.length > 0) && (
          <div className="mt-6">
            <ProgressBar progress={progress} isInstalling={isInstalling} />
            <StatusLog logs={logs} />
          </div>
        )}
      </main>

      {/* Footer */}
      <footer className="bg-neutral-900 border-t border-neutral-800 px-6 py-4">
        <button
          onClick={handleInstall}
          disabled={isInstalling || toolsToInstallCount === 0}
          className={`w-full py-3 px-4 rounded-lg font-medium transition-all duration-200 ${
            isInstalling || toolsToInstallCount === 0
              ? "bg-neutral-800 text-neutral-500 cursor-not-allowed"
              : "bg-claude-600 text-white hover:bg-claude-700 active:bg-claude-800"
          }`}
        >
          {isInstalling
            ? "Installing..."
            : toolsToInstallCount === 0
            ? "All selected tools are installed"
            : `Install Selected (${toolsToInstallCount})`}
        </button>
      </footer>
    </div>
  );
}

export default App;
