module type S0 = sig
  type elt
  type t

  val scan_right: t -> init:elt -> f:(elt -> elt -> elt) -> t
  val scan_right_i: t -> init:elt -> f:(i:int -> elt -> elt -> elt) -> t
  val scan_right_acc: acc:'acc -> t -> init:elt -> f:(acc:'acc -> elt -> elt -> 'acc * elt) -> t
end

module type S1 = sig
  type 'a t

  val scan_right: 'a t -> init:'b -> f:('a -> 'b -> 'b) -> 'b t
  val scan_right_i: 'a t -> init:'b -> f:(i:int -> 'a -> 'b -> 'b) -> 'b t
  val scan_right_acc: acc:'acc -> 'a t -> init:'b -> f:(acc:'acc -> 'a -> 'b -> 'acc * 'b) -> 'b t
end
