let (//) = Filename.concat




let ((>::),
     (>:::)) = OUnit.((>::),(>:::))

let (=~) = OUnit.assert_equal





(* let output_of_exec_command command args =
    let readme, writeme = Unix.pipe () in 
    let pid = Unix.create_process command args Unix.stdin writeme Unix.stderr in 
    let in_chan = Unix.in_channel_of_descr readme *)


let react = {|
type u 

external a : u = "react" [@@bs.module]

external b : unit -> int = "bool" [@@bs.module "react"]

let v = a
let h = b ()

|}        
let foo_react = {|
type bla


external foo : bla = "foo.react" [@@bs.module]

external bar : unit -> bla  = "bar" [@@bs.val] [@@bs.module "foo.react"]

let c = foo 

let d = bar ()

|}

let perform_bsc = Ounit_cmd_util.perform_bsc
let bsc_eval = Ounit_cmd_util.bsc_eval


let suites = 
  __FILE__
  >::: [
    __LOC__ >:: begin fun _ -> 
      let v_output = perform_bsc  [| "-v" |] in 
      OUnit.assert_bool __LOC__ ((perform_bsc [| "-h" |]).exit_code  <> 0  );
      OUnit.assert_bool __LOC__ (v_output.exit_code = 0);
      (* Printf.printf "\n*>%s" v_output.stdout; *)
      (* Printf.printf "\n*>%s" v_output.stderr ; *)
    end; 
    __LOC__ >:: begin fun _ -> 
      let simple_quote = 
        perform_bsc  [| "-bs-eval"; {|let str = "'a'" |}|] in 
      OUnit.assert_bool __LOC__ (simple_quote.exit_code = 0)
    end;
    __LOC__ >:: begin fun _ -> 
      let should_be_warning = 
        bsc_eval  {|let bla4 foo x y= foo##(method1 x y [@bs]) |} in 
      (* debug_output should_be_warning; *)
      OUnit.assert_bool __LOC__ (Ext_string.contain_substring
                                   should_be_warning.stderr Literals.unused_attribute)
    end;
    __LOC__ >:: begin fun _ -> 
      let dedupe_require = 
        bsc_eval (react ^ foo_react) in 
      OUnit.assert_bool __LOC__ (Ext_string.non_overlap_count
                                   dedupe_require.stdout ~sub:"require" = 2
                                )     
    end;
    __LOC__ >:: begin fun _ -> 
      let dedupe_require = 
        bsc_eval react in 
      OUnit.assert_bool __LOC__ (Ext_string.non_overlap_count
                                   dedupe_require.stdout ~sub:"require" = 1
                                )     
    end;
    __LOC__ >:: begin fun _ -> 
      let dedupe_require = 
        bsc_eval foo_react in 
      OUnit.assert_bool __LOC__ (Ext_string.non_overlap_count
                                   dedupe_require.stdout ~sub:"require" = 1
                                )     
    end

  ]

