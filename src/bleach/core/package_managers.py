import shutil
import subprocess

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

    def clean(self) -> CleanupResult:
        try:
            # sudo apt-get clean && sudo apt-get autoremove -y
            steps = [
                ["sudo", "apt-get", "clean"],
                ["sudo", "apt-get", "autoremove", "-y"],
            ]
            for cmd in steps:
                subprocess.run(
                    cmd, check=True, capture_output=True
                )

            return CleanupResult(
                success=True,
                message="APT cache cleaned and unused packages removed."
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

    def clean(self) -> CleanupResult:
        try:
            subprocess.run(
                ["sudo", "dnf", "clean", "all"],
                check=True,
                capture_output=True,
            )
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

    def clean(self) -> CleanupResult:
        try:
            # pacman -Sc (Clean cache), usually requires interactive confirmation
            # or --noconfirm logic
            subprocess.run(
                ["sudo", "pacman", "-Sc", "--noconfirm"],
                check=True,
                capture_output=True,
            )
            return CleanupResult(success=True, message="Pacman cache cleaned.")
        except subprocess.CalledProcessError as e:
            return CleanupResult(
                success=False, message="Pacman cleanup failed", details=str(e)
            )

def get_package_manager_cleaners() -> list[Cleaner]:
    """Returns a list of available package manager cleaners for the system."""
    cleaners = [AptCleaner(), DnfCleaner(), PacmanCleaner()]
    return [c for c in cleaners if c.is_available()]
