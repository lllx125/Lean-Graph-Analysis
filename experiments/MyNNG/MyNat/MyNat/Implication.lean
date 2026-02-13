import MyNat.Addition

open MyNat

namespace MyNat

theorem implication_one (x y z : MyNat) (h1 : add x y = four) (h2 : add (mul three x) z = two) : add x y = four :=
  h1

theorem implication_two (x y : MyNat) (h : add zero x = add (add zero y) two) : x = add y two :=
  -- We want to transform h: (0+x) = (0+y)+2 into x = y+2
  -- LHS: 0+x = x via zero_add
  -- RHS: 0+y = y via zero_add
  Eq.trans
    (Eq.symm (zero_add x))
    (Eq.trans h (congrArg (fun n => add n two) (zero_add y)))

theorem implication_three (x y : MyNat) (h1 : x = three) (h2 : x = three → y = four) : y = four :=
  h2 h1

theorem implication_four (x : MyNat) (h : add x one = four) : x = three :=
  -- Rewrite one and four definitions
  let h_nums : add x (succ zero) = succ three :=
    Eq.trans
      (congrArg (add x) one_eq_succ_zero)
      (Eq.trans h four_eq_succ_three)

  -- Apply add_succ to LHS: add x (succ 0) becomes succ (add x 0)
  let h_add : succ (add x zero) = succ three :=
    Eq.trans (Eq.symm (add_succ x zero)) h_nums

  -- Injectivity: add x 0 = 3
  let h_inj : add x zero = three := succ_inj (add x zero) three h_add

  -- Apply add_zero: x = 3
  Eq.trans (Eq.symm (add_zero x)) h_inj

theorem implication_five (x : MyNat) : x = four → x = four :=
  fun h => h

theorem implication_six (x y : MyNat) : add x one = add y one → x = y :=
  fun h =>
  -- Substitute one = succ zero
  let h_subst : add x (succ zero) = add y (succ zero) :=
    Eq.trans
      (congrArg (add x) one_eq_succ_zero)
      (Eq.trans h (congrArg (add y) (Eq.symm one_eq_succ_zero)))

  -- Pull out succ from both sides using add_succ
  let h_succ : succ (add x zero) = succ (add y zero) :=
    Eq.trans
      (Eq.symm (add_succ x zero))
      (Eq.trans h_subst (add_succ y zero))

  -- Remove succ and add_zero
  let h_inj : add x zero = add y zero := succ_inj (add x zero) (add y zero) h_succ
  Eq.trans (Eq.symm (add_zero x)) (Eq.trans h_inj (add_zero y))

theorem implication_seven (x y : MyNat) (h1 : x = y) (h2 : x ≠ y) : False :=
  h2 h1

theorem zero_ne_one : (zero : MyNat) ≠ one :=
  fun h =>
    -- h is zero = one. We substitute one = succ zero
    let h_succ : zero = succ zero := Eq.trans h one_eq_succ_zero
    zero_ne_succ zero h_succ

theorem one_ne_zero : (one : MyNat) ≠ zero :=
  fun h => zero_ne_one (Eq.symm h)

theorem two_plus_two_ne_five : add (succ (succ zero)) (succ (succ zero)) ≠ succ (succ (succ (succ (succ zero)))) :=
  fun h =>
  let two := succ (succ zero)
  -- Step 1: Reduce LHS add (succ (succ zero)) (succ (succ zero))
  -- add 2 (succ 1) = succ (add 2 1)
  -- add 2 (succ 0) = succ (add 2 0)
  -- add 2 0 = 2
  let lhs_step1 : add two (succ (succ zero)) = succ (add two (succ zero)) := add_succ two (succ zero)
  let lhs_step2 : succ (add two (succ zero)) = succ (succ (add two zero)) := congrArg succ (add_succ two zero)
  let lhs_step3 : succ (succ (add two zero)) = succ (succ two) := congrArg (fun n => succ (succ n)) (add_zero two)

  let lhs_reduce : add two two = succ (succ two) :=
    Eq.trans lhs_step1 (Eq.trans lhs_step2 lhs_step3)

  -- RHS is succ (succ (succ (succ (succ zero)))) which is succ (succ (succ (succ 1))) basically 5
  -- LHS is succ (succ (succ (succ zero))) which is 4

  -- Substitute reduced LHS into hypothesis h
  let h_red : succ (succ (succ (succ zero))) = succ (succ (succ (succ (succ zero)))) :=
    Eq.trans (Eq.symm lhs_reduce) h

  -- Peel off succs
  let h1 := succ_inj _ _ h_red
  let h2 := succ_inj _ _ h1
  let h3 := succ_inj _ _ h2
  let h4 := succ_inj _ _ h3

  -- h4 is zero = succ zero
  zero_ne_succ zero h4

end MyNat
