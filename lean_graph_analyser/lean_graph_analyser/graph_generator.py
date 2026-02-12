"""
GraphGenerator Module
=====================

This module extracts fine-grained theorem-dependency graphs from a LeanDojo TracedRepo.
It enriches nodes with metadata (namespaces, code, file paths) suitable for 
high-performance visualization (Cosmograph, Gephi, Plotly).

"""

import os
import igraph as ig
from typing import Optional, Dict, Any, List, Tuple, Set
from pathlib import Path
from loguru import logger

# LeanDojo Imports
from lean_dojo_v2.lean_dojo.data_extraction.traced_data import TracedRepo, TracedFile

# Local Imports
# (Assuming you have a notifier class, otherwise can be replaced with print)
try:
    from lean_graph_analyser.utils.notifier import Notifier, ConsoleNotifier
except ImportError:
    # Fallback if specific project structure isn't present
    class Notifier:
        def send(self, msg, important=False): print(msg)
    class ConsoleNotifier(Notifier): pass

class GraphGenerator:
    """
    Converts a LeanDojo TracedRepo into a structured igraph object.
    
    Features:
    - Extracts Theorems, Definitions, Inductives as Nodes.
    - Extracts dependencies as Directed Edges.
    - Annotates Nodes with:
      - Namespace (e.g., 'Mathlib.Algebra') for coloring.
      - File path for filtering.
      - PageRank for node sizing.
      - Code snippets for tooltips.
    """

    def __init__(
        self, 
        traced_repo: TracedRepo,
        notifier: Notifier = ConsoleNotifier(),
        graph_location: str = "graphs/dependency_graph.graphml",
    ):
        self.graph_location = graph_location
        self.notifier = notifier
        self.graph: Optional[ig.Graph] = None
        self.traced_repo = traced_repo

    def generate(self) -> ig.Graph:
        """
        Main pipeline: Load Cache -> Or Build New -> Save -> Return.
        """
        # 1. Check Cache
        if os.path.exists(self.graph_location):
            self.notifier.send(f"📂 Found cached graph at `{self.graph_location}`. Loading...")
            try:
                self.graph = ig.Graph.Read_GraphML(self.graph_location)
                if self.graph.vcount() > 0:
                    self.notifier.send(f"✅ Loaded {self.graph.vcount()} nodes, {self.graph.ecount()} edges.")
                    return self.graph
            except Exception as e:
                self.notifier.send(f"⚠️ Cache corrupted ({e}). Regenerating...")

        # 2. Build Graph
        self.notifier.send(f"🏗️ Building graph from repo: `{self.traced_repo.name}`...", important=True)
        self.graph = self._build_igraph_from_trace(self.traced_repo)

        # 3. Save
        self._save_graph()
        
        return self.graph

    def _build_igraph_from_trace(self, traced_repo: TracedRepo) -> ig.Graph:
        """Core logic to convert LeanDojo ASTs into a Graph."""
        G = ig.Graph(directed=True)
        node_lookup: Dict[str, int] = {}
        
        # --- Phase 1: Node Extraction (Theorems, Defs, Inductives) ---
        self.notifier.send("🔍 Phase 1: Extracting nodes & metadata...", important=False)
        
        # We iterate over FILES to get everything defined in them (not just theorems)
        for tf in traced_repo.traced_files:
            # get_premise_definitions returns dicts of EVERYTHING defined in the file
            definitions = tf.get_premise_definitions()
            
            for definition in definitions:
                full_name = definition.get('full_name')
                if not full_name or full_name in node_lookup:
                    continue

                v = G.add_vertex()
                node_lookup[full_name] = v.index
                
                # --- Metadata Injection ---
                # 1. Identity
                v["name"] = full_name
                v["label"] = full_name.split('.')[-1] # Short name for display
                
                # 2. Taxonomy (Namespaces) - Crucial for Coloring
                # Example: "Mathlib.Algebra.Group.Defs" -> root="Mathlib", group="Algebra"
                parts = full_name.split('.')
                v["root_namespace"] = parts[0] if parts else "Root"
                v["namespace"] = parts[1] if len(parts) > 1 else parts[0]
                v["full_namespace"] = ".".join(parts[:-1]) if len(parts) > 1 else "Root"

                # 3. Source Location
                v["file_path"] = str(tf.path)
                v["start_line"] = definition.get("start", [0, 0])[0]
                v["end_line"] = definition.get("end", [0, 0])[0]
                
                # 4. Content (Code)
                # Truncate code to 1000 chars to keep graphml size manageable
                raw_code = definition.get("code", "")
                v["code"] = raw_code[:1000] if raw_code else ""
                v["kind"] = definition.get("kind", "unknown") # Theorem, Def, etc.

        self.notifier.send(f"✅ Extracted {len(node_lookup)} nodes.", important=True)

        # --- Phase 2: Edge Extraction (Dependencies) ---
        self.notifier.send("🔗 Phase 2: Extracting dependency edges...", important=False)
        
        edges_to_add: Set[Tuple[int, int]] = set()
        
        # We iterate over TRACED THEOREMS because they contain the proof ASTs 
        # required to find what premises were used.
        all_traced_theorems = traced_repo.get_traced_theorems()
        count = 0
        total = len(all_traced_theorems)

        for traced_thm in all_traced_theorems:
            count += 1
            if count % 1000 == 0:
                print(f"   Processing {count}/{total} theorems...", end='\r')

            source_name = traced_thm.theorem.full_name
            if source_name not in node_lookup:
                continue # Should not happen often
            
            source_idx = node_lookup[source_name]

            # Extract dependencies from the proof AST
            # get_premise_full_names() finds identifiers resolved in the proof
            try:
                used_premises = traced_thm.get_premise_full_names()
                
                for target_name in used_premises:
                    # Filter: Self-loops and references to things not in our graph (e.g. Lean core internals)
                    if target_name in node_lookup and target_name != source_name:
                        target_idx = node_lookup[target_name]
                        edges_to_add.add((source_idx, target_idx))
            except Exception as e:
                # Occasional AST traversal errors shouldn't stop the whole build
                logger.warning(f"Error extracting edges for {source_name}: {e}")

        G.add_edges(list(edges_to_add))
        self.notifier.send(f"✅ Edges extracted. Total Edges: {G.ecount()}", important=True)
        
        return G

    def _save_graph(self) -> None:
        """Saves graph to disk."""
        if not self.graph: return
        try:
            os.makedirs(os.path.dirname(self.graph_location), exist_ok=True)
            self.graph.write_graphml(self.graph_location)
            self.notifier.send(f"💾 Graph saved to `{self.graph_location}`", important=True)
        except Exception as e:
            self.notifier.send(f"⚠️ Failed to save: {e}", important=True)