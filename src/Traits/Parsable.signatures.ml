module type S0 = sig
  type t

  val try_of_string: string -> t option
  val of_string: string -> t
end
