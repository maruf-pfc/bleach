import shutil
import subprocess
from collections.abc import Generator

from bleach.core.cleaner import Cleaner, CleanupResult


class AptCleaner(Cleaner):
    @property
    def name(self) -> str:
        return "APT (Debian/Ubuntu)"

    @property
    def description(self) -> str:
        return "Cleans APT cache and removes unused dependencies."

    def is_available(self) -> bool:
        return shutil.which("apt-get") is not None

    def scan(self) -> CleanupResult:
        # Checking /var/cache/apt/archives size could be a scan method
        return CleanupResult(success=True, message="APT detected.")

    def clean(self) -> Generator[str, None, CleanupResult]:
        try:
            # apt-get clean && apt-get autoremove -y
            steps = [
                (["apt-get", "clean"], "Cleaning APT cache..."),
                (["apt-get", "autoremove", "-y"], "Removing unused packages..."),
            ]

            for cmd, desc in steps:
                yield f"[bold]{desc}[/]"
                process = subprocess.Popen(
                    cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
                )
                if process.stdout:
                    for line in process.stdout:
                        yield f"  {line.strip()}"
                process.wait()

                if process.returncode != 0:
                     raise subprocess.CalledProcessError(process.returncode, cmd)

            return CleanupResult(
                success=True,
                message="APT cleanup completed."
            )
        except subprocess.CalledProcessError as e:
            return CleanupResult(
                success=False, message="APT cleanup failed", details=str(e)
            )

class DnfCleaner(Cleaner):
    @property
    def name(self) -> str:
        return "DNF (Fedora/RHEL)"

    @property
    def description(self) -> str:
        return "Cleans DNF cache."

    def is_available(self) -> bool:
        return shutil.which("dnf") is not None

    def scan(self) -> CleanupResult:
        return CleanupResult(success=True, message="DNF detected.")

    def clean(self) -> Generator[str, None, CleanupResult]:
        try:
            cmd = ["dnf", "clean", "all"]
            yield f"[bold]Running {cmd}[/]"
            process = subprocess.Popen(
                cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
            )
            if process.stdout:
                for line in process.stdout:
                    yield f"  {line.strip()}"
            process.wait()

            if process.returncode != 0:
                raise subprocess.CalledProcessError(process.returncode, cmd)

            return CleanupResult(success=True, message="DNF cache cleaned.")
        except subprocess.CalledProcessError as e:
            return CleanupResult(
                success=False, message="DNF cleanup failed", details=str(e)
            )

class PacmanCleaner(Cleaner):
    @property
    def name(self) -> str:
        return "Pacman (Arch Linux)"

    @property
    def description(self) -> str:
        return "Cleans Pacman cache (removing uninstalled packages)."

    def is_available(self) -> bool:
        return shutil.which("pacman") is not None

    def scan(self) -> CleanupResult:
        return CleanupResult(success=True, message="Pacman detected.")

    def clean(self) -> Generator[str, None, CleanupResult]:
        try:
            cmd = ["pacman", "-Sc", "--noconfirm"]
            yield f"[bold]Running {cmd}[/]"
            process = subprocess.Popen(
                cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
            )
            if process.stdout:
                for line in process.stdout:
                    yield f"  {line.strip()}"
            process.wait()

            if process.returncode != 0:
                raise subprocess.CalledProcessError(process.returncode, cmd)

            return CleanupResult(success=True, message="Pacman cache cleaned.")
        except subprocess.CalledProcessError as e:
            return CleanupResult(
                success=False, message="Pacman cleanup failed", details=str(e)
            )

def get_package_manager_cleaners() -> list[Cleaner]:
    """Returns a list of available package manager cleaners for the system."""
    cleaners = [AptCleaner(), DnfCleaner(), PacmanCleaner()]
    return [c for c in cleaners if c.is_available()]
