include Foundations.String_

module OCSS = OCamlStandard.String

(* @todo Find a suitable module for 'or_failure'? (If yes, accept a Format.t) *)
let or_failure message = function
  | None ->
    Exception.failure message
  | Some x ->
    x

let size = OCSS.length

let substring s ~pos ~len = OCSS.sub s pos len

let prefix s ~len =
  substring s ~pos:0 ~len

let suffix s ~len =
  substring s ~pos:(size s - len) ~len

let has_prefix s ~pre =
  size s >= size pre
  && pre = prefix s ~len:(size pre)

let has_suffix s ~suf =
  size s >= size suf
  && suf = suffix s ~len:(size suf)

let drop_prefix' s ~len =
  substring s ~pos:len ~len:(size s - len)

let drop_suffix' s ~len =
  substring s ~pos:0 ~len:(size s - len)

let try_drop_suffix s ~suf =
  Option.some_if
    (has_suffix s ~suf)
    (lazy (drop_suffix' s ~len:(size suf)))

let try_drop_prefix s ~pre =
  Option.some_if
    (has_prefix s ~pre)
    (lazy (drop_prefix' s ~len:(size pre)))

let drop_suffix s ~suf =
  try_drop_suffix ~suf s
  |> or_failure "String.drop_suffix"

let drop_prefix s ~pre =
  try_drop_prefix ~pre s
  |> or_failure "String.drop_prefix"

let split s ~sep =
  let len = size sep in
  if len = 0 then Exception.invalid_argument "String.split: empty separator";
  let match_sep ~pos =
    pos >= 0
    && substring s ~pos ~len = sep
  in
  let rec aux ret last_pos = function
    | pos when match_sep ~pos ->
      aux ((substring s ~pos:(pos + len) ~len:(last_pos - pos -len))::ret) pos (pos - len)
    | pos when pos <= 0 ->
      (substring s ~pos:0 ~len:last_pos)::ret
    | pos ->
      aux ret last_pos (pos - 1)
  in
  match aux [] (size s) ((size s) - len) with
    | [""] -> []
    | parts -> parts

module Tests = struct
  open Testing

  module Examples = struct
    let repr = [
      ("foo", "\"foo\"");
      ("bar\"baz", "\"bar\\\"baz\"");
    ]

    let equal = [
      ["foo"];
    ]

    let different = [
      ("foo", "bar");
    ]
  end

  let test = "String" >:: [
    (let module T = Traits.Representable.Tests.Make0(Foundations.String_)(Examples) in T.test);
    (let module T = Traits.Equatable.Tests.Make0(Foundations.String_)(Examples) in T.test);
  ]
end