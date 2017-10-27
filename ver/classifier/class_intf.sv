/* (c) 2017 Bayware, Inc.
//
//   Project: Mackinac
//   Module:  class_intf.sv
//   Owner:   G Walter
//   Date:    10/27/17
//
//   Summary:  Interface for the classifier.
*/

interface class_intf
#(
    parameter KEY_LEN = 276,
    parameter ITEMS = 32768,
    parameter BUS_WIDTH = 128,
    localparam VT_AWIDTH = $clog2( ITEMS )
)
(
    input logic clk,
    input logic rst_n
);
    // data path lookup
    logic lu_vld;
    logic [ BUS_WIDTH - 1:0 ] lu_key;
    logic lu_done;
    logic lu_hit_miss;
    logic [ VT_AWIDTH - 1:0 ] lu_vid;
    logic lu_err;

    // data path insert
    logic ins_vld;
    logic [ BUS_WIDTH - 1:0 ] ins_key;
    logic ins_done;
    logic ins_hit_miss;
    logic [ VT_AWIDTH - 1:0 ] ins_vid;
    logic ins_err;

    // data path remove
    logic rm_vld;
    logic [ BUS_WIDTH - 1:0 ] rm_key;
    logic rm_done;
    logic rm_hit_miss;
    logic [ VT_AWIDTH - 1:0 ] rm_vid;
    logic rm_err;

    modport class_ing
    (
        input lu_vld, lu_key,
        output lu_done, lu_hit_miss, lu_vid, lu_err
    );

    clocking cb @( posedge clk );
        default output #1;

        input lu_done, lu_hit_miss, lu_vid, lu_err;
        output lu_vld, lu_key;
    endclocking

    modport TB ( clocking cb );

endinterface
