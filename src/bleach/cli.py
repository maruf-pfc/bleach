
import typer

from bleach import __version__
from bleach.tui.app import BleachApp

app = typer.Typer(
    name="bleach",
    help="A safe, cross-platform terminal-based system cleaner.",
    add_completion=False,
)

def version_callback(value: bool) -> None:
    if value:
        typer.echo(f"Bleach v{__version__}")
        raise typer.Exit()

@app.command()
def main(
    version: bool | None = typer.Option(
        None, "--version", "-v", help="Show version", callback=version_callback
    ),  # noqa: B008
) -> None:
    """
    Launch the Bleach TUI.
    """
    tui = BleachApp()
    tui.run()

if __name__ == "__main__":
    app()
