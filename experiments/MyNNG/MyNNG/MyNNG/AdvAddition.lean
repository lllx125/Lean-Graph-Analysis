import MyNNG.Addition

open MyNat

theorem add_right_cancel (a b n : MyNat) : add a n = add b n → a = b := by
  induction n with
  | zero =>
    intro h
    rw [add_zero, add_zero] at h
    exact h
  | succ d ih =>
    intro h
    rw [add_succ, add_succ] at h
    apply succ_inj at h
    apply ih
    exact h

theorem add_left_cancel (a b n : MyNat) : add n a = add n b → a = b := by
  repeat rw [add_comm n]
  intro h
  apply add_right_cancel at h
  exact h

theorem add_left_eq_self (x y : MyNat) : add x y = y → x = zero := by
  intro h
  nth_rewrite 2 [← zero_add y] at h
  apply add_right_cancel at h
  exact h

theorem add_right_eq_self (x y : MyNat) : add x y = x → y = zero := by
  intro h
  nth_rewrite 2 [← zero_add x] at h
  nth_rewrite 2 [add_comm] at h
  apply add_left_cancel at h
  exact h

theorem add_right_eq_zero (a b : MyNat) : add a b = zero → a = zero := by
  induction b with
  | zero =>
    intro h
    rw [add_zero] at h
    exact h
  | succ d ih =>
    intro h
    rw [add_succ] at h
    symm at h
    apply zero_ne_succ at h
    cases h

theorem add_left_eq_zero (a b : MyNat) : add a b = zero → b = zero := by
  rw [add_comm]
  exact add_right_eq_zero b a
