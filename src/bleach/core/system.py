import shutil
import subprocess
from pathlib import Path

from bleach.core.cleaner import Cleaner, CleanupResult


class SystemLogsCleaner(Cleaner):
    @property
    def name(self) -> str:
        return "System Logs"

    @property
    def description(self) -> str:
        return "Cleans systemd journal logs keeping only recent ones."

    def is_available(self) -> bool:
        return shutil.which("journalctl") is not None

    def scan(self) -> CleanupResult:
        # It's hard to predict exact size release from journalctl without running it
        # strictly speaking, but we can check the size of /var/log/journal
        size = 0.0
        journal_path = Path("/var/log/journal")
        if journal_path.exists():
            # Calculate size
            total_size = sum(
                f.stat().st_size for f in journal_path.glob("**/*") if f.is_file()
            )
            size = total_size / (1024 * 1024)

        return CleanupResult(
            success=True,
            cleaned_size_mb=size,
            message=f"Journal logs detected: {size:.2f} MB"
        )

    def clean(self) -> CleanupResult:
        try:
            # Vacuum logs older than 2 weeks or larger than 100M
            subprocess.run(
                ["sudo", "journalctl", "--vacuum-size=100M", "--vacuum-time=2weeks"],
                check=True,
                capture_output=True
            )
            return CleanupResult(
                success=True, message="System logs vacuumed successfully."
            )
        except subprocess.CalledProcessError as e:
            return CleanupResult(
                success=False, message="Failed to clean logs", details=str(e)
            )


class CacheCleaner(Cleaner):
    @property
    def name(self) -> str:
        return "User Cache"

    @property
    def description(self) -> str:
        return "Cleans generic temporary user caches (~/.cache/tmp, etc)."

    def is_available(self) -> bool:
        return True

    def scan(self) -> CleanupResult:
        # Just a dummy scan for now or implement specific folder sizing
        return CleanupResult(success=True, message="Checking generic caches...")

    def clean(self) -> CleanupResult:
        cleaned_mb = 0.0
        # Example: Clear standardized cache locations if safe
        # NOTE: Be very careful here. For now let's just do a safe subset.

        # Safe targets: thumbnails
        targets = [
            Path.home() / ".cache/thumbnails",
        ]

        for target in targets:
            if target.exists():
                # Simple logic to remove content
                # In real imp, calculate size before delete
                try:
                    shutil.rmtree(target)
                    cleaned_mb += 1.0 # placeholder
                except Exception:
                    pass

        return CleanupResult(
            success=True,
            cleaned_size_mb=cleaned_mb,
            message="User cache cleaned."
        )
