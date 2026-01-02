interface ProgressBarProps {
  progress: number;
  isInstalling: boolean;
}

function ProgressBar({ progress, isInstalling }: ProgressBarProps) {
  return (
    <div className="mb-3">
      <div className="flex items-center justify-between mb-1">
        <span className="text-sm font-medium text-neutral-300">
          {isInstalling ? "Installing..." : progress === 100 ? "Complete" : "Ready"}
        </span>
        <span className="text-sm text-neutral-400">{Math.round(progress)}%</span>
      </div>
      <div className="w-full h-2 bg-neutral-800 rounded-full overflow-hidden">
        <div
          className={`h-full transition-all duration-300 ease-out ${
            progress === 100 ? "bg-green-500" : "bg-claude-600"
          }`}
          style={{ width: `${progress}%` }}
        />
      </div>
    </div>
  );
}

export default ProgressBar;
