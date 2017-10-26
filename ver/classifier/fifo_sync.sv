module fifo_sync
#(
    parameter DWIDTH = 24,
    parameter DEPTH = 256,
    parameter HEADROOM = 6,

    localparam AWIDTH = $clog2( DEPTH )
)
(
    input logic clk,
    input logic rst_n,
    
    input logic push,
    input logic [ DWIDTH - 1:0 ] data_in,
    output logic full,
    output logic alFull,
    
    input logic pop,
    output logic vld,
    output logic [ DWIDTH - 1:0 ] data_out,
    output logic empty
);
  
// =======================================================================
// Declarations & Parameters

localparam CW = AWIDTH + 1;
  
logic [ CW - 1:0 ] cnt;
logic [ DWIDTH - 1:0 ] rd_data;
logic [ DWIDTH - 1:0 ] wr_data;
logic wen;
logic wen_q;
logic ren;
logic [ AWIDTH - 1:0 ] wr_addr;
logic [ AWIDTH - 1:0 ] rd_addr;
logic [ AWIDTH - 1:0 ] rd_addr_q;
logic [ AWIDTH - 1:0 ] rd_addr_c;

// =======================================================================
// Combinational Logic

// only pop a non-empty FIFO... note that user may assert pop without regard
// to empty.  Data will be should be sampled only when pop and !empty are
// asserted together i.e., pop && vld
assign ren = pop && !empty;

assign data_out = rd_data;

// user samples data when pop && vld are both true... user drives pop, FIFO
// logic determines vld here
assign vld = !empty;
  
// the combinational version of the read address is used to immediately
// change the address into memory on a pop since there's a one-cycle delay
// to get the data out
assign rd_addr_c = rd_addr_q + 'd1;

// this is the signal into memory; the mux ensures that the next read 
// data is available on the next cycle
assign rd_addr = ren ? rd_addr_c : rd_addr_q;
  
// =======================================================================
// Registered Logic

// Register:  wen
//
// Only push data into a non-full FIFO to avoid corrupting data already
// in FIFO.  User must, however, avoid pushing data into an emtpy FIFO
// using the almost full signal, alFull

always_ff @( posedge clk )
    
    if ( !rst_n )
        wen <= 1'b0;
      
    else
        wen <= push && !full;
  
// Register:  wr_data
//
// push and data input are registered before going into memory for timing.

always_ff @( posedge clk )
    
    if ( !rst_n )
        wr_data <= {DWIDTH{1'b0}};
  
    else
        wr_data <= data_in;
  
// Register:  wen_q
//
// Use a delayed version of write enable for count calculations to ensure
// data is really in memory and it is, therefore, not popped out too early.

always_ff @( posedge clk )
    
    if ( !rst_n )
        wen_q <= 1'b0;
  
    else
        wen_q <= wen;
  
// Register: cnt 
//
// Track number of elements in the FIFO.

always_ff @( posedge clk )
  
    if ( !rst_n )
        cnt <= {CW{1'b0}};

    else if ( wen_q && ~ren )
        cnt <= cnt + 'd1;

    else if ( ~wen_q && ren )
        cnt <= cnt - 'd1;

// Register: empty
//
// Empty on the next clock when no elements and no write or one element
// and no write but a read.

always_ff @( posedge clk )
    
    if ( !rst_n )
        empty <= 1'b1;
  
    else if ( cnt == 'd0 && ~wen_q ||
              cnt == 'd1 && ~wen_q && ren )
        empty <= 1'b1;
  
    else
        empty <= 1'b0;
  
// Register: alFull
//
// External logic should use alFull to determine when to stop pushing into
// the FIFO.

always_ff @( posedge clk )
    
    if ( !rst_n )
        alFull <= 1'b0;
  
    else if ( cnt >= DEPTH - HEADROOM )
        alFull <= 1'b1;
  
    else
        alFull <= 1'b0;
  
// Register: full
//
// FIFO goes full if it's already full and there's no read or if it's one less
// than full and there's a write and no read.

always_ff @( posedge clk )
    
    if ( !rst_n )
        full <= 1'b0;
  
    else if ( cnt == DEPTH && ~ren ||
              cnt == DEPTH - 1 && wen_q && ~ren )
        full <= 1'b1;
  
    else
        full <= 1'b0;
  
// Register:  wr_addr
//
// Write address into memory.

always_ff @( posedge clk )
    
    if ( !rst_n )
        wr_addr <= {AWIDTH{1'b0}};
  
    else if ( wen )
        wr_addr <= wr_addr + 'd1;
  
// Register:  red_addr
//
// Since there's a one-clock read latency through memory, this signal is muxed
// with the combination version.  When the data is popped from the FIFO, the
// address has to change in the same clock cycle to ensure the new data is
// available on the next clock cycle.

always_ff @( posedge clk )
    
    if ( !rst_n )
        rd_addr_q <= {AWIDTH{1'b0}};
  
    else if ( ren )
        rd_addr_q <= rd_addr_c;
  
// =======================================================================
// Module Instantiations

ram_sdp_one_clock
#(
    .DWIDTH( DWIDTH ),
    .DEPTH( DEPTH )
)
u_ram2p
(
    .clk( clk ),
    .ena( 1'b1 ),
    .enb( 1'b1 ),
    .wea( wen ),
    .addra( wr_addr ),
    .addrb( rd_addr ),
    .dia( wr_data ),
    .dob( rd_data )
);
  
endmodule
