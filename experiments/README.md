# Lean Graph Experiments

Experimental scripts and analysis notebooks using the `lean_graph_analysor` package.

## Overview

This directory contains experimental code, scripts, and Jupyter notebooks that apply the `lean_graph_analysor` package to real Lean projects for research and analysis.

Whenever the `lean_graph_analysor` package is updated, experiments automatically get the latest changes since it imports the package directly from the workspace.

## Purpose

The experiments directory serves as:
- A testing ground for new analysis techniques
- A collection of research scripts and reproducible experiments
- Example usage of the `lean_graph_analysor` API
- A workspace for exploratory data analysis on Lean dependency graphs

## Structure

```
experiments/
├── scripts/              # Python scripts (to be added)
├── notebooks/            # Jupyter notebooks (to be added)
├── data/                 # Experiment data and results (to be added)
└── README.md
```

## Installation

From the workspace root:

```bash
uv sync
```

This installs the `lean_graph_analysor` package and all dependencies, making it available for your experiments.

## Usage

### Running Experiment Scripts

```bash
# Run a specific experiment script
uv run python experiments/scripts/my_experiment.py

# Or use Python directly in the activated environment
uv run python
>>> import sys
>>> sys.path.append('.')
>>> from lean_graph_analysor import graph_generator
>>> # Your experiment code here
```

### Jupyter Notebooks

```bash
# Install Jupyter if not already installed
uv pip install jupyter ipython

# Launch Jupyter from the workspace root
uv run jupyter notebook experiments/notebooks/
```

## Development Workflow

1. Import the `lean_graph_analysor` package
2. Load or generate Lean dependency graphs
3. Apply metrics and analysis techniques
4. Document findings in scripts or notebooks
5. Share reproducible results

## Example Experiment

```python
from lean_graph_analysor import graph_generator
from lean_graph_analysor.metrics import centrality
from lean_graph_analysor.metric_analysis import seperation_analysis

# Load Lean project
graph = graph_generator.generate_from_repo("mathlib4")

# Compute various metrics
pagerank_scores = centrality.pagerank(graph)
betweenness_scores = centrality.betweenness(graph)

# Analyze which metric better separates important theorems
labeled_theorems = load_labeled_data()
pr_separation = seperation_analysis.evaluate(pagerank_scores, labeled_theorems)
bt_separation = seperation_analysis.evaluate(betweenness_scores, labeled_theorems)

print(f"PageRank separation: {pr_separation}")
print(f"Betweenness separation: {bt_separation}")
```

## Contributing

Add new experiments by:
1. Creating a new Python script or notebook
2. Documenting the experiment's purpose and methodology
3. Including any required data or instructions for reproduction

## License

MIT
