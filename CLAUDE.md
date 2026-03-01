# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PwnDoc MCP Server is a Model Context Protocol (MCP) server that enables AI assistants to interact with PwnDoc penetration testing documentation systems. It has two implementations with complete feature parity:
- **Python** (primary): Located in `python/` directory
- **Native C++**: Located in `native/` directory

**Status**: Unreleased - no backward compatibility requirements.

## Common Commands

### Python Development

```bash
# Setup (from python/ directory)
cd python
python -m venv venv
source venv/bin/activate
pip install -e ".[dev]"

# Run all tests
pytest

# Run single test file
pytest tests/test_client.py

# Run single test
pytest tests/test_client.py::test_authentication

# Run with coverage
pytest --cov=pwndoc_mcp_server --cov-report=html

# Linting and formatting
ruff check src/
ruff check --fix src/
black src/

# Type checking
mypy src/pwndoc_mcp_server/

# All quality checks
ruff check src/ && black --check src/ && mypy src/pwndoc_mcp_server/ && pytest

# Build package
python -m build
```

### Native C++ Development

```bash
# Build (from native/ directory)
cd native
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
```

### CLI Commands (after installation)

```bash
pwndoc-mcp test           # Test connection
pwndoc-mcp tools          # List available tools
pwndoc-mcp serve          # Start MCP server
pwndoc-mcp config init    # Interactive config setup
pwndoc-mcp claude-install # Install for Claude Desktop
```

## Architecture

### Python Implementation (`python/src/pwndoc_mcp_server/`)

| File | Purpose |
|------|---------|
| `server.py` | MCP protocol server - registers 90 tools, handles JSON-RPC messages, supports stdio/SSE transports |
| `client.py` | PwnDoc REST API client - authentication, rate limiting, retries, all API endpoints |
| `config.py` | Configuration management - env vars, YAML files, CLI args |
| `cli.py` | Typer CLI commands |
| `mcp_installer.py` | Claude Desktop integration |
| `logging_config.py` | Logging setup |

### Key Patterns

**Tool Registration**: Tools are defined with name, description, JSON schema, and handler function in `server.py`. Add new tools by:
1. Define tool in `_register_tools()`
2. Add handler method
3. Add to tool dispatcher

**Authentication Flow**: Prefers username/password (auto-refresh) over static tokens. See `client.py:PwnDocClient`.

**Error Hierarchy**: `PwnDocError` base class with `AuthenticationError`, `RateLimitError`, `NotFoundError` subclasses.

## Code Style

- Line length: 100 characters
- Black for formatting
- Ruff for linting (select: E, F, I, W)
- mypy for type checking (Python 3.8+ target)
- Conventional commits (feat/fix/docs/refactor/test/chore)

## Testing

Tests are in `python/tests/`. Uses pytest with async support (`pytest-asyncio`). Fixtures in `conftest.py` provide mock data for audits, findings, clients, etc.

Integration tests (marked `@pytest.mark.integration`) require a real PwnDoc instance via `PWNDOC_TEST_URL`, `PWNDOC_TEST_USER`, `PWNDOC_TEST_PASS`.
