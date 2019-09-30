(* Phase 1: ensure our code is explicit about using the OCaml standard library (i.e. through OCamlStandard) *)

module OCamlStandard = struct
  #include "Reset/OCamlStandard.ml"
end

module Reset = struct
  #define SIGNATURE 0
  #include "Reset/ResetPervasives.ml"
  #include "Reset/ResetStandardLibrary.ml"
  #undef SIGNATURE
end

open Reset

module OCSP = OCamlStandard.Pervasives

(* Phase 2: add basic types used in Facets' interface *)

module Equate = struct
  #include "Equate.ml"
end

module Compare = struct
  #include "Compare.ml"
end

module Shorten = struct
  #include "Shorten.ml"
end

module Test = struct
  #include "Testing/Test.ml"
end

module type Facets = sig
  [@@@ocaml.warning "-32"]
  #include "Generated/Facets.mli"
  [@@@ocaml.warning "+32"]
end

module type Testing = sig
  type context = NodeJs | ByteCode | Native
  val context: context

  val (>::): string -> Test.t list -> Test.t
  val (>:): string -> unit lazy_t -> Test.t
  val (~:): ('a, unit, string, string, string, unit lazy_t -> Test.t) CamlinternalFormatBasics.format6 -> 'a
  (* val (~::): ('a, unit, string, string, string, Test.t list -> Test.t) CamlinternalFormatBasics.format6 -> 'a *)

  (* val fail: ('a, unit, string, string, string, 'b) CamlinternalFormatBasics.format6 -> 'a *)
  val expect_exception: expected:exn -> 'a lazy_t -> unit
  val expect_exception_named: expected:string -> 'a lazy_t -> unit
  val check: repr:('a -> string) -> equal:('a -> 'a -> bool) -> expected:'a -> 'a -> unit
  (* val check_poly: repr:('a -> string) -> expected:'a -> 'a -> unit *)

  val check_compare: expected:Compare.t -> Compare.t -> unit
  val check_eq: Compare.t -> unit
  val check_lt: Compare.t -> unit
  val check_gt: Compare.t -> unit
  val check_string: expected:string -> string -> unit
  val check_bool: expected:bool -> bool -> unit
  val check_true: bool -> unit
  val check_false: bool -> unit
  val check_int: expected:int -> int -> unit
  (* val check_int32: expected:int32 -> int32 -> unit *)
  (* val check_int64: expected:int64 -> int64 -> unit *)
  (* val check_float: ?precision:float -> expected:float -> float -> unit *)
  (* val check_float_in: low:float -> high:float -> float -> unit *)
  val check_float_exact: expected:float -> float -> unit
  (* val check_option: repr:('a -> string) -> equal:('a -> 'a -> bool) -> expected:'a option -> 'a option -> unit *)
  (* val check_option_poly: repr:('a -> string) -> expected:'a option -> 'a option -> unit *)
  val check_some: repr:('a -> string) -> equal:('a -> 'a -> bool) -> expected:'a -> 'a option -> unit
  val check_none: repr:('a -> string) -> equal:('a -> 'a -> bool) -> 'a option -> unit
  (* val check_some_poly: repr:('a -> string) -> expected:'a -> 'a option -> unit *)
  (* val check_none_poly: repr:('a -> string) -> 'a option -> unit *)
  (* val check_int_option: expected:int option -> int option -> unit *)
  val check_some_int: expected:int -> int option -> unit
  val check_none_int: int option -> unit
  (* val check_string_option: expected:string option -> string option -> unit *)
  val check_some_string: expected:string -> string option -> unit
  (* val check_none_string: string option -> unit *)
  (* val check_list: repr:('a -> string) -> equal:('a -> 'a -> bool) -> expected:'a list -> 'a list -> unit *)
  (* val check_list_poly: repr:('a -> string) -> expected:'a list -> 'a list -> unit *)
  val check_string_list: expected:string list -> string list -> unit
  (* val check_int_list: expected:int list -> int list -> unit *)
  val check_int_tuple2: expected:int * int -> int * int -> unit
  val check_int_tuple3: expected:int * int * int -> int * int * int -> unit
  val check_int_tuple4: expected:int * int * int * int -> int * int * int * int -> unit
  val check_int_tuple5: expected:int * int * int * int * int -> int * int * int * int * int -> unit
end

(* Phase 3: implement everything that does not depend on Facets *)

module Format = struct
  #include "OldFashion/Atoms/Format.ml"
end

module Lazy_ = struct
  #include "Wrappers/Lazy.ml"
  module Lazy = Basic
end
open Lazy_

module Exception_ = struct
  #include "Atoms/Exception.ml"
  module Exception = Basic
end
open Exception_

module Function1_ = struct
  #include "Atoms/Function1.ml"
  module Function1 = Basic
end
open Function1_

let (|>) = Function1.rev_apply  (* @todo Put somewhere *)

module Bool_ = struct
  #include "Atoms/Bool.ml"
  module Bool = Basic
end
open Bool_

module Function2_ = struct
  #include "Atoms/Function2.ml"
  module Function2 = Basic
end
open Function2_

module Function3_ = struct
  #include "Atoms/Function3.ml"
  module Function3 = Basic
end
open Function3_

module Function4_ = struct
  #include "Atoms/Function4.ml"
  module Function4 = Basic
end
open Function4_

module Function5_ = struct
  #include "Atoms/Function5.ml"
  module Function5 = Basic
end
open Function5_

module Int_ = struct
  #include "Atoms/Int.ml"
  module Int = Basic
end
open Int_

module Reference_ = struct
  #include "Wrappers/Reference.ml"
  module Reference = Basic
end
open Reference_

let ref = Reference.of_contents  (* @todo Put somewhere *)
let ( ! ) = Reference.O.( ! )  (* @todo Put somewhere *)
let ( := ) = Reference.O.( := )  (* @todo Put somewhere *)

module Option_ = struct
  #include "Wrappers/Option.ml"
  module Option = Basic
end
open Option_

module List_ = struct
  #include "OldFashion/Collections/List.ml"
  module List = Basic
end
open List_

module CallStack_ = struct
  #include "Atoms/CallStack.ml"
  module CallStack = Basic
end
open CallStack_

module Float_ = struct
  #include "Atoms/Float.ml"
  module Float = Basic
end
open Float_

module Unit_ = struct
  #include "Atoms/Unit.ml"
  module Unit = Basic
end
open Unit_

let ignore = Unit.ignore  (* @todo Put somewhere *)

module RedBlackTree = struct
  #include "OldFashion/Collections/RedBlackTree.ml"
end

module Tuple2_ = struct
  #include "Wrappers/Tuple2.ml"
  module Tuple2 = Basic
end
open Tuple2_

module Tuple3_ = struct
  #include "Wrappers/Tuple3.ml"
  module Tuple3 = Basic
end
open Tuple3_

module Tuple4_ = struct
  #include "Wrappers/Tuple4.ml"
  module Tuple4 = Basic
end
open Tuple4_

module Tuple5_ = struct
  #include "Wrappers/Tuple5.ml"
  module Tuple5 = Basic
end
open Tuple5_

module SortedSet_ = struct
  #include "OldFashion/Collections/SortedSet.ml"
  module SortedSet = Basic
end
open SortedSet_

module String_ = struct
  #include "Atoms/String.ml"
  module String = Basic
end
open String_

module IntRange = struct
  #include "OldFashion/Collections/IntRange.ml"
end

module Exit_ = struct
  #include "Atoms/Exit.ml"
  module Exit = Basic
end
open Exit_

module Stream = struct
  #include "OldFashion/Collections/Stream.ml"
end

module Char_ = struct
  #include "Atoms/Char.ml"
  module Char = Basic
end
open Char_

module PervasivesWhitelist = struct
  #include "Reset/PervasivesWhitelist.ml"
end

open PervasivesWhitelist

module Array = struct
  #include "OldFashion/Implementation/Array.ml"
end

module Bytes_ = struct
  #include "Atoms/Bytes.ml"
  module Bytes = Basic
end
open Bytes_

module InChannel = struct
  #include "OldFashion/Implementation/InChannel.ml"
end

module InFile = struct
  #include "OldFashion/Implementation/InFile.ml"
end

module OutChannel = struct
  #include "OldFashion/Implementation/OutChannel.ml"
end

module OutFile = struct
  #include "OldFashion/Implementation/OutFile.ml"
end

module BinaryHeap = struct
  #include "OldFashion/Implementation/BinaryHeap.ml"
end

module StandardOutChannel = struct
  #include "OldFashion/Implementation/StandardOutChannel.ml"
end

module StdErr = struct
  #include "OldFashion/Implementation/StdErr.ml"
end

module StdIn = struct
  #include "OldFashion/Implementation/StdIn.ml"
end

module StdOut = struct
  #include "OldFashion/Implementation/StdOut.ml"
end

module StandardInt = struct
  #include "Atoms/StandardInt.ml"
end

module Int32_ = struct
  #include "Atoms/Int32.ml"
end

module Int64_ = struct
  #include "Atoms/Int64.ml"
  module Int64 = Basic
end
open Int64_

module NativeInt_ = struct
  #include "Atoms/NativeInt.ml"
end

module BigInt_ = struct
  #include "Atoms/BigInt.ml"
end

(* Phase 4: Implement Facets *)

module Facets_alpha = struct
  #include "Generated/Facets_alpha.ml"

  module FilterMapable = struct
    #include "OldFashion/Facets/FilterMapable.ml"
  end

  module Foldable = struct
    #include "OldFashion/Facets/Foldable.ml"
  end

  module Scanable = struct
    #include "OldFashion/Facets/Scanable.ml"
  end
end

module Testing = struct
  #include "Testing/Testing.ml"
end

module Facets = struct
  #include "Generated/Facets.ml"

  module FilterMapable = Facets_alpha.FilterMapable

  module Foldable = Facets_alpha.Foldable

  module Scanable = Facets_alpha.Scanable
end

(* Phase 5: extend implementation using Facets *)

#include "Generated/Types.extended.ml"

module List = List_.Extended(Facets)

module PriorityQueue = struct
  #include "OldFashion/Implementation/PriorityQueue.ml"
end

module Heap = struct
  #include "OldFashion/Implementation/Heap.ml"
end

module SortedMap = struct
  #include "OldFashion/Implementation/SortedMap.ml"
end

module SortedSet = SortedSet_.Extended(Facets)

(* Phase 6: wrap it up *)

module TestingTests = struct
  #include "Testing/Tests.ml"
end

module Specializations = struct
  module List = struct
    #include "OldFashion/Specializations/List.ml"
  end

  module Option = struct
    #include "OldFashion/Specializations/Option.ml"
  end

  module Reference = struct
    #include "OldFashion/Specializations/Reference.ml"
  end

  module SortedMap = struct
    #include "OldFashion/Specializations/SortedMap.ml"
  end

  module SortedSet = struct
    #include "OldFashion/Specializations/SortedSet.ml"
  end
end

module FloatOption = Specializations.Option.Float
module IntOption = Specializations.Option.Int
module StringOption = Specializations.Option.String

module FloatReference = Specializations.Reference.Float
module IntReference = Specializations.Reference.Int
module StringReference = Specializations.Reference.String

module FloatList = Specializations.List.Float
module IntList = Specializations.List.Int
module StringList = Specializations.List.String

module CharSortedSet = Specializations.SortedSet.Char
module FloatSortedSet = Specializations.SortedSet.Float
module IntSortedSet = Specializations.SortedSet.Int
module StringSortedSet = Specializations.SortedSet.String

module CharSortedMap = Specializations.SortedMap.Char
module FloatSortedMap = Specializations.SortedMap.Float
module IntSortedMap = Specializations.SortedMap.Int
module StringSortedMap = Specializations.SortedMap.String

module Standard = struct
  module Testing = Testing

  module Array = Array
  module BigInt = BigInt
  module Bool = Bool
  module Bytes = Bytes
  module CallStack = CallStack
  module Char = Char
  module Exception = Exception
  module Exit = Exit
  module Float = Float
  module Format = Format
  module Function1 = Function1
  module Function2 = Function2
  module Function3 = Function3
  module Function4 = Function4
  module Function5 = Function5
  module Heap = Heap
  module InChannel = InChannel
  module InFile = InFile
  module Int = Int
  module Int32 = Int32
  module Int64 = Int64
  module Lazy = Lazy
  module List = List
  module NativeInt = NativeInt
  module Option = Option
  module OutChannel = OutChannel
  module OutFile = OutFile
  module PriorityQueue = PriorityQueue
  module Reference = Reference
  module SortedMap = SortedMap
  module SortedSet = SortedSet
  module StdErr = StdErr
  module StdIn = StdIn
  module StdOut = StdOut
  module Stream = Stream
  module String = String
  module Tuple2 = Tuple2
  module Tuple3 = Tuple3
  module Tuple4 = Tuple4
  module Tuple5 = Tuple5
  module Unit = Unit

  module IntRange = IntRange

  module FloatOption = FloatOption
  module IntOption = IntOption
  module StringOption = StringOption

  module FloatReference = FloatReference
  module IntReference = IntReference
  module StringReference = StringReference

  module FloatList = FloatList
  module IntList = IntList
  module StringList = StringList

  module CharSortedSet = CharSortedSet
  module FloatSortedSet = FloatSortedSet
  module IntSortedSet = IntSortedSet
  module StringSortedSet = StringSortedSet

  module CharSortedMap = CharSortedMap
  module FloatSortedMap = FloatSortedMap
  module IntSortedMap = IntSortedMap
  module StringSortedMap = StringSortedMap

  module OCamlStandard = OCamlStandard

  include (
    Reset: module type of Reset[@remove_aliases]
    with module Array := Array
    and module Bool := Bool
    and module Bytes := Bytes
    and module Char := Char
    and module Float := Float
    and module Format := Format
    and module Lazy := Lazy
    and module List := List
    and module Option := Option
    and module Stream := Stream
    and module String := String
  )

  include PervasivesWhitelist
end

module Abbr = struct
  module Tst = Testing

  module Ar = Array
  module BigInt = BigInt
  module Bo = Bool
  module By = Bytes
  module CallStack = CallStack
  module Ch = Char
  module Exit = Exit
  module Exn = Exception
  module Fl = Float
  module Frmt = Format
  module Fun1 = Function1
  module Fun2 = Function2
  module Fun3 = Function3
  module Fun4 = Function4
  module Fun5 = Function5
  module Heap = Heap
  module InCh = InChannel
  module InFile = InFile
  module Int = Int
  module Int32 = Int32
  module Int64 = Int64
  module Laz = Lazy
  module Li = List
  module NativeInt = NativeInt
  module Opt = Option
  module OutCh = OutChannel
  module OutFile = OutFile
  module PriQu = PriorityQueue
  module Ref = Reference
  module SoMap = SortedMap
  module SoSet = SortedSet
  module StdErr = StdErr
  module StdIn = StdIn
  module StdOut = StdOut
  module Str = String
  module Strm = Stream
  module Tu2 = Tuple2
  module Tu3 = Tuple3
  module Tu4 = Tuple4
  module Tu5 = Tuple5
  module Unit = Unit

  module IntRa = IntRange

  module FlOpt = FloatOption
  module IntOpt = IntOption
  module StrOpt = StringOption

  module FlRef = FloatReference
  module IntRef = IntReference
  module StrRef = StringReference

  module FlLi = FloatList
  module IntLi = IntList
  module StrLi = StringList

  module ChSoSet = CharSortedSet
  module FlSoSet = FloatSortedSet
  module IntSoSet = IntSortedSet
  module StrSoSet = StringSortedSet

  module ChSoMap = CharSortedMap
  module FlSoMap = FloatSortedMap
  module IntSoMap = IntSortedMap
  module StrSoMap = StringSortedMap

  module OCamlStandard = OCamlStandard

  include Reset
  include PervasivesWhitelist
end

module MakeTests() = struct
  open Testing

  let test = "General" >:: [
    (let module T = BigInt.MakeTests(Testing) in T.test);
    (* BinaryHeap.Tests.test; *)
    (let module T = Bool.MakeTests(Testing) in T.test);
    (let module T = Bytes.MakeTests(Testing) in T.test);
    (let module T = CallStack.MakeTests(Testing) in T.test);
    (let module T = Char.MakeTests(Testing) in T.test);
    (let module T = Exception.MakeTests(Testing) in T.test);
    (let module T = Exit.MakeTests(Testing) in T.test);
    (let module T = Float.MakeTests(Testing) in T.test);
    (let module T = Function1.MakeTests(Testing) in T.test);
    (let module T = Function2.MakeTests(Testing) in T.test);
    (let module T = Function3.MakeTests(Testing) in T.test);
    (let module T = Function4.MakeTests(Testing) in T.test);
    (let module T = Function5.MakeTests(Testing) in T.test);
    (let module T = Int.MakeTests(Testing) in T.test);
    (let module T = Int32.MakeTests(Testing) in T.test);
    (let module T = Int64.MakeTests(Testing) in T.test);
    (let module T = Lazy.MakeTests(Testing) in T.test);
    (* List.Tests.test; *)
    (let module T = NativeInt.MakeTests(Testing) in T.test);
    (let module T = Option.MakeTests(Testing) in T.test);
    (* RedBlackTree.Tests.test; *)
    (let module T = Reference.MakeTests(Testing) in T.test);
    (* Stream.Tests.test; *)
    (let module T = String.MakeTests(Testing) in T.test);
    (let module T = Tuple2.MakeTests(Testing) in T.test);
    (let module T = Tuple3.MakeTests(Testing) in T.test);
    (let module T = Tuple4.MakeTests(Testing) in T.test);
    (let module T = Tuple5.MakeTests(Testing) in T.test);
    (let module T = Unit.MakeTests(Testing) in T.test);

    (* IntRange.Tests.test; *)

    (* TestingTests.Tests.test; *)

    "Syntactic sugar" >:: [
      "Standard" >:: Standard.[
        "array" >:: [
          "get" >: (let a: int array = [|42|] in lazy (check_int ~expected:42 a.(0)));
          "set" >: (let a: int array = [|42|] in lazy (check_int ~expected:42 (Array.get a 0); a.(0) <- 37; check_int ~expected:37 (Array.get a 0)));
        ];
        (* @todo Use check_char *)
        "string" >:: [
          "get" >: (let a: string = "a" in lazy (check_char ~expected:'a' a.[0]));
          #if OCAML_VERSION < (4, 6, 0)
          skip_if_javascript (
            "set" >: (let a: string = "a" in lazy (check_char ~expected:'a' (String.get a 0); a.[0] <- 'z'; check_char ~expected:'z' (String.get a 0)))
          );
          #endif
        ];
        "bytes" >:: [
          "set" >: (let a: bytes = Bytes.of_string "a" in lazy (check_char ~expected:'a' (Bytes.get a 0); a.[0] <- 'z'; check_char ~expected:'z' (Bytes.get a 0)));
        ];
      ];
      "Abbr" >:: Abbr.[
        "array" >:: [
          "get" >: (let a: int array = [|42|] in lazy (check_int ~expected:42 a.(0)));
          "set" >: (let a: int array = [|42|] in lazy (check_int ~expected:42 (Ar.get a 0); a.(0) <- 37; check_int ~expected:37 (Ar.get a 0)));
        ];
        (* @todo Use check_char *)
        "string" >:: [
          "get" >: (let a: string = "a" in lazy (check_char ~expected:'a' a.[0]));
          #if OCAML_VERSION < (4, 6, 0)
          skip_if_javascript (
            "set" >: (let a: string = "a" in lazy (check_char ~expected:'a' (Str.get a 0); a.[0] <- 'z'; check_char ~expected:'z' (Str.get a 0)))
          );
          #endif
        ];
        "bytes" >:: [
          "set" >: (let a: bytes = By.of_string "a" in lazy (check_char ~expected:'a' (By.get a 0); a.[0] <- 'z'; check_char ~expected:'z' (By.get a 0)));
        ];
      ];
    ];
  ]
end
