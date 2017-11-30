//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import type_package::*;
import meta_package::*;

module pu_core #(
parameter PU_ID = 0,
parameter ID_NBITS = `PU_ID_NBITS,
parameter DATA_NBITS = `DATA_PATH_NBITS,
parameter WIDTH_NBITS = `PU_WIDTH_NBITS,
parameter INST_DEPTH_NBITS = `INST_CHUNK_NBITS-4,
parameter PC_NBITS = INST_DEPTH_NBITS+2+1,
parameter BUFFER_NUM_NBITS = 2,
parameter PD_MEM_BWIDTH_NBITS = 4,
parameter PD_MEM_DEPTH_LSB_NBITS = `PU_MEM_16B_DEPTH_MSB+1-PD_MEM_BWIDTH_NBITS,
parameter PD_MEM_DEPTH_NBITS = PD_MEM_DEPTH_LSB_NBITS+BUFFER_NUM_NBITS,
parameter HOP_MEM_BWIDTH_NBITS = 2,
parameter HOP_MEM_DEPTH_LSB_NBITS = `PU_MEM_4B_DEPTH_MSB+1-HOP_MEM_BWIDTH_NBITS,
parameter HOP_MEM_DEPTH_NBITS = HOP_MEM_DEPTH_LSB_NBITS+BUFFER_NUM_NBITS,
parameter RF_DEPTH_NBITS = 5,
parameter IO_DATA_NBITS = WIDTH_NBITS,
parameter IO_ADDR_NBITS = `PU_MEM_DEPTH_NBITS-2
) (

input clk, 
input `RESET_SIG,

input clk_div, 

input [`PIO_RANGE] reg_addr,
input [`PIO_RANGE] reg_din,
input reg_rd,
input reg_wr,
input reg_ms,

output     mem_ack,
output [`PIO_RANGE] mem_rdata,

input pu_gnt,

input piarb_pu_valid_in,
input [ID_NBITS-1:0] piarb_pu_pid_in,
input piarb_pu_sop_in,
input piarb_pu_eop_in,
input piarb_pu_fid_sel_in,
input [`HOP_INFO_NBITS-1:0] piarb_pu_data_in,
   
input pu_hop_meta_type piarb_pu_meta_data_in,

input piarb_pu_inst_valid_in,
input [ID_NBITS-1:0] piarb_pu_inst_pid_in,
input piarb_pu_inst_sop_in,
input piarb_pu_inst_eop_in,
input [DATA_NBITS-1:0] piarb_pu_inst_data_in,
input piarb_pu_inst_pd_in,
   
input io_ack, 
input [WIDTH_NBITS-1:0] io_ack_data, 

input pu_asa_start_in, 
input pu_asa_valid_in, 
input [WIDTH_NBITS-1:0] pu_asa_data_in, 
input pu_asa_eop_in, 
input [`PU_ID_NBITS-1:0] pu_asa_pu_id_in,

input pu_em_data_valid_in,
input pu_em_sop_in,
input pu_em_eop_in,
input [ID_NBITS-1:0] pu_em_port_id_in,        
input [DATA_NBITS-1:0] pu_em_packet_data_in,

input pu_fid_done_in,
input [`PU_ID_NBITS-1:0] pu_id_in,
input pu_fid_sel_in,

output logic pu_req,

output logic piarb_pu_valid_out,
output logic [ID_NBITS-1:0] piarb_pu_pid_out,
output logic piarb_pu_sop_out,
output logic piarb_pu_eop_out,
output logic piarb_pu_fid_sel_out,
output logic [`HOP_INFO_NBITS-1:0] piarb_pu_data_out,
   
output pu_hop_meta_type  piarb_pu_meta_data_out,

output logic piarb_pu_inst_valid_out,
output logic [ID_NBITS-1:0] piarb_pu_inst_pid_out,
output logic piarb_pu_inst_sop_out,
output logic piarb_pu_inst_eop_out,
output logic [DATA_NBITS-1:0] piarb_pu_inst_data_out,
output logic piarb_pu_inst_pd_out,
   
output logic io_req, 
output io_type io_cmd, 

output logic pu_asa_start_out, 
output logic pu_asa_valid_out, 
output logic [WIDTH_NBITS-1:0] pu_asa_data_out, 
output logic pu_asa_eop_out, 
output logic [`PU_ID_NBITS-1:0] pu_asa_pu_id_out,

output logic pu_em_data_valid_out,
output logic pu_em_sop_out,
output logic pu_em_eop_out,
output logic [ID_NBITS-1:0] pu_em_port_id_out,        
output logic [DATA_NBITS-1:0] pu_em_packet_data_out,

output logic pu_fid_done_out,
output logic [`PU_ID_NBITS-1:0] pu_id_out,
output logic pu_fid_sel_out

);

/***************************** LOCAL VARIABLES *******************************/

integer i, j;

logic init_wr;
logic [INST_DEPTH_NBITS+1:0] init_addr;

logic piarb_pu_valid;
logic [ID_NBITS-1:0] piarb_pu_pid;
logic piarb_pu_sop;
logic piarb_pu_eop;
logic piarb_pu_fid_sel;
logic [`HOP_INFO_NBITS-1:0] piarb_pu_data;
   
pu_hop_meta_type piarb_pu_meta_data;

logic piarb_pu_inst_valid;
logic [ID_NBITS-1:0] piarb_pu_inst_pid;
logic piarb_pu_inst_sop;
logic piarb_pu_inst_eop;
logic [DATA_NBITS-1:0] piarb_pu_inst_data;
logic piarb_pu_inst_pd;
   
logic pu_asa_valid_out_p1; 
logic [WIDTH_NBITS-1:0] pu_asa_data_out_p1; 
logic pu_asa_eop_out_p1; 
logic [`PU_ID_NBITS-1:0] pu_asa_pu_id_out_p1;

logic pu_em_data_valid_out_p1;
logic pu_em_sop_out_p1;
logic pu_em_eop_out_p1;
logic [ID_NBITS-1:0] pu_em_port_id_out_p1;        
logic [DATA_NBITS-1:0] pu_em_packet_data_out_p1;

logic pu_fid_done_out_p1;
logic [`PU_ID_NBITS-1:0] pu_id_out_p1;
logic pu_fid_sel_out_p1;

logic pu_gnt_d1;

logic ras_fifo_wr;
logic ras_fifo_eop_in;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin

                piarb_pu_pid_out <= piarb_pu_pid_in;
                piarb_pu_sop_out <= piarb_pu_sop_in;
                piarb_pu_eop_out <= piarb_pu_eop_in;
                piarb_pu_fid_sel_out <= piarb_pu_fid_sel_in;
                piarb_pu_data_out <= piarb_pu_data_in;
        
                piarb_pu_meta_data_out <= piarb_pu_meta_data_in;
        
                piarb_pu_inst_pid_out <= piarb_pu_inst_pid_in;
                piarb_pu_inst_sop_out <= piarb_pu_inst_sop_in;
                piarb_pu_inst_eop_out <= piarb_pu_inst_eop_in;
                piarb_pu_inst_data_out <= piarb_pu_inst_data_in;
                piarb_pu_inst_pd_out <= piarb_pu_inst_pd_in;

		pu_asa_data_out <= pu_asa_data_out_p1;
		pu_asa_eop_out <= pu_asa_eop_out_p1;
		pu_asa_pu_id_out <= pu_asa_pu_id_out_p1;

		pu_em_sop_out <= pu_em_sop_out_p1;
		pu_em_eop_out <= pu_em_eop_out_p1;
		pu_em_port_id_out <= pu_em_port_id_out_p1;
		pu_em_packet_data_out <= pu_em_packet_data_out_p1;

		pu_fid_sel_out <= pu_fid_sel_out_p1;
		pu_id_out <= pu_id_out_p1;
end

always @(`CLK_RST) 
	if (`ACTIVE_RESET) begin
          
                piarb_pu_valid_out <= 1'b0;
                piarb_pu_inst_valid_out <= 1'b0;
		pu_asa_start_out <= 1'b0;
		pu_asa_valid_out <= 1'b0;
		pu_em_data_valid_out <= 1'b0;
		pu_fid_done_out <= 1'b0;

		pu_req <= 1'b0;

	end else begin
                piarb_pu_valid_out <= piarb_pu_valid_in;
                piarb_pu_inst_valid_out <= piarb_pu_inst_valid_in;
		pu_asa_start_out <= pu_asa_start_in;
		pu_asa_valid_out <= pu_asa_valid_out_p1;
		pu_em_data_valid_out <= pu_em_data_valid_out_p1;
		pu_fid_done_out <= pu_fid_done_out_p1;

		pu_req <= ras_fifo_wr&ras_fifo_eop_in;

	end


/***************************** PROGRAM BODY **********************************/

logic ff_piarb_pu_valid;
logic ff_piarb_pu_sop;
logic ff_piarb_pu_eop;
logic ff_piarb_pu_fid_sel;
logic [`HOP_INFO_NBITS-1:0] ff_piarb_pu_data;

logic hop_fifo_empty;
logic hop_fifo_rd;
wire hop_fifo_wr = piarb_pu_valid&piarb_pu_pid==PU_ID;


sfifo2f_fo #(`HOP_INFO_NBITS+3, 4) u_sfifo2f_fo_00(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(hop_fifo_wr), .din({piarb_pu_data, piarb_pu_sop, piarb_pu_eop, piarb_pu_fid_sel}), .dout({ff_piarb_pu_data, ff_piarb_pu_sop, ff_piarb_pu_eop, ff_piarb_pu_fid_sel}), .rd(hop_fifo_rd), .full(), .empty(hop_fifo_empty), .ncount(), .count(), .fullm1(), .emptyp2());

logic hop_meta_fifo_empty;
logic hop_meta_fifo_rd;
wire hop_meta_fifo_wr = hop_fifo_wr&piarb_pu_sop;
pu_hop_meta_type ff_piarb_pu_meta_data;

sfifo_pu_hop_meta #(1) u_sfifo_pu_hop_meta_0(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(hop_meta_fifo_wr), .din(piarb_pu_meta_data), .dout(ff_piarb_pu_meta_data), .rd(hop_meta_fifo_rd), .full(), .empty(hop_meta_fifo_empty), .ncount(), .count(), .fullm1(), .emptyp2());

logic last_en_hop_wr0;
logic last_en_hop_wr1;
logic [1:0] hop_st;
logic [1:0] n_hop_st;
always @*
	case(hop_st)
		0: n_hop_st = last_en_hop_wr0&last_en_hop_wr1?3:last_en_hop_wr0?1:last_en_hop_wr1?2:0;
		1: n_hop_st = last_en_hop_wr1?3:1;
		2: n_hop_st = last_en_hop_wr0?3:2;
		3: n_hop_st = 0;
	endcase
flop_rst #(2, 0) u_flop_rst_112(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({n_hop_st}), .dout({hop_st}));

logic en_meta_zero;
logic [3:0] hop_wr_cnt0;
logic [3:0] hop_wr_cnt1;
wire en_piarb_wr = ~(hop_st==1);
wire en_hop_wr00 = en_piarb_wr&~hop_meta_fifo_empty&(hop_wr_cnt0<3);
wire en_hop_wr01 = en_piarb_wr&~hop_fifo_empty&(hop_wr_cnt0>2)&~en_meta_zero;
assign hop_fifo_rd = en_hop_wr01;

wire en_hop_wr0 = en_meta_zero|en_hop_wr00|en_hop_wr01;

wire last_hop_wr_cnt0 = hop_wr_cnt0==13;
wire last_hop_wr_cnt1 = hop_wr_cnt1==14;
wire [`HOP_INFO_PC_NBITS+3-1:0] pc_to_load_p1 = ff_piarb_pu_data[`HOP_INFO_PC]<<(ff_piarb_pu_data[`HOP_INFO_FLAGS]+1);
logic [`HOP_INFO_PC_NBITS+3-1:0] pc_to_load;
logic [`HOP_INFO_FLAGS_RANGE] flags_to_load;
logic [`HOP_INFO_BYTE_POINTER_RANGE] ptr_to_load;
wire first_en_hop_wr0 = en_hop_wr00&hop_wr_cnt0==0;

flop_en #(`HOP_INFO_BYTE_POINTER_NBITS+`HOP_INFO_PC_NBITS+3) u_flop_en_0023(.clk(clk), .en(first_en_hop_wr0), .din({ff_piarb_pu_data[`HOP_INFO_BYTE_POINTER], pc_to_load_p1}), .dout({ptr_to_load, pc_to_load}));
logic en_hop_wr1_en;
logic en_hop_wr1;
assign last_en_hop_wr0 = en_hop_wr0&last_hop_wr_cnt0;
assign last_en_hop_wr1 = en_hop_wr1&last_hop_wr_cnt1;
wire en_meta_zero_p1 = last_en_hop_wr0?1'b0:en_hop_wr01&ff_piarb_pu_eop?1'b1:en_meta_zero;
wire en_hop_wr1_en_p1 = first_en_hop_wr0?1'b1:last_en_hop_wr1?1'b0:en_hop_wr1_en;
flop_rst #(2, 0) u_flop_rst_0(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({en_meta_zero_p1, en_hop_wr1_en_p1}), .dout({en_meta_zero, en_hop_wr1_en}));
assign en_hop_wr1 = en_hop_wr1_en&~en_hop_wr0;
wire [3:0] hop_wr_cnt0_p1 = ~en_hop_wr0?hop_wr_cnt0:last_en_hop_wr0?0:hop_wr_cnt0+1;
wire [3:0] hop_wr_cnt1_p1 = ~en_hop_wr1?hop_wr_cnt1:last_en_hop_wr1?0:hop_wr_cnt1+1;
flop_rst #(8, 0) u_flop_rst_1(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({hop_wr_cnt1_p1, hop_wr_cnt0_p1}), .dout({hop_wr_cnt1, hop_wr_cnt0}));

logic [BUFFER_NUM_NBITS-1:0] wr_hop_buf_sel;
wire [BUFFER_NUM_NBITS-1:0] n_wr_hop_buf_sel = wr_hop_buf_sel+1;
wire hop_wr_done_p1 = n_hop_st==3;
assign hop_meta_fifo_rd = hop_wr_done_p1;
wire toggle_wr0 = hop_st==3;
flop_rst_en #(BUFFER_NUM_NBITS) u_flop_rst_en_3(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(toggle_wr0), .din({(n_wr_hop_buf_sel)}), .dout({wr_hop_buf_sel}));

wire [3:0] hop_wr_addr = en_hop_wr0?hop_wr_cnt0:hop_wr_cnt1;

wire ram_wr01 = en_hop_wr0|en_hop_wr1_en;
logic [WIDTH_NBITS-1:0] ram_wdata01;
always @*
	if(en_hop_wr0) 
		case(hop_wr_cnt0)
			0: ram_wdata01 = ff_piarb_pu_meta_data.creation_time;
			1: ram_wdata01 = {ff_piarb_pu_meta_data.switch_tag, ff_piarb_pu_meta_data.pkt_type};
			2: ram_wdata01 = ff_piarb_pu_meta_data.rci_type;
			12: ram_wdata01 = {ff_piarb_pu_meta_data.f_payload};
			13: ram_wdata01 = {ff_piarb_pu_meta_data.fid, {(16-`TID_NBITS){1'b0}}, ff_piarb_pu_meta_data.tid};
			default: ram_wdata01 = en_meta_zero?0:ff_piarb_pu_data;
		endcase
	else
		case(hop_wr_cnt1)
			0: ram_wdata01 = 3'b110;
			1: ram_wdata01 = 3'b000;
			2: ram_wdata01 = 1'b1;
			3: ram_wdata01 = 1'b1;
			4: ram_wdata01 = 6'b111101;
			14: ram_wdata01 = {16'b0, ptr_to_load};
			default: ram_wdata01 = 0;
			//default: ram_wdata01 = ~hop_wr_cnt1[0]?(`DEFAULT_RCI+1):`DEFAULT_RCI;
		endcase

wire [HOP_MEM_DEPTH_NBITS-1:0] ram_waddr01 = {wr_hop_buf_sel, (en_hop_wr1?{`PU_MEM_RAS, 2'b0}:{`PU_MEM_META, `PU_MEM_META_META, 1'b0}), hop_wr_addr};

wire last_ram_wr01 = ram_wr01&hop_wr_done_p1;

wire en_inst_pd_wr = piarb_pu_inst_valid&piarb_pu_inst_pid==PU_ID;
wire en_inst_wr0 = en_inst_pd_wr&piarb_pu_inst_pd;
wire en_inst_wr = init_wr|en_inst_wr0;
wire toggle_wr1 = en_inst_pd_wr&piarb_pu_inst_eop;

logic wr_inst_buf_sel;
flop_rst_en #(1) u_flop_rst_en_5(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(toggle_wr1), .din({~wr_inst_buf_sel}), .dout({wr_inst_buf_sel}));

logic [INST_DEPTH_NBITS-1:0] inst_wr_addr_lsb;
wire [INST_DEPTH_NBITS-1:0] inst_wr_addr_lsb_p1 = toggle_wr1?0:~en_inst_wr0?inst_wr_addr_lsb:inst_wr_addr_lsb+1;
flop_rst #(INST_DEPTH_NBITS) u_flop_rst_6(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({inst_wr_addr_lsb_p1}), .dout({inst_wr_addr_lsb}));
wire [INST_DEPTH_NBITS:0] inst_wr_addr = init_wr?init_addr[INST_DEPTH_NBITS:0]:{wr_inst_buf_sel, inst_wr_addr_lsb};

logic ff_piarb_pu_inst_sop;
logic ff_piarb_pu_inst_eop;
logic [`DATA_PATH_NBITS-1:0] ff_piarb_pu_inst_data;

logic piarb_pu_inst_pd_d1;
logic pd_wr_fifo_empty;
logic pd_wr_fifo_rd;
wire pd_wr_fifo_wr = en_inst_pd_wr&~piarb_pu_inst_pd;

sfifo2f_fo #(`DATA_PATH_NBITS+2, 3) u_sfifo2f_fo_100(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(pd_wr_fifo_wr), .din({piarb_pu_inst_data, (~piarb_pu_inst_pd&piarb_pu_inst_pd_d1), piarb_pu_inst_eop}), .dout({ff_piarb_pu_inst_data, ff_piarb_pu_inst_sop, ff_piarb_pu_inst_eop}), .rd(pd_wr_fifo_rd), .full(), .empty(pd_wr_fifo_empty), .count(), .ncount(), .fullm1(), .emptyp2());

logic [1:0] pd_st;
logic [2:0] pd_wr_cnt;
logic [2:0] scratch_wr_cnt;
logic pd_wr_zero_st;
logic scratch_wr_st;
wire en_pd_wr0 = ~pd_wr_fifo_empty&~pd_wr_zero_st&~(pd_st==1);
assign pd_wr_fifo_rd = en_pd_wr0;
wire set_scratch_wr_st = en_pd_wr0&ff_piarb_pu_inst_sop;
wire set_pd_wr_zero_st = en_pd_wr0&ff_piarb_pu_inst_eop;
wire en_pd_wr = pd_wr_zero_st|en_pd_wr0;
wire en_scratch_wr = ~en_pd_wr&scratch_wr_st;

wire last_pd_wr = en_pd_wr&(&pd_wr_cnt);
wire last_scratch_wr = en_scratch_wr&(&scratch_wr_cnt);

wire n_pd_wr_zero_st = last_pd_wr?1'b0:set_pd_wr_zero_st?1'b1:pd_wr_zero_st;
wire n_scratch_wr_st = set_scratch_wr_st?1'b1:last_scratch_wr?1'b0:scratch_wr_st;

wire [2:0] pd_wr_cnt_p1 = ~en_pd_wr?pd_wr_cnt:pd_wr_cnt+1;
wire [2:0] scratch_wr_cnt_p1 = ~en_scratch_wr?scratch_wr_cnt:scratch_wr_cnt+1;
flop_rst #(8) u_flop_rst_64(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({n_pd_wr_zero_st, n_scratch_wr_st, pd_wr_cnt_p1, scratch_wr_cnt_p1}), .dout({pd_wr_zero_st, scratch_wr_st, pd_wr_cnt, scratch_wr_cnt}));

logic [1:0] n_pd_st;
always @*
	case(pd_st)
		0: n_pd_st = last_pd_wr&last_scratch_wr?3:last_pd_wr?1:last_scratch_wr?2:0;
		1: n_pd_st = last_scratch_wr?3:1;
		2: n_pd_st = last_pd_wr?3:2;
		3: n_pd_st = 0;
	endcase
flop_rst #(2, 0) u_flop_rst_312(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({n_pd_st}), .dout({pd_st}));

wire last_en_pd_wr = n_pd_st==3;

logic [BUFFER_NUM_NBITS-1:0] wr_pd_buf_sel;
wire [BUFFER_NUM_NBITS-1:0] n_wr_pd_buf_sel = wr_pd_buf_sel+1;
flop_rst_en #(BUFFER_NUM_NBITS) u_flop_rst_en_61(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(last_en_pd_wr), .din({(n_wr_pd_buf_sel)}), .dout({wr_pd_buf_sel}));

logic mem_update_pc;
logic exec_update_pc;

logic db_fifo_pc_msb;
logic [`HOP_INFO_PC_NBITS+3-1:0] db_fifo_pc;
logic [`TID_NBITS-1:0] db_fifo_tid;
logic [`FID_NBITS-1:0] db_fifo_fid;
logic db_fifo_fid_sel;
logic [BUFFER_NUM_NBITS-1:0] db_fifo_buf_sel;
wire [BUFFER_NUM_NBITS-1:0] n_db_fifo_buf_sel = db_fifo_buf_sel+1;
logic db_fifo_empty;
logic db_fifo_full;

wire db_fifo_rd = mem_update_pc;

sfifo2f1 #(`HOP_INFO_PC_NBITS+3) u_sfifo2f1_00(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(last_ram_wr01), .din({pc_to_load}), .dout({db_fifo_pc}), .rd(db_fifo_rd), .full(), .empty(db_fifo_empty), .count(), .fullm1(), .emptyp2());

sfifo2f1 #(1+`TID_NBITS+`FID_NBITS) u_sfifo2f1_0(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(hop_wr_done_p1), .din({piarb_pu_meta_data.tid, piarb_pu_meta_data.fid, piarb_pu_fid_sel}), .dout({db_fifo_tid, db_fifo_fid, db_fifo_fid_sel}), .rd(db_fifo_rd), .full(db_fifo_full), .empty(), .count(), .fullm1(), .emptyp2());

flop_rst_en #(BUFFER_NUM_NBITS+1) u_flop_rst_en_7(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(db_fifo_rd), .din({(n_db_fifo_buf_sel), ~db_fifo_pc_msb}), .dout({db_fifo_buf_sel, db_fifo_pc_msb}));

/* issue */

wire en_update_pc = ~db_fifo_empty;

logic inst_fifo_full;
logic inst_fifo_rd;

wire inst_fifo_av = ~inst_fifo_full|inst_fifo_rd;

logic stall_pipeline;
wire update_pc = ~stall_pipeline&en_update_pc&inst_fifo_av;

logic end_load_pc;
logic end_load_pc_sv;
wire n_end_load_pc_sv = end_load_pc&~update_pc?1'b1:update_pc?1'b0:end_load_pc_sv;

logic db_fifo_rd_d1;
wire n_db_fifo_rd_d1 = db_fifo_rd&~db_fifo_full?1'b1:~db_fifo_empty?1'b0:db_fifo_rd_d1;
flop_rst #(2, 2'b01) u_flop_rst_611(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({n_end_load_pc_sv, n_db_fifo_rd_d1}), .dout({end_load_pc_sv, db_fifo_rd_d1}));
wire hold_pc = db_fifo_rd&~db_fifo_full|db_fifo_rd_d1;

assign end_load_pc = (db_fifo_rd&db_fifo_full)|(db_fifo_rd_d1&~db_fifo_empty);

logic [PC_NBITS-1:0] exec_pc;

wire exec_pc_fifo_wr = exec_update_pc&~update_pc;
logic exec_pc_fifo_empty;
wire exec_pc_fifo_rd = ~exec_pc_fifo_empty&update_pc;
logic [PC_NBITS-1:0] exec_pc_fifo_pc;
sfifo1f #(PC_NBITS) u_sfifo1f_137(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(exec_pc_fifo_wr), .din({exec_pc}), .dout({exec_pc_fifo_pc}), .rd(exec_pc_fifo_rd), .full(), .empty(exec_pc_fifo_empty));

logic [PC_NBITS-1:0] pc;
wire [PC_NBITS-1:0] next_pc = end_load_pc_sv|end_load_pc?db_fifo_pc:exec_pc_fifo_rd?exec_pc_fifo_pc:exec_update_pc?exec_pc:hold_pc?pc:pc+2;

logic dec_flag;
wire mend_load_pc = (end_load_pc_sv|end_load_pc)&update_pc;
flop_rst_en #(1, 1) u_flop_rst_en_8(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(mend_load_pc), .din({~dec_flag}), .dout({dec_flag}));

logic exec_flag;
wire mexec_update_pc = exec_update_pc&update_pc|exec_pc_fifo_rd;
flop_rst_en #(1) u_flop_rst_en_9(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(mexec_update_pc), .din({~exec_flag}), .dout({exec_flag}));

logic [PC_NBITS-1:0] pc_d1;
flop_rst_en #(PC_NBITS<<1) u_pc(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(update_pc), .din({pc, next_pc}), .dout({pc_d1, pc}));

logic [WIDTH_NBITS-1:0] ram_inst0, ram_inst1, ram_inst2, ram_inst3, ram_inst;/* synthesis DONT_TOUCH */
ram_1r1w_bram #(WIDTH_NBITS, INST_DEPTH_NBITS+1) u_ram_1r1w_bram_0(.clk(clk), .wr(en_inst_wr), .raddr({db_fifo_pc_msb, pc[PC_NBITS-1:3]}), .waddr(inst_wr_addr), .din(init_wr?0:piarb_pu_inst_data[WIDTH_NBITS-1:0]), .dout(ram_inst0));
ram_1r1w_bram #(WIDTH_NBITS, INST_DEPTH_NBITS+1) u_ram_1r1w_bram_1(.clk(clk), .wr(en_inst_wr), .raddr({db_fifo_pc_msb, pc[PC_NBITS-1:3]}), .waddr(inst_wr_addr), .din(init_wr?0:piarb_pu_inst_data[WIDTH_NBITS*2-1:WIDTH_NBITS*1]), .dout(ram_inst1));
ram_1r1w_bram #(WIDTH_NBITS, INST_DEPTH_NBITS+1) u_ram_1r1w_bram_2(.clk(clk), .wr(en_inst_wr), .raddr({db_fifo_pc_msb, pc[PC_NBITS-1:3]}), .waddr(inst_wr_addr), .din(init_wr?0:piarb_pu_inst_data[WIDTH_NBITS*3-1:WIDTH_NBITS*2]), .dout(ram_inst2));
ram_1r1w_bram #(WIDTH_NBITS, INST_DEPTH_NBITS+1) u_ram_1r1w_bram_3(.clk(clk), .wr(en_inst_wr), .raddr({db_fifo_pc_msb, pc[PC_NBITS-1:3]}), .waddr(inst_wr_addr), .din(init_wr?0:piarb_pu_inst_data[WIDTH_NBITS*4-1:WIDTH_NBITS*3]), .dout(ram_inst3));

logic inst_fifo_wr;
logic first_inst;
logic set_first_inst_d1;
wire set_first_inst = mend_load_pc|mexec_update_pc;
wire first_inst_p1 = set_first_inst?1'b1:inst_fifo_wr?1'b0:first_inst;
logic update_pc_d1;
logic en_update_pc_d1;
logic odd_addr;
wire odd_addr1 = set_first_inst&next_pc[0]|odd_addr;
flop_rst_en #(1) u_flop_rst_en_910(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(set_first_inst), .din({next_pc[0]}), .dout({odd_addr}));
flop_rst #(1, 1) u_flop_rst_910(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({first_inst_p1}), .dout({first_inst}));
flop_rst #(3) u_flop_rst_10(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({set_first_inst, en_update_pc, update_pc}), .dout({set_first_inst_d1, en_update_pc_d1, update_pc_d1}));
always @(*) case(pc_d1[2:1]) 2'b00: ram_inst = ram_inst3; 2'b01: ram_inst = ram_inst2; 2'b10: ram_inst = ram_inst1; 2'b11: ram_inst = ram_inst0; endcase

logic lower_av;
logic [15:0] inst_sv;
flop_rst_en #(16+1) u_flop_rst_en_11(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(update_pc_d1), .din({ram_inst[15:0], pc_d1[0]}), .dout({inst_sv, lower_av}));

logic inst_fifo_first_inst;
logic [PC_NBITS-1:0] inst_fifo_pc;
wire [WIDTH_NBITS-1:0] instruction = lower_av&~(inst_fifo_first_inst&~inst_fifo_pc[0])?{inst_sv, ram_inst[31:16]}:ram_inst;

assign inst_fifo_wr = ~(set_first_inst_d1&pc[0])&~stall_pipeline&en_update_pc_d1&~db_fifo_rd&inst_fifo_av;

logic [`TID_NBITS-1:0] inst_fifo_tid;
logic [`FID_NBITS-1:0] inst_fifo_fid;
logic inst_fifo_odd_addr;
logic inst_fifo_dec_flag;
logic inst_fifo_exec_flag;
logic inst_fifo_fid_sel;
logic [BUFFER_NUM_NBITS-1:0] inst_fifo_buf_sel;
logic inst_fifo_empty;
sfifo1f #(3+`TID_NBITS+`FID_NBITS+1+BUFFER_NUM_NBITS+PC_NBITS+1) u_sfifo1f_1(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(inst_fifo_wr), .din({first_inst, dec_flag, exec_flag, db_fifo_tid, db_fifo_fid, db_fifo_fid_sel, db_fifo_buf_sel, pc, odd_addr1}), .dout({inst_fifo_first_inst, inst_fifo_dec_flag, inst_fifo_exec_flag, inst_fifo_tid, inst_fifo_fid, inst_fifo_fid_sel, inst_fifo_buf_sel, inst_fifo_pc, inst_fifo_odd_addr}), .rd(inst_fifo_rd), .full(inst_fifo_full), .empty(inst_fifo_empty));

/* fetch */

logic inst_fifo_wr_d1;
flop_rst #(1) u_flop_rst_en_311(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({inst_fifo_wr}), .dout({inst_fifo_wr_d1}));

wire instr_fifo_wr = inst_fifo_wr_d1&~inst_fifo_rd;
wire instr_fifo_rd = ~inst_fifo_wr_d1&inst_fifo_rd;
logic [WIDTH_NBITS-1:0] instruction_d1;
sfifo1f #(WIDTH_NBITS) u_sfifo1f_91(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(instr_fifo_wr), .din({instruction}), .dout({instruction_d1}), .rd(instr_fifo_rd), .full(), .empty());
logic [15:0] inst_low_half;

wire [WIDTH_NBITS-1:0] instr = inst_fifo_wr_d1?instruction:instruction_d1;

logic low_half_av;
wire mlow_half_av = ~inst_fifo_first_inst&low_half_av;

wire inst_32b = mlow_half_av?&inst_low_half[1:0]:&instr[17:16];

logic fetch_fifo_rd;
logic fetch_fifo_full;
wire fetch_fifo_av = ~fetch_fifo_full|fetch_fifo_rd;
wire inst_16b_av = ~inst_32b&mlow_half_av;
wire fetch_fifo_wr = ~stall_pipeline&fetch_fifo_av&(inst_16b_av|~inst_fifo_empty);
assign inst_fifo_rd = ~stall_pipeline&fetch_fifo_av&~inst_fifo_empty&~inst_16b_av;

wire low_half = mlow_half_av?inst_32b:~inst_32b;

logic [PC_NBITS-1:0] n_fetch_fifo_pc;
wire [PC_NBITS-1:0] n_fetch_fifo_pc_p1 = inst_fifo_odd_addr?inst_fifo_pc-1:inst_fifo_pc+1;
flop_rst_en #(16+1+PC_NBITS) u_flop_rst_en_12(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(fetch_fifo_wr), .din({instr[15:0], low_half, n_fetch_fifo_pc_p1}), .dout({inst_low_half, low_half_av, n_fetch_fifo_pc}));

logic [PC_NBITS-1:0] fetch_fifo_pc;
wire [PC_NBITS-1:0] fetch_fifo_pc_p1 = mlow_half_av?n_fetch_fifo_pc:inst_fifo_odd_addr?inst_fifo_pc-2:inst_fifo_pc;

logic [`TID_NBITS-1:0] fetch_fifo_tid;
logic [`FID_NBITS-1:0] fetch_fifo_fid;
logic fetch_fifo_inst_32b;
logic fetch_fifo_fid_sel;
logic [BUFFER_NUM_NBITS-1:0] fetch_fifo_buf_sel;
logic fetch_fifo_dec_flag;
logic fetch_fifo_exec_flag;
wire [WIDTH_NBITS-1:0] fetch_fifo_din1 = mlow_half_av?{inst_low_half, instr[31:16]}:instr;
wire [WIDTH_NBITS-1:0] fetch_fifo_din = inst_32b?{fetch_fifo_din1[15:0], fetch_fifo_din1[31:16]}:expansion(fetch_fifo_din1[31:16]);
logic fetch_fifo_empty;
logic [WIDTH_NBITS-1:0] fetch_fifo_dout;
sfifo1f #(1+WIDTH_NBITS+2+`TID_NBITS+`FID_NBITS+1+BUFFER_NUM_NBITS+PC_NBITS) u_sfifo1f_2(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(fetch_fifo_wr), .din({fetch_fifo_pc_p1, inst_32b, fetch_fifo_din, inst_fifo_dec_flag, inst_fifo_exec_flag, inst_fifo_tid, inst_fifo_fid, inst_fifo_fid_sel, inst_fifo_buf_sel}), .dout({fetch_fifo_pc, fetch_fifo_inst_32b, fetch_fifo_dout, fetch_fifo_dec_flag, fetch_fifo_exec_flag, fetch_fifo_tid, fetch_fifo_fid, fetch_fifo_fid_sel, fetch_fifo_buf_sel}), .rd(fetch_fifo_rd), .full(fetch_fifo_full), .empty(fetch_fifo_empty));

/* decode */

dec_type dec_cmd;
pu_decode u_pu_decode(.inst(fetch_fifo_dout), .dec_cmd(dec_cmd));

logic wb_en;
logic [WIDTH_NBITS-1:0] wb_data;
logic [RF_DEPTH_NBITS-1:0] wb_addr;

logic [WIDTH_NBITS-1:0] rf_data0, rf_data1;

pu_rf #(WIDTH_NBITS, RF_DEPTH_NBITS) u_pu_rf(.clk(clk), .`RESET_SIG(`COMBINE_RESET(mem_update_pc)), .wr(wb_en), .raddr0(dec_cmd.rs1), .raddr1(dec_cmd.rs2), .waddr(wb_addr), .din(wb_data), .dout0(rf_data0), .dout1(rf_data1));

wire inst_16b = ~fetch_fifo_inst_32b;

logic en_load_delay;
logic dec_fifo_empty;
logic exec_fifo_empty;
logic mem_fifo_empty;
logic mem_fifo_load00;
logic mem_fifo_load10;
exec_type exec_cmd, exec_cmd_d1, exec_cmd_d2;
wire load_use_delay_en = ~dec_fifo_empty&(exec_cmd.load&~dec_cmd.load)&((dec_cmd.use_rs1&(exec_cmd.wb_addr==dec_cmd.rs1))|(dec_cmd.use_rs2&(exec_cmd.wb_addr==dec_cmd.rs2)));
wire load_use_delay_en0 = ~exec_fifo_empty&(exec_cmd_d1.load&~dec_cmd.load)&((dec_cmd.use_rs1&(exec_cmd_d1.wb_addr==dec_cmd.rs1))|(dec_cmd.use_rs2&(exec_cmd_d1.wb_addr==dec_cmd.rs2)));
wire load_use_delay_en1 = ~mem_fifo_empty&(exec_cmd_d2.load&~dec_cmd.load&(mem_fifo_load00|mem_fifo_load10))&((dec_cmd.use_rs1&(exec_cmd_d2.wb_addr==dec_cmd.rs1))|(dec_cmd.use_rs2&(exec_cmd_d2.wb_addr==dec_cmd.rs2)));
logic dec_fifo_full;
logic dec_fifo_rd;
wire dec_fifo_av = ~dec_fifo_full|dec_fifo_rd;
wire dec_fifo_wr_en = ~(load_use_delay_en|load_use_delay_en0|load_use_delay_en1)&~stall_pipeline&~fetch_fifo_empty&dec_fifo_av;
assign fetch_fifo_rd = dec_fifo_wr_en;

wire dec_fifo_wr = dec_fifo_wr_en;

flop_rst_en #(1) u_flop_rst_en_131(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(dec_fifo_wr), .din(1'b1), .dout({en_load_delay}));
logic dec_fifo_wr_d1;
flop_rst #(1) u_flop_rst_131(.clk(clk), .`RESET_SIG(`RESET_SIG), .din(dec_fifo_wr), .dout({dec_fifo_wr_d1}));

dec_type dec_cmd_d1;
always @(posedge clk) dec_cmd_d1 <= dec_fifo_wr?dec_cmd:dec_cmd_d1;

wire dec_fifo_end_program = dec_cmd_d1.end_program;
wire dec_fifo_exception = dec_cmd_d1.exception;

logic [`TID_NBITS-1:0] dec_fifo_tid;
logic [`FID_NBITS-1:0] dec_fifo_fid;
logic [PC_NBITS-1:0] dec_fifo_pc;
logic dec_fifo_inst_32b;
logic dec_fifo_fid_sel;
logic [BUFFER_NUM_NBITS-1:0] dec_fifo_buf_sel;
logic dec_fifo_dec_flag;
logic dec_fifo_exec_flag;
sfifo1f #(3+`TID_NBITS+`FID_NBITS+1+BUFFER_NUM_NBITS+PC_NBITS) u_sfifo1f_3(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(dec_fifo_wr), .din({fetch_fifo_inst_32b, fetch_fifo_dec_flag, fetch_fifo_exec_flag, fetch_fifo_tid, fetch_fifo_fid, fetch_fifo_fid_sel, fetch_fifo_buf_sel, fetch_fifo_pc}), .dout({dec_fifo_inst_32b, dec_fifo_dec_flag, dec_fifo_exec_flag, dec_fifo_tid, dec_fifo_fid, dec_fifo_fid_sel, dec_fifo_buf_sel, dec_fifo_pc}), .rd(dec_fifo_rd), .full(dec_fifo_full), .empty(dec_fifo_empty));

/* execution */

logic mem_wb_en;
logic [RF_DEPTH_NBITS-1:0] mem_wb_addr_p1;
logic [WIDTH_NBITS-1:0] mem_wb_data;

logic wb_en0;
logic [RF_DEPTH_NBITS-1:0] wb_addr0_p1;
logic [WIDTH_NBITS-1:0] wb_data0;
logic [WIDTH_NBITS-1:0] wb_data00;
logic [WIDTH_NBITS-1:0] wb_data0_d1;

wire rs1_eq0_p1 = dec_cmd.rs1==0;
logic rs1_eq0;

wire mem_wb_addr_cmp1_p1 = (dec_cmd.rs1==mem_wb_addr_p1);
logic mem_wb_addr_cmp1;

wire wb_addr0_cmp1_p1 = (dec_cmd.rs1==wb_addr0_p1);
logic wb_addr0_cmp1;

wire wb_addr0_cmp11_p1 = (dec_cmd.rs1==wb_addr);
logic wb_addr0_cmp11;

wire rs2_eq0_p1 = dec_cmd.rs2==0;
logic rs2_eq0;

wire mem_wb_addr_cmp2_p1 = (dec_cmd.rs2==mem_wb_addr_p1);
logic mem_wb_addr_cmp2;

wire wb_addr0_cmp2_p1 = (dec_cmd.rs2==wb_addr0_p1);
logic wb_addr0_cmp2;

wire wb_addr0_cmp22_p1 = (dec_cmd.rs2==wb_addr);
logic wb_addr0_cmp22;

flop_rst_en #(2+WIDTH_NBITS+6) u_flop_rst_en_79(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(dec_fifo_wr), .din({(wb_en0&wb_addr0_cmp11_p1), (wb_en0&wb_addr0_cmp22_p1), wb_data0, rs1_eq0_p1, rs2_eq0_p1, mem_wb_addr_cmp1_p1, wb_addr0_cmp1_p1, mem_wb_addr_cmp2_p1, wb_addr0_cmp2_p1}), .dout({wb_en0_cmp11, wb_en0_cmp22, wb_data0_d1, rs1_eq0, rs2_eq0, mem_wb_addr_cmp1, wb_addr0_cmp1, mem_wb_addr_cmp2, wb_addr0_cmp2}));

logic jump_rd_eq0;
logic valid_inst;
logic exec_fifo_wr;
wire rf_fifo_wr = dec_fifo_wr_d1&~exec_fifo_wr&valid_inst&~jump_rd_eq0;
logic rf_fifo_empty;
logic rf_fifo_rd;
logic [WIDTH_NBITS-1:0] rf_fifo_dout;
logic [WIDTH_NBITS-1:0] rf_fifo_dout1;
sfifo1f #(WIDTH_NBITS*2) u_sfifo1f_41(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(rf_fifo_wr), .din({rf_data0, rf_data1}), .dout({rf_fifo_dout, rf_fifo_dout1}), .rd(rf_fifo_rd), .full(), .empty(rf_fifo_empty));
wire [WIDTH_NBITS-1:0] mmrf_data0 = rf_fifo_empty?rf_data0:rf_fifo_dout;
wire [WIDTH_NBITS-1:0] mmrf_data1 = rf_fifo_empty?rf_data1:rf_fifo_dout1;

wire [WIDTH_NBITS-1:0] mrf_data0 = mem_wb_en&mem_wb_addr_cmp1?mem_wb_data:
				wb_en0&wb_addr0_cmp1?wb_data00:
				wb_en0_cmp11?wb_data0_d1:rs1_eq0?0:mmrf_data0;

wire [WIDTH_NBITS-1:0] mrf_data1 = mem_wb_en&mem_wb_addr_cmp2?mem_wb_data:
				wb_en0&wb_addr0_cmp2?wb_data00:
				wb_en0_cmp22?wb_data0_d1:rs2_eq0?0:mmrf_data1;

wire [2:0] alu_f3 = dec_cmd_d1.load|dec_cmd_d1.store|dec_cmd_d1.atomic?0:dec_cmd_d1.funct3;
wire [4:0] alu_f5 = dec_cmd_d1.load|dec_cmd_d1.store|dec_cmd_d1.atomic?0:dec_cmd_d1.funct5;

logic [WIDTH_NBITS-1:0] alu_out;
pu_alu u_pu_alu(.use_imm(dec_cmd_d1.use_imm), .imm(dec_cmd_d1.imm), .rs1(mrf_data0), .rs2(mrf_data1), .funct3(alu_f3), .funct5(alu_f5), .alu(alu_out));

logic do_branch;
always @*
	case (dec_cmd_d1.funct3[1:0])
		2'b00: do_branch = mrf_data0==mrf_data1?1:0;
		2'b10: do_branch = $signed(mrf_data0)<$signed(mrf_data1)?1:0;
		default: do_branch = mrf_data0<mrf_data1?1:0;
	endcase

logic exec_fifo_full;
logic exec_fifo_rd;
wire exec_fifo_av = ~exec_fifo_full|exec_fifo_rd;
wire exec_fifo_wr_en = ~stall_pipeline&~dec_fifo_empty&exec_fifo_av;
assign dec_fifo_rd = exec_fifo_wr_en;

logic exec_exec_flag;
logic exec_dec_flag;
assign valid_inst = (exec_exec_flag==dec_fifo_exec_flag)&(exec_dec_flag==dec_fifo_dec_flag);
wire good_inst = exec_fifo_wr_en&valid_inst;

flop_rst_en #(1) u_flop_rst_en_13(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(good_inst&(dec_fifo_end_program|dec_fifo_exception)), .din({~exec_dec_flag}), .dout({exec_dec_flag}));
flop_rst_en #(1) u_flop_rst_en_14(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(exec_update_pc), .din({~exec_exec_flag}), .dout({exec_exec_flag}));

wire [WIDTH_NBITS-1:0] pc_offset = dec_cmd_d1.imm;
wire [WIDTH_NBITS-1:0] pc_base = dec_cmd_d1.jalr?mrf_data0<<1:dec_fifo_pc;
wire [WIDTH_NBITS-1:0] new_pc = pc_base+pc_offset;
assign exec_pc = dec_cmd_d1.jalr?new_pc>>1:new_pc;
assign en_exec_update_pc_j = dec_cmd_d1.jal|dec_cmd_d1.jalr;
assign en_exec_update_pc_b = dec_cmd_d1.branch&(dec_cmd_d1.take_branch?do_branch==0:do_branch!=0);
assign exec_update_pc = good_inst&(en_exec_update_pc_j|en_exec_update_pc_b);

assign jump_rd_eq0 = (en_exec_update_pc_j&dec_cmd_d1.rd==0);
assign exec_fifo_wr = good_inst&~jump_rd_eq0;
assign rf_fifo_rd = exec_fifo_wr&~rf_fifo_empty;

wire exec_update_pc_wb = en_exec_update_pc_j&dec_cmd_d1.rd!=0;
wire [WIDTH_NBITS-1:0] exec_update_pc_wb_data = dec_fifo_inst_32b?dec_fifo_pc+2:dec_fifo_pc+1;

wire [WIDTH_NBITS-1:0] auipc_wb_data = new_pc;
wire auipc_wb = dec_cmd_d1.auipc;

wire [WIDTH_NBITS-1:0] lui_wb_data = dec_cmd_d1.imm;
wire lui_wb = dec_cmd_d1.lui;

wire [WIDTH_NBITS-1:0] op_wb_data = alu_out;
wire op_wb = dec_cmd_d1.op|dec_cmd_d1.opi;

assign exec_cmd.funct3 = dec_cmd_d1.funct3;
assign exec_cmd.load = dec_cmd_d1.load;
assign exec_cmd.atomic = dec_cmd_d1.atomic;
assign exec_cmd.aq = dec_cmd_d1.aq;
assign exec_cmd.rl = dec_cmd_d1.rl;
assign exec_cmd.funct5 = dec_cmd_d1.funct5;
assign exec_cmd.wb_en = (exec_update_pc_wb|auipc_wb|lui_wb|op_wb|dec_cmd_d1.load|dec_cmd_d1.atomic)&(dec_cmd_d1.rd!=0);
assign exec_cmd.wb_data = op_wb?op_wb_data:auipc_wb?auipc_wb_data:exec_update_pc_wb?exec_update_pc_wb_data:lui_wb_data;
assign exec_cmd.wb_addr = dec_cmd_d1.rd;
assign exec_cmd.mem_addr = alu_out;
assign exec_cmd.mem_wdata = mrf_data1;
assign exec_cmd.mem_en = dec_cmd_d1.load|dec_cmd_d1.store|dec_cmd_d1.atomic;
assign exec_cmd.mem_wr = dec_cmd_d1.store|dec_cmd_d1.atomic;

always @(posedge clk) exec_cmd_d1 <= exec_fifo_wr?exec_cmd:exec_cmd_d1;

logic [`TID_NBITS-1:0] exec_fifo_tid;
logic [`FID_NBITS-1:0] exec_fifo_fid;
logic exec_fifo_fid_sel;
logic [BUFFER_NUM_NBITS-1:0] exec_fifo_buf_sel;
logic exec_fifo_end_program;
logic exec_fifo_exception;
sfifo1f #(3+BUFFER_NUM_NBITS+`TID_NBITS+`FID_NBITS) u_sfifo1f_4(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(exec_fifo_wr), .din({dec_fifo_exception, dec_fifo_end_program, dec_fifo_fid_sel, dec_fifo_tid, dec_fifo_fid, dec_fifo_buf_sel}), .dout({exec_fifo_exception, exec_fifo_end_program, exec_fifo_fid_sel, exec_fifo_tid, exec_fifo_fid, exec_fifo_buf_sel}), .rd(exec_fifo_rd), .full(exec_fifo_full), .empty(exec_fifo_empty));

/* memory */

wire sel_data = (exec_cmd_d1.mem_addr[`PU_MEM_CYCLE_DEPTH_RANGE]==`PU_MEM_SINGLE_CYCLE)&
		(exec_cmd_d1.mem_addr[`PU_MEM_SINGLE_DEPTH_RANGE]==`PU_MEM_DATA);

logic io_ack_d1; 
logic exec_fifo_wr_d1;
flop_rst #(1+1) u_flop_rst_141(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({io_ack, exec_fifo_wr}), .dout({io_ack_d1, exec_fifo_wr_d1}));
wire io_req_en = exec_cmd_d1.mem_en&exec_cmd_d1.mem_addr[`PU_MEM_CYCLE_DEPTH_RANGE]==`PU_MEM_MULTI_CYCLE;
assign io_req = exec_fifo_wr_d1&io_req_en;

logic mem_fifo_full;
logic mem_fifo_rd;
wire mem_fifo_av = 1'b1;//~mem_fifo_full|mem_fifo_rd;
wire mem_fifo_wr_en = ~stall_pipeline&~exec_fifo_empty&(~io_req_en|io_ack_d1)&mem_fifo_av;

wire sel_4byte_mem = sel_data&(exec_cmd_d1.mem_addr[`PU_MEM_DATA_DEPTH_RANGE]==`PU_MEM_4B);
wire load_meta = sel_4byte_mem&(exec_cmd_d1.mem_addr[`PU_MEM_4B_DEPTH_RANGE]==`PU_MEM_META);
wire load_registers = load_meta&(exec_cmd_d1.mem_addr[`PU_MEM_META_DEPTH_RANGE]==`PU_MEM_META_REGISTERS);
wire ram_wr00 = mem_fifo_wr_en&(sel_4byte_mem&~load_meta&~exec_fifo_end_program&exec_cmd_d1.mem_wr|exec_fifo_exception);
logic [WIDTH_NBITS-1:0] ram_wdata00;
logic [3:0] ram_we;
always @(*) begin
	if(exec_fifo_exception) begin
		ram_wdata00 = 0;
		ram_we = 4'hf;
	end else begin
	ram_wdata00 = exec_cmd_d1.mem_wdata;
	case (exec_cmd_d1.funct3[2:0])
		2'b0: 
			case(exec_cmd_d1.mem_addr[1:0])
				2'b00: begin ram_we = 4'h8; ram_wdata00[31:24] = exec_cmd_d1.mem_wdata[7:0]; end
				2'b01: begin ram_we = 4'h4; ram_wdata00[23:16] = exec_cmd_d1.mem_wdata[7:0]; end
				2'b10: begin ram_we = 4'h2; ram_wdata00[15:8] = exec_cmd_d1.mem_wdata[7:0]; end
				2'b11: begin ram_we = 4'h1; ram_wdata00[7:0] = exec_cmd_d1.mem_wdata[7:0]; end
			endcase
		2'b1: 
			case(exec_cmd_d1.mem_addr[1])
				1'b0: begin ram_we = 4'hc; ram_wdata00[31:16] = exec_cmd_d1.mem_wdata[15:0]; end
				1'b1: begin ram_we = 4'h3; ram_wdata00[15:0] = exec_cmd_d1.mem_wdata[15:0]; end
			endcase
		default: 
			ram_we = 4'hf;
	endcase
	end
end

wire [3:0] ram_we00 = ram_we&{(4){ram_wr00}};

wire [HOP_MEM_DEPTH_LSB_NBITS-1:0] ram_waddr00 = exec_fifo_exception?(`RAS_BASE+0)>>2:exec_cmd_d1.mem_addr[HOP_MEM_DEPTH_LSB_NBITS-1+2:0+2];
wire [HOP_MEM_DEPTH_NBITS-1:0] ram_raddr00 = {(load_registers?0:exec_fifo_buf_sel), ram_waddr00};

logic [WIDTH_NBITS-1:0] ram_rdata00 /* synthesis DONT_TOUCH */;

logic ram_rd01;
logic [HOP_MEM_DEPTH_NBITS-1:0] ram_raddr01;
logic [WIDTH_NBITS-1:0] ram_rdata01 /* synthesis DONT_TOUCH */;

pio_rw_dmem_bram #(WIDTH_NBITS, HOP_MEM_DEPTH_NBITS) u_pio_rw_dmem_bram(.clk(clk), .wea(ram_we00), .addra(~ram_wr00?ram_raddr00:{exec_fifo_buf_sel, ram_waddr00}), .dina(ram_wdata00), .douta(ram_rdata00), .web({(4){ram_wr01}}), .addrb(~ram_wr01?ram_raddr01:ram_waddr01), .dinb(ram_wdata01), .doutb(ram_rdata01), .app_mem_rd(ram_rd01), .clk_div(clk_div), .`RESET_SIG(`RESET_SIG), .reg_addr(reg_addr), .reg_din(reg_din), .reg_rd(reg_rd), .reg_wr(reg_wr), .reg_ms(reg_ms), .mem_ack(mem_ack), .mem_rdata(mem_rdata));

wire sel_16byte_mem = sel_data&(exec_cmd_d1.mem_addr[`PU_MEM_DATA_DEPTH_RANGE]==`PU_MEM_16B);
wire [1:0] ram_raddr10_lsb = exec_cmd_d1.mem_addr[3:2];
wire disable_wr = exec_fifo_exception|exec_fifo_end_program;
wire ram_wr10_0 = mem_fifo_wr_en&sel_16byte_mem&~disable_wr&exec_cmd_d1.mem_wr&(ram_raddr10_lsb==2'b11);
logic [WIDTH_NBITS-1:0] ram_rdata10_0 /* synthesis DONT_TOUCH */;
wire ram_wr10_1 = mem_fifo_wr_en&sel_16byte_mem&~disable_wr&exec_cmd_d1.mem_wr&(ram_raddr10_lsb==2'b10);
logic [WIDTH_NBITS-1:0] ram_rdata10_1 /* synthesis DONT_TOUCH */;
wire ram_wr10_2 = mem_fifo_wr_en&sel_16byte_mem&~disable_wr&exec_cmd_d1.mem_wr&(ram_raddr10_lsb==2'b01);
logic [WIDTH_NBITS-1:0] ram_rdata10_2 /* synthesis DONT_TOUCH */;
wire ram_wr10_3 = mem_fifo_wr_en&sel_16byte_mem&~disable_wr&exec_cmd_d1.mem_wr&(ram_raddr10_lsb==2'b00);
logic [WIDTH_NBITS-1:0] ram_rdata10_3 /* synthesis DONT_TOUCH */;
wire [PD_MEM_DEPTH_LSB_NBITS-1:0] ram_waddr10 = exec_cmd_d1.mem_addr[PD_MEM_DEPTH_LSB_NBITS-1+4:0+4];
wire [PD_MEM_DEPTH_LSB_NBITS-1:0] ram_raddr10 = ram_waddr10;
wire [3:0] ram_we10_0 = {(4){ram_wr10_0}}&ram_we;
wire [3:0] ram_we10_1 = {(4){ram_wr10_1}}&ram_we;
wire [3:0] ram_we10_2 = {(4){ram_wr10_2}}&ram_we;
wire [3:0] ram_we10_3 = {(4){ram_wr10_3}}&ram_we;
wire [WIDTH_NBITS-1:0] ram_wdata10 = ram_wdata00;

wire ram_wr11 = en_pd_wr|en_scratch_wr;
wire [PD_MEM_DEPTH_LSB_NBITS-1:0] pd_wr_addr_lsb = en_pd_wr?{`PU_MEM_PD, pd_wr_cnt}:{`PU_MEM_SCRATCH, scratch_wr_cnt};
wire [PD_MEM_DEPTH_NBITS-1:0] ram_waddr11 = {wr_pd_buf_sel, pd_wr_addr_lsb};
wire [`DATA_PATH_NBITS-1:0] ram_wdata11 = en_pd_wr0?ff_piarb_pu_inst_data:0;
logic [PD_MEM_DEPTH_NBITS-1:0] ram_raddr11;
logic [`DATA_PATH_NBITS-1:0] ram_rdata11 /* synthesis DONT_TOUCH */;

ram_dual_we_bram #(WIDTH_NBITS/4, PD_MEM_DEPTH_NBITS) u_ram_dual_we_bram_4(.clka(clk), .wea(ram_we10_0), .addra(~|ram_we10_0?{exec_fifo_buf_sel, ram_raddr10}:{exec_fifo_buf_sel, ram_waddr10}), .dina(ram_wdata10), .douta(ram_rdata10_0), .clkb(clk), .web({(4){ram_wr11}}), .addrb(~ram_wr11?ram_raddr11:ram_waddr11), .dinb(ram_wdata11[WIDTH_NBITS*1-1:WIDTH_NBITS*0]), .doutb(ram_rdata11[WIDTH_NBITS*1-1:WIDTH_NBITS*0]));
ram_dual_we_bram #(WIDTH_NBITS/4, PD_MEM_DEPTH_NBITS) u_ram_dual_we_bram_5(.clka(clk), .wea(ram_we10_1), .addra(~|ram_we10_1?{exec_fifo_buf_sel, ram_raddr10}:{exec_fifo_buf_sel, ram_waddr10}), .dina(ram_wdata10), .douta(ram_rdata10_1), .clkb(clk), .web({(4){ram_wr11}}), .addrb(~ram_wr11?ram_raddr11:ram_waddr11), .dinb(ram_wdata11[WIDTH_NBITS*2-1:WIDTH_NBITS*1]), .doutb(ram_rdata11[WIDTH_NBITS*2-1:WIDTH_NBITS*1]));
ram_dual_we_bram #(WIDTH_NBITS/4, PD_MEM_DEPTH_NBITS) u_ram_dual_we_bram_6(.clka(clk), .wea(ram_we10_2), .addra(~|ram_we10_2?{exec_fifo_buf_sel, ram_raddr10}:{exec_fifo_buf_sel, ram_waddr10}), .dina(ram_wdata10), .douta(ram_rdata10_2), .clkb(clk), .web({(4){ram_wr11}}), .addrb(~ram_wr11?ram_raddr11:ram_waddr11), .dinb(ram_wdata11[WIDTH_NBITS*3-1:WIDTH_NBITS*2]), .doutb(ram_rdata11[WIDTH_NBITS*3-1:WIDTH_NBITS*2]));
ram_dual_we_bram #(WIDTH_NBITS/4, PD_MEM_DEPTH_NBITS) u_ram_dual_we_bram_7(.clka(clk), .wea(ram_we10_3), .addra(~|ram_we10_3?{exec_fifo_buf_sel, ram_raddr10}:{exec_fifo_buf_sel, ram_waddr10}), .dina(ram_wdata10), .douta(ram_rdata10_3), .clkb(clk), .web({(4){ram_wr11}}), .addrb(~ram_wr11?ram_raddr11:ram_waddr11), .dinb(ram_wdata11[WIDTH_NBITS*4-1:WIDTH_NBITS*3]), .doutb(ram_rdata11[WIDTH_NBITS*4-1:WIDTH_NBITS*3]));

wire mem_fifo_wr = /*~exec_fifo_end_program&*/mem_fifo_wr_en;
assign exec_fifo_rd = mem_fifo_wr;

logic [1:0] ram_raddr10_lsb_d1;
flop_en #(2) u_flop_en_141(.clk(clk), .en(mem_fifo_wr_en), .din({ram_raddr10_lsb}), .dout({ram_raddr10_lsb_d1}));
logic [WIDTH_NBITS-1:0] ram_rdata10;
always @(*) case(ram_raddr10_lsb_d1) 2'b00: ram_rdata10 = ram_rdata10_0; 2'b01: ram_rdata10 = ram_rdata10_1; 2'b10: ram_rdata10 = ram_rdata10_2; 2'b11: ram_rdata10 = ram_rdata10_3; endcase

wire buf_sel_fifo_wr = exec_fifo_rd&disable_wr;
logic ras_fifo_full;

assign io_cmd.wr = exec_cmd_d1.mem_wr;
assign io_cmd.addr = exec_cmd_d1.mem_addr;
assign io_cmd.wdata = exec_cmd_d1.mem_wdata;
assign io_cmd.atomic = exec_cmd_d1.atomic;
assign io_cmd.funct5 = exec_cmd_d1.funct5;
assign io_cmd.aq = exec_cmd_d1.aq;
assign io_cmd.rl = exec_cmd_d1.rl;
assign io_cmd.tid = exec_fifo_tid;
assign io_cmd.fid = exec_fifo_fid;
wire io_req_rd = io_req_en&(exec_cmd_d1.atomic|~exec_cmd_d1.mem_wr);

always @(posedge clk) exec_cmd_d2 <= mem_fifo_wr?exec_cmd_d1:exec_cmd_d2;

logic [WIDTH_NBITS-1:0] io_rdata;
assign mem_wb_en = exec_cmd_d1.wb_en&mem_fifo_wr_en;
assign mem_wb_addr_p1 = exec_cmd.wb_addr;
assign mem_wb_data = io_req_rd?io_rdata:exec_cmd_d1.wb_data;

logic mem_fifo_io_req_rd;
logic mem_fifo_end_program;
logic mem_fifo_exception;
sfifo1f #(5) u_sfifo1f_5(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(mem_fifo_wr), .din({io_req_rd, exec_fifo_exception, exec_fifo_end_program, sel_4byte_mem, sel_16byte_mem}), .dout({mem_fifo_io_req_rd, mem_fifo_exception, mem_fifo_end_program, mem_fifo_load00, mem_fifo_load10}), .rd(mem_fifo_rd), .full(mem_fifo_full), .empty(mem_fifo_empty));

logic io_rdata_fifo_rd;
logic io_rdata_fifo_empty;
sfifo1f #(WIDTH_NBITS) u_sfifo1f_6(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(io_ack&io_req_rd), .din(io_ack_data), .dout(io_rdata), .rd(io_rdata_fifo_rd), .full(), .empty(io_rdata_fifo_empty));

/* write back */

wire [WIDTH_NBITS-1:0] ram_rdata = mem_fifo_load00?ram_rdata00:ram_rdata10;

// "IO" memories: no LB, LBU, LH, LHU support
logic [WIDTH_NBITS-1:0] ram_rdata1;
always @(*)
	case (exec_cmd_d2.funct3[1:0])
		2'b00: 
			case(exec_cmd_d2.mem_addr[1:0])
				2'b11: ram_rdata1 = {{(24){~exec_cmd_d2.funct3[2]&ram_rdata[7]}}, ram_rdata[7:0]};
				2'b10: ram_rdata1 = {{(24){~exec_cmd_d2.funct3[2]&ram_rdata[15]}}, ram_rdata[15:8]};
				2'b01: ram_rdata1 = {{(24){~exec_cmd_d2.funct3[2]&ram_rdata[23]}}, ram_rdata[23:16]};
				2'b00: ram_rdata1 = {{(24){~exec_cmd_d2.funct3[2]&ram_rdata[31]}}, ram_rdata[31:24]};
			endcase
		2'b01: 
			case(exec_cmd_d2.mem_addr[1])
				1'b1: ram_rdata1 = {{(16){~exec_cmd_d2.funct3[2]&ram_rdata[15]}}, ram_rdata[15:0]};
				1'b0: ram_rdata1 = {{(16){~exec_cmd_d2.funct3[2]&ram_rdata[31]}}, ram_rdata[31:16]};
			endcase
		default: ram_rdata1 = ram_rdata;
	endcase

assign mem_fifo_rd = ~stall_pipeline&~mem_fifo_empty;

assign io_rdata_fifo_rd = mem_fifo_rd&mem_fifo_io_req_rd;

wire n_stall_pipeline = 1'b0;//io_req?1'b1:io_ack?1'b0:stall_pipeline;
flop_rst #(1) u_flop_rst_15(.clk(clk), .`RESET_SIG(`RESET_SIG), .din(n_stall_pipeline), .dout(stall_pipeline));

assign wb_en0 = mem_fifo_rd&exec_cmd_d2.wb_en;
assign wb_addr0_p1 = exec_cmd_d1.wb_addr;
assign wb_data00 = mem_fifo_io_req_rd?io_rdata:exec_cmd_d2.wb_data;
assign wb_data0 = exec_cmd_d2.load&~mem_fifo_io_req_rd?ram_rdata1:mem_fifo_io_req_rd?io_rdata:exec_cmd_d2.wb_data;

assign wb_en = wb_en0;
assign wb_addr = exec_cmd_d2.wb_addr;
assign wb_data = wb_data0;

assign mem_update_pc = mem_fifo_rd&(mem_fifo_end_program|mem_fifo_exception);

/****************************************************************************/

wire rd_pd_len_fifo_wr = set_pd_wr_zero_st;
logic rd_pd_len_fifo_rd;
wire [`PD_CHUNK_NBITS-1-4:0] rd_pd_len_fifo_din = pd_wr_cnt;
logic [`PD_CHUNK_NBITS-1-4:0] rd_pd_len_fifo_dout;

sfifo2f_fo #(`PD_CHUNK_NBITS-4, 2) u_sfifo2f_fo_8(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(rd_pd_len_fifo_wr), .din(rd_pd_len_fifo_din), .dout(rd_pd_len_fifo_dout), .rd(rd_pd_len_fifo_rd), .ncount(), .count(), .full(), .empty(), .fullm1(), .emptyp2());

logic pd_fifo_wr;
logic pd_fifo_eop_in;

logic pd_fifo_rd;
logic pd_fifo_empty;
logic pd_fifo_sop_in;
logic pd_fifo_sop;
logic pd_fifo_eop;
logic [`DATA_PATH_NBITS-1:0] pd_fifo_din;
logic [`DATA_PATH_NBITS-1:0] pd_fifo_dout;

assign pu_em_data_valid_out_p1 = pu_em_data_valid_in|pd_fifo_rd;
assign pu_em_sop_out_p1 = pu_em_data_valid_in?pu_em_sop_in:pd_fifo_sop;
assign pu_em_eop_out_p1 = pu_em_data_valid_in?pu_em_eop_in:pd_fifo_eop;
assign pu_em_port_id_out_p1 = pu_em_data_valid_in?pu_em_port_id_in:PU_ID;
assign pu_em_packet_data_out_p1 = pu_em_data_valid_in?pu_em_packet_data_in:pd_fifo_dout;

logic pu_done_fifo_empty;
logic pu_gnt_fifo_empty;
wire pu_done_fifo_rd = ~pu_fid_done_in&~pu_done_fifo_empty&~pu_gnt_fifo_empty;
wire pu_gnt_fifo_rd = pu_done_fifo_rd;
sfifo2f1 #(1) u_sfifo2f1_9(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(pu_gnt_d1), .din(1'b1), .dout(), .rd(pu_gnt_fifo_rd), .full(), .empty(pu_gnt_fifo_empty), .count(), .fullm1(), .emptyp2());

wire set_pd_fifo_rd_en = ~pd_fifo_empty&~pu_gnt_fifo_empty;
logic pd_fifo_rd_en;
wire pd_fifo_rd_mode = set_pd_fifo_rd_en|pd_fifo_rd_en;
assign pd_fifo_rd = ~pu_em_data_valid_in&~pd_fifo_empty&pd_fifo_rd_mode;
wire reset_pd_fifo_rd_en = pd_fifo_rd&pd_fifo_eop;

logic pd_fifo_full, pd_fifo_fullm1;
wire pd_fifo_av = ~(pd_fifo_full|pd_fifo_wr&pd_fifo_fullm1);

sfifo2f_fo #(2+`DATA_PATH_NBITS, 3) u_sfifo2f_fo_10(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(pd_fifo_wr), .din({pd_fifo_sop_in, pd_fifo_eop_in, pd_fifo_din}), .dout({pd_fifo_sop, pd_fifo_eop, pd_fifo_dout}), .rd(pd_fifo_rd), .full(pd_fifo_full), .empty(pd_fifo_empty), .count(), .ncount(), .fullm1(pd_fifo_fullm1), .emptyp2());

logic [3:0] ras_rd_cnt_d1;

logic pu_gnt_fifo_rd1;
logic pu_gnt_fifo_empty1;

sfifo2f1 #(1) u_sfifo2f1_91(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(pu_gnt_d1), .din(1'b1), .dout(), .rd(pu_gnt_fifo_rd1), .full(), .empty(pu_gnt_fifo_empty1), .count(), .fullm1(), .emptyp2());
logic ras_fifo_empty;
wire set_ras_fifo_rd_en = pu_asa_start_in&~pu_asa_valid_in&~ras_fifo_empty&~pu_gnt_fifo_empty1;
logic ras_fifo_rd_en;
wire ras_fifo_rd_mode = set_ras_fifo_rd_en|ras_fifo_rd_en;

logic ras_fifo_eop;
wire ras_fifo_rd = ras_fifo_rd_mode&~ras_fifo_empty;

wire reset_ras_fifo_rd_en = ras_fifo_rd&ras_fifo_eop;
assign pu_gnt_fifo_rd1 = reset_ras_fifo_rd_en;
;
logic [WIDTH_NBITS-1:0] ras_fifo_din;
logic [WIDTH_NBITS-1:0] ras_fifo_dout;

assign pu_asa_valid_out_p1 = pu_asa_valid_in|ras_fifo_rd;
assign pu_asa_eop_out_p1 = pu_asa_valid_in?pu_asa_eop_in:ras_fifo_eop;
assign pu_asa_data_out_p1 = pu_asa_valid_in?pu_asa_data_in:ras_fifo_dout;
assign pu_asa_pu_id_out_p1 = pu_asa_valid_in?pu_asa_pu_id_in:PU_ID;

sfifof_fo #(WIDTH_NBITS+1, 5, 20) u_sfifof_fo_12(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(ras_fifo_wr), .din({ras_fifo_eop_in, ras_fifo_din}), .dout({ras_fifo_eop, ras_fifo_dout}), .rd(ras_fifo_rd), .full(ras_fifo_full), .empty(ras_fifo_empty), .count(), .fullm1(), .emptyp2());

logic pu_done_fifo_din;
logic pu_done_fifo_dout;

assign pu_fid_done_out_p1 = pu_fid_done_in|pu_done_fifo_rd;
assign pu_fid_sel_out_p1 = pu_fid_done_in?pu_fid_sel_in:pu_done_fifo_dout;
assign pu_id_out_p1 = pu_fid_done_in?pu_id_in:PU_ID;

sfifo2f1 #(1) u_sfifo2f1_13(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(pu_done_fifo_wr), .din(pu_done_fifo_din), .dout(pu_done_fifo_dout), .rd(pu_done_fifo_rd), .full(), .empty(pu_done_fifo_empty), .count(), .fullm1(), .emptyp2());

localparam RAS_RAM_DEPTH_NBITS = `PU_ASA_TS_NBITS;
localparam RAS_RAM_DEPTH = `PU_ASA_TS;

typedef enum {
IDLE,
CHECK_PD,
RD_RAS,
RD_RAS_PD,
RD_PD,
PU_DONE
} state_t;

state_t pu_rd_st;

logic rd_st_fifo_empty;
wire set_ras_rd = ~rd_st_fifo_empty&pu_rd_st==IDLE;

logic [3:0] ras_rd_cnt;
wire last_ras_rd_cnt = ras_rd_cnt==14;
logic last_ras_rd_cnt_d1;

logic [3-1:0] pd_rd_cnt;
logic [3-1:0] pd_rd_cnt_d1;
wire first_pd_rd_cnt = pd_rd_cnt==0;
wire last_pd_rd_cnt = pd_rd_cnt==rd_pd_len_fifo_dout;
logic last_pd_rd_cnt_d1;

logic ras_rd_st;
wire mras_rd_st = ras_rd_st&~ram_wr01;
logic ras_rd_st_d1;
wire reset_ras_rd = mras_rd_st&last_ras_rd_cnt;

wire set_pd_rd = (pu_rd_st==RD_PD)&(pd_rd_cnt==0);
logic pd_rd_st;
wire mpd_rd_st = pd_rd_st&&pd_fifo_av&~ram_wr11;
logic pd_rd_st_d1;
wire reset_pd_rd = mpd_rd_st&last_pd_rd_cnt;
logic [BUFFER_NUM_NBITS-1:0] rd_buf_sel;
logic rd_fid_sel;

assign pu_done_fifo_wr = ((pu_rd_st==RD_RAS)&reset_ras_rd)|((pu_rd_st==RD_PD)&reset_pd_rd)|((pu_rd_st==RD_RAS_PD)&reset_ras_rd&reset_pd_rd);
assign pu_done_fifo_din = rd_fid_sel;

wire buf_sel_fifo_rd = pu_done_fifo_wr;
sfifo2f_fo #(BUFFER_NUM_NBITS+1, 2) u_sfifo2f_fo_14(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(buf_sel_fifo_wr), .din({exec_fifo_buf_sel, exec_fifo_fid_sel}), .dout({rd_buf_sel, rd_fid_sel}), .rd(buf_sel_fifo_rd), .full(), .empty(buf_sel_fifo_empty), .ncount(), .count(), .fullm1(), .emptyp2());

sfifo2f_fo #(1, 2) u_sfifo2f_fo_141(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(buf_sel_fifo_wr), .din(1'b1), .dout(), .rd(set_ras_rd), .full(), .empty(rd_st_fifo_empty), .ncount(), .count(), .fullm1(), .emptyp2());

assign ram_rd01 = mras_rd_st;
assign ram_raddr01 = {rd_buf_sel, `PU_MEM_RAS, {2'b0}, ras_rd_cnt};
assign ram_raddr11 = {rd_buf_sel, `PU_MEM_PD, pd_rd_cnt};

logic reset_pd_rd_d1;
assign rd_pd_len_fifo_rd = reset_pd_rd_d1;

localparam PD_UPDATE_LOC = 8;

always @(posedge clk) begin
        piarb_pu_pid <= piarb_pu_pid_in;
        piarb_pu_sop <= piarb_pu_sop_in;
        piarb_pu_eop <= piarb_pu_eop_in;
        piarb_pu_fid_sel <= piarb_pu_fid_sel_in;
        piarb_pu_data <= piarb_pu_data_in;

        piarb_pu_meta_data <= piarb_pu_valid_in&piarb_pu_sop_in?piarb_pu_meta_data_in:piarb_pu_meta_data;

        piarb_pu_inst_pid <= piarb_pu_inst_pid_in;
        piarb_pu_inst_sop <= piarb_pu_inst_sop_in;
        piarb_pu_inst_eop <= piarb_pu_inst_eop_in;
        piarb_pu_inst_data <= piarb_pu_inst_data_in;
        piarb_pu_inst_pd <= piarb_pu_inst_pd_in;
        piarb_pu_inst_pd_d1 <= piarb_pu_inst_valid?piarb_pu_inst_pd:piarb_pu_inst_pd_d1;

	if(ras_rd_st_d1)
		case(ras_rd_cnt_d1)
			0: ras_fifo_din <= ram_rdata01[2:0];
			1: ras_fifo_din <= {ras_fifo_din[2:0], ram_rdata01[2:0]};
			2: ras_fifo_din <= {ras_fifo_din[5:0], ram_rdata01[0]};
			3: ras_fifo_din <= {ras_fifo_din[6:0], ram_rdata01[0]};
			4: ras_fifo_din <= {ram_rdata01[5:0], ras_fifo_din[7:0]};
			5, 7, 9, 11, 13: ras_fifo_din <= ram_rdata01[WIDTH_NBITS-1:0];
			default: ras_fifo_din <= {ras_fifo_din[WIDTH_NBITS/2-1:0], ram_rdata01[WIDTH_NBITS/2-1:0]};
		endcase
	else
		ras_fifo_din <= ras_fifo_din;

        last_ras_rd_cnt_d1 <= last_ras_rd_cnt;
	ras_fifo_eop_in <= last_ras_rd_cnt_d1;
	pd_fifo_din <= pd_rd_st_d1?ram_rdata11:pd_fifo_din;
	pd_fifo_sop_in <= pd_rd_cnt_d1==0;
        last_pd_rd_cnt_d1 <= last_pd_rd_cnt;
	pd_fifo_eop_in <= last_pd_rd_cnt_d1;
end
   
always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin

                init_wr <= 1'b0;
                init_addr <= 0;

                piarb_pu_valid <= 1'b0;
                piarb_pu_inst_valid <= 1'b0;

		pu_rd_st <= IDLE;
		ras_rd_st <= 0;
		ras_rd_st_d1 <= 0;
                ras_fifo_wr <= 1'b0;
                ras_fifo_rd_en <= 1'b0;
                pd_fifo_rd_en <= 1'b0;
		pd_rd_st <= 0;
		pd_rd_st_d1 <= 0;
                pd_fifo_wr <= 1'b0;

		ras_rd_cnt <= 0;
		ras_rd_cnt_d1 <= 0;
		pd_rd_cnt <= 0;
		pd_rd_cnt_d1 <= 0;

		pu_gnt_d1 <= 1'b0;

		reset_pd_rd_d1 <= 1'b0;

	end else begin

                init_wr <= ~init_addr[INST_DEPTH_NBITS+1];
                init_addr <= init_addr[INST_DEPTH_NBITS+1]?(1<<(1+INST_DEPTH_NBITS)):init_addr+1;

                piarb_pu_valid <= piarb_pu_valid_in;
                piarb_pu_inst_valid <= piarb_pu_inst_valid_in;

                case (pu_rd_st)
                  IDLE: if(~rd_st_fifo_empty) pu_rd_st <= CHECK_PD;
                        else pu_rd_st <= IDLE;
                  CHECK_PD: if(reset_pd_rd) pu_rd_st <= RD_RAS;
	  		else if(ram_rdata01[PD_UPDATE_LOC]) pu_rd_st <= RD_RAS_PD;
                        else pu_rd_st <= RD_RAS;
                  RD_RAS_PD: if(reset_ras_rd&reset_pd_rd) pu_rd_st <= PU_DONE;
                             else if(reset_ras_rd) pu_rd_st <= RD_PD;
                             else if(reset_pd_rd) pu_rd_st <= RD_RAS;
                             else pu_rd_st <= RD_RAS_PD;
                  RD_PD: if(reset_pd_rd) pu_rd_st <= PU_DONE;
                         else pu_rd_st <= RD_PD;
                  RD_RAS: if(reset_ras_rd) pu_rd_st <= PU_DONE;
                         else pu_rd_st <= RD_RAS;
                  PU_DONE: /*if(pu_done_fifo_rd)*/ pu_rd_st <= IDLE;
                         /* else pu_rd_st <= PU_DONE;*/
                  default: pu_rd_st <= IDLE;
  		endcase

		ras_rd_st <= set_ras_rd?1'b1:reset_ras_rd?1'b0:ras_rd_st;
		ras_rd_st_d1 <= mras_rd_st;
                ras_fifo_wr <= ras_rd_st_d1&(~ras_rd_cnt_d1[0])&(ras_rd_cnt_d1>3);
                ras_fifo_rd_en <= set_ras_fifo_rd_en?1'b1:reset_ras_fifo_rd_en?1'b0:ras_fifo_rd_en;
                pd_fifo_rd_en <= set_pd_fifo_rd_en?1'b1:reset_pd_fifo_rd_en?1'b0:pd_fifo_rd_en;
		pd_rd_st <= set_ras_rd?1'b1:reset_pd_rd?1'b0:pd_rd_st;
		pd_rd_st_d1 <= mpd_rd_st;
                pd_fifo_wr <= pd_rd_st_d1;

		ras_rd_cnt <= set_ras_rd?0:~mras_rd_st?ras_rd_cnt:last_ras_rd_cnt?0:ras_rd_cnt+1;
		ras_rd_cnt_d1 <= ras_rd_cnt;
		pd_rd_cnt <= set_ras_rd?0:~mpd_rd_st?pd_rd_cnt:last_pd_rd_cnt?0:pd_rd_cnt+1;
		pd_rd_cnt_d1 <= pd_rd_cnt;

		pu_gnt_d1 <= pu_gnt;

		reset_pd_rd_d1 <= reset_pd_rd;

	end

function [31:0] expansion;
input[15:0] din;

begin
	expansion[1:0] = 2'b11;
	expansion[6:2] = 5'h00;
	expansion[11:7] = din[11:7]; // rd
	expansion[14:12] = din[15:13]; // funct3
	expansion[19:15] = din[11:7]; // rs1
	expansion[24:20] = din[6:2]; // rs2
	expansion[31:25] = 7'h00;
	case({din[1:0], din[15:13]})
		5'b00000, 5'b00001, 5'b00011, 5'b00100, 5'b00101, 5'b00111, 5'b10001, 5'b10011, 5'b10101, 5'b10111, 5'b11000, 5'b11001, 5'b11010, 5'b11011, 5'b11100, 5'b11101, 5'b11110, 5'b11111: begin 
			expansion[6:2] = 5'b00001;
		end
		5'b00010: begin //LW
			expansion[6:2] = 5'b00000;
			expansion[31:20] = {din[5], din[12:10], din[6], 2'b00};
			expansion[11:7] = din[4:2]; // rd
			expansion[19:15] = din[9:7]; // rs1
		end
		5'b00110: begin //SW
			expansion[6:2] = 5'b01000;
			{expansion[31:25], expansion[11:7]} = {din[5], din[12:10], din[6], 2'b00};
			expansion[19:15] = din[9:7]; // rs1
			expansion[24:20] = din[4:2]; // rs2
		end
		5'b01000: begin //ADDI
			expansion[6:2] = 5'b00100;
			expansion[31:20] = {{(7){din[12]}}, din[6:2]};
			//expansion[31:20] = {{(7){din[12]}}, din[4:3], din[5], din[2], din[6]}; // ADDI16SP
			expansion[14:12] = 3'b000; // funct3
		end
		5'b01001: begin //JAL
			expansion[6:2] = 5'b11011;
			{expansion[31], expansion[19:12], expansion[20], expansion[30:21]} = {{(10){din[12]}}, din[8], din[10:9], din[6], din[7], din[2], din[11], din[5:3]};
			expansion[11:7] = 5'b00001; // rd
		end
		5'b01010: begin //LI
			expansion[6:2] = 5'b00100;
			expansion[31:20] = {{(7){din[12]}}, din[6:2]};
			expansion[19:15] = 5'b00000; // rs1
			expansion[14:12] = 3'b000; // funct3
		end
		5'b01011: begin //LUI
			expansion[6:2] = 5'b01101;
			expansion[31:12] = {{(15){din[12]}}, din[6:2]};
		end
		5'b01100: begin 
			expansion[11:7] = din[9:7]; // rd
			expansion[19:15] = din[9:7]; // rs1
			case (din[11:10])
				2'b00: begin //SRLI
					expansion[6:2] = 5'b00100;
					expansion[31:30] = 2'b00;
					expansion[29:20] = {din[6:2]};
					expansion[14:12] = 3'b101; // funct3
				end
				2'b01: begin //SRAI
					expansion[6:2] = 5'b00100;
					expansion[31:30] = 2'b01;
					expansion[29:20] = {din[6:2]};
					expansion[14:12] = 3'b101; // funct3
				end
				2'b10: begin //ANDI
					expansion[6:2] = 5'b00100;
					expansion[31:20] = {{(7){din[12]}}, din[6:2]};
					expansion[14:12] = 3'b111; // funct3
				end
				2'b11: begin 
					expansion[6:2] = 5'b01100;
					expansion[19:15] = din[9:7]; // rs1
					expansion[24:20] = din[4:2]; // rs2
					expansion[31:25] = 0;
					case (din[6:5])
						2'b00: begin //SUB
							expansion[31:30] = 2'b01;
							expansion[14:12] = 3'b000; // funct3
						end
						2'b01: begin //XOR
							expansion[14:12] = 3'b100; // funct3
						end
						2'b10: begin //OR
							expansion[14:12] = 3'b110; // funct3
						end
						2'b11: begin //AND
							expansion[14:12] = 3'b111; // funct3
						end
					endcase
				end
			endcase
		end
		5'b01101: begin //J
			expansion[6:2] = 5'b11011;
			{expansion[31], expansion[19:12], expansion[20], expansion[30:21]} = {{(10){din[12]}}, din[8], din[10:9], din[6], din[7], din[2], din[11], din[5:3]};
			expansion[11:7] = 5'b00000; // rd
		end
		5'b01110: begin //BEQZ
			expansion[6:2] = 5'b11000;
			{expansion[31], expansion[7], expansion[30:25], expansion[11:8]} = {{(5){din[12]}}, din[6:5], din[2], din[11:10], din[4:3]};
			expansion[19:15] = din[9:7]; // rs1
			expansion[24:20] = 5'b00000; // rs2
			expansion[14:12] = 3'b000; // funct3
		end
		5'b01111: begin //BNEZ
			expansion[6:2] = 5'b11000;
			{expansion[31], expansion[7], expansion[30:25], expansion[11:8]} = {{(5){din[12]}}, din[6:5], din[2], din[11:10], din[4:3]};
			expansion[19:15] = din[9:7]; // rs1
			expansion[24:20] = 5'b00000; // rs2
			expansion[14:12] = 3'b001; // funct3
		end
		/*
		5'b01000: begin //ADDI16SP, ADDII4SPN
		end
		*/
		5'b10000: begin //SLLI
			expansion[6:2] = 5'b00100;
			expansion[24:20] = {din[6:2]};
			expansion[14:12] = 3'b001; // funct3
		end
		5'b10010: begin //LWSP
			expansion[6:2] = 5'b00000;
			expansion[31:20] = {din[3:2], din[12], din[6:4], 2'b00};
		end
		5'b10100: begin 
			case (din[12])
				1'b0: begin
					if(din[6:2]!=0) begin //MV
						expansion[6:2] = 5'b01100;
						expansion[31:30] = 2'b00;
						expansion[14:12] = 3'b000; // funct3
					end else begin //JR
						expansion[6:2] = 5'b11001;
						expansion[11:7] = 5'b00000; // rd
						expansion[31:20] = 12'b0; // pc+2
					end
				end
				1'b1: begin
					if(din[6:2]!=0) begin //ADD
						expansion[6:2] = 5'b01100;
						expansion[31:30] = 2'b00;
						expansion[14:12] = 3'b000; // funct3
					end else begin 
						if(din[11:7]!=0) begin //JALR
							expansion[6:2] = 5'b11001;
							expansion[11:7] = 5'b00001; // rd
							expansion[31:20] = 12'b0; // pc+2
						end else begin //EBREAK
							expansion[6:2] = 5'b11100;
						end
					end
				end
			endcase
		end
		5'b10110: begin //SWSP
			expansion[6:2] = 5'b01000;
			{expansion[31:25], expansion[11:7]} = {din[8:7], din[12:9], 2'b00};
		end
	endcase
end
endfunction

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

