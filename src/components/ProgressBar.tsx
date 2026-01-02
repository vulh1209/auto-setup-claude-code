interface ProgressBarProps {
  progress: number;
  isInstalling: boolean;
}

function ProgressBar({ progress, isInstalling }: ProgressBarProps) {
  return (
    <div className="mb-3">
      <div className="flex items-center justify-between mb-2">
        <span className="text-sm font-mono text-neutral-400">
          <span className="text-claude-500">&gt;</span>{" "}
          {isInstalling ? "installing..." : progress === 100 ? "complete" : "ready"}
        </span>
        <span className="text-sm font-mono text-claude-500">{Math.round(progress)}%</span>
      </div>
      <div className="w-full h-1.5 bg-charcoal-800 rounded-full overflow-hidden border border-white/5">
        <div
          className={`h-full transition-all duration-300 ease-out ${
            progress === 100
              ? "bg-gradient-to-r from-green-500 to-green-400"
              : "bg-gradient-to-r from-claude-600 to-claude-400"
          }`}
          style={{
            width: `${progress}%`,
            boxShadow: progress > 0 ? `0 0 10px ${progress === 100 ? 'rgba(34, 197, 94, 0.5)' : 'rgba(232, 124, 46, 0.5)'}` : 'none'
          }}
        />
      </div>
    </div>
  );
}

export default ProgressBar;
