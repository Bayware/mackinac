//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module decap #(
parameter PBUS_NBITS = 32,
parameter DMA_BUS_NBITS = `DMA_BUS_NBITS,
parameter RING_NBITS = 64,
parameter RCI_DEPTH_NBITS = `RCI_HASH_TABLE_DEPTH_NBITS,
parameter RCI_BUCKET_NBITS = `RCI_HASH_BUCKET_NBITS,
parameter RCI_VALUE_NBITS = `RCI_VALUE_NBITS,
parameter RCI_VALUE_DEPTH_NBITS = `RCI_VALUE_DEPTH_NBITS,
parameter EKEY_DEPTH_NBITS = `EKEY_HASH_TABLE_DEPTH_NBITS,
parameter EKEY_BUCKET_NBITS = `EKEY_HASH_BUCKET_NBITS,
parameter EKEY_VALUE_NBITS = `EKEY_VALUE_NBITS,
parameter EKEY_VALUE_DEPTH_NBITS = `EKEY_VALUE_DEPTH_NBITS,
parameter WR_NBITS = `SEQUENCE_NUMBER_NBITS+`SPI_NBITS
) (

input clk, 
input `RESET_SIG,

input clk_mac, 
input clk_axi, 

input         pio_start,
input         pio_rw,
input [`PIO_RANGE] pio_addr_wdata,

input [PBUS_NBITS-1:0] rx_axis_tdata0,
input [3:0] rx_axis_tkeep0,
input rx_axis_tvalid0,
input rx_axis_tuser0,
input rx_axis_tlast0,

input [PBUS_NBITS-1:0] rx_axis_tdata1,
input [3:0] rx_axis_tkeep1,
input rx_axis_tvalid1,
input rx_axis_tuser1,
input rx_axis_tlast1,

input m_axis_h2c_tvalid_x0,
input m_axis_h2c_tlast_x0,
input [DMA_BUS_NBITS-1:0] m_axis_h2c_tdata_x0,

output m_axis_h2c_tready_x0,

input m_axis_h2c_tvalid_x1,
input m_axis_h2c_tlast_x1,
input [DMA_BUS_NBITS-1:0] m_axis_h2c_tdata_x1,

output m_axis_h2c_tready_x1,

input m_axis_h2c_tvalid_x2,
input m_axis_h2c_tlast_x2,
input [DMA_BUS_NBITS-1:0] m_axis_h2c_tdata_x2,

output m_axis_h2c_tready_x2,

input m_axis_h2c_tvalid_x3,
input m_axis_h2c_tlast_x3,
input [DMA_BUS_NBITS-1:0] m_axis_h2c_tdata_x3,

output m_axis_h2c_tready_x3,

input [`NUM_OF_PORTS-1:0] aggr_port_bp,

output dec_aggr_data_valid0,
output [`PORT_BUS_RANGE] dec_aggr_packet_data0,
output dec_aggr_sop0,
output dec_aggr_eop0,
output [`PORT_BUS_VB_RANGE] dec_aggr_valid_bytes0,    
output [`RCI_NBITS-1:0] dec_aggr_rci0,    
output dec_aggr_error0,  

output dec_aggr_data_valid1,
output [`PORT_BUS_RANGE] dec_aggr_packet_data1,
output dec_aggr_sop1,
output dec_aggr_eop1,
output [`PORT_BUS_VB_RANGE] dec_aggr_valid_bytes1,    
output [`RCI_NBITS-1:0] dec_aggr_rci1,    
output dec_aggr_error1,  

output dec_aggr_data_valid2,
output [`PORT_BUS_RANGE] dec_aggr_packet_data2,
output dec_aggr_sop2,
output dec_aggr_eop2,
output [`PORT_BUS_VB_RANGE] dec_aggr_valid_bytes2,    
output [`RCI_NBITS-1:0] dec_aggr_rci2,    
output dec_aggr_error2,  

output dec_aggr_data_valid3,
output [`PORT_BUS_RANGE] dec_aggr_packet_data3,
output dec_aggr_sop3,
output dec_aggr_eop3,
output [`PORT_BUS_VB_RANGE] dec_aggr_valid_bytes3,    
output [`RCI_NBITS-1:0] dec_aggr_rci3,    
output dec_aggr_error3,  

output dec_aggr_data_valid4,
output [`PORT_BUS_RANGE] dec_aggr_packet_data4,
output dec_aggr_sop4,
output dec_aggr_eop4,
output [`PORT_BUS_VB_RANGE] dec_aggr_valid_bytes4,    
output [`RCI_NBITS-1:0] dec_aggr_rci4,    
output dec_aggr_error4,  

output dec_aggr_data_valid5,
output [`PORT_BUS_RANGE] dec_aggr_packet_data5,
output dec_aggr_sop5,
output dec_aggr_eop5,
output [`PORT_BUS_VB_RANGE] dec_aggr_valid_bytes5,    
output [`RCI_NBITS-1:0] dec_aggr_rci5,    
output dec_aggr_error5,  

output clk_div,

output pio_ack,
output pio_rvalid,
output [`PIO_RANGE] pio_rdata

);

/***************************** LOCAL VARIABLES *******************************/
logic [PBUS_NBITS-1:0] rx_axis_tdata2;
logic [3:0] rx_axis_tkeep2;
logic rx_axis_tvalid2;
logic rx_axis_tuser2;
logic rx_axis_tlast2;

logic [PBUS_NBITS-1:0] rx_axis_tdata3;
logic [3:0] rx_axis_tkeep3;
logic rx_axis_tvalid3;
logic rx_axis_tuser3;
logic rx_axis_tlast3;

logic [PBUS_NBITS-1:0] rx_axis_tdata4;
logic [3:0] rx_axis_tkeep4;
logic rx_axis_tvalid4;
logic rx_axis_tuser4;
logic rx_axis_tlast4;

logic [PBUS_NBITS-1:0] rx_axis_tdata5;
logic [3:0] rx_axis_tkeep5;
logic rx_axis_tvalid5;
logic rx_axis_tuser5;
logic rx_axis_tlast5;

wire [`PIO_RANGE] reg_addr;
wire [`PIO_RANGE] reg_din;
wire reg_rd;
wire reg_wr;
wire mem_bs;
wire reg_ms_rci_hash_table;
wire reg_ms_rci_value;
wire reg_ms_ekey_hash_table;
wire reg_ms_ekey_value;

wire rci_hash_table_mem_ack;
wire [`PIO_RANGE] rci_hash_table_mem_rdata;

wire rci_value_mem_ack;
wire [`PIO_RANGE] rci_value_mem_rdata;

wire ekey_hash_table_mem_ack;
wire [`PIO_RANGE] ekey_hash_table_mem_rdata;

wire ekey_value_mem_ack;
wire [`PIO_RANGE] ekey_value_mem_rdata;

wire [RING_NBITS-1:0] decr_ring_in_data;
wire decr_ring_in_sof;
wire decr_ring_in_sos;
wire decr_ring_in_valid;

wire [RING_NBITS-1:0] decr_ring_out_data;
wire decr_ring_out_sof;
wire decr_ring_out_sos;
wire decr_ring_out_valid;

wire [RING_NBITS-1:0] decr_ring_out_data0;
wire decr_ring_out_sof0;
wire decr_ring_out_sos0;
wire decr_ring_out_valid0;

wire [RING_NBITS-1:0] decr_ring_out_data1;
wire decr_ring_out_sof1;
wire decr_ring_out_sos1;
wire decr_ring_out_valid1;

wire [RING_NBITS-1:0] decr_ring_out_data2;
wire decr_ring_out_sof2;
wire decr_ring_out_sos2;
wire decr_ring_out_valid2;

wire [RING_NBITS-1:0] decr_ring_out_data3;
wire decr_ring_out_sof3;
wire decr_ring_out_sos3;
wire decr_ring_out_valid3;

wire [RING_NBITS-1:0] decr_ring_out_data4;
wire decr_ring_out_sof4;
wire decr_ring_out_sos4;
wire decr_ring_out_valid4;

wire rci_hash_table0_ack; 
wire [RCI_BUCKET_NBITS-1:0] rci_hash_table0_rdata  /* synthesis keep = 1 */;

wire rci_hash_table1_ack; 
wire [RCI_BUCKET_NBITS-1:0] rci_hash_table1_rdata  /* synthesis keep = 1 */;

wire rci_value_ack; 
wire [RCI_VALUE_NBITS-1:0] rci_value_rdata  /* synthesis keep = 1 */;

wire ekey_hash_table0_ack; 
wire [EKEY_BUCKET_NBITS-1:0] ekey_hash_table0_rdata  /* synthesis keep = 1 */;

wire ekey_hash_table1_ack; 
wire [EKEY_BUCKET_NBITS-1:0] ekey_hash_table1_rdata  /* synthesis keep = 1 */;

wire ekey_value_ack; 
wire [EKEY_VALUE_NBITS-1:0] ekey_value_rdata  /* synthesis keep = 1 */;

wire rci_hash_table0_rd; 
wire [RCI_DEPTH_NBITS-1:0] rci_hash_table0_raddr;

wire rci_hash_table1_rd; 
wire [RCI_DEPTH_NBITS-1:0] rci_hash_table1_raddr;

wire rci_value_rd; 
wire [RCI_VALUE_DEPTH_NBITS-1:0] rci_value_raddr;

wire ekey_hash_table0_rd; 
wire [EKEY_DEPTH_NBITS-1:0] ekey_hash_table0_raddr;

wire ekey_hash_table1_rd; 
wire [EKEY_DEPTH_NBITS-1:0] ekey_hash_table1_raddr;

wire ekey_value_rd; 
wire [EKEY_VALUE_DEPTH_NBITS-1:0] ekey_value_raddr;

wire ekey_value_wr; 
wire [EKEY_VALUE_DEPTH_NBITS-1:0] ekey_value_waddr;
wire [WR_NBITS-1:0] ekey_value_wdata;

wire [`NUM_OF_PORTS-1:2] dec_bp;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/


/***************************** PROGRAM BODY **********************************/

pio2reg_bus #(
  .BLOCK_ADDR_LSB(`DECR_BLOCK_ADDR_LSB),
  .BLOCK_ADDR(`DECR_BLOCK_ADDR),
  .REG_BLOCK_ADDR_LSB(`DECR_BLOCK_ADDR_LSB),
  .REG_BLOCK_ADDR(`DECR_BLOCK_ADDR)
) u_pio2reg_bus (

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 
    
    .pio_start(pio_start),
    .pio_rw(pio_rw),
    .pio_addr_wdata(pio_addr_wdata),
    
    .clk_div(clk_div),

    .reg_addr(reg_addr),
    .reg_din(reg_din),
    .reg_rd(reg_rd),
    .reg_wr(reg_wr),
    .mem_bs(mem_bs),
    .reg_bs()

);

decap_pio u_decap_pio(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_div(clk_div),

    .reg_bs(mem_bs),
    .reg_wr(reg_wr),
    .reg_rd(reg_rd),
    .reg_addr(reg_addr),
    .reg_din(reg_din),

    .rci_hash_table_mem_ack(rci_hash_table_mem_ack),
    .rci_value_mem_ack(rci_value_mem_ack),
    .ekey_hash_table_mem_ack(ekey_hash_table_mem_ack),
    .ekey_value_mem_ack(ekey_value_mem_ack),

    .rci_hash_table_mem_rdata(rci_hash_table_mem_rdata),
    .rci_value_mem_rdata(rci_value_mem_rdata),
    .ekey_hash_table_mem_rdata(ekey_hash_table_mem_rdata),
    .ekey_value_mem_rdata(ekey_value_mem_rdata),

    .reg_ms_rci_hash_table(reg_ms_rci_hash_table),
    .reg_ms_rci_value(reg_ms_rci_value),
    .reg_ms_ekey_hash_table(reg_ms_ekey_hash_table),
    .reg_ms_ekey_value(reg_ms_ekey_value),

    .pio_ack(pio_ack),
    .pio_rvalid(pio_rvalid),
    .pio_rdata(pio_rdata)

);

decap_mem_rci u_decap_mem_rci(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_div(clk_div), 

    .reg_addr(reg_addr),
    .reg_din(reg_din),
    .reg_wr(reg_wr),
    .reg_rd(reg_rd),
    .reg_ms_rci_hash_table(reg_ms_rci_hash_table),
    .reg_ms_rci_value(reg_ms_rci_value),

    .rci_hash_table_mem_ack(rci_hash_table_mem_ack),
    .rci_hash_table_mem_rdata(rci_hash_table_mem_rdata),

    .rci_value_mem_ack(rci_value_mem_ack),
    .rci_value_mem_rdata(rci_value_mem_rdata),

    .rci_hash_table0_rd(rci_hash_table0_rd),
    .rci_hash_table0_raddr(rci_hash_table0_raddr),

    .rci_hash_table1_rd(rci_hash_table1_rd),
    .rci_hash_table1_raddr(rci_hash_table1_raddr),

    .rci_value_rd(rci_value_rd),
    .rci_value_raddr(rci_value_raddr),

    .rci_hash_table0_ack(rci_hash_table0_ack),
    .rci_hash_table0_rdata(rci_hash_table0_rdata),

    .rci_hash_table1_ack(rci_hash_table1_ack),
    .rci_hash_table1_rdata(rci_hash_table1_rdata),

    .rci_value_ack(rci_value_ack),
    .rci_value_rdata(rci_value_rdata)

);


decap_mem_ekey u_decap_mem_ekey(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_div(clk_div), 

    .reg_addr(reg_addr),
    .reg_din(reg_din),
    .reg_wr(reg_wr),
    .reg_rd(reg_rd),
    .reg_ms_ekey_hash_table(reg_ms_ekey_hash_table),
    .reg_ms_ekey_value(reg_ms_ekey_value),

    .ekey_hash_table_mem_ack(ekey_hash_table_mem_ack),
    .ekey_hash_table_mem_rdata(ekey_hash_table_mem_rdata),

    .ekey_value_mem_ack(ekey_value_mem_ack),
    .ekey_value_mem_rdata(ekey_value_mem_rdata),

    .ekey_hash_table0_rd(ekey_hash_table0_rd),
    .ekey_hash_table0_raddr(ekey_hash_table0_raddr),

    .ekey_hash_table1_rd(ekey_hash_table1_rd),
    .ekey_hash_table1_raddr(ekey_hash_table1_raddr),

    .ekey_value_rd(ekey_value_rd),
    .ekey_value_raddr(ekey_value_raddr),

    .ekey_value_wr(ekey_value_wr),
    .ekey_value_waddr(ekey_value_waddr),
    .ekey_value_wdata(ekey_value_wdata),

    .ekey_hash_table0_ack(ekey_hash_table0_ack),
    .ekey_hash_table0_rdata(ekey_hash_table0_rdata),

    .ekey_hash_table1_ack(ekey_hash_table1_ack),
    .ekey_hash_table1_rdata(ekey_hash_table1_rdata),

    .ekey_value_ack(ekey_value_ack),
    .ekey_value_rdata(ekey_value_rdata)

);


decap_lookup u_decap_lookup(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .decr_ring_in_data(decr_ring_in_data),
    .decr_ring_in_sof(decr_ring_in_sof),
    .decr_ring_in_sos(decr_ring_in_sos),
    .decr_ring_in_valid(decr_ring_in_valid),
 
    .rci_hash_table0_ack(rci_hash_table0_ack),
    .rci_hash_table0_rdata(rci_hash_table0_rdata),

    .rci_hash_table1_ack(rci_hash_table1_ack),
    .rci_hash_table1_rdata(rci_hash_table1_rdata),

    .rci_value_ack(rci_value_ack),
    .rci_value_rdata(rci_value_rdata),

    .ekey_hash_table0_ack(ekey_hash_table0_ack),
    .ekey_hash_table0_rdata(ekey_hash_table0_rdata),

    .ekey_hash_table1_ack(ekey_hash_table1_ack),
    .ekey_hash_table1_rdata(ekey_hash_table1_rdata),

    .ekey_value_ack(ekey_value_ack),
    .ekey_value_rdata(ekey_value_rdata),


    .rci_hash_table0_rd(rci_hash_table0_rd),
    .rci_hash_table0_raddr(rci_hash_table0_raddr),

    .rci_hash_table1_rd(rci_hash_table1_rd),
    .rci_hash_table1_raddr(rci_hash_table1_raddr),

    .rci_value_rd(rci_value_rd),
    .rci_value_raddr(rci_value_raddr),

    .ekey_hash_table0_rd(ekey_hash_table0_rd),
    .ekey_hash_table0_raddr(ekey_hash_table0_raddr),

    .ekey_hash_table1_rd(ekey_hash_table1_rd),
    .ekey_hash_table1_raddr(ekey_hash_table1_raddr),

    .ekey_value_rd(ekey_value_rd),
    .ekey_value_raddr(ekey_value_raddr),

    .ekey_value_wr(ekey_value_wr),
    .ekey_value_waddr(ekey_value_waddr),
    .ekey_value_wdata(ekey_value_wdata),

    .decr_ring_out_data(decr_ring_out_data),
    .decr_ring_out_sof(decr_ring_out_sof),
    .decr_ring_out_sos(decr_ring_out_sos),
    .decr_ring_out_valid(decr_ring_out_valid)
 
);

decap_port #(.DECRYPTOR_ID(0)) u_decap_port_0( 

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_mac(clk_mac), 

    .rx_axis_tdata(rx_axis_tdata0),
    .rx_axis_tkeep(rx_axis_tkeep0),
    .rx_axis_tvalid(rx_axis_tvalid0),
    .rx_axis_tuser(rx_axis_tuser0),
    .rx_axis_tlast(rx_axis_tlast0),

    .decr_ring_in_data(decr_ring_out_data),
    .decr_ring_in_sof(decr_ring_out_sof),
    .decr_ring_in_sos(decr_ring_out_sos),
    .decr_ring_in_valid(decr_ring_out_valid),

    .aggr_port_bp(aggr_port_bp[0]),

    .dec_bp(),

    .decr_ring_out_data(decr_ring_out_data0),
    .decr_ring_out_sof(decr_ring_out_sof0),
    .decr_ring_out_sos(decr_ring_out_sos0),
    .decr_ring_out_valid(decr_ring_out_valid0),
 
    .dec_aggr_data_valid(dec_aggr_data_valid0),
    .dec_aggr_packet_data(dec_aggr_packet_data0),
    .dec_aggr_sop(dec_aggr_sop0),
    .dec_aggr_eop(dec_aggr_eop0),
    .dec_aggr_valid_bytes(dec_aggr_valid_bytes0),
    .dec_aggr_rci(dec_aggr_rci0),
    .dec_aggr_error(dec_aggr_error0)
 
);

decap_port #(.DECRYPTOR_ID(1)) u_decap_port_1( 

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_mac(clk_mac), 

    .rx_axis_tdata(rx_axis_tdata1),
    .rx_axis_tkeep(rx_axis_tkeep1),
    .rx_axis_tvalid(rx_axis_tvalid1),
    .rx_axis_tuser(rx_axis_tuser1),
    .rx_axis_tlast(rx_axis_tlast1),

    .decr_ring_in_data(decr_ring_out_data0),
    .decr_ring_in_sof(decr_ring_out_sof0),
    .decr_ring_in_sos(decr_ring_out_sos0),
    .decr_ring_in_valid(decr_ring_out_valid0),

    .aggr_port_bp(aggr_port_bp[1]),

    .dec_bp(),

    .decr_ring_out_data(decr_ring_out_data1),
    .decr_ring_out_sof(decr_ring_out_sof1),
    .decr_ring_out_sos(decr_ring_out_sos1),
    .decr_ring_out_valid(decr_ring_out_valid1),
 
    .dec_aggr_data_valid(dec_aggr_data_valid1),
    .dec_aggr_packet_data(dec_aggr_packet_data1),
    .dec_aggr_sop(dec_aggr_sop1),
    .dec_aggr_eop(dec_aggr_eop1),
    .dec_aggr_valid_bytes(dec_aggr_valid_bytes1),
    .dec_aggr_rci(dec_aggr_rci1),
    .dec_aggr_error(dec_aggr_error1)
 
);

gb_64to32 u_gb_64to32_2(

    .clk_mac(clk_mac), 
    .clk_axi(clk_axi), 

    .`RESET_SIG(`RESET_SIG), 

    .m_axis_h2c_tvalid_x(m_axis_h2c_tvalid_x0),
    .m_axis_h2c_tlast_x(m_axis_h2c_tlast_x0),
    .m_axis_h2c_tdata_x(m_axis_h2c_tdata_x0),

    .m_axis_h2c_tready_x(m_axis_h2c_tready_x0),

    .dec_bp(dec_bp[2]),

    .rx_axis_tdata(rx_axis_tdata2),
    .rx_axis_tkeep(rx_axis_tkeep2),
    .rx_axis_tvalid(rx_axis_tvalid2),
    .rx_axis_tuser(rx_axis_tuser2),
    .rx_axis_tlast(rx_axis_tlast2)
);

decap_port #(.DECRYPTOR_ID(2)) u_decap_port_2( 

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_mac(clk_mac), 

    .rx_axis_tdata(rx_axis_tdata2),
    .rx_axis_tkeep(rx_axis_tkeep2),
    .rx_axis_tvalid(rx_axis_tvalid2),
    .rx_axis_tuser(rx_axis_tuser2),
    .rx_axis_tlast(rx_axis_tlast2),

    .decr_ring_in_data(decr_ring_out_data1),
    .decr_ring_in_sof(decr_ring_out_sof1),
    .decr_ring_in_sos(decr_ring_out_sos1),
    .decr_ring_in_valid(decr_ring_out_valid1),

    .aggr_port_bp(aggr_port_bp[2]),

    .dec_bp(dec_bp[2]),

    .decr_ring_out_data(decr_ring_out_data2),
    .decr_ring_out_sof(decr_ring_out_sof2),
    .decr_ring_out_sos(decr_ring_out_sos2),
    .decr_ring_out_valid(decr_ring_out_valid2),
 
    .dec_aggr_data_valid(dec_aggr_data_valid2),
    .dec_aggr_packet_data(dec_aggr_packet_data2),
    .dec_aggr_sop(dec_aggr_sop2),
    .dec_aggr_eop(dec_aggr_eop2),
    .dec_aggr_valid_bytes(dec_aggr_valid_bytes2),
    .dec_aggr_rci(dec_aggr_rci2),
    .dec_aggr_error(dec_aggr_error2)
 
);

gb_64to32 u_gb_64to32_3(

    .clk_mac(clk_mac), 
    .clk_axi(clk_axi), 

    .`RESET_SIG(`RESET_SIG), 

    .m_axis_h2c_tvalid_x(m_axis_h2c_tvalid_x1),
    .m_axis_h2c_tlast_x(m_axis_h2c_tlast_x1),
    .m_axis_h2c_tdata_x(m_axis_h2c_tdata_x1),

    .m_axis_h2c_tready_x(m_axis_h2c_tready_x1),

    .dec_bp(dec_bp[3]),

    .rx_axis_tdata(rx_axis_tdata3),
    .rx_axis_tkeep(rx_axis_tkeep3),
    .rx_axis_tvalid(rx_axis_tvalid3),
    .rx_axis_tuser(rx_axis_tuser3),
    .rx_axis_tlast(rx_axis_tlast3)
);

decap_port #(.DECRYPTOR_ID(3)) u_decap_port_3( 

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_mac(clk_mac), 

    .rx_axis_tdata(rx_axis_tdata3),
    .rx_axis_tkeep(rx_axis_tkeep3),
    .rx_axis_tvalid(rx_axis_tvalid3),
    .rx_axis_tuser(rx_axis_tuser3),
    .rx_axis_tlast(rx_axis_tlast3),

    .decr_ring_in_data(decr_ring_out_data2),
    .decr_ring_in_sof(decr_ring_out_sof2),
    .decr_ring_in_sos(decr_ring_out_sos2),
    .decr_ring_in_valid(decr_ring_out_valid2),

    .aggr_port_bp(aggr_port_bp[3]),

    .dec_bp(dec_bp[3]),

    .decr_ring_out_data(decr_ring_out_data3),
    .decr_ring_out_sof(decr_ring_out_sof3),
    .decr_ring_out_sos(decr_ring_out_sos3),
    .decr_ring_out_valid(decr_ring_out_valid3),
 
    .dec_aggr_data_valid(dec_aggr_data_valid3),
    .dec_aggr_packet_data(dec_aggr_packet_data3),
    .dec_aggr_sop(dec_aggr_sop3),
    .dec_aggr_eop(dec_aggr_eop3),
    .dec_aggr_valid_bytes(dec_aggr_valid_bytes3),
    .dec_aggr_rci(dec_aggr_rci3),
    .dec_aggr_error(dec_aggr_error3)
 
);

gb_64to32 u_gb_64to32_4(

    .clk_mac(clk_mac), 
    .clk_axi(clk_axi), 

    .`RESET_SIG(`RESET_SIG), 

    .m_axis_h2c_tvalid_x(m_axis_h2c_tvalid_x2),
    .m_axis_h2c_tlast_x(m_axis_h2c_tlast_x2),
    .m_axis_h2c_tdata_x(m_axis_h2c_tdata_x2),

    .m_axis_h2c_tready_x(m_axis_h2c_tready_x2),

    .dec_bp(dec_bp[4]),

    .rx_axis_tdata(rx_axis_tdata4),
    .rx_axis_tkeep(rx_axis_tkeep4),
    .rx_axis_tvalid(rx_axis_tvalid4),
    .rx_axis_tuser(rx_axis_tuser4),
    .rx_axis_tlast(rx_axis_tlast4)
);

decap_port #(.DECRYPTOR_ID(4)) u_decap_port_4( 

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_mac(clk_mac), 

    .rx_axis_tdata(rx_axis_tdata4),
    .rx_axis_tkeep(rx_axis_tkeep4),
    .rx_axis_tvalid(rx_axis_tvalid4),
    .rx_axis_tuser(rx_axis_tuser4),
    .rx_axis_tlast(rx_axis_tlast4),

    .decr_ring_in_data(decr_ring_out_data3),
    .decr_ring_in_sof(decr_ring_out_sof3),
    .decr_ring_in_sos(decr_ring_out_sos3),
    .decr_ring_in_valid(decr_ring_out_valid3),

    .aggr_port_bp(aggr_port_bp[4]),

    .dec_bp(dec_bp[4]),

    .decr_ring_out_data(decr_ring_out_data4),
    .decr_ring_out_sof(decr_ring_out_sof4),
    .decr_ring_out_sos(decr_ring_out_sos4),
    .decr_ring_out_valid(decr_ring_out_valid4),
 
    .dec_aggr_data_valid(dec_aggr_data_valid4),
    .dec_aggr_packet_data(dec_aggr_packet_data4),
    .dec_aggr_sop(dec_aggr_sop4),
    .dec_aggr_eop(dec_aggr_eop4),
    .dec_aggr_valid_bytes(dec_aggr_valid_bytes4),
    .dec_aggr_rci(dec_aggr_rci4),
    .dec_aggr_error(dec_aggr_error4)
 
);

gb_64to32 u_gb_64to32_5(

    .clk_mac(clk_mac), 
    .clk_axi(clk_axi), 
    .`RESET_SIG(`RESET_SIG), 

    .m_axis_h2c_tvalid_x(m_axis_h2c_tvalid_x3),
    .m_axis_h2c_tlast_x(m_axis_h2c_tlast_x3),
    .m_axis_h2c_tdata_x(m_axis_h2c_tdata_x3),

    .m_axis_h2c_tready_x(m_axis_h2c_tready_x3),

    .dec_bp(dec_bp[5]),

    .rx_axis_tdata(rx_axis_tdata5),
    .rx_axis_tkeep(rx_axis_tkeep5),
    .rx_axis_tvalid(rx_axis_tvalid5),
    .rx_axis_tuser(rx_axis_tuser5),
    .rx_axis_tlast(rx_axis_tlast5)
);

decap_port #(.DECRYPTOR_ID(5)) u_decap_port_5( 

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_mac(clk_mac), 

    .rx_axis_tdata(rx_axis_tdata5),
    .rx_axis_tkeep(rx_axis_tkeep5),
    .rx_axis_tvalid(rx_axis_tvalid5),
    .rx_axis_tuser(rx_axis_tuser5),
    .rx_axis_tlast(rx_axis_tlast5),

    .decr_ring_in_data(decr_ring_out_data4),
    .decr_ring_in_sof(decr_ring_out_sof4),
    .decr_ring_in_sos(decr_ring_out_sos4),
    .decr_ring_in_valid(decr_ring_out_valid4),

    .aggr_port_bp(aggr_port_bp[5]),

    .dec_bp(dec_bp[5]),

    .decr_ring_out_data(decr_ring_in_data),
    .decr_ring_out_sof(decr_ring_in_sof),
    .decr_ring_out_sos(decr_ring_in_sos),
    .decr_ring_out_valid(decr_ring_in_valid),
 
    .dec_aggr_data_valid(dec_aggr_data_valid5),
    .dec_aggr_packet_data(dec_aggr_packet_data5),
    .dec_aggr_sop(dec_aggr_sop5),
    .dec_aggr_eop(dec_aggr_eop5),
    .dec_aggr_valid_bytes(dec_aggr_valid_bytes5),
    .dec_aggr_rci(dec_aggr_rci5),
    .dec_aggr_error(dec_aggr_error5)
 
);


/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

