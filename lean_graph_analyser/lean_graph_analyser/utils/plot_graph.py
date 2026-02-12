"""
Graph Plotting Module.

This module provides functionality to visualize and plot the generated dependency
graphs using matplotlib and other visualization libraries.
"""

import igraph as ig
import plotly.graph_objects as go
import numpy as np
import pandas as pd
import webbrowser
import os
from typing import Callable, Dict, Any, Optional

def default_centrality(g: ig.Graph) -> Dict[int, float]:
    """Default centrality: PageRank (approximate importance)."""
    try:
        # Pagerank on the reversed graph highlights 'foundational' nodes
        # directed=True, mode='in' implies analyzing incoming edges (dependencies)
        return dict(zip(range(g.vcount()), g.pagerank(directed=True)))
    except:
        return {v.index: 1.0 for v in g.vs}

def get_namespace(name: str) -> str:
    """Extracts 'Topic' from 'Mathlib.Topic.Subtopic.Theorem'."""
    parts = name.split('.')
    if len(parts) >= 2:
        # Return "Mathlib.Algebra" or just "Algebra" depending on preference
        return parts[1] 
    return "Root"

def compute_mathlib_layout(g: ig.Graph) -> pd.DataFrame:
    """
    Computes the specific X/Y layout used by Mathlib Explorer.
    X-Axis: Topological Depth (Time/Complexity)
    Y-Axis: Semantic Namespace (Topic)
    """
    print("   [Layout] Computing Topological Sort (X-Axis)...")
    try:
        # Topological sort gives a linear ordering of dependencies
        # This is O(V+E), very fast for 200k nodes
        topo_indices = g.topological_sorting(mode='out')
        
        # Create a mapping from node_index -> topo_order
        # We perform a reverse lookup to get the X coordinate for every node
        x_map = np.zeros(g.vcount())
        for rank, node_idx in enumerate(topo_indices):
            x_map[node_idx] = rank
            
        # Apply the Mathlib Explorer scaling factor: index^0.72
        # This compresses the tail end of the graph
        x_coords = np.power(x_map, 0.72)
        
    except ig.InternalError:
        print("   [Warning] Graph has cycles (not a DAG). Fallback to Degree-based X-axis.")
        x_coords = np.array(g.degree(mode='out'), dtype=float)

    print("   [Layout] Computing Namespace Grouping (Y-Axis)...")
    # Extract namespaces
    node_names = g.vs["name"]
    namespaces = [get_namespace(name) for name in node_names]
    
    # Create unique integer ID for each namespace for Y-positioning
    unique_ns = sorted(list(set(namespaces)))
    ns_to_y = {ns: i * 100.0 for i, ns in enumerate(unique_ns)}
    
    # Calculate base Y coordinates
    base_y = np.array([ns_to_y[ns] for ns in namespaces])
    
    # Anti-Collision / Jittering
    # We add random noise to Y to prevent nodes in the same namespace 
    # from forming a flat line.
    # For a prettier "cloud" look, we can sine-wave the jitter based on X
    y_jitter = np.sin(x_coords * 0.1) * 30 + np.random.normal(0, 15, g.vcount())
    y_coords = base_y + y_jitter

    return pd.DataFrame({
        'x': x_coords,
        'y': y_coords,
        'namespace': namespaces,
        'name': node_names
    })

def plot_graph(
    g: ig.Graph, 
    centrality_func: Callable[[ig.Graph], Dict[int, float]] = default_centrality,
    output_file: str = "lean_atlas.html",
    dark_mode: bool = True
):
    """
    Generates an interactive WebGL plot of the graph.
    
    Args:
        g: The igraph object.
        centrality_func: Function accepting g and returning {node_index: score}.
        output_file: Path to save the HTML.
        dark_mode: Whether to use the specific Mathlib Explorer dark theme.
    """
    print(f"🚀 Starting Plot Generation for {g.vcount()} nodes...")

    # 1. Calculate Layout
    layout_df = compute_mathlib_layout(g)
    
    # 2. Calculate Size (Centrality)
    print("   [Metrics] Calculating Centrality...")
    centrality_scores = centrality_func(g)
    # Normalize size: min 2px, max 20px
    scores = np.array([centrality_scores.get(i, 0) for i in range(g.vcount())])
    min_s, max_s = scores.min(), scores.max()
    # Log-scale normalization is usually better for power-law graphs like Mathlib
    sizes = 3 + 15 * (scores - min_s) / (max_s - min_s + 1e-9)

    # 3. Assign Colors (Categorical based on Namespace)
    # We use a hash map to ensure the same namespace always gets the same color
    unique_ns = layout_df['namespace'].unique()
    # Plotly handles mapping automatically if we pass the category column

    # 4. Render with Plotly WebGL
    print("   [Render] Building WebGL Trace...")
    
    # We use Scattergl for performance with 200k+ points
    trace = go.Scattergl(
        x=layout_df['x'],
        y=layout_df['y'],
        mode='markers',
        marker=dict(
            size=sizes,
            color=pd.Categorical(layout_df['namespace']).codes, # Map strings to ints for coloring
            colorscale='Viridis' if dark_mode else 'Turbo',
            showscale=False,
            opacity=0.7,
            line=dict(width=0) # No border improves performance at scale
        ),
        text=layout_df['name'], # Hover text
        hovertemplate="<b>%{text}</b><br>Topic: %{customdata}<extra></extra>",
        customdata=layout_df['namespace']
    )

    # 5. Configure Layout (The "Mathlib Explorer" Look)
    layout = go.Layout(
        title=f"Lean Mathlib Atlas ({g.vcount()} nodes)",
        template="plotly_dark" if dark_mode else "plotly_white",
        xaxis=dict(
            title="Complexity (Topological Depth)",
            showgrid=False,
            zeroline=False,
            showticklabels=False
        ),
        yaxis=dict(
            title="Namespace / Topic",
            showgrid=False,
            zeroline=False,
            showticklabels=False
        ),
        hovermode='closest',
        dragmode='pan', # Default to Panning (like Google Maps)
        width=1600,
        height=1000,
        margin=dict(l=0, r=0, t=30, b=0)
    )

    fig = go.Figure(data=[trace], layout=layout)

    # 6. Save and Open
    print(f"   [Output] Saving to {output_file}...")
    fig.write_html(output_file)
    
    abs_path = os.path.abspath(output_file)
    print(f"✅ Done! Opening {abs_path}")
    webbrowser.open(f"file://{abs_path}")

# ==========================================
# Example Usage
# ==========================================
if __name__ == "__main__":
    # 1. Create a dummy graph for testing (since we don't have your loaded graph)
    print("Generating dummy test graph (Simulating 10,000 nodes)...")
    # Barabasi model simulates the citation/dependency structure well
    g_test = ig.Graph.Barabasi(n=10000, m=2, directed=True)
    
    # Assign dummy names mimicking Mathlib
    topics = ["Algebra", "Topology", "Analysis", "Logic", "Geometry", "NumberTheory"]
    names = []
    for i in range(10000):
        t = topics[i % len(topics)]
        names.append(f"Mathlib.{t}.Basic.Theorem_{i}")
    g_test.vs["name"] = names

    # 2. Define a Custom Centrality Function
    # Example: Size by "Betweenness" (very slow) or just "Degree" (fast)
    def my_custom_size(graph):
        # Let's use simple degree for speed in this demo
        # Returns dict: {node_idx: score}
        deg = graph.degree(mode='in')
        return dict(enumerate(deg))

    # 3. Call the plotting function
    plot_graph(g_test, centrality_func=my_custom_size)