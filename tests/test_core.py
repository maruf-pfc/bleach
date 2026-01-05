from typing import Any
from unittest.mock import MagicMock

from bleach.core.package_managers import AptCleaner
from bleach.core.system import SystemLogsCleaner


def test_apt_cleaner_detect(mock_shutil_which: Any) -> None:
    mock_shutil_which.return_value = "/usr/bin/apt-get"
    cleaner = AptCleaner()
    assert cleaner.is_available() is True

def consume_generator(gen: Any) -> Any:
    """Helper to consume generator and get return value."""
    try:
        while True:
            next(gen)
    except StopIteration as e:
        return e.value
    return None

def test_apt_cleaner_clean(mocker: Any) -> None:
    # Mock subprocess.Popen
    mock_popen = mocker.patch("subprocess.Popen")
    process_mock = MagicMock()
    process_mock.stdout = ["Log line 1", "Log line 2"]
    process_mock.returncode = 0
    process_mock.wait.return_value = None
    mock_popen.return_value = process_mock

    cleaner = AptCleaner()
    result = consume_generator(cleaner.clean())

    assert result.success is True
    assert mock_popen.call_count == 2
    # Verify call args (first call)
    args, _ = mock_popen.call_args_list[0]
    assert args[0] == ["apt-get", "clean"]

def test_system_logs_cleaner(mock_shutil_which: Any, mocker: Any) -> None:
    mock_shutil_which.return_value = "/bin/journalctl"

    mock_popen = mocker.patch("subprocess.Popen")
    process_mock = MagicMock()
    process_mock.stdout = ["Vacuuming logs..."]
    process_mock.returncode = 0
    process_mock.wait.return_value = None
    mock_popen.return_value = process_mock

    cleaner = SystemLogsCleaner()
    assert cleaner.is_available() is True

    result = consume_generator(cleaner.clean())
    assert result.success is True

    msg_args, _ = mock_popen.call_args
    assert msg_args[0] == ["journalctl", "--vacuum-size=100M", "--vacuum-time=2weeks"]
