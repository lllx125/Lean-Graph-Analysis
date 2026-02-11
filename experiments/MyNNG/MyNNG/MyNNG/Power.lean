import MyNNG.Multiplication

open MyNat

theorem zero_pow_zero : pow (zero : MyNat)  zero = one := by
  rw [pow_zero]

theorem zero_pow_succ (m : MyNat) : pow (zero : MyNat) (succ m) = zero := by
  rw [pow_succ]
  rw [mul_zero]

theorem pow_one (a : MyNat) : pow a one = a  := by
  rw [one_eq_succ_zero]
  rw [pow_succ]
  rw [pow_zero]
  rw [one_mul]

theorem one_pow (m : MyNat) : pow (one : MyNat) m = one := by
  induction m with
  | zero =>
    rw [pow_zero]
  | succ t ht =>
    rw [pow_succ]
    rw [ht]
    rw [one_mul]

theorem pow_two (a : MyNat) : pow a two = mul a a := by
  rw [two_eq_succ_one]
  rw [pow_succ]
  rw [pow_one]

theorem pow_add (a m n : MyNat) : pow a (add m n) = mul (pow a m) (pow a n) := by
  induction n with
  | zero =>
    rw [add_zero]
    rw [pow_zero]
    rw [mul_one]
  | succ t ht =>
    rw [add_succ]
    rw [pow_succ]
    rw [pow_succ]
    rw [ht]
    rw [mul_assoc]

theorem mul_pow (a b n : MyNat) : pow (mul a b) n = mul (pow a n) (pow b n) := by
  induction n with
  | zero =>
    repeat rw [pow_zero]
    rw [one_mul]
  | succ t ht =>
    repeat rw [pow_succ]
    rw [ht]
    rw [mul_assoc]
    rw [mul_comm (pow b t) (mul a b)]
    rw [mul_comm (pow b t) b]
    repeat rw [← mul_assoc]

theorem pow_pow (a m n : MyNat) : pow (pow a m) n = pow a (mul m n) := by
  induction n with
  | zero =>
    rw [mul_zero]
    rw [pow_zero]
    rw [pow_zero]
  | succ t ht =>
    rw [pow_succ]
    rw [ht]
    rw [mul_succ]
    rw [pow_add]

theorem add_sq (a b : MyNat) : pow (add a b) two = add (add (pow a two) (pow b two)) (mul (mul two a) b) := by
  rw [pow_two, pow_two, pow_two]
  rw [add_right_comm]
  rw [mul_add, add_mul, add_mul]
  rw [two_mul, add_mul]
  rw [mul_comm b a]
  rw [← add_assoc, ← add_assoc]
