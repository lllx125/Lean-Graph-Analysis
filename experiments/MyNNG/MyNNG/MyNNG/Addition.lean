import MyNNG.Header

open MyNat

theorem zero_add (n : MyNat) : add zero n = n := by
  induction n with
  | zero =>
    rw [add_zero]
  | succ d ih =>
    rw [add_succ,ih]

theorem succ_add (a b : MyNat) : add (succ a) b = succ (add a b)  := by
  induction b with
  | zero =>
    rw [add_zero,add_zero]
  | succ d ih =>
    rw [add_succ,ih,add_succ]

theorem add_comm (a b : MyNat) : add a b = add b a := by
  induction b with
  | zero =>
    rw [add_zero, zero_add]
  | succ d ih =>
    rw [add_succ, ih, succ_add]

theorem add_assoc (a b c : MyNat) : add (add a b) c = add a (add b c) := by
  induction c with
  | zero =>
    rw [add_zero, add_zero]
  | succ d ih =>
    rw [add_succ, add_succ, ih, add_succ]

theorem add_right_comm (a b c : MyNat) : add (add a b) c = add (add a c) b := by
  rw [add_assoc]
  rw [add_comm b, add_assoc]

theorem add_left_comm (a b c : MyNat) : add a (add b c) = add b (add a c) := by
  rw [← add_assoc]
  rw [add_comm a b]
  rw [add_assoc]

theorem succ_eq_add_one (n : MyNat) : succ n = add n one := by
  rw [one_eq_succ_zero]
  rw [add_succ, add_zero]
