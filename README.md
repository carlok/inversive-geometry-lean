# inversive-geometry-lean

Generalized circles ("circlines") in Lean 4 - circles and lines as a single object, cut out by
a Hermitian equation

```
A|z|² + Bz + B̄z̄ + C = 0,    A, C real,  B complex.
```

Mathlib has no such object. This repository is an attempt to build one, starting small and
asking before scaling up.

## The object

Everything below follows from that one equation. It is short enough to check while reading.

**Why `A` and `C` are real and `B` is not.** Conjugating `H` swaps `z` with `z̄` and `B` with `B̄`,
so with `A` and `C` real it returns `H` unchanged:

```
conj(H(z)) = A·z̄·z + B̄·z̄ + B·z + C = H(z)
```

A complex number equal to its own conjugate is real, so `H(z) = 0` is **one real equation** - which
is what a curve in the plane should cost. That is the whole reason for the asymmetry in the types.

**Why `A = 0` versus `A ≠ 0` is exactly circle versus line.** For `A ≠ 0`, divide by `A` and
complete the square:

```
|z|² + (B/A)·z + (B̄/A)·z̄ + C/A = 0
|z + B̄/A|² = (|B|² − A·C) / A²
```

a circle with centre `−B̄/A` and radius `√(|B|² − A·C) / |A|`, real when `|B|² − A·C > 0`.

For `A = 0` the quadratic term is gone, and since `B̄·z̄ = conj(B·z)`:

```
B·z + B̄·z̄ + C = 2·Re(B·z) + C = 0
```

a straight line, provided `B ≠ 0`. One equation, one family, and the case split on `A` is the
line-versus-circle split. Mathlib currently writes that split out by hand in at least two places -
see below.

**Where the reflection comes from.** Take `H(z) = 0`, group by which terms carry `z`, and solve for
it, treating `z̄` as independent:

```
z·(A·z̄ + B) + (B̄·z̄ + C) = 0
z = (−B̄·z̄ − C) / (A·z̄ + B)
```

Read the right-hand side as a map and you have `reflect`. Its fixed points are the solutions of
`H = 0` by construction, which is the first theorem. It is a Möbius transformation precomposed
with conjugation, so it is *anti*-holomorphic - orientation-reversing, as a reflection should be.

Sanity check on the unit circle: `A = 1`, `B = 0`, `C = −1` gives `H(z) = |z|² − 1`, and

```
reflect(z) = 1 / z̄
```

inversion in the unit circle.

**The pole is the centre.** The denominator `A·z̄ + B` vanishes at `z = −B̄/A`, which is the centre
computed above. Not an edge case to patch: inversion sends the centre to infinity and genuinely has
no value there. Both theorems therefore carry an explicit non-vanishing hypothesis, since Lean's
`x / 0 = 0` would otherwise make them true for the wrong reason.

## Status

Early. What exists:

- `reflection across a generalized circle` - the anti-Möbius involution whose fixed-point set is
  the circle, with the fixed-point characterization and involutivity, `sorry`-free.

What does not exist yet: the circline object itself as a bundled structure (the representation
question is open - see below), and everything downstream of it.

## The representation question

This is the open design question and the reason for the Zulip thread. Candidates:

| | representation | note |
|---|---|---|
| (a) | structure bundling `(A : ℝ) (B : ℂ) (C : ℝ)` + non-degeneracy | what the current code effectively uses; direct, but carries the scaling redundancy |
| (b) | Hermitian 2×2 matrix up to real scaling | generalizes better; more painful at point of use |
| (c) | explicit quotient by scaling | canonical, heavier |
| (d) | subset of the sphere with a predicate | matches "a circline *is* a set", weakest algebra |

No decision made. Input wanted before building on any of them.

## Why this object and not another

Generalized circles are the hub of classical inversive geometry, not a leaf. What rests on the
object, in rough dependency order:

- reflections and inversions (the part that exists here);
- Möbius maps send generalized circles to generalized circles;
- classification of Möbius transformations by their fixed circlines;
- orthogonality and pencils;
- the boundary structure of the standard hyperbolic models.

None of that is currently reachable in Mathlib, because the object it all rests on is missing.

The question that actually matters is *which existing Mathlib files would import this*. Two
plausible consumers exist today, both currently written as case splits on exactly the
circle-versus-line dichotomy:

- `Analysis/Complex/UpperHalfPlane/FixedPoints.lean` states the fixed-point set of an
  orientation-reversing isometry of `ℍ` as two theorems, `gl_smul_eq_self_iff_re_eq` and
  `gl_smul_eq_self_iff_dist_eq`, branching on whether the set is a vertical line or a Euclidean
  semicircle centred on `ℝ`.
- `Geometry/Euclidean/Inversion/ImageHyperplane.lean` spreads "inversion swaps spheres through the
  centre with hyperplanes" over three lemmas, each carrying its own non-degeneracy side condition.

That is evidence the dichotomy is real and already costs something. It is not evidence anyone has
asked for the object: no Zulip thread and no PR ever has. Whether the object is wanted is the
open question, and it is being asked before anything is proposed for inclusion.

## Prior art

Yan & Shum, *Formalizing Extended Complex Numbers, Möbius Transformations, and Cross Ratio in
Lean 4*, [arXiv:2606.20358](https://arxiv.org/abs/2606.20358), June 2026. About 6000 lines of
Lean 4 covering Möbius transformations and cross-ratio over ℂ, using `Option ℂ` for the extended
plane. Standalone repository, Apache-2.0, no stated intention to upstream. They list generalized
circles explicitly as future work not undertaken.

Related Mathlib material that exists: `Projectivization` and its 2-pretransitivity results,
`OnePoint K` with `equivProjectivization` and a GL(2,K) action, and the `UpperHalfPlane` Möbius
action. None of it defines a circline.

## Contributing

Contributions welcome, and the intended first slice for anyone who wants one is *Möbius maps send
generalized circles to generalized circles* - self-contained, and a few evenings of work once the
representation is settled.

I am not a professional mathematician and I am new to Mathlib conventions. I can write proofs; I
do not yet reliably know what is idiomatic. Corrections on that front are the most useful thing
anyone can offer.

## Build

```bash
lake exe cache get   # downloads ~8700 prebuilt Mathlib olean files
lake build
```

Requires `elan`. Pinned to Lean `v4.33.0` and the matching Mathlib tag; the toolchain is in
`lean-toolchain` and the Mathlib revision in `lake-manifest.json`, both committed, so `cache get`
should hit rather than compile Mathlib from source.

On CI the fetch takes under three minutes and the project itself builds in seconds; on a home
connection the fetch is the slow part and dominates everything else. If it *misses* the cache,
Mathlib compiles from source and that takes hours - which almost always means the toolchain and
the manifest have drifted apart.

## Style

Mathlib's own text-based style linter runs in CI and passes:

```bash
lake build lint-style
lake env .lake/packages/mathlib/.lake/build/bin/lint-style InversiveGeometry
```

The argument matters. `lint-style` lints the *imports* of the module it is given, filtered to the
same package, so it must be handed the root module. Passing a leaf module such as
`InversiveGeometry.Reflection` lints nothing and exits 0, which is indistinguishable from a pass.

## Maintenance

Pinned to a tagged Mathlib release, not to master. Intended bump cadence: **roughly every 6–8
weeks**, or sooner if someone has a PR blocked on it. Between bumps the repository is
deliberately stationary.

If it has been longer than that and CI is red, treat the repo as stale and open an issue rather
than assuming your branch is at fault - a stale pin is the likeliest cause, and a contributor's
branch cannot be evaluated against a Mathlib revision the manifest no longer matches.

## Note on AI assistance

Parts of this repository were produced with LLM assistance. Mathlib's contribution policy
requires that this be declared in the description of any pull request, together with which tools
were used and how, and that substantially LLM-generated code carry the `LLM-generated` label. It
also requires the human author to understand and be able to justify every design decision without
AI help. Nothing here will be proposed upstream until that standard is genuinely met, statement
by statement.

The same policy states that LLMs may not be used to write comments on GitHub or Zulip. Any
message posted from this project is written by a human.

## License

Apache-2.0, for Mathlib compatibility.
