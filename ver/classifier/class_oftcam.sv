// (c) 2017 Bayware, Inc.
//
//   Project: Mackinac
//   Module:  class_oftcam.sv
//   Owner:   G Walter
//   Date:    10/03/17
//
//   Summary:  This block takes in a key and does simultaneousy compare against
//   n entries then outputs ID associated with the lowest numbered entry found.
//   It indicates if multiple entries were found and if no entries were found.

module class_oftcam
    import class_pkg::*;
#(
    // DEPTH of this overflow TCAM itself
    parameter DEPTH = 8,
    parameter KEY_LEN = 276,

    // number of bits for FID/TID of whole table
    parameter VID_WIDTH = 15
)
(
    input logic clk,
    input logic rst_n,

    input logic key_vld,
    input logic [ KEY_LEN - 1:0 ] key,

    // static software register
    input logic [ VID_WIDTH - 1:0 ] base_vid,

    output logic rslt_vld,
    output logic [ VID_WIDTH - 1:0 ] rslt_vid,
    output logic rslt_hit_miss,
    output logic rslt_err,

    // read/write OF TCAM array
    input logic pio_oftcam_rd,
    input logic pio_oftcam_wr,
    input logic [ 15:0 ] pio_oftcam_addr,
    input logic [ 31:0 ] pio_oftcam_wrdata,
    output logic  oftcam_pio_ack,
    output logic [ 31:0 ] oftcam_pio_rddata
);

// =======================================================================
// Declarations & Parameters

localparam CNT_WIDTH = $clog2( DEPTH ) + 1;

logic [ DEPTH - 1:0 ] compare;
logic [ KEY_LEN - 1:0 ] tcam [ DEPTH ];

logic [ VID_WIDTH - 1:0 ] ffs_low_bit;
logic [ CNT_WIDTH - 1:0 ] cnt;
logic hit_miss;
logic err;

logic key_vld_q;
logic key_vld_qq;

// =======================================================================
// Combinational Logic

always_comb
begin
    cnt = '0;
    for ( int i = 0; i < DEPTH; i = i + 1 )
        cnt = cnt + 'd1;
end

// =======================================================================
// Registered Logic

// Register:  compare
always_ff @( posedge clk )
    if ( !rst_n )
        compare <= '0;

    else if ( key_vld )
        for ( int i = 0; i < DEPTH; i = i + 1 )
            compare[ i ] <= key == tcam[ i ];

// Register:  ffs_low_bit
always_ff @( posedge clk )
    if ( !rst_n )
        ffs_low_bit <= '0;

    else if ( key_vld )
    begin
        ffs_low_bit <= 'd0;
        hit_miss <= MISS;
    end

    else if ( key_vld_q )
        { hit_miss, ffs_low_bit } <= ffs( compare );

// Register: err
always_ff @( posedge clk )
    if ( !rst_n )
        err <= 1'b0;

    else if ( key_vld )
        err <= 1'b0;

    else if ( key_vld_q )
        err <= cnt != 'd0 && cnt != 'd1;

// Register: rslt_vld
// Register: rslt_vid
// Register: rslt_hit_miss
// Register: rslt_err
always_ff @( posedge clk )
    if ( !rst_n )
    begin
        rslt_vld <= 1'b0;
        rslt_vid <= '0;
        rslt_hit_miss <= 1'b0;
        rslt_err <= 1'b0;
    end

    else
        if ( key_vld_qq )
        begin
            rslt_vld <= 1'b1;
            rslt_vid <= ffs_low_bit + base_vid;
            rslt_hit_miss <= hit_miss;
            rslt_err <= err;
        end

        else
        begin
            rslt_vld <= 1'b0;
            rslt_vid <= '0;
            rslt_hit_miss <= MISS;
            rslt_err <= 1'b0;
        end

// Register:  key_vld_q
// Register:  key_vld_qq
always_ff @( posedge clk )
    if ( !rst_n )
    begin
        key_vld_q <= 1'b0;
        key_vld_qq <= 1'b0;
    end

    else
    begin
        key_vld_q <= key_vld;
        key_vld_qq <= key_vld_q;
    end

// Register:  oftcam_pio_rddata
always_ff @( posedge clk )
    if ( !rst_n )
        oftcam_pio_rddata <= '0;

    else if ( pio_oftcam_rd )
        oftcam_pio_rddata <= tcam[ pio_oftcam_addr ];

// =======================================================================
// Functions

// Function: ffs
//
// Returns the first set bit starting with the least-significant bit.  Format
// for return is { hit_miss, location[ VID_WIDTH - 1:0 ] }

function automatic logic [ VID_WIDTH:0 ] ffs( input logic [ DEPTH - 1:0 ] vector );

    logic hit_miss;
    logic [ VID_WIDTH - 1:0 ] location;

    hit_miss = MISS;
    location = '0;

    for ( int i = DEPTH - 1; i >= 0; i-- )
        if ( vector[ i ] == 'd1 )
        begin
            hit_miss = HIT;
            location = i[ VID_WIDTH - 1:0 ];
        end

    return( { hit_miss, location } );

endfunction

endmodule
