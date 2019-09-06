// NOTE:
// - Please use Xcode 11 (Swift 5.1).
// - `X ===> Y` is an inference (transformation) rule from premise X to conclusion Y.
// - `X ⊢ Z` means `X ===> ... ===> Z` (derivable from using axioms and inference rules).

//--------------------------------------------------------------------------------

// MARK: → (imply)

/// `B ===> A → B`
/// - Note: More formally, A ⊢ B ===> ⊢ A → B (Deduction Theorem).
func implyIntro<A, B>(_ b: B) -> ((A) -> B) {
    { _ in b }
}

/// `A → B, A ===> B` (Modus ponens)
func implyElim<A, B>(_ a: A, _ f: (A) -> B) -> B {
    f(a)
}

// MARK: ∧ (conjunction, and)

/// `A, B ===> A ∧ B`
func andIntro<A, B>(_ a: A, _ b: B) -> (A, B) {
    (a, b)
}

/// `A ∧ B ===> A`
func andElim1<A, B>(_ ab: (A, B)) -> A {
    ab.0
}

/// `A ∧ B ===> B`
func andElim2<A, B>(_ ab: (A, B)) -> B {
    ab.1
}

// MARK: ∨ (disjunction, or)

/// `A ===> A ∨ B`
func orIntro1<A, B>(_ a: A) -> Either<A, B> {
    .left(a)
}

/// `B ===> A ∨ B`
func orIntro2<A, B>(_ b: B) -> Either<A, B> {
    .right(b)
}

/// `A ∨ B, A → C, B → C ===> C`
func orElim<A, B, C>(_ e: Either<A, B>, _ ac: (A) -> C, _ bc: (B) -> C) -> C {
    switch e {
    case let .left(a):
        return ac(a)
    case let .right(b):
        return bc(b)
    }
}

// MARK: ¬ (not)

/// `A ⊢ ⊥ ===> ⊢ ¬A`
func notIntro<A>(_ x: Never) -> Not<A> {
    Not { _ in x } // compiles in Swift 5.1
}

/// `A, ¬A ===> ⊥` (NOTE: not using `fatalError`)
func notElim<A>(_ a: A, _ notA: Not<A>) -> Never {
    notA.f(a)
}

// NOTE: Above → ∧ ∨ ¬ introduction / elimination rules are so called "Minimal Logic".

//--------------------------------------------------------------------------------

// MARK: ⊥ (bottom)

// NOTE: Adding `absurd` makes "minimal logic" into "Intuitionistic Logic (IL)".

/// `⊥ ===> A`
func absurd<A>(_ x: Never) -> A {
    // Do nothing, but it compiles in Swift 5.1
}

/// `A ===> ¬¬A`
func doubleNegationIntro<A>(_ a: A) -> Not<Not<A>> {
    Not { notA in
        notA.f(a)
    }
}

// MARK: Triple Negation ≣ Single Negation

/// `¬¬¬A ===> ¬A`
func tripleNegationToSingle<A>(_ notNotNotA: Not<Not<Not<A>>>) -> Not<A> {
    Not<A> { a in
        notNotNotA.f(Not<Not<A>> { notA in
            notA.f(a)
        })
    }
}

/// `¬A ===> ¬¬¬A`
func singleNegationToTriple<A>(_ notA: Not<A>) -> Not<Not<Not<A>>> {
    Not<Not<Not<A>>> { notNotA in
        notNotA.f(notA)
    }
}

// MARK: De-Morgan's Law (except `¬(A ∧ B) ===> ¬A ∨ ¬B`)

/// `¬(A ∨ B) ===> ¬A ∧ ¬B`
func deMorgan<A, B>(_ notEither: Not<Either<A, B>>) -> (Not<A>, Not<B>) {
    (Not { a in notEither.f(.left(a)) }, Not { b in notEither.f(.right(b)) })
}

/// `¬A ∧ ¬B ===> ¬(A ∨ B)`
func deMorgan2<A, B>(_ notAB: (Not<A>, Not<B>)) -> Not<Either<A, B>> {
    Not { either in
        switch either {
        case let .left(a):
            return notAB.0.f(a)
        case let .right(b):
            return notAB.1.f(b)
        }
    }
}

/// `¬A ∨ ¬B ===> ¬(A ∧ B)`
func deMorgan3<A, B>(_ either: Either<Not<A>, Not<B>>) -> Not<(A, B)> {
    Not { ab in
        switch either {
        case let .left(notA):
            return notA.f(ab.0)
        case let .right(notB):
            return notB.f(ab.1)
        }
    }
}

//--------------------------------------------------------------------------------

// MARK: Classical Logic (Forbidden functions in Intuitionistic Logic / Swift)

// NOTE: Adding `absurd` makes "minimal logic" into "intuitionistic logic".

/// `A ∨ ¬A` (Law of excluded middle)
func excludedMiddle<A>() -> Either<A, Not<A>> {
    fatalError("Can't impl in Intuitionistic Logic")
}

/// `¬¬A ===> A` (Double negation elimination)
/// `¬A ⊢ ⊥ ===> A` (Reductio ad absurdum)
func doubleNegationElim<A>(_ notNotA: Not<Not<A>>) -> A {
    fatalError("Can't impl in Intuitionistic Logic")

    // NOTE: Can still impl when using `excludedMiddle()`, though it is not still valid.
    let either: Either<A, Not<A>> = excludedMiddle()
    switch either {
    case let .left(a):
        return a
    case let .right(notA):
        return absurd(notNotA.f(notA))
    }
}

/// `¬(A ∧ B) ===> ¬A ∨ ¬B`
func deMorgan4<A, B>(_ notAB: Not<(A, B)>) -> Either<Not<A>, Not<B>> {
    fatalError("Can't impl in Intuitionistic Logic")

    // NOTE: This compiles, but using invalid `excludedMiddle()`.
    let either: Either<A, Not<A>> = excludedMiddle()
    switch either {
    case let .left(a):
        return .right(Not<B> { b in notAB.f((a, b)) })
    case let .right(notA):
        return .left(notA)
    }
}

/// `((A → B) → A) → A`
func peirceLaw<A, B>() -> (((A) -> B) -> A) -> A {
    { (aba: ((A) -> B) -> A) in
        let ab: (A) -> B = { fatalError("Can't impl in Intuitionistic Logic") }()
        let a = aba(ab)
        return a

        // NOTE: This compiles, but using invalid `excludedMiddle()`.
        let either: Either<A, Not<A>> = excludedMiddle()
        switch either {
        case let .left(a):
            return a
        case let .right(notA):
            return aba({ a in absurd(notA.f(a)) })
        }
    }
}

//--------------------------------------------------------------------------------

// MARK: Double-negation translation (Glivenko’s Theorem)

// NOTE:
// "_IL" stands for "Intuitionistic Logic", which can be translated from classical logic by
// adding [Double\-negation translation](https://ncatlab.org/nlab/show/double+negation+translation)

/// `¬¬(A ∨ ¬A)` (Law of excluded middle in Intuitionistic Logic)
/// https://github.com/vladciobanu/logic-in-haskell/blob/master/src/Logic.hs
func excludedMiddle_IL<A>() -> Not<Not<Either<A, Not<A>>>> {
    Not<Not<Either<A, Not<A>>>> { notEither in
        let notA: Not<A> = Not { a in notEither.f(.left(a)) }
        let either: Either<A, Not<A>> = .right(notA)
        return notEither.f(either)
    }
}

/// `¬¬¬¬A ===> ¬¬A` (Double negation elimination in Intuitionistic Logic)
func doubleNegationElim_IL<A>(_ notNotNotNotA: Not<Not<Not<Not<A>>>>) -> Not<Not<A>> {
    Not<Not<A>> { notA in
        notNotNotNotA.f(
            Not<Not<Not<A>>> { notNotA in
                notNotA.f(notA)
            }
        )
    }
}

/// `¬¬¬(A ∧ B) ===> ¬¬(¬A ∨ ¬B)`  (De-Morgan's Law in Intuitionistic Logic)
func deMorgan4_IL<A, B>(_ notNotNotAB: Not<Not<Not<(A, B)>>>) -> Not<Not<Either<Not<A>, Not<B>>>> {
    Not<Not<Either<Not<A>, Not<B>>>> { (notEither: Not<Either<Not<A>, Not<B>>>) in
        let notNotAB = Not<Not<(A, B)>> { notAB in
            let notB = Not<B> { b in
                let notA = Not<A> { a in
                    notAB.f((a, b))
                }
                let either: Either<Not<A>, Not<B>> = .left(notA)
                return notEither.f(either)
            }
            let either: Either<Not<A>, Not<B>> = .right(notB)
            return notEither.f(either)
        }
        return notNotNotAB.f(notNotAB)
    }
}

/// `¬¬((A → B) → A) → ¬¬A` (Peirce's Law in Intuitionistic Logic)
func peirceLaw_IL<A, B>() -> (Not<Not<((A) -> B) -> A>>) -> Not<Not<A>> {
    { notNotF in
        Not<Not<A>> { notA in
            let notABA = Not<((A) -> B) -> A> { aba in
                let ab: (A) -> B = { a in absurd(notElim(a, notA)) }
                let a = aba(ab)
                return notA.f(a)
            }
            return notNotF.f(notABA)
        }
    }
}

//--------------------------------------------------------------------------------

// MARK: - callCC (Call with Current Continuation)

/// Continuation.
typealias Cont<R, A> = (@escaping (A) -> R) -> R

func flatMap<A, B, R>(_ ma: @escaping Cont<R, A>, _ f: @escaping (A) -> Cont<R, B>) -> Cont<R, B> {
    { br in
        ma { a in f(a)(br) }
    }
}

/// Call with Current Continuation.
///
/// - Peirce (classical):       `((A → B) → A) → A`
/// - CallCC (intuitionistic): `((A → M<B>) → M<A>) → M<A>`
///
/// - Note: `callCC` is like control operators e.g. `goto`, `longjmp`, `return`, `throw`, `break`.
func callCC<A, B, R>(
    _ f: @escaping (_ exit: @escaping (A) -> Cont<R, B>) -> Cont<R, A>
) -> Cont<R, A>
{
    { outer in
        f { a in { _ in outer(a) } }(outer)
    }
}

/// - DoubleNegationElim (classical):      `((A → ⊥) → ⊥) ===> A`
/// - DoubleNegationElim (intuitionistic): `((A → M<⊥>) → M<⊥>) ===> M<A>`
func doubleNegationElim_callCC<R, A>(
    _ doubleNegation: @escaping (_ neg: @escaping (A) -> Cont<R, Never>) -> Cont<R, Never>
) -> Cont<R, A>
{
    return callCC { exit -> Cont<R, A> in
        flatMap(doubleNegation(exit), absurd)
    }
}

//--------------------------------------------------------------------------------

// MARK: - CPS (Continuation Passing Style)

/// `A → ((A → B) → B)`
/// Also, `⊢(CL) A ===> ⊢(IL) ((A → B) → B)` (CL = classical logic)
/// Also, `⊢(CL) A ===> ⊢(IL) ¬¬A` (where `B = ⊥`, Glivenko's theorem)
func toCPS<A, B>(_ a: A) -> (((A) -> B) -> B) {
    { ab in ab(a) }
}

/// `((A → B) → B) → A`
/// - Note: Not type-safe in Swift due to lack of Rank2 polymorphism.
func fromCPS<A>(_ f: @escaping ((A) -> Any) -> Any) -> A {
    f({ $0 } as (A) -> Any) as! A
}

/// `X → A <===> ∀B.((A → B) → (X → B))`
/// Also, `X → A ===> (A → ⊥) -> (X → ⊥)) = ¬A → ¬X` (contraposition)
func cpsTransform<A, B, X>(_ f: @escaping (X) -> A)
    -> ((@escaping (A) -> B) -> ((X) -> B))
{
    { g in { x in g(f(x)) } }
}



print("✅")
