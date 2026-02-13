import MyNat.AdvAddition

open MyNat

namespace MyNat

theorem le_refl (x : MyNat) : le x x :=
  Exists.intro zero (Eq.symm (add_zero x))

theorem zero_le (x : MyNat) : le zero x :=
  Exists.intro x (Eq.symm (zero_add x))

theorem le_succ_self (x : MyNat) : le x (succ x) :=
  Exists.intro one (succ_eq_add_one x)

theorem le_trans (x y z : MyNat) (hxy : le x y) (hyz : le y z) : le x z :=
  match hxy, hyz with
  | Exists.intro a ha, Exists.intro b hb =>
    Exists.intro (add a b)
      (Eq.trans hb
        (Eq.trans
          (congrArg (fun n => add n b) ha)
          (add_assoc x a b)))

theorem le_zero (x : MyNat) (hx : le x zero) : x = zero :=
  match hx with
  | Exists.intro a ha =>
    -- ha : zero = add x a
    -- symm ha : add x a = zero
    add_right_eq_zero x a (Eq.symm ha)

theorem le_antisymm (x y : MyNat) (hxy : le x y) (hyx : le y x) : x = y :=
  match hxy, hyx with
  | Exists.intro a ha, Exists.intro b hb =>
    -- y = x + a (ha)
    -- x = y + b (hb)
    -- x = (x + a) + b = x + (a + b)
    let h_subst := Eq.trans hb (congrArg (fun n => add n b) ha)
    let h_assoc := Eq.trans h_subst (add_assoc x a b)
    -- x = x + (a + b) implies a + b = 0
    let h_sum_zero := add_right_eq_self x (add a b) (Eq.symm h_assoc)
    -- a + b = 0 implies b = 0
    let hb_zero := add_left_eq_zero a b h_sum_zero
    -- substitute b = 0 into x = y + b
    Eq.trans hb (Eq.trans (congrArg (add y) hb_zero) (add_zero y))

theorem or_symm (x y : MyNat) (h : x = four ∨ y = three) : y = three ∨ x = four :=
  match h with
  | Or.inl hx => Or.inr hx
  | Or.inr hy => Or.inl hy

theorem le_total (x y : MyNat) : (le x y) ∨ (le y x) :=
  match y with
  | zero => Or.inr (zero_le x)
  | succ d =>
    match le_total x d with
    | Or.inl h_le_x_d =>
      -- x <= d -> x <= succ d
      Or.inl (le_trans x d (succ d) h_le_x_d (le_succ_self d))
    | Or.inr h_le_d_x =>
      -- d <= x means x = d + e
      match h_le_d_x with
      | Exists.intro e he =>
        match e with
        | zero =>
          -- x = d + 0 = d. So x <= succ d.
          let h_x_eq_d := Eq.trans he (add_zero d)
          -- We need succ d = x + 1.
          -- 1. succ d = succ x (because d = x)
          -- 2. succ x = x + 1
          let h_succ : succ d = add x one :=
             Eq.trans (congrArg succ (Eq.symm h_x_eq_d)) (succ_eq_add_one x)
          Or.inl (Exists.intro one h_succ)
        | succ a =>
          -- x = d + succ a = succ d + a. So succ d <= x.
          -- he : x = add d (succ a)
          -- add_succ : add d (succ a) = succ (add d a)
          -- succ_add : add (succ d) a = succ (add d a)
          let h_final := Eq.trans he (Eq.trans (add_succ d a) (Eq.symm (succ_add d a)))
          Or.inr (Exists.intro a h_final)

theorem succ_le_succ (x y : MyNat) (hx : le (succ x) (succ y)) : le x y :=
  match hx with
  | Exists.intro d hd =>
    -- succ y = succ x + d
    -- succ y = succ (x + d)
    let h_assoc := Eq.trans hd (succ_add x d)
    let h_inj := succ_inj y (add x d) h_assoc
    Exists.intro d h_inj

theorem le_one (x : MyNat) (hx : le x one) : x = zero ∨ x = one :=
  match x with
  | zero => Or.inl rfl
  | succ d =>
    -- hx : le (succ d) one
    -- Substitute one = succ zero to get le (succ d) (succ zero)
    let h_le_succ : le (succ d) (succ zero) :=
      Eq.subst one_eq_succ_zero (motive := fun n => le (succ d) n) hx
    -- Apply succ_le_succ to strip succs
    let h_le_zero := succ_le_succ d zero h_le_succ
    -- implies d = 0
    let h_eq_zero := le_zero d h_le_zero
    -- We have x = succ d, so x = succ zero.
    -- We need x = one. Since one = succ zero, this holds.
    let x_eq_one := Eq.trans (congrArg succ h_eq_zero) (Eq.symm one_eq_succ_zero)
    Or.inr x_eq_one

theorem le_two (x : MyNat) (hx : le x two) : x = zero ∨ x = one ∨ x = two :=
  match x with
  | zero => Or.inl rfl
  | succ y =>
    match y with
    | zero =>
      -- Case: x = succ zero.
      -- Goal: succ zero = one.
      -- one_eq_succ_zero gives: one = succ zero.
      Or.inr (Or.inl (Eq.symm one_eq_succ_zero))
    | succ z =>
      -- Case: x = succ (succ z).
      -- 1. Unfold 'two' to 'succ (succ zero)'
      let two_def : two = succ (succ zero) :=
        Eq.trans two_eq_succ_one (congrArg succ one_eq_succ_zero)

      -- 2. Substitute 'two' in the hypothesis hx
      -- hx : le (succ (succ z)) two
      let h_sub : le (succ (succ z)) (succ (succ zero)) :=
        Eq.subst two_def (motive := fun n => le (succ (succ z)) n) hx

      -- 3. Peel off the succ wrappers
      let h_le_z : le z zero :=
        succ_le_succ z zero (succ_le_succ (succ z) (succ zero) h_sub)

      -- 4. Prove z = zero
      let z_is_zero : z = zero := le_zero z h_le_z

      -- 5. Build the equality x = two
      -- succ (succ z) = succ (succ zero) = two
      let x_eq_two : succ (succ z) = two :=
        Eq.trans
          (congrArg (fun n => succ (succ n)) z_is_zero)
          (Eq.symm two_def)

      Or.inr (Or.inr x_eq_two)

theorem one_add_le_self (x : MyNat) : le x (add one x) :=
  Exists.intro one (add_comm one x)

theorem reflexive (x : MyNat) : le x  x := le_refl x

theorem le_succ (a b : MyNat) : le a b → le a (succ b) :=
  fun ⟨c, hc⟩ =>
  Exists.intro (succ c) (Eq.trans (congrArg succ hc) (Eq.symm (add_succ a c)))

end MyNat
