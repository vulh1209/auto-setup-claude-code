import { useState, useCallback } from "react";
import { invoke } from "@tauri-apps/api/core";
import { LogEntry } from "../components/StatusLog";

interface InstallResult {
  success: boolean;
  message: string;
  output?: string;
}

export function useInstaller() {
  const [isInstalling, setIsInstalling] = useState(false);
  const [progress, setProgress] = useState(0);
  const [logs, setLogs] = useState<LogEntry[]>([]);

  const addLog = useCallback(
    (type: LogEntry["type"], message: string) => {
      setLogs((prev) => [
        ...prev,
        { type, message, timestamp: new Date() },
      ]);
    },
    []
  );

  const installTools = useCallback(
    async (toolIds: string[]) => {
      if (toolIds.length === 0) return;

      setIsInstalling(true);
      setProgress(0);
      setLogs([]);

      const toolNameMap: Record<string, string> = {
        nodejs: "Node.js",
        claude_code: "Claude Code CLI",
        git: "Git",
        vscode: "VS Code",
        bun: "Bun",
      };

      const installFunctionMap: Record<string, string> = {
        nodejs: "install_nodejs",
        claude_code: "install_claude_code",
        git: "install_git",
        vscode: "install_vscode",
        bun: "install_bun",
      };

      // Order matters: nodejs must be first if claude_code is selected
      const orderedTools = [...toolIds].sort((a, b) => {
        if (a === "nodejs") return -1;
        if (b === "nodejs") return 1;
        if (a === "claude_code") return 1;
        if (b === "claude_code") return -1;
        return 0;
      });

      const totalSteps = orderedTools.length;
      let completedSteps = 0;

      for (const toolId of orderedTools) {
        const toolName = toolNameMap[toolId] || toolId;
        const installFunction = installFunctionMap[toolId];

        if (!installFunction) {
          addLog("error", `Unknown tool: ${toolId}`);
          continue;
        }

        addLog("info", `Installing ${toolName}...`);

        try {
          const result: InstallResult = await invoke(installFunction);

          if (result.success) {
            addLog("success", result.message);
          } else {
            addLog("error", result.message);
          }
        } catch (error) {
          addLog("error", `Failed to install ${toolName}: ${error}`);
        }

        completedSteps++;
        setProgress((completedSteps / totalSteps) * 100);
      }

      addLog("success", "Installation complete!");
      setIsInstalling(false);
    },
    [addLog]
  );

  return {
    isInstalling,
    progress,
    logs,
    installTools,
  };
}
