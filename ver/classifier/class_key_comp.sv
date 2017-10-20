/* (c) 2017 Bayware, Inc.
//
//   Project: Mackinac
//   Module:  class_key_comp.sv
//   Owner:   G Walter
//   Date:    10/18/17
//
//   Summary:  Compares keys from value memory to original key.  Gets
//   result from OF TCAM compare and produces final hit/miss with FID or
//   TID.  Supports one of the two value mem ports only.
/*                                                                           */

module class_key_comp(
#(
    parameter KEY_LEN = 276
)
    input logic clk,
    input logic rst_n,

    // hbkt & val mem
    input logic pkt_strobe,
    input logic pkt_hbkt_err,
    input logic pkt_hbkt_hit_miss,
    input logic [ ] val_ptr,
    input logic [ ] key_orig,
    input logic [ ] value_mem_douta_q,

    // OF TCAM
    input logic of_tcam_vld,
    input logic of_tcam_err,
    input logic of_tcam_hit_miss,
    input logic [ ] tcam_ptr,

    // final
    output logic final_vld,
    output logic final_err,
    output logic [ ] final_hit_miss,
    output logic [ ] final_ptr
);

// =======================================================================
// Declarations & Parameters

// =======================================================================
// Combinational Logic

// =======================================================================
// Registered Logic


endmodule
