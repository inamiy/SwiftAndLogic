// MARK: - (A_1 → B) ∧ (A_2 → B) ∧ ⋯ ≅ ∀X.(X → B)

let intToBool: (Int) -> Bool = { _ in true }
let floatToBool: (Float) -> Bool = { _ in true }
let strToBool: (String) -> Bool = { _ in true }
// ...

// Tons of same impl... Can we abstract this?
// ... Yes, use generic function!

func xToBool<X>(_ x: X) -> Bool { true }

// MARK: - ∀X.(X → B) ≅ (∃X.X) → B

func forallXToBool<X>(_ x: X) -> Bool {
    anyToBool(x)
}

/// - Note: `∃X.X` is isomorphic to `Any`.
func anyToBool(_ any: Any) -> Bool {
    forallXToBool(any)
}

// MARK: - ∀(X <: P).(X → B) ≅ (∃(X <: P).X) → B

protocol P {
    var value: String { get }
}

struct AnyP: P { // Type erasure
    let value: String
}

func forallXProtocolToBool<X: P>(_ x: X) -> Bool { // Generic func
    protocolToBool(x)
}

func protocolToBool(_ p: P) -> Bool { // Protocol func (dynamic)
    forallXProtocolToBool(AnyP(value: p.value))
}

// Reverse Opaque Result Type (static, isn't supported yet in Swift 5.1)
// ERROR: 'some' types are only implemented for the declared type of properties and subscripts and the return type of functions
//func someProtocolToBool(_ p: some P) -> Bool {
//    forallXProtocolToBool(p)
//}



print("✅")
