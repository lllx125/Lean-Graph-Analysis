import MyNNG.LessOrEqual
import MyNNG.Multiplication

open MyNat

theorem mul_le_mul_right (a b t : MyNat) (h : le a b) : le (mul a t) (mul b t) := by
  cases h with
  |intro d hd =>
    use mul d t
    rw [hd, add_mul]

theorem mul_left_ne_zero (a b : MyNat) (h : mul a b ≠ zero) : b ≠ zero := by
  intro hb
  apply h
  rw [hb, mul_zero]

theorem eq_succ_of_ne_zero (a : MyNat) (ha : a ≠ zero) : ∃ n, a = succ n := by
  induction a with
  | zero => contradiction
  | succ d =>
    use d

theorem one_le_of_ne_zero (a : MyNat) (ha : a ≠ zero) : le one a := by
  apply eq_succ_of_ne_zero at ha
  cases ha with
  |intro n hn =>
    use n
    rw [hn, succ_eq_add_one, add_comm]

theorem le_mul_right (a b : MyNat) (h : mul a b ≠ zero) : le a (mul a b) := by
  apply mul_left_ne_zero at h
  apply one_le_of_ne_zero at h
  apply mul_le_mul_right one b a at h
  rw [one_mul, mul_comm] at h
  exact h

theorem mul_right_eq_one (x y : MyNat) (h : mul x y = one) : x = one := by
  have h2 : mul x y ≠ zero := by
    rw [h, one_eq_succ_zero]
    symm
    apply zero_ne_succ
  apply le_mul_right at h2
  rw [h] at h2
  apply le_one at h2
  cases h2 with
  |inl h0 =>
    rw [h0] at h
    rw [zero_mul] at h
    cases h
  |inr h1 =>
    exact h1

theorem mul_ne_zero (a b : MyNat) (ha : a ≠ zero) (hb : b ≠ zero) : mul a b ≠ zero := by
  apply eq_succ_of_ne_zero at ha
  apply eq_succ_of_ne_zero at hb
  cases ha with
  |intro c hc =>
    cases hb with
    |intro d hd =>
      rw [hc, hd]
      rw [mul_succ, add_succ]
      symm
      apply zero_ne_succ

theorem mul_eq_zero (a b : MyNat) (h : mul a b = zero) : a = zero ∨ b = zero := by
  have h2 := mul_ne_zero a b
  tauto

theorem mul_left_cancel (a b c : MyNat) (ha : a ≠ zero) (h : mul a b = mul a c) : b = c := by
  revert c
  induction b with
  | zero =>
    intro c h
    rw [mul_zero] at h
    symm at h
    apply mul_eq_zero at h
    cases h with
    |inl ha0 => contradiction
    |inr hc0 =>
      rw [hc0]
  | succ d ih =>
    intro c h
    induction c with
    | zero =>
      rw [mul_zero] at h
      apply mul_eq_zero at h
      cases h with
      |inl ha0 => contradiction
      |inr hc0 => contradiction
    | succ e he =>
      rw [mul_succ, mul_succ] at h
      apply add_right_cancel at h
      apply ih at h
      rw [h]

theorem mul_right_eq_self (a b : MyNat) (ha : a ≠ zero) (h : mul a b = a) : b = one := by
  nth_rewrite 2 [← mul_one a] at h
  exact mul_left_cancel a b one ha h
