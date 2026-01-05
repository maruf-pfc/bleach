
from typing import Any

import pytest


@pytest.fixture
def mock_shutil_which(mocker: Any) -> Any:
    return mocker.patch("shutil.which")

@pytest.fixture
def mock_subprocess_run(mocker: Any) -> Any:
    return mocker.patch("subprocess.run")
