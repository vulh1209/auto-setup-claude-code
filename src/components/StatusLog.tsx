export interface LogEntry {
  type: "info" | "success" | "error" | "warning";
  message: string;
  timestamp: Date;
}

interface StatusLogProps {
  logs: LogEntry[];
}

function StatusLog({ logs }: StatusLogProps) {
  if (logs.length === 0) return null;

  const getLogPrefix = (type: LogEntry["type"]) => {
    switch (type) {
      case "success":
        return { symbol: "✓", color: "text-green-400" };
      case "error":
        return { symbol: "✗", color: "text-red-400" };
      case "warning":
        return { symbol: "!", color: "text-amber-400" };
      default:
        return { symbol: "›", color: "text-claude-500" };
    }
  };

  return (
    <div className="glass-card overflow-hidden max-h-48 overflow-y-auto font-mono text-sm">
      {logs.map((log, index) => {
        const prefix = getLogPrefix(log.type);
        return (
          <div
            key={index}
            className={`flex items-start gap-2 px-3 py-2 ${
              index !== logs.length - 1 ? "border-b border-white/5" : ""
            }`}
          >
            <span className={`flex-shrink-0 ${prefix.color} font-bold`}>
              {prefix.symbol}
            </span>
            <span className="flex-1 break-words text-neutral-300">
              {log.message}
            </span>
            <span className="flex-shrink-0 text-xs text-neutral-600">
              {log.timestamp.toLocaleTimeString("en-US", {
                hour: "2-digit",
                minute: "2-digit",
                second: "2-digit",
                hour12: false,
              })}
            </span>
          </div>
        );
      })}
    </div>
  );
}

export default StatusLog;
