// (c) 2017 Bayware, Inc.
//
//   Project: Mackinac
//   Module:  memory_arb.sv
//   Owner:   G Walter
//   Date:    10/03/17
//
//   Summary:  Generic memory arbitration.  This module will grow to accept
//   multiple requestors.  Memory depth and width should correspond to 
//   depth and width of actual memory instance.  This module does not do
//   memory decode. (FIXME:  place-holder to get things connected)

module class_hasht_arb
    import class_pkg::*;
#(
    // actual memory instance depth/width
    parameter AW = 13,
    parameter DW = 128
)
(
    input logic clk,
    input logic rst_n,

    input logic req,
    input logic rd_or_wr,
    input logic [ CLASSIFIER_PIO_MEM_ADDR_WIDTH - 1:0 ] addr,
    input logic [ DW - 1:0 ] wdata,

    output logic ack,
    output logic [ PIO_NBITS - 1:0 ] rdata,

    output logic mem_we,
    output logic [ DW - 1:0 ] mem_wdata,
    output logic [ AW - 1:0 ] mem_addr,
    input logic [ DW - 1:0 ] mem_rdata
);

// =======================================================================
// Declarations & Parameters

logic [ 1:0 ] wd_sel;
logic req_q, req_qq, req_qqq;

// =======================================================================
// Combinational Logic

assign wd_sel = addr[ 3:2 ];

// =======================================================================
// Registered Logic

always_ff @( posedge clk )
    if ( !rst_n )
    begin
        mem_we <= 1'b0;
        mem_wdata <= '0;
        mem_addr <= '0;
    end

    else if ( req )
    begin
        mem_we <= rd_or_wr == WR;
        mem_wdata <= wdata;
        mem_addr <= addr[ 16:4 ];
    end

always_ff @( posedge clk )
    if ( !rst_n )
    begin
        req_q <= 1'b0;
        req_qq <= 1'b0;
        req_qqq <= 1'b0;
    end

    else
    begin
        req_q <= req;
        req_qq <= req_q;
        req_qqq <= req_qq;
    end

// FIXME:  writes don't take three cycles; cycles lost in req-ack
// for single client
always_ff @( posedge clk )
    if ( !rst_n )
    begin
        ack <= 1'b0;
        rdata <= '0;
    end

    else if ( req_qqq )
    begin
        ack <= 1'b1;
        rdata <= mem_rdata[ wd_sel * 32 +: 32 ];
    end

    else
    begin
        ack <= 1'b0;
        rdata <= '0;
    end

endmodule
