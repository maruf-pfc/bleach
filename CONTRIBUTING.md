# Contributing to Bleach

First off, thanks for taking the time to contribute! 🎉

The following is a set of guidelines for contributing to Bleach. These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

## Code of Conduct

This project and everyone participating in it is governed by the
[Bleach Code of Conduct](CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

- **Ensure the bug was not already reported** by searching on GitHub under [Issues].
- If you're unable to find an open issue addressing the problem, open a new one. Be sure to include a **title and clear description**, as much relevant information as possible, and a **code sample** or an **executable test case** demonstrating the expected behavior that is not occurring.

### Suggesting Enhancements

- Open a new issue and purely describe the feature you would like to see.
- Explain why this feature would be useful to most users.

### Pull Requests

1. Fork the repo and create your branch from `main` (or `dev`).
2. If you've added code that should be tested, add tests.
3. Ensure the test suite passes.
4. Make sure your code lints (`ruff check .`).
5. Issue that pull request!

## Styleguides

### Git Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line

### Python Styleguide

- We use [Ruff](https://beta.ruff.rs/docs/) for linting and formatting.
- We use [MyPy](https://mypy-lang.org/) for static type checking.
- All public functions and classes should have docstrings (Google style).

## Development Setup

1. Clone the repo
2. Install dependencies: `pip install -e ".[dev]"`
3. Run tests: `pytest`
4. Run linter: `ruff check .`

Thanks! ❤️
