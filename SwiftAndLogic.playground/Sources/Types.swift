/// A ∨ B
public enum Either<A, B> {
    case left(A)
    case right(B)
}

/// ¬A ≣ A → ⊥
/// (¬A ===> A → ⊥ , and A → ⊥ ===> ¬A)
public struct Not<A> {
    public let f: (A) -> Never

    public init(_ f: @escaping (A) -> Never) {
        self.f = f
    }
}
// or, `typealias Not<A> = (A) -> Never` will also work.
