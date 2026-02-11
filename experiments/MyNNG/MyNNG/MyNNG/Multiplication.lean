import MyNNG.Addition

open MyNat

theorem mul_one (m : MyNat) : mul m one = m := by
  rw [one_eq_succ_zero]
  rw [mul_succ]
  rw [mul_zero]
  rw [zero_add]

theorem zero_mul (m : MyNat) : mul zero m = zero := by
  induction m with
  | zero =>
    rw [mul_zero]
  | succ d ih =>
    rw [mul_succ, ih, zero_add]

theorem succ_mul (a b : MyNat) : mul (succ a) b = add (mul a b) b := by
  induction b with
  | zero =>
    rw [mul_zero, mul_zero, add_zero]
  | succ d hd =>
    rw [mul_succ, mul_succ, hd, add_succ, add_succ, add_right_comm]

theorem mul_comm (a b : MyNat) : mul a b = mul b a := by
  induction b with
  | zero =>
    rw [zero_mul]
    rw [mul_zero]
  | succ d hd =>
    rw [succ_mul]
    rw [← hd]
    rw [mul_succ]

theorem one_mul (m : MyNat) : mul one m = m := by
  rw [mul_comm, mul_one]

theorem two_mul (m : MyNat) : mul two m = add m m := by
  rw [two_eq_succ_one, succ_mul, one_mul]

theorem mul_add (a b c : MyNat) : mul a (add b c) = add (mul a b) (mul a c) := by
  induction c with
  | zero =>
    rw [add_zero, mul_zero, add_zero]
  | succ d hd =>
    rw [add_succ, mul_succ, hd, mul_succ, add_assoc]

theorem add_mul (a b c : MyNat) : mul (add a b) c = add (mul a c) (mul b c) := by
  rw [mul_comm, mul_add]
  repeat rw [mul_comm c]

theorem mul_assoc (a b c : MyNat) : mul (mul a b) c = mul a (mul b c)  := by
  induction c with
  | zero =>
    rw [mul_zero, mul_zero, mul_zero]
  | succ d ih =>
    rw [mul_succ, mul_succ, ih, mul_add]
