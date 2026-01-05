
from textual.app import App, ComposeResult
from textual.containers import Container, VerticalScroll
from textual.widgets import Button, Checkbox, Footer, Header, Label, Log

from bleach.core.cleaner import Cleaner
from bleach.core.package_managers import get_package_manager_cleaners
from bleach.core.system import CacheCleaner, SystemLogsCleaner
from bleach.core.tools import DockerCleaner, NpmCleaner, PipCleaner


class BleachApp(App):
    """A TUI for system cleaning."""

    CSS = """
    Screen {
        layout: grid;
        grid-size: 2;
        grid-columns: 2fr 3fr;
    }

    .box {
        height: 100%;
        border: solid green;
    }

    #sidebar {
        dock: left;
        width: 30%;
        height: 100%;
        border-right: solid green;
    }

    #main_content {
        height: 100%;
    }

    #log_container {
        height: 50%;
        border-top: solid blue;
    }

    Log {
        background: $surface;
    }

    Checkbox {
        padding: 1;
    }

    Button {
        margin: 1 2;
        width: 100%;
    }
    """

    BINDINGS = [
        ("q", "quit", "Quit"),
        ("c", "run_cleanup", "Clean"),
        ("d", "toggle_dark", "Dark Mode"),
    ]

    def __init__(self) -> None:
        super().__init__()
        self.cleaners: list[Cleaner] = self._discover_cleaners()
        self.selected_cleaners: list[Cleaner] = []

    def _discover_cleaners(self) -> list[Cleaner]:
        cleaners: list[Cleaner] = []
        # System
        cleaners.append(SystemLogsCleaner())
        cleaners.append(CacheCleaner())

        # Package Managers
        cleaners.extend(get_package_manager_cleaners())

        # Tools
        cleaners.append(DockerCleaner())
        cleaners.append(NpmCleaner())
        cleaners.append(PipCleaner())

        # Filter available
        return [c for c in cleaners if c.is_available()]

    def compose(self) -> ComposeResult:
        yield Header()

        # Sidebar with checkboxes
        with Container(id="sidebar"):
            yield Label("[b]Available Cleanup Tasks[/b]")
            with VerticalScroll():
                for cleaner in self.cleaners:
                    yield Checkbox(cleaner.name, value=True, id=f"chk_{cleaner.name}")
            yield Button("Run Cleanup", variant="primary", id="btn_run")

        # Main content area (Logs for now, maybe details later)
        with Container(id="main_content"):
            yield Label("[b]Activity Log[/b]")
            yield Log(id="log")

        yield Footer()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "btn_run":
            self.action_run_cleanup()

    def action_run_cleanup(self) -> None:
        log = self.query_one(Log)
        log.write_line("Starting cleanup...")

        # Identify selected
        to_run = []
        for cleaner in self.cleaners:
            checkbox = self.query_one(f"#chk_{cleaner.name}", Checkbox)
            if checkbox.value:
                to_run.append(cleaner)

        if not to_run:
            log.write_line("[!] No tasks selected.")
            return

        # Run them
        self.run_worker(self._perform_cleanup(to_run, log))

    async def _perform_cleanup(self, cleaners: list[Cleaner], log: Log) -> None:
        success_count = 0
        total = len(cleaners)
        for cleaner in cleaners:
            log.write_line(f"Running: {cleaner.name}...")
            result = cleaner.clean()

            if result.success:
                msg = f"[green]OK[/green]: {result.message}"
                if result.cleaned_size_mb > 0:
                    msg += f" (Freed {result.cleaned_size_mb:.2f} MB)"
                log.write_line(msg)
                success_count += 1
            else:
                log.write_line(f"[red]FAIL[/red]: {result.message}")
                if result.details:
                    log.write_line(f"      {result.details}")

        log.write_line("-" * 40)
        log.write_line(f"Cleanup complete. ({success_count}/{total} successful)")

    def action_toggle_dark(self) -> None:
        self.theme = "bleach" if self.theme == "default" else "default"

if __name__ == "__main__":
    app = BleachApp()
    app.run()
