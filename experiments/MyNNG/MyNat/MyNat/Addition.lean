import MyNat.Header

open MyNat

namespace MyNat

theorem zero_add (n : MyNat) : add zero n = n :=
  match n with
  | zero => add_zero zero
  | succ d =>
    let ih := zero_add d
    Eq.trans (add_succ zero d) (congrArg succ ih)

theorem succ_add (a b : MyNat) : add (succ a) b = succ (add a b) :=
  match b with
  | zero =>
    Eq.trans
      (add_zero (succ a))
      (Eq.symm (congrArg succ (add_zero a)))
  | succ d =>
    let ih := succ_add a d
    Eq.trans
      (add_succ (succ a) d)
      (Eq.trans
        (congrArg succ ih)
        (Eq.symm (congrArg succ (add_succ a d))))

theorem add_comm (a b : MyNat) : add a b = add b a :=
  match b with
  | zero =>
    Eq.trans (add_zero a) (Eq.symm (zero_add a))
  | succ d =>
    let ih := add_comm a d
    Eq.trans (add_succ a d)
      (Eq.trans (congrArg succ ih) (Eq.symm (succ_add d a)))

theorem add_assoc (a b c : MyNat) : add (add a b) c = add a (add b c) :=
  match c with
  | zero =>
    Eq.trans
      (add_zero (add a b))
      (Eq.symm (congrArg (add a) (add_zero b)))
  | succ d =>
    let ih := add_assoc a b d
    Eq.trans
      (add_succ (add a b) d)
      (Eq.trans
        (congrArg succ ih)
        (Eq.trans
          (Eq.symm (add_succ a (add b d)))
          (Eq.symm (congrArg (add a) (add_succ b d)))))

theorem add_right_comm (a b c : MyNat) : add (add a b) c = add (add a c) b :=
  Eq.trans (add_assoc a b c)
    (Eq.trans (congrArg (add a) (add_comm b c)) (Eq.symm (add_assoc a c b)))

theorem add_left_comm (a b c : MyNat) : add a (add b c) = add b (add a c) :=
  Eq.trans (Eq.symm (add_assoc a b c))
    (Eq.trans (congrArg (fun x => add x c) (add_comm a b)) (add_assoc b a c))

theorem succ_eq_add_one (n : MyNat) : succ n = add n one :=
  Eq.symm (Eq.trans (add_succ n zero) (congrArg succ (add_zero n)))

end MyNat
