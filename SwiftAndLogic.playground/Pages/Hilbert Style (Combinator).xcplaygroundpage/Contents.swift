/// `S = (A → (B → C)) → ((A → B) → (A → C))`
func s<A, B, C>(_ a: @escaping (C) -> (A) -> B)
    -> (_ b: @escaping (C) -> A)
    -> (C) -> B
{
    { b in { c in a(c)(b(c)) } }
}

/// `K = A → (B → A)`
func k<A, B>(_ a: A) -> (B) -> A {
    { _ in a }
}

/// `I = SKK: A → A`
func i<A>(_ a: A) -> A {
    let k_: (A) -> (A) -> A = k
    let skk: (A) -> A = s(k)(k_)
    return skk(a)
}

i("hello")  // "hello"
i(123)      // 123



print("✅")
