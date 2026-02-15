import LambdaNat.NaturalNumber


#eval ⌈1⌉
#eval ⌈2⌉

theorem addBody_subst_one : subst (λ λ λ ν 3 ∙ ν 1 ∙ (ν 2 ∙ ν 1 ∙ ν 0)) ⌈ 1 ⌉ 0 ≡β λ λ λ (weaken 3 ⌈1⌉) ∙ ν 1 ∙ (ν 2 ∙ ν 1 ∙ ν 0) := by
  -- 1. Use `simp` to force Lean to evaluate the functions via their equation lemmas
  have h : subst (λ λ λ ν 3 ∙ ν 1 ∙ (ν 2 ∙ ν 1 ∙ ν 0)) ⌈ 1 ⌉ 0 = λ λ λ (weaken 3 ⌈1⌉) ∙ ν 1 ∙ (ν 2 ∙ ν 1 ∙ ν 0) := by
    simp [subst, substVar, weaken]

  -- 2. Rewrite the goal so both sides match exactly
  rw [h]

  -- 3. Now the unifier can trivially see they are identical
  exact BetaEq.refl _


/-- 1+1 =2 -/
theorem one_plus_one_eq_two : add ∙ ⌈1⌉ ∙ ⌈1⌉ ≡β ⌈2⌉ := by
  -- λmfx.nf(mfx)
  let addBody : Lambda 1 := λ λ λ ν 3 ∙ ν 1 ∙ (ν 2 ∙ ν 1 ∙ ν 0)
  -- λmfx.⌈1⌉f(mfx)
  let add1Body : Lambda 0 := λ λ λ (weaken 3 ⌈1⌉) ∙ ν 1 ∙ (ν 2 ∙ ν 1 ∙ ν 0)

  -- Step 1: Beta reduce the first application (add ∙ ⌈1⌉)
  have step1 : add ∙ ⌈1⌉ ≡β add1Body := by
    rw [BetaEq.beta addBody ⌈1⌉]

  -- Step 2: Apply congruence to multiply by the second ⌈1⌉
  have step2 : add ∙ ⌈1⌉ ∙ ⌈1⌉ ≡β (λ add1Body) ∙ ⌈1⌉ :=
    BetaEq.appLeft step1
Type mismatch
  BetaEq.refl ?m.55
has type
  ?m.55 ≡β ?m.55
but is expected to have type
  λλλν 3 ∙ ν 1 ∙ (ν 2 ∙ ν 1 ∙ ν 0) [ ⌈ 1 ⌉ / 0 ] ≡β λλλweaken 3 ⌈ 1 ⌉ ∙ ν 1 ∙ (ν 2 ∙ ν 1 ∙ ν 0)
