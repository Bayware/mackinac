// (c) 2017 Bayware, Inc.
//
//   Project: Mackinac
//   Module:  class_key_cmp
//   Owner:   G Walter
//   Date:    10/18/17
//
//   Summary:  Compares keys from value memory to original key.  Gets
//   result from OF TCAM compare and produces final hit/miss with FID or
//   TID.  Supports one of the two value mem ports only.

module class_key_cmp
#(
    parameter KEY_LEN = 276,
    parameter VT_AWIDTH = 15
)
(
    input logic clk,
    input logic rst_n,

    // hbkt & val mem
    input logic pkt_strobe,
    input logic pkt_hbkt_err,
    input logic pkt_hbkt_hit_miss,
    input logic [ VT_AWIDTH - 1:0 ] val_ptr,
    input logic [ KEY_LEN - 1:0 ] key_orig,
    input logic [ KEY_LEN - 1:0 ] val_mem_dout_q,

    // OF TCAM
    input logic oftcam_vld,
    input logic oftcam_err,
    input logic oftcam_hit_miss,
    input logic [ VT_AWIDTH - 1:0 ] tcam_ptr,

    // final
    output logic final_vld,
    output logic final_err,
    output logic final_hit_miss,
    output logic [ VT_AWIDTH - 1:0 ] final_ptr
);

// =======================================================================
// Declarations & Parameters

logic [ VT_AWIDTH - 1:0 ] val_ptr_aligned;
logic rd_vld_aligned;

logic [ KEY_LEN - 1:0 ] key_orig_q;

logic pkt_strobe_aligned;
logic pkt_strobe_aligned_q;
logic pkt_strobe_aligned_qq;
logic pkt_strobe_aligned_qqq;
logic pkt_strobe_aligned_qqqq;

logic pkt_strobe_q;
logic pkt_strobe_qq;
logic pkt_strobe_qqq;
logic pkt_strobe_qqqq;

logic pkt_hbkt_hit_miss_q;
logic pkt_hbkt_hit_miss_qq;
logic pkt_hbkt_hit_miss_qqq;
logic pkt_hbkt_hit_miss_qqqq;

logic [ VT_AWIDTH - 1:0 ] val_ptr_aligned_q;
logic [ VT_AWIDTH - 1:0 ] val_ptr_aligned_qq;
logic [ VT_AWIDTH - 1:0 ] val_ptr_aligned_qqq;
logic [ VT_AWIDTH - 1:0 ] val_ptr_aligned_qqqq;

logic cmp_q;
logic cmp_running_q;

// =======================================================================
// Combinational Logic

// these align to rd_data_q from value memory
assign pkt_strobe_aligned = pkt_strobe_qqqq;
assign rd_vld_aligned = pkt_hbkt_hit_miss_qqqq;
assign val_ptr_aligned = val_ptr_aligned_qqqq;

assign final_vld = pkt_strobe_aligned_qqqq;
assign final_hit_miss = cmp_running_q /*FIXME*/ || oftcam_hit_miss & oftcam_vld & !oftcam_err;

// =======================================================================
// Registered Logic

// Register:  pkt_strobe_qqqq
// Register:  pkt_hbkt_hit_miss_qqqq
//
// Pipeline all info related to value memory lookup in order to correctly
// identify hit/miss and have corred FID/TID ready.

always_ff @( posedge clk )
    if ( !rst_n )
    begin
        pkt_strobe_q <= 1'b0;
        pkt_strobe_qq <= 1'b0;
        pkt_strobe_qqq <= 1'b0;
        pkt_strobe_qqqq <= 1'b0;

        pkt_hbkt_hit_miss_q <= 1'b0;
        pkt_hbkt_hit_miss_qq <= 1'b0;
        pkt_hbkt_hit_miss_qqq <= 1'b0;
        pkt_hbkt_hit_miss_qqqq <= 1'b0;

        val_ptr_aligned_q <= '0;
        val_ptr_aligned_qq <= '0;
        val_ptr_aligned_qqq <= '0;
        val_ptr_aligned_qqqq <= '0;
    end

    else
    begin
        pkt_strobe_q <= pkt_strobe;
        pkt_strobe_qq <= pkt_strobe_q;
        pkt_strobe_qqq <= pkt_strobe_qq;
        pkt_strobe_qqqq <= pkt_strobe_qqq;

        pkt_hbkt_hit_miss_q <= pkt_hbkt_hit_miss;
        pkt_hbkt_hit_miss_qq <= pkt_hbkt_hit_miss_q;
        pkt_hbkt_hit_miss_qqq <= pkt_hbkt_hit_miss_qq;
        pkt_hbkt_hit_miss_qqqq <= pkt_hbkt_hit_miss_qqq;

        val_ptr_aligned_q <= val_ptr;
        val_ptr_aligned_qq <= val_ptr_aligned_q;
        val_ptr_aligned_qqq <= val_ptr_aligned_qq;
        val_ptr_aligned_qqqq <= val_ptr_aligned_qqq;
    end

// Register:  pkt_strobe_aligned_qqqqq

always_ff @( posedge clk )
    if ( !rst_n )
    begin
        pkt_strobe_aligned_q <= 1'b0;
        pkt_strobe_aligned_qq <= 1'b0;
        pkt_strobe_aligned_qqq <= 1'b0;
        pkt_strobe_aligned_qqqq <= 1'b0;
    end

    else
    begin
        pkt_strobe_aligned_q <= pkt_strobe_aligned;
        pkt_strobe_aligned_qq <= pkt_strobe_aligned_q;
        pkt_strobe_aligned_qqq <= pkt_strobe_aligned_qq;
        pkt_strobe_aligned_qqqq <= pkt_strobe_aligned_qqq;
    end

// Register:  key_orig_q
always_ff @( posedge clk )
    if ( !rst_n )
        key_orig_q <= '0;

    else
        key_orig_q <= key_orig;

// Register:  cmp_q
//
// When a value memory read is valid (that is, this a "hit" cycle form the hash
// bucket compare logic), then this signal holds the compare status between the
// current output from value memory with the original key.

always_ff @( posedge clk )
    if ( !rst_n )
        cmp_q <= 1'b0;

    else if ( rd_vld_aligned )
        cmp_q <= val_mem_dout_q == key_orig_q;

    else
        cmp_q <= 1'b0;

// Register:  cmp_running_q
//
// For four consecutive cycles the value memory may be read for a given lookup.
// The results of the four lookups--their match status--is consolidated in this
// signal.  Note that more than one match from the value memory constitutes an
// error.
//
// FIXME:  this doesn't take into account the OF TCAM yet; also needs to take into
// account pkt_hbkt_err

always_ff @( posedge clk )
    if ( !rst_n )
    begin
        cmp_running_q <= 1'b0;
        final_err <= 1'b0;
        final_ptr <= { VT_AWIDTH{ 1'b0 } };
    end

    else if ( pkt_strobe_aligned_q )
    begin
        cmp_running_q <= cmp_q;
        final_err <= 1'b0;
        final_ptr <= cmp_q ? val_ptr_aligned_q : { VT_AWIDTH{ 1'b0 } };
    end

    else if ( pkt_strobe_aligned_qq )
    begin
        cmp_running_q <= cmp_running_q | cmp_q;
        final_err <= cmp_running_q && cmp_q;
        final_ptr <= cmp_q ? val_ptr_aligned_qq : final_ptr;
    end

    else if ( pkt_strobe_aligned_qqq )
    begin
        cmp_running_q <= cmp_running_q | cmp_q;
        final_err <= cmp_running_q && cmp_q;
        final_ptr <= cmp_q ? val_ptr_aligned_qqq : final_ptr;
    end

    else if ( pkt_strobe_aligned_qqqq )
    begin
        cmp_running_q <= cmp_running_q | cmp_q;
        final_err <= cmp_running_q && cmp_q;
        final_ptr <= cmp_q ? val_ptr_aligned_qqqq : final_ptr;
    end

    else
    begin
        cmp_running_q <= 1'b0;
        final_err <= 1'b0;
        final_ptr <= tcam_ptr /* FIXME was '0 */;
    end

endmodule
