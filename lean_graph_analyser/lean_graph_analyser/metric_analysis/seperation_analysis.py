"""
Separation Analysis Module.

This module analyzes how well graph metrics separate different classes of theorems.

Input:
    - rank_list: A ranked list of theorems based on a metric
    - theorem_list: List of all theorems labeled with their class
                    (e.g., 1 for Mathlib theorems, 0 for homework problems)

Output:
    - Separation quality metrics indicating how well the ranking separates
      Mathlib theorems from homework problems or other theorem classes.

The module supports human-labeled important theorems for more nuanced analysis.
"""
