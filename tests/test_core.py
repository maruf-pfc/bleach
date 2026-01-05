from typing import Any

from bleach.core.package_managers import AptCleaner
from bleach.core.system import SystemLogsCleaner


def test_apt_cleaner_detect(mock_shutil_which: Any) -> None:
    mock_shutil_which.return_value = "/usr/bin/apt-get"
    cleaner = AptCleaner()
    assert cleaner.is_available() is True

def test_apt_cleaner_clean(mock_subprocess_run: Any) -> None:
    cleaner = AptCleaner()
    result = cleaner.clean()
    assert result.success is True
    assert mock_subprocess_run.call_count == 2
    mock_subprocess_run.assert_any_call(
        ["sudo", "apt-get", "clean"], check=True, capture_output=True
    )

def test_system_logs_cleaner(mock_shutil_which: Any, mock_subprocess_run: Any) -> None:
    mock_shutil_which.return_value = "/bin/journalctl"
    cleaner = SystemLogsCleaner()
    assert cleaner.is_available() is True

    result = cleaner.clean()
    assert result.success is True
    mock_subprocess_run.assert_called_with(
        ["sudo", "journalctl", "--vacuum-size=100M", "--vacuum-time=2weeks"],
        check=True, capture_output=True
    )
