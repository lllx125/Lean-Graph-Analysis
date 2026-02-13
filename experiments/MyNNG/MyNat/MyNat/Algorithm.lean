import MyNat.Addition

open MyNat

namespace MyNat

theorem add_algo_1 (a b c d : MyNat) : add (add a b) (add c d) = add (add (add a c) d) b :=
  Eq.trans
    (Eq.symm (add_assoc (add a b) c d))
    (Eq.trans
      (congrArg (fun x => add x d) (add_right_comm a b c))
      (add_right_comm (add a c) b d))

theorem succ_ne_zero (a : MyNat) : succ a ≠ zero :=
  fun h => zero_ne_succ a (Eq.symm h)

theorem succ_ne_succ (m n : MyNat) (h : m ≠ n) : succ m ≠ succ n :=
  fun h_eq => h (succ_inj m n h_eq)

end MyNat
