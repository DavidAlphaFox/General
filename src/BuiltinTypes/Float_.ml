module SelfA = struct
  type t = float

  let zero = 0.

  let one = 1.

  let of_int x =
    OCamlStandard.Pervasives.float_of_int x

  let to_int x =
    OCamlStandard.Pervasives.int_of_float x

  let of_float x =
    x

  let to_float x =
    x

  let of_string x =
    OCamlStandard.Pervasives.float_of_string x

  let to_string x =
    OCamlStandard.Pervasives.string_of_float x

  let repr x =
    OCamlStandard.Pervasives.string_of_float x

  let add x y =
    OCamlStandard.Pervasives.(+.) x y

  let substract x y =
    OCamlStandard.Pervasives.(-.) x y

  let negate x =
    OCamlStandard.Pervasives.(~-.) x

  let multiply x y =
    OCamlStandard.Pervasives.( *. ) x y

  let divide x y =
    OCamlStandard.Pervasives.(/.) x y

  let abs x =
    OCamlStandard.Pervasives.abs_float x

  let modulo x y =
    OCamlStandard.Pervasives.mod_float x y

  let exponentiate_negative_exponent ~exponentiate x n =
    exponentiate (divide 1. x) OCamlStandard.Pervasives.(-n)
end

module SelfB = struct
  include Traits_.Ringoid_.Square.Make0(SelfA)
  include SelfA
end

module SelfC = struct
  include Concepts_.Integer_.PredSucc.Make0(SelfB)
  include Traits_.Ringoid_.Exponentiate.Make0(SelfB)
  include SelfB
end

module O = struct
  include Compare_.Poly.O
  include Equate_.Poly.O
  include Traits_.Ringoid_.Operators.Make0(SelfC)

  let (mod) x y =
    OCamlStandard.Pervasives.mod_float x y
end

include (Compare_.Poly: module type of Compare_.Poly with module O := O)
include (Equate_.Poly: module type of Equate_.Poly with module O := O)
include SelfC

module Class = struct
  type t =
    | Normal
    | SubNormal
    | Zero
    | Infinite
    | Nan

  let of_float x =
    match OCamlStandard.Pervasives.classify_float x with
      | OCamlStandard.Pervasives.FP_normal -> Normal
      | OCamlStandard.Pervasives.FP_subnormal -> SubNormal
      | OCamlStandard.Pervasives.FP_zero -> Zero
      | OCamlStandard.Pervasives.FP_infinite -> Infinite
      | OCamlStandard.Pervasives.FP_nan -> Nan

  let repr = function
    | Normal -> "Normal"
    | SubNormal -> "SubNormal"
    | Zero -> "Zero"
    | Infinite -> "Infinite"
    | Nan -> "Nan"

  module O = struct
    include Compare_.Poly.O
    include Equate_.Poly.O
  end

  include (Compare_.Poly: module type of Compare_.Poly with module O := O)
  include (Equate_.Poly: module type of Equate_.Poly with module O := O)
end
