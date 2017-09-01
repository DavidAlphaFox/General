type t = string

module OCSS = OCamlStandard.String
module OCSB = OCamlStandard.Bytes
open Int.O
open Bool.O
open Functions.Function1.O

let repr x =
  Format_.apply "%S" x

let to_string = Functions.Function1.identity
let of_string = Functions.Function1.identity

let get = OCSS.get
let set = OCSB.set

let concat = OCSP.(^)

module O = struct
  include Compare.Poly.O
  include Equate.Poly.O

  let (^) = OCSP.(^)
end

include (Compare.Poly: module type of Compare.Poly with module O := O)
include (Equate.Poly: module type of Equate.Poly with module O := O)

let size = OCSS.length

let substring s ~pos ~len =
  OCSS.sub s pos len

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
  |> Option.or_failure "String.drop_suffix"

let drop_prefix s ~pre =
  try_drop_prefix ~pre s
  |> Option.or_failure "String.drop_prefix"

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
