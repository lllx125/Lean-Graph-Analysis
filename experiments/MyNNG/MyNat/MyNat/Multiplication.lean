import MyNat.Addition

open MyNat

namespace MyNat

theorem mul_one (m : MyNat) : mul m one = m :=
  Eq.trans
    (congrArg (mul m) one_eq_succ_zero)
    (Eq.trans
      (mul_succ m zero)
      (Eq.trans
        (congrArg (fun x => add x m) (mul_zero m))
        (zero_add m)))

theorem zero_mul (m : MyNat) : mul zero m = zero :=
  match m with
  | zero => mul_zero zero
  | succ d =>
    let ih := zero_mul d
    Eq.trans
      (mul_succ zero d)
      (Eq.trans (congrArg (fun x => add x zero) ih) (add_zero zero))

theorem succ_mul (a b : MyNat) : mul (succ a) b = add (mul a b) b :=
  match b with
  | zero =>
    Eq.trans
      (mul_zero (succ a))
      (Eq.symm (Eq.trans (congrArg (fun x => add x zero) (mul_zero a)) (add_zero zero)))
  | succ d =>
    let ih := succ_mul a d
    -- LHS: mul (succ a) (succ d) = ... = succ (add (add (mul a d) d) a)
    let lhs_step :=
      Eq.trans (mul_succ (succ a) d)
      (Eq.trans
        (congrArg (fun x => add x (succ a)) ih)
        (add_succ (add (mul a d) d) a))

    -- RHS: add (mul a (succ d)) (succ d) = ... = succ (add (add (mul a d) a) d)
    let rhs_step :=
      Eq.trans
        (congrArg (fun x => add x (succ d)) (mul_succ a d))
        (add_succ (add (mul a d) a) d)

    -- Glue: add_right_comm (mul a d) d a
    let glue := add_right_comm (mul a d) d a

    Eq.trans lhs_step (Eq.trans (congrArg succ glue) (Eq.symm rhs_step))

theorem mul_comm (a b : MyNat) : mul a b = mul b a :=
  match b with
  | zero =>
    Eq.trans (mul_zero a) (Eq.symm (zero_mul a))
  | succ d =>
    let ih := mul_comm a d
    Eq.trans
      (mul_succ a d)
      (Eq.trans
        (congrArg (fun x => add x a) ih)
        (Eq.symm (succ_mul d a)))

theorem one_mul (m : MyNat) : mul one m = m :=
  Eq.trans (mul_comm one m) (mul_one m)

theorem two_mul (m : MyNat) : mul two m = add m m :=
  Eq.trans
    (congrArg (fun x => mul x m) two_eq_succ_one)
    (Eq.trans (succ_mul one m) (congrArg (fun x => add x m) (one_mul m)))

theorem mul_add (a b c : MyNat) : mul a (add b c) = add (mul a b) (mul a c) :=
  match c with
  | zero =>
    Eq.trans
      (congrArg (mul a) (add_zero b))
      (Eq.symm (Eq.trans (congrArg (add (mul a b)) (mul_zero a)) (add_zero (mul a b))))
  | succ d =>
    let ih := mul_add a b d
    -- LHS: mul a (add b (succ d)) = mul a (succ (add b d)) = add (mul a (add b d)) a
    let lhs := Eq.trans (congrArg (mul a) (add_succ b d)) (mul_succ a (add b d))
    -- RHS: add (mul a b) (mul a (succ d)) = add (mul a b) (add (mul a d) a)
    let rhs := congrArg (add (mul a b)) (mul_succ a d)

    Eq.trans lhs
      (Eq.trans
        (congrArg (fun x => add x a) ih)
        (Eq.trans (add_assoc (mul a b) (mul a d) a) (Eq.symm rhs)))

theorem add_mul (a b c : MyNat) : mul (add a b) c = add (mul a c) (mul b c) :=
  Eq.trans
    (mul_comm (add a b) c)
    (Eq.trans
      (mul_add c a b)
      (congrArg (add (mul c a)) (mul_comm c b)
        |> fun h => Eq.trans h (congrArg (fun x => add x (mul b c)) (mul_comm c a))))

theorem mul_assoc (a b c : MyNat) : mul (mul a b) c = mul a (mul b c) :=
  match c with
  | zero =>
    Eq.trans
      (mul_zero (mul a b))
      (Eq.symm (Eq.trans (congrArg (mul a) (mul_zero b)) (mul_zero a)))
  | succ d =>
    let ih := mul_assoc a b d
    -- LHS: mul (mul a b) (succ d) = add (mul (mul a b) d) (mul a b)
    let lhs := mul_succ (mul a b) d
    -- RHS: mul a (mul b (succ d)) = mul a (add (mul b d) b) = add (mul a (mul b d)) (mul a b)
    let rhs := Eq.trans (congrArg (mul a) (mul_succ b d)) (mul_add a (mul b d) b)

    Eq.trans lhs (Eq.trans (congrArg (fun x => add x (mul a b)) ih) (Eq.symm rhs))

end MyNat
