//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module mackinac_bw 

(

input clk, 
input `RESET_SIG,

input clk_mac, 
input clk_axi, 

input [`PORT_BUS_NBITS-1:0] rx_axis_tdata0,
input [3:0] rx_axis_tkeep0,
input rx_axis_tvalid0,
input rx_axis_tuser0,
input rx_axis_tlast0,

input [`PORT_BUS_NBITS-1:0] rx_axis_tdata1,
input [3:0] rx_axis_tkeep1,
input rx_axis_tvalid1,
input rx_axis_tuser1,
input rx_axis_tlast1,

input m_axis_h2c_tvalid_x0,
input m_axis_h2c_tlast_x0,
input [`DMA_BUS_NBITS-1:0] m_axis_h2c_tdata_x0,

output m_axis_h2c_tready_x0,

input m_axis_h2c_tvalid_x1,
input m_axis_h2c_tlast_x1,
input [`DMA_BUS_NBITS-1:0] m_axis_h2c_tdata_x1,

output m_axis_h2c_tready_x1,

input m_axis_h2c_tvalid_x2,
input m_axis_h2c_tlast_x2,
input [`DMA_BUS_NBITS-1:0] m_axis_h2c_tdata_x2,

output m_axis_h2c_tready_x2,

input m_axis_h2c_tvalid_x3,
input m_axis_h2c_tlast_x3,
input [`DMA_BUS_NBITS-1:0] m_axis_h2c_tdata_x3,

output m_axis_h2c_tready_x3,


output [`PORT_BUS_NBITS-1:0] tx_axis_tdata0,
output [3:0] tx_axis_tkeep0,
output tx_axis_tvalid0,
output tx_axis_tuser0,
output tx_axis_tlast0,

input tx_axis_tready0,

output [`PORT_BUS_NBITS-1:0] tx_axis_tdata1,
output [3:0] tx_axis_tkeep1,
output tx_axis_tvalid1,
output tx_axis_tuser1,
output tx_axis_tlast1,

input tx_axis_tready1,

output s_axis_c2h_tvalid_x0,
output s_axis_c2h_tlast_x0,
output [`DMA_BUS_NBITS-1:0] s_axis_c2h_tdata_x0,

input s_axis_c2h_tready_x0,

output s_axis_c2h_tvalid_x1,
output s_axis_c2h_tlast_x1,
output [`DMA_BUS_NBITS-1:0] s_axis_c2h_tdata_x1,

input s_axis_c2h_tready_x1,

output s_axis_c2h_tvalid_x2,
output s_axis_c2h_tlast_x2,
output [`DMA_BUS_NBITS-1:0] s_axis_c2h_tdata_x2,

input s_axis_c2h_tready_x2,

output s_axis_c2h_tvalid_x3,
output s_axis_c2h_tlast_x3,
output [`DMA_BUS_NBITS-1:0] s_axis_c2h_tdata_x3,

input s_axis_c2h_tready_x3,

input [`PIO_RANGE] m_axil_awaddr,
input m_axil_awvalid,
output m_axil_awready,
input [`PIO_RANGE] m_axil_wdata,
input m_axil_wstrb,
input m_axil_wvalid,
output m_axil_wready,
output m_axil_bvalid,
input m_axil_bready,

input [`PIO_RANGE] m_axil_araddr,
input m_axil_arvalid,
output m_axil_arready,
output [`PIO_RANGE] m_axil_rdata,
output m_axil_rresp,
output m_axil_rvalid,
input m_axil_rready

);

/***************************** LOCAL VARIABLES *******************************/

logic         pio_start;
logic         pio_rw;
logic [`PIO_RANGE] pio_addr_wdata;

logic [`NUM_OF_PIO-1:0] clk_div; 
logic [`NUM_OF_PIO-1:0] pio_ack; 
logic [`NUM_OF_PIO-1:0] pio_rvalid; 
logic [`PIO_RANGE] pio_rdata[`NUM_OF_PIO-1:0];

logic dec_aggr_data_valid0;
logic [`PORT_BUS_RANGE] dec_aggr_packet_data0;
logic dec_aggr_sop0;
logic dec_aggr_eop0;
logic [`PORT_BUS_VB_RANGE] dec_aggr_valid_bytes0;    
logic [`RCI_NBITS-1:0] dec_aggr_rci0;    
logic dec_aggr_error0;  

logic dec_aggr_data_valid1;
logic [`PORT_BUS_RANGE] dec_aggr_packet_data1;
logic dec_aggr_sop1;
logic dec_aggr_eop1;
logic [`PORT_BUS_VB_RANGE] dec_aggr_valid_bytes1;    
logic [`RCI_NBITS-1:0] dec_aggr_rci1;    
logic dec_aggr_error1;  

logic dec_aggr_data_valid2;
logic [`PORT_BUS_RANGE] dec_aggr_packet_data2;
logic dec_aggr_sop2;
logic dec_aggr_eop2;
logic [`PORT_BUS_VB_RANGE] dec_aggr_valid_bytes2;    
logic [`RCI_NBITS-1:0] dec_aggr_rci2;    
logic dec_aggr_error2;  

logic dec_aggr_data_valid3;
logic [`PORT_BUS_RANGE] dec_aggr_packet_data3;
logic dec_aggr_sop3;
logic dec_aggr_eop3;
logic [`PORT_BUS_VB_RANGE] dec_aggr_valid_bytes3;    
logic [`RCI_NBITS-1:0] dec_aggr_rci3;    
logic dec_aggr_error3;  

logic dec_aggr_data_valid4;
logic [`PORT_BUS_RANGE] dec_aggr_packet_data4;
logic dec_aggr_sop4;
logic dec_aggr_eop4;
logic [`PORT_BUS_VB_RANGE] dec_aggr_valid_bytes4;    
logic [`RCI_NBITS-1:0] dec_aggr_rci4;    
logic dec_aggr_error4;  

logic dec_aggr_data_valid5;
logic [`PORT_BUS_RANGE] dec_aggr_packet_data5;
logic dec_aggr_sop5;
logic dec_aggr_eop5;
logic [`PORT_BUS_VB_RANGE] dec_aggr_valid_bytes5;    
logic [`RCI_NBITS-1:0] dec_aggr_rci5;    
logic dec_aggr_error5;  

logic dec_aggr_data_valid6 = 0;
logic [`PORT_BUS_RANGE] dec_aggr_packet_data6 = 0;
logic dec_aggr_sop6 = 0;
logic dec_aggr_eop6 = 0;
logic [`PORT_BUS_VB_RANGE] dec_aggr_valid_bytes6 = 0;    
logic [`RCI_NBITS-1:0] dec_aggr_rci6 = 0;    
logic dec_aggr_error6 = 0;  

logic bm_aggr_buf_valid;        
logic [`BUF_PTR_RANGE] bm_aggr_buf_ptr;   
logic bm_aggr_buf_available;    

logic bm_aggr_rel_buf_valid;        
logic [`PORT_ID_RANGE] bm_aggr_rel_buf_port_id; 
logic [3:0] bm_aggr_rel_alpha;  

logic bm_ed_data_valid;
logic [`PORT_ID_NBITS-1:0] bm_ed_port_id;
logic bm_ed_sop;
logic bm_ed_eop;
logic [`DATA_PATH_VB_NBITS-1:0] bm_ed_valid_bytes;
logic [`DATA_PATH_NBITS-1:0] bm_ed_packet_data;

logic aggr_par_hdr_valid;
logic [`DATA_PATH_RANGE] aggr_par_hdr_data;
aggr_par_meta_type   aggr_par_meta_data;
logic aggr_par_sop;
logic aggr_par_eop;

logic aggr_bm_buf_req;

logic aggr_bm_packet_valid;
logic [`DATA_PATH_RANGE] aggr_bm_packet_data;
logic [`BUF_PTR_RANGE] aggr_bm_buf_ptr;    
logic [`BUF_PTR_LSB_RANGE] aggr_bm_buf_ptr_lsb;
logic [`PORT_ID_RANGE] aggr_bm_port_id;
logic aggr_bm_sop;

logic [`REAL_TIME_NBITS-1:0] current_time;

logic asa_classifier_valid;
logic [`FID_NBITS-1:0] asa_classifier_fid;

logic ecdsa_classifier_flow_valid;
logic [`FID_NBITS-1:0] ecdsa_classifier_fid;
logic [`EXP_TIME_NBITS-1:0] ecdsa_classifier_flow_etime;

logic ecdsa_classifier_topic_valid;
logic [`TID_NBITS-1:0] ecdsa_classifier_tid;
logic [`EXP_TIME_NBITS-1:0] ecdsa_classifier_topic_etime;


logic cla_supervisor_flow_valid;
logic [`FLOW_HASH_TABLE_DEPTH_NBITS-1:0] cla_supervisor_flow_hash0;
logic [`FLOW_HASH_TABLE_DEPTH_NBITS-1:0] cla_supervisor_flow_hash1;
logic [`FLOW_KEY_NBITS-1:0] cla_supervisor_flow_key;

logic cla_supervisor_topic_valid;
logic [`TOPIC_HASH_TABLE_DEPTH_NBITS-1:0] cla_supervisor_topic_hash0;
logic [`TOPIC_HASH_TABLE_DEPTH_NBITS-1:0] cla_supervisor_topic_hash1;
logic [`TOPIC_KEY_NBITS-1:0] cla_supervisor_topic_key;

logic cla_irl_valid;
logic [`DATA_PATH_RANGE] cla_irl_hdr_data;
cla_irl_meta_type   cla_irl_meta_data;
logic cla_irl_sop;
logic cla_irl_eop;

logic ecdsa_irl_fill_tb_src_wr; 
logic [`FLOW_VALUE_DEPTH_NBITS-1:0] ecdsa_irl_fill_tb_src_waddr;
logic [`FILL_TB_NBITS-1:0] ecdsa_irl_fill_tb_src_wdata;

logic irl_lh_valid;
logic [`DATA_PATH_RANGE] irl_lh_hdr_data;
irl_lh_meta_type   irl_lh_meta_data;
logic irl_lh_sop;
logic irl_lh_eop;

logic ecdsa_lh_wr;
logic [`FID_NBITS-1:0] ecdsa_lh_waddr;
logic [`LOGIC_HASH_NBITS-1:0] ecdsa_lh_wdata;
logic [`SERIAL_NUM_NBITS-1:0]   ecdsa_lh_sn_wdata;
logic [`PPL_NBITS-1:0]   ecdsa_lh_ppl_wdata;

logic lh_ecdsa_hash_valid;
logic [`LOGIC_HASH_NBITS-1:0] lh_ecdsa_hash_data;

logic ecdsa_lh_ready;

logic lh_pp_valid;
logic [`DATA_PATH_RANGE] lh_pp_hdr_data;
lh_pp_meta_type   lh_pp_meta_data;
logic lh_pp_sop;
logic lh_pp_eop;

logic lh_ecdsa_valid;
logic [`DATA_PATH_RANGE] lh_ecdsa_hdr_data;
lh_ecdsa_meta_type   lh_ecdsa_meta_data;
logic lh_ecdsa_sop;
logic lh_ecdsa_eop;

logic pp_ecdsa_ready;

logic      ecdsa_pp_valid;
logic      ecdsa_pp_sop;
logic      ecdsa_pp_eop;
logic [`DATA_PATH_RANGE] ecdsa_pp_data;
ecdsa_pp_meta_type ecdsa_pp_meta_data;
logic [`CHUNK_LEN_NBITS-1:0] ecdsa_pp_auth_len;

logic ecdsa_piarb_wr;
logic [`FID_NBITS-1:0] ecdsa_piarb_waddr;
logic [`FLOW_PU_NBITS-1:0] ecdsa_piarb_wdata;

logic         ecdsa_asa_fp_wr;
logic [`FID_NBITS-1:0] ecdsa_asa_fp_waddr;				
logic [`FLOW_POLICY2_NBITS-1:0] ecdsa_asa_fp_wdata;

logic     pu_pp_buf_fifo_rd;
logic [`PIARB_INST_BUF_FIFO_DEPTH_NBITS:0] pu_pp_inst_buf_fifo_count;

logic pp_pu_hop_valid;
logic [`HOP_INFO_RANGE] pp_pu_hop_data;
logic pp_pu_hop_sop;
logic pp_pu_hop_eop;
pp_piarb_meta_type pp_pu_meta_data;
logic [`CHUNK_LEN_NBITS-1:0] pp_pu_pp_loc;


logic  pp_pu_valid;
logic  pp_pu_sop;
logic  pp_pu_eop;
logic  [`DATA_PATH_RANGE] pp_pu_data;
logic  [`DATA_PATH_VB_RANGE] pp_pu_valid_bytes;
logic  pp_pu_inst_pd;
logic [`CHUNK_LEN_NBITS-1:0] pp_pu_pd_loc;
logic [`CHUNK_LEN_NBITS-1:0] pp_pu_pd_len;

logic piarb_asa_valid;
logic piarb_asa_type3;
logic [`PU_ID_NBITS-1:0] piarb_asa_pu_id;
piarb_asa_meta_type piarb_asa_meta_data;

logic pu_fid_done; 
logic [`PU_ID_NBITS-1:0] pu_id;
logic pu_fid_sel;

logic piarb_pu_valid;
logic [`PU_ID_NBITS-1:0] piarb_pu_pid;
logic piarb_pu_sop;
logic piarb_pu_eop;
logic piarb_pu_fid_sel;
logic [`HOP_INFO_NBITS-1:0] piarb_pu_data;

pu_hop_meta_type piarb_pu_meta_data;

logic piarb_pu_inst_valid;
logic [`PU_ID_NBITS-1:0] piarb_pu_inst_pid;
logic piarb_pu_inst_sop;
logic piarb_pu_inst_eop;
logic [`DATA_PATH_NBITS-1:0] piarb_pu_inst_data;
logic piarb_pu_inst_pd;

logic   asa_pu_table_wr;
logic [`RCI_NBITS-1:0] asa_pu_table_waddr;
logic [`SCI_NBITS-1:0] asa_pu_table_wdata;

logic pu_asa_start; 
logic pu_asa_valid; 
logic [`PU_ASA_NBITS-1:0] pu_asa_data; 
logic pu_asa_eop; 
logic [`PU_ID_NBITS-1:0] pu_asa_pu_id;

logic pu_em_data_valid;
logic pu_em_data_sop;
logic pu_em_data_eop;
logic [`PU_ID_NBITS-1:0] pu_em_port_id;        
logic [`DATA_PATH_NBITS-1:0] pu_em_packet_data;

logic em_asa_valid;
logic [`EM_BUF_PTR_NBITS-1:0] em_asa_buf_ptr;				
logic [`PU_ID_NBITS-1:0] em_asa_pu_id;				
logic [`PD_CHUNK_DEPTH_NBITS-1:0] em_asa_len;				
logic em_asa_discard;

logic asa_tm_poll_req;		
logic [`FIRST_LVL_QUEUE_ID_NBITS-1:0] asa_tm_poll_qid;				
logic [`PORT_ID_NBITS-1:0] asa_tm_poll_src_port;				

logic tm_asa_poll_ack;
logic tm_asa_poll_drop;
logic [`SECOND_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_conn_id;
logic [`THIRD_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_conn_group_id;
logic [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_port_queue_id;
logic [`PORT_ID_NBITS-1:0] tm_asa_poll_port_id;

logic asa_tm_enq_req;					
logic [`FIRST_LVL_QUEUE_ID_NBITS-1:0] asa_tm_enq_qid;				
logic [`SECOND_LVL_QUEUE_ID_NBITS-1:0] asa_tm_enq_conn_id;
logic [`THIRD_LVL_QUEUE_ID_NBITS-1:0] asa_tm_enq_conn_group_id;
logic [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] asa_tm_enq_port_queue_id;
enq_pkt_desc_type asa_tm_enq_desc;				

logic asa_em_read_count_valid;
logic [`EM_BUF_PTR_NBITS-1:0] asa_em_buf_ptr;
logic [`PORT_ID_NBITS-1:0] asa_em_rc_port_id;
logic [`READ_COUNT_NBITS-1:0] asa_em_read_count;
logic [`PD_CHUNK_DEPTH_NBITS-1:0] asa_em_pd_length;

logic asa_bm_read_count_valid;
logic [`READ_COUNT_NBITS-1:0] asa_bm_read_count;
logic [`PACKET_LENGTH_NBITS-1:0] asa_bm_packet_length;
logic [`PORT_ID_NBITS-1:0] asa_bm_rc_port_id;
logic [`BUF_PTR_NBITS-1:0] asa_bm_buf_ptr;

localparam ADDR_NBITS = `ENQ_ED_CMD_PD_BP_NBITS+`PD_CHUNK_DEPTH_NBITS-`DATA_PATH_VB_NBITS;

logic edit_mem_req;
logic [ADDR_NBITS-1:0] edit_mem_raddr;
logic [`PORT_ID_NBITS-1:0] edit_mem_port_id;
logic edit_mem_eop;

logic edit_mem_ack;
logic [`DATA_PATH_NBITS-1:0] edit_mem_rdata;

enq_ed_cmd_type bm_ed_cmd;

logic ed_dstr_data_valid;
logic [`DATA_PATH_NBITS-1:0] ed_dstr_packet_data;
logic [`PORT_ID_NBITS-1:0] ed_dstr_port_id;
logic ed_dstr_sop;
logic ed_dstr_eop;
logic [`RCI_NBITS-1:0] ed_dstr_rci;	
logic [`PACKET_LENGTH_NBITS-1:0] ed_dstr_pkt_len;	
logic [`DATA_PATH_VB_NBITS-1:0] ed_dstr_valid_bytes;

logic [`NUM_OF_PORTS-1:0] port_dstr_bp;

logic [`NUM_OF_PORTS-1:0] dstr_ed_bp;

logic dstr_enc_data_valid0;
logic [`PORT_BUS_RANGE] dstr_enc_packet_data0;
logic dstr_enc_sop0;
logic dstr_enc_eop0;
logic [`PORT_BUS_VB_RANGE] dstr_enc_valid_bytes0;	

logic dstr_enc_data_valid1;
logic [`PORT_BUS_RANGE] dstr_enc_packet_data1;
logic dstr_enc_sop1;
logic dstr_enc_eop1;
logic [`PORT_BUS_VB_RANGE] dstr_enc_valid_bytes1;	

logic dstr_enc_data_valid2;
logic [`PORT_BUS_RANGE] dstr_enc_packet_data2;
logic dstr_enc_sop2;
logic dstr_enc_eop2;
logic [`PORT_BUS_VB_RANGE] dstr_enc_valid_bytes2;	
logic dstr_enc_port_id2;

logic dstr_enc_data_valid3;
logic [`PORT_BUS_RANGE] dstr_enc_packet_data3;
logic dstr_enc_sop3;
logic dstr_enc_eop3;
logic [`PORT_BUS_VB_RANGE] dstr_enc_valid_bytes3;	
logic [1:0] dstr_enc_port_id3;

logic [`NUM_OF_PORTS-1:0] bm_tm_bp;

logic tm_bm_enq_req;
enq_pkt_desc_type tm_bm_enq_pkt_desc;
logic [`PORT_ID_NBITS-1:0] tm_bm_enq_src_port;
logic [`PORT_ID_NBITS-1:0] tm_bm_enq_dst_port;
logic [`PACKET_LENGTH_NBITS-1:0] tm_bm_enq_packet_len;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/


/***************************** PROGRAM BODY **********************************/

pio_bus u_pio_bus(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_axi(clk_axi), 

    .m_axil_awaddr(m_axil_awaddr),
    .m_axil_awvalid(m_axil_awvalid),
    .m_axil_awready(m_axil_awready),

    .m_axil_wdata(m_axil_wdata),
    .m_axil_wstrb(m_axil_wstrb),
    .m_axil_wvalid(m_axil_wvalid),
    .m_axil_wready(m_axil_wready),

    .m_axil_bvalid(m_axil_bvalid),
    .m_axil_bready(m_axil_bready),

    .m_axil_araddr(m_axil_araddr),
    .m_axil_arvalid(m_axil_arvalid),
    .m_axil_arready(m_axil_arready),

    .m_axil_rdata(m_axil_rdata),
    .m_axil_rresp(m_axil_rresp),
    .m_axil_rvalid(m_axil_rvalid),
    .m_axil_rready(m_axil_rready),

    .clk_div(clk_div),
    .pio_ack(pio_ack),
    .pio_rvalid(pio_rvalid),
    .pio_rdata(pio_rdata),

    .pio_start(pio_start),
    .pio_rw(pio_rw),
    .pio_addr_wdata(pio_addr_wdata),

    .current_time(current_time)
);

decap u_decap(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_mac(clk_mac), 
    .clk_axi(clk_axi), 

    .pio_start(pio_start),
    .pio_rw(pio_rw),
    .pio_addr_wdata(pio_addr_wdata),

    .clk_div(clk_div[0]),
 
    .pio_ack(pio_ack[0]),
    .pio_rvalid(pio_rvalid[0]),
    .pio_rdata(pio_rdata[0]),

    .rx_axis_tdata0(rx_axis_tdata0),
    .rx_axis_tkeep0(rx_axis_tkeep0),
    .rx_axis_tvalid0(rx_axis_tvalid0),
    .rx_axis_tuser0(rx_axis_tuser0),
    .rx_axis_tlast0(rx_axis_tlast0),

    .rx_axis_tdata1(rx_axis_tdata1),
    .rx_axis_tkeep1(rx_axis_tkeep1),
    .rx_axis_tvalid1(rx_axis_tvalid1),
    .rx_axis_tuser1(rx_axis_tuser1),
    .rx_axis_tlast1(rx_axis_tlast1),

    .m_axis_h2c_tvalid_x0(m_axis_h2c_tvalid_x0),
    .m_axis_h2c_tlast_x0(m_axis_h2c_tlast_x0),
    .m_axis_h2c_tdata_x0(m_axis_h2c_tdata_x0),

    .m_axis_h2c_tready_x0(m_axis_h2c_tready_x0),

    .m_axis_h2c_tvalid_x1(m_axis_h2c_tvalid_x1),
    .m_axis_h2c_tlast_x1(m_axis_h2c_tlast_x1),
    .m_axis_h2c_tdata_x1(m_axis_h2c_tdata_x1),

    .m_axis_h2c_tready_x1(m_axis_h2c_tready_x1),

    .m_axis_h2c_tvalid_x2(m_axis_h2c_tvalid_x2),
    .m_axis_h2c_tlast_x2(m_axis_h2c_tlast_x2),
    .m_axis_h2c_tdata_x2(m_axis_h2c_tdata_x2),

    .m_axis_h2c_tready_x2(m_axis_h2c_tready_x2),

    .m_axis_h2c_tvalid_x3(m_axis_h2c_tvalid_x3),
    .m_axis_h2c_tlast_x3(m_axis_h2c_tlast_x3),
    .m_axis_h2c_tdata_x3(m_axis_h2c_tdata_x3),

    .m_axis_h2c_tready_x3(m_axis_h2c_tready_x3),

    .dec_aggr_data_valid0(dec_aggr_data_valid0),
    .dec_aggr_packet_data0(dec_aggr_packet_data0),
    .dec_aggr_sop0(dec_aggr_sop0),
    .dec_aggr_eop0(dec_aggr_eop0),
    .dec_aggr_valid_bytes0(dec_aggr_valid_bytes0),
    .dec_aggr_rci0(dec_aggr_rci0),
    .dec_aggr_error0(dec_aggr_error0),
 
    .dec_aggr_data_valid1(dec_aggr_data_valid1),
    .dec_aggr_packet_data1(dec_aggr_packet_data1),
    .dec_aggr_sop1(dec_aggr_sop1),
    .dec_aggr_eop1(dec_aggr_eop1),
    .dec_aggr_valid_bytes1(dec_aggr_valid_bytes1),
    .dec_aggr_rci1(dec_aggr_rci1),
    .dec_aggr_error1(dec_aggr_error1),
 
    .dec_aggr_data_valid2(dec_aggr_data_valid2),
    .dec_aggr_packet_data2(dec_aggr_packet_data2),
    .dec_aggr_sop2(dec_aggr_sop2),
    .dec_aggr_eop2(dec_aggr_eop2),
    .dec_aggr_valid_bytes2(dec_aggr_valid_bytes2),
    .dec_aggr_rci2(dec_aggr_rci2),
    .dec_aggr_error2(dec_aggr_error2),
 
    .dec_aggr_data_valid3(dec_aggr_data_valid3),
    .dec_aggr_packet_data3(dec_aggr_packet_data3),
    .dec_aggr_sop3(dec_aggr_sop3),
    .dec_aggr_eop3(dec_aggr_eop3),
    .dec_aggr_valid_bytes3(dec_aggr_valid_bytes3),
    .dec_aggr_rci3(dec_aggr_rci3),
    .dec_aggr_error3(dec_aggr_error3),
 
    .dec_aggr_data_valid4(dec_aggr_data_valid4),
    .dec_aggr_packet_data4(dec_aggr_packet_data4),
    .dec_aggr_sop4(dec_aggr_sop4),
    .dec_aggr_eop4(dec_aggr_eop4),
    .dec_aggr_valid_bytes4(dec_aggr_valid_bytes4),
    .dec_aggr_rci4(dec_aggr_rci4),
    .dec_aggr_error4(dec_aggr_error4),
 
    .dec_aggr_data_valid5(dec_aggr_data_valid5),
    .dec_aggr_packet_data5(dec_aggr_packet_data5),
    .dec_aggr_sop5(dec_aggr_sop5),
    .dec_aggr_eop5(dec_aggr_eop5),
    .dec_aggr_valid_bytes5(dec_aggr_valid_bytes5),
    .dec_aggr_rci5(dec_aggr_rci5),
    .dec_aggr_error5(dec_aggr_error5)

);

aggr u_aggr(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .dec_aggr_data_valid0(dec_aggr_data_valid0),
    .dec_aggr_packet_data0(dec_aggr_packet_data0),
    .dec_aggr_sop0(dec_aggr_sop0),
    .dec_aggr_eop0(dec_aggr_eop0),
    .dec_aggr_valid_bytes0(dec_aggr_valid_bytes0),
    .dec_aggr_rci0(dec_aggr_rci0),
    .dec_aggr_error0(dec_aggr_error0),
 
    .dec_aggr_data_valid1(dec_aggr_data_valid1),
    .dec_aggr_packet_data1(dec_aggr_packet_data1),
    .dec_aggr_sop1(dec_aggr_sop1),
    .dec_aggr_eop1(dec_aggr_eop1),
    .dec_aggr_valid_bytes1(dec_aggr_valid_bytes1),
    .dec_aggr_rci1(dec_aggr_rci1),
    .dec_aggr_error1(dec_aggr_error1),
 
    .dec_aggr_data_valid2(dec_aggr_data_valid2),
    .dec_aggr_packet_data2(dec_aggr_packet_data2),
    .dec_aggr_sop2(dec_aggr_sop2),
    .dec_aggr_eop2(dec_aggr_eop2),
    .dec_aggr_valid_bytes2(dec_aggr_valid_bytes2),
    .dec_aggr_rci2(dec_aggr_rci2),
    .dec_aggr_error2(dec_aggr_error2),
 
    .dec_aggr_data_valid3(dec_aggr_data_valid3),
    .dec_aggr_packet_data3(dec_aggr_packet_data3),
    .dec_aggr_sop3(dec_aggr_sop3),
    .dec_aggr_eop3(dec_aggr_eop3),
    .dec_aggr_valid_bytes3(dec_aggr_valid_bytes3),
    .dec_aggr_rci3(dec_aggr_rci3),
    .dec_aggr_error3(dec_aggr_error3),
 
    .dec_aggr_data_valid4(dec_aggr_data_valid4),
    .dec_aggr_packet_data4(dec_aggr_packet_data4),
    .dec_aggr_sop4(dec_aggr_sop4),
    .dec_aggr_eop4(dec_aggr_eop4),
    .dec_aggr_valid_bytes4(dec_aggr_valid_bytes4),
    .dec_aggr_rci4(dec_aggr_rci4),
    .dec_aggr_error4(dec_aggr_error4),
 
    .dec_aggr_data_valid5(dec_aggr_data_valid5),
    .dec_aggr_packet_data5(dec_aggr_packet_data5),
    .dec_aggr_sop5(dec_aggr_sop5),
    .dec_aggr_eop5(dec_aggr_eop5),
    .dec_aggr_valid_bytes5(dec_aggr_valid_bytes5),
    .dec_aggr_rci5(dec_aggr_rci5),
    .dec_aggr_error5(dec_aggr_error5),

    .dec_aggr_data_valid6(dec_aggr_data_valid6),
    .dec_aggr_packet_data6(dec_aggr_packet_data6),
    .dec_aggr_sop6(dec_aggr_sop6),
    .dec_aggr_eop6(dec_aggr_eop6),
    .dec_aggr_valid_bytes6(dec_aggr_valid_bytes6),
    .dec_aggr_error6(dec_aggr_error6),

    .bm_aggr_buf_valid(bm_aggr_buf_valid),
    .bm_aggr_buf_ptr(bm_aggr_buf_ptr),
    .bm_aggr_buf_available(bm_aggr_buf_available),

    .bm_aggr_rel_buf_valid(bm_aggr_rel_buf_valid),
    .bm_aggr_rel_buf_port_id(bm_aggr_rel_buf_port_id),
    .bm_aggr_rel_alpha(bm_aggr_rel_alpha),

    .aggr_par_hdr_valid(aggr_par_hdr_valid),
    .aggr_par_hdr_data(aggr_par_hdr_data),
    .aggr_par_meta_data(aggr_par_meta_data),
    .aggr_par_sop(aggr_par_sop),
    .aggr_par_eop(aggr_par_eop),

    .aggr_port_bp(),

    .aggr_bm_buf_req(aggr_bm_buf_req),

    .aggr_bm_packet_valid(aggr_bm_packet_valid),
    .aggr_bm_packet_data(aggr_bm_packet_data),
    .aggr_bm_buf_ptr(aggr_bm_buf_ptr),
    .aggr_bm_buf_ptr_lsb(aggr_bm_buf_ptr_lsb),
    .aggr_bm_port_id(aggr_bm_port_id),
    .aggr_bm_sop(aggr_bm_sop)

);

classifier u_classifier(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG),

    .pio_start(pio_start),
    .pio_rw(pio_rw),
    .pio_addr_wdata(pio_addr_wdata),

    .clk_div(clk_div[1]),
 
    .pio_ack(pio_ack[1]),
    .pio_rvalid(pio_rvalid[1]),
    .pio_rdata(pio_rdata[1]),

    .current_time(current_time),

    .aggr_par_hdr_valid(aggr_par_hdr_valid),
    .aggr_par_hdr_data(aggr_par_hdr_data),
    .aggr_par_meta_data(aggr_par_meta_data),
    .aggr_par_sop(aggr_par_sop),
    .aggr_par_eop(aggr_par_eop),

    .asa_classifier_valid(asa_classifier_valid),
    .asa_classifier_fid(asa_classifier_fid),

    .ecdsa_classifier_flow_valid(ecdsa_classifier_flow_valid),
    .ecdsa_classifier_fid(ecdsa_classifier_fid),
    .ecdsa_classifier_flow_etime(ecdsa_classifier_flow_etime),

    .ecdsa_classifier_topic_valid(ecdsa_classifier_topic_valid),
    .ecdsa_classifier_tid(ecdsa_classifier_tid),
    .ecdsa_classifier_topic_etime(ecdsa_classifier_topic_etime),

    .cla_supervisor_flow_valid(cla_supervisor_flow_valid),
    .cla_supervisor_flow_hash0(cla_supervisor_flow_hash0),
    .cla_supervisor_flow_hash1(cla_supervisor_flow_hash1),
    .cla_supervisor_flow_key(cla_supervisor_flow_key),

    .cla_supervisor_topic_valid(cla_supervisor_topic_valid),
    .cla_supervisor_topic_hash0(cla_supervisor_topic_hash0),
    .cla_supervisor_topic_hash1(cla_supervisor_topic_hash1),
    .cla_supervisor_topic_key(cla_supervisor_topic_key),

    .cla_irl_valid(cla_irl_valid),
    .cla_irl_hdr_data(cla_irl_hdr_data),
    .cla_irl_meta_data(cla_irl_meta_data),
    .cla_irl_sop(cla_irl_sop),
    .cla_irl_eop(cla_irl_eop)

);

irl u_irl(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG),

    .pio_start(pio_start),
    .pio_rw(pio_rw),
    .pio_addr_wdata(pio_addr_wdata),

    .clk_div(clk_div[2]),
 
    .pio_ack(pio_ack[2]),
    .pio_rvalid(pio_rvalid[2]),
    .pio_rdata(pio_rdata[2]),

    .ecdsa_irl_fill_tb_src_wr(ecdsa_irl_fill_tb_src_wr),
    .ecdsa_irl_fill_tb_src_waddr(ecdsa_irl_fill_tb_src_waddr),
    .ecdsa_irl_fill_tb_src_wdata(ecdsa_irl_fill_tb_src_wdata),

    .cla_irl_valid(cla_irl_valid),
    .cla_irl_hdr_data(cla_irl_hdr_data),
    .cla_irl_meta_data(cla_irl_meta_data),
    .cla_irl_sop(cla_irl_sop),
    .cla_irl_eop(cla_irl_eop),

    .irl_lh_valid(irl_lh_valid),
    .irl_lh_hdr_data(irl_lh_hdr_data),
    .irl_lh_meta_data(irl_lh_meta_data),
    .irl_lh_sop(irl_lh_sop),
    .irl_lh_eop(irl_lh_eop)

);

logic_hash u_logic_hash(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG),

    .ecdsa_lh_wr(ecdsa_lh_wr),
    .ecdsa_lh_waddr(ecdsa_lh_waddr),
    .ecdsa_lh_wdata(ecdsa_lh_wdata),
    .ecdsa_lh_sn_wdata(ecdsa_lh_sn_wdata),
    .ecdsa_lh_ppl_wdata(ecdsa_lh_ppl_wdata),

    .irl_lh_valid(irl_lh_valid),
    .irl_lh_hdr_data(irl_lh_hdr_data),
    .irl_lh_meta_data(irl_lh_meta_data),
    .irl_lh_sop(irl_lh_sop),
    .irl_lh_eop(irl_lh_eop),

    .lh_ecdsa_hash_valid(lh_ecdsa_hash_valid),
    .lh_ecdsa_hash_data(lh_ecdsa_hash_data),

    .ecdsa_lh_ready(ecdsa_lh_ready),

    .lh_pp_valid(lh_pp_valid),
    .lh_pp_hdr_data(lh_pp_hdr_data),
    .lh_pp_meta_data(lh_pp_meta_data),
    .lh_pp_sop(lh_pp_sop),
    .lh_pp_eop(lh_pp_eop),

    .lh_ecdsa_valid(lh_ecdsa_valid),
    .lh_ecdsa_hdr_data(lh_ecdsa_hdr_data),
    .lh_ecdsa_meta_data(lh_ecdsa_meta_data),
    .lh_ecdsa_sop(lh_ecdsa_sop),
    .lh_ecdsa_eop(lh_ecdsa_eop)

);

ecdsa u_ecdsa(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG),

    .pio_start(pio_start),
    .pio_rw(pio_rw),
    .pio_addr_wdata(pio_addr_wdata),

    .clk_div(clk_div[3]),
    .pio_ack(pio_ack[3]),
    .pio_rvalid(pio_rvalid[3]),
    .pio_rdata(pio_rdata[3]),

    .current_time(current_time),

    .lh_ecdsa_hash_valid(lh_ecdsa_hash_valid),
    .lh_ecdsa_hash_data(lh_ecdsa_hash_data),

    .lh_ecdsa_valid(lh_ecdsa_valid),
    .lh_ecdsa_hdr_data(lh_ecdsa_hdr_data),
    .lh_ecdsa_meta_data(lh_ecdsa_meta_data),
    .lh_ecdsa_sop(lh_ecdsa_sop),
    .lh_ecdsa_eop(lh_ecdsa_eop),

    .pp_ecdsa_ready(pp_ecdsa_ready),

    .ecdsa_pp_valid(ecdsa_pp_valid),
    .ecdsa_pp_data(ecdsa_pp_data),
    .ecdsa_pp_meta_data(ecdsa_pp_meta_data),
    .ecdsa_pp_sop(ecdsa_pp_sop),
    .ecdsa_pp_eop(ecdsa_pp_eop),
    .ecdsa_pp_auth_len(ecdsa_pp_auth_len),

    .ecdsa_lh_ready(ecdsa_lh_ready),

    .ecdsa_classifier_flow_valid(ecdsa_classifier_flow_valid),
    .ecdsa_classifier_fid(ecdsa_classifier_fid),
    .ecdsa_classifier_flow_etime(ecdsa_classifier_flow_etime),

    .ecdsa_classifier_topic_valid(ecdsa_classifier_topic_valid),
    .ecdsa_classifier_tid(ecdsa_classifier_tid),
    .ecdsa_classifier_topic_etime(ecdsa_classifier_topic_etime),

    .ecdsa_irl_fill_tb_src_wr(ecdsa_irl_fill_tb_src_wr),
    .ecdsa_irl_fill_tb_src_waddr(ecdsa_irl_fill_tb_src_waddr),
    .ecdsa_irl_fill_tb_src_wdata(ecdsa_irl_fill_tb_src_wdata),

    .ecdsa_lh_wr(ecdsa_lh_wr),
    .ecdsa_lh_waddr(ecdsa_lh_waddr),
    .ecdsa_lh_wdata(ecdsa_lh_wdata),
    .ecdsa_lh_sn_wdata(ecdsa_lh_sn_wdata),
    .ecdsa_lh_ppl_wdata(ecdsa_lh_ppl_wdata),

    .ecdsa_piarb_wr(ecdsa_piarb_wr),
    .ecdsa_piarb_waddr(ecdsa_piarb_waddr),
    .ecdsa_piarb_wdata(ecdsa_piarb_wdata),

    .ecdsa_asa_fp_wr(ecdsa_asa_fp_wr),
    .ecdsa_asa_fp_waddr(ecdsa_asa_fp_waddr),
    .ecdsa_asa_fp_wdata(ecdsa_asa_fp_wdata)

);

pp u_pp(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG),

    .ecdsa_pp_valid(ecdsa_pp_valid),
    .ecdsa_pp_data(ecdsa_pp_data),
    .ecdsa_pp_meta_data(ecdsa_pp_meta_data),
    .ecdsa_pp_sop(ecdsa_pp_sop),
    .ecdsa_pp_eop(ecdsa_pp_eop),
    .ecdsa_pp_auth_len(ecdsa_pp_auth_len),

    .lh_pp_valid(lh_pp_valid),
    .lh_pp_hdr_data(lh_pp_hdr_data),
    .lh_pp_meta_data(lh_pp_meta_data),
    .lh_pp_sop(lh_pp_sop),
    .lh_pp_eop(lh_pp_eop),

    .pu_pp_buf_fifo_rd(pu_pp_buf_fifo_rd),
    .pu_pp_inst_buf_fifo_count(pu_pp_inst_buf_fifo_count),

    .pp_ecdsa_ready(pp_ecdsa_ready),

    .pp_pu_hop_valid(pp_pu_hop_valid),
    .pp_pu_hop_data(pp_pu_hop_data),
    .pp_pu_hop_sop(pp_pu_hop_sop),
    .pp_pu_hop_eop(pp_pu_hop_eop),
    .pp_pu_meta_data(pp_pu_meta_data),
    .pp_pu_pp_loc(pp_pu_pp_loc),

    .pp_pu_valid(pp_pu_valid),
    .pp_pu_sop(pp_pu_sop),
    .pp_pu_eop(pp_pu_eop),
    .pp_pu_data(pp_pu_data),
    .pp_pu_valid_bytes(pp_pu_valid_bytes),
    .pp_pu_pd_loc(pp_pu_pd_loc),
    .pp_pu_inst_pd(pp_pu_inst_pd)

);

piarb u_piarb(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG),

    .pio_start(pio_start),
    .pio_rw(pio_rw),
    .pio_addr_wdata(pio_addr_wdata),

    .clk_div(clk_div[4]),
    .pio_ack(pio_ack[4]),
    .pio_rvalid(pio_rvalid[4]),
    .pio_rdata(pio_rdata[4]),

    .ecdsa_piarb_wr(ecdsa_piarb_wr),
    .ecdsa_piarb_waddr(ecdsa_piarb_waddr),
    .ecdsa_piarb_wdata(ecdsa_piarb_wdata),

    .pp_pu_hop_valid(pp_pu_hop_valid),
    .pp_pu_hop_data(pp_pu_hop_data),
    .pp_pu_hop_sop(pp_pu_hop_sop),
    .pp_pu_hop_eop(pp_pu_hop_eop),
    .pp_pu_meta_data(pp_pu_meta_data),
    .pp_pu_pp_loc(pp_pu_pp_loc),

    .pp_pu_valid(pp_pu_valid),
    .pp_pu_sop(pp_pu_sop),
    .pp_pu_eop(pp_pu_eop),
    .pp_pu_data(pp_pu_data),
    .pp_pu_valid_bytes(pp_pu_valid_bytes),
    .pp_pu_pd_loc(pp_pu_pd_loc),
    .pp_pu_inst_pd(pp_pu_inst_pd),

    .pu_fid_done(pu_fid_done),
    .pu_id(pu_id),
    .pu_fid_sel(pu_fid_sel),

    .piarb_asa_valid(piarb_asa_valid),
    .piarb_asa_type3(piarb_asa_type3),
    .piarb_asa_pu_id(piarb_asa_pu_id),
    .piarb_asa_meta_data(piarb_asa_meta_data),

    .pu_pp_buf_fifo_rd(pu_pp_buf_fifo_rd),
    .pu_pp_inst_buf_fifo_count(pu_pp_inst_buf_fifo_count),

    .piarb_pu_valid(piarb_pu_valid),
    .piarb_pu_pid(piarb_pu_pid),
    .piarb_pu_sop(piarb_pu_sop),
    .piarb_pu_eop(piarb_pu_eop),
    .piarb_pu_fid_sel(piarb_pu_fid_sel),
    .piarb_pu_data(piarb_pu_data),
    
    .piarb_pu_meta_data(piarb_pu_meta_data),

    .piarb_pu_inst_valid(piarb_pu_inst_valid),
    .piarb_pu_inst_pid(piarb_pu_inst_pid),
    .piarb_pu_inst_sop(piarb_pu_inst_sop),
    .piarb_pu_inst_eop(piarb_pu_inst_eop),
    .piarb_pu_inst_data(piarb_pu_inst_data),
    .piarb_pu_inst_pd(piarb_pu_inst_pd)
    
);

pu u_pu(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG),

    .pio_start(pio_start),
    .pio_rw(pio_rw),
    .pio_addr_wdata(pio_addr_wdata),

    .clk_div(clk_div[5]),
 
    .pio_ack(pio_ack[5]),
    .pio_rvalid(pio_rvalid[5]),
    .pio_rdata(pio_rdata[5]),

    .asa_pu_table_wr(asa_pu_table_wr),
    .asa_pu_table_waddr(asa_pu_table_waddr),
    .asa_pu_table_wdata(asa_pu_table_wdata),

    .piarb_pu_valid(piarb_pu_valid),
    .piarb_pu_pid(piarb_pu_pid),
    .piarb_pu_sop(piarb_pu_sop),
    .piarb_pu_eop(piarb_pu_eop),
    .piarb_pu_fid_sel(piarb_pu_fid_sel),
    .piarb_pu_data(piarb_pu_data),
    
    .piarb_pu_meta_data(piarb_pu_meta_data),

    .piarb_pu_inst_valid(piarb_pu_inst_valid),
    .piarb_pu_inst_pid(piarb_pu_inst_pid),
    .piarb_pu_inst_sop(piarb_pu_inst_sop),
    .piarb_pu_inst_eop(piarb_pu_inst_eop),
    .piarb_pu_inst_data(piarb_pu_inst_data),
    .piarb_pu_inst_pd(piarb_pu_inst_pd),
    
    .pu_asa_start(pu_asa_start),
    .pu_asa_valid(pu_asa_valid),
    .pu_asa_data(pu_asa_data),
    .pu_asa_eop(pu_asa_eop),
    .pu_asa_pu_id(pu_asa_pu_id),
    
    .pu_em_data_valid(pu_em_data_valid),
    .pu_em_sop(pu_em_sop),
    .pu_em_eop(pu_em_eop),
    .pu_em_port_id(pu_em_port_id),
    .pu_em_packet_data(pu_em_packet_data),
    
    .pu_fid_done(pu_fid_done),
    .pu_id(pu_id),
    .pu_fid_sel(pu_fid_sel)

);

asa u_asa(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG),

    .pio_start(pio_start),
    .pio_rw(pio_rw),
    .pio_addr_wdata(pio_addr_wdata),

    .clk_div(clk_div[6]),
    .pio_ack(pio_ack[6]),
    .pio_rvalid(pio_rvalid[6]),
    .pio_rdata(pio_rdata[6]),

    .current_time(current_time),

    .ecdsa_asa_fp_wr(ecdsa_asa_fp_wr),
    .ecdsa_asa_fp_waddr(ecdsa_asa_fp_waddr),
    .ecdsa_asa_fp_wdata(ecdsa_asa_fp_wdata),

    .pu_asa_start(pu_asa_start),
    .pu_asa_valid(pu_asa_valid),
    .pu_asa_data(pu_asa_data),
    .pu_asa_eop(pu_asa_eop),
    .pu_asa_pu_id(pu_asa_pu_id),
    
    .em_asa_valid(em_asa_valid),
    .em_asa_buf_ptr(em_asa_buf_ptr),
    .em_asa_pu_id(em_asa_pu_id),
    .em_asa_len(em_asa_len),
    .em_asa_discard(em_asa_discard),
    
    .piarb_asa_valid(piarb_asa_valid),
    .piarb_asa_type3(piarb_asa_type3),
    .piarb_asa_pu_id(piarb_asa_pu_id),
    .piarb_asa_meta_data(piarb_asa_meta_data),

    .tm_asa_poll_ack(tm_asa_poll_ack),
    .tm_asa_poll_drop(tm_asa_poll_drop),
    .tm_asa_poll_conn_id(tm_asa_poll_conn_id),
    .tm_asa_poll_conn_group_id(tm_asa_poll_conn_group_id),
    .tm_asa_poll_port_queue_id(tm_asa_poll_port_queue_id),
    .tm_asa_poll_port_id(tm_asa_poll_port_id),

    .asa_pu_table_wr(asa_pu_table_wr),
    .asa_pu_table_waddr(asa_pu_table_waddr),
    .asa_pu_table_wdata(asa_pu_table_wdata),

    .asa_classifier_valid(asa_classifier_valid),
    .asa_classifier_fid(asa_classifier_fid),

    .int_rep_bp(),

    .asa_tm_poll_req(asa_tm_poll_req),
    .asa_tm_poll_qid(asa_tm_poll_qid),
    .asa_tm_poll_src_port(asa_tm_poll_src_port),

    .asa_tm_enq_req(asa_tm_enq_req),
    .asa_tm_enq_qid(asa_tm_enq_qid),
    .asa_tm_enq_conn_id(asa_tm_enq_conn_id),
    .asa_tm_enq_conn_group_id(asa_tm_enq_conn_group_id),
    .asa_tm_enq_port_queue_id(asa_tm_enq_port_queue_id),
    .asa_tm_enq_desc(asa_tm_enq_desc),

    .asa_em_read_count_valid(asa_em_read_count_valid),
    .asa_em_buf_ptr(asa_em_buf_ptr),
    .asa_em_rc_port_id(asa_em_rc_port_id),
    .asa_em_read_count(asa_em_read_count),
    .asa_em_pd_length(asa_em_pd_length),

    .asa_bm_read_count_valid(asa_bm_read_count_valid),
    .asa_bm_read_count(asa_bm_read_count),
    .asa_bm_packet_length(asa_bm_packet_length),
    .asa_bm_rc_port_id(asa_bm_rc_port_id),
    .asa_bm_buf_ptr(asa_bm_buf_ptr)
    
);

tm u_tm(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG),

    .pio_start(pio_start),
    .pio_rw(pio_rw),
    .pio_addr_wdata(pio_addr_wdata),

    .clk_div(clk_div[7]),
 
    .pio_ack(pio_ack[7]),
    .pio_rvalid(pio_rvalid[7]),
    .pio_rdata(pio_rdata[7]),

    .bm_tm_bp(bm_tm_bp),

    .asa_tm_poll_req(asa_tm_poll_req),
    .asa_tm_poll_qid(asa_tm_poll_qid),
    .asa_tm_poll_src_port(asa_tm_poll_src_port),

    .asa_tm_enq_req(asa_tm_enq_req),
    .asa_tm_enq_qid(asa_tm_enq_qid),
    .asa_tm_enq_conn_id(asa_tm_enq_conn_id),
    .asa_tm_enq_conn_group_id(asa_tm_enq_conn_group_id),
    .asa_tm_enq_port_queue_id(asa_tm_enq_port_queue_id),
    .asa_tm_enq_desc(asa_tm_enq_desc),

    .tm_asa_poll_ack(tm_asa_poll_ack),
    .tm_asa_poll_drop(tm_asa_poll_drop),
    .tm_asa_poll_conn_id(tm_asa_poll_conn_id),
    .tm_asa_poll_conn_group_id(tm_asa_poll_conn_group_id),
    .tm_asa_poll_port_queue_id(tm_asa_poll_port_queue_id),
    .tm_asa_poll_port_id(tm_asa_poll_port_id),

    .tm_bm_enq_req(tm_bm_enq_req),
    .tm_bm_enq_pkt_desc(tm_bm_enq_pkt_desc)
    
);

bm u_bm(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG),

    .pio_start(pio_start),
    .pio_rw(pio_rw),
    .pio_addr_wdata(pio_addr_wdata),

    .clk_div(clk_div[8]),
 
    .pio_ack(pio_ack[8]),
    .pio_rvalid(pio_rvalid[8]),
    .pio_rdata(pio_rdata[8]),

    .aggr_bm_packet_valid(aggr_bm_packet_valid),
    .aggr_bm_packet_data(aggr_bm_packet_data),
    .aggr_bm_buf_ptr(aggr_bm_buf_ptr),
    .aggr_bm_buf_ptr_lsb(aggr_bm_buf_ptr_lsb),
    .aggr_bm_port_id(aggr_bm_port_id),
    .aggr_bm_sop(aggr_bm_sop),

    .aggr_bm_buf_req(aggr_bm_buf_req),

    .ed_bm_bp(dstr_ed_bp),
    .asa_bm_bp(1'b0),

    .asa_bm_read_count_valid(asa_bm_read_count_valid),
    .asa_bm_rc_port_id(asa_bm_rc_port_id),
    .asa_bm_buf_ptr(asa_bm_buf_ptr),
    .asa_bm_read_count(asa_bm_read_count),
    .asa_bm_packet_length(asa_bm_packet_length),

    .tm_bm_enq_req(tm_bm_enq_req),
    .tm_bm_enq_pkt_desc(tm_bm_enq_pkt_desc),
    
    .bm_tm_bp(bm_tm_bp),

    .bm_aggr_rel_buf_valid(bm_aggr_rel_buf_valid),
    .bm_aggr_rel_buf_port_id(bm_aggr_rel_buf_port_id),
    .bm_aggr_rel_alpha(bm_aggr_rel_alpha),

    .bm_aggr_buf_valid(bm_aggr_buf_valid),
    .bm_aggr_buf_ptr(bm_aggr_buf_ptr),
    .bm_aggr_buf_available(bm_aggr_buf_available),

    .bm_ed_data_valid(bm_ed_data_valid),
    .bm_ed_port_id(bm_ed_port_id),
    .bm_ed_sop(bm_ed_sop),
    .bm_ed_eop(bm_ed_eop),
    .bm_ed_valid_bytes(bm_ed_valid_bytes),
    .bm_ed_packet_data(bm_ed_packet_data),

    .bm_ed_cmd(bm_ed_cmd)

);

edit_mem u_edit_mem(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG),

    .pu_em_data_valid(pu_em_data_valid),
    .pu_em_sop(pu_em_sop),
    .pu_em_eop(pu_em_eop),
    .pu_em_port_id(pu_em_port_id),
    .pu_em_packet_data(pu_em_packet_data),
    
    .asa_em_read_count_valid(asa_em_read_count_valid),
    .asa_em_read_count(asa_em_read_count),
    .asa_em_pd_length(asa_em_pd_length),
    .asa_em_rc_port_id(asa_em_rc_port_id),
    .asa_em_buf_ptr(asa_em_buf_ptr),

    .edit_mem_req(edit_mem_req),
    .edit_mem_raddr(edit_mem_raddr),
    .edit_mem_port_id(edit_mem_port_id),
    .edit_mem_eop(edit_mem_eop),
    
    .em_asa_valid(em_asa_valid),
    .em_asa_buf_ptr(em_asa_buf_ptr),
    .em_asa_pu_id(em_asa_pu_id),
    .em_asa_len(em_asa_len),
    .em_asa_discard(em_asa_discard),

    .edit_mem_ack(edit_mem_ack),
    .edit_mem_rdata(edit_mem_rdata)
    
);

editor u_editor(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG),

    .bm_ed_data_valid(bm_ed_data_valid),
    .bm_ed_port_id(bm_ed_port_id),
    .bm_ed_sop(bm_ed_sop),
    .bm_ed_eop(bm_ed_eop),
    .bm_ed_valid_bytes(bm_ed_valid_bytes),
    .bm_ed_packet_data(bm_ed_packet_data),

    .bm_ed_cmd(bm_ed_cmd),

    .edit_mem_ack(edit_mem_ack),
    .edit_mem_rdata(edit_mem_rdata),
    
    .edit_mem_req(edit_mem_req),
    .edit_mem_raddr(edit_mem_raddr),
    .edit_mem_port_id(edit_mem_port_id),
    .edit_mem_eop(edit_mem_eop),
    
    .ed_dstr_data_valid(ed_dstr_data_valid),
    .ed_dstr_packet_data(ed_dstr_packet_data),
    .ed_dstr_port_id(ed_dstr_port_id),
    .ed_dstr_sop(ed_dstr_sop),
    .ed_dstr_eop(ed_dstr_eop),
    .ed_dstr_rci(ed_dstr_rci),
    .ed_dstr_pkt_len(ed_dstr_pkt_len),
    .ed_dstr_valid_bytes(ed_dstr_valid_bytes)
    
);


dstr u_dstr(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG),

    .ed_dstr_data_valid(ed_dstr_data_valid),
    .ed_dstr_packet_data(ed_dstr_packet_data),
    .ed_dstr_port_id(ed_dstr_port_id),
    .ed_dstr_sop(ed_dstr_sop),
    .ed_dstr_eop(ed_dstr_eop),
    .ed_dstr_rci(ed_dstr_rci),
    .ed_dstr_pkt_len(ed_dstr_pkt_len),
    .ed_dstr_valid_bytes(ed_dstr_valid_bytes),

    .port_dstr_bp(port_dstr_bp),

    .dstr_ed_bp(dstr_ed_bp),

    .dstr_enc_data_valid0(dstr_enc_data_valid0),
    .dstr_enc_packet_data0(dstr_enc_packet_data0),
    .dstr_enc_sop0(dstr_enc_sop0),
    .dstr_enc_eop0(dstr_enc_eop0),
    .dstr_enc_valid_bytes0(dstr_enc_valid_bytes0),

    .dstr_enc_data_valid1(dstr_enc_data_valid1),
    .dstr_enc_packet_data1(dstr_enc_packet_data1),
    .dstr_enc_sop1(dstr_enc_sop1),
    .dstr_enc_eop1(dstr_enc_eop1),
    .dstr_enc_valid_bytes1(dstr_enc_valid_bytes1),

    .dstr_enc_data_valid2(dstr_enc_data_valid2),
    .dstr_enc_packet_data2(dstr_enc_packet_data2),
    .dstr_enc_sop2(dstr_enc_sop2),
    .dstr_enc_eop2(dstr_enc_eop2),
    .dstr_enc_valid_bytes2(dstr_enc_valid_bytes2),
    .dstr_enc_port_id2(dstr_enc_port_id2),

    .dstr_enc_data_valid3(dstr_enc_data_valid3),
    .dstr_enc_packet_data3(dstr_enc_packet_data3),
    .dstr_enc_sop3(dstr_enc_sop3),
    .dstr_enc_eop3(dstr_enc_eop3),
    .dstr_enc_valid_bytes3(dstr_enc_valid_bytes3),
    .dstr_enc_port_id3(dstr_enc_port_id3)
    
);

encap u_encap(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG),

    .clk_mac(clk_mac), 
    .clk_axi(clk_axi), 

    .pio_start(pio_start),
    .pio_rw(pio_rw),
    .pio_addr_wdata(pio_addr_wdata),

    .clk_div(clk_div[9]),
 
    .pio_ack(pio_ack[9]),
    .pio_rvalid(pio_rvalid[9]),
    .pio_rdata(pio_rdata[9]),

    .dstr_enc_data_valid0(dstr_enc_data_valid0),
    .dstr_enc_packet_data0(dstr_enc_packet_data0),
    .dstr_enc_sop0(dstr_enc_sop0),
    .dstr_enc_eop0(dstr_enc_eop0),
    .dstr_enc_valid_bytes0(dstr_enc_valid_bytes0),

    .dstr_enc_data_valid1(dstr_enc_data_valid1),
    .dstr_enc_packet_data1(dstr_enc_packet_data1),
    .dstr_enc_sop1(dstr_enc_sop1),
    .dstr_enc_eop1(dstr_enc_eop1),
    .dstr_enc_valid_bytes1(dstr_enc_valid_bytes1),

    .dstr_enc_data_valid2(dstr_enc_data_valid2),
    .dstr_enc_packet_data2(dstr_enc_packet_data2),
    .dstr_enc_sop2(dstr_enc_sop2),
    .dstr_enc_eop2(dstr_enc_eop2),
    .dstr_enc_valid_bytes2(dstr_enc_valid_bytes2),
    .dstr_enc_port_id2(dstr_enc_port_id2),

    .dstr_enc_data_valid3(dstr_enc_data_valid3),
    .dstr_enc_packet_data3(dstr_enc_packet_data3),
    .dstr_enc_sop3(dstr_enc_sop3),
    .dstr_enc_eop3(dstr_enc_eop3),
    .dstr_enc_valid_bytes3(dstr_enc_valid_bytes3),
    .dstr_enc_port_id3(dstr_enc_port_id3),
    
    .port_dstr_bp(port_dstr_bp),

    .tx_axis_tdata0(tx_axis_tdata0),
    .tx_axis_tkeep0(tx_axis_tkeep0),
    .tx_axis_tvalid0(tx_axis_tvalid0),
    .tx_axis_tuser0(tx_axis_tuser0),
    .tx_axis_tlast0(tx_axis_tlast0),

    .tx_axis_tready0(tx_axis_tready0),

    .tx_axis_tdata1(tx_axis_tdata1),
    .tx_axis_tkeep1(tx_axis_tkeep1),
    .tx_axis_tvalid1(tx_axis_tvalid1),
    .tx_axis_tuser1(tx_axis_tuser1),
    .tx_axis_tlast1(tx_axis_tlast1),

    .tx_axis_tready1(tx_axis_tready1),

    .s_axis_c2h_tvalid_x0(s_axis_c2h_tvalid_x0),
    .s_axis_c2h_tlast_x0(s_axis_c2h_tlast_x0),
    .s_axis_c2h_tdata_x0(s_axis_c2h_tdata_x0),
    .s_axis_c2h_tready_x0(s_axis_c2h_tready_x0),

    .s_axis_c2h_tvalid_x1(s_axis_c2h_tvalid_x1),
    .s_axis_c2h_tlast_x1(s_axis_c2h_tlast_x1),
    .s_axis_c2h_tdata_x1(s_axis_c2h_tdata_x1),
    .s_axis_c2h_tready_x1(s_axis_c2h_tready_x1),

    .s_axis_c2h_tvalid_x2(s_axis_c2h_tvalid_x2),
    .s_axis_c2h_tlast_x2(s_axis_c2h_tlast_x2),
    .s_axis_c2h_tdata_x2(s_axis_c2h_tdata_x2),
    .s_axis_c2h_tready_x2(s_axis_c2h_tready_x2),

    .s_axis_c2h_tvalid_x3(s_axis_c2h_tvalid_x3),
    .s_axis_c2h_tlast_x3(s_axis_c2h_tlast_x3),
    .s_axis_c2h_tdata_x3(s_axis_c2h_tdata_x3),
    .s_axis_c2h_tready_x3(s_axis_c2h_tready_x3)

);

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

