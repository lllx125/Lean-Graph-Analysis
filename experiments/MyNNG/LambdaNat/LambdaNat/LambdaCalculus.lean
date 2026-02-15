-- Defining the syntax of untyped lambda calculus using de Bruijn indices in Lean
inductive Lambda : Nat → Type
  | var {n : Nat} (x : Fin n) : Lambda n
  | app {n : Nat} (s t : Lambda n) : Lambda n
  | abs {n : Nat} (s : Lambda (n + 1)) : Lambda n

/--
Helper to substitute a variable.
Returns `none` if we matched the substitution target `x`.
Returns `some z` where `z` is the shifted variable if they didn't match.
-/
def substVar {n : Nat} (y x : Fin (n + 1)) : Option (Fin n) :=
  if h : y.val = x.val then
    none
  else if h2 : y.val < x.val then
    -- y is strictly less than x, so its index doesn't shift
    some ⟨y.val, by omega⟩
  else
    -- y is strictly greater than x, so we shift its index down by 1
    some ⟨y.val - 1, by omega⟩

/--
Shifts (weakens) a term by incrementing all variables strictly greater than or
equal to `bv` (the bound variable insertion point).
-/
def lift {n : Nat} (term : Lambda n) (bv : Fin (n + 1)) : Lambda (n + 1) :=
  match term with
  | .var x =>
    if x.val < bv.val then
      .var (Fin.castSucc x)
    else
      .var (Fin.succ x)
  | .app s t =>
    .app (lift s bv) (lift t bv)
  | .abs s =>
    .abs (lift s (Fin.succ bv))

/--
Weakens a term by lifting it `k` times.
This effectively inserts `k` new unused variables at the local context bound.
-/
def weaken (k : Nat) {n : Nat} (term : Lambda n) : Lambda (n + k) :=
  match k with
  | 0 => term
  | k' + 1 =>
    -- We iteratively lift the already weakened term.
    -- (0 : Fin (n + k' + 1)) automatically proves 0 is a valid index.
    lift (weaken k' term) (0 : Fin (n + k' + 1))

/--
Substitutes term `t` into `s` replacing variable `x`.
-/
def subst {n : Nat} (s : Lambda (n + 1)) (t : Lambda n) (x : Fin (n + 1)) : Lambda n :=
  match s with
  | .var y =>
    match substVar y x with
    | none => t
    | some z => .var z
  | .app s₁ s₂ =>
    .app (subst s₁ t x) (subst s₂ t x)
  | .abs s₁ =>
    -- `t` must be lifted to context `n + 1`. Insert at index 0.
    .abs (subst s₁ (lift t (0 : Fin (n + 1))) (Fin.succ x))

/--
Beta equivalence is the reflexive, symmetric, transitive, and compatible
closure of single-step root beta reduction.
-/
inductive BetaEq: {n : Nat} → Lambda n → Lambda n → Prop
  -- 1. Base β-reduction step
  -- (ƛ s) ∙ t ＝β s [ t / 0 ]
  | beta (s : Lambda (n + 1)) (t : Lambda n) :
      BetaEq (.app (.abs s) t) (subst s t (0 : Fin (n + 1)))

  -- 2. Compatibility rules
  -- left: s ＝β t → s ∙ u ＝β t ∙ u
  | appLeft {s t u : Lambda n} (h : BetaEq s t) :
      BetaEq (.app s u) (.app t u)

  -- right: s ＝β t → u ∙ s ＝β u ∙ t
  | appRight {s t u : Lambda n} (h : BetaEq s t) :
      BetaEq (.app u s) (.app u t)

  -- abs: s ＝β t → ƛ s ＝β ƛ t
  | abs {s t : Lambda (n + 1)} (h : BetaEq s t) :
      BetaEq (.abs s) (.abs t)

  -- 3. Equivalence relation rules
  -- refl: s ＝β s
  | refl (s : Lambda n) :
      BetaEq s s

  -- sym: s ＝β t → t ＝β s
  | sym {s t : Lambda n} (h : BetaEq s t) :
      BetaEq t s

  -- trans: s ＝β t → t ＝β u → s ＝β u
  | trans {s t u : Lambda n} (h₁ : BetaEq s t) (h₂ : BetaEq t u) :
      BetaEq s u

-- Custom notations
notation:max "ν " x:max => Lambda.var x
infixl:70 " ∙ " => Lambda.app
prefix:65 "λ" => Lambda.abs
notation:60 s " [ " t " / " x " ]" => subst s t x
infix:50 " ≡β " => BetaEq
