# Lean Graph Analysis

A workspace-based monorepo for analyzing dependency graphs in Lean theorem proving projects.

## Overview

This project provides tools to extract, analyze, and visualize dependency graphs from Lean projects using Lean Dojo. It includes various graph metrics and analysis techniques to understand the structure and relationships between theorems.

## Project Structure

This is a workspace-based monorepo managed with [uv](https://github.com/astral-sh/uv):

```
Lean-Graph-Analysis/
├── lean_graph_analysor/         # Core analysis package
├── experiments/                 # Experimental scripts and notebooks
├── pyproject.toml               # Workspace configuration
└── README.md
```

### Components

#### lean_graph_analysor (Package)

The core package providing graph generation and analysis capabilities:

- **graph_generator.py**: Uses Lean Dojo to extract dependency graphs from Lean repositories
- **utils/**: Utility modules
  - `notifier.py`: External notifications and stream output capture
  - `plot_graph.py`: Graph visualization tools
- **metric_analysis/**: Analysis modules
  - `seperation_analysis.py`: Evaluates how well metrics separate different theorem classes
- **metrics/**: Graph algorithm implementations that assign scores to nodes

#### experiments (Directory)

A directory containing experimental scripts and notebooks that use the `lean_graph_analysor` package. When `lean_graph_analysor` is updated, experiments automatically get the latest changes.

## Prerequisites

- Python >= 3.10
- [uv](https://github.com/astral-sh/uv) package manager
- igraph (already installed in .venv)
- lean-dojo-v2 (already installed in .venv)

## Installation

1. Install uv if you haven't already:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

2. Sync the workspace:
```bash
uv sync
```

This will install all packages in the workspace and their dependencies.

## Development

### Working with the monorepo

All packages are linked together in the workspace. Changes to `lean_graph_analysor` are immediately available in `experiments`.

### Running tests

```bash
uv run pytest
```

### Code formatting and linting

```bash
uv run ruff check .
uv run ruff format .
```

### Type checking

```bash
uv run mypy lean_graph_analysor/
```

## Usage

See individual READMEs for detailed usage instructions:

- [lean_graph_analysor/README.md](lean_graph_analysor/README.md)
- [experiments/README.md](experiments/README.md)

## License

MIT