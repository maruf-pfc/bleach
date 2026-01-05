import shutil
import subprocess
from pathlib import Path

from bleach.core.cleaner import Cleaner, CleanupResult


class DockerCleaner(Cleaner):
    @property
    def name(self) -> str:
        return "Docker"

    @property
    def description(self) -> str:
        return "Prunes unused Docker images, containers, and networks."

    def is_available(self) -> bool:
        return shutil.which("docker") is not None

    def scan(self) -> CleanupResult:
        return CleanupResult(success=True, message="Docker detected.")

    def clean(self) -> CleanupResult:
        try:
            # docker system prune -f
            subprocess.run(
                ["docker", "system", "prune", "-f"],
                check=True,
                capture_output=True
            )
            return CleanupResult(success=True, message="Docker resources pruned.")
        except subprocess.CalledProcessError as e:
            return CleanupResult(
                success=False, message="Docker cleanup failed", details=str(e)
            )

class NpmCleaner(Cleaner):
    @property
    def name(self) -> str:
        return "NPM Cache"

    @property
    def description(self) -> str:
        return "Cleans NPM cache."

    def is_available(self) -> bool:
        return shutil.which("npm") is not None

    def scan(self) -> CleanupResult:
        return CleanupResult(success=True, message="NPM detected.")

    def clean(self) -> CleanupResult:
        try:
            subprocess.run(
                ["npm", "cache", "clean", "--force"],
                check=True,
                capture_output=True
            )
            return CleanupResult(success=True, message="NPM cache cleaned.")
        except subprocess.CalledProcessError as e:
            return CleanupResult(
                success=False, message="NPM cleanup failed", details=str(e)
            )

class PipCleaner(Cleaner):
    @property
    def name(self) -> str:
        return "Pip Cache"

    @property
    def description(self) -> str:
        return "Removes standard pip cache directory."

    def is_available(self) -> bool:
        # Pip cache is usually at ~/.cache/pip
        return (Path.home() / ".cache/pip").exists()

    def scan(self) -> CleanupResult:
        path = Path.home() / ".cache/pip"
        size = 0.0
        if path.exists():
            size = sum(
                f.stat().st_size for f in path.glob("**/*") if f.is_file()
            ) / (1024 * 1024)
        return CleanupResult(
            success=True,
            cleaned_size_mb=size,
            message=f"Pip cache: {size:.2f} MB"
        )

    def clean(self) -> CleanupResult:
        path = Path.home() / ".cache/pip"
        if path.exists():
            try:
                shutil.rmtree(path)
                return CleanupResult(success=True, message="Pip cache removed.")
            except Exception as e:
                return CleanupResult(
                    success=False,
                    message="Failed to remove pip cache",
                    details=str(e)
                )
        return CleanupResult(
            success=True, message="Pip cache not found (already clean)."
        )
