open StdLabels
open Sexplib.Std

module Make(Driver: Testable.Driver) = struct
  module M = Testable.Make(Driver)

  module EmptyList : M.Testable = struct
    let name = __MODULE__ ^ ".SingleElem"
    type t = int list
    [@@deriving protocol ~driver:(module Driver), sexp]

    let t = []
  end

  module Singleton : M.Testable = struct
    let name = __MODULE__ ^ ".SingleElem"
    type t = int list
    [@@deriving protocol ~driver:(module Driver), sexp]

    let t = [2]
  end

  module LongList : M.Testable = struct
    let name = __MODULE__ ^ ".Longlist"
    type t = int list
    [@@deriving protocol ~driver:(module Driver), sexp]

    let t = [4;3;2;1]
  end

  module EmptyInsideRec : M.Testable = struct
    let name = __MODULE__ ^ ".EmptyInsideRec"
    type v = int [@key "A"]
    and t = { a : string;
              b : v list; [@key "V"]
                c : string;
            }
    [@@deriving protocol ~driver:(module Driver), sexp]

    let t = { a= "a"; b = []; c = "c" }
  end

  module SingleInsideRec : M.Testable = struct
    let name = __MODULE__ ^ ".SingleInsideRec"
    type v = int [@key "A"]
    and t = { a : string;
              b : v list; [@key "V"]
                c : string;
            }
    [@@deriving protocol ~driver:(module Driver), sexp]

    let t = { a= "a"; b = [2]; c = "c" }
  end

  module MultiInsideRec : M.Testable = struct
    let name = __MODULE__ ^ ".MultiInsideRec"
    type v = int [@key "A"]
    and t = { a : string;
              b : v list; [@key "V"]
                c : string;
            }
    [@@deriving protocol ~driver:(module Driver), sexp]

    let t = { a= "a"; b = [4; 2; 3; 1]; c = "c" }
  end

  module ListOfLists : M.Testable = struct
    let name = __MODULE__ ^ ".ListOfLists"
    type v = int list
    and t = { a : v list; }
    [@@deriving protocol ~driver:(module Driver), sexp]

    let t = { a = [ [2;3]; [4;5] ] }
  end

  module ListOfLists2 : M.Testable = struct
    let name = __MODULE__ ^ ".ListOfLists2"
    type t = int list list list
    [@@deriving protocol ~driver:(module Driver), sexp]

    let t = [ []; [ []; [2]; [3;4]; ]; [ [] ]; [ [2] ]; ]
  end

  module Stack_overflow = struct
    type t = int list
    [@@deriving protocol ~driver:(module Driver), sexp]
    let t = List.init ~len:1_000_000 ~f:(fun i -> i)
    let name = __MODULE__ ^ "Stack_overflow"
    let test =
      Alcotest.test_case name `Quick (fun () ->
          try
            to_driver t
            |> of_driver_exn
            |> ignore
          with
          | Failure "ignore" [@warning "-52"] -> ()
        )
  end

  let unittest = __MODULE__, [
      M.test (module EmptyList);
      M.test (module Singleton);
      M.test (module LongList);
      M.test (module EmptyInsideRec);
      M.test (module SingleInsideRec);
      M.test (module MultiInsideRec);
      M.test (module ListOfLists);
      M.test (module ListOfLists2);
      Stack_overflow.test
    ]
end
