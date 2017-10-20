/* (c) 2017 Bayware, Inc.
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
/*                                                                           */

module classifier
#(
    parameter KEY_LEN = 276,
    parameter ITEMS = 32768,
    parameter BUS_WIDTH = 128
)
    input logic clk,
    input logic rst_n,

    // data path lookup
    input logic lu_vld,
    input logic [ BUS_WIDTH - 1:0 ] lu_key,
    output logic lu_done,
    output logic lu_hit_miss,
    output logic lu_vid,
    output logic lu_err,

    // data path insert
    input logic ins_vld,
    input logic [ BUS_WIDTH - 1:0 ] ins_key,
    output logic ins_done,
    output logic ins_hit_miss,
    output logic ins_vid,
    output logic ins_err,

    // data path remove
    input logic rm_vld,
    input logic [ BUS_WIDTH - 1:0 ] rm_key,
    output logic rm_done,
    output logic rm_hit_miss,
    output logic rm_vid,
    output logic rm_err
);

// =======================================================================
// Declarations & Parameters

// buckets per hash table, T1 and T2:  assumes 2x number of buckets than
// what are required in order to avoid collissions i.e., for 32k IDs, we
// only need 32k / 2 hash tables / 4 slots per table = 4k buckets; instead,
// use 8k buckets (13-bit address)
localparam HT_AWIDTH = $clog2( ITEMS / 2 / 4 * 2 );
localparam HT_DWIDTH = 128;
localparam VT_AWIDTH = $clog2( ITEMS );
localparam VT_DWIDTH = $ceil( KEY_LEN / 64 );

logic [ BUS_WIDTH - 1:0 ] lu_key_q;
logic lu_vld_q;
logic [ HT_AWIDTH - 1:0 ] ht_t1_addrq_q;
logic [ HT_AWIDTH - 1:0 ] ht_t1_addrq_qq;
logic [ HT_AWIDTH - 1:0 ] ht_t1_addrq_qqq;
logic [ HT_AWIDTH - 1:0 ] ht_t1_addrq_qqqq;
logic [ HT_AWIDTH - 1:0 ] ht_t2_addrq_q;
logic [ HT_AWIDTH - 1:0 ] ht_t2_addrq_qq;
logic [ HT_AWIDTH - 1:0 ] ht_t2_addrq_qqq;
logic [ HT_AWIDTH - 1:0 ] ht_t2_addrq_qqqq;
logic hash_a_vld;
logic hash_b_vld;
logic [ HT_AWIDTH ] h1k_a;
logic [ HT_AWIDTH ] h2k_a;
logic [ HT_AWIDTH ] h1k_b;
logic [ HT_AWIDTH ] h2k_b;

logic hbkt_cmp_pkt_strobe_a;
logic hbkt_cmp_pkt_err_a;
logic hbkt_cmp_hit_miss_a;
logic [ VT_AWIDTH - 1:0 ] hbkt_cmp_ptr_a;

// =======================================================================
// Combinational Logic

// =======================================================================
// Registered Logic

// Register:  lu_key_q
// Register:  lu_vld_q
always @( posedge clk )
    if ( !rst_n )
    begin
        lu_key_q <= { BUS_WIDTH{ 1'b0 } };
        lu_vld_q <= 1'b0;
    end

    else
    begin
        lu_key_q <= lu_key;
        lu_vld_q <= lu_vld;
    end

// Register:  ht_t1_addra_q
// Register:  ht_t2_addra_q
//
// Flop the address before passing into memory--may not be necessary
// for port A since it should always be "read" for lookup from main data.
// path.

always @( posedge clk )
    if ( !rst_n )
    begin
        ht_t1_addra_q <= { HT_ADDR_WIDTH{ 1'b0 } };
        ht_t2_addra_q <= { HT_ADDR_WIDTH{ 1'b0 } };
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
        ht_t2_addra_qq <= { HT_ADDR_WIDTH{ 1'b0 } };
        ht_t2_addra_qqq <= { HT_ADDR_WIDTH{ 1'b0 } };
        ht_t2_addra_qqqq <= { HT_ADDR_WIDTH{ 1'b0 } };
        ht_t1_addra_qq <= { HT_ADDR_WIDTH{ 1'b0 } };
        ht_t1_addra_qqq <= { HT_ADDR_WIDTH{ 1'b0 } };
        ht_t1_addra_qqqq <= { HT_ADDR_WIDTH{ 1'b0 } };
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

// Register:  value_mem_douta_q

always_ff @( posedge clk )
    value_mem_douta_q <= value_mem_douta;

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
    .key_b( 'd0 ),
    .key_b_start( 1'b0 ),
    .hash_b_vld( hash_b_vld ),
    .h1k_b( h1k_b ),
    .h2k_b( h2k_b )
);

class_hbkt_cmp u_class_hbkt_cmp_a
#(
    HASH_WIDTH = 13,
    PTR_WIDTH = 15
)
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
    clk( clk ),   

    // main data path lookup
    rsta( ~rst_n ),   
    wea( 1'b0 ),    
    regcea( 1'b1 ), 
    mem_ena( 1'b1 ),
    dina( { HT_DWIDTH{ 1'b0 } } ), 
    addra( ht_t1_addra_q ),
    douta( ht_t1_douta ),

    // insert, remove, s/w
    // FIXME:  update for port B behavior
    rstb( ~rst_n ),   
    web( 1'b0 ),    
    regceb( 1'b1 ), 
    mem_enb( 1'b1 ),
    dinb( { HT_DWIDTH{ 1'b0 } } ), 
    addrb( { HT_AWIDTH{ 1'b0 } } ),
    doutb()
);

xilinx_ultraram_true_dual_port
#(
    .AWIDTH( HT_AWIDTH ),
    .DWIDTH( HT_DWIDTH ),
    .NBPIPE( 3 )
)
u_hashtable_t2
(
    clk( clk ),   

    // main data path lookup
    rsta( ~rst_n ),
    wea( 1'b0 ),
    regcea( 1'b1 ),
    mem_ena( 1'b1 ),
    dina( { HT_DWIDTH{ 1'b0 } } ),
    addra( ht_t2_addra_q ),
    douta( ht_t2_douta ),

    // insert, remove, s/w
    // FIXME:  update for port B behavior
    rstb( ~rst_n ),
    web( 1'b0 ),
    regceb( 1'b1 ),
    mem_enb( 1'b1 ),
    dinb( { HT_DWIDTH{ 1'b0 } } ),
    addrb( { HT_AWIDTH{ 1'b0 } } ),
    doutb()
);

xilinx_ultraram_true_dual_port
#(
    .AWIDTH( VT_AWIDTH ),
    .DWIDTH( VT_DWIDTH ),
    .NBPIPE( 3 )
)
u_value_mem
(
    clk( clk ),

    // main data path lookup:  read only
    rsta( ~rst_n ),
    wea( 1'b0 ),
    regcea( 1'b1 ),
    mem_ena( 1'b1 ),
    dina( { VT_DWIDTH{ 1'b0 } } ),
    addra( hbkt_cmp_ptr_a ),
    douta( value_mem_douta ),

    // insert, remove, s/w
    // FIXME:  update for port B behavior
    rstb( ~rst_n ),
    web( 1'b0 ),
    regceb( 1'b1 ),
    mem_enb( 1'b1 ),
    dinb( { VT_DWIDTH{ 1'b0 } } ),
    addrb( { VT_AWIDTH{ 1'b0 } } ),
    doutb()
);

endmodule
