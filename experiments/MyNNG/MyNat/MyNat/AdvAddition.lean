import MyNat.Addition

open MyNat

namespace MyNat

theorem add_right_cancel (a b n : MyNat) : add a n = add b n → a = b :=
  match n with
  | zero => fun h =>
    -- h : add a zero = add b zero
    -- We transform it to a = b using add_zero
    Eq.trans (Eq.symm (add_zero a)) (Eq.trans h (add_zero b))
  | succ d => fun h =>
    -- h : add a (succ d) = add b (succ d)
    -- We need to prove a = b.
    -- First, peel off the outer succ using add_succ and the hypothesis
    let h_succ : succ (add a d) = succ (add b d) :=
      Eq.trans (Eq.symm (add_succ a d)) (Eq.trans h (add_succ b d))
    -- Injectivity of succ gives us add a d = add b d
    let h_inner : add a d = add b d := succ_inj (add a d) (add b d) h_succ
    -- Inductive hypothesis gives a = b
    add_right_cancel a b d h_inner

theorem add_left_cancel (a b n : MyNat) : add n a = add n b → a = b :=
  fun h =>
  -- Convert add n a = add n b  ->  add a n = add b n using commutativity
  let h_comm := Eq.trans (add_comm a n) (Eq.trans h (add_comm n b))
  add_right_cancel a b n h_comm

theorem add_left_eq_self (x y : MyNat) : add x y = y → x = zero :=
  fun h =>
  -- h : add x y = y
  -- We want to see this as: add x y = add zero y
  let h_eq_zero_add := Eq.trans h (Eq.symm (zero_add y))
  -- Cancel y on the right
  add_right_cancel x zero y h_eq_zero_add

theorem add_right_eq_self (x y : MyNat) : add x y = x → y = zero :=
  fun h =>
  -- h : add x y = x
  -- Rewrite LHS to add y x
  let h_comm := Eq.trans (add_comm y x) h
  -- Rewrite RHS to add zero x
  let h_norm := Eq.trans h_comm (Eq.symm (zero_add x))
  -- Cancel x on the right
  add_right_cancel y zero x h_norm

theorem add_right_eq_zero (a b : MyNat) : add a b = zero → a = zero :=
  match b with
  | zero => fun h =>
    -- h : add a zero = zero
    -- add_zero says add a zero = a, so a = zero
    Eq.trans (Eq.symm (add_zero a)) h
  | succ d => fun h =>
    -- h : add a (succ d) = zero
    -- add_succ says add a (succ d) = succ (add a d)
    -- This implies succ (add a d) = zero
    let h_contra : succ (add a d) = zero :=
      Eq.trans (Eq.symm (add_succ a d)) h
    -- This contradicts zero_ne_succ (which says zero != succ ...)
    -- zero_ne_succ takes (add a d) and proves zero != succ (add a d)
    -- We apply symmetry to h_contra to get zero = succ (add a d), then apply the contradiction
    False.elim (zero_ne_succ (add a d) (Eq.symm h_contra))

theorem add_left_eq_zero (a b : MyNat) : add a b = zero → b = zero :=
  fun h =>
  -- Commute to apply add_right_eq_zero
  add_right_eq_zero b a (Eq.trans (add_comm b a) h)

end MyNat
