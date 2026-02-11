import MyNNG.Addition

open MyNat

theorem add_algo_1 (a b c d : MyNat) : add (add a b) (add c d) = add (add (add a c) d) b := by
  repeat rw [add_assoc]
  rw [add_left_comm b c]
  rw [add_comm b d]

theorem succ_ne_zero (a : MyNat) : succ a ≠ zero := by
  intro h
  rw [← is_zero_succ a]
  rw [h]
  rw [is_zero_zero]
  trivial

theorem succ_ne_succ (m n : MyNat) (h : m ≠ n) : succ m ≠ succ n := by
  contrapose! h
  apply succ_inj at h
  exact h
