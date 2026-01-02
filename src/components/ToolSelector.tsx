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
          className={`flex items-center gap-3 p-3 rounded-lg border transition-all duration-200 cursor-pointer ${
            tool.installed
              ? "bg-green-950/50 border-green-800"
              : selectedTools.has(tool.id)
              ? "bg-claude-950/50 border-claude-700"
              : "bg-neutral-900 border-neutral-800 hover:border-neutral-700"
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
              <span className="font-medium text-neutral-100">{tool.name}</span>
              {tool.required && !tool.installed && (
                <span className="text-xs px-1.5 py-0.5 bg-amber-900/50 text-amber-400 rounded">
                  Required
                </span>
              )}
              {tool.installed && (
                <span className="text-xs px-1.5 py-0.5 bg-green-900/50 text-green-400 rounded flex items-center gap-1">
                  <svg className="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      fillRule="evenodd"
                      d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                      clipRule="evenodd"
                    />
                  </svg>
                  Installed
                </span>
              )}
            </div>
            <p className="text-sm text-neutral-400 truncate">
              {tool.description}
              {tool.version && (
                <span className="text-neutral-500"> • {tool.version}</span>
              )}
            </p>
          </div>
        </label>
      ))}
    </div>
  );
}

export default ToolSelector;
