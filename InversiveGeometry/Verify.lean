/-
Copyright (c) 2026 Carlo Perassi. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Carlo Perassi
-/
import InversiveGeometry.Reflection

/-!
# Axiom verification

Permanent axiom checks. `lake build` prints these; the expected output is that every theorem
depends only on `propext`, `Classical.choice`, and `Quot.sound`.
-/

#print axioms InversiveGeometry.reflect_eq_self_iff
#print axioms InversiveGeometry.reflect_reflect
#print axioms InversiveGeometry.fixedSet_eq_zeroLocus
