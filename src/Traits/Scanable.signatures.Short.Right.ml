module type S0 = sig
  type elt
  type t

  val scan_short_right: t -> init:elt -> f:(elt -> elt -> Shorten.t * elt) -> t
  val scan_short_right_i: t -> init:elt -> f:(i:int -> elt -> elt -> Shorten.t * elt) -> t
  val scan_short_right_acc: acc:'acc -> t -> init:elt -> f:(acc:'acc -> elt -> elt -> 'acc * Shorten.t * elt) -> t
end

module type S1 = sig
  type 'a t

  val scan_short_right: 'a t -> init:'b -> f:('a -> 'b -> Shorten.t * 'b) -> 'b t
  val scan_short_right_i: 'a t -> init:'b -> f:(i:int -> 'a -> 'b -> Shorten.t * 'b) -> 'b t
  val scan_short_right_acc: acc:'acc -> 'a t -> init:'b -> f:(acc:'acc -> 'a -> 'b -> 'acc * Shorten.t * 'b) -> 'b t
end
