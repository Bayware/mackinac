// (c) 2017 Bayware, Inc.
//
//   Project: Mackinac
//   Module:  class_hash_top.sv
//   Owner:   G Walter
//   Date:    10/03/17
//
//   Summary:  This block receives the key in three contiguous clock cycles.
//   The key must be padded out with 0s by the calling module to support a 
//   width of 3*BUS_WIDTH.  The hash is returned three clock cycles later.

module class_hash_top
#(
    BUS_WIDTH = 128,
    HASH_WIDTH = 13
)
(
    // system
    input logic clk,
    input logic rst_n,

    // port A signals
    input logic [ BUS_WIDTH - 1:0 ] key_a,
    input logic key_a_start,
    output logic hash_a_vld,
    output logic [ HASH_WIDTH - 1:0 ] h1k_a,
    output logic [ HASH_WIDTH - 1:0 ] h2k_a,

    // port B signals
    input logic [ BUS_WIDTH - 1:0 ] key_b,
    input logic key_b_start,
    output logic hash_b_vld,
    output logic [ HASH_WIDTH - 1:0 ] h1k_b,
    output logic [ HASH_WIDTH - 1:0 ] h2k_b
);

// =======================================================================
// Declarations & Parameters

localparam HASH_WIDTH_MASK = 2**HASH_WIDTH - 1;
localparam CRC32_INIT = 32'hffff_ffff;
localparam CRC16_INIT = 16'hffff;

logic key_a_start_q;
logic key_a_start_qq;
logic key_a_start_qqq;

logic key_b_start_q;
logic key_b_start_qq;
logic key_b_start_qqq;

logic [ 31:0 ] crc_a_1;
logic [ 31:0 ] next_crc_a_1;
logic [ 31:0 ] crc_a_1_final;
logic [ 15:0 ] crc_a_2;
logic [ 15:0 ] next_crc_a_2;
logic [ 15:0 ] crc_a_2_final;
logic [ 31:0 ] crc_b_1;
logic [ 31:0 ] next_crc_b_1;
logic [ 31:0 ] crc_b_1_final;
logic [ 15:0 ] crc_b_2;
logic [ 15:0 ] next_crc_b_2;
logic [ 15:0 ] crc_b_2_final;

// =======================================================================
// Combinational Logic

assign hash_a_vld = key_a_start_qqq;
assign hash_b_vld = key_b_start_qqq;

assign crc_a_1 = key_a_start ? CRC32_INIT : next_crc_a_1;
assign crc_a_1_final = key_a_start_qqq ? next_crc_a_1 : 32'd0;
assign h1k_a = crc_a_1_final & HASH_WIDTH_MASK;

assign crc_a_2 = key_a_start ? CRC16_INIT : next_crc_a_2;
assign crc_a_2_final = key_a_start_qqq ? next_crc_a_2 : 32'd0;
assign h2k_a = crc_a_2_final & HASH_WIDTH_MASK;

assign crc_b_1 = key_b_start ? CRC32_INIT : next_crc_b_1;
assign crc_b_1_final = key_b_start_qqq ? next_crc_b_1 : 32'd0;
assign h1k_b = crc_b_1_final & HASH_WIDTH_MASK;

assign crc_b_2 = key_b_start ? CRC16_INIT : next_crc_b_2;
assign crc_b_2_final = key_b_start_qqq ? next_crc_b_2 : 32'd0;
assign h2k_b = crc_b_2_final & HASH_WIDTH_MASK;

// =======================================================================
// Registered Logic

// Register:  key_a_start_q
// Register:  key_a_start_qq
// Register:  key_a_start_qqq
always @( posedge clk )
    if ( !rst_n )
    begin
        key_a_start_q <= 1'b0;
        key_a_start_qq <= 1'b0;
        key_a_start_qqq <= 1'b0;
    end

    else
    begin
        key_a_start_q <= key_a_start;
        key_a_start_qq <= key_a_start_q;
        key_a_start_qqq <= key_a_start_qq;
    end

// Register:  key_b_start_q
// Register:  key_b_start_qq
// Register:  key_b_start_qqq
always @( posedge clk )
    if ( !rst_n )
    begin
        key_b_start_q <= 1'b0;
        key_b_start_qq <= 1'b0;
        key_b_start_qqq <= 1'b0;
    end

    else
    begin
        key_b_start_q <= key_b_start;
        key_b_start_qq <= key_b_start_q;
        key_b_start_qqq <= key_b_start_qq;
    end

// =======================================================================
// Module Instantiations

// CRC32 for H1(k) Port A
crc32_d128_mod u_crc32_d128_a
(
    .clk( clk ),
    .rst_n( rst_n ),

    .data( key_a ),
    .crc( crc_a_1 ),
    .next_crc( next_crc_a_1 )
);

// CRC16 for H2(k) Port A
crc16_d128_mod u_crc16_d128_a
(
    .clk( clk ),
    .rst_n( rst_n ),

    .data( key_a ),
    .crc( crc_a_2 ),
    .next_crc( next_crc_a_2 )
);

// CRC32 for H1(k) Port B
crc32_d128_mod u_crc32_d128_b
(
    .clk( clk ),
    .rst_n( rst_n ),

    .data( key_b ),
    .crc( crc_b_1 ),
    .next_crc( next_crc_b_1 )
);

// CRC16 for H2(k) Port B
crc16_d128_mod u_crc16_d128_b
(
    .clk( clk ),
    .rst_n( rst_n ),

    .data( key_b ),
    .crc( crc_b_2 ),
    .next_crc( next_crc_b_2 )
);

endmodule
