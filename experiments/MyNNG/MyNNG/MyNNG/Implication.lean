import MyNNG.Addition

open MyNat

theorem implication_one (x y z : MyNat) (h1 : add x y = four) (h2 : add (mul three x) z = two) : add x y = four := by
  exact h1

theorem implication_two (x y : MyNat) (h : add zero x = add (add zero y) two) : x = add y two := by
  rw [zero_add] at h
  rw [zero_add] at h
  exact h

theorem implication_three (x y : MyNat) (h1 : x = three) (h2 : x = three → y = four) : y = four := by
  apply h2 at h1
  exact h1

theorem implication_four (x : MyNat) (h : add x one = four) : x = three := by
  rw [one_eq_succ_zero] at h
  rw [four_eq_succ_three] at h
  rw [add_succ] at h
  apply succ_inj at h
  rw [add_zero] at h
  exact h

theorem implication_five (x : MyNat) : x = four → x = four := by
  intro h
  exact h

theorem implication_six (x y : MyNat) : add x one = add y one → x = y := by
  intro h
  rw[one_eq_succ_zero] at h
  rw[add_succ,add_succ] at h
  apply succ_inj at h
  rw[add_zero,add_zero] at h
  exact h

theorem implication_seven (x y : MyNat) (h1 : x = y) (h2 : x ≠ y) : False := by
  apply h2 at h1
  exact h1

theorem zero_ne_one : (zero : MyNat) ≠ one := by
  intro h
  rw [one_eq_succ_zero] at h
  apply zero_ne_succ at h
  exact h

theorem one_ne_zero : (one : MyNat) ≠ zero := by
  symm
  exact zero_ne_one

theorem two_plus_two_ne_five : add (succ (succ zero)) (succ (succ zero)) ≠ succ (succ (succ (succ (succ zero)))) := by
  intro h
  rw [add_succ, add_succ, add_zero] at h
  repeat apply succ_inj at h
  apply zero_ne_succ at h
  exact h
