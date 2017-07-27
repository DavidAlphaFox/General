open Abbr_

include (Concepts_.Number_: module type of Number_)

module Tests = struct
  open Testing_

  module Examples = struct
    module type S0 = sig
      include Traits.Representable.Tests.Examples.S0
      include Traits.Displayable.Tests.Examples.S0 with type t := t
      include Traits.Equatable.Tests.Examples.S0 with type t := t
      include Traits.Ringoid.Tests.Examples.S0 with type t := t
    end
  end

  module Make0(M: S0)(E: Examples.S0 with type t := M.t) = struct
    open M

    module E = struct
      include E

      let equal = equal @ [
        [zero; of_int 0; of_float 0.; of_string "0"];
        [one; of_int 1; of_float 1.; of_string "1"];
      ]

      let different = different @ [
        (zero, one);
      ]
    end

    let test = "Number" >:: [
      (let module T = Traits.Representable.Tests.Make0(M)(E) in T.test);
      (let module T = Traits.Displayable.Tests.Make0(M)(E) in T.test);
      (let module T = Traits.Equatable.Tests.Make0(M)(E) in T.test);
      (let module T = Traits.Ringoid.Tests.Make0(M)(E) in T.test);
    ]
  end
end