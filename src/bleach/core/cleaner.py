from abc import ABC, abstractmethod
from dataclasses import dataclass


@dataclass
class CleanupResult:
    """Result of a cleanup operation."""
    success: bool
    cleaned_size_mb: float = 0.0
    message: str = ""
    details: str | None = None

class Cleaner(ABC):
    """Abstract base class for all cleaner implementations."""

    @property
    @abstractmethod
    def name(self) -> str:
        """Name of the cleaner (e.g., 'APT', 'Docker')."""
        pass

    @property
    @abstractmethod
    def description(self) -> str:
        """Description of what this cleaner does."""
        pass

    @abstractmethod
    def is_available(self) -> bool:
        """Check if this cleaner is applicable to the current system."""
        pass

    @abstractmethod
    def scan(self) -> CleanupResult:
        """Scan for cleanable resources without checking."""
        pass

    @abstractmethod
    def clean(self) -> CleanupResult:
        """Perform the cleanup operation."""
        pass
