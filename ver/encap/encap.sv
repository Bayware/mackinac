//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module encap #(
parameter PBUS_NBITS = 32,
parameter DMA_BUS_NBITS = `DMA_BUS_NBITS,
parameter RING_NBITS = 128,
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

output clk_div,
output pio_ack,
output pio_rvalid,
output [`PIO_RANGE] pio_rdata,

input dstr_enc_data_valid0,
input [`PORT_BUS_RANGE] dstr_enc_packet_data0,
input dstr_enc_sop0,
input dstr_enc_eop0,
input [`PORT_BUS_VB_RANGE] dstr_enc_valid_bytes0,    

input dstr_enc_data_valid1,
input [`PORT_BUS_RANGE] dstr_enc_packet_data1,
input dstr_enc_sop1,
input dstr_enc_eop1,
input [`PORT_BUS_VB_RANGE] dstr_enc_valid_bytes1,    

input dstr_enc_data_valid2,
input [`PORT_BUS_RANGE] dstr_enc_packet_data2,
input dstr_enc_sop2,
input dstr_enc_eop2,
input [`PORT_BUS_VB_RANGE] dstr_enc_valid_bytes2,    
input dstr_enc_port_id2,

input dstr_enc_data_valid3,
input [`PORT_BUS_RANGE] dstr_enc_packet_data3,
input dstr_enc_sop3,
input dstr_enc_eop3,
input [`PORT_BUS_VB_RANGE] dstr_enc_valid_bytes3,    
input [1:0] dstr_enc_port_id3,

output [`NUM_OF_PORTS-1:0] port_dstr_bp,

output [PBUS_NBITS-1:0] tx_axis_tdata0,
output [3:0] tx_axis_tkeep0,
output tx_axis_tvalid0,
output tx_axis_tuser0,
output tx_axis_tlast0,

input tx_axis_tready0,

output [PBUS_NBITS-1:0] tx_axis_tdata1,
output [3:0] tx_axis_tkeep1,
output tx_axis_tvalid1,
output tx_axis_tuser1,
output tx_axis_tlast1,

input tx_axis_tready1,

output s_axis_c2h_tvalid_x0,
output s_axis_c2h_tlast_x0,
output [DMA_BUS_NBITS-1:0] s_axis_c2h_tdata_x0,

input s_axis_c2h_tready_x0,

output s_axis_c2h_tvalid_x1,
output s_axis_c2h_tlast_x1,
output [DMA_BUS_NBITS-1:0] s_axis_c2h_tdata_x1,

input s_axis_c2h_tready_x1,

output s_axis_c2h_tvalid_x2,
output s_axis_c2h_tlast_x2,
output [DMA_BUS_NBITS-1:0] s_axis_c2h_tdata_x2,

input s_axis_c2h_tready_x2,

output s_axis_c2h_tvalid_x3,
output s_axis_c2h_tlast_x3,
output [DMA_BUS_NBITS-1:0] s_axis_c2h_tdata_x3,

input s_axis_c2h_tready_x3

);

/***************************** LOCAL VARIABLES *******************************/
logic pio_ack0;
logic pio_rvalid0;
logic [`PIO_RANGE] pio_rdata0;

logic pio_ack1;
logic pio_rvalid1;
logic [`PIO_RANGE] pio_rdata1;

logic [PBUS_NBITS-1:0] tx_axis_tdata2;
logic [3:0] tx_axis_tkeep2;
logic tx_axis_tvalid2;
logic tx_axis_tuser2;
logic tx_axis_tlast2;

logic tx_axis_tready2;

logic [PBUS_NBITS-1:0] tx_axis_tdata3;
logic [3:0] tx_axis_tkeep3;
logic tx_axis_tvalid3;
logic tx_axis_tuser3;
logic tx_axis_tlast3;

logic tx_axis_tready3;

logic [PBUS_NBITS-1:0] tx_axis_tdata4;
logic [3:0] tx_axis_tkeep4;
logic tx_axis_tvalid4;
logic tx_axis_tuser4;
logic tx_axis_tlast4;

logic tx_axis_tready4;

logic [PBUS_NBITS-1:0] tx_axis_tdata5;
logic [3:0] tx_axis_tkeep5;
logic tx_axis_tvalid5;
logic tx_axis_tuser5;
logic tx_axis_tlast5;

logic tx_axis_tready5;

wire [`PIO_RANGE] reg_addr;
wire [`PIO_RANGE] reg_din;
wire reg_rd;
wire reg_wr;
wire mem_bs;
wire reg_bs;
wire reg_ms_tunnel_hash_table;
wire reg_ms_tunnel_value;
wire reg_ms_ekey_hash_table;
wire reg_ms_ekey_value;

wire tunnel_hash_table_mem_ack;
wire [`PIO_RANGE] tunnel_hash_table_mem_rdata;

wire tunnel_value_mem_ack;
wire [`PIO_RANGE] tunnel_value_mem_rdata;

wire ekey_hash_table_mem_ack;
wire [`PIO_RANGE] ekey_hash_table_mem_rdata;

wire ekey_value_mem_ack;
wire [`PIO_RANGE] ekey_value_mem_rdata;

wire [RING_NBITS-1:0] encr_ring_in_data;
wire encr_ring_in_sof;
wire encr_ring_in_sos;
wire encr_ring_in_valid;

wire [RING_NBITS-1:0] encr_ring_out_data;
wire encr_ring_out_sof;
wire encr_ring_out_sos;
wire encr_ring_out_valid;

wire [RING_NBITS-1:0] encr_ring_out_data0;
wire encr_ring_out_sof0;
wire encr_ring_out_sos0;
wire encr_ring_out_valid0;

wire [RING_NBITS-1:0] encr_ring_out_data1;
wire encr_ring_out_sof1;
wire encr_ring_out_sos1;
wire encr_ring_out_valid1;

wire [RING_NBITS-1:0] encr_ring_out_data2;
wire encr_ring_out_sof2;
wire encr_ring_out_sos2;
wire encr_ring_out_valid2;

wire [RING_NBITS-1:0] encr_ring_out_data3;
wire encr_ring_out_sof3;
wire encr_ring_out_sos3;
wire encr_ring_out_valid3;

wire [RING_NBITS-1:0] encr_ring_out_data4;
wire encr_ring_out_sof4;
wire encr_ring_out_sos4;
wire encr_ring_out_valid4;

wire tunnel_hash_table0_ack; 
wire [RCI_BUCKET_NBITS-1:0] tunnel_hash_table0_rdata  /* synthesis DONT_TOUCH */;

wire tunnel_hash_table1_ack; 
wire [RCI_BUCKET_NBITS-1:0] tunnel_hash_table1_rdata  /* synthesis DONT_TOUCH */;

wire tunnel_value_ack; 
wire [`TUNNEL_VALUE_NBITS-1:0] tunnel_value_rdata  /* synthesis DONT_TOUCH */;

wire ekey_hash_table0_ack; 
wire [EKEY_BUCKET_NBITS-1:0] ekey_hash_table0_rdata  /* synthesis DONT_TOUCH */;

wire ekey_hash_table1_ack; 
wire [EKEY_BUCKET_NBITS-1:0] ekey_hash_table1_rdata  /* synthesis DONT_TOUCH */;

wire ekey_value_ack; 
wire [EKEY_VALUE_NBITS-1:0] ekey_value_rdata  /* synthesis DONT_TOUCH */;

wire tunnel_hash_table0_rd; 
wire [RCI_DEPTH_NBITS-1:0] tunnel_hash_table0_raddr;

wire tunnel_hash_table1_rd; 
wire [RCI_DEPTH_NBITS-1:0] tunnel_hash_table1_raddr;

wire tunnel_value_rd; 
wire [RCI_VALUE_DEPTH_NBITS-1:0] tunnel_value_raddr;

wire ekey_hash_table0_rd; 
wire [EKEY_DEPTH_NBITS-1:0] ekey_hash_table0_raddr;

wire ekey_hash_table1_rd; 
wire [EKEY_DEPTH_NBITS-1:0] ekey_hash_table1_raddr;

wire ekey_value_rd; 
wire [EKEY_VALUE_DEPTH_NBITS-1:0] ekey_value_raddr;

wire ekey_value_wr; 
wire [EKEY_VALUE_DEPTH_NBITS-1:0] ekey_value_waddr;
wire [WR_NBITS-1:0] ekey_value_wdata;

wire [15:0] in_vlan;
wire [47:0] in_mac_sa;
wire [47:0] in_mac_da;
wire [47:0] mac_sa;
wire [63:0] ipsec_iv;
wire [31:0] gre_header;
wire [19:0] flow_label;
wire [15:0] identification;
wire [7:0] ttl;
wire [7:0] dscp_ecn;


/***************************** NON REGISTERED OUTPUTS ************************/

assign pio_ack = pio_ack0|pio_ack1;
assign pio_rvalid = pio_rvalid0|pio_rvalid1;
assign pio_rdata = pio_rvalid0?pio_rdata0:pio_rdata1;

/***************************** REGISTERED OUTPUTS ****************************/


/***************************** PROGRAM BODY **********************************/

pio2reg_bus #(
  .BLOCK_ADDR_LSB(`ENCR_BLOCK_ADDR_LSB),
  .BLOCK_ADDR(`ENCR_BLOCK_ADDR),
  .REG_BLOCK_ADDR_LSB(`ENCR_REG_BLOCK_ADDR_LSB),
  .REG_BLOCK_ADDR(`ENCR_REG_BLOCK_ADDR)
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
    .reg_bs(reg_bs)

);

encap_pio u_encap_pio(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_div(clk_div),

    .reg_bs(mem_bs),
    .reg_wr(reg_wr),
    .reg_rd(reg_rd),
    .reg_addr(reg_addr),
    .reg_din(reg_din),

    .tunnel_hash_table_mem_ack(tunnel_hash_table_mem_ack),
    .tunnel_value_mem_ack(tunnel_value_mem_ack),
    .ekey_hash_table_mem_ack(ekey_hash_table_mem_ack),
    .ekey_value_mem_ack(ekey_value_mem_ack),

    .tunnel_hash_table_mem_rdata(tunnel_hash_table_mem_rdata),
    .tunnel_value_mem_rdata(tunnel_value_mem_rdata),
    .ekey_hash_table_mem_rdata(ekey_hash_table_mem_rdata),
    .ekey_value_mem_rdata(ekey_value_mem_rdata),

    .reg_ms_tunnel_hash_table(reg_ms_tunnel_hash_table),
    .reg_ms_tunnel_value(reg_ms_tunnel_value),
    .reg_ms_ekey_hash_table(reg_ms_ekey_hash_table),
    .reg_ms_ekey_value(reg_ms_ekey_value),

    .pio_ack(pio_ack0),
    .pio_rvalid(pio_rvalid0),
    .pio_rdata(pio_rdata0)

);

encap_reg u_encap_reg(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_div(clk_div),

    .reg_bs(reg_bs),
    .reg_wr(reg_wr),
    .reg_rd(reg_rd),
    .reg_addr(reg_addr),
    .reg_din(reg_din),

    .in_vlan(in_vlan),
    .in_mac_da(in_mac_da),
    .in_mac_sa(in_mac_sa),
    .mac_sa(mac_sa),
    .ipsec_iv(ipsec_iv),
    .gre_header(gre_header),
    .flow_label(flow_label),
    .identification(identification),
    .ttl(ttl),
    .dscp_ecn(dscp_ecn),

    .pio_ack(pio_ack1),
    .pio_rvalid(pio_rvalid1),
    .pio_rdata(pio_rdata1)

);


encap_mem_tunnel u_encap_mem_tunnel(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_div(clk_div), 

    .reg_addr(reg_addr),
    .reg_din(reg_din),
    .reg_wr(reg_wr),
    .reg_rd(reg_rd),
    .reg_ms_tunnel_hash_table(reg_ms_tunnel_hash_table),
    .reg_ms_tunnel_value(reg_ms_tunnel_value),

    .tunnel_hash_table_mem_ack(tunnel_hash_table_mem_ack),
    .tunnel_hash_table_mem_rdata(tunnel_hash_table_mem_rdata),

    .tunnel_value_mem_ack(tunnel_value_mem_ack),
    .tunnel_value_mem_rdata(tunnel_value_mem_rdata),

    .tunnel_hash_table0_rd(tunnel_hash_table0_rd),
    .tunnel_hash_table0_raddr(tunnel_hash_table0_raddr),

    .tunnel_hash_table1_rd(tunnel_hash_table1_rd),
    .tunnel_hash_table1_raddr(tunnel_hash_table1_raddr),

    .tunnel_value_rd(tunnel_value_rd),
    .tunnel_value_raddr(tunnel_value_raddr),

    .tunnel_hash_table0_ack(tunnel_hash_table0_ack),
    .tunnel_hash_table0_rdata(tunnel_hash_table0_rdata),

    .tunnel_hash_table1_ack(tunnel_hash_table1_ack),
    .tunnel_hash_table1_rdata(tunnel_hash_table1_rdata),

    .tunnel_value_ack(tunnel_value_ack),
    .tunnel_value_rdata(tunnel_value_rdata)

);


encap_mem_ekey u_encap_mem_ekey(

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


encap_lookup u_encap_lookup(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .encr_ring_in_data(encr_ring_in_data),
    .encr_ring_in_sof(encr_ring_in_sof),
    .encr_ring_in_sos(encr_ring_in_sos),
    .encr_ring_in_valid(encr_ring_in_valid),
 
    .tunnel_hash_table0_ack(tunnel_hash_table0_ack),
    .tunnel_hash_table0_rdata(tunnel_hash_table0_rdata),

    .tunnel_hash_table1_ack(tunnel_hash_table1_ack),
    .tunnel_hash_table1_rdata(tunnel_hash_table1_rdata),

    .tunnel_value_ack(tunnel_value_ack),
    .tunnel_value_rdata(tunnel_value_rdata),

    .ekey_hash_table0_ack(ekey_hash_table0_ack),
    .ekey_hash_table0_rdata(ekey_hash_table0_rdata),

    .ekey_hash_table1_ack(ekey_hash_table1_ack),
    .ekey_hash_table1_rdata(ekey_hash_table1_rdata),

    .ekey_value_ack(ekey_value_ack),
    .ekey_value_rdata(ekey_value_rdata),


    .tunnel_hash_table0_rd(tunnel_hash_table0_rd),
    .tunnel_hash_table0_raddr(tunnel_hash_table0_raddr),

    .tunnel_hash_table1_rd(tunnel_hash_table1_rd),
    .tunnel_hash_table1_raddr(tunnel_hash_table1_raddr),

    .tunnel_value_rd(tunnel_value_rd),
    .tunnel_value_raddr(tunnel_value_raddr),

    .ekey_hash_table0_rd(ekey_hash_table0_rd),
    .ekey_hash_table0_raddr(ekey_hash_table0_raddr),

    .ekey_hash_table1_rd(ekey_hash_table1_rd),
    .ekey_hash_table1_raddr(ekey_hash_table1_raddr),

    .ekey_value_rd(ekey_value_rd),
    .ekey_value_raddr(ekey_value_raddr),

    .ekey_value_wr(ekey_value_wr),
    .ekey_value_waddr(ekey_value_waddr),
    .ekey_value_wdata(ekey_value_wdata),

    .encr_ring_out_data(encr_ring_out_data),
    .encr_ring_out_sof(encr_ring_out_sof),
    .encr_ring_out_sos(encr_ring_out_sos),
    .encr_ring_out_valid(encr_ring_out_valid)
 
);

encap_port #(.ENCRYPTOR_ID(0)) u_encap_port_0(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_mac(clk_mac), 

    .dstr_enc_data_valid(dstr_enc_data_valid0),
    .dstr_enc_packet_data(dstr_enc_packet_data0),
    .dstr_enc_sop(dstr_enc_sop0),
    .dstr_enc_eop(dstr_enc_eop0),
    .dstr_enc_valid_bytes(dstr_enc_valid_bytes0),
 
    .encr_ring_in_data(encr_ring_out_data),
    .encr_ring_in_sof(encr_ring_out_sof),
    .encr_ring_in_sos(encr_ring_out_sos),
    .encr_ring_in_valid(encr_ring_out_valid),

    .in_vlan(in_vlan),
    .in_mac_da(in_mac_da),
    .in_mac_sa(in_mac_sa),
    .mac_sa(mac_sa),
    .ipsec_iv(ipsec_iv),
    .gre_header(gre_header),
    .flow_label(flow_label),
    .identification(identification),
    .ttl(ttl),
    .dscp_ecn(dscp_ecn),

    .tx_axis_tready(tx_axis_tready0),

    .port_dstr_bp(port_dstr_bp[0]),

    .encr_ring_out_data(encr_ring_out_data0),
    .encr_ring_out_sof(encr_ring_out_sof0),
    .encr_ring_out_sos(encr_ring_out_sos0),
    .encr_ring_out_valid(encr_ring_out_valid0),
 
    .tx_axis_tdata(tx_axis_tdata0),
    .tx_axis_tkeep(tx_axis_tkeep0),
    .tx_axis_tvalid(tx_axis_tvalid0),
    .tx_axis_tuser(tx_axis_tuser0),
    .tx_axis_tlast(tx_axis_tlast0)

);

encap_port #(.ENCRYPTOR_ID(1)) u_encap_port_1(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_mac(clk_mac), 

    .dstr_enc_data_valid(dstr_enc_data_valid1),
    .dstr_enc_packet_data(dstr_enc_packet_data1),
    .dstr_enc_sop(dstr_enc_sop1),
    .dstr_enc_eop(dstr_enc_eop1),
    .dstr_enc_valid_bytes(dstr_enc_valid_bytes1),
 
    .encr_ring_in_data(encr_ring_out_data0),
    .encr_ring_in_sof(encr_ring_out_sof0),
    .encr_ring_in_sos(encr_ring_out_sos0),
    .encr_ring_in_valid(encr_ring_out_valid0),

    .in_vlan(in_vlan),
    .in_mac_da(in_mac_da),
    .in_mac_sa(in_mac_sa),
    .mac_sa(mac_sa),
    .ipsec_iv(ipsec_iv),
    .gre_header(gre_header),
    .flow_label(flow_label),
    .identification(identification),
    .ttl(ttl),
    .dscp_ecn(dscp_ecn),

    .tx_axis_tready(tx_axis_tready1),

    .port_dstr_bp(port_dstr_bp[1]),

    .encr_ring_out_data(encr_ring_out_data1),
    .encr_ring_out_sof(encr_ring_out_sof1),
    .encr_ring_out_sos(encr_ring_out_sos1),
    .encr_ring_out_valid(encr_ring_out_valid1),
 
    .tx_axis_tdata(tx_axis_tdata1),
    .tx_axis_tkeep(tx_axis_tkeep1),
    .tx_axis_tvalid(tx_axis_tvalid1),
    .tx_axis_tuser(tx_axis_tuser1),
    .tx_axis_tlast(tx_axis_tlast1)

);

gb_32to64 u_gb_32to64_2(

    .clk_mac(clk_mac), 

    .clk_axi(clk_axi), 
    .`RESET_SIG(`RESET_SIG), 

    .tx_axis_tdata(tx_axis_tdata2),
    .tx_axis_tkeep(tx_axis_tkeep2),
    .tx_axis_tvalid(tx_axis_tvalid2),
    .tx_axis_tuser(tx_axis_tuser2),
    .tx_axis_tlast(tx_axis_tlast2),

    .tx_axis_tready(tx_axis_tready2),

    .s_axis_c2h_tready_x(s_axis_c2h_tready_x0),

    .s_axis_c2h_tvalid_x(s_axis_c2h_tvalid_x0),
    .s_axis_c2h_tlast_x(s_axis_c2h_tlast_x0),
    .s_axis_c2h_tdata_x(s_axis_c2h_tdata_x0)

);

encap_port #(.ENCRYPTOR_ID(2)) u_encap_port_2(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_mac(clk_mac), 

    .dstr_enc_data_valid(dstr_enc_data_valid2&~dstr_enc_port_id2),
    .dstr_enc_packet_data(dstr_enc_packet_data2),
    .dstr_enc_sop(dstr_enc_sop2),
    .dstr_enc_eop(dstr_enc_eop2),
    .dstr_enc_valid_bytes(dstr_enc_valid_bytes2),
 
    .encr_ring_in_data(encr_ring_out_data1),
    .encr_ring_in_sof(encr_ring_out_sof1),
    .encr_ring_in_sos(encr_ring_out_sos1),
    .encr_ring_in_valid(encr_ring_out_valid1),

    .in_vlan(in_vlan),
    .in_mac_da(in_mac_da),
    .in_mac_sa(in_mac_sa),
    .mac_sa(mac_sa),
    .ipsec_iv(ipsec_iv),
    .gre_header(gre_header),
    .flow_label(flow_label),
    .identification(identification),
    .ttl(ttl),
    .dscp_ecn(dscp_ecn),

    .tx_axis_tready(tx_axis_tready2),

    .port_dstr_bp(port_dstr_bp[2]),

    .encr_ring_out_data(encr_ring_out_data2),
    .encr_ring_out_sof(encr_ring_out_sof2),
    .encr_ring_out_sos(encr_ring_out_sos2),
    .encr_ring_out_valid(encr_ring_out_valid2),
 
    .tx_axis_tdata(tx_axis_tdata2),
    .tx_axis_tkeep(tx_axis_tkeep2),
    .tx_axis_tvalid(tx_axis_tvalid2),
    .tx_axis_tuser(tx_axis_tuser2),
    .tx_axis_tlast(tx_axis_tlast2)

);

gb_32to64 u_gb_32to64_3(

    .clk_mac(clk_mac), 

    .clk_axi(clk_axi), 
    .`RESET_SIG(`RESET_SIG), 

    .tx_axis_tdata(tx_axis_tdata3),
    .tx_axis_tkeep(tx_axis_tkeep3),
    .tx_axis_tvalid(tx_axis_tvalid3),
    .tx_axis_tuser(tx_axis_tuser3),
    .tx_axis_tlast(tx_axis_tlast3),

    .tx_axis_tready(tx_axis_tready3),

    .s_axis_c2h_tready_x(s_axis_c2h_tready_x1),

    .s_axis_c2h_tvalid_x(s_axis_c2h_tvalid_x1),
    .s_axis_c2h_tlast_x(s_axis_c2h_tlast_x1),
    .s_axis_c2h_tdata_x(s_axis_c2h_tdata_x1)

);

encap_port #(.ENCRYPTOR_ID(3)) u_encap_port_3(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_mac(clk_mac), 

    .dstr_enc_data_valid(dstr_enc_data_valid2&dstr_enc_port_id2),
    .dstr_enc_packet_data(dstr_enc_packet_data2),
    .dstr_enc_sop(dstr_enc_sop2),
    .dstr_enc_eop(dstr_enc_eop2),
    .dstr_enc_valid_bytes(dstr_enc_valid_bytes2),
 
    .encr_ring_in_data(encr_ring_out_data2),
    .encr_ring_in_sof(encr_ring_out_sof2),
    .encr_ring_in_sos(encr_ring_out_sos2),
    .encr_ring_in_valid(encr_ring_out_valid2),

    .in_vlan(in_vlan),
    .in_mac_da(in_mac_da),
    .in_mac_sa(in_mac_sa),
    .mac_sa(mac_sa),
    .ipsec_iv(ipsec_iv),
    .gre_header(gre_header),
    .flow_label(flow_label),
    .identification(identification),
    .ttl(ttl),
    .dscp_ecn(dscp_ecn),

    .tx_axis_tready(tx_axis_tready3),

    .port_dstr_bp(port_dstr_bp[3]),

    .encr_ring_out_data(encr_ring_out_data3),
    .encr_ring_out_sof(encr_ring_out_sof3),
    .encr_ring_out_sos(encr_ring_out_sos3),
    .encr_ring_out_valid(encr_ring_out_valid3),
 
    .tx_axis_tdata(tx_axis_tdata3),
    .tx_axis_tkeep(tx_axis_tkeep3),
    .tx_axis_tvalid(tx_axis_tvalid3),
    .tx_axis_tuser(tx_axis_tuser3),
    .tx_axis_tlast(tx_axis_tlast3)

);

gb_32to64 u_gb_32to64_4(

    .clk_mac(clk_mac), 

    .clk_axi(clk_axi), 
    .`RESET_SIG(`RESET_SIG), 

    .tx_axis_tdata(tx_axis_tdata4),
    .tx_axis_tkeep(tx_axis_tkeep4),
    .tx_axis_tvalid(tx_axis_tvalid4),
    .tx_axis_tuser(tx_axis_tuser4),
    .tx_axis_tlast(tx_axis_tlast4),

    .tx_axis_tready(tx_axis_tready4),

    .s_axis_c2h_tready_x(s_axis_c2h_tready_x2),

    .s_axis_c2h_tvalid_x(s_axis_c2h_tvalid_x2),
    .s_axis_c2h_tlast_x(s_axis_c2h_tlast_x2),
    .s_axis_c2h_tdata_x(s_axis_c2h_tdata_x2)

);

encap_port #(.ENCRYPTOR_ID(4)) u_encap_port_4(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_mac(clk_mac), 

    .dstr_enc_data_valid(dstr_enc_data_valid3&(dstr_enc_port_id3==0)),
    .dstr_enc_packet_data(dstr_enc_packet_data3),
    .dstr_enc_sop(dstr_enc_sop3),
    .dstr_enc_eop(dstr_enc_eop3),
    .dstr_enc_valid_bytes(dstr_enc_valid_bytes3),
 
    .encr_ring_in_data(encr_ring_out_data3),
    .encr_ring_in_sof(encr_ring_out_sof3),
    .encr_ring_in_sos(encr_ring_out_sos3),
    .encr_ring_in_valid(encr_ring_out_valid3),

    .in_vlan(in_vlan),
    .in_mac_da(in_mac_da),
    .in_mac_sa(in_mac_sa),
    .mac_sa(mac_sa),
    .ipsec_iv(ipsec_iv),
    .gre_header(gre_header),
    .flow_label(flow_label),
    .identification(identification),
    .ttl(ttl),
    .dscp_ecn(dscp_ecn),

    .tx_axis_tready(tx_axis_tready4),

    .port_dstr_bp(port_dstr_bp[4]),

    .encr_ring_out_data(encr_ring_out_data4),
    .encr_ring_out_sof(encr_ring_out_sof4),
    .encr_ring_out_sos(encr_ring_out_sos4),
    .encr_ring_out_valid(encr_ring_out_valid4),
 
    .tx_axis_tdata(tx_axis_tdata4),
    .tx_axis_tkeep(tx_axis_tkeep4),
    .tx_axis_tvalid(tx_axis_tvalid4),
    .tx_axis_tuser(tx_axis_tuser4),
    .tx_axis_tlast(tx_axis_tlast4)

);

gb_32to64 u_gb_32to64_5(

    .clk_mac(clk_mac), 

    .clk_axi(clk_axi), 
    .`RESET_SIG(`RESET_SIG), 

    .tx_axis_tdata(tx_axis_tdata5),
    .tx_axis_tkeep(tx_axis_tkeep5),
    .tx_axis_tvalid(tx_axis_tvalid5),
    .tx_axis_tuser(tx_axis_tuser5),
    .tx_axis_tlast(tx_axis_tlast5),

    .tx_axis_tready(tx_axis_tready5),

    .s_axis_c2h_tready_x(s_axis_c2h_tready_x3),

    .s_axis_c2h_tvalid_x(s_axis_c2h_tvalid_x3),
    .s_axis_c2h_tlast_x(s_axis_c2h_tlast_x3),
    .s_axis_c2h_tdata_x(s_axis_c2h_tdata_x3)

);

encap_port #(.ENCRYPTOR_ID(5)) u_encap_port_5(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_mac(clk_mac), 

    .dstr_enc_data_valid(dstr_enc_data_valid3&(dstr_enc_port_id3==1)),
    .dstr_enc_packet_data(dstr_enc_packet_data3),
    .dstr_enc_sop(dstr_enc_sop3),
    .dstr_enc_eop(dstr_enc_eop3),
    .dstr_enc_valid_bytes(dstr_enc_valid_bytes3),
 
    .encr_ring_in_data(encr_ring_out_data4),
    .encr_ring_in_sof(encr_ring_out_sof4),
    .encr_ring_in_sos(encr_ring_out_sos4),
    .encr_ring_in_valid(encr_ring_out_valid4),

    .in_vlan(in_vlan),
    .in_mac_da(in_mac_da),
    .in_mac_sa(in_mac_sa),
    .mac_sa(mac_sa),
    .ipsec_iv(ipsec_iv),
    .gre_header(gre_header),
    .flow_label(flow_label),
    .identification(identification),
    .ttl(ttl),
    .dscp_ecn(dscp_ecn),

    .tx_axis_tready(tx_axis_tready5),

    .port_dstr_bp(port_dstr_bp[5]),

    .encr_ring_out_data(encr_ring_in_data),
    .encr_ring_out_sof(encr_ring_in_sof),
    .encr_ring_out_sos(encr_ring_in_sos),
    .encr_ring_out_valid(encr_ring_in_valid),
 
    .tx_axis_tdata(tx_axis_tdata5),
    .tx_axis_tkeep(tx_axis_tkeep5),
    .tx_axis_tvalid(tx_axis_tvalid5),
    .tx_axis_tuser(tx_axis_tuser5),
    .tx_axis_tlast(tx_axis_tlast5)

);


/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

