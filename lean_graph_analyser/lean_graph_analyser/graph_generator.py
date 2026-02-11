"""
GraphGenerator Module
=====================

This module provides the core functionality for extracting fine-grained 
theorem-level dependency graphs from a pre-traced Lean repository.

Classes:
    GraphGenerator: Converts a LeanDojo TracedRepo object into a structured 
                    igraph object representing theorem dependencies.

"""

import os
import igraph as ig
from typing import Optional, Dict, Any
from pathlib import Path

# LeanDojo Imports
from lean_dojo_v2.lean_dojo.data_extraction.traced_data import TracedRepo

# Local Imports
from lean_graph_analyser.utils.notifier import Notifier, ConsoleNotifier

class GraphGenerator:
    """
    Transformer class that converts a LeanDojo TracedRepo into a theorem dependency graph.

    Attributes:
        graph_location (str): Filesystem path where the processed .graphml file 
                              should be saved and loaded from.
        notifier (Notifier): An instance of a Notifier class to broadcast progress 
                             events to external channels (e.g., Discord, Console).
        graph (Optional[ig.Graph]): The generated igraph object (None until generate() is called).
    """

    def __init__(
        self, 
        traced_repo: TracedRepo,
        notifier: Notifier = ConsoleNotifier(),
        graph_location: str = "graphs/dependency_graph.graphml",
    ):
        """
        Initialize the GraphGenerator.

        Args:
            notifier (Notifier): The notifier instance for sending updates.
            graph_location (str, optional): Path to save/load the final graph. 
                                          Defaults to "graphs/dependency_graph.graphml".
        """
        self.graph_location = graph_location
        self.notifier = notifier
        self.graph: Optional[ig.Graph] = None
        self.traced_repo = traced_repo

    def generate(self) -> ig.Graph:
        """
        Execute the graph generation pipeline using a provided TracedRepo.

        Args:
            traced_repo (TracedRepo): A fully traced Lean repository object containing
                                      file-level dependency data and ASTs.

        Returns:
            ig.Graph: The processed dependency graph containing nodes (theorems/defs)
                      and edges (dependencies).
        """
        # 1. Check for existing processed graph (Fast Path)
        # We use the repo name from the TracedRepo to ensure we load the right cache
        # if the user switches repos but keeps the same GraphGenerator instance.
        # (Optional refinement: incorporate commit hash into filename for strict versioning)
        
        if os.path.exists(self.graph_location):
            self.notifier.send(f"📂 Found cached graph at `{self.graph_location}`. Loading...")
            try:
                self.graph = ig.Graph.Read_GraphML(self.graph_location)
                # Simple validation: ensure the graph isn't empty if we expect content
                if self.graph.vcount() > 0:
                    self.notifier.send(f"✅ Graph loaded. Nodes: {self.graph.vcount()}, Edges: {self.graph.ecount()}")
                    return self.graph
                else:
                     self.notifier.send("⚠️ Cached graph is empty. Regenerating...")
            except Exception as e:
                self.notifier.send(f"⚠️ Failed to load cache: {e}. Regenerating...")

        # 2. Build Graph Structure from the TracedRepo
        self.notifier.send(f"🏗️ Building theorem graph from traced repo: `{self.traced_repo.name}`...", important=False)
        self.graph = self._build_igraph_from_trace(self.traced_repo)
        
        # 3. Save Graph for next time
        self._save_graph()
        
        return self.graph

    def _build_igraph_from_trace(self, traced_repo: TracedRepo) -> ig.Graph:
        """
        Converts the TracedRepo AST data into a fine-grained igraph.Graph.
        
        Nodes = Theorems, Definitions, Axioms, Inductives
        Edges = Dependency (Node A uses Node B in its proof/definition)

        Args:
            traced_repo (TracedRepo): The source data containing parsed ASTs.

        Returns:
            ig.Graph: A directed graph where vertices are definitions/theorems
                      and edges represent dependencies.
        """
        G = ig.Graph(directed=True)
        node_lookup: Dict[str, int] = {}
        
        self.notifier.send("🔍 Phase 1: Extracting nodes (Theorems & Definitions)...", important=False)
        
        # --- Phase 1: Node Extraction ---
        # We iterate over every file to find all defined concepts.
        for traced_file in traced_repo.traced_files:
            # get_premise_definitions returns a list of dicts with:
            # 'full_name', 'code', 'start', 'end', 'kind'
            definitions = traced_file.get_premise_definitions()
            
            for definition in definitions:
                full_name = definition.get('full_name')
                
                # Ensure unique nodes (Lean allows overloading, but full_name is usually unique in context)
                if full_name and full_name not in node_lookup:
                    v = G.add_vertex()
                    node_lookup[full_name] = v.index
                    
                    # --- Metadata Population ---
                    v["name"] = full_name
                    v["label"] = full_name 
                    v["kind"] = definition.get("kind", "unknown")
                    v["file"] = str(traced_file.path)
                    v["start_line"] = definition.get("start", [0, 0])[0]
                    v["end_line"] = definition.get("end", [0, 0])[0]
                    
                    # Store the code snippet (useful for LLM analysis later)
                    # We limit size to prevent massive graph files
                    code = definition.get("code", "")
                    v["code"] = code[:2000] if code else "" 
                    v["desc"] = code.split('\n')[0][:100] if code else "" # Quick summary

        self.notifier.send(f"✅ Found {len(node_lookup)} nodes. Phase 2: Extracting edges...", important=True)

        # --- Phase 2: Edge Extraction ---
        # We need to find what each theorem *uses*.
        edges_to_add = set() # Use a set to avoid duplicate edges
        
        # We iterate through 'traced_theorems' because they contain the specific AST 
        # for proofs, which allows us to find dependencies.
        all_traced_theorems = traced_repo.get_traced_theorems()
        total_theorems = len(all_traced_theorems)
        
        for i, traced_thm in enumerate(all_traced_theorems):
            # Progress update every 500 theorems
            if i % 500 == 0:
                 self.notifier.send(f"Processing edges for theorem {i}/{total_theorems}...", important=False)

            source_name = traced_thm.theorem.full_name
            
            # If the theorem itself isn't in our node list (rare, but possible if filtered), skip
            if source_name not in node_lookup:
                continue
                
            source_idx = node_lookup[source_name]

            # Strategy: Extract all identifiers used in the proof.
            # TracedTheorem has a helper method `get_premise_full_names()`
            # This traverses the AST of the proof and finds resolved names.
            used_premises = traced_thm.get_premise_full_names()
            
            for target_name in used_premises:
                # We only care if the premise is a node in our graph
                # (This filters out built-in Lean keywords or local variables)
                if target_name in node_lookup and target_name != source_name:
                    target_idx = node_lookup[target_name]
                    edges_to_add.add((source_idx, target_idx))

        # Bulk add edges for performance
        if edges_to_add:
            G.add_edges(list(edges_to_add))
            
        self.notifier.send(f"✅ Graph built. Nodes: {G.vcount()}, Edges: {G.ecount()}", important=True)

        return G

    def _save_graph(self) -> None:
        """Saves the current igraph object to the configured graph_location."""
        if not self.graph:
            return
            
        try:
            # Ensure directory exists
            os.makedirs(os.path.dirname(self.graph_location), exist_ok=True)
            self.graph.write_graphml(self.graph_location)
            self.notifier.send(f"💾 Graph saved to `{self.graph_location}`", important=True)
        except Exception as e:
            self.notifier.send(f"⚠️ Failed to save graph: {e}", important=True)