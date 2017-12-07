// (c) 2017 Bayware, Inc.
//
//   Project: Mackinac
//   Module:  class_hbkt_cmp.sv
//   Owner:   G Walter
//   Date:    10/04/17
//
//   Summary:  

module class_hbkt_cmp
#(
    HASH_WIDTH = 13,
    PTR_WIDTH = 15
)
(
    // system
    input logic clk,
    input logic rst_n,

    // hashes
    input logic [ HASH_WIDTH - 1:0 ] h1k,
    input logic [ HASH_WIDTH - 1:0 ] h2k,

    // flopped hash table output
    input logic ht_vld,
    input logic [ 127:0 ] ht_t1_data,
    input logic [ 127:0 ] ht_t2_data,

    // each lookup in main data path consumes four clock cycles
    // strobe is valid on first cycle only; hit_miss indicates validity
    output logic pkt_strobe,
    output logic pkt_err,
    output logic ptr_hit_miss,
    output logic [ PTR_WIDTH - 1:0 ] ptr
);

// =======================================================================
// Declarations & Parameters

localparam HASH_MASK = 2**HASH_WIDTH - 1;
localparam PTR_MASK = 2**PTR_WIDTH - 1;

logic [ HASH_WIDTH - 1:0 ] t1_hashes [ 4 ];
logic [ PTR_WIDTH - 1:0 ] t1_ptrs [ 4 ];
logic [ HASH_WIDTH - 1:0 ] t2_hashes [ 4 ];
logic [ PTR_WIDTH - 1:0 ] t2_ptrs [ 4 ];

logic [ PTR_WIDTH - 1:0 ] all_ptrs_q[ 8 ];
logic [ PTR_WIDTH - 1:0 ] all_ptrs_qq[ 8 ];
logic [ PTR_WIDTH - 1:0 ] all_ptrs_qqq[ 8 ];
logic [ PTR_WIDTH - 1:0 ] all_ptrs_qqqq[ 8 ];
logic [ PTR_WIDTH - 1:0 ] all_ptrs_qqqqq[ 8 ];

// { t2w3, t2w2, t2w1, t2w0, t1w3, t1w2, t1w1, t1w0 }
logic [ 7:0 ] match_vector_q;
logic [ 7:0 ] match_vector_qq;
logic [ 7:0 ] match_vector_qqq;
logic [ 7:0 ] match_vector_qqqq;
logic [ 7:0 ] match_vector_qqqqq;

logic [ 7:0 ] mask_vector_0;
logic [ 7:0 ] mask_vector_1;
logic [ 7:0 ] mask_vector_2;
logic [ 7:0 ] mask_vector_3;
logic [ 7:0 ] mask_vector_4;

logic [ 7:0 ] masked_match_vect_0;
logic [ 7:0 ] masked_match_vect_1;
logic [ 7:0 ] masked_match_vect_2;
logic [ 7:0 ] masked_match_vect_3;
logic [ 7:0 ] masked_match_vect_4;

logic hit_miss_0_c;
logic hit_miss_1_c;
logic hit_miss_2_c;
logic hit_miss_3_c;
logic hit_miss_4_c;

logic [ 2:0 ] winner_0_c;
logic [ 2:0 ] winner_1_c;
logic [ 2:0 ] winner_2_c;
logic [ 2:0 ] winner_3_c;
logic [ 2:0 ] winner_4_c;

logic hit_miss_0_q;
logic hit_miss_1_q;
logic hit_miss_2_q;
logic hit_miss_3_q;
logic hit_miss_4_q;

logic [ 2:0 ] winner_0_q;
logic [ 2:0 ] winner_1_q;
logic [ 2:0 ] winner_2_q;
logic [ 2:0 ] winner_3_q;
logic [ 2:0 ] winner_4_q;

logic ht_vld_q;
logic ht_vld_qq;
logic ht_vld_qqq;
logic ht_vld_qqqq;
logic ht_vld_qqqqq;

// =======================================================================
// Combinational Logic

// the hashes and pointers are stored in 32-bit words as, for example,
// { 1'b0, 15'dpointer, 3'b000, 13'dhash }
always_comb
    for ( int i = 0; i < 4; i++ )
    begin
        t1_hashes[ i ] = ht_t1_data[ i*32 +: HASH_WIDTH ];
        t1_ptrs[ i ] = ht_t1_data[ i*32 + 16 +: PTR_WIDTH ];
        t2_hashes[ i ] = ht_t2_data[ i*32 +: HASH_WIDTH ];
        t2_ptrs[ i ] = ht_t2_data[ i*32 + 16 +: PTR_WIDTH ];
    end

// valid during ht_vld_q
assign mask_vector_0 = 8'hff;    
assign masked_match_vect_0 = match_vector_q & mask_vector_0;
assign { hit_miss_0_c, winner_0_c } = ffs( masked_match_vect_0 );

// valid during ht_vld_qq
assign mask_vector_1 = make_mask( winner_0_q );
assign masked_match_vect_1 = match_vector_qq & mask_vector_1;
assign { hit_miss_1_c, winner_1_c } = ffs( masked_match_vect_1 );

// valid during ht_vld_qqq
assign mask_vector_2 = make_mask( winner_1_q );
assign masked_match_vect_2 = match_vector_qqq & mask_vector_2;
assign { hit_miss_2_c, winner_2_c } = ffs( masked_match_vect_2 );

// valid during ht_vld_qqqq
assign mask_vector_3 = make_mask( winner_2_q );
assign masked_match_vect_3 = match_vector_qqqq & mask_vector_3;
assign { hit_miss_3_c, winner_3_c } = ffs( masked_match_vect_3 );

// valid during ht_vld_qqqqq
assign mask_vector_4 = make_mask( winner_3_q );
assign masked_match_vect_4 = match_vector_qqqqq & mask_vector_4;
assign { hit_miss_4_c, winner_4_c } = ffs( masked_match_vect_4 );

// =======================================================================
// Registered Logic

// Register:  pkt_strobe
//
// Always asserted one cycle for each request (on the first cycle of the
// output).

always_ff @( posedge clk )
    if ( !rst_n )
        pkt_strobe <= 1'b0;

    else if ( ht_vld_qq )
        pkt_strobe <= 1'b1;

    else
        pkt_strobe <= 1'b0;

// Register:  pkt_err
//
// If more than four hashes match, the error signal is asserted on the
// last cycle of the group. Note this is based off FFS combinational
// output to keep it conincident with the last cycle in the group.

always_ff @( posedge clk )
    if ( !rst_n )
        pkt_err <= 1'b0;

    else if ( ht_vld_qqqqq && hit_miss_4_q )
        pkt_err <= 1'b1;

    else
        pkt_err <= 1'b0;

// Register:  ptr
// Register:  ptr_hit_miss
//
// The pointer that is associated with a matched hash.  Typically, only 1
// will match and this will be outputed coincent with pkt_strobe.  If up 
// to three others are valid, they will appear consecutively on this bus
// after the first.

always_ff @( posedge clk )
    if ( !rst_n )
    begin
        ptr <= '0;
        ptr_hit_miss <= 1'b0;
    end

    else if ( ht_vld_qq && hit_miss_0_q )
    begin
        ptr <= all_ptrs_qq[ winner_0_q ];
        ptr_hit_miss <= 1'b1;
    end

    else if ( ht_vld_qqq && hit_miss_1_q )
    begin
        ptr <= all_ptrs_qqq[ winner_1_q ];
        ptr_hit_miss <= 1'b1;
    end

    else if ( ht_vld_qqqq && hit_miss_2_q )
    begin
        ptr <= all_ptrs_qqqq[ winner_2_q ];
        ptr_hit_miss <= 1'b1;
    end

    else if ( ht_vld_qqqqq && hit_miss_3_q )
    begin
        ptr <= all_ptrs_qqqqq[ winner_3_q ];
        ptr_hit_miss <= 1'b1;
    end

    else
    begin
        ptr <= '0;
        ptr_hit_miss <= 1'b0;
    end

// Register:  all_ptrs_q

always_ff @( posedge clk )
    if ( !rst_n )
        all_ptrs_q <= '{ default: '0 };

    else if ( ht_vld )
        all_ptrs_q <= { t2_ptrs, t1_ptrs };

// Register:  all_ptrs_qq
// Register:  all_ptrs_qqq
// Register:  all_ptrs_qqqq
// Register:  all_ptrs_qqqqq

always_ff @( posedge clk )
    if ( !rst_n )
    begin
        all_ptrs_qq <= '{ default: '0 };
        all_ptrs_qqq <= '{ default: '0 };
        all_ptrs_qqqq <= '{ default: '0 };
        all_ptrs_qqqqq <= '{ default: '0 };
    end

    else
    begin
        all_ptrs_qq <= all_ptrs_q;
        all_ptrs_qqq <= all_ptrs_qq;
        all_ptrs_qqqq <= all_ptrs_qqq;
        all_ptrs_qqqqq <= all_ptrs_qqqq;
    end

// Register:  match_vector_q
//
// An 8-bit vector indicating which hashes matched in T1 and T2.  This will
// be pipelined to allow 4-cycle performance for four grants to value memory
// in addition to error checking.

always_ff @( posedge clk )
    if ( !rst_n )
        match_vector_q <= 8'd0;

    else if ( ht_vld )
        for ( int i = 0; i < 4; i++ )
        begin
            match_vector_q[ i ] = t1_hashes[ i ] == h2k;
            match_vector_q[ i + 4 ] = t2_hashes[ i ] == h1k;
        end

    else
        match_vector_q <= 8'd0;

// Register:  ht_vld_q
// Register:  ht_vld_qq
// Register:  ht_vld_qqq
// Register:  ht_vld_qqqq
// Register:  ht_vld_qqqqq
//
// Pipelined valid signals that line up with match_vector_q* signals.

always_ff @( posedge clk )
    if ( !rst_n )
    begin
        ht_vld_q <= 1'b0;
        ht_vld_qq <= 1'b0;
        ht_vld_qqq <= 1'b0;
        ht_vld_qqqq <= 1'b0;
        ht_vld_qqqqq <= 1'b0;
    end

    else
    begin
        ht_vld_q <= ht_vld;
        ht_vld_qq <= ht_vld_q;
        ht_vld_qqq <= ht_vld_qq;
        ht_vld_qqqq <= ht_vld_qqq;
        ht_vld_qqqqq <= ht_vld_qqqq;
    end

// Register:  hit_miss_0_q
// Register:  winner_0_q
//
// FPGAs... flopping everything...

always_ff @( posedge clk )
    if ( !rst_n )
    begin
        hit_miss_0_q <= 1'b0;
        winner_0_q <= 4'd0;
    end

    else if ( ht_vld_q )
    begin
        hit_miss_0_q <= hit_miss_0_c;
        winner_0_q <= winner_0_c;
    end

// Register:  hit_miss_1_q
// Register:  winner_1_q
//
// FPGAs... flopping everything...

always_ff @( posedge clk )
    if ( !rst_n )
    begin
        hit_miss_1_q <= 1'b0;
        winner_1_q <= 4'd0;
    end

    else if ( ht_vld_qq )
    begin
        hit_miss_1_q <= hit_miss_1_c;
        winner_1_q <= winner_1_c;
    end

// Register:  hit_miss_2_q
// Register:  winner_2_q
//
// FPGAs... flopping everything...

always_ff @( posedge clk )
    if ( !rst_n )
    begin
        hit_miss_2_q <= 1'b0;
        winner_2_q <= 4'd0;
    end

    else if ( ht_vld_qqq )
    begin
        hit_miss_2_q <= hit_miss_2_c;
        winner_2_q <= winner_2_c;
    end

// Register:  hit_miss_3_q
// Register:  winner_3_q
//
// FPGAs... flopping everything...

always_ff @( posedge clk )
    if ( !rst_n )
    begin
        hit_miss_3_q <= 1'b0;
        winner_3_q <= 4'd0;
    end

    else if ( ht_vld_qqqq )
    begin
        hit_miss_3_q <= hit_miss_3_c;
        winner_3_q <= winner_3_c;
    end

// Register:  hit_miss_4_q

always_ff @( posedge clk )
    if ( !rst_n )
        hit_miss_4_q <= 1'b0;

    else
        hit_miss_4_q <= hit_miss_4_c;

// Register:  match_vector_qq
// Register:  match_vector_qqq
// Register:  match_vector_qqqq
// Register:  match_vector_qqqqq
//
// Pipelined versions of match vector so that each FFS stage has its own copy.

always_ff @( posedge clk )
    if ( !rst_n )
    begin
        match_vector_qq <= 8'd0;
        match_vector_qqq <= 8'd0;
        match_vector_qqqq <= 8'd0;
        match_vector_qqqqq <= 8'd0;
    end
    
    else
    begin
        match_vector_qq <= match_vector_q;
        match_vector_qqq <= match_vector_qq;
        match_vector_qqqq <= match_vector_qqq;
        match_vector_qqqqq <= match_vector_qqqq;
    end

// =======================================================================
// Functions

// Function: ffs
//
// Returns the first set bit starting with the least-significant bit.  Format
// for return is { vld, location[ 2:0 ] }

function automatic logic [ 3:0 ] ffs( input logic [ 7:0 ] vector );

    logic vld;
    logic [ 2:0 ] location;

    vld = 1'b0;
    location = 3'b000;

    for ( int i = 7; i >= 0; i-- )
        if ( vector[ i ] == 1 )
        begin
            vld = 1'b1;
            location = i[ 2:0 ];
        end

    return( { vld, location } );

endfunction

// Function:  make_mask
//
// Returns a vector of contiguous 1s from the MSB down to index+1.  All bits
// from index to [ 0 ] are 0.  Index values 0..7 are supported.  Any other
// index returns 0.

function automatic logic [ 7:0 ] make_mask( input logic [ 2:0 ] index );

    logic [ 7:0 ] mask;

    case( index )
        3'd0:  mask = 8'b1111_1110;
        3'd1:  mask = 8'b1111_1100;
        3'd2:  mask = 8'b1111_1000;
        3'd3:  mask = 8'b1111_0000;
        3'd4:  mask = 8'b1110_0000;
        3'd5:  mask = 8'b1100_0000;
        3'd6:  mask = 8'b1000_0000;
        default:  mask = 8'b0000_0000;
    endcase

    return( mask );

endfunction

endmodule
