import shutil
import subprocess
from collections.abc import Generator
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

    def clean(self) -> Generator[str, None, CleanupResult]:
        try:
            cmd = ["docker", "system", "prune", "-f"]
            yield "Pruning Docker resources..."
            process = subprocess.Popen(
                cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
            )
            if process.stdout:
                for line in process.stdout:
                    yield f"  {line.strip()}"
            process.wait()

            if process.returncode != 0:
                raise subprocess.CalledProcessError(process.returncode, cmd)

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

    def clean(self) -> Generator[str, None, CleanupResult]:
        try:
            cmd = ["npm", "cache", "clean", "--force"]
            yield "Cleaning NPM cache..."
            process = subprocess.Popen(
                cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
            )
            if process.stdout:
                for line in process.stdout:
                    yield f"  {line.strip()}"
            process.wait()

            if process.returncode != 0:
                raise subprocess.CalledProcessError(process.returncode, cmd)

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

    def clean(self) -> Generator[str, None, CleanupResult]:
        path = Path.home() / ".cache/pip"
        if path.exists():
            yield f"Removing Pip cache at {path}..."
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
