import MyNat.Multiplication

open MyNat

namespace MyNat

theorem zero_pow_zero : pow (zero : MyNat)  zero = one :=
  pow_zero zero

theorem zero_pow_succ (m : MyNat) : pow (zero : MyNat) (succ m) = zero :=
  Eq.trans (pow_succ zero m) (mul_zero (pow zero m))

theorem pow_one (a : MyNat) : pow a one = a :=
  Eq.trans
    (congrArg (pow a) one_eq_succ_zero)
    (Eq.trans (pow_succ a zero)
      (Eq.trans (congrArg (fun x => mul x a) (pow_zero a)) (one_mul a)))

theorem one_pow (m : MyNat) : pow (one : MyNat) m = one :=
  match m with
  | zero => pow_zero one
  | succ t =>
    let ih := one_pow t
    Eq.trans (pow_succ one t)
      (Eq.trans (congrArg (fun x => mul x one) ih) (mul_one one))

theorem pow_two (a : MyNat) : pow a two = mul a a :=
  Eq.trans
    (congrArg (pow a) two_eq_succ_one)
    (Eq.trans (pow_succ a one) (congrArg (fun x => mul x a) (pow_one a)))

theorem pow_add (a m n : MyNat) : pow a (add m n) = mul (pow a m) (pow a n) :=
  match n with
  | zero =>
    Eq.trans
      (congrArg (pow a) (add_zero m))
      (Eq.symm (Eq.trans (congrArg (mul (pow a m)) (pow_zero a)) (mul_one (pow a m))))
  | succ t =>
    let ih := pow_add a m t
    -- LHS: pow a (m + succ t) = pow a (succ (m + t)) = mul (pow a (m+t)) a
    let lhs := Eq.trans (congrArg (pow a) (add_succ m t)) (pow_succ a (add m t))
    -- RHS: mul (pow a m) (pow a (succ t)) = mul (pow a m) (mul (pow a t) a)
    let rhs := congrArg (mul (pow a m)) (pow_succ a t)

    Eq.trans lhs
      (Eq.trans
        (congrArg (fun x => mul x a) ih)
        (Eq.trans (mul_assoc (pow a m) (pow a t) a) (Eq.symm rhs)))

theorem mul_pow (a b n : MyNat) : pow (mul a b) n = mul (pow a n) (pow b n) :=
  match n with
  | zero =>
    Eq.trans
      (pow_zero (mul a b))
      (Eq.symm (Eq.trans (congrArg (mul (pow a zero)) (pow_zero b)) (Eq.trans (congrArg (fun x => mul x one) (pow_zero a)) (one_mul one))))
  | succ t =>
    let ih := mul_pow a b t
    -- LHS: pow (ab) (succ t) = mul (pow (ab) t) (ab)
    let lhs := Eq.trans (pow_succ (mul a b) t) (congrArg (fun x => mul x (mul a b)) ih)
    -- Current state of LHS: (An * Bn) * (A * B)

    -- Target RHS: (An * A) * (Bn * B)
    let rhs := Eq.trans (congrArg (fun x => mul x (pow b (succ t))) (pow_succ a t)) (congrArg (mul (mul (pow a t) a)) (pow_succ b t))

    -- We need to shuffle (An * Bn) * (A * B) to (An * A) * (Bn * B)
    let shuffle :=
      Eq.trans (mul_assoc (pow a t) (pow b t) (mul a b))
      (Eq.trans
        (congrArg (mul (pow a t))
          (Eq.trans (Eq.symm (mul_assoc (pow b t) a b))
            (Eq.trans (congrArg (fun x => mul x b) (mul_comm (pow b t) a))
              (mul_assoc a (pow b t) b))))
        (Eq.symm (mul_assoc (pow a t) a (mul (pow b t) b))))

    Eq.trans lhs (Eq.trans shuffle (Eq.symm rhs))

theorem pow_pow (a m n : MyNat) : pow (pow a m) n = pow a (mul m n) :=
  match n with
  | zero =>
    Eq.trans
      (pow_zero (pow a m))
      (Eq.symm (Eq.trans (congrArg (pow a) (mul_zero m)) (pow_zero a)))
  | succ t =>
    let ih := pow_pow a m t
    -- LHS: pow (pow a m) (succ t) = mul (pow (pow a m) t) (pow a m)
    let lhs := Eq.trans (pow_succ (pow a m) t) (congrArg (fun x => mul x (pow a m)) ih)
    -- LHS is now: mul (pow a (m*t)) (pow a m)

    -- RHS: pow a (m * succ t) = pow a (m*t + m)
    let rhs := Eq.trans (congrArg (pow a) (mul_succ m t)) (pow_add a (mul m t) m)

    Eq.trans lhs (Eq.symm rhs)

theorem add_sq (a b : MyNat) : pow (add a b) two = add (add (pow a two) (pow b two)) (mul (mul two a) b) :=
  -- 1. Expand (a+b)^2 to (a+b)(a+b)
  let s1 := pow_two (add a b)

  -- 2. Distribute: (a+b)(a+b) = (a+b)a + (a+b)b
  -- Uses mul_add x y z : x(y+z) = xy + xz
  let s2 := Eq.trans s1 (mul_add (add a b) a b)

  -- 3. Expand inner terms: (a+b)a = aa + ba  and  (a+b)b = ab + bb
  -- Uses add_mul x y z : (x+y)z = xz + yz
  let term1_exp := add_mul a b a
  let term2_exp := add_mul a b b

  -- Substitute term1: (aa + ba) + (a+b)b
  let s3 := Eq.trans s2 (congrArg (fun x => add x (mul (add a b) b)) term1_exp)
  -- Substitute term2: (aa + ba) + (ab + bb)
  let s4 := Eq.trans s3 (congrArg (add (add (mul a a) (mul b a))) term2_exp)

  -- 4. Commute ba to ab: (aa + ab) + (ab + bb)
  let s5 := Eq.trans s4
    (congrArg (fun x => add (add (mul a a) x) (add (mul a b) (mul b b))) (mul_comm b a))

  -- 5. Associativity shuffle to get (aa + bb) + (ab + ab)
  -- (aa + ab) + (ab + bb) -> aa + (ab + (ab + bb))
  let s6 := Eq.trans s5 (add_assoc (mul a a) (mul a b) (add (mul a b) (mul b b)))

  -- aa + (ab + (ab + bb)) -> aa + ((ab + ab) + bb)
  let s7 := Eq.trans s6
    (congrArg (add (mul a a)) (Eq.symm (add_assoc (mul a b) (mul a b) (mul b b))))

  -- aa + ((ab + ab) + bb) -> aa + (bb + (ab + ab))
  let s8 := Eq.trans s7
    (congrArg (add (mul a a)) (add_comm (add (mul a b) (mul a b)) (mul b b)))

  -- aa + (bb + (ab + ab)) -> (aa + bb) + (ab + ab)
  let s9 := Eq.trans s8
    (Eq.symm (add_assoc (mul a a) (mul b b) (add (mul a b) (mul a b))))

  -- 6. Prepare the "2ab" term: (2a)b = (a+a)b = ab + ab
  let h_2ab : mul (mul two a) b = add (mul a b) (mul a b) :=
    Eq.trans
      (congrArg (fun x => mul x b) (two_mul a)) -- mul (add a a) b
      (add_mul a a b)                        -- add (mul a b) (mul a b)

  -- 7. Prepare squares: aa = a^2, bb = b^2
  let h_a2 : mul a a = pow a two := Eq.symm (pow_two a)
  let h_b2 : mul b b = pow b two := Eq.symm (pow_two b)

  -- 8. Final substitution
  -- Replace (ab + ab) with (2a)b
  let s10 := Eq.trans s9
    (congrArg (add (add (mul a a) (mul b b))) (Eq.symm h_2ab))

  -- Replace aa with a^2 and bb with b^2
  Eq.trans s10
    (congrArg (fun x => add x (mul (mul two a) b))
      (Eq.trans
        (congrArg (fun x => add x (mul b b)) h_a2)
        (congrArg (add (pow a two)) h_b2)))

end MyNat
