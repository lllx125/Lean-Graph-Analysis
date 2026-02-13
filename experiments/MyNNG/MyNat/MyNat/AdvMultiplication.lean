import MyNat.LessOrEqual
import MyNat.Multiplication

open MyNat

namespace MyNat

theorem mul_le_mul_right (a b t : MyNat) (h : le a b) : le (mul a t) (mul b t) :=
  match h with
  | Exists.intro d hd =>
    Exists.intro (mul d t)
      (Eq.trans
        (congrArg (fun x => mul x t) hd)
        (add_mul a d t))

theorem mul_left_ne_zero (a b : MyNat) (h : mul a b ≠ zero) : b ≠ zero :=
  fun hb => h (Eq.trans (congrArg (mul a) hb) (mul_zero a))

theorem eq_succ_of_ne_zero (a : MyNat) (ha : a ≠ zero) : ∃ n, a = succ n :=
  match a with
  | zero => False.elim (ha rfl)
  | succ d => Exists.intro d rfl

theorem one_le_of_ne_zero (a : MyNat) (ha : a ≠ zero) : le one a :=
  match eq_succ_of_ne_zero a ha with
  | Exists.intro n hn =>
    Exists.intro n
      (Eq.trans hn
        (Eq.trans (succ_eq_add_one n) (add_comm n one)))

theorem le_mul_right (a b : MyNat) (h : mul a b ≠ zero) : le a (mul a b) :=
  let hb_ne_zero := mul_left_ne_zero a b h
  let h_one_le_b := one_le_of_ne_zero b hb_ne_zero
  let h_mul_le := mul_le_mul_right one b a h_one_le_b

  -- h_mul_le : le (mul one a) (mul b a)
  -- simplify LHS: mul one a = a
  let lhs_simp : mul one a = a := one_mul a
  -- simplify RHS: mul b a = mul a b
  let rhs_simp : mul b a = mul a b := mul_comm b a

  Eq.subst rhs_simp (motive := fun x => le a x)
    (Eq.subst lhs_simp (motive := fun x => le x (mul b a)) h_mul_le)

theorem mul_right_eq_one (x y : MyNat) (h : mul x y = one) : x = one :=
  -- Prove mul x y != 0
  let h_ne_zero : mul x y ≠ zero :=
    fun hz =>
      -- hz : mul x y = zero
      -- h  : mul x y = one
      -- Eq.symm hz : zero = mul x y
      -- Eq.trans (Eq.symm hz) h : zero = one
      zero_ne_succ zero (Eq.trans (Eq.symm hz) h)

  let h_le := le_mul_right x y h_ne_zero
  -- Rewrite h in h_le to get le x one
  -- h_le : le x (mul x y)
  -- Eq.subst replaces (mul x y) with one using h
  let h_le_one : le x one := Eq.subst h (motive := le x) h_le

  match le_one x h_le_one with
  | Or.inl h0 =>
    -- Case x = 0. Substitute into original hypothesis h: mul 0 y = 1
    let h_sub := Eq.subst h0 (motive := fun n => mul n y = one) h
    -- zero_mul y says mul 0 y = 0
    let h_contra := Eq.trans (Eq.symm (zero_mul y)) h_sub -- 0 = 1
    False.elim (zero_ne_succ zero h_contra)
  | Or.inr h1 => h1

theorem mul_ne_zero (a b : MyNat) (ha : a ≠ zero) (hb : b ≠ zero) : mul a b ≠ zero :=
  match a with
  | zero => False.elim (ha rfl)
  | succ m =>
    match b with
    | zero => False.elim (hb rfl)
    | succ n =>
      -- mul (succ m) (succ n)
      -- = add (mul (succ m) n) (succ m)    [via mul_succ]
      -- = succ (add (mul (succ m) n) m)    [via add_succ]
      let h_mul := mul_succ (succ m) n
      let h_add := add_succ (mul (succ m) n) m
      let h_res := Eq.trans h_mul h_add

      -- If mul ... = zero
      fun h_zero =>
        -- succ ... = zero
        let h_contra := Eq.trans (Eq.symm h_res) h_zero
        -- Contradiction
        zero_ne_succ (add (mul (succ m) n) m) (Eq.symm h_contra)

theorem mul_eq_zero (a b : MyNat) (h : mul a b = zero) : a = zero ∨ b = zero :=
  match a with
  | zero => Or.inl rfl
  | succ m =>
    match b with
    | zero => Or.inr rfl
    | succ n =>
      -- mul (succ m) (succ n) = add (mul (succ m) n) (succ m) = succ (...)
      -- This is structurally non-zero.
      let h_unfold : mul (succ m) (succ n) = succ (add (mul (succ m) n) m) :=
        Eq.trans (mul_succ (succ m) n) (add_succ (mul (succ m) n) m)

      -- h says this equals zero
      let h_contra : succ (add (mul (succ m) n) m) = zero :=
        Eq.trans (Eq.symm h_unfold) h

      -- zero cannot equal succ (...)
      False.elim (zero_ne_succ (add (mul (succ m) n) m) (Eq.symm h_contra))

theorem mul_left_cancel (a b c : MyNat) (ha : a ≠ zero) (h : mul a b = mul a c) : b = c :=
  match b with
  | zero =>
    -- mul a 0 = mul a c => 0 = mul a c
    let h_eq := Eq.trans (Eq.symm (mul_zero a)) h
    match mul_eq_zero a c (Eq.symm h_eq) with
    | Or.inl ha_zero => False.elim (ha ha_zero)
    | Or.inr hc_zero => Eq.symm hc_zero
  | succ d =>
    match c with
    | zero =>
      -- mul a (succ d) = mul a 0 => mul a (succ d) = 0
      let h_eq := Eq.trans h (mul_zero a)
      match mul_eq_zero a (succ d) h_eq with
      | Or.inl ha_zero => False.elim (ha ha_zero)
      | Or.inr hd_zero => False.elim (zero_ne_succ d (Eq.symm hd_zero))
    | succ e =>
      -- h : mul a (succ d) = mul a (succ e)
      -- We need: add (mul a d) a = add (mul a e) a

      -- LHS: add (mul a d) a = mul a (succ d)
      let lhs_to_mul := Eq.symm (mul_succ a d)
      -- RHS: mul a (succ e) = add (mul a e) a
      let mul_to_rhs := mul_succ a e

      -- Chain: add ... = mul ... = mul ... = add ...
      let h_expand := Eq.trans lhs_to_mul (Eq.trans h mul_to_rhs)

      -- Cancel 'a' on the right
      let h_cancel := add_right_cancel (mul a d) (mul a e) a h_expand

      -- Recurse
      let ih := mul_left_cancel a d e ha h_cancel
      congrArg succ ih

theorem mul_right_eq_self (a b : MyNat) (ha : a ≠ zero) (h : mul a b = a) : b = one :=
  mul_left_cancel a b one ha (Eq.trans h (Eq.symm (mul_one a)))

end MyNat
