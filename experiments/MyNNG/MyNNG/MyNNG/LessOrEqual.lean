import MyNNG.AdvAddition

open MyNat

theorem le_refl (x : MyNat) : le x x := by
  use zero
  rw [add_zero]

theorem zero_le (x : MyNat) : le zero x := by
  use x
  rw [zero_add]

theorem le_succ_self (x : MyNat) : le x (succ x) := by
  use one
  rw [one_eq_succ_zero]
  rw [add_succ]
  rw [add_zero]

theorem le_trans (x y z : MyNat) (hxy : le x y) (hyz : le y z) : le x z := by
  cases hxy with
  | intro a ha =>
    cases hyz with
    | intro b hb =>
      apply Exists.intro (add a b)
      rw [hb, ha]
      rw [add_assoc]

theorem le_zero (x : MyNat) (hx : le x zero) : x = zero := by
  cases hx with
  | intro a ha =>
    symm at ha
    apply add_right_eq_zero at ha
    exact ha

theorem le_antisymm (x y : MyNat) (hxy : le x y) (hyx : le y x) : x = y := by
  cases hxy with
  | intro a ha =>
    cases hyx with
    | intro b hb =>
      rw [ha]
      rw [ha, add_assoc] at hb
      symm at hb
      apply add_right_eq_self at hb
      apply add_right_eq_zero at hb
      rw [hb, add_zero]
theorem or_symm (x y : MyNat) (h : x = four ∨ y = three) : y = three ∨ x = four := by
  cases h with
  | inl hx =>
    right
    rw [hx]
  | inr hy =>
    left
    rw [hy]

theorem le_total (x y : MyNat) : (le x y) ∨ (le y x) := by
  induction y with
  | zero =>
    right
    exact zero_le x
  | succ d hd =>
    cases hd with
    | inl h1 =>
      left
      cases h1 with
      | intro e h1 =>
        rw [h1]
        use add e one
        rw [succ_eq_add_one, add_assoc]
    | inr h2 =>
      cases h2 with
      | intro e he =>
        cases e with
        | zero =>
          rw [he]
          left
          rw [add_zero]
          use one
          exact succ_eq_add_one d
        | succ a =>
          right
          use a
          rw [add_succ] at he
          rw [succ_add]
          exact he

theorem succ_le_succ (x y : MyNat) (hx : le (succ x) (succ y)) : le x y := by
  cases hx with
  | intro d hd =>
    use d
    rw [succ_add] at hd
    apply succ_inj at hd
    exact hd

theorem le_one (x : MyNat) (hx : le x one) : x = zero ∨ x = one := by
  induction x with
  | zero =>
    left
    rfl
  | succ d hd =>
    right
    rw[one_eq_succ_zero] at hx
    apply succ_le_succ at hx
    apply le_zero at hx
    rw [hx]
    rfl

theorem le_two (x : MyNat) (hx : le x two) : x = zero ∨ x = one ∨ x = two := by
  cases x with
  | zero =>
    left
    rfl
  | succ y =>
    cases y with
    | zero =>
      right
      left
      rw [one_eq_succ_zero]
    | succ z =>
      rw [two_eq_succ_one, one_eq_succ_zero] at hx ⊢
      apply succ_le_succ at hx
      apply succ_le_succ at hx
      apply le_zero at hx
      rw [hx]
      right
      right
      rfl

theorem one_add_le_self (x : MyNat) : le x (add one x) := by
  use one
  rw [add_comm]

theorem reflexive (x : MyNat) : le x  x := by
  use zero
  rw [add_zero]

theorem le_succ (a b : MyNat) : le a b → le a (succ b) := by
  intro h
  cases h with
  | intro c hc =>
    use succ c
    rw [hc]
    rw [add_succ]
