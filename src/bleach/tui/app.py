from textual.app import App, ComposeResult
from textual.containers import Container, VerticalScroll
from textual.widgets import (
    Button,
    Checkbox,
    Footer,
    Header,
    LoadingIndicator,
    RichLog,
    Static,
)

from bleach.core.cleaner import Cleaner
from bleach.core.package_managers import get_package_manager_cleaners
from bleach.core.system import CacheCleaner, SystemLogsCleaner
from bleach.core.tools import DockerCleaner, NpmCleaner, PipCleaner


class BleachApp(App):
    CSS = """
    Screen {
        layout: grid;
        grid-size: 2;
        grid-columns: 35% 1fr;
        background: #1e1e1e;
    }

    /* Sidebar Styling */
    #sidebar {
        background: #252526;
        border-right: solid #333333;
        height: 100%;
        dock: left;
        layout: vertical;
    }

    #sidebar_header {
        background: #3c3c3c;
        color: white;
        text-align: center;
        padding: 1;
        text-style: bold;
    }

    .cleaner-list {
        padding: 1;
        height: 1fr;
    }

    Checkbox {
        padding: 0 1;
        margin: 0;
        color: #cccccc;
    }

    Checkbox:hover {
        background: #2a2d2e;
        color: white;
    }

    /* Controls Area */
    #controls {
        height: auto;
        padding: 1;
        border-top: solid #333333;
        background: #252526;
    }

    Button {
        width: 100%;
        margin-bottom: 1;
    }

    #btn_run {
        background: #007acc;
        color: white;
    }

    #btn_run:hover {
        background: #0062a3;
    }

    .secondary-btn {
        background: #3e3e42;
        color: #cccccc;
    }

    .secondary-btn:hover {
        background: #4e4e52;
        color: white;
    }

    /* Main Content */
    #main_content {
        height: 100%;
        background: #1e1e1e;
        layout: vertical;
        padding: 0;
    }

    #log_header {
        background: #333333;
        color: white;
        padding: 1;
        text-style: bold;
    }

    RichLog {
        background: #1e1e1e;
        color: #d4d4d4;
        padding: 1;
        height: 1fr;
        scrollbar-background: #1e1e1e;
        scrollbar-color: #424242;
    }

    LoadingIndicator {
        height: 100%;
        content-align: center middle;
        display: none;
    }

    .processing LoadingIndicator {
        display: block;
    }
    """

    TITLE = "Bleach TUI"
    SUB_TITLE = "Professional System Cleaner"

    BINDINGS = [
        ("q", "quit", "Quit"),
        ("d", "toggle_dark", "Toggle Dark Mode"),
        ("a", "select_all", "Select All"),
        ("n", "select_none", "Select None"),
        ("r", "run_cleanup", "Run Cleanup"),
    ]

    def __init__(self) -> None:
        super().__init__()
        self.cleaners: list[Cleaner] = self._discover_cleaners()

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

    def _get_cleaner_id(self, cleaner: Cleaner) -> str:
        # Sanitize ID
        safe_name = (
            cleaner.name.replace(" ", "_")
            .replace("(", "")
            .replace(")", "")
            .replace("/", "_")
            .lower()
        )
        return f"chk_{safe_name}"

    def compose(self) -> ComposeResult:
        yield Header(show_clock=True)

        # Sidebar with checkboxes
        with Container(id="sidebar"):
            yield Static("CLEANUP TASKS", id="sidebar_header")
            with VerticalScroll(classes="cleaner-list"):
                for cleaner in self.cleaners:
                    yield Checkbox(
                        cleaner.name,
                        value=True,
                        id=self._get_cleaner_id(cleaner),
                        tooltip=cleaner.description,
                    )

            with Container(id="controls"):
                yield Button("Select All", id="btn_all", classes="secondary-btn")
                yield Button("Select None", id="btn_none", classes="secondary-btn")
                yield Button("RUN CLEANUP", variant="primary", id="btn_run")

        # Main content area
        with Container(id="main_content"):
            yield Static("ACTIVITY LOG", id="log_header")
            yield RichLog(id="log", markup=True, wrap=True)
            yield LoadingIndicator(id="loader")

        yield Footer()

    def on_mount(self) -> None:
        log = self.query_one(RichLog)
        log.write("[bold green]Welcome to Bleach![/]")
        log.write(f"Detected {len(self.cleaners)} available cleaning modules.\n")
        log.write(
            "[dim]Select tasks from the sidebar and click 'RUN CLEANUP' to start.[/dim]"
        )

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "btn_run":
            self.action_run_cleanup()
        elif event.button.id == "btn_all":
            self.action_select_all()
        elif event.button.id == "btn_none":
            self.action_select_none()

    def action_select_all(self) -> None:
        for checkbox in self.query(Checkbox):
            checkbox.value = True

    def action_select_none(self) -> None:
        for checkbox in self.query(Checkbox):
            checkbox.value = False

    def action_run_cleanup(self) -> None:
        log = self.query_one(RichLog)

        # Identify selected
        to_run = []
        for cleaner in self.cleaners:
            cleaner_id = self._get_cleaner_id(cleaner)
            checkbox = self.query_one(f"#{cleaner_id}", Checkbox)
            if checkbox.value:
                to_run.append(cleaner)

        if not to_run:
            log.write(
                "[bold yellow][!] No tasks selected. "
                "Please select at least one task.[/]"
            )
            return

        # Start loading stats
        self.query_one("#main_content").add_class("processing")
        self.query_one(RichLog).display = False

        self.run_worker(self._perform_cleanup(to_run, log))

    async def _perform_cleanup(self, cleaners: list[Cleaner], log: RichLog) -> None:
        log.clear()
        log.write(f"[bold]Starting cleanup of {len(cleaners)} tasks...[/]\n")

        success_count = 0
        total = len(cleaners)
        total_freed_mb = 0.0

        for cleaner in cleaners:
            log.write(f"Running: [bold cyan]{cleaner.name}[/]...")
            # Yield control to UI loop
            result = cleaner.clean()

            if result.success:
                msg = f"  [green]✔ OK[/]: {result.message}"
                if result.cleaned_size_mb > 0:
                    msg += f" [bold green](Freed {result.cleaned_size_mb:.2f} MB)[/]"
                    total_freed_mb += result.cleaned_size_mb
                log.write(msg)
                success_count += 1
            else:
                log.write(f"  [bold red]✘ FAIL[/]: {result.message}")
                if result.details:
                    log.write(f"    [red]{result.details}[/]")

            log.write("")  # Spacer

        log.write("[bold white]" + "-" * 50 + "[/]")
        summary = f"[bold]Cleanup Complete.[/] ({success_count}/{total} successful)"
        if total_freed_mb > 0:
            summary += (
                f"\n[bold green]Total Space Recovered: {total_freed_mb:.2f} MB[/]"
            )
        log.write(summary)

        # Stop loading
        self.query_one("#main_content").remove_class("processing")
        self.query_one(RichLog).display = True

    def action_toggle_dark(self) -> None:
        self.theme = "bleach" if self.theme == "default" else "default"

if __name__ == "__main__":
    import os
    import shutil
    import sys

    # Auto-elevate to root
    if os.geteuid() != 0:
        # Check if sudo is available
        if not shutil.which("sudo"):
            print("Error: 'sudo' is required to run this application.")
            print("Please install sudo or run as root.")
            sys.exit(1)

        print("Bleach requires root privileges to clean system files.")
        print("Restarting with sudo...")

        # Replace current process with sudo
        # usage: sudo python3 script.py [args]
        args = ["sudo", sys.executable] + sys.argv
        os.execvp("sudo", args)

    app = BleachApp()
    app.run()
