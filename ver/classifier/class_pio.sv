// (c) 2017 Bayware, Inc.
//
//   Project: Mackinac
//   Module:  class_pio.sv
//   Owner:   G Walter
//   Date:    10/03/17
//
//   Summary:  Logic for all register and memory access via PIO.

module class_pio
    import class_pkg::*;
(
    input logic clk,
    input logic rst_n,

    input logic clk_div,

    input logic [ PIO_NBITS - 1:0 ] reg_addr,
    input logic [ PIO_NBITS - 1:0 ] reg_din,
    input logic reg_rd,
    input logic reg_wr,
    input logic mem_bs,
    input logic reg_bs,

    output logic pio_ack,
    output logic pio_rvalid,
    output logic pio_error,
    output logic pio_invld,
    output logic [ PIO_NBITS - 1:0 ] pio_rdata,

    output logic pio_mem_req_value,
    input logic mem_pio_ack_value,
    input logic [ VAL_MEM_WIDTH - 1:0 ] mem_dout_value,
    output logic [ VAL_MEM_WIDTH - 1:0 ] pio_value_din,

    output logic pio_mem_req_hasht1,
    input logic mem_pio_ack_hasht1,
    input logic [ PIO_NBITS - 1:0 ] mem_dout_hasht1,

    output logic pio_mem_req_hasht2,
    input logic mem_pio_ack_hasht2,
    input logic [ PIO_NBITS - 1:0 ] mem_dout_hasht2,

    output logic pio_mem_rd_wr,
    output logic [ CLASSIFIER_PIO_MEM_ADDR_WIDTH - 1:0 ] pio_mem_addr,
    output logic [ PIO_NBITS - 1:0 ] pio_mem_din
);

// =======================================================================
// Declarations & Parameters

logic [ 7:0 ] register_sel;
logic [ 4:0 ] memory_sel;
logic [ 3:0 ] memory_value_wd_sel;
logic memory_value_rd_first_wd;
logic memory_value_wr_last_wd;
logic mem_pio_ack;
logic mem_wr_stretch;
logic mem_rd_stretch;
logic mem_rd_value_hold_regs;
logic mem_wr_value_hold_regs;
logic pio_mem_req_reserved;
logic mem_pio_ack_value_stretch;
logic mem_pio_ack_hasht1_stretch;
logic mem_pio_ack_hasht2_stretch;
logic [ 31:0 ] mem_dout_hasht1_stretch;
logic [ 31:0 ] mem_dout_hasht2_stretch;
logic [ 275:0 ] mem_dout_value_stretch;
logic [ 31:0 ] reg_rd_data;
logic [ 31:0 ] mem_value_hold_regs_data;
logic reg0_ex_wr;
logic reg1_ex_wr;
logic reg_wr_invalid;
logic reg_rd_invalid;
logic mem_rd_value_hold_regs_stretch;
logic mem_wr_value_hold_regs_stretch;
logic reg_rd_stretch;
logic reg_wr_stretch;
logic pio_reg_req_reserved_stretch;
logic pio_mem_req_reserved_stretch;
logic mem_pio_ack_reserved;
logic [ 31:0 ] reg0_ex;
logic [ 31:0 ] reg1_ex;

// holding registers:  Value Memory ONLY
// for software write... address words 0..8; flushes at word 15
logic [ 31:0 ] hold_regs_ld_wr[ 0:8 ];
// for software read... address words 1..8; word 0 not stored
logic [ 31:0 ] hold_regs_ld_rd[ 1:8 ];

// =======================================================================
// Combinational Logic

assign register_sel = reg_addr[ 7:0 ];
assign memory_sel = reg_addr[ 21:17 ];
assign memory_value_wd_sel = reg_addr[ 5:2 ];
assign memory_value_rd_first_wd = memory_value_wd_sel == 4'd0 && reg_rd;
assign memory_value_wr_last_wd = memory_value_wd_sel == 4'd15 && reg_wr;
assign mem_pio_ack = mem_pio_ack_value || mem_pio_ack_hasht1 || mem_pio_ack_hasht2 ||
    mem_pio_ack_reserved;

assign mem_wr_stretch = ( mem_pio_ack_value_stretch || mem_pio_ack_hasht1_stretch ||
    mem_pio_ack_hasht2_stretch ) && pio_mem_rd_wr == WR;
assign mem_rd_stretch = ( mem_pio_ack_value_stretch || mem_pio_ack_hasht1_stretch ||
    mem_pio_ack_hasht2_stretch ) && pio_mem_rd_wr == RD;

// value memory read to words other than 0 results in holding regs
assign mem_rd_value_hold_regs = mem_bs && reg_rd && ~reg_addr[ 21 ] && reg_addr[ 5:2 ] != 4'd0;
// value memory write to words other than 15 results in holding or fake regs
assign mem_wr_value_hold_regs = mem_bs && reg_wr && ~reg_addr[ 21 ] && reg_addr[ 5:2 ] != 4'd15;

// =======================================================================
// Registered Logic

// Register:  pio_mem_req_value
// Register:  pio_mem_req_hasht1
// Register:  pio_mem_req_hasht2
always_ff @( posedge clk )
    if ( !rst_n )
    begin
        pio_mem_req_value <= 1'b0;
        pio_mem_req_hasht1 <= 1'b0;
        pio_mem_req_hasht2 <= 1'b0;
        pio_mem_req_reserved <= 1'b0;
    end

    else if ( mem_bs && ( reg_wr || reg_rd ) )
    begin
        // defaults
        pio_mem_req_value <= 1'b0;
        pio_mem_req_hasht1 <= 1'b0;
        pio_mem_req_hasht2 <= 1'b0;
        pio_mem_req_reserved <= 1'b0;

        case ( memory_sel ) inside
            5'b0????:  pio_mem_req_value <= memory_value_rd_first_wd || memory_value_wr_last_wd;
            5'b10000:  pio_mem_req_hasht1 <= 1'b1;
            5'b10001:  pio_mem_req_hasht2 <= 1'b1;
            default: pio_mem_req_reserved <= 1'b1;
        endcase
    end

    else if ( mem_pio_ack )
    begin
        pio_mem_req_value <= 1'b0;
        pio_mem_req_hasht1 <= 1'b0;
        pio_mem_req_hasht2 <= 1'b0;
        pio_mem_req_reserved <= 1'b0;
    end

// Register:  hold_regs_ld_rd[ 1:8 ]
//
// On a software read, words 1..8 are loaded into holding registers from the
// memory. Word 0 is immediately returned and not stored.
always_ff @( posedge clk )
    if ( !rst_n )
        hold_regs_ld_rd <= '{ default: '0 };

    else if ( pio_mem_req_value && pio_mem_rd_wr && pio_mem_addr[ 5:2 ] == 4'd0 && mem_pio_ack_value )
    begin
        for ( int i = 1; i < 8; i = i + 1 )
            hold_regs_ld_rd[ i ] <= mem_dout_value[ 276 - i*32 - 1 -: 32 ];

        hold_regs_ld_rd[ 8 ] <= { mem_dout_value[ 19:0 ], 12'd0 };
    end

// Register:  hold_regs_ld_wr[ 0:8 ]
//
// On a software write, words 0..8 are loaded into holding registers.  When
// software writes to word 15, all holding registers are flushed to memory.
always_ff @( posedge clk )
    if ( !rst_n )
        hold_regs_ld_wr <= '{ default: '0 };

    // selects Value memory
    else if ( mem_bs && reg_wr && reg_addr[ 21 ] == 1'b0 )
        for ( int i = 0; i < 9; i = i + 1 )
            if ( memory_value_wd_sel == i )
                hold_regs_ld_wr[ i ] <= reg_din;

// Register:  pio_mem_rd_wr
always_ff @( posedge clk )
    if ( !rst_n )
        pio_mem_rd_wr <= 1'b0;

    else if ( mem_bs && reg_wr )
        pio_mem_rd_wr <= WR;

    else if ( mem_bs && reg_rd )
        pio_mem_rd_wr <= RD;

// Register:  pio_mem_addr
always_ff @( posedge clk )
    if ( !rst_n )
        pio_mem_addr <= '0;

    else
        pio_mem_addr <= reg_addr[ CLASSIFIER_PIO_MEM_ADDR_WIDTH - 1:0 ];

// Register:  pio_mem_din
always_ff @( posedge clk )
    if ( !rst_n )
        pio_mem_din <= '0;

    else
        pio_mem_din <= reg_din;

// Register:  pio_value_din
//
// Value memory write data is formed from holding registers
always_ff @( posedge clk )
    if ( !rst_n )
        pio_value_din <= '0;

    else
        for ( int i = 0; i < 9; i++ )
            pio_value_din[ i*32 +: 32 ] <= hold_regs_ld_wr[ i ];

// Register:  mem_pio_ack_value_stretch
always_ff @( posedge clk )
    if ( !rst_n )
        mem_pio_ack_value_stretch <= 1'b0;

    else if ( clk_div && mem_pio_ack_value_stretch )
        mem_pio_ack_value_stretch <= 1'b0;

    else if ( mem_pio_ack_value )
        mem_pio_ack_value_stretch <= 1'b1;

// Register:  mem_pio_ack_hasht1_stretch
always_ff @( posedge clk )
    if ( !rst_n )
        mem_pio_ack_hasht1_stretch <= 1'b0;

    else if ( clk_div && mem_pio_ack_hasht1_stretch )
        mem_pio_ack_hasht1_stretch <= 1'b0;

    else if ( mem_pio_ack_hasht1 )
        mem_pio_ack_hasht1_stretch <= 1'b1;

// Register:  mem_pio_ack_hasht2_stretch
always_ff @( posedge clk )
    if ( !rst_n )
        mem_pio_ack_hasht2_stretch <= 1'b0;

    else if ( clk_div && mem_pio_ack_hasht2_stretch )
        mem_pio_ack_hasht2_stretch <= 1'b0;

    else if ( mem_pio_ack_hasht2 )
        mem_pio_ack_hasht2_stretch <= 1'b1;

// Register:  mem_dout_hasht1_stretch
always_ff @( posedge clk )
    if ( !rst_n )
        mem_dout_hasht1_stretch <= '0;

    else if ( mem_pio_ack_hasht1 && pio_mem_rd_wr == RD )
        mem_dout_hasht1_stretch <= mem_dout_hasht1;

    else if ( mem_rd_stretch && clk_div )
        mem_dout_hasht1_stretch <= '0;

// Register:  mem_dout_hasht2_stretch
always_ff @( posedge clk )
    if ( !rst_n )
        mem_dout_hasht2_stretch <= '0;

    else if ( mem_pio_ack_hasht2 && pio_mem_rd_wr == RD )
        mem_dout_hasht2_stretch <= mem_dout_hasht2;

    else if ( mem_rd_stretch && clk_div )
        mem_dout_hasht2_stretch <= '0;

// Register:  mem_dout_value_stretch
always_ff @( posedge clk )
    if ( !rst_n )
        mem_dout_value_stretch <= '0;

    else if ( mem_pio_ack_value && pio_mem_rd_wr == RD )
        mem_dout_value_stretch <= mem_dout_value;

    else if ( mem_rd_stretch && clk_div )
        mem_dout_value_stretch <= '0;

// Register:  pio_rdata
always_ff @( posedge clk )
    if ( !rst_n )
        pio_rdata <= '0;

    else if ( reg_rd_stretch )
        pio_rdata <= reg_rd_data;

    else if ( mem_rd_value_hold_regs_stretch )
        pio_rdata <= mem_value_hold_regs_data;

    else if ( mem_pio_ack_hasht1_stretch && pio_mem_rd_wr == RD )
        pio_rdata <= mem_dout_hasht1_stretch;

    else if ( mem_pio_ack_hasht2_stretch && pio_mem_rd_wr == RD )
        pio_rdata <= mem_dout_hasht2_stretch;

    // only Word 0 comes directly from value memory 
    else if ( mem_pio_ack_value_stretch && pio_mem_rd_wr == RD )
        pio_rdata <= mem_dout_value_stretch[ 276 - 1 -: 32 ];

// Register:  reg_rd_data
always_ff @( posedge clk )
    if ( !rst_n )
    begin
        reg_rd_data <= '0;
        reg_rd_invalid <= 1'b0;
    end

    else if ( reg_rd && reg_bs )
    begin
        reg_rd_invalid <= 1'b0;
        case ( register_sel ) inside
            8'h00: reg_rd_data <= reg0_ex;
            8'h04: reg_rd_data <= reg1_ex;
            default:  begin reg_rd_data <= '0; reg_rd_invalid <= 1'b1; end
        endcase
    end

    // clearing... prob not necessary, but for debug
    else if ( pio_rvalid )
    begin
        reg_rd_invalid <= 1'b0;
        reg_rd_data <= '0;
    end

// Register:  mem_value_hold_regs_data
//
// Value memory uses holding registers.  Word 0 is returned immediately; the
// others come from the flops.
always_ff @( posedge clk )
    if ( !rst_n )
        mem_value_hold_regs_data <= '0;

    else if ( mem_rd_value_hold_regs )
        case ( reg_addr[ 5:2 ] ) inside
            1:  mem_value_hold_regs_data <= hold_regs_ld_rd[ 1 ];
            2:  mem_value_hold_regs_data <= hold_regs_ld_rd[ 2 ];
            3:  mem_value_hold_regs_data <= hold_regs_ld_rd[ 3 ];
            4:  mem_value_hold_regs_data <= hold_regs_ld_rd[ 4 ];
            5:  mem_value_hold_regs_data <= hold_regs_ld_rd[ 5 ];
            6:  mem_value_hold_regs_data <= hold_regs_ld_rd[ 6 ];
            7:  mem_value_hold_regs_data <= hold_regs_ld_rd[ 7 ];
            8:  mem_value_hold_regs_data <= hold_regs_ld_rd[ 8 ];
            default: mem_value_hold_regs_data <= '0;
        endcase

// Register:  reg0_ex_wr
// Register:  reg1_ex_wr
// Register:  reg_wr_invalid
//
// Address mux for register writes, including dummy write.
always_ff @( posedge clk )
    if ( !rst_n )
    begin
        reg0_ex_wr <= 1'b0;
        reg1_ex_wr <= 1'b0;
        reg_wr_invalid <= 1'b0;
    end

    // register access to this block
    else if ( reg_wr && reg_bs )
    begin
        // defaults
        reg0_ex_wr <= 1'b0;
        reg1_ex_wr <= 1'b0;
        reg_wr_invalid <= 1'b0;

        // decode
        case ( register_sel ) inside
            8'h00:  reg0_ex_wr <= 1'b1;
            8'h04:  reg1_ex_wr <= 1'b1;
            default:  reg_wr_invalid <= 1'b1;
        endcase
    end
    else
    begin
        reg0_ex_wr <= 1'b0;
        reg1_ex_wr <= 1'b0;
        reg_wr_invalid <= 1'b0;
    end

// Register:  mem_rd_value_hold_regs_stretch
always_ff @( posedge clk )
    if ( !rst_n )
        mem_rd_value_hold_regs_stretch <= 1'b0;

    else if ( mem_rd_value_hold_regs )
        mem_rd_value_hold_regs_stretch <= 1'b1;

    else if ( mem_rd_value_hold_regs_stretch && clk_div )
        mem_rd_value_hold_regs_stretch <= 1'b0;

// Register:  mem_wr_value_hold_regs_stretch
always_ff @( posedge clk )
    if ( !rst_n )
        mem_wr_value_hold_regs_stretch <= 1'b0;

    else if ( mem_wr_value_hold_regs )
        mem_wr_value_hold_regs_stretch <= 1'b1;

    else if ( mem_wr_value_hold_regs_stretch && clk_div )
        mem_wr_value_hold_regs_stretch <= 1'b0;

// Register:  reg_rd_stretch
always_ff @( posedge clk )
    if ( !rst_n )
        reg_rd_stretch <= '0;

    else if ( reg_rd && reg_bs )
        reg_rd_stretch <= 1'b1;

    else if ( reg_rd_stretch && clk_div )
        reg_rd_stretch <= 1'b0;

// Register:  pio_rvalid
always_ff @( posedge clk )
    if ( !rst_n )
        pio_rvalid <= 1'b0;

    else if ( ( reg_rd_stretch || mem_rd_stretch || mem_rd_value_hold_regs_stretch ) && clk_div )
        pio_rvalid <= 1'b1;

    else if ( pio_rvalid && clk_div )
        pio_rvalid <= 1'b0;

// Register:  reg_wr_stretch
always_ff @( posedge clk )
    if ( !rst_n )
        reg_wr_stretch <= 1'b0;

    else if ( reg_wr && reg_bs )
        reg_wr_stretch <= 1'b1;

    else if ( reg_wr_stretch && clk_div )
        reg_wr_stretch <= 1'b0;

// Register:  pio_ack
always_ff @( posedge clk )
    if ( !rst_n )
        pio_ack <= 1'b0;

    else if ( ( reg_wr_stretch || mem_wr_stretch || mem_wr_value_hold_regs_stretch ) && clk_div )
        pio_ack <= 1'b1;

    else if ( pio_ack && clk_div )
        pio_ack <= 1'b0;

// Register:  reg0_ex
always_ff @( posedge clk )
    if ( !rst_n )
        reg0_ex <= '0;

    else if ( reg0_ex_wr )
        reg0_ex <= reg_din;

// Register:  reg1_ex
always_ff @( posedge clk )
    if ( !rst_n )
        reg1_ex <= '0;

    else if ( reg1_ex_wr )
        reg1_ex <= reg_din;

// Register:  pio_reg_req_reserved_stretch
always_ff @( posedge clk )
    if ( !rst_n )
        pio_reg_req_reserved_stretch <= 1'b0;

    else if ( reg_wr_invalid || reg_rd_invalid )
        pio_reg_req_reserved_stretch <= 1'b1;

    else if ( pio_reg_req_reserved_stretch && clk_div )
        pio_reg_req_reserved_stretch <= 1'b0;

// Register:  pio_invld
// Asserted when software tries to access a non-existent address in reg or
// mem space.
always_ff @( posedge clk )
    if ( !rst_n )
        pio_invld <= 1'b0;

    else if ( pio_mem_req_reserved_stretch || pio_reg_req_reserved_stretch )
        pio_invld <= 1'b1;

    else if ( pio_invld && clk_div )
        pio_invld <= 1'b0;

// Register:  pio_mem_req_reserved_stretch
always_ff @( posedge clk )
    if ( !rst_n )
        pio_mem_req_reserved_stretch <= 1'b0;

    else if ( pio_mem_req_reserved )
        pio_mem_req_reserved_stretch <= 1'b1;

    else if ( pio_mem_req_reserved_stretch && clk_div )
        pio_mem_req_reserved_stretch <= 1'b0;

// Register:  mem_pio_ack_reserved
//
// Pseudo ack to acknowledge request to non-existent memory address.
always_ff @( posedge clk )
    if ( !rst_n )
        mem_pio_ack_reserved <= 1'b0;

    else if ( pio_mem_req_reserved )
        mem_pio_ack_reserved <= 1'b1;

    else
        mem_pio_ack_reserved <= 1'b0;

// =======================================================================
// Functions

endmodule

