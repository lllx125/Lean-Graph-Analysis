# Lean Graph Analysor

A Python package for analyzing dependency graphs in Lean theorem proving projects.

## Overview

This package provides tools to:
- Generate dependency graphs from Lean projects using Lean Dojo
- Compute various graph metrics on theorem dependency networks
- Analyze and visualize the structure of mathematical proofs
- Evaluate how well different metrics separate theorem classes

## Features

### Graph Generation

The `graph_generator` module uses Lean Dojo to extract dependency graphs from Lean repositories, returning graph objects ready for analysis.

### Metrics

The `metrics` package contains various graph algorithms that compute node-level metrics. Each metric takes a graph as input and returns a dictionary mapping each node to a real number score.

Common metrics include:
- PageRank and centrality measures
- Clustering coefficients
- Shortest path distances
- Community detection scores

### Metric Analysis

The `metric_analysis` package evaluates the quality of different metrics:

#### Separation Analysis

The `seperation_analysis` module assesses how well a metric separates different classes of theorems:

**Input:**
- `rank_list`: Theorems ranked by metric score
- `theorem_list`: All theorems labeled by class (e.g., 1 for Mathlib, 0 for homework)

**Output:**
- Separation quality metrics (e.g., AUC, precision@k, separation score)

This helps identify which graph metrics best distinguish important library theorems from problem-specific proofs.

### Utilities

The `utils` package provides:
- **notifier**: External notifications and stream output capture for monitoring long-running analyses
- **plot_graph**: Visualization tools for dependency graphs using matplotlib and igraph

## Installation

From the workspace root:

```bash
uv sync
```

## Usage

```python
from lean_graph_analysor import graph_generator
from lean_graph_analysor.metrics import pagerank
from lean_graph_analysor.metric_analysis import seperation_analysis
from lean_graph_analysor.utils import plot_graph

# Generate graph from Lean project
graph = graph_generator.generate_from_repo("path/to/lean/project")

# Compute metrics
scores = pagerank.compute(graph)

# Analyze separation quality
separation_score = seperation_analysis.evaluate(
    rank_list=sorted_theorems,
    theorem_list=labeled_theorems
)

# Visualize
plot_graph.plot(graph, node_scores=scores)
```

## Development

### Running Tests

```bash
uv run pytest
```

### Code Quality

```bash
# Linting
uv run ruff check lean_graph_analysor/

# Formatting
uv run ruff format lean_graph_analysor/

# Type checking
uv run mypy lean_graph_analysor/
```

## API Reference

See the docstrings in each module for detailed API documentation.

## License

MIT
