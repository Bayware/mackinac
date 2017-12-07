// (c) 2017 Bayware, Inc.
//
//   Project: Mackinac
//   Module:  classifier.sv
//   Owner:   G Walter
//   Date:    10/03/17
//
//   Summary:  Supports up to 100Gbps by doing main data path lookup on PortA
//   path once in four clock cycles.  Main LU data path key comes in three
//   consecutive clock cycles; back-to-back LUs must be at least four cycles
//   apart.
//       Port B is used for insert, remove, and software lookups.

module classifier
    import class_pkg::*;
#(
    parameter KEY_LEN = 276,
    parameter ITEMS = 32768,
    parameter BUS_WIDTH = 128,
    localparam VT_AWIDTH = $clog2( ITEMS )
)
(
    input logic clk,
    input logic rst_n,

    class_intf.class_ing clsmp
);

// =======================================================================
// Declarations & Parameters

// buckets per hash table, T1 and T2:  assumes 2x number of buckets than
// what are required in order to avoid collissions i.e., for 32k IDs, we
// only need 32k / 2 hash tables / 4 slots per table = 4k buckets; instead,
// use 8k buckets (13-bit address)
localparam HT_AWIDTH = $clog2( ITEMS / 2 / 4 * 2 );
localparam HT_DWIDTH = 128;
// localparam VT_DWIDTH = $ceil( KEY_LEN / 64 ) * 64; --Vivado support, but not Mentor?
localparam VT_DWIDTH = 320;
localparam KEY_FIFO_DEPTH = 32;
localparam [ VT_AWIDTH - 1:0 ] OFTCAM_DEPTH = 8;
// some number of pointers reserved for overflow; (FIXME upper IDs reserved
// for special purpose, see Wiki)
localparam [ VT_AWIDTH - 1:0 ] OFTCAM_BASE = 2**15 - OFTCAM_DEPTH;

logic [ KEY_LEN - 1:0 ] data_out_key_a;
logic [ KEY_LEN - 1:0 ] lu_key_full_q;

logic [ BUS_WIDTH - 1:0 ] lu_key_q;
logic [ BUS_WIDTH - 1:0 ] lu_key_hi;
logic [ BUS_WIDTH - 1:0 ] lu_key_mid;
logic lu_vld_q;
logic lu_vld_qq;
logic lu_vld_qqq;
logic lu_vld_qqqq;
logic [ HT_AWIDTH - 1:0 ] ht_t1_addra_q;
logic [ HT_AWIDTH - 1:0 ] ht_t1_addra_qq;
logic [ HT_AWIDTH - 1:0 ] ht_t1_addra_qqq;
logic [ HT_AWIDTH - 1:0 ] ht_t1_addra_qqqq;
logic [ HT_AWIDTH - 1:0 ] ht_t2_addra_q;
logic [ HT_AWIDTH - 1:0 ] ht_t2_addra_qq;
logic [ HT_AWIDTH - 1:0 ] ht_t2_addra_qqq;
logic [ HT_AWIDTH - 1:0 ] ht_t2_addra_qqqq;
logic hash_a_vld;
logic hash_a_vld_q;
logic hash_a_vld_qq;
logic hash_a_vld_qqq;
logic hash_a_vld_qqqq;
logic hash_b_vld;
logic [ HT_AWIDTH - 1:0 ] h1k_a;
logic [ HT_AWIDTH - 1:0 ] h2k_a;
logic [ HT_AWIDTH - 1:0 ] h1k_b;
logic [ HT_AWIDTH - 1:0 ] h2k_b;

logic hbkt_cmp_pkt_strobe_a;
logic hbkt_cmp_pkt_err_a;
logic hbkt_cmp_hit_miss_a;
logic [ VT_AWIDTH - 1:0 ] hbkt_cmp_ptr_a;
logic [ VT_AWIDTH - 1:0 ] hbkt_cmp_ptr_a_q;

logic [ HT_DWIDTH - 1:0 ] ht_t1_douta_q;
logic [ HT_DWIDTH - 1:0 ] ht_t2_douta_q;
logic [ HT_DWIDTH - 1:0 ] ht_t1_douta;
logic [ HT_DWIDTH - 1:0 ] ht_t2_douta;

logic [ VT_DWIDTH - 1:0 ] val_mem_douta;
logic [ KEY_LEN - 1:0 ] val_mem_douta_keyonly_q;

logic oftcam_rslt_vld;
logic [ VT_AWIDTH - 1:0 ] oftcam_rslt_vid;
logic oftcam_rslt_hit_miss;
logic oftcam_rslt_err;

logic [ PIO_NBITS - 1:0 ] reg_addr;
logic [ PIO_NBITS - 1:0 ] reg_din;
logic reg_rd;
logic reg_wr;
logic mem_bs;
logic reg_bs;

logic pio_mem_req_hasht1;
logic mem_pio_ack_hasht1;
logic [ PIO_NBITS - 1:0 ] mem_dout_hasht1;
logic pio_mem_req_hasht2;
logic mem_pio_ack_hasht2;
logic [ PIO_NBITS - 1:0 ] mem_dout_hasht2;
logic pio_mem_rd_wr;
logic [ CLASSIFIER_PIO_MEM_ADDR_WIDTH - 1:0 ] pio_mem_addr;
logic [ PIO_NBITS - 1:0 ] pio_mem_din;

logic pio_mem_req_value;
logic mem_pio_ack_value;
logic [ VAL_MEM_WIDTH - 1:0 ] mem_dout_value;
logic [ VAL_MEM_WIDTH - 1:0 ] pio_value_din;

logic pio_start;
logic pio_rw;
logic [ PIO_NBITS - 1:0 ] pio_addr_wdata;
logic clk_div;

// =======================================================================
// Combinational Logic

assign lu_push_key_a = lu_vld_qqqq;

// hbkt signal is high once per clock cycle and kicks off the value memory
// read cycle; use here to also pop original key from FIFO and maybe it's
// read around the time needed by value memory output; key also goes into
// overflow tcam
// FIXME:  need to line up key exiting FIFO and when it's needed in oftcam
// and value memory
assign pop_key_a = hbkt_cmp_pkt_strobe_a;

// =======================================================================
// Registered Logic

// Register:  lu_key_q
// Register:  lu_vld_q
// Register:  lu_vld_qq
// Register:  lu_vld_qqq
// Register:  lu_vld_qqqq
always_ff @( posedge clk )
    if ( !rst_n )
    begin
        lu_key_q <= '0;
        lu_vld_q <= 1'b0;
        lu_vld_qq <= 1'b0;
        lu_vld_qqq <= 1'b0;
        lu_vld_qqqq <= 1'b0;
    end

    else
    begin
        lu_key_q <= clsmp.lu_key;
        lu_vld_q <= clsmp.lu_vld;
        lu_vld_qq <= lu_vld_q;
        lu_vld_qqq <= lu_vld_qq;
        lu_vld_qqqq <= lu_vld_qqq;
    end

// Register:  lu_key_hi
//
// Aids in widening out the key for single-cycle push into FIFO.

always_ff @( posedge clk )
    if ( !rst_n )
        lu_key_hi <= '0;

    else if ( lu_vld_q )
        lu_key_hi <= lu_key_q;

// Register:  lu_key_mid
//
// Aids in widening out the key for single-cycle push into FIFO.

always_ff @( posedge clk )
    if ( !rst_n )
        lu_key_mid <= '0;

    else if ( lu_vld_qq )
        lu_key_mid <= lu_key_q;

// Register:  lu_key_full_q
//
// Full-width key for lookup port A.

always_ff @( posedge clk )
    if ( !rst_n )
        lu_key_full_q <= '0;

    else if ( lu_vld_qqq )
        lu_key_full_q <= { lu_key_hi, lu_key_mid, lu_key_q[ BUS_WIDTH - 1:BUS_WIDTH - 20 ] };

// Register:  ht_t1_addra_q
// Register:  ht_t2_addra_q
//
// Flop the address before passing into memory--may not be necessary
// for port A since it should always be "read" for lookup from main data.
// path.

always @( posedge clk )
    if ( !rst_n )
    begin
        ht_t1_addra_q <= '0;
        ht_t2_addra_q <= '0;
    end

    else if ( hash_a_vld )
    begin
        ht_t1_addra_q <= h1k_a;
        ht_t2_addra_q <= h2k_a;
    end

// Register:  ht_t1_douta_q
// Register:  ht_t2_douta_q
//
// Flop all data coming out of hash tables.  (Is this overkill if already
// several pipline stages in memory instance?)
//
// Avoiding reset flops here in data path per Xilinx.

always @( posedge clk )
begin
    ht_t1_douta_q <= ht_t1_douta;
    ht_t2_douta_q <= ht_t2_douta;
end

// Register:  hash_a_vld_q
// Register:  hash_a_vld_qq
// Register:  hash_a_vld_qqq
// Register:  hash_a_vld_qqqq
//
// From hash valid to flopped T1/T2 read data valid on port A.

always @( posedge clk )
    if ( !rst_n )
    begin
        hash_a_vld_q <= 1'b0;
        hash_a_vld_qq <= 1'b0;
        hash_a_vld_qqq <= 1'b0;
        hash_a_vld_qqqq <= 1'b0;
    end

    else
    begin
        hash_a_vld_q <= hash_a_vld;
        hash_a_vld_qq <= hash_a_vld_q;
        hash_a_vld_qqq <= hash_a_vld_qq;
        hash_a_vld_qqqq <= hash_a_vld_qqq;
    end

// Register:  ht_t2_addra_qq
// Register:  ht_t2_addra_qqq
// Register:  ht_t2_addra_qqqq
//
// Register:  ht_t1_addra_qq
// Register:  ht_t1_addra_qqq
// Register:  ht_t1_addra_qqqq

always_ff @( posedge clk )
    if ( !rst_n )
    begin
        ht_t2_addra_qq <= '0;
        ht_t2_addra_qqq <= '0;
        ht_t2_addra_qqqq <= '0;
        ht_t1_addra_qq <= '0;
        ht_t1_addra_qqq <= '0;
        ht_t1_addra_qqqq <= '0;
    end

    else
    begin
        ht_t2_addra_qq <= ht_t2_addra_q;
        ht_t2_addra_qqq <= ht_t2_addra_qq;
        ht_t2_addra_qqqq <= ht_t2_addra_qqq;
        ht_t1_addra_qq <= ht_t1_addra_q;
        ht_t1_addra_qqq <= ht_t1_addra_qq;
        ht_t1_addra_qqqq <= ht_t1_addra_qqq;
    end

// Register:  val_mem_douta_keyonly_q

always_ff @( posedge clk )
    val_mem_douta_keyonly_q <= val_mem_douta[ VT_DWIDTH - 1:VT_DWIDTH - KEY_LEN ];

// Register:  hbkt_cmp_ptr_a_q
//
// Flop again immediately before going into memory.  (Extra stage
// because might need mux between hbkt ptr gen stage and reading
// if arbitration for this port is necessary.)
always_ff @( posedge clk )
    if ( !rst_n )
        hbkt_cmp_ptr_a_q <= '0;

    else
        hbkt_cmp_ptr_a_q <= hbkt_cmp_ptr_a;

// =======================================================================
// Module Instantiations

// calculates hashes:  2 hashes for port A and 2 hashes for port B
class_hash_top
#(
    .BUS_WIDTH( BUS_WIDTH ),
    .HASH_WIDTH( HT_AWIDTH )
)
u_class_hash_top
(
    // system
    .clk( clk ),
    .rst_n( rst_n ),

    // port A signals
    .key_a( lu_key_q ),
    .key_a_start( lu_vld_q ),
    .hash_a_vld( hash_a_vld ),
    .h1k_a( h1k_a ),
    .h2k_a( h2k_a ),

    // port B signals
    .key_b( { BUS_WIDTH{ 1'b0 } } ),
    .key_b_start( 1'b0 ),
    .hash_b_vld( hash_b_vld ),
    .h1k_b( h1k_b ),
    .h2k_b( h2k_b )
);

class_hbkt_cmp
#(
    .HASH_WIDTH( HT_AWIDTH ),
    .PTR_WIDTH( VT_AWIDTH )
)
u_class_hbkt_cmp_a
(
    // system
    .clk( clk ),
    .rst_n( rst_n ),

    // hashes
    .h1k( ht_t1_addra_qqqq ),
    .h2k( ht_t2_addra_qqqq ),

    // flopped hash table output
    .ht_vld( hash_a_vld_qqqq ),
    .ht_t1_data( ht_t1_douta_q ),
    .ht_t2_data( ht_t2_douta_q ),

    // each lookup in main data path consumes clock cycles
    // strobe is valid on first cycle only; hit_miss is validity
    .pkt_strobe( hbkt_cmp_pkt_strobe_a ),
    .pkt_err( hbkt_cmp_pkt_err_a ),
    .ptr_hit_miss( hbkt_cmp_hit_miss_a ),
    .ptr( hbkt_cmp_ptr_a )
);

class_key_cmp
#(
    .KEY_LEN( KEY_LEN ),
    .VT_AWIDTH( VT_AWIDTH )
)
u_class_key_cmp_a
(
    .clk( clk ),
    .rst_n( rst_n ),

    // hbkt & val mem
    .pkt_strobe( hbkt_cmp_pkt_strobe_a ),
    .pkt_hbkt_err( hbkt_cmp_pkt_err_a ),
    .pkt_hbkt_hit_miss( hbkt_cmp_hit_miss_a ),
    .val_ptr( hbkt_cmp_ptr_a_q ),
    .key_orig( data_out_key_a  ),
    .val_mem_dout_q( val_mem_douta_keyonly_q ),

    // OF TCAM
    .oftcam_vld( oftcam_rslt_vld ),
    .oftcam_err( oftcam_rslt_err ),
    .oftcam_hit_miss( oftcam_rslt_hit_miss ),
    .tcam_ptr( oftcam_rslt_vid ),

    // final
    .final_vld( clsmp.lu_done ),
    .final_err( clsmp.lu_err ),
    .final_hit_miss( clsmp.lu_hit_miss ),
    .final_ptr( clsmp.lu_vid )
);

// Module:  u_fifo_sync_key_a
//
// The "a" port stores keys in this FIFO during the lookup process.  The FIFO
// is popped at such a time as the key can be used to lookup in the overflow
// TCAM and then used to compare against the keys coming out of the value
// memory to determine final match status.

fifo_sync
#(
    .DWIDTH( KEY_LEN ),
    .DEPTH( KEY_FIFO_DEPTH ),
    .HEADROOM( 6 )
)
u_fifo_sync_key_a
(
    .clk( clk ),
    .rst_n( rst_n ),
    
    .push( lu_push_key_a ),
    .data_in( lu_key_full_q ),
    .full(),
    .alFull(),
    
    .pop( pop_key_a ),
    .vld( vld_key_a ),
    .data_out( data_out_key_a ),
    .empty( empty_key_a )
);

// Module:  class_oftcam
//
// Holds n entries deep.  Uses FFs to do simultaneous compare and return VID
// from base offset.

class_oftcam
#(
    .DEPTH( OFTCAM_DEPTH ),
    .KEY_LEN( KEY_LEN ),
    .VID_WIDTH( VT_AWIDTH )
)
u_class_oftcam
(
    .clk( clk ),
    .rst_n( rst_n ),

    .key_vld( vld_key_a ),
    .key( data_out_key_a  ),

    .base_vid( OFTCAM_BASE ),
    .rslt_vld( oftcam_rslt_vld ),
    .rslt_vid( oftcam_rslt_vid ),
    .rslt_hit_miss( oftcam_rslt_hit_miss ),
    .rslt_err( oftcam_rslt_err ),

    .pio_oftcam_rd(),
    .pio_oftcam_wr(),
    .pio_oftcam_addr(),
    .pio_oftcam_wrdata(),
    .oftcam_pio_ack(),
    .oftcam_pio_rddata()
);

// pio2reg_bus
// standardized PIO convertor
pio2reg_bus
#(
    .BLOCK_ADDR_LSB( CLASSIFIER_BLOCK_ADDR_LSB ),
    .BLOCK_ADDR( CLASSIFIER_BLOCK_ADDR ),
    .REG_BLOCK_ADDR_LSB( CLASSIFIER_REG_BLOCK_ADDR_LSB ),
    .REG_BLOCK_ADDR( CLASSIFIER_REG_BLOCK_ADDR )
)
u_pio2reg_bus
(
    .clk( clk ),
    .rst_n( rst_n ),

    // from central PIO
    .pio_start,
    .pio_rw,
    .pio_addr_wdata,

    // locally generated
    .clk_div,

    // for local mem/reg access
    .reg_addr,
    .reg_din,
    .reg_rd,
    .reg_wr,
    .mem_bs,
    .reg_bs
);

// Arbitration for HASHT2
class_hasht_arb
#(
    // actual memory instance depth/width
    .AW( HT_AWIDTH ),
    .DW( HT_DWIDTH )
)
u_class_hasht_arb_2
(
    .clk,
    .rst_n,

    .req( pio_mem_req_hasht2 ),
    .rd_or_wr( pio_mem_rd_wr ),
    .addr( pio_mem_addr ),
    .wdata( pio_mem_din ),

    .ack( mem_pio_ack_hasht2 ),
    .rdata( mem_dout_hasht2 ),

    .mem_we( hasht2_mem_we ),
    .mem_wdata( hasht2_mem_wdata ),
    .mem_addr( hasht2_mem_addr ),
    .mem_rdata( hasht2_mem_rdata )
);

// Arbitration for HASHT1
class_hasht_arb
#(
    // actual memory instance depth/width
    .AW( HT_AWIDTH ),
    .DW( HT_DWIDTH )
)
u_class_hasht_arb_1
(
    .clk,
    .rst_n,

    .req( pio_mem_req_hasht1 ),
    .rd_or_wr( pio_mem_rd_wr ),
    .addr( pio_mem_addr ),
    .wdata( pio_mem_din ),

    .ack( mem_pio_ack_hasht1 ),
    .rdata( mem_dout_hasht1 ),

    .mem_we( hasht1_mem_we ),
    .mem_wdata( hasht1_mem_wdata ),
    .mem_addr( hasht1_mem_addr ),
    .mem_rdata( hasht1_mem_rdata )
);

class_pio u_class_pio
(
    clk,
    rst_n,

    clk_div,

    reg_addr,
    reg_din,
    reg_rd,
    reg_wr,
    mem_bs,
    reg_bs,

    pio_ack,
    pio_rvalid,
    pio_error(),
    pio_invld(),
    pio_rdata,

    pio_mem_req_value,
    mem_pio_ack_value,
    mem_dout_value,
    pio_value_din,

    pio_mem_req_hasht1,
    mem_pio_ack_hasht1,
    mem_dout_hasht1,

    pio_mem_req_hasht2,
    mem_pio_ack_hasht2,
    mem_dout_hasht2,

    pio_mem_rd_wr,
    pio_mem_addr,
    pio_mem_din
);

// =======================================================================
// Memory Instances

xilinx_ultraram_true_dual_port
#(
    .AWIDTH( HT_AWIDTH ),
    .DWIDTH( HT_DWIDTH ),
    .NBPIPE( 3 )
)
u_hashtable_t1
(
    .clk( clk ),   

    // main data path lookup
    .rsta( ~rst_n ),   
    .wea( 1'b0 ),    
    .regcea( 1'b1 ), 
    .mem_ena( 1'b1 ),
    .dina( { HT_DWIDTH{ 1'b0 } } ), 
    .addra( ht_t1_addra_q ),
    .douta( ht_t1_douta ),

    // insert, remove, s/w
    .rstb( ~rst_n ),   
    .web( hasht1_mem_we ),    
    .regceb( 1'b1 ), 
    .mem_enb( 1'b1 ),
    .dinb( hasht1_mem_wdata ),
    .addrb( hasht1_mem_addr ),
    .doutb( hasht1_mem_rdata )
);

xilinx_ultraram_true_dual_port
#(
    .AWIDTH( HT_AWIDTH ),
    .DWIDTH( HT_DWIDTH ),
    .NBPIPE( 3 )
)
u_hashtable_t2
(
    .clk( clk ),   

    // main data path lookup
    .rsta( ~rst_n ),
    .wea( 1'b0 ),
    .regcea( 1'b1 ),
    .mem_ena( 1'b1 ),
    .dina( { HT_DWIDTH{ 1'b0 } } ),
    .addra( ht_t2_addra_q ),
    .douta( ht_t2_douta ),

    // insert, remove, s/w
    // FIXME:  update for port B behavior
    .rstb( ~rst_n ),
    .web( hasht2_mem_we ),
    .regceb( 1'b1 ),
    .mem_enb( 1'b1 ),
    .dinb( hasht1_mem_wdata ),
    .addrb( hasht2_mem_addr ),
    .doutb( hasht2_mem_rdata )
);

xilinx_ultraram_true_dual_port
#(
    .AWIDTH( VT_AWIDTH ),
    .DWIDTH( VT_DWIDTH ),
    .NBPIPE( 3 )
)
u_value_mem
(
    .clk( clk ),

    // main data path lookup:  read only
    .rsta( ~rst_n ),
    .wea( 1'b0 ),
    .regcea( 1'b1 ),
    .mem_ena( 1'b1 ),
    .dina( { VT_DWIDTH{ 1'b0 } } ),
    .addra( hbkt_cmp_ptr_a_q ),
    .douta( val_mem_douta ),

    // insert, remove, s/w
    // FIXME:  needs arbiter logic module
    .rstb( ~rst_n ),
    .web( pio_mem_rd_wr & pio_mem_req_value ),
    .regceb( 1'b1 ),
    .mem_enb( 1'b1 ),
    .dinb( pio_value_din ),
    .addrb( pio_mem_addr[ 20:6 ] ),
    .doutb( mem_dout_value )
);

endmodule
