// (c) 2017 Bayware, Inc.
//
//   Project: Mackinac
//   Module:  class_intf.sv
//   Owner:   G Walter
//   Date:    10/27/17
//
//   Summary:  Interface for the classifier.

interface class_intf
    import class_pkg::*;
#(
    parameter BUS_WIDTH = 128,
    parameter ITEMS = 32768,
    localparam VT_AWIDTH = $clog2( ITEMS )
)
(
    input logic clk,
    output logic rst_n
);
    // data path lookup
    logic lu_vld = 0;
    logic [ BUS_WIDTH - 1:0 ] lu_key = '0;
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

    // pio
    logic pio_start = 1'b0;
    logic pio_rw = 1'b0;
    logic [ PIO_NBITS - 1:0 ] pio_addr_wdata = '0;
    logic clk_div;
    logic pio_ack;
    logic pio_rvalid;
    logic [ PIO_NBITS - 1:0 ] pio_rdata;

    modport class_ing
    (
        input lu_vld, lu_key, pio_start, pio_rw, pio_addr_wdata,
        output lu_done, lu_hit_miss, lu_vid, lu_err, clk_div, pio_rvalid,
        pio_ack, pio_rdata
    );

    clocking cb @( posedge clk );
        default output #1;

        input lu_done, lu_hit_miss, lu_vid, lu_err, clk_div, pio_ack,
        pio_rvalid, pio_rdata;
        output lu_vld, lu_key, rst_n, pio_start, pio_rw, pio_addr_wdata;
    endclocking

    modport TB ( clocking cb );

endinterface
