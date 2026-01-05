
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
        background: #111111;
    }

    /* Sidebar Styling */
    #sidebar {
        background: #1e1e1e;
        border-right: solid #333333;
        height: 100%;
        layout: vertical;
        scrollbar-gutter: stable;
    }

    #sidebar_header {
        background: #252526;
        color: #eeeeee;
        text-align: center;
        padding: 1;
        text-style: bold;
        border-bottom: solid #333333;
    }

    .cleaner-list {
        padding: 1;
        height: 1fr;
    }

    Checkbox {
        padding: 1;
        margin: 0;
        color: #888888;
        border: none;
    }

    Checkbox:hover {
        background: #2a2d2e;
        color: #ffffff;
    }

    Checkbox.-on {
        color: #ffffff;
        text-style: bold;
    }

    /* Controls Area */
    #controls {
        height: auto;
        padding: 1 2;
        border-top: solid #333333;
        background: #1e1e1e;
    }

    Button {
        width: 100%;
        margin-bottom: 1;
        height: 3;
        border: none;
    }

    #btn_run {
        background: #007acc;
        color: white;
        text-style: bold;
    }

    #btn_run:hover {
        background: #0062a3;
    }

    .secondary-btn {
        background: #333333;
        color: #cccccc;
        height: 1;
        margin-bottom: 0;
        border: none;
    }

    .secondary-btn:hover {
        background: #444444;
        color: white;
    }

    /* Main Content */
    #main_content {
        height: 100%;
        background: #111111;
        layout: vertical;
        padding: 0;
    }

    #log_header {
        background: #252526;
        color: #eeeeee;
        padding: 1;
        text-style: bold;
        border-bottom: solid #333333;
    }

    RichLog {
        background: #0d0d0d;
        color: #d4d4d4;
        padding: 1 2;
        height: 1fr;
        scrollbar-background: #0d0d0d;
        scrollbar-color: #333333;
        border: none;
    }

    LoadingIndicator {
        height: 100%;
        content-align: center middle;
        display: none;
        color: #007acc;
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
            log.write("[bold yellow][!] No tasks selected.[/]")
            return

        # Start loading stats
        self.query_one("#main_content").add_class("processing")
        self.query_one(RichLog).display = False

        # Launch thread
        self.run_worker(lambda: self._cleanup_worker(to_run, log), thread=True)

    def _cleanup_worker(self, cleaners: list[Cleaner], log: RichLog) -> None:
        self.call_from_thread(log.clear)
        self.call_from_thread(
            log.write, f"[bold]Starting cleanup of {len(cleaners)} tasks...[/]\n"
        )

        success_count = 0
        total_freed_mb = 0.0

        for cleaner in cleaners:
            self.call_from_thread(
                log.write, f"Running: [bold cyan]{cleaner.name}[/]..."
            )

            gen = cleaner.clean()
            result = None
            try:
                while True:
                    msg = next(gen)
                    self.call_from_thread(log.write, f"  {msg}")
            except StopIteration as e:
                result = e.value
            except Exception as e:
                self.call_from_thread(log.write, f"  [bold red]ERROR[/]: {e}")
                continue

            if result and result.success:
                msg = f"  [green]✔ DONE[/]: {result.message}"
                if result.cleaned_size_mb > 0:
                    msg += f" [bold green](Freed {result.cleaned_size_mb:.2f} MB)[/]"
                    total_freed_mb += result.cleaned_size_mb
                self.call_from_thread(log.write, msg)
                success_count += 1
            elif result:
                self.call_from_thread(
                    log.write, f"  [bold red]✘ FAIL[/]: {result.message}"
                )
                if result.details:
                    self.call_from_thread(log.write, f"    [red]{result.details}[/]")

            self.call_from_thread(log.write, "")  # Spacer

        self.call_from_thread(log.write, "[bold white]" + "-" * 50 + "[/]")
        summary = f"[bold]Complete.[/] ({success_count}/{len(cleaners)} successful)"
        if total_freed_mb > 0:
            summary += (
                f"\n[bold green]Total Space Recovered: {total_freed_mb:.2f} MB[/]"
            )
        self.call_from_thread(log.write, summary)

        def stop_loading() -> None:
            self.query_one("#main_content").remove_class("processing")
            self.query_one(RichLog).display = True

        self.call_from_thread(stop_loading)

    def action_toggle_dark(self) -> None:
        self.dark = not self.dark  # type: ignore

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

        # Re-launch with sudo; minimal output to avoid breaking TUI
        # usage: sudo python3 script.py [args]
        args = ["sudo", sys.executable] + sys.argv
        os.execvp("sudo", args)

    app = BleachApp()
    app.run()
