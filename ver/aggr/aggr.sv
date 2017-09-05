//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : aggregator
//===========================================================================

`include "defines.vh"

import meta_package::aggr_par_meta_type;

module aggr(


input clk, 
input `RESET_SIG,

input dec_aggr_data_valid0,
input [`PORT_BUS_RANGE] dec_aggr_packet_data0,
input dec_aggr_sop0,
input dec_aggr_eop0,
input [`PORT_BUS_VB_RANGE] dec_aggr_valid_bytes0,    
input [`RCI_NBITS-1:0] dec_aggr_rci0,    
input dec_aggr_error0,  

input dec_aggr_data_valid1,
input [`PORT_BUS_RANGE] dec_aggr_packet_data1,
input dec_aggr_sop1,
input dec_aggr_eop1,
input [`PORT_BUS_VB_RANGE] dec_aggr_valid_bytes1,    
input [`RCI_NBITS-1:0] dec_aggr_rci1,    
input dec_aggr_error1,  

input dec_aggr_data_valid2,
input [`PORT_BUS_RANGE] dec_aggr_packet_data2,
input dec_aggr_sop2,
input dec_aggr_eop2,
input [`PORT_BUS_VB_RANGE] dec_aggr_valid_bytes2,    
input [`RCI_NBITS-1:0] dec_aggr_rci2,    
input dec_aggr_error2,  

input dec_aggr_data_valid3,
input [`PORT_BUS_RANGE] dec_aggr_packet_data3,
input dec_aggr_sop3,
input dec_aggr_eop3,
input [`PORT_BUS_VB_RANGE] dec_aggr_valid_bytes3,    
input [`RCI_NBITS-1:0] dec_aggr_rci3,    
input dec_aggr_error3,  

input dec_aggr_data_valid4,
input [`PORT_BUS_RANGE] dec_aggr_packet_data4,
input dec_aggr_sop4,
input dec_aggr_eop4,
input [`PORT_BUS_VB_RANGE] dec_aggr_valid_bytes4,    
input [`RCI_NBITS-1:0] dec_aggr_rci4,    
input dec_aggr_error4,  

input dec_aggr_data_valid5,
input [`PORT_BUS_RANGE] dec_aggr_packet_data5,
input dec_aggr_sop5,
input dec_aggr_eop5,
input [`PORT_BUS_VB_RANGE] dec_aggr_valid_bytes5,    
input [`RCI_NBITS-1:0] dec_aggr_rci5,    
input dec_aggr_error5,  

input dec_aggr_data_valid6,
input [`PORT_BUS_RANGE] dec_aggr_packet_data6,
input dec_aggr_sop6,
input dec_aggr_eop6,
input [`PORT_BUS_VB_RANGE] dec_aggr_valid_bytes6,    
input dec_aggr_error6,  

input bm_aggr_buf_valid,        
input [`BUF_PTR_RANGE] bm_aggr_buf_ptr,   
input bm_aggr_buf_available,    

input bm_aggr_rel_buf_valid,        
input [`PORT_ID_RANGE] bm_aggr_rel_buf_port_id, 
input [3:0] bm_aggr_rel_alpha,  

output logic aggr_par_hdr_valid,
output logic [`DATA_PATH_RANGE] aggr_par_hdr_data,
output aggr_par_meta_type   aggr_par_meta_data,
output logic aggr_par_sop,
output logic aggr_par_eop,

output logic [`NUM_OF_PORTS-1:0] aggr_port_bp, // decryptor must back off

output logic aggr_bm_buf_req,

output logic aggr_bm_packet_valid,
output logic [`DATA_PATH_RANGE] aggr_bm_packet_data,
output logic [`BUF_PTR_RANGE] aggr_bm_buf_ptr,    
output logic [`BUF_PTR_LSB_RANGE] aggr_bm_buf_ptr_lsb,
output logic [`PORT_ID_RANGE] aggr_bm_port_id,
output logic aggr_bm_sop

);

localparam PREFETCH_FIFO_DEPTH_NBITS = 3;
localparam DISCARD_FIFO_DEPTH_NBITS = 5;
localparam BUF_FIFO_DEPTH_NBITS = 5;
localparam BUF_FIFO_XON_LEVEL = 10;
localparam BUF_FIFO_XOFF_LEVEL = (1<<BUF_FIFO_DEPTH_NBITS)-10;
localparam DISCARD_FIFO_XON_LEVEL = 10;
localparam DISCARD_FIFO_XOFF_LEVEL = (1<<DISCARD_FIFO_DEPTH_NBITS)-10;
localparam NUM_PKTS_NBITS = 2;
localparam META_REG_DEPTH_NBITS = `PORT_ID_NBITS+NUM_PKTS_NBITS;
localparam HEADER_DEPTH_NBITS = `HEADER_LENGTH_NBITS;
localparam HDR_REG_DEPTH_NBITS = META_REG_DEPTH_NBITS+HEADER_DEPTH_NBITS;

/***************************** LOCAL VARIABLES *******************************/

logic bm_aggr_buf_valid_d1;       
logic [`BUF_PTR_RANGE] bm_aggr_buf_ptr_d1;  
logic bm_aggr_buf_available_d1;   

logic bm_aggr_rel_buf_valid_d1;       
logic [`PORT_ID_RANGE] bm_aggr_rel_buf_port_id_d1;    
logic [3:0] bm_aggr_rel_alpha_d1; 


logic aggr_bm_packet_valid_p3;
logic aggr_bm_packet_valid_p2;
logic aggr_bm_packet_valid_p1;


logic [1:0] rot_cnt_d1 /* synthesis maxfan = 16 preserve */;
logic [1:0] rot_cnt_d2 /* synthesis maxfan = 16 preserve */;
logic [1:0] rot_cnt1_d2 /* synthesis maxfan = 16 preserve */;
logic [1:0] rot_cnt2_d2 /* synthesis maxfan = 16 preserve */;
logic [1:0] rot_cnt3_d2 /* synthesis maxfan = 16 preserve */;
logic [1:0] rot_cnt4_d2 /* synthesis maxfan = 16 preserve */;
logic [1:0] rot_cnt5_d2 /* synthesis maxfan = 16 preserve */;

logic [`NUM_OF_PORTS-1:0] wr_sel_port_d1;
logic [`NUM_OF_PORTS-1:0] wr_sel_port_d2;
logic [`PORT_ID_RANGE] wr_sel_port_id_d1;

logic [`NUM_OF_PORTS-1:0] port_rf_wr_ctr;

logic [1:0] port_rf_wr_cnt0;
logic [1:0] port_rf_wr_cnt1;
logic [1:0] port_rf_wr_cnt2;
logic [1:0] port_rf_wr_cnt3;
logic [1:0] port_rf_wr_cnt4;
logic [1:0] port_rf_wr_cnt5;
logic [1:0] port_rf_wr_cnt6;

logic [1:0] port_rf_wr_seq0;
logic [1:0] port_rf_wr_seq1;
logic [1:0] port_rf_wr_seq2;
logic [1:0] port_rf_wr_seq3;
logic [1:0] port_rf_wr_seq4;
logic [1:0] port_rf_wr_seq5;
logic [1:0] port_rf_wr_seq6;

logic [`NUM_OF_PORTS-1:0] port_rf_wr_last;

logic [`DATA_PATH_RANGE] rot_data;

logic [(`PORT_ID_NBITS+1)-1:0] hold_register_waddr0_d1;
logic [(`PORT_ID_NBITS+1)-1:0] hold_register_waddr1_d1;
logic [(`PORT_ID_NBITS+1)-1:0] hold_register_waddr2_d1;
logic [(`PORT_ID_NBITS+1)-1:0] hold_register_waddr3_d1;

logic [`DATA_PATH_RANGE] hold_register_rdata_d1;

logic [`NUM_OF_PORTS-1:0] buf_fifo_eop_d1;
logic [`NUM_OF_PORTS-1:0] buf_fifo_error_d1;

logic [`RCI_NBITS-1:0] buf_fifo_rci0_d1;
logic [`RCI_NBITS-1:0] buf_fifo_rci1_d1;
logic [`RCI_NBITS-1:0] buf_fifo_rci2_d1;
logic [`RCI_NBITS-1:0] buf_fifo_rci3_d1;
logic [`RCI_NBITS-1:0] buf_fifo_rci4_d1;
logic [`RCI_NBITS-1:0] buf_fifo_rci5_d1;

logic [`NUM_OF_PORTS-1:0] event_fifo_wr_p1;
logic [`NUM_OF_PORTS-1:0] event_fifo_wr;

logic [`PORT_ID_RANGE] rd_sel_port_id_d1 /* synthesis maxfan = 16 preserve */;
logic [`PORT_ID_RANGE] rd_sel_port_id_d2 /* synthesis maxfan = 16 preserve */;
logic [`PORT_ID_RANGE] rd_sel_port_id_d3 /* synthesis maxfan = 16 preserve */;

logic [`NUM_OF_PORTS-1:0] port_rf_rd_ctr;
logic sel_port_rf_rd_ctr_d1;

logic [`NUM_OF_PORTS-1:0] ext_hdr;

logic [`RCI_NBITS-1:0] sel_port_event_fifo_rci_p1;
logic [`RCI_NBITS-1:0] sel_port_event_fifo_rci;
logic [`RCI_NBITS-1:0] sel_port_event_fifo_rci_d1;

logic [`HEADER_LENGTH_RANGE] sel_hdr_length_p1;
logic [`HEADER_LENGTH_RANGE] sel_hdr_length;
logic [`HEADER_LENGTH_RANGE] sel_hdr_length_d1;

logic [`HEADER_LENGTH_RANGE] hdr_len0;
logic [`HEADER_LENGTH_RANGE] hdr_len1;
logic [`HEADER_LENGTH_RANGE] hdr_len2;
logic [`HEADER_LENGTH_RANGE] hdr_len3;
logic [`HEADER_LENGTH_RANGE] hdr_len4;
logic [`HEADER_LENGTH_RANGE] hdr_len5;
logic [`HEADER_LENGTH_RANGE] hdr_len6;

logic [`HEADER_LENGTH_RANGE] hdr_len_fifo_rdata0;
logic [`HEADER_LENGTH_RANGE] hdr_len_fifo_rdata1;
logic [`HEADER_LENGTH_RANGE] hdr_len_fifo_rdata2;
logic [`HEADER_LENGTH_RANGE] hdr_len_fifo_rdata3;
logic [`HEADER_LENGTH_RANGE] hdr_len_fifo_rdata4;
logic [`HEADER_LENGTH_RANGE] hdr_len_fifo_rdata5;
logic [`HEADER_LENGTH_RANGE] hdr_len_fifo_rdata6;

logic [`NUM_OF_PORTS-1:0] hdr_len_fifo_wr;
logic [`NUM_OF_PORTS-1:0] hdr_len_fifo_rd;

logic [`HEADER_LENGTH_RANGE] sel_port_event_fifo_rd_seq;
logic [`HEADER_LENGTH_RANGE] sel_port_event_fifo_rd_seq_d1;
logic [`HEADER_LENGTH_RANGE] sel_port_event_fifo_rd_seq_d2;
logic [`HEADER_LENGTH_RANGE] sel_port_event_fifo_rd_seq_d3;

logic [`HEADER_LENGTH_RANGE] port_event_fifo_rd_seq0;
logic [`HEADER_LENGTH_RANGE] port_event_fifo_rd_seq1;
logic [`HEADER_LENGTH_RANGE] port_event_fifo_rd_seq2;
logic [`HEADER_LENGTH_RANGE] port_event_fifo_rd_seq3;
logic [`HEADER_LENGTH_RANGE] port_event_fifo_rd_seq4;
logic [`HEADER_LENGTH_RANGE] port_event_fifo_rd_seq5;
logic [`HEADER_LENGTH_RANGE] port_event_fifo_rd_seq6;

logic [`NUM_OF_PORTS-1:0] port_event_fifo_rd_last;

logic [`NUM_OF_PORTS-1:0] event_fifo_rd;
logic [`NUM_OF_PORTS-1:0] event_fifo_rd_d1;
logic [`NUM_OF_PORTS-1:0] event_fifo_eop_d1;
logic [`NUM_OF_PORTS-1:0] event_fifo_sop_in;

logic [`DATA_PATH_VB_RANGE] event_fifo_valid_bytes_in0;
logic [`DATA_PATH_VB_RANGE] event_fifo_valid_bytes_in1;
logic [`DATA_PATH_VB_RANGE] event_fifo_valid_bytes_in2;
logic [`DATA_PATH_VB_RANGE] event_fifo_valid_bytes_in3;
logic [`DATA_PATH_VB_RANGE] event_fifo_valid_bytes_in4;
logic [`DATA_PATH_VB_RANGE] event_fifo_valid_bytes_in5;
logic [`DATA_PATH_VB_RANGE] event_fifo_valid_bytes_in6;

logic [`NUM_OF_PORTS-1:0] dec_aggr_bus_sop;

logic sel_event_fifo_error_d1;
logic sel_event_fifo_bad_packet;

logic [`PACKET_LENGTH_RANGE] sel_packet_length;
logic [`PACKET_LENGTH_RANGE] sel_packet_length_d1;

logic [`NUM_OF_PORTS-1:0] port_buf_not_available_st;
logic [`NUM_OF_PORTS-1:0] port_packet_length_cnt_en;
logic [`NUM_OF_PORTS-1:0] clr_port_packet_length;

logic [`BUF_PTR_RANGE] sel_port_buf_pointer;
logic [`BUF_PTR_RANGE] sel_port_buf_pointer_d1;
logic [`BUF_PTR_RANGE] sel_port_buf_pointer_d2;

logic [`BUF_PTR_RANGE] port_buf_pointer0;
logic [`BUF_PTR_RANGE] port_buf_pointer1;
logic [`BUF_PTR_RANGE] port_buf_pointer2;
logic [`BUF_PTR_RANGE] port_buf_pointer3;
logic [`BUF_PTR_RANGE] port_buf_pointer4;
logic [`BUF_PTR_RANGE] port_buf_pointer5;
logic [`BUF_PTR_RANGE] port_buf_pointer6;

logic [`PACKET_LENGTH_RANGE] port_packet_length0;
logic [`PACKET_LENGTH_RANGE] port_packet_length1;
logic [`PACKET_LENGTH_RANGE] port_packet_length2;
logic [`PACKET_LENGTH_RANGE] port_packet_length3;
logic [`PACKET_LENGTH_RANGE] port_packet_length4;
logic [`PACKET_LENGTH_RANGE] port_packet_length5;
logic [`PACKET_LENGTH_RANGE] port_packet_length6;

logic [PREFETCH_FIFO_DEPTH_NBITS:0] prefetch_fifo_count;

logic [`NUM_OF_PORTS-1:0] port_prefetch_fifo_rd;
logic [`NUM_OF_PORTS-1:0] port_buf_ptr_register_wr;
logic [`NUM_OF_PORTS-1:0] port_buf_ptr_register_wr_d1;
logic [`NUM_OF_PORTS-1:0] port_meta_data_register_wr;
logic [`NUM_OF_PORTS-1:0] port_meta_data_register_wr_d1;
logic [`NUM_OF_PORTS-1:0] port_parser_header_register_wr;
logic [`NUM_OF_PORTS-1:0] port_parser_header_register_wr_d1;

logic buf_ptr_register_wr;
logic meta_data_register_wr;

logic [NUM_PKTS_NBITS-1:0] port_parser_meta_wr_ctr0;
logic [NUM_PKTS_NBITS-1:0] port_parser_meta_wr_ctr1;
logic [NUM_PKTS_NBITS-1:0] port_parser_meta_wr_ctr2;
logic [NUM_PKTS_NBITS-1:0] port_parser_meta_wr_ctr3;
logic [NUM_PKTS_NBITS-1:0] port_parser_meta_wr_ctr4;
logic [NUM_PKTS_NBITS-1:0] port_parser_meta_wr_ctr5;
logic [NUM_PKTS_NBITS-1:0] port_parser_meta_wr_ctr6;
logic [NUM_PKTS_NBITS-1:0] port_parser_header_wr_ctr0;
logic [NUM_PKTS_NBITS-1:0] port_parser_header_wr_ctr1;
logic [NUM_PKTS_NBITS-1:0] port_parser_header_wr_ctr2;
logic [NUM_PKTS_NBITS-1:0] port_parser_header_wr_ctr3;
logic [NUM_PKTS_NBITS-1:0] port_parser_header_wr_ctr4;
logic [NUM_PKTS_NBITS-1:0] port_parser_header_wr_ctr5;
logic [NUM_PKTS_NBITS-1:0] port_parser_header_wr_ctr6;

logic parser_header_register_wr_p2;
logic [HDR_REG_DEPTH_NBITS-1:0] parser_header_register_waddr_p2;
logic [`DATA_PATH_NBITS-1:0] parser_header_register_wdata_p2;

logic parser_header_register_wr_p1;

logic parser_header_register_wr;
logic [HDR_REG_DEPTH_NBITS-1:0] parser_header_register_waddr;
logic [`DATA_PATH_NBITS-1:0] parser_header_register_wdata;


logic [1:0] clk_div4;
logic clk_div4_pulse;
logic clk_div4_pulse_d1;
logic clk_div4_pulse_d2;

logic [NUM_PKTS_NBITS-1:0] port_parser_header_rd_ctr0;
logic [NUM_PKTS_NBITS-1:0] port_parser_header_rd_ctr1;
logic [NUM_PKTS_NBITS-1:0] port_parser_header_rd_ctr2;
logic [NUM_PKTS_NBITS-1:0] port_parser_header_rd_ctr3;
logic [NUM_PKTS_NBITS-1:0] port_parser_header_rd_ctr4;
logic [NUM_PKTS_NBITS-1:0] port_parser_header_rd_ctr5;
logic [NUM_PKTS_NBITS-1:0] port_parser_header_rd_ctr6;

logic [NUM_PKTS_NBITS-1:0] sel_port_parser_header_rd_ctr_d1;

logic [NUM_PKTS_NBITS:0] eop_event0;
logic [NUM_PKTS_NBITS:0] eop_event1;
logic [NUM_PKTS_NBITS:0] eop_event2;
logic [NUM_PKTS_NBITS:0] eop_event3;
logic [NUM_PKTS_NBITS:0] eop_event4;
logic [NUM_PKTS_NBITS:0] eop_event5;
logic [NUM_PKTS_NBITS:0] eop_event6;

logic parser_header_rd;
logic parser_header_rd_d1;
logic parser_header_rd_d2;
logic parser_header_rd_d3;
logic parser_header_rd_d4;

logic [`HEADER_LENGTH_RANGE] parser_header_rd_len;
logic [`HEADER_LENGTH_RANGE] parser_header_rd_cnt;
logic [`HEADER_LENGTH_RANGE] parser_header_rd_cnt_d1;
logic [`HEADER_LENGTH_RANGE] parser_header_rd_cnt_d2;
logic [`HEADER_LENGTH_RANGE] parser_header_rd_cnt_d3;
logic [`HEADER_LENGTH_RANGE] parser_header_rd_cnt_d4;

logic [`PORT_ID_RANGE] sel_parser_port_id_d1;
logic [`PORT_ID_RANGE] sel_parser_port_id_d2;
logic [`PORT_ID_RANGE] sel_parser_port_id_d3;
logic [`PORT_ID_RANGE] sel_parser_port_id_d4;
logic [`PORT_ID_RANGE] sel_parser_port_id_d5;

logic [NUM_PKTS_NBITS-1:0] sel_port_parser_meta_wr_ctr_d1;
logic [NUM_PKTS_NBITS-1:0] sel_port_parser_meta_wr_ctr_d2;

logic [NUM_PKTS_NBITS-1:0] sel_port_parser_header_wr_ctr_d1;
logic [NUM_PKTS_NBITS-1:0] sel_port_parser_header_wr_ctr_d2;
logic [NUM_PKTS_NBITS-1:0] sel_port_parser_header_wr_ctr_d3;


logic sel_port_buf_not_available_st_d1;

logic [`NUM_OF_PORTS-1:0] parser_header_rd_trig;

logic sel_event_fifo_sop_d1;
logic sel_event_fifo_sop_d2;
logic sel_event_fifo_sop_d3;

logic [`NUM_OF_PORTS-1:0] port_return_buf;

logic [`BUF_PTR_RANGE] prefetch_fifo_buf_pointer_d1;
logic [`BUF_PTR_RANGE] prefetch_fifo_buf_pointer_d2;

logic [`PORT_ID_RANGE] wr_port_id;

logic [3:0] hold_register_wr;
logic [(`PORT_ID_NBITS+1)-1:0] hold_register_waddr0;
logic [`DATA_PATH_RANGE] hold_register_wdata;

logic parser_header_rd_cnt_last_d1;
logic parser_header_rd_cnt_last_d2;
logic parser_header_rd_cnt_last_d3;
logic parser_header_rd_cnt_last_d4;

logic [`PORT_ID_NBITS+NUM_PKTS_NBITS-1:0] meta_data_register_raddr_d1;
logic [`PORT_ID_NBITS+NUM_PKTS_NBITS-1:0] meta_data_register_raddr_d2;

logic [`HEADER_LENGTH_NBITS+`PACKET_LENGTH_NBITS+3-1:0] meta_data_register_rdata_d1;
logic [`HEADER_LENGTH_NBITS+`PACKET_LENGTH_NBITS+3-1:0] meta_data_register_rdata_d2;

integer i;

logic aggr_bm_buf_req_p1 = prefetch_fifo_count!=((1<<PREFETCH_FIFO_DEPTH_NBITS)-1);

logic [1:0] rot_cnt;
logic [`NUM_OF_PORTS-1:0] wr_sel_port;
logic [`PORT_ID_RANGE] wr_sel_port_id;

logic [BUF_FIFO_DEPTH_NBITS:0] buf_fifo_ncount0;
logic [BUF_FIFO_DEPTH_NBITS:0] buf_fifo_ncount1;
logic [BUF_FIFO_DEPTH_NBITS:0] buf_fifo_ncount2;
logic [BUF_FIFO_DEPTH_NBITS:0] buf_fifo_ncount3;
logic [BUF_FIFO_DEPTH_NBITS:0] buf_fifo_ncount4;
logic [BUF_FIFO_DEPTH_NBITS:0] buf_fifo_ncount5;
logic [BUF_FIFO_DEPTH_NBITS:0] buf_fifo_ncount6;

logic [`NUM_OF_PORTS-1:0] buf_fifo_rd;
logic [`NUM_OF_PORTS-1:0] buf_fifo_empty;
logic [`NUM_OF_PORTS-1:0] buf_fifo_sop;
logic [`NUM_OF_PORTS-1:0] buf_fifo_eop;
logic [`NUM_OF_PORTS:0] buf_fifo_error;

logic [`PORT_BUS_VB_RANGE] buf_fifo_valid_bytes0;
logic [`PORT_BUS_VB_RANGE] buf_fifo_valid_bytes1;
logic [`PORT_BUS_VB_RANGE] buf_fifo_valid_bytes2;
logic [`PORT_BUS_VB_RANGE] buf_fifo_valid_bytes3;
logic [`PORT_BUS_VB_RANGE] buf_fifo_valid_bytes4;
logic [`PORT_BUS_VB_RANGE] buf_fifo_valid_bytes5;
logic [`PORT_BUS_VB_RANGE] buf_fifo_valid_bytes6;

logic [`PORT_BUS_RANGE] buf_fifo_packet_data0;
logic [`PORT_BUS_RANGE] buf_fifo_packet_data1;
logic [`PORT_BUS_RANGE] buf_fifo_packet_data2;
logic [`PORT_BUS_RANGE] buf_fifo_packet_data3;
logic [`PORT_BUS_RANGE] buf_fifo_packet_data4;
logic [`PORT_BUS_RANGE] buf_fifo_packet_data5;
logic [`PORT_BUS_RANGE] buf_fifo_packet_data6;

logic [`RCI_NBITS-1:0] buf_fifo_rci0;
logic [`RCI_NBITS-1:0] buf_fifo_rci1;
logic [`RCI_NBITS-1:0] buf_fifo_rci2;
logic [`RCI_NBITS-1:0] buf_fifo_rci3;
logic [`RCI_NBITS-1:0] buf_fifo_rci4;
logic [`RCI_NBITS-1:0] buf_fifo_rci5;

logic [`PORT_BUS_RANGE] buf_fifo_packet_data2_m = buf_fifo_rd[2]?buf_fifo_packet_data2:buf_fifo_packet_data3;
logic [`PORT_BUS_RANGE] buf_fifo_packet_data3_m = buf_fifo_rd[4]?buf_fifo_packet_data4:buf_fifo_rd[5]?buf_fifo_packet_data5:buf_fifo_packet_data6;

logic [`NUM_OF_PORTS-1:0] rd_sel_port;
logic [`PORT_ID_RANGE] rd_sel_port_id;

logic [`NUM_OF_PORTS-1:0] port_buf_available;

logic prefetch_fifo_empty;
logic [PREFETCH_FIFO_DEPTH_NBITS:0] prefetch_fifo_depth;
logic [`BUF_PTR_RANGE] prefetch_fifo_buf_pointer;

logic [`NUM_OF_PORTS-1:0] event_fifo_full;
logic [`NUM_OF_PORTS-1:0] event_fifo_empty;
logic [`NUM_OF_PORTS-1:0] event_fifo_sop;
logic [`NUM_OF_PORTS-1:0] event_fifo_eop;
logic [`NUM_OF_PORTS-1:0] event_fifo_error;

logic [`DATA_PATH_VB_RANGE] event_fifo_valid_bytes0;
logic [`DATA_PATH_VB_RANGE] event_fifo_valid_bytes1;
logic [`DATA_PATH_VB_RANGE] event_fifo_valid_bytes2;
logic [`DATA_PATH_VB_RANGE] event_fifo_valid_bytes3;
logic [`DATA_PATH_VB_RANGE] event_fifo_valid_bytes4;
logic [`DATA_PATH_VB_RANGE] event_fifo_valid_bytes5;
logic [`DATA_PATH_VB_RANGE] event_fifo_valid_bytes6;

logic [`RCI_NBITS-1:0] event_fifo_rci0;
logic [`RCI_NBITS-1:0] event_fifo_rci1;
logic [`RCI_NBITS-1:0] event_fifo_rci2;
logic [`RCI_NBITS-1:0] event_fifo_rci3;
logic [`RCI_NBITS-1:0] event_fifo_rci4;
logic [`RCI_NBITS-1:0] event_fifo_rci5;


logic prefetch_fifo_rd = |port_prefetch_fifo_rd;

logic [`PORT_ID_RANGE] wr_port_id_p1 = wr_sel_port_id_d1;
logic [(`PORT_ID_NBITS+1)-1:0] hold_register_waddr0_p1 = {wr_port_id, port_rf_wr_ctr[wr_port_id]};
logic [(`PORT_ID_NBITS+1)-1:0] hold_register_waddr1 = hold_register_waddr0_d1;
logic [(`PORT_ID_NBITS+1)-1:0] hold_register_waddr2 = hold_register_waddr1_d1;
logic [(`PORT_ID_NBITS+1)-1:0] hold_register_waddr3 = hold_register_waddr2_d1;

logic [3:0] hold_register_wr_p1 = aggr_rot({|buf_fifo_rd[6:4], |buf_fifo_rd[3:2], buf_fifo_rd[1:0]}, rot_cnt_d2);


logic [`DATA_PATH_RANGE] hold_register_wdata_p1 = rot_data;
logic [`DATA_PATH_RANGE] hold_register_rdata;

logic [`NUM_OF_PORTS-1:0] port_rf_wr_seq_first;
assign port_rf_wr_seq_first[0] = ~|port_rf_wr_seq0;
assign port_rf_wr_seq_first[1] = ~|port_rf_wr_seq1;
assign port_rf_wr_seq_first[2] = ~|port_rf_wr_seq2;
assign port_rf_wr_seq_first[3] = ~|port_rf_wr_seq3;
assign port_rf_wr_seq_first[4] = ~|port_rf_wr_seq4;
assign port_rf_wr_seq_first[5] = ~|port_rf_wr_seq5;
assign port_rf_wr_seq_first[6] = ~|port_rf_wr_seq6;

logic [`NUM_OF_PORTS-1:0] port_rf_wr_seq_last;
assign port_rf_wr_seq_last[0] = port_rf_wr_seq0==`DATA_PATH_PORT_BUS_RATIO-1;
assign port_rf_wr_seq_last[1] = port_rf_wr_seq1==`DATA_PATH_PORT_BUS_RATIO-1;
assign port_rf_wr_seq_last[2] = port_rf_wr_seq2==`DATA_PATH_PORT_BUS_RATIO-1;
assign port_rf_wr_seq_last[3] = port_rf_wr_seq3==`DATA_PATH_PORT_BUS_RATIO-1;
assign port_rf_wr_seq_last[4] = port_rf_wr_seq4==`DATA_PATH_PORT_BUS_RATIO-1;
assign port_rf_wr_seq_last[5] = port_rf_wr_seq5==`DATA_PATH_PORT_BUS_RATIO-1;
assign port_rf_wr_seq_last[6] = port_rf_wr_seq6==`DATA_PATH_PORT_BUS_RATIO-1;

//

logic prefetch_fifo_available = ~prefetch_fifo_empty;

logic [(`PORT_ID_NBITS+1)-1:0] hold_register_raddr = {rd_sel_port_id_d1, sel_port_rf_rd_ctr_d1};

logic [`NUM_OF_PORTS-1:0] port_event_fifo_rd_seq_last;
assign port_event_fifo_rd_seq_last[0] = port_event_fifo_rd_seq0>=hdr_len_fifo_rdata0;
assign port_event_fifo_rd_seq_last[1] = port_event_fifo_rd_seq1>=hdr_len_fifo_rdata1;
assign port_event_fifo_rd_seq_last[2] = port_event_fifo_rd_seq2>=hdr_len_fifo_rdata2;
assign port_event_fifo_rd_seq_last[3] = port_event_fifo_rd_seq3>=hdr_len_fifo_rdata3;
assign port_event_fifo_rd_seq_last[4] = port_event_fifo_rd_seq4>=hdr_len_fifo_rdata4;
assign port_event_fifo_rd_seq_last[5] = port_event_fifo_rd_seq5>=hdr_len_fifo_rdata5;
assign port_event_fifo_rd_seq_last[6] = port_event_fifo_rd_seq6>=hdr_len_fifo_rdata6;


logic [`NUM_OF_PORTS-1:0] port_event_fifo_rd_seq_buf_en;
assign port_event_fifo_rd_seq_buf_en[0] = port_event_fifo_rd_seq0[1:0]==0;
assign port_event_fifo_rd_seq_buf_en[1] = port_event_fifo_rd_seq1[1:0]==0;
assign port_event_fifo_rd_seq_buf_en[2] = port_event_fifo_rd_seq2[1:0]==0;
assign port_event_fifo_rd_seq_buf_en[3] = port_event_fifo_rd_seq3[1:0]==0;
assign port_event_fifo_rd_seq_buf_en[4] = port_event_fifo_rd_seq4[1:0]==0;
assign port_event_fifo_rd_seq_buf_en[5] = port_event_fifo_rd_seq5[1:0]==0;
assign port_event_fifo_rd_seq_buf_en[6] = port_event_fifo_rd_seq6[1:0]==0;

logic [`PORT_ID_NBITS+NUM_PKTS_NBITS-1:0] buf_ptr_register_waddr = {rd_sel_port_id_d2, sel_port_parser_meta_wr_ctr_d2};
logic [`BUF_PTR_RANGE] buf_ptr_register_wdata = prefetch_fifo_buf_pointer_d2;

logic [`PORT_ID_NBITS+NUM_PKTS_NBITS-1:0] meta_data_register_waddr = buf_ptr_register_waddr;
logic sel_port_buf_not_available_st = port_buf_not_available_st[rd_sel_port_id_d1];
logic len_neq_0 = ~(sel_packet_length_d1==0);
logic [`RCI_NBITS+`HEADER_LENGTH_NBITS+`PACKET_LENGTH_NBITS+3-1:0] meta_data_register_wdata = {sel_port_event_fifo_rci_d1, sel_hdr_length_d1, sel_packet_length_d1, len_neq_0, sel_event_fifo_bad_packet, sel_port_buf_not_available_st_d1};

logic [`PORT_ID_RANGE] sel_parser_port_id;

logic [`NUM_OF_PORTS-1:0] eop_event_empty;
assign eop_event_empty[0] = eop_event0==0;
assign eop_event_empty[1] = eop_event1==0;
assign eop_event_empty[2] = eop_event2==0;
assign eop_event_empty[3] = eop_event3==0;
assign eop_event_empty[4] = eop_event4==0;
assign eop_event_empty[5] = eop_event5==0;
assign eop_event_empty[6] = eop_event6==0;

logic [`RCI_NBITS+`HEADER_LENGTH_NBITS+`PACKET_LENGTH_NBITS+3-1:0] meta_data_register_rdata;
logic [`PORT_ID_NBITS+NUM_PKTS_NBITS-1:0] meta_data_register_raddr = {sel_parser_port_id_d2, sel_port_parser_header_rd_ctr_d1};

logic [`BUF_PTR_RANGE] buf_ptr_register_rdata;
logic [`PORT_ID_NBITS+NUM_PKTS_NBITS-1:0] buf_ptr_register_raddr = meta_data_register_raddr;

logic [`DATA_PATH_NBITS-1:0] parser_header_register_rdata;
logic [HDR_REG_DEPTH_NBITS-1:0] parser_header_register_raddr = {buf_ptr_register_raddr, parser_header_rd_cnt_d1};

logic [`RCI_NBITS-1:0] meta_rci = meta_data_register_rdata[`RCI_NBITS+`HEADER_LENGTH_NBITS+`PACKET_LENGTH_NBITS+3-1:`HEADER_LENGTH_NBITS+`PACKET_LENGTH_NBITS+3];
logic [`HEADER_LENGTH_RANGE] meta_hdr_len = meta_data_register_rdata[`HEADER_LENGTH_NBITS+`PACKET_LENGTH_NBITS+3-1:`PACKET_LENGTH_NBITS+3];
logic meta_len_neq0 = |meta_data_register_rdata[2];
logic meta_error = |meta_data_register_rdata[1:0];

logic [`PACKET_LENGTH_RANGE] meta_pkt_len = meta_data_register_rdata[`PACKET_LENGTH_NBITS+3-1:3];
logic [`BUF_PTR_RANGE] meta_buf_ptr = buf_ptr_register_rdata;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
        aggr_bm_port_id <= rd_sel_port_id_d3;
        aggr_bm_sop <= sel_event_fifo_sop_d3;
        aggr_bm_packet_data <= transpose16bytes(hold_register_rdata_d1);
        aggr_bm_buf_ptr_lsb <= sel_port_event_fifo_rd_seq_d3[0];
        aggr_bm_buf_ptr <= sel_port_buf_pointer_d2;

        aggr_par_hdr_data <= transpose16bytes(parser_header_register_rdata);
	aggr_par_meta_data.discard <= meta_error;
	aggr_par_meta_data.rci <= meta_rci;
	aggr_par_meta_data.hdr_len <= meta_hdr_len;
	aggr_par_meta_data.len <= meta_pkt_len;
	aggr_par_meta_data.buf_ptr <= meta_buf_ptr;
	aggr_par_meta_data.port <= sel_parser_port_id_d3;
/*
	aggr_par_meta_data[`AGGR_PAR_META_DISCARD] <= meta_error;
	aggr_par_meta_data[`AGGR_PAR_META_RCI] <= meta_rci;
	aggr_par_meta_data[`AGGR_PAR_META_HDR_LEN] <= meta_hdr_len;
	aggr_par_meta_data[`AGGR_PAR_META_LEN] <= meta_pkt_len;
	aggr_par_meta_data[`AGGR_PAR_META_BUF_PTR] <= meta_buf_ptr;
	aggr_par_meta_data[`AGGR_PAR_META_PORT] <= sel_parser_port_id_d3;
*/
	aggr_par_sop <= parser_header_rd_cnt_d2==0;
	aggr_par_eop <= parser_header_rd_cnt_last_d2;

end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
        aggr_bm_buf_req <= 0;
        aggr_bm_packet_valid <= 0;
        aggr_par_hdr_valid <= 0;
	aggr_port_bp <= 0;
    end else begin
        aggr_bm_buf_req <= aggr_bm_buf_req_p1;
        aggr_bm_packet_valid <= aggr_bm_packet_valid_p1;
        aggr_par_hdr_valid <= parser_header_rd_d2&meta_len_neq0;
	aggr_port_bp[0] <= (buf_fifo_ncount0<BUF_FIFO_XON_LEVEL?0:buf_fifo_ncount0>BUF_FIFO_XOFF_LEVEL?1:aggr_port_bp[0]);
	aggr_port_bp[1] <= (buf_fifo_ncount1<BUF_FIFO_XON_LEVEL?0:buf_fifo_ncount1>BUF_FIFO_XOFF_LEVEL?1:aggr_port_bp[1]);
	aggr_port_bp[2] <= (buf_fifo_ncount2<BUF_FIFO_XON_LEVEL?0:buf_fifo_ncount2>BUF_FIFO_XOFF_LEVEL?1:aggr_port_bp[2]);
	aggr_port_bp[3] <= (buf_fifo_ncount3<BUF_FIFO_XON_LEVEL?0:buf_fifo_ncount3>BUF_FIFO_XOFF_LEVEL?1:aggr_port_bp[3]);
	aggr_port_bp[4] <= (buf_fifo_ncount4<BUF_FIFO_XON_LEVEL?0:buf_fifo_ncount4>BUF_FIFO_XOFF_LEVEL?1:aggr_port_bp[4]);
	aggr_port_bp[5] <= (buf_fifo_ncount5<BUF_FIFO_XON_LEVEL?0:buf_fifo_ncount5>BUF_FIFO_XOFF_LEVEL?1:aggr_port_bp[5]);
	aggr_port_bp[6] <= (buf_fifo_ncount6<BUF_FIFO_XON_LEVEL?0:buf_fifo_ncount6>BUF_FIFO_XOFF_LEVEL?1:aggr_port_bp[6]);

    end

/***************************** PROGRAM BODY **********************************/

logic[1:0] mod_port_rf_wr_seq3 = (port_rf_wr_seq3>2)?port_rf_wr_seq3-3:port_rf_wr_seq3+1;
logic[1:0] mod_port_rf_wr_seq2 = (port_rf_wr_seq2>1)?port_rf_wr_seq2-2:port_rf_wr_seq2+2;
logic[1:0] mod_port_rf_wr_seq1 = (port_rf_wr_seq1>0)?port_rf_wr_seq1-1:port_rf_wr_seq1+3;

assign buf_fifo_rd[0] = (~port_rf_wr_last[0]|~event_fifo_full[0])&~buf_fifo_empty[0]&(rot_cnt1_d2==port_rf_wr_seq0)&wr_sel_port_d2[0];
assign buf_fifo_rd[6] = (~port_rf_wr_last[6]|~event_fifo_full[6])&~buf_fifo_empty[6]&(rot_cnt3_d2==mod_port_rf_wr_seq3)&wr_sel_port_d2[6]; //FIXME
assign buf_fifo_rd[5] = (~port_rf_wr_last[5]|~event_fifo_full[5])&~buf_fifo_empty[5]&(rot_cnt3_d2==mod_port_rf_wr_seq3)&wr_sel_port_d2[5];
assign buf_fifo_rd[4] = (~port_rf_wr_last[4]|~event_fifo_full[4])&~buf_fifo_empty[4]&(rot_cnt3_d2==mod_port_rf_wr_seq3)&wr_sel_port_d2[4];
assign buf_fifo_rd[3] = (~port_rf_wr_last[3]|~event_fifo_full[3])&~buf_fifo_empty[3]&(rot_cnt3_d2==mod_port_rf_wr_seq2)&wr_sel_port_d2[3];
assign buf_fifo_rd[2] = (~port_rf_wr_last[2]|~event_fifo_full[2])&~buf_fifo_empty[2]&(rot_cnt4_d2==mod_port_rf_wr_seq2)&wr_sel_port_d2[2];
assign buf_fifo_rd[1] = (~port_rf_wr_last[1]|~event_fifo_full[1])&~buf_fifo_empty[1]&(rot_cnt4_d2==mod_port_rf_wr_seq1)&wr_sel_port_d2[1];


logic [META_REG_DEPTH_NBITS-1:0] parser_header_register_waddr_msb = {rd_sel_port_id_d3, sel_port_parser_header_wr_ctr_d3};
logic [HDR_REG_DEPTH_NBITS-1:0] parser_header_register_waddr_p1 = {parser_header_register_waddr_msb, sel_port_event_fifo_rd_seq_d3};
logic [`DATA_PATH_RANGE] parser_header_register_wdata_p1 = hold_register_rdata_d1;

logic parser_header_rd_cnt_last = parser_header_rd_cnt>=parser_header_rd_len;
logic parser_header_rd_last = parser_header_rd&parser_header_rd_cnt_last;
logic en_next_port = parser_header_rd_last;

logic [`NUM_OF_PORTS-1:0] port_parser_header_rd_last;
assign port_parser_header_rd_last[0] = (sel_parser_port_id_d1==0)&parser_header_rd_last;
assign port_parser_header_rd_last[1] = (sel_parser_port_id_d1==1)&parser_header_rd_last;
assign port_parser_header_rd_last[2] = (sel_parser_port_id_d1==2)&parser_header_rd_last;
assign port_parser_header_rd_last[3] = (sel_parser_port_id_d1==3)&parser_header_rd_last;
assign port_parser_header_rd_last[4] = (sel_parser_port_id_d1==4)&parser_header_rd_last;
assign port_parser_header_rd_last[5] = (sel_parser_port_id_d1==5)&parser_header_rd_last;
assign port_parser_header_rd_last[6] = (sel_parser_port_id_d1==6)&parser_header_rd_last;


always @(*) begin

    for (i = 0; i < `NUM_OF_PORTS; i = i+1) begin
	port_rf_wr_last[i] = port_rf_wr_seq_last[i]|buf_fifo_eop[i];
	event_fifo_wr_p1[i] = buf_fifo_rd[i]&port_rf_wr_last[i];

        event_fifo_rd[i] = ~event_fifo_empty[i]&rd_sel_port[i];

	port_event_fifo_rd_last[i] = port_event_fifo_rd_seq_last[i]|event_fifo_eop[i];

        port_return_buf[i] = bm_aggr_rel_buf_valid_d1&bm_aggr_rel_buf_port_id_d1==i;

        port_prefetch_fifo_rd[i] = prefetch_fifo_available&~port_buf_not_available_st[i]&port_buf_available[i]&event_fifo_rd[i]&port_event_fifo_rd_seq_buf_en[i];

        port_packet_length_cnt_en[i] = ~port_buf_not_available_st[i]&~event_fifo_error[i]&event_fifo_rd[i]&~port_event_fifo_rd_seq_buf_en[i]|port_prefetch_fifo_rd[i];

        hdr_len_fifo_rd[i] = event_fifo_rd[i]&event_fifo_eop[i];
        port_buf_ptr_register_wr[i] = event_fifo_rd[i]&event_fifo_sop[i];
        port_meta_data_register_wr[i] = event_fifo_rd[i]&event_fifo_eop[i];
        port_parser_header_register_wr[i] = event_fifo_rd[i]&dec_aggr_bus_sop[i];

        parser_header_rd_trig[i] = ~eop_event_empty[i]&(sel_parser_port_id==i);
    end
    

    case (rd_sel_port_id)
        0: sel_port_event_fifo_rd_seq = port_event_fifo_rd_seq0;
        1: sel_port_event_fifo_rd_seq = port_event_fifo_rd_seq1;
        2: sel_port_event_fifo_rd_seq = port_event_fifo_rd_seq2;
        3: sel_port_event_fifo_rd_seq = port_event_fifo_rd_seq3;
        4: sel_port_event_fifo_rd_seq = port_event_fifo_rd_seq4;
        5: sel_port_event_fifo_rd_seq = port_event_fifo_rd_seq5;
        default: sel_port_event_fifo_rd_seq = port_event_fifo_rd_seq6;
    endcase

    case (rd_sel_port_id_d1)
        0: sel_port_buf_pointer = port_buf_pointer0;
        1: sel_port_buf_pointer = port_buf_pointer1;
        2: sel_port_buf_pointer = port_buf_pointer2;
        3: sel_port_buf_pointer = port_buf_pointer3;
        4: sel_port_buf_pointer = port_buf_pointer4;
        5: sel_port_buf_pointer = port_buf_pointer5;
        default: sel_port_buf_pointer = port_buf_pointer6;
    endcase

    case (rd_sel_port_id)
        0: sel_hdr_length_p1 = hdr_len0;
        1: sel_hdr_length_p1 = hdr_len1;
        2: sel_hdr_length_p1 = hdr_len2;
        3: sel_hdr_length_p1 = hdr_len3;
        4: sel_hdr_length_p1 = hdr_len4;
        5: sel_hdr_length_p1 = hdr_len5;
        default: sel_hdr_length_p1 = hdr_len6;
    endcase

	case(rd_sel_port_id)
		0: sel_port_event_fifo_rci_p1 = event_fifo_rci0;
		1: sel_port_event_fifo_rci_p1 = event_fifo_rci1;
		2: sel_port_event_fifo_rci_p1 = event_fifo_rci2;
		3: sel_port_event_fifo_rci_p1 = event_fifo_rci3;
		4: sel_port_event_fifo_rci_p1 = event_fifo_rci4;
		5: sel_port_event_fifo_rci_p1 = event_fifo_rci5;
		default: sel_port_event_fifo_rci_p1 = 0;
	endcase

    case (rd_sel_port_id_d1)
        0: sel_packet_length = port_packet_length0;
        1: sel_packet_length = port_packet_length1;
        2: sel_packet_length = port_packet_length2;
        3: sel_packet_length = port_packet_length3;
        4: sel_packet_length = port_packet_length4;
        5: sel_packet_length = port_packet_length5;
        default: sel_packet_length = port_packet_length6;
    endcase

    for (i = 0; i < `PORT_BUS_NBITS; i = i+1)
        {
        rot_data[`PORT_BUS_NBITS*3+i],
        rot_data[`PORT_BUS_NBITS*2+i],
        rot_data[`PORT_BUS_NBITS+i],
        rot_data[i]} = aggr_rot({buf_fifo_packet_data3_m[i], buf_fifo_packet_data2_m[i], buf_fifo_packet_data1[i], buf_fifo_packet_data0[i]}, rot_cnt5_d2);

end

always @(posedge clk) begin

        bm_aggr_buf_ptr_d1 <= bm_aggr_buf_ptr;
        bm_aggr_buf_available_d1 <= bm_aggr_buf_available;

        rot_cnt_d1 <= rot_cnt;
        rot_cnt_d2 <= rot_cnt_d1;
        rot_cnt1_d2 <= rot_cnt_d1;
        rot_cnt2_d2 <= rot_cnt_d1;
        rot_cnt3_d2 <= rot_cnt_d1;
        rot_cnt4_d2 <= rot_cnt_d1;
        rot_cnt5_d2 <= rot_cnt_d1;

        wr_sel_port_d1 <= wr_sel_port;
        wr_sel_port_d2 <= wr_sel_port_d1;
        wr_sel_port_id_d1 <= wr_sel_port_id;

        wr_port_id <= wr_port_id_p1;

        hold_register_wr <= hold_register_wr_p1;
        hold_register_wdata <= hold_register_wdata_p1;
        hold_register_waddr0 <= hold_register_waddr0_p1;
        hold_register_waddr0_d1 <= hold_register_waddr0;
        hold_register_waddr1_d1 <= hold_register_waddr1;
        hold_register_waddr2_d1 <= hold_register_waddr2;
        hold_register_waddr3_d1 <= hold_register_waddr3;

	buf_fifo_eop_d1 <= buf_fifo_eop;
	buf_fifo_error_d1 <= buf_fifo_error;

	buf_fifo_rci0_d1 <= buf_fifo_rci0;
	buf_fifo_rci1_d1 <= buf_fifo_rci1;
	buf_fifo_rci2_d1 <= buf_fifo_rci2;
	buf_fifo_rci3_d1 <= buf_fifo_rci3;
	buf_fifo_rci4_d1 <= buf_fifo_rci4;
	buf_fifo_rci5_d1 <= buf_fifo_rci5;

	event_fifo_rd_d1 <= event_fifo_rd;
	event_fifo_eop_d1 <= event_fifo_eop;

        event_fifo_valid_bytes_in0 <= buf_fifo_rd[0]?(port_rf_wr_seq_first[0]?buf_fifo_valid_bytes0:event_fifo_valid_bytes_in0+buf_fifo_valid_bytes0):event_fifo_valid_bytes_in0;
        event_fifo_valid_bytes_in1 <= buf_fifo_rd[1]?(port_rf_wr_seq_first[1]?buf_fifo_valid_bytes1:event_fifo_valid_bytes_in1+buf_fifo_valid_bytes1):event_fifo_valid_bytes_in1;
        event_fifo_valid_bytes_in2 <= buf_fifo_rd[2]?(port_rf_wr_seq_first[2]?buf_fifo_valid_bytes2:event_fifo_valid_bytes_in2+buf_fifo_valid_bytes2):event_fifo_valid_bytes_in2;
        event_fifo_valid_bytes_in3 <= buf_fifo_rd[3]?(port_rf_wr_seq_first[3]?buf_fifo_valid_bytes3:event_fifo_valid_bytes_in3+buf_fifo_valid_bytes3):event_fifo_valid_bytes_in3;
        event_fifo_valid_bytes_in4 <= buf_fifo_rd[4]?(port_rf_wr_seq_first[4]?buf_fifo_valid_bytes4:event_fifo_valid_bytes_in4+buf_fifo_valid_bytes4):event_fifo_valid_bytes_in4;
        event_fifo_valid_bytes_in5 <= buf_fifo_rd[5]?(port_rf_wr_seq_first[5]?buf_fifo_valid_bytes5:event_fifo_valid_bytes_in5+buf_fifo_valid_bytes5):event_fifo_valid_bytes_in5;
        event_fifo_valid_bytes_in6 <= buf_fifo_rd[6]?(port_rf_wr_seq_first[6]?buf_fifo_valid_bytes6:event_fifo_valid_bytes_in6+buf_fifo_valid_bytes6):event_fifo_valid_bytes_in6;

        ext_hdr[0] <= buf_fifo_rd[0]&(port_rf_wr_cnt0==1)&(buf_fifo_packet_data0[15:8]==253);
        ext_hdr[1] <= buf_fifo_rd[1]&(port_rf_wr_cnt1==1)&(buf_fifo_packet_data1[15:8]==253);
        ext_hdr[2] <= buf_fifo_rd[2]&(port_rf_wr_cnt2==1)&(buf_fifo_packet_data2[15:8]==253);
        ext_hdr[3] <= buf_fifo_rd[3]&(port_rf_wr_cnt3==1)&(buf_fifo_packet_data3[15:8]==253);
        ext_hdr[4] <= buf_fifo_rd[4]&(port_rf_wr_cnt4==1)&(buf_fifo_packet_data4[15:8]==253);
        ext_hdr[5] <= buf_fifo_rd[5]&(port_rf_wr_cnt5==1)&(buf_fifo_packet_data5[15:8]==253);
        ext_hdr[6] <= buf_fifo_rd[6]&(port_rf_wr_cnt6==1)&(buf_fifo_packet_data6[15:8]==253);

        rd_sel_port_id_d1 <= rd_sel_port_id;
        rd_sel_port_id_d2 <= rd_sel_port_id_d1;
        rd_sel_port_id_d3 <= rd_sel_port_id_d2;

        sel_port_rf_rd_ctr_d1 <= port_rf_rd_ctr[rd_sel_port_id];

        sel_event_fifo_error_d1 <= event_fifo_error[rd_sel_port_id];
        sel_event_fifo_bad_packet <= sel_event_fifo_error_d1|sel_port_buf_not_available_st;

        sel_port_event_fifo_rci <= sel_port_event_fifo_rci_p1;
        sel_port_event_fifo_rci_d1 <= sel_port_event_fifo_rci;

        sel_hdr_length <= sel_hdr_length_p1;
        sel_hdr_length_d1 <= sel_hdr_length;
        sel_packet_length_d1 <= sel_packet_length;

        sel_event_fifo_sop_d1 <= event_fifo_sop[rd_sel_port_id];
        sel_event_fifo_sop_d2 <= sel_event_fifo_sop_d1;
        sel_event_fifo_sop_d3 <= sel_event_fifo_sop_d2;

        sel_port_event_fifo_rd_seq_d1 <= sel_port_event_fifo_rd_seq;
        sel_port_event_fifo_rd_seq_d2 <= sel_port_event_fifo_rd_seq_d1;
        sel_port_event_fifo_rd_seq_d3 <= sel_port_event_fifo_rd_seq_d2;

        hold_register_rdata_d1 <= hold_register_rdata;

        port_buf_pointer0 <= port_prefetch_fifo_rd[0]?prefetch_fifo_buf_pointer_d1:port_buf_pointer0;
        port_buf_pointer1 <= port_prefetch_fifo_rd[1]?prefetch_fifo_buf_pointer_d1:port_buf_pointer1;
        port_buf_pointer2 <= port_prefetch_fifo_rd[2]?prefetch_fifo_buf_pointer_d1:port_buf_pointer2;
        port_buf_pointer3 <= port_prefetch_fifo_rd[3]?prefetch_fifo_buf_pointer_d1:port_buf_pointer3;
        port_buf_pointer4 <= port_prefetch_fifo_rd[4]?prefetch_fifo_buf_pointer_d1:port_buf_pointer4;
        port_buf_pointer5 <= port_prefetch_fifo_rd[5]?prefetch_fifo_buf_pointer_d1:port_buf_pointer5;
        port_buf_pointer6 <= port_prefetch_fifo_rd[6]?prefetch_fifo_buf_pointer_d1:port_buf_pointer6;

        sel_port_buf_pointer_d1 <= sel_port_buf_pointer;
        sel_port_buf_pointer_d2 <= sel_port_buf_pointer_d1;

        port_packet_length0 <= port_packet_length_cnt_en[0]?(event_fifo_sop[0]?event_fifo_valid_bytes0:port_packet_length0+event_fifo_valid_bytes0):clr_port_packet_length[0]?0:port_packet_length0;
        port_packet_length1 <= port_packet_length_cnt_en[1]?(event_fifo_sop[1]?event_fifo_valid_bytes1:port_packet_length1+event_fifo_valid_bytes1):clr_port_packet_length[1]?0:port_packet_length1;
        port_packet_length2 <= port_packet_length_cnt_en[2]?(event_fifo_sop[2]?event_fifo_valid_bytes2:port_packet_length2+event_fifo_valid_bytes2):clr_port_packet_length[2]?0:port_packet_length2;
        port_packet_length3 <= port_packet_length_cnt_en[3]?(event_fifo_sop[3]?event_fifo_valid_bytes3:port_packet_length3+event_fifo_valid_bytes3):clr_port_packet_length[3]?0:port_packet_length3;
        port_packet_length4 <= port_packet_length_cnt_en[4]?(event_fifo_sop[4]?event_fifo_valid_bytes4:port_packet_length4+event_fifo_valid_bytes4):clr_port_packet_length[4]?0:port_packet_length4;
        port_packet_length5 <= port_packet_length_cnt_en[5]?(event_fifo_sop[5]?event_fifo_valid_bytes5:port_packet_length5+event_fifo_valid_bytes5):clr_port_packet_length[5]?0:port_packet_length5;
        port_packet_length6 <= port_packet_length_cnt_en[6]?(event_fifo_sop[6]?event_fifo_valid_bytes6:port_packet_length6+event_fifo_valid_bytes6):clr_port_packet_length[6]?0:port_packet_length6;


		case(rd_sel_port_id)
			0: sel_port_parser_meta_wr_ctr_d1 <= port_parser_meta_wr_ctr0;
			1: sel_port_parser_meta_wr_ctr_d1 <= port_parser_meta_wr_ctr1;
			2: sel_port_parser_meta_wr_ctr_d1 <= port_parser_meta_wr_ctr2;
			3: sel_port_parser_meta_wr_ctr_d1 <= port_parser_meta_wr_ctr3;
			4: sel_port_parser_meta_wr_ctr_d1 <= port_parser_meta_wr_ctr4;
			5: sel_port_parser_meta_wr_ctr_d1 <= port_parser_meta_wr_ctr5;
			default: sel_port_parser_meta_wr_ctr_d1 <= port_parser_meta_wr_ctr6;
		endcase

        sel_port_parser_meta_wr_ctr_d2 <= sel_port_parser_meta_wr_ctr_d1;

		case(rd_sel_port_id)
			0: sel_port_parser_header_wr_ctr_d1 <= port_parser_header_wr_ctr0;
			1: sel_port_parser_header_wr_ctr_d1 <= port_parser_header_wr_ctr1;
			2: sel_port_parser_header_wr_ctr_d1 <= port_parser_header_wr_ctr2;
			3: sel_port_parser_header_wr_ctr_d1 <= port_parser_header_wr_ctr3;
			4: sel_port_parser_header_wr_ctr_d1 <= port_parser_header_wr_ctr4;
			5: sel_port_parser_header_wr_ctr_d1 <= port_parser_header_wr_ctr5;
			default: sel_port_parser_header_wr_ctr_d1 <= port_parser_header_wr_ctr6;
		endcase

        sel_port_parser_header_wr_ctr_d2 <= sel_port_parser_header_wr_ctr_d1;
        sel_port_parser_header_wr_ctr_d3 <= sel_port_parser_header_wr_ctr_d2;

        port_buf_ptr_register_wr_d1 <= port_buf_ptr_register_wr;
        buf_ptr_register_wr <= |port_buf_ptr_register_wr_d1;
        port_meta_data_register_wr_d1 <= port_meta_data_register_wr;
        meta_data_register_wr <= |port_meta_data_register_wr_d1;
        port_parser_header_register_wr_d1 <= port_parser_header_register_wr;
        parser_header_register_wr_p2 <= |port_parser_header_register_wr_d1;
        parser_header_register_wr_p1 <= parser_header_register_wr_p2;


        sel_port_buf_not_available_st_d1 <= sel_port_buf_not_available_st;

        bm_aggr_rel_buf_port_id_d1 <= bm_aggr_rel_buf_port_id;
        bm_aggr_rel_alpha_d1 <= bm_aggr_rel_alpha;

        prefetch_fifo_buf_pointer_d1 <= prefetch_fifo_buf_pointer;
        prefetch_fifo_buf_pointer_d2 <= prefetch_fifo_buf_pointer_d1;

        sel_parser_port_id_d1 <= sel_parser_port_id;
        sel_parser_port_id_d2 <= sel_parser_port_id_d1;
        sel_parser_port_id_d3 <= sel_parser_port_id_d2;
        sel_parser_port_id_d4 <= sel_parser_port_id_d3;
        sel_parser_port_id_d5 <= sel_parser_port_id_d4;

		case(sel_parser_port_id_d1)
			0: sel_port_parser_header_rd_ctr_d1 <= port_parser_header_rd_ctr0;
			1: sel_port_parser_header_rd_ctr_d1 <= port_parser_header_rd_ctr1;
			2: sel_port_parser_header_rd_ctr_d1 <= port_parser_header_rd_ctr2;
			3: sel_port_parser_header_rd_ctr_d1 <= port_parser_header_rd_ctr3;
			4: sel_port_parser_header_rd_ctr_d1 <= port_parser_header_rd_ctr4;
			5: sel_port_parser_header_rd_ctr_d1 <= port_parser_header_rd_ctr5;
			default: sel_port_parser_header_rd_ctr_d1 <= port_parser_header_rd_ctr6;
		endcase

	parser_header_register_wr <= parser_header_register_wr_p1;
	parser_header_register_waddr <= parser_header_register_waddr_p1;
	parser_header_register_wdata <= parser_header_register_wdata_p1;

	parser_header_rd_cnt_last_d1 <= parser_header_rd_cnt_last;
	parser_header_rd_cnt_last_d2 <= parser_header_rd_cnt_last_d1;
	parser_header_rd_cnt_last_d3 <= parser_header_rd_cnt_last_d2;
	parser_header_rd_cnt_last_d4 <= parser_header_rd_cnt_last_d3;

	meta_data_register_raddr_d1 <= meta_data_register_raddr;
	meta_data_register_raddr_d2 <= meta_data_register_raddr_d1;
end

logic inc_prefetch_fifo = aggr_bm_buf_req_p1;
logic dec_prefetch_fifo = bm_aggr_buf_valid_d1&~bm_aggr_buf_available_d1;

always @(`CLK_RST) 
  
    if (`ACTIVE_RESET) begin
        bm_aggr_rel_buf_valid_d1 <= 0;
        bm_aggr_buf_valid_d1 <= 0;

        port_rf_wr_ctr <= 0;
        event_fifo_wr <= 0;
	event_fifo_sop_in <= {(`NUM_OF_PORTS){1'b1}};
        dec_aggr_bus_sop <= {(`NUM_OF_PORTS){1'b1}};
        port_rf_wr_cnt0 <= 0;
        port_rf_wr_cnt1 <= 0;
        port_rf_wr_cnt2 <= 0;
        port_rf_wr_cnt3 <= 0;
        port_rf_wr_cnt4 <= 0;
        port_rf_wr_cnt5 <= 0;
        port_rf_wr_cnt6 <= 0;
        port_rf_wr_seq0 <= 0;
        port_rf_wr_seq1 <= 0;
        port_rf_wr_seq2 <= 0;
        port_rf_wr_seq3 <= 0;
        port_rf_wr_seq4 <= 0;
        port_rf_wr_seq5 <= 0;
        port_rf_wr_seq6 <= 0;
        port_rf_rd_ctr <= 0;
        port_event_fifo_rd_seq0 <= 0;
        port_event_fifo_rd_seq1 <= 0;
        port_event_fifo_rd_seq2 <= 0;
        port_event_fifo_rd_seq3 <= 0;
        port_event_fifo_rd_seq4 <= 0;
        port_event_fifo_rd_seq5 <= 0;
        port_event_fifo_rd_seq6 <= 0;
        port_buf_not_available_st <= 0;
        prefetch_fifo_count <= 0;
        aggr_bm_packet_valid_p3 <= 0;
        aggr_bm_packet_valid_p2 <= 0;
        aggr_bm_packet_valid_p1 <= 0;

        hdr_len_fifo_wr <= 0;

        hdr_len0 <= 40/`DATA_PATH_NBYTES-1;
        hdr_len1 <= 40/`DATA_PATH_NBYTES-1;
        hdr_len2 <= 40/`DATA_PATH_NBYTES-1;
        hdr_len3 <= 40/`DATA_PATH_NBYTES-1;
        hdr_len4 <= 40/`DATA_PATH_NBYTES-1;
        hdr_len5 <= 40/`DATA_PATH_NBYTES-1;
        hdr_len6 <= 40/`DATA_PATH_NBYTES-1;
        eop_event0 <= 0;
        eop_event1 <= 0;
        eop_event2 <= 0;
        eop_event3 <= 0;
        eop_event4 <= 0;
        eop_event5 <= 0;
        eop_event6 <= 0;
        parser_header_rd <= 0;
        parser_header_rd_d1 <= 0;
        parser_header_rd_d2 <= 0;
        parser_header_rd_d3 <= 0;
        parser_header_rd_d4 <= 0;
        parser_header_rd_len <= 64/`DATA_PATH_NBYTES-1; // instead of 40 because of timing
        parser_header_rd_cnt <= 0;
        parser_header_rd_cnt_d1 <= 0;
        parser_header_rd_cnt_d2 <= 0;
        parser_header_rd_cnt_d3 <= 0;
        parser_header_rd_cnt_d4 <= 0;
        port_parser_meta_wr_ctr0 <= 0;
        port_parser_meta_wr_ctr1 <= 0;
        port_parser_meta_wr_ctr2 <= 0;
        port_parser_meta_wr_ctr3 <= 0;
        port_parser_meta_wr_ctr4 <= 0;
        port_parser_meta_wr_ctr5 <= 0;
        port_parser_meta_wr_ctr6 <= 0;
        port_parser_header_wr_ctr0 <= 0;
        port_parser_header_wr_ctr1 <= 0;
        port_parser_header_wr_ctr2 <= 0;
        port_parser_header_wr_ctr3 <= 0;
        port_parser_header_wr_ctr4 <= 0;
        port_parser_header_wr_ctr5 <= 0;
        port_parser_header_wr_ctr6 <= 0;
        port_parser_header_rd_ctr0 <= 0;
        port_parser_header_rd_ctr1 <= 0;
        port_parser_header_rd_ctr2 <= 0;
        port_parser_header_rd_ctr3 <= 0;
        port_parser_header_rd_ctr4 <= 0;
        port_parser_header_rd_ctr5 <= 0;
        port_parser_header_rd_ctr6 <= 0;
	clr_port_packet_length <= 0;

    end else begin

        bm_aggr_rel_buf_valid_d1 <= bm_aggr_rel_buf_valid;
        bm_aggr_buf_valid_d1 <= bm_aggr_buf_valid;

        event_fifo_wr <= event_fifo_wr_p1;

        for (i = 0; i < `NUM_OF_PORTS; i = i+1) begin
            port_rf_wr_ctr[i] <= event_fifo_wr_p1[i]?~port_rf_wr_ctr[i]:port_rf_wr_ctr[i];
            event_fifo_sop_in[i] <= event_fifo_wr[i]?(buf_fifo_eop_d1[i]?1:0):event_fifo_sop_in[i];
		end

        port_rf_wr_cnt0 <= buf_fifo_rd[0]?(buf_fifo_eop[0]?0:&port_rf_wr_cnt0?15:port_rf_wr_cnt0+1):port_rf_wr_cnt0;
        port_rf_wr_cnt1 <= buf_fifo_rd[1]?(buf_fifo_eop[1]?0:&port_rf_wr_cnt1?15:port_rf_wr_cnt1+1):port_rf_wr_cnt1;
        port_rf_wr_cnt2 <= buf_fifo_rd[2]?(buf_fifo_eop[2]?0:&port_rf_wr_cnt2?15:port_rf_wr_cnt2+1):port_rf_wr_cnt2;
        port_rf_wr_cnt3 <= buf_fifo_rd[3]?(buf_fifo_eop[3]?0:&port_rf_wr_cnt3?15:port_rf_wr_cnt3+1):port_rf_wr_cnt3;
        port_rf_wr_cnt4 <= buf_fifo_rd[4]?(buf_fifo_eop[4]?0:&port_rf_wr_cnt4?15:port_rf_wr_cnt4+1):port_rf_wr_cnt4;
        port_rf_wr_cnt5 <= buf_fifo_rd[5]?(buf_fifo_eop[5]?0:&port_rf_wr_cnt5?15:port_rf_wr_cnt5+1):port_rf_wr_cnt5;
        port_rf_wr_cnt6 <= buf_fifo_rd[6]?(buf_fifo_eop[6]?0:&port_rf_wr_cnt6?15:port_rf_wr_cnt6+1):port_rf_wr_cnt6;
        
        port_rf_wr_seq0 <= buf_fifo_rd[0]?(port_rf_wr_last[0]?0:port_rf_wr_seq0+1):port_rf_wr_seq0;
        port_rf_wr_seq1 <= buf_fifo_rd[1]?(port_rf_wr_last[1]?0:port_rf_wr_seq1+1):port_rf_wr_seq1;
        port_rf_wr_seq2 <= buf_fifo_rd[2]?(port_rf_wr_last[2]?0:port_rf_wr_seq2+1):port_rf_wr_seq2;
        port_rf_wr_seq3 <= buf_fifo_rd[3]?(port_rf_wr_last[3]?0:port_rf_wr_seq3+1):port_rf_wr_seq3;
        port_rf_wr_seq4 <= buf_fifo_rd[4]?(port_rf_wr_last[4]?0:port_rf_wr_seq4+1):port_rf_wr_seq4;
        port_rf_wr_seq5 <= buf_fifo_rd[5]?(port_rf_wr_last[5]?0:port_rf_wr_seq5+1):port_rf_wr_seq5;
        port_rf_wr_seq6 <= buf_fifo_rd[6]?(port_rf_wr_last[6]?0:port_rf_wr_seq6+1):port_rf_wr_seq6;

        for (i = 0; i < `NUM_OF_PORTS; i = i+1) begin
            
            port_rf_rd_ctr[i] <= event_fifo_rd[i]?~port_rf_rd_ctr[i]:port_rf_rd_ctr[i];
            dec_aggr_bus_sop[i] <= event_fifo_rd[i]&event_fifo_eop[i]?1:event_fifo_rd[i]&port_event_fifo_rd_seq_last[i]?0:dec_aggr_bus_sop[i];
            port_buf_not_available_st[i] <= event_fifo_rd[i]&port_event_fifo_rd_seq_buf_en[i]&(~prefetch_fifo_available|~port_buf_available[i])?1:                                                                    		event_fifo_rd_d1[i]&event_fifo_eop_d1[i]?0:port_buf_not_available_st[i];

        end

		
	port_parser_header_wr_ctr0 <= port_parser_header_register_wr[0]&port_event_fifo_rd_last[0]?port_parser_header_wr_ctr0+1:port_parser_header_wr_ctr0;
	port_parser_header_wr_ctr1 <= port_parser_header_register_wr[1]&port_event_fifo_rd_last[1]?port_parser_header_wr_ctr1+1:port_parser_header_wr_ctr1;
	port_parser_header_wr_ctr2 <= port_parser_header_register_wr[2]&port_event_fifo_rd_last[2]?port_parser_header_wr_ctr2+1:port_parser_header_wr_ctr2;
	port_parser_header_wr_ctr3 <= port_parser_header_register_wr[3]&port_event_fifo_rd_last[3]?port_parser_header_wr_ctr3+1:port_parser_header_wr_ctr3;
	port_parser_header_wr_ctr4 <= port_parser_header_register_wr[4]&port_event_fifo_rd_last[4]?port_parser_header_wr_ctr4+1:port_parser_header_wr_ctr4;
	port_parser_header_wr_ctr5 <= port_parser_header_register_wr[5]&port_event_fifo_rd_last[5]?port_parser_header_wr_ctr5+1:port_parser_header_wr_ctr5;
	port_parser_header_wr_ctr6 <= port_parser_header_register_wr[6]&port_event_fifo_rd_last[6]?port_parser_header_wr_ctr6+1:port_parser_header_wr_ctr6;

	port_parser_meta_wr_ctr0 <= port_meta_data_register_wr[0]?port_parser_meta_wr_ctr0+1:port_parser_meta_wr_ctr0;
	port_parser_meta_wr_ctr1 <= port_meta_data_register_wr[1]?port_parser_meta_wr_ctr1+1:port_parser_meta_wr_ctr1;
	port_parser_meta_wr_ctr2 <= port_meta_data_register_wr[2]?port_parser_meta_wr_ctr2+1:port_parser_meta_wr_ctr2;
	port_parser_meta_wr_ctr3 <= port_meta_data_register_wr[3]?port_parser_meta_wr_ctr3+1:port_parser_meta_wr_ctr3;
	port_parser_meta_wr_ctr4 <= port_meta_data_register_wr[4]?port_parser_meta_wr_ctr4+1:port_parser_meta_wr_ctr4;
	port_parser_meta_wr_ctr5 <= port_meta_data_register_wr[5]?port_parser_meta_wr_ctr5+1:port_parser_meta_wr_ctr5;
	port_parser_meta_wr_ctr6 <= port_meta_data_register_wr[6]?port_parser_meta_wr_ctr6+1:port_parser_meta_wr_ctr6;

        
        port_event_fifo_rd_seq0 <= event_fifo_rd[0]?(event_fifo_eop[0]?0:port_event_fifo_rd_seq0+1):port_event_fifo_rd_seq0;
        port_event_fifo_rd_seq1 <= event_fifo_rd[1]?(event_fifo_eop[1]?0:port_event_fifo_rd_seq1+1):port_event_fifo_rd_seq1;
        port_event_fifo_rd_seq2 <= event_fifo_rd[2]?(event_fifo_eop[2]?0:port_event_fifo_rd_seq2+1):port_event_fifo_rd_seq2;
        port_event_fifo_rd_seq3 <= event_fifo_rd[3]?(event_fifo_eop[3]?0:port_event_fifo_rd_seq3+1):port_event_fifo_rd_seq3;
        port_event_fifo_rd_seq4 <= event_fifo_rd[4]?(event_fifo_eop[4]?0:port_event_fifo_rd_seq4+1):port_event_fifo_rd_seq4;
        port_event_fifo_rd_seq5 <= event_fifo_rd[5]?(event_fifo_eop[5]?0:port_event_fifo_rd_seq5+1):port_event_fifo_rd_seq5;
        port_event_fifo_rd_seq6 <= event_fifo_rd[6]?(event_fifo_eop[6]?0:port_event_fifo_rd_seq6+1):port_event_fifo_rd_seq6;

		case ({inc_prefetch_fifo, dec_prefetch_fifo, prefetch_fifo_rd})
			3'b000: prefetch_fifo_count <= prefetch_fifo_count;
			3'b001: prefetch_fifo_count <= prefetch_fifo_count-1;
			3'b010: prefetch_fifo_count <= prefetch_fifo_count-1;
			3'b011: prefetch_fifo_count <= prefetch_fifo_count-2;
			3'b100: prefetch_fifo_count <= prefetch_fifo_count+1;
			3'b101: prefetch_fifo_count <= prefetch_fifo_count;
			default: prefetch_fifo_count <= prefetch_fifo_count-1;
		endcase

        aggr_bm_packet_valid_p3 <= |port_packet_length_cnt_en;
        aggr_bm_packet_valid_p2 <= aggr_bm_packet_valid_p3;
        aggr_bm_packet_valid_p1 <= aggr_bm_packet_valid_p2;

        hdr_len_fifo_wr[0] <= buf_fifo_rd[0]&(port_rf_wr_cnt0==10);
        hdr_len_fifo_wr[1] <= buf_fifo_rd[1]&(port_rf_wr_cnt1==10);
        hdr_len_fifo_wr[2] <= buf_fifo_rd[2]&(port_rf_wr_cnt2==10);
        hdr_len_fifo_wr[3] <= buf_fifo_rd[3]&(port_rf_wr_cnt3==10);
        hdr_len_fifo_wr[4] <= buf_fifo_rd[4]&(port_rf_wr_cnt4==10);
        hdr_len_fifo_wr[5] <= buf_fifo_rd[5]&(port_rf_wr_cnt5==10);
        hdr_len_fifo_wr[6] <= buf_fifo_rd[6]&(port_rf_wr_cnt6==10);

        hdr_len0 <= ext_hdr[0]?((buf_fifo_packet_data0[7:0]<<3)+56)/`DATA_PATH_NBYTES-1:48/`DATA_PATH_NBYTES-1;
        hdr_len1 <= ext_hdr[1]?((buf_fifo_packet_data1[7:0]<<3)+56)/`DATA_PATH_NBYTES-1:48/`DATA_PATH_NBYTES-1;
        hdr_len2 <= ext_hdr[2]?((buf_fifo_packet_data2[7:0]<<3)+56)/`DATA_PATH_NBYTES-1:48/`DATA_PATH_NBYTES-1;
        hdr_len3 <= ext_hdr[3]?((buf_fifo_packet_data3[7:0]<<3)+56)/`DATA_PATH_NBYTES-1:48/`DATA_PATH_NBYTES-1;
        hdr_len4 <= ext_hdr[4]?((buf_fifo_packet_data4[7:0]<<3)+56)/`DATA_PATH_NBYTES-1:48/`DATA_PATH_NBYTES-1;
        hdr_len5 <= ext_hdr[5]?((buf_fifo_packet_data5[7:0]<<3)+56)/`DATA_PATH_NBYTES-1:48/`DATA_PATH_NBYTES-1;
        hdr_len6 <= ext_hdr[6]?((buf_fifo_packet_data6[7:0]<<3)+56)/`DATA_PATH_NBYTES-1:48/`DATA_PATH_NBYTES-1;

        eop_event0 <= ~port_meta_data_register_wr_d1[0]^port_parser_header_rd_last[0]?eop_event0:port_meta_data_register_wr_d1[0]?eop_event0+1:eop_event0-1;
        eop_event1 <= ~port_meta_data_register_wr_d1[1]^port_parser_header_rd_last[1]?eop_event1:port_meta_data_register_wr_d1[1]?eop_event1+1:eop_event1-1;
        eop_event2 <= ~port_meta_data_register_wr_d1[2]^port_parser_header_rd_last[2]?eop_event2:port_meta_data_register_wr_d1[2]?eop_event2+1:eop_event2-1;
        eop_event3 <= ~port_meta_data_register_wr_d1[3]^port_parser_header_rd_last[3]?eop_event3:port_meta_data_register_wr_d1[3]?eop_event3+1:eop_event3-1;
        eop_event4 <= ~port_meta_data_register_wr_d1[4]^port_parser_header_rd_last[4]?eop_event4:port_meta_data_register_wr_d1[4]?eop_event4+1:eop_event4-1;
        eop_event5 <= ~port_meta_data_register_wr_d1[5]^port_parser_header_rd_last[5]?eop_event5:port_meta_data_register_wr_d1[5]?eop_event5+1:eop_event5-1;
        eop_event6 <= ~port_meta_data_register_wr_d1[6]^port_parser_header_rd_last[6]?eop_event6:port_meta_data_register_wr_d1[6]?eop_event6+1:eop_event6-1;

        parser_header_rd <= |parser_header_rd_trig?1:parser_header_rd_cnt_last?0:parser_header_rd;
        parser_header_rd_d1 <= parser_header_rd;
        parser_header_rd_d2 <= parser_header_rd_d1;
        parser_header_rd_d3 <= parser_header_rd_d2;
        parser_header_rd_d4 <= parser_header_rd_d3;
        parser_header_rd_cnt <= parser_header_rd_last?0:parser_header_rd?parser_header_rd_cnt+1:parser_header_rd_cnt;
        parser_header_rd_cnt_d1 <= parser_header_rd_cnt;
        parser_header_rd_cnt_d2 <= parser_header_rd_cnt_d1;
        parser_header_rd_cnt_d3 <= parser_header_rd_cnt_d2;
        parser_header_rd_cnt_d4 <= parser_header_rd_cnt_d3;
        parser_header_rd_len <= parser_header_rd_d2?meta_hdr_len:parser_header_rd_len;

	port_parser_header_rd_ctr0 <= port_parser_header_rd_last[0]?port_parser_header_rd_ctr0+1:port_parser_header_rd_ctr0;
	port_parser_header_rd_ctr1 <= port_parser_header_rd_last[1]?port_parser_header_rd_ctr1+1:port_parser_header_rd_ctr1;
	port_parser_header_rd_ctr2 <= port_parser_header_rd_last[2]?port_parser_header_rd_ctr2+1:port_parser_header_rd_ctr2;
	port_parser_header_rd_ctr3 <= port_parser_header_rd_last[3]?port_parser_header_rd_ctr3+1:port_parser_header_rd_ctr3;
	port_parser_header_rd_ctr4 <= port_parser_header_rd_last[4]?port_parser_header_rd_ctr4+1:port_parser_header_rd_ctr4;
	port_parser_header_rd_ctr5 <= port_parser_header_rd_last[5]?port_parser_header_rd_ctr5+1:port_parser_header_rd_ctr5;
	port_parser_header_rd_ctr6 <= port_parser_header_rd_last[6]?port_parser_header_rd_ctr6+1:port_parser_header_rd_ctr6;

	clr_port_packet_length <= port_packet_length_cnt_en&event_fifo_eop;

    end
 
/***************************** Port Scheduler ***************************************/

port_scheduler u_port_scheduler(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),
        .en(en_next_port),

        // outputs

        .rot_cnt(),
        .sel_port(),
        .sel_port_id(sel_parser_port_id)

    );

port_scheduler u_port_scheduler_1(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),
        .en(1'b1),

        // outputs

        .rot_cnt(rot_cnt),
        .sel_port(wr_sel_port),
        .sel_port_id(wr_sel_port_id)

    );

port_scheduler u_port_scheduler_2(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),
        .en(1'b1),

        // outputs

        .rot_cnt(),
        .sel_port(rd_sel_port),
        .sel_port_id(rd_sel_port_id)
    );


resource_manager u_resource_manager(

       // inputs

        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .alpha(bm_aggr_rel_alpha_d1),

        .port_get_resource(port_prefetch_fifo_rd),       
        .port_return_resource(port_return_buf),       


       // outputs

        .port_resource_available(port_buf_available)

);

/***************************** FIFO ***************************************/

sfifo2f_2f1 #(`PORT_BUS_NBITS+2+`PORT_BUS_VB_NBITS+1+`RCI_NBITS, BUF_FIFO_DEPTH_NBITS) u_sfifo2f_2f1_0(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({dec_aggr_packet_data0, dec_aggr_sop0, dec_aggr_eop0, dec_aggr_valid_bytes0, dec_aggr_error0, dec_aggr_rci0}),             
        .rd(buf_fifo_rd[0]),
        .wr(dec_aggr_data_valid0),

        .ncount(buf_fifo_ncount0),
        .count(),
        .full(),
        .empty(buf_fifo_empty[0]),
        .fullm1(),
        .emptyp2(),
        .dout({buf_fifo_packet_data0, buf_fifo_sop[0], buf_fifo_eop[0], buf_fifo_valid_bytes0, buf_fifo_error[0], buf_fifo_rci0})       
    );

sfifo2f_2f1 #(`PORT_BUS_NBITS+2+`PORT_BUS_VB_NBITS+1+`RCI_NBITS, BUF_FIFO_DEPTH_NBITS) u_sfifo2f_2f1_1(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({dec_aggr_packet_data1, dec_aggr_sop1, dec_aggr_eop1, dec_aggr_valid_bytes1, dec_aggr_error1, dec_aggr_rci1}),             
        .rd(buf_fifo_rd[1]),
        .wr(dec_aggr_data_valid1),

        .ncount(buf_fifo_ncount1),
        .count(),
        .full(),
        .empty(buf_fifo_empty[1]),
        .fullm1(),
        .emptyp2(),
        .dout({buf_fifo_packet_data1, buf_fifo_sop[1], buf_fifo_eop[1], buf_fifo_valid_bytes1, buf_fifo_error[1], buf_fifo_rci1})       
    );

sfifo2f_2f1 #(`PORT_BUS_NBITS+2+`PORT_BUS_VB_NBITS+1+`RCI_NBITS, BUF_FIFO_DEPTH_NBITS) u_sfifo2f_2f1_2(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({dec_aggr_packet_data2, dec_aggr_sop2, dec_aggr_eop2, dec_aggr_valid_bytes2, dec_aggr_error2, dec_aggr_rci2}),             
        .rd(buf_fifo_rd[2]),
        .wr(dec_aggr_data_valid2),

        .ncount(buf_fifo_ncount2),
        .count(),
        .full(),
        .empty(buf_fifo_empty[2]),
        .fullm1(),
        .emptyp2(),
        .dout({buf_fifo_packet_data2, buf_fifo_sop[2], buf_fifo_eop[2], buf_fifo_valid_bytes2, buf_fifo_error[2], buf_fifo_rci2})       
    );

sfifo2f_2f1 #(`PORT_BUS_NBITS+2+`PORT_BUS_VB_NBITS+1+`RCI_NBITS, BUF_FIFO_DEPTH_NBITS) u_sfifo2f_2f1_3(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({dec_aggr_packet_data3, dec_aggr_sop3, dec_aggr_eop3, dec_aggr_valid_bytes3, dec_aggr_error3, dec_aggr_rci3}),             
        .rd(buf_fifo_rd[3]),
        .wr(dec_aggr_data_valid3),

        .ncount(buf_fifo_ncount3),
        .count(),
        .full(),
        .empty(buf_fifo_empty[3]),
        .fullm1(),
        .emptyp2(),
        .dout({buf_fifo_packet_data3, buf_fifo_sop[3], buf_fifo_eop[3], buf_fifo_valid_bytes3, buf_fifo_error[3], buf_fifo_rci3})       
    );

sfifo2f_2f1 #(`PORT_BUS_NBITS+2+`PORT_BUS_VB_NBITS+1+`RCI_NBITS, BUF_FIFO_DEPTH_NBITS) u_sfifo2f_2f1_4(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({dec_aggr_packet_data4, dec_aggr_sop4, dec_aggr_eop4, dec_aggr_valid_bytes4, dec_aggr_error4, dec_aggr_rci4}),             
        .rd(buf_fifo_rd[4]),
        .wr(dec_aggr_data_valid4),

        .ncount(buf_fifo_ncount4),
        .count(),
        .full(),
        .empty(buf_fifo_empty[4]),
        .fullm1(),
        .emptyp2(),
        .dout({buf_fifo_packet_data4, buf_fifo_sop[4], buf_fifo_eop[4], buf_fifo_valid_bytes4, buf_fifo_error[4], buf_fifo_rci4})       
    );

sfifo2f_2f1 #(`PORT_BUS_NBITS+2+`PORT_BUS_VB_NBITS+1+`RCI_NBITS, BUF_FIFO_DEPTH_NBITS) u_sfifo2f_2f1_5(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({dec_aggr_packet_data5, dec_aggr_sop5, dec_aggr_eop5, dec_aggr_valid_bytes5, dec_aggr_error5, dec_aggr_rci5}),             
        .rd(buf_fifo_rd[5]),
        .wr(dec_aggr_data_valid5),

        .ncount(buf_fifo_ncount5),
        .count(),
        .full(),
        .empty(buf_fifo_empty[5]),
        .fullm1(),
        .emptyp2(),
        .dout({buf_fifo_packet_data5, buf_fifo_sop[5], buf_fifo_eop[5], buf_fifo_valid_bytes5, buf_fifo_error[5], buf_fifo_rci5})       
    );

sfifo2f_2f1 #(`PORT_BUS_NBITS+2+`PORT_BUS_VB_NBITS+1, BUF_FIFO_DEPTH_NBITS) u_sfifo2f_2f1_6(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({dec_aggr_packet_data6, dec_aggr_sop6, dec_aggr_eop6, dec_aggr_valid_bytes6, dec_aggr_error6}),             
        .rd(buf_fifo_rd[6]),
        .wr(dec_aggr_data_valid6),

        .ncount(buf_fifo_ncount6),
        .count(),
        .full(),
        .empty(buf_fifo_empty[6]),
        .fullm1(),
        .emptyp2(),
        .dout({buf_fifo_packet_data6, buf_fifo_sop[6], buf_fifo_eop[6], buf_fifo_valid_bytes6, buf_fifo_error[6]})       
    );

sfifo2f1 #(2+`DATA_PATH_VB_NBITS+1+`RCI_NBITS) u_sfifo2f1_40(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({event_fifo_sop_in[0], buf_fifo_eop_d1[0], event_fifo_valid_bytes_in0, buf_fifo_error_d1[0], buf_fifo_rci0_d1}),                
        .rd(event_fifo_rd[0]),
        .wr(event_fifo_wr[0]),

        .count(),
        .full(event_fifo_full[0]),
        .empty(event_fifo_empty[0]),
        .fullm1(),
        .emptyp2(),
        .dout({event_fifo_sop[0], event_fifo_eop[0], event_fifo_valid_bytes0, event_fifo_error[0], event_fifo_rci0})       
    );
sfifo2f1 #(2+`DATA_PATH_VB_NBITS+1+`RCI_NBITS) u_sfifo2f1_41(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({event_fifo_sop_in[1], buf_fifo_eop_d1[1], event_fifo_valid_bytes_in1, buf_fifo_error_d1[1], buf_fifo_rci1_d1}),                
        .rd(event_fifo_rd[1]),
        .wr(event_fifo_wr[1]),

        .count(),
        .full(event_fifo_full[1]),
        .empty(event_fifo_empty[1]),
        .fullm1(),
        .emptyp2(),
        .dout({event_fifo_sop[1], event_fifo_eop[1], event_fifo_valid_bytes1, event_fifo_error[1], event_fifo_rci1})       
    );
sfifo2f1 #(2+`DATA_PATH_VB_NBITS+1+`RCI_NBITS) u_sfifo2f1_42(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({event_fifo_sop_in[2], buf_fifo_eop_d1[2], event_fifo_valid_bytes_in2, buf_fifo_error_d1[2], buf_fifo_rci2_d1}),                
        .rd(event_fifo_rd[2]),
        .wr(event_fifo_wr[2]),

        .count(),
        .full(event_fifo_full[2]),
        .empty(event_fifo_empty[2]),
        .fullm1(),
        .emptyp2(),
        .dout({event_fifo_sop[2], event_fifo_eop[2], event_fifo_valid_bytes2, event_fifo_error[2], event_fifo_rci2})       
    );
sfifo2f1 #(2+`DATA_PATH_VB_NBITS+1+`RCI_NBITS) u_sfifo2f1_43(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({event_fifo_sop_in[3], buf_fifo_eop_d1[3], event_fifo_valid_bytes_in3, buf_fifo_error_d1[3], buf_fifo_rci3_d1}),                
        .rd(event_fifo_rd[3]),
        .wr(event_fifo_wr[3]),

        .count(),
        .full(event_fifo_full[3]),
        .empty(event_fifo_empty[3]),
        .fullm1(),
        .emptyp2(),
        .dout({event_fifo_sop[3], event_fifo_eop[3], event_fifo_valid_bytes3, event_fifo_error[3], event_fifo_rci3})       
    );

sfifo2f1 #(2+`DATA_PATH_VB_NBITS+1+`RCI_NBITS) u_sfifo2f1_44(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({event_fifo_sop_in[4], buf_fifo_eop_d1[4], event_fifo_valid_bytes_in4, buf_fifo_error_d1[4], buf_fifo_rci4_d1}),                
        .rd(event_fifo_rd[4]),
        .wr(event_fifo_wr[4]),

        .count(),
        .full(event_fifo_full[4]),
        .empty(event_fifo_empty[4]),
        .fullm1(),
        .emptyp2(),
        .dout({event_fifo_sop[4], event_fifo_eop[4], event_fifo_valid_bytes4, event_fifo_error[4], event_fifo_rci4})       
    );
sfifo2f1 #(2+`DATA_PATH_VB_NBITS+1+`RCI_NBITS) u_sfifo2f1_45(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({event_fifo_sop_in[5], buf_fifo_eop_d1[5], event_fifo_valid_bytes_in5, buf_fifo_error_d1[5], buf_fifo_rci5_d1}),                
        .rd(event_fifo_rd[5]),
        .wr(event_fifo_wr[5]),

        .count(),
        .full(),
        .empty(event_fifo_empty[5]),
        .fullm1(),
        .emptyp2(),
        .dout({event_fifo_sop[5], event_fifo_eop[5], event_fifo_valid_bytes5, event_fifo_error[5], event_fifo_rci5})       
    );
sfifo2f1 #(2+`DATA_PATH_VB_NBITS+1) u_sfifo2f1_46(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({event_fifo_sop_in[6], buf_fifo_eop_d1[6], event_fifo_valid_bytes_in6, buf_fifo_error_d1[6]}),                
        .rd(event_fifo_rd[6]),
        .wr(event_fifo_wr[6]),

        .count(),
        .full(),
        .empty(event_fifo_empty[6]),
        .fullm1(),
        .emptyp2(),
        .dout({event_fifo_sop[6], event_fifo_eop[6], event_fifo_valid_bytes6, event_fifo_error[6]})       
    );

sfifo2f1 #(`HEADER_LENGTH_NBITS) u_sfifo2f1_70(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({hdr_len0}),                
        .rd(hdr_len_fifo_rd[0]),
        .wr(hdr_len_fifo_wr[0]),

        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout(hdr_len_fifo_rdata0)       
    );

sfifo2f1 #(`HEADER_LENGTH_NBITS) u_sfifo2f1_71(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({hdr_len1}),                
        .rd(hdr_len_fifo_rd[1]),
        .wr(hdr_len_fifo_wr[1]),

        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout(hdr_len_fifo_rdata1)       
    );

sfifo2f1 #(`HEADER_LENGTH_NBITS) u_sfifo2f1_72(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({hdr_len2}),                
        .rd(hdr_len_fifo_rd[2]),
        .wr(hdr_len_fifo_wr[2]),

        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout(hdr_len_fifo_rdata2)       
    );

sfifo2f1 #(`HEADER_LENGTH_NBITS) u_sfifo2f1_73(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({hdr_len3}),                
        .rd(hdr_len_fifo_rd[3]),
        .wr(hdr_len_fifo_wr[3]),

        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout(hdr_len_fifo_rdata3)       
    );

sfifo2f1 #(`HEADER_LENGTH_NBITS) u_sfifo2f1_74(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({hdr_len4}),                
        .rd(hdr_len_fifo_rd[4]),
        .wr(hdr_len_fifo_wr[4]),

        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout(hdr_len_fifo_rdata4)       
    );

sfifo2f1 #(`HEADER_LENGTH_NBITS) u_sfifo2f1_75(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({hdr_len5}),                
        .rd(hdr_len_fifo_rd[5]),
        .wr(hdr_len_fifo_wr[5]),

        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout(hdr_len_fifo_rdata5)       
    );

sfifo2f1 #(`HEADER_LENGTH_NBITS) u_sfifo2f1_76(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({hdr_len6}),                
        .rd(hdr_len_fifo_rd[6]),
        .wr(hdr_len_fifo_wr[6]),

        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout(hdr_len_fifo_rdata6)       
    );

sfifo2f_fo #(`BUF_PTR_NBITS, PREFETCH_FIFO_DEPTH_NBITS) u_sfifo2f_fo_5(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din(bm_aggr_buf_ptr_d1),               
        .rd(prefetch_fifo_rd),
        .wr(bm_aggr_buf_valid_d1&bm_aggr_buf_available_d1),

        .ncount(),
        .count(prefetch_fifo_depth),
        .full(),
        .empty(prefetch_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout(prefetch_fifo_buf_pointer)       
    );


/***************************** MEMORY ***************************************/
register_file #(`PORT_BUS_NBITS, `PORT_ID_NBITS+1) u_register_file_0(
        .clk(clk),
        .wr(hold_register_wr[0]),
        .raddr(hold_register_raddr),
        .waddr(hold_register_waddr0),
        .din(hold_register_wdata[`PORT_BUS_RANGE]),

        .dout(hold_register_rdata[`PORT_BUS_RANGE]));

register_file #(`PORT_BUS_NBITS, `PORT_ID_NBITS+1) u_register_file_1(
        .clk(clk),
        .wr(hold_register_wr[1]),
        .raddr(hold_register_raddr),
        .waddr(hold_register_waddr1),
        .din(hold_register_wdata[(`PORT_BUS_NBITS<<1)-1:`PORT_BUS_NBITS]),

        .dout(hold_register_rdata[(`PORT_BUS_NBITS<<1)-1:`PORT_BUS_NBITS]));

register_file #(`PORT_BUS_NBITS, `PORT_ID_NBITS+1) u_register_file_2(
        .clk(clk),
        .wr(hold_register_wr[2]),
        .raddr(hold_register_raddr),
        .waddr(hold_register_waddr2),
        .din(hold_register_wdata[(`PORT_BUS_NBITS*3)-1:(`PORT_BUS_NBITS<<1)]),

        .dout(hold_register_rdata[(`PORT_BUS_NBITS*3)-1:(`PORT_BUS_NBITS<<1)]));

register_file #(`PORT_BUS_NBITS, `PORT_ID_NBITS+1) u_register_file_3(
        .clk(clk),
        .wr(hold_register_wr[3]),
        .raddr(hold_register_raddr),
        .waddr(hold_register_waddr3),
        .din(hold_register_wdata[(`PORT_BUS_NBITS*4)-1:(`PORT_BUS_NBITS*3)]),

        .dout(hold_register_rdata[(`PORT_BUS_NBITS*4)-1:(`PORT_BUS_NBITS*3)]));


register_file #(`DATA_PATH_NBITS, HDR_REG_DEPTH_NBITS) u_register_file_6(
        .clk(clk),
        .wr(parser_header_register_wr),
        .raddr(parser_header_register_raddr),
        .waddr(parser_header_register_waddr),
        .din(parser_header_register_wdata),

        .dout(parser_header_register_rdata[`DATA_PATH_NBITS-1:0]));

register_file #(`BUF_PTR_NBITS, META_REG_DEPTH_NBITS) u_register_file_7(
        .clk(clk),
        .wr(buf_ptr_register_wr),
        .raddr(buf_ptr_register_raddr),
        .waddr(buf_ptr_register_waddr),
        .din(buf_ptr_register_wdata),

        .dout(buf_ptr_register_rdata));

register_file #(`RCI_NBITS+`HEADER_LENGTH_NBITS+`PACKET_LENGTH_NBITS+3, META_REG_DEPTH_NBITS) u_register_file_8(
        .clk(clk),
        .wr(meta_data_register_wr),
        .raddr(meta_data_register_raddr),
        .waddr(meta_data_register_waddr),
        .din(meta_data_register_wdata),

        .dout(meta_data_register_rdata));


/***************************** FUNCTION ************************************/
function [3:0] aggr_rot;
input[3:0] din;
input[1:0] rot_cnt;

logic[3:0] din0;

begin
    din0 = rot_cnt[1]?{din[1:0], din[3:2]}:din;
    aggr_rot = rot_cnt[0]?{din0[2:0], din0[3]}:din0;
end
endfunction

function [`DATA_PATH_RANGE] transpose16bytes;
input[`DATA_PATH_RANGE] din;

integer i, j;

begin

	for (i = 0; i < `DATA_PATH_NBITS; i = i+8)
		for (j = 0; j < 8; j = j+1)
			transpose16bytes[i+j] = din[`DATA_PATH_NBITS-1-7-i+j];

end
endfunction

function [31:0] transpose;
input[31:0] din;

begin
	transpose = {din[7:0], din[15:8], din[23:16], din[31:24]};
end
endfunction

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

