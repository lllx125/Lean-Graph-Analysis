import LambdaNat.LambdaCalculus

-- 1. Church Booleans

/-- True boolean value -/
def T : Lambda 0 := λλ ν 0

/-- False boolean value -/
def F : Lambda 0 := λλ ν 1

-- 2. Church Numerals

/-- Church numeral body by induction -/
def churchBody : Nat → Lambda 2
  | 0 => ν 0
  | n + 1 => ν 1 ∙ (churchBody n)

/-- Church numeral n -/
def church (n : Nat) : Lambda 0 := λλ (churchBody n)

notation:max "⌈ " n " ⌉" => church n

/-- Church numeral 0 -/
def zero : Lambda 0 := ⌈ 0 ⌉

/-- Church numeral 1 -/
def one : Lambda 0 := ⌈ 1 ⌉

-- 3. Functions on Church Numerals

/-- Successor function  λnfx.f(nfx)-/
def succ : Lambda 0 := λλλ ν 1 ∙ (ν 2 ∙ ν 1 ∙ ν 0)

/-- Addition function λnmfx.nf(mfx)-/
def add : Lambda 0 := λλλλ ν 3 ∙ ν 1∙ (ν 2 ∙ ν 1 ∙ ν 0)

/-- Multiplication function  λnmf.n(mf)-/
def mul : Lambda 0 := λλλ ν 2 ∙ (ν 1 ∙ ν 0)

/-- Power function λnm.mn-/
def pow : Lambda 0 := λλ ν 1 ∙ ν 0

/-- Zero test λn.n(λx.F)T -/
def isZero : Lambda 0 := λ ν 0 ∙ (λ weaken 2 F) ∙ (weaken 1 T)

/-- Predecessor function λnfx.n(λpz.z(p F)(f(p F))) (λz.zxx) T -/
def pred : Lambda 0 := λλλ ν 2 ∙ (λλ ν 0 ∙ (ν 1 ∙ weaken 5 F) ∙ (ν 3 ∙ (ν 1 ∙ weaken 5 F))) ∙ (λ ν 0 ∙ ν 1 ∙ ν 1) ∙ weaken 3 T

/-- Y combinator λf.(λx.f(xx))(λx.f(xx))-/
def Y : Lambda 0 := λ (λ ν 1 ∙ (ν 0 ∙ ν 0)) ∙ (λ ν 1 ∙ (ν 0 ∙ ν 0))
