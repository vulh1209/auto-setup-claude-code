import { Tool } from "../App";

interface ToolSelectorProps {
  tools: Tool[];
  selectedTools: Set<string>;
  onToggle: (toolId: string) => void;
  disabled?: boolean;
}

function ToolSelector({
  tools,
  selectedTools,
  onToggle,
  disabled,
}: ToolSelectorProps) {
  return (
    <div className="space-y-2">
      {tools.map((tool) => (
        <label
          key={tool.id}
          className={`glass-card flex items-center gap-3 p-3 transition-all duration-200 cursor-pointer ${
            tool.installed
              ? "!border-green-500/30 !bg-green-950/20"
              : selectedTools.has(tool.id)
              ? "!border-claude-500/40 !bg-claude-950/20"
              : ""
          } ${disabled ? "opacity-60 cursor-not-allowed" : ""}`}
        >
          <input
            type="checkbox"
            checked={tool.installed || selectedTools.has(tool.id)}
            onChange={() => onToggle(tool.id)}
            disabled={disabled || tool.installed}
            className="checkbox-custom"
          />
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2">
              <span className="font-medium text-neutral-200">{tool.name}</span>
              {tool.required && !tool.installed && (
                <span className="text-xs px-1.5 py-0.5 bg-claude-500/20 text-claude-400 rounded border border-claude-500/30 font-mono">
                  required
                </span>
              )}
              {tool.installed && (
                <span className="text-xs px-1.5 py-0.5 bg-green-500/20 text-green-400 rounded border border-green-500/30 flex items-center gap-1 font-mono">
                  <svg className="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      fillRule="evenodd"
                      d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                      clipRule="evenodd"
                    />
                  </svg>
                  installed
                </span>
              )}
            </div>
            <p className="text-sm text-neutral-500 truncate font-mono">
              {tool.description}
              {tool.version && (
                <span className="text-claude-500/70"> • v{tool.version.replace(/^v/, '')}</span>
              )}
            </p>
          </div>
        </label>
      ))}
    </div>
  );
}

export default ToolSelector;
