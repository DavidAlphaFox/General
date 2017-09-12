module type S0 = sig
  type elt
  type t

  val map: t -> f:(elt -> 'b) -> 'b C.t
  val map_i: t -> f:(i:int -> elt -> 'b) -> 'b C.t
  val map_acc: acc:'acc -> t -> f:(acc:'acc -> elt -> 'acc * 'b) -> 'b C.t

  val filter: t -> f:(elt -> bool) -> elt C.t
  val filter_i: t -> f:(i:int -> elt -> bool) -> elt C.t
  val filter_acc: acc:'acc -> t -> f:(acc:'acc -> elt -> 'acc * bool) -> elt C.t

  val filter_map: t -> f:(elt -> 'b option) -> 'b C.t
  val filter_map_i: t -> f:(i:int -> elt -> 'b option) -> 'b C.t
  val filter_map_acc: acc:'acc -> t -> f:(acc:'acc -> elt -> 'acc * 'b option) -> 'b C.t

  val flat_map: t -> f:(elt -> 'b C.t) -> 'b C.t
  val flat_map_i: t -> f:(i:int -> elt -> 'b C.t) -> 'b C.t
  val flat_map_acc: acc:'acc -> t -> f:(acc:'acc -> elt -> 'acc * 'b C.t) -> 'b C.t
end

module type S1 = sig
  type 'a t

  val map: 'a t -> f:('a -> 'b) -> 'b C.t
  val map_i: 'a t -> f:(i:int -> 'a -> 'b) -> 'b C.t
  val map_acc: acc:'acc -> 'a t -> f:(acc:'acc -> 'a -> 'acc * 'b) -> 'b C.t

  val filter: 'a t -> f:('a -> bool) -> 'a C.t
  val filter_i: 'a t -> f:(i:int -> 'a -> bool) -> 'a C.t
  val filter_acc: acc:'acc -> 'a t -> f:(acc:'acc -> 'a -> 'acc * bool) -> 'a C.t

  val filter_map: 'a t -> f:('a -> 'b option) -> 'b C.t
  val filter_map_i: 'a t -> f:(i:int -> 'a -> 'b option) -> 'b C.t
  val filter_map_acc: acc:'acc -> 'a t -> f:(acc:'acc -> 'a -> 'acc * 'b option) -> 'b C.t

  val flat_map: 'a t -> f:('a -> 'b C.t) -> 'b C.t
  val flat_map_i: 'a t -> f:(i:int -> 'a -> 'b C.t) -> 'b C.t
  val flat_map_acc: acc:'acc -> 'a t -> f:(acc:'acc -> 'a -> 'acc * 'b C.t) -> 'b C.t
end
