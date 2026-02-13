"""
Test script to build a dependency graph from MyNat using lean_graph_analysor package.
"""

from pathlib import Path
from dotenv import load_dotenv
load_dotenv()

from lean_dojo_v2.lean_dojo.data_extraction.lean import LeanGitRepo
from lean_dojo_v2.lean_dojo.data_extraction.trace import trace
from lean_graph_analyser.graph_generator import GraphGenerator

def main():
    """Build and analyze the MyNat dependency graph."""

    # Path to the MyNat Lean project
    MyNat_path = Path(__file__).parent / "MyNat"

    print(f"Building dependency graph for MyNat project at: {MyNat_path}")
    print("=" * 70)

    # Step 1: Create a LeanGitRepo from the local path
    print("\nStep 1: Creating LeanGitRepo from local path...")
    repo = LeanGitRepo.from_path(MyNat_path)

    # Step 2: Trace the repository to extract AST and dependency information
    print("\nStep 2: Tracing the repository (this may take a while)...")
    traced_repo = trace(repo)

    print(f"Repository traced successfully!")
    print(f"   - Repository name: {traced_repo.name}")
    print(f"   - Number of traced files: {len(traced_repo.traced_files)}")

    # Step 3: Create a GraphGenerator instance
    print("\nStep 3: Initializing GraphGenerator...")
    graph_location = Path(__file__).parent / "graphs" / "MyNat_dependency_graph.graphml"

    generator = GraphGenerator(
        traced_repo=traced_repo,
        graph_location=str(graph_location)
    )

    # Step 4: Generate the graph
    print("\nStep 4: Generating dependency graph...")
    graph = generator.generate()

    # Step 5: Display graph statistics
    print("\n" + "=" * 70)
    print("Graph Statistics:")
    print("=" * 70)
    print(f"   - Total nodes (theorems/definitions): {graph.vcount()}")
    print(f"   - Total edges (dependencies): {graph.ecount()}")
    print(f"   - Average degree: {2 * graph.ecount() / graph.vcount():.2f}")
    print(f"   - Density: {graph.density():.6f}")

    # Display some example nodes
    if graph.vcount() > 0:
        print("\nSample nodes (first 5):")
        for i, v in enumerate(graph.vs[:5]):
            print(f"   {i+1}. {v['name']} ({v['kind']}) in {Path(v['file']).name}")

    # Display node type distribution
    print("\nNode type distribution:")
    node_types = {}
    for v in graph.vs:
        kind = v['kind']
        node_types[kind] = node_types.get(kind, 0) + 1

    for kind, count in sorted(node_types.items(), key=lambda x: x[1], reverse=True):
        print(f"   - {kind}: {count}")

    print("\nGraph generation complete!")
    print(f"Graph saved to: {graph_location}")
    print("\nYou can now use this graph for further analysis.")

    return graph

if __name__ == "__main__":
    graph = main()
