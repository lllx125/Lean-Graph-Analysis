-- definition
inductive MyNat where
| zero : MyNat
| succ : MyNat → MyNat

namespace MyNat

instance : Inhabited MyNat where
  default := MyNat.zero

-- addition
opaque add : MyNat → MyNat → MyNat

axiom add_zero (a : MyNat) : add a zero = a

axiom add_succ (a d : MyNat) : add a (succ d) = succ (add a d)

-- Peano axioms
def pred : MyNat → MyNat
| zero => zero
| succ n => n

theorem pred_succ (n : MyNat) : pred (succ n) = n := rfl

theorem succ_inj (a b : MyNat) (h : succ a = succ b) : a = b :=
  congrArg pred h

def is_zero : MyNat → Prop
| zero => True
| succ _ => False

theorem is_zero_zero : is_zero zero = True := rfl
theorem is_zero_succ (n : MyNat) : is_zero (succ n) = False := rfl

theorem zero_ne_succ (a : MyNat) : zero ≠ succ a :=
  fun h => Eq.subst h (motive := is_zero) True.intro

-- multiplication
opaque mul : MyNat → MyNat → MyNat

axiom mul_zero (a : MyNat) : mul a zero = zero

axiom mul_succ (a b : MyNat) : mul a (succ b) = add (mul a b) a

-- some numerals
def one : MyNat := MyNat.succ zero
def two : MyNat := MyNat.succ one
def three : MyNat := MyNat.succ two
def four : MyNat := MyNat.succ three

theorem one_eq_succ_zero : one = succ zero := rfl
theorem two_eq_succ_one : two = succ one := rfl
theorem three_eq_succ_two : three = succ two := rfl
theorem four_eq_succ_three : four = succ three := rfl

-- power
opaque pow : MyNat → MyNat → MyNat

axiom pow_zero (m : MyNat) : pow m zero = one

axiom pow_succ (m n : MyNat) : pow m (succ n) = mul (pow m n) m


-- inequality
def le (a b : MyNat) :=  ∃ (c : MyNat), b = add a c

theorem le_iff_exists_add (a b : MyNat) : le a b ↔ ∃ (c : MyNat), b = add a c := Iff.rfl
def lt_myNat (a b : MyNat) :=  (le a b) ∧ ¬ (le b  a)

end MyNat
