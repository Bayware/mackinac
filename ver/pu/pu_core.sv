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
parameter PD_DEPTH_NBITS = `PD_CHUNK_NBITS-4,
parameter HOP_DEPTH_NBITS = `PATH_CHUNK_NBITS-4,
parameter HOP_MEM_DEPTH_NBITS = 9,
parameter RF_DEPTH_NBITS = 5,
parameter PU_MEM_DEPTH_NBITS = `PU_MEM_DEPTH_NBITS,
parameter IO_DATA_NBITS = WIDTH_NBITS,
parameter IO_ADDR_NBITS = `PU_MEM_DEPTH_NBITS-2
) (

input clk, 
input `RESET_SIG,

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

integer i;

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

wire en_hop_wr0 = piarb_pu_valid&piarb_pu_pid==PU_ID;
logic piarb_pu_valid_eop_d1, piarb_pu_valid_eop_d2;

logic [3:0] hop_wr_cnt0;
logic [3:0] hop_wr_cnt1;
wire last_hop_wr_cnt_meta = hop_wr_cnt0==3;
wire last_hop_wr_cnt_ras = hop_wr_cnt1==6;
wire last_hop_wr_cnt = hop_wr_cnt1==10;
wire first_en_hop_wr0 = en_hop_wr0&piarb_pu_sop;
wire last_en_hop_wr0 = en_hop_wr0&piarb_pu_eop;
logic [`HOP_INFO_PC_RANGE] pc_to_load;
logic [`HOP_INFO_BYTE_POINTER_RANGE] ptr_to_load;
flop_en #(`HOP_INFO_BYTE_POINTER_NBITS+`HOP_INFO_PC_NBITS) u_flop_en_0023(.clk(clk), .en(first_en_hop_wr0), .din({piarb_pu_data[`HOP_INFO_BYTE_POINTER], piarb_pu_data[`HOP_INFO_PC]}), .dout({ptr_to_load, pc_to_load}));
logic en_hop_wr1_en;
logic en_hop_wr1;
wire last_en_hop_wr1 = en_hop_wr1&last_hop_wr_cnt;
wire en_hop_wr1_en_p1 = first_en_hop_wr0?1'b1:last_en_hop_wr1?1'b0:en_hop_wr1_en;
flop_rst #(1, 0) u_flop_rst_0(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({en_hop_wr1_en_p1}), .dout({en_hop_wr1_en}));
assign en_hop_wr1 = en_hop_wr1_en&~en_hop_wr0;
wire [3:0] hop_wr_cnt0_p1 = ~en_hop_wr0?hop_wr_cnt0:last_en_hop_wr0?0:hop_wr_cnt0+1;
flop_rst #(4, 0) u_flop_rst_1(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({hop_wr_cnt0_p1}), .dout({hop_wr_cnt0}));
wire [3:0] hop_wr_cnt1_p1 = ~en_hop_wr1?hop_wr_cnt1:last_en_hop_wr1?0:hop_wr_cnt1+1;
flop_rst #(4, 0) u_flop_rst_1010(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({hop_wr_cnt1_p1}), .dout({hop_wr_cnt1}));
logic en_hop_wr_ras;
wire en_hop_wr_ras_p1 = first_en_hop_wr0?1'b1:last_hop_wr_cnt_ras?1'b0:en_hop_wr_ras;
flop_rst #(1, 0) u_flop_rst_011(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({en_hop_wr_ras_p1}), .dout({en_hop_wr_ras}));

pu_hop_meta_type piarb_pu_meta_data_d1;
always @(posedge clk) piarb_pu_meta_data_d1 <= first_en_hop_wr0?piarb_pu_meta_data:piarb_pu_meta_data_d1;

logic [1:0] last_st;
logic [1:0] n_last_st;
always @*
	case(last_st)
		0: n_last_st = last_en_hop_wr0&last_en_hop_wr1?3:last_en_hop_wr0?1:last_en_hop_wr1?2:0;
		1: n_last_st = last_en_hop_wr1?3:1;
		2: n_last_st = last_en_hop_wr0?3:2;
		3: n_last_st = 0;
	endcase
flop_rst #(2, 0) u_flop_rst_012(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({n_last_st}), .dout({last_st}));
logic wr_hop_buf_sel;
wire toggle_wr0 = last_st==3;
flop_rst_en #(1) u_flop_rst_en_3(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(toggle_wr0), .din({~wr_hop_buf_sel}), .dout({wr_hop_buf_sel}));

wire [2:0] hop_wr_addr = en_hop_wr0?hop_wr_cnt0:en_hop_wr_ras?hop_wr_cnt1:hop_wr_cnt1-7;

wire ram_wr01 = en_hop_wr0|en_hop_wr1_en;
logic [WIDTH_NBITS-1:0] ram_wdata01;
always @*
	if(en_hop_wr0) ram_wdata01 = piarb_pu_data;
	else if(~en_hop_wr_ras)
		case(hop_wr_addr[2:0])
			0: ram_wdata01 = piarb_pu_meta_data_d1.creation_time;
			1: ram_wdata01 = {piarb_pu_meta_data_d1.switch_tag, piarb_pu_meta_data_d1.pkt_type, piarb_pu_meta_data_d1.rci_type[11:0]};
			2: ram_wdata01 = {piarb_pu_meta_data_d1.f_payload};
			default: ram_wdata01 = {piarb_pu_meta_data_d1.fid, {(16-`TID_NBITS){1'b0}}, piarb_pu_meta_data_d1.tid};
		endcase
	else
		case(hop_wr_addr[2:0])
			0: ram_wdata01 = {8'b111, 8'b011, 8'b1, 8'b1};
			1: ram_wdata01 = {ptr_to_load, 16'b11};
			default: ram_wdata01 = {(`DEFAULT_RCI+1), `DEFAULT_RCI};
		endcase

wire [HOP_MEM_DEPTH_NBITS-1:0] ram_waddr01 = {wr_hop_buf_sel, 1'b0, {(HOP_MEM_DEPTH_NBITS-7){1'b0}}, en_hop_wr1, (en_hop_wr0?1'b0:en_hop_wr_ras?`PU_RAS_MEM_RAS:`PU_RAS_MEM_META), hop_wr_addr};

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

wire en_pd_wr = en_inst_pd_wr&~piarb_pu_inst_pd;
wire last_en_pd_wr = en_pd_wr&piarb_pu_inst_eop;

logic wr_pd_buf_sel;
flop_rst_en #(1) u_flop_rst_en_61(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(last_en_pd_wr), .din({~wr_pd_buf_sel}), .dout({wr_pd_buf_sel}));

logic [PD_DEPTH_NBITS-1:0] pd_wr_addr_lsb;
wire [PD_DEPTH_NBITS-1:0] pd_wr_addr_lsb_p1 = ~en_pd_wr?pd_wr_addr_lsb:piarb_pu_inst_eop?0:pd_wr_addr_lsb+1;
flop_rst_en #(PD_DEPTH_NBITS) u_flop_rst_en_62(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(en_pd_wr), .din({pd_wr_addr_lsb_p1}), .dout({pd_wr_addr_lsb}));

logic end_program;
logic dec_update_pc;
logic exec_update_pc;

logic db_fifo_pc_msb;
logic [`HOP_INFO_PC_RANGE] db_fifo_pc;
logic [`TID_NBITS-1:0] db_fifo_tid;
logic [`FID_NBITS-1:0] db_fifo_fid;
logic db_fifo_fid_sel;
logic db_fifo_buf_sel;
logic db_fifo_empty;
logic db_fifo_full;
wire db_fifo_wr = toggle_wr0;

wire db_fifo_rd = dec_update_pc;

sfifo2f1 #(`HOP_INFO_PC_NBITS+1+`TID_NBITS+`FID_NBITS) u_sfifo2f1_0(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(db_fifo_wr), .din({pc_to_load, piarb_pu_meta_data.tid, piarb_pu_meta_data.fid, piarb_pu_fid_sel}), .dout({db_fifo_pc, db_fifo_tid, db_fifo_fid, db_fifo_fid_sel}), .rd(db_fifo_rd), .full(db_fifo_full), .empty(db_fifo_empty), .count(), .fullm1(), .emptyp2());

flop_rst_en #(2) u_flop_rst_en_7(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(db_fifo_rd), .din({~db_fifo_buf_sel, ~db_fifo_pc_msb}), .dout({db_fifo_buf_sel, db_fifo_pc_msb}));

/* issue */

wire en_update_pc = ~db_fifo_empty;

logic inst_fifo_full;
logic inst_fifo_rd;

wire inst_fifo_av = ~inst_fifo_full|inst_fifo_rd;

logic stall_pipeline;
wire update_pc = ~stall_pipeline&en_update_pc&inst_fifo_av;

logic [PC_NBITS-1:0] exec_pc;

logic db_fifo_rd_d1;
wire n_db_fifo_rd_d1 = db_fifo_rd&~db_fifo_full?1'b1:~db_fifo_empty?1'b0:db_fifo_rd_d1;
flop_rst #(1, 1) u_flop_rst_611(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({n_db_fifo_rd_d1}), .dout({db_fifo_rd_d1}));
wire hold_pc = db_fifo_rd&~db_fifo_full|db_fifo_rd_d1;

wire end_load_pc = (db_fifo_rd&db_fifo_full)|(db_fifo_rd_d1&~db_fifo_empty);

logic [PC_NBITS-1:0] pc;
wire [PC_NBITS-1:0] next_pc = end_load_pc?db_fifo_pc:exec_update_pc?exec_pc:hold_pc?pc:pc+2;
wire load_pc = end_load_pc|exec_update_pc;
logic load_pc_d1;

logic dec_flag;
logic exec_flag;

flop_rst_en #(1, 1) u_flop_rst_en_8(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(end_load_pc), .din({~dec_flag}), .dout({dec_flag}));
flop_rst_en #(1) u_flop_rst_en_9(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(exec_update_pc), .din({~exec_flag}), .dout({exec_flag}));

flop_rst_en #(PC_NBITS) u_pc(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(update_pc), .din(next_pc), .dout(pc));

logic [WIDTH_NBITS-1:0] ram_inst0, ram_inst1, ram_inst2, ram_inst3, ram_inst /* synthesis DONT_TOUCH */;
ram_1r1w_bram #(WIDTH_NBITS, INST_DEPTH_NBITS+1) u_ram_1r1w_bram_0(.clk(clk), .wr(en_inst_wr), .raddr({db_fifo_pc_msb, pc[PC_NBITS-1:3]}), .waddr(inst_wr_addr), .din(init_wr?0:piarb_pu_inst_data[WIDTH_NBITS-1:0]), .dout(ram_inst0));
ram_1r1w_bram #(WIDTH_NBITS, INST_DEPTH_NBITS+1) u_ram_1r1w_bram_1(.clk(clk), .wr(en_inst_wr), .raddr({db_fifo_pc_msb, pc[PC_NBITS-1:3]}), .waddr(inst_wr_addr), .din(init_wr?0:piarb_pu_inst_data[WIDTH_NBITS*2-1:WIDTH_NBITS*1]), .dout(ram_inst1));
ram_1r1w_bram #(WIDTH_NBITS, INST_DEPTH_NBITS+1) u_ram_1r1w_bram_2(.clk(clk), .wr(en_inst_wr), .raddr({db_fifo_pc_msb, pc[PC_NBITS-1:3]}), .waddr(inst_wr_addr), .din(init_wr?0:piarb_pu_inst_data[WIDTH_NBITS*3-1:WIDTH_NBITS*2]), .dout(ram_inst2));
ram_1r1w_bram #(WIDTH_NBITS, INST_DEPTH_NBITS+1) u_ram_1r1w_bram_3(.clk(clk), .wr(en_inst_wr), .raddr({db_fifo_pc_msb, pc[PC_NBITS-1:3]}), .waddr(inst_wr_addr), .din(init_wr?0:piarb_pu_inst_data[WIDTH_NBITS*4-1:WIDTH_NBITS*3]), .dout(ram_inst3));

logic [2:0] pc_d1;
logic update_pc_d1;
logic en_update_pc_d1;
flop_rst_en #(3) u_flop_rst_en_10(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(update_pc), .din({pc[2:0]}), .dout({pc_d1}));
flop_rst #(3) u_flop_rst_10(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({en_update_pc, load_pc, update_pc}), .dout({en_update_pc_d1, load_pc_d1, update_pc_d1}));
always @(*) case(pc_d1[2:1]) 2'b00: ram_inst = ram_inst3; 2'b01: ram_inst = ram_inst2; 2'b10: ram_inst = ram_inst1; 2'b11: ram_inst = ram_inst0; endcase
logic upper_av;
logic [15:0] inst_sv;
flop_rst_en #(16+1) u_flop_rst_en_11(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(update_pc_d1), .din({ram_inst[31:16], pc_d1[0]}), .dout({inst_sv, upper_av}));

wire upper_av1 = upper_av&~load_pc_d1;
wire [WIDTH_NBITS-1:0] instruction = upper_av1?{ram_inst[15:0], inst_sv}:ram_inst;

wire inst_fifo_wr = (~pc[0]|upper_av1)&~stall_pipeline&en_update_pc_d1&~db_fifo_rd&inst_fifo_av;

logic [`TID_NBITS-1:0] inst_fifo_tid;
logic [`FID_NBITS-1:0] inst_fifo_fid;
logic inst_fifo_dec_flag;
logic inst_fifo_exec_flag;
logic [PC_NBITS-1:0] inst_fifo_pc;
logic inst_fifo_fid_sel;
logic inst_fifo_buf_sel;
logic inst_fifo_empty;
sfifo1f #(2+`TID_NBITS+`FID_NBITS+2+PC_NBITS) u_sfifo1f_1(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(inst_fifo_wr), .din({dec_flag, exec_flag, db_fifo_tid, db_fifo_fid, db_fifo_fid_sel, db_fifo_buf_sel, pc}), .dout({inst_fifo_dec_flag, inst_fifo_exec_flag, inst_fifo_tid, inst_fifo_fid, inst_fifo_fid_sel, inst_fifo_buf_sel, inst_fifo_pc}), .rd(inst_fifo_rd), .full(inst_fifo_full), .empty(inst_fifo_empty));

/* fetch */

logic [15:0] inst_up_half;

logic up_half_av;

wire inst_32b = up_half_av?&inst_up_half[1:0]:&instruction[1:0];

logic fetch_fifo_rd;
logic fetch_fifo_full;
wire fetch_fifo_av = ~fetch_fifo_full|fetch_fifo_rd;
wire inst_16b_av = ~inst_32b&up_half_av;
wire fetch_fifo_wr = ~stall_pipeline&fetch_fifo_av&(inst_16b_av|~inst_fifo_empty);
assign inst_fifo_rd = ~stall_pipeline&fetch_fifo_av&~inst_fifo_empty&~inst_16b_av;

wire up_half = up_half_av?inst_32b:~inst_32b;

flop_rst_en #(16+1) u_flop_rst_en_12(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(fetch_fifo_wr), .din({instruction[31:16], up_half}), .dout({inst_up_half, up_half_av}));

logic [`TID_NBITS-1:0] fetch_fifo_tid;
logic [`FID_NBITS-1:0] fetch_fifo_fid;
logic [PC_NBITS-1:0] fetch_fifo_pc;
logic fetch_fifo_inst_32b;
logic fetch_fifo_fid_sel;
logic fetch_fifo_buf_sel;
logic fetch_fifo_dec_flag;
logic fetch_fifo_exec_flag;
wire [WIDTH_NBITS-1:0] fetch_fifo_din1 = up_half_av?{instruction[15:0], inst_up_half}:instruction;
wire [WIDTH_NBITS-1:0] fetch_fifo_din = inst_32b?fetch_fifo_din1:expansion(fetch_fifo_din1[15:0]);
logic fetch_fifo_empty;
logic [WIDTH_NBITS-1:0] fetch_fifo_dout;
sfifo1f #(1+WIDTH_NBITS+2+`TID_NBITS+`FID_NBITS+2+PC_NBITS) u_sfifo1f_2(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(fetch_fifo_wr), .din({inst_32b, fetch_fifo_din, inst_fifo_dec_flag, inst_fifo_exec_flag, inst_fifo_tid, inst_fifo_fid, inst_fifo_fid_sel, inst_fifo_buf_sel, inst_fifo_pc}), .dout({fetch_fifo_inst_32b, fetch_fifo_dout, fetch_fifo_dec_flag, fetch_fifo_exec_flag, fetch_fifo_tid, fetch_fifo_fid, fetch_fifo_fid_sel, fetch_fifo_buf_sel, fetch_fifo_pc}), .rd(fetch_fifo_rd), .full(fetch_fifo_full), .empty(fetch_fifo_empty));

/* decode */

dec_type dec_cmd;
pu_decode u_pu_decode(.inst(fetch_fifo_dout), .dec_cmd(dec_cmd));

logic wb_en;
logic [WIDTH_NBITS-1:0] wb_data;
logic [RF_DEPTH_NBITS-1:0] wb_addr;

logic [WIDTH_NBITS-1:0] rf_data0, rf_data1;

pu_rf #(WIDTH_NBITS, RF_DEPTH_NBITS) u_pu_rf(.clk(clk), .wr(wb_en), .raddr0(dec_cmd.rs1), .raddr1(dec_cmd.rs2), .waddr(wb_addr), .din(wb_data), .dout0(rf_data0), .dout1(rf_data1));

wire inst_16b = ~fetch_fifo_inst_32b;

logic en_load_delay;
logic load_use_delay_en_d1, load_use_delay_en_d2;
wire load_use_delay_en = en_load_delay&dec_cmd_d1.load&((dec_cmd.use_rs1&(dec_cmd_d1.rd==dec_cmd.rs1))|(dec_cmd.use_rs2&(dec_cmd_d1.rd==dec_cmd.rs2)))&~load_use_delay_en_d1;
flop_rst #(2) u_flop_rst_113(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({load_use_delay_en, load_use_delay_en_d1}), .dout({load_use_delay_en_d1, load_use_delay_en_d2}));
wire dec_fifo_wr_en = ~((load_use_delay_en&~load_use_delay_en_d2)|load_use_delay_en_d1)&~stall_pipeline&~fetch_fifo_empty;
assign fetch_fifo_rd = dec_fifo_wr_en;

logic dec_dec_flag;
flop_rst_en #(1) u_flop_rst_en_13(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(dec_update_pc), .din({~dec_dec_flag}), .dout({dec_dec_flag}));

wire dec_valid = dec_dec_flag==fetch_fifo_dec_flag;

assign end_program = dec_cmd.end_program;
assign dec_update_pc = dec_fifo_wr_en&end_program&dec_valid;

wire dec_fifo_wr = dec_fifo_wr_en&dec_valid&~(dec_update_pc&~end_program);

flop_rst_en #(1) u_flop_rst_en_131(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(dec_fifo_wr), .din(1'b1), .dout({en_load_delay}));

dec_type dec_cmd_d1;
always @(posedge clk) dec_cmd_d1 <= dec_fifo_wr?dec_cmd:dec_cmd_d1;

logic [`TID_NBITS-1:0] dec_fifo_tid;
logic [`FID_NBITS-1:0] dec_fifo_fid;
logic [PC_NBITS-1:0] dec_fifo_pc;
logic dec_fifo_inst_32b;
logic dec_fifo_fid_sel;
logic dec_fifo_buf_sel;
logic dec_fifo_end_program;
logic dec_fifo_exec_flag;
logic dec_fifo_empty;
logic dec_fifo_rd;
sfifo1f #(2+`TID_NBITS+`FID_NBITS+3+PC_NBITS) u_sfifo1f_3(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(dec_fifo_wr), .din({fetch_fifo_inst_32b, fetch_fifo_exec_flag, fetch_fifo_tid, fetch_fifo_fid, (dec_update_pc&end_program), fetch_fifo_fid_sel, fetch_fifo_buf_sel, inst_fifo_pc}), .dout({dec_fifo_inst_32b, dec_fifo_exec_flag, dec_fifo_tid, dec_fifo_fid, dec_fifo_end_program, dec_fifo_fid_sel, dec_fifo_buf_sel, dec_fifo_pc}), .rd(dec_fifo_rd), .full(), .empty(dec_fifo_empty));

/* execution */

logic mem_wb_en;
logic [RF_DEPTH_NBITS-1:0] mem_wb_addr_p1;
logic [WIDTH_NBITS-1:0] mem_wb_data;

logic io_wb_en;
logic [RF_DEPTH_NBITS-1:0] io_wb_addr_p1;
logic [WIDTH_NBITS-1:0] io_wb_data;

logic wb_en0;
logic [RF_DEPTH_NBITS-1:0] wb_addr0_p1;
logic [WIDTH_NBITS-1:0] wb_data0;

wire rs1_eq0_p1 = dec_cmd.rs1==0;
logic rs1_eq0;

wire mem_wb_addr_cmp1_p1 = (dec_cmd.rs1==mem_wb_addr_p1);
logic mem_wb_addr_cmp1;

wire io_wb_addr_cmp1_p1 = (dec_cmd.rs1==io_wb_addr_p1);
logic io_wb_addr_cmp1;

wire wb_addr0_cmp1_p1 = (dec_cmd.rs1==wb_addr0_p1);
logic wb_addr0_cmp1;

wire rs2_eq0_p1 = dec_cmd.rs2==0;
logic rs2_eq0;

wire mem_wb_addr_cmp2_p1 = (dec_cmd.rs2==mem_wb_addr_p1);
logic mem_wb_addr_cmp2;

wire io_wb_addr_cmp2_p1 = (dec_cmd.rs2==io_wb_addr_p1);
logic io_wb_addr_cmp2;

wire wb_addr0_cmp2_p1 = (dec_cmd.rs2==wb_addr0_p1);
logic wb_addr0_cmp2;

flop_rst #(8) u_flop_rst_79(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({rs1_eq0_p1, rs2_eq0_p1, mem_wb_addr_cmp1_p1, io_wb_addr_cmp1_p1, wb_addr0_cmp1_p1, mem_wb_addr_cmp2_p1, io_wb_addr_cmp2_p1, wb_addr0_cmp2_p1}), .dout({rs1_eq0, rs2_eq0, mem_wb_addr_cmp1, io_wb_addr_cmp1, wb_addr0_cmp1, mem_wb_addr_cmp2, io_wb_addr_cmp2, wb_addr0_cmp2}));

wire [WIDTH_NBITS-1:0] mrf_data0 = mem_wb_en&mem_wb_addr_cmp1?mem_wb_data:
				io_wb_en&io_wb_addr_cmp1?io_wb_data:
				wb_en0&wb_addr0_cmp1?wb_data0:rs1_eq0?0:rf_data0;

wire [WIDTH_NBITS-1:0] mrf_data1 = mem_wb_en&mem_wb_addr_cmp2?mem_wb_data:
				io_wb_en&io_wb_addr_cmp2?io_wb_data:
				wb_en0&wb_addr0_cmp2?wb_data0:rs2_eq0?0:rf_data1;

logic [WIDTH_NBITS-1:0] alu_out;
pu_alu u_pu_alu(.use_imm(dec_cmd_d1.use_imm), .imm(dec_cmd_d1.imm), .rs1(mrf_data0), .rs2(mrf_data1), .funct3(dec_cmd_d1.funct3), .funct5(dec_cmd_d1.funct5), .alu(alu_out));

wire exec_fifo_wr_en = ~stall_pipeline&~dec_fifo_empty;
assign dec_fifo_rd = exec_fifo_wr_en;

wire [INST_DEPTH_NBITS-1:0] pc_offset = dec_cmd_d1.imm;
assign exec_pc = (dec_cmd_d1.jalr?mrf_data0:dec_fifo_pc)+pc_offset;
assign exec_update_pc = exec_fifo_wr_en&(dec_cmd_d1.jal|dec_cmd_d1.jalr|(dec_cmd_d1.branch&(dec_cmd_d1.take_branch?alu_out==0:alu_out!=0)));

wire [WIDTH_NBITS-1:0] exec_update_pc_wb_data = dec_fifo_inst_32b?dec_fifo_pc+4:dec_fifo_pc+2;
wire exec_update_pc_wb = (dec_cmd_d1.jal|dec_cmd_d1.jalr)&dec_cmd_d1.rd!=0;

wire [WIDTH_NBITS-1:0] auipc_wb_data = exec_pc;
wire auipc_wb = dec_cmd_d1.auipc;

wire [WIDTH_NBITS-1:0] lui_wb_data = dec_cmd_d1.imm;
wire lui_wb = dec_cmd_d1.lui;

wire [WIDTH_NBITS-1:0] op_wb_data = alu_out;
wire op_wb = dec_cmd_d1.op|dec_cmd_d1.opi;

exec_type exec_cmd;
assign exec_cmd.funct3 = dec_cmd_d1.funct3;
assign exec_cmd.load = dec_cmd_d1.load;
assign exec_cmd.atomic = dec_cmd_d1.atomic;
assign exec_cmd.aq = dec_cmd_d1.aq;
assign exec_cmd.rl = dec_cmd_d1.rl;
assign exec_cmd.funct5 = dec_cmd_d1.funct5;
assign exec_cmd.wb_en = (exec_update_pc_wb|auipc_wb|lui_wb|op_wb|dec_cmd_d1.load)&(dec_cmd_d1.rd!=0);
assign exec_cmd.wb_data = op_wb?op_wb_data:auipc_wb?auipc_wb_data:exec_update_pc_wb?exec_update_pc_wb_data:lui_wb_data;
assign exec_cmd.wb_addr = dec_cmd_d1.rd;
assign exec_cmd.mem_addr = dec_cmd_d1.atomic?mrf_data0:alu_out;
assign exec_cmd.mem_wdata = mrf_data1;
assign exec_cmd.mem_en = dec_cmd_d1.load|dec_cmd_d1.store|dec_cmd_d1.atomic;
assign exec_cmd.mem_wr = dec_cmd_d1.store|dec_cmd_d1.atomic;

logic exec_exec_flag;
flop_rst_en #(1) u_flop_rst_en_14(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(exec_update_pc), .din({~exec_exec_flag}), .dout({exec_exec_flag}));

wire exec_fifo_wr = exec_fifo_wr_en&(exec_exec_flag==dec_fifo_exec_flag)&~(exec_update_pc&~exec_update_pc_wb);

exec_type exec_cmd_d1;
always @(posedge clk) exec_cmd_d1 <= exec_fifo_wr?exec_cmd:exec_cmd_d1;

logic [`TID_NBITS-1:0] exec_fifo_tid;
logic [`FID_NBITS-1:0] exec_fifo_fid;
logic exec_fifo_fid_sel;
logic exec_fifo_buf_sel;
logic exec_fifo_end_program;
logic exec_fifo_rd;
logic exec_fifo_empty;
sfifo1f #(3+`TID_NBITS+`FID_NBITS) u_sfifo1f_4(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(exec_fifo_wr), .din({dec_fifo_end_program, dec_fifo_fid_sel, dec_fifo_tid, dec_fifo_fid, dec_fifo_buf_sel}), .dout({exec_fifo_end_program, exec_fifo_fid_sel, exec_fifo_tid, exec_fifo_fid, exec_fifo_buf_sel}), .rd(exec_fifo_rd), .full(), .empty(exec_fifo_empty));

/* memory */

wire mem_fifo_wr_en = ~stall_pipeline&~exec_fifo_empty;

assign mem_wb_en = exec_cmd_d1.wb_en&mem_fifo_wr_en;
assign mem_wb_addr_p1 = exec_cmd.wb_addr;
assign mem_wb_data = exec_cmd_d1.wb_data;

wire load_mem00 = (exec_cmd_d1.mem_addr[`PU_MEM_DEPTH_MSB_RANGE]==`PU_RAS_MEM);
wire ram_wr00 = ~exec_fifo_end_program&exec_cmd_d1.mem_wr&(exec_cmd_d1.mem_addr[`PU_MEM_DEPTH_MSB_RANGE]==`PU_RAS_MEM);
logic [3:0] ram_we;
always @(*)
	case (exec_cmd_d1.funct3[2:0])
		2'b0: for (i=0; i<4; i=i+1) ram_we[i] = i==exec_cmd_d1.mem_addr[1:0];
		2'b1: for (i=0; i<4; i=i+1) ram_we[i] = (i>>1)==exec_cmd_d1.mem_addr[1];
		default: ram_we = 4'hf;
	endcase
wire [3:0] ram_we00 = ram_we;

wire [HOP_MEM_DEPTH_NBITS-1-1:0] ram_waddr00 = exec_cmd_d1.mem_addr[`PU_MEM_DEPTH_LSB_RANGE];
wire [WIDTH_NBITS-1:0] ram_wdata00 = exec_cmd_d1.mem_wdata;
wire [HOP_MEM_DEPTH_NBITS-1-1:0] ram_raddr00 = ram_waddr00;
logic [WIDTH_NBITS-1:0] ram_rdata00 /* synthesis DONT_TOUCH */;

logic [HOP_MEM_DEPTH_NBITS-1:0] ram_raddr01;
logic [WIDTH_NBITS-1:0] ram_rdata01 /* synthesis DONT_TOUCH */;

ram_dual_we_bram #(WIDTH_NBITS/4, HOP_MEM_DEPTH_NBITS) u_ram_dual_we_bram(.clka(clk), .wea({(4){ram_wr00}}), .addra(~ram_wr00?{exec_fifo_buf_sel, ram_raddr00}:{exec_fifo_buf_sel, ram_waddr00}), .dina(ram_wdata00), .douta(ram_rdata00), .clkb(clk), .web({(4){ram_wr01}}), .addrb(~ram_wr01?ram_raddr01:ram_waddr01), .dinb(ram_wdata01), .doutb(ram_rdata01));

wire load_mem10 = (exec_cmd_d1.mem_addr[`PU_MEM_DEPTH_MSB_RANGE]==`PU_PD_MEM);
wire ram_wr10_0 = ~exec_fifo_end_program&exec_cmd_d1.mem_wr&(exec_cmd_d1.mem_addr[`PU_MEM_DEPTH_MSB_RANGE]==`PU_PD_MEM)&(exec_cmd_d1.mem_addr[1:0]==2'b00);
logic [WIDTH_NBITS-1:0] ram_rdata10_0 /* synthesis DONT_TOUCH */;
wire ram_wr10_1 = ~exec_fifo_end_program&exec_cmd_d1.mem_wr&(exec_cmd_d1.mem_addr[`PU_MEM_DEPTH_MSB_RANGE]==`PU_PD_MEM)&(exec_cmd_d1.mem_addr[1:0]==2'b01);
logic [WIDTH_NBITS-1:0] ram_rdata10_1 /* synthesis DONT_TOUCH */;
wire ram_wr10_2 = ~exec_fifo_end_program&exec_cmd_d1.mem_wr&(exec_cmd_d1.mem_addr[`PU_MEM_DEPTH_MSB_RANGE]==`PU_PD_MEM)&(exec_cmd_d1.mem_addr[1:0]==2'b10);
logic [WIDTH_NBITS-1:0] ram_rdata10_2 /* synthesis DONT_TOUCH */;
wire ram_wr10_3 = ~exec_fifo_end_program&exec_cmd_d1.mem_wr&(exec_cmd_d1.mem_addr[`PU_MEM_DEPTH_MSB_RANGE]==`PU_PD_MEM)&(exec_cmd_d1.mem_addr[1:0]==2'b11);
logic [WIDTH_NBITS-1:0] ram_rdata10_3 /* synthesis DONT_TOUCH */;
wire [PD_DEPTH_NBITS-1:0] ram_waddr10 = exec_cmd_d1.mem_addr[`PU_MEM_DEPTH_LSB_RANGE];
wire [WIDTH_NBITS-1:0] ram_wdata10 = exec_cmd_d1.mem_wdata;
wire [PD_DEPTH_NBITS-1:0] ram_raddr10 = ram_waddr10;
wire [1:0] ram_raddr10_lsb = exec_cmd_d1.mem_addr[3:2];
wire [3:0] ram_we10_0 = {(4){ram_wr10_0}}&ram_we;
wire [3:0] ram_we10_1 = {(4){ram_wr10_1}}&ram_we;
wire [3:0] ram_we10_2 = {(4){ram_wr10_2}}&ram_we;
wire [3:0] ram_we10_3 = {(4){ram_wr10_3}}&ram_we;

wire ram_wr11 = en_pd_wr;
wire [PD_DEPTH_NBITS:0] ram_waddr11 = {wr_pd_buf_sel, pd_wr_addr_lsb};
wire [`DATA_PATH_NBITS-1:0] ram_wdata11 = piarb_pu_inst_data;
logic [PD_DEPTH_NBITS:0] ram_raddr11;
logic [`DATA_PATH_NBITS-1:0] ram_rdata11 /* synthesis DONT_TOUCH */;

ram_dual_we_bram #(WIDTH_NBITS/4, PD_DEPTH_NBITS+1) u_ram_dual_we_bram_4(.clka(clk), .wea(ram_we10_0), .addra(~|ram_we10_0?{exec_fifo_buf_sel, ram_raddr10}:{exec_fifo_buf_sel, ram_waddr10}), .dina(ram_wdata10), .douta(ram_rdata10_0), .clkb(clk), .web({(4){ram_wr11}}), .addrb(~ram_wr11?ram_raddr11:ram_waddr11), .dinb(ram_wdata11[WIDTH_NBITS*1-1:WIDTH_NBITS*0]), .doutb(ram_rdata11[WIDTH_NBITS*1-1:WIDTH_NBITS*0]));
ram_dual_we_bram #(WIDTH_NBITS/4, PD_DEPTH_NBITS+1) u_ram_dual_we_bram_5(.clka(clk), .wea(ram_we10_1), .addra(~|ram_we10_1?{exec_fifo_buf_sel, ram_raddr10}:{exec_fifo_buf_sel, ram_waddr10}), .dina(ram_wdata10), .douta(ram_rdata10_1), .clkb(clk), .web({(4){ram_wr11}}), .addrb(~ram_wr11?ram_raddr11:ram_waddr11), .dinb(ram_wdata11[WIDTH_NBITS*2-1:WIDTH_NBITS*1]), .doutb(ram_rdata11[WIDTH_NBITS*2-1:WIDTH_NBITS*1]));
ram_dual_we_bram #(WIDTH_NBITS/4, PD_DEPTH_NBITS+1) u_ram_dual_we_bram_6(.clka(clk), .wea(ram_we10_2), .addra(~|ram_we10_2?{exec_fifo_buf_sel, ram_raddr10}:{exec_fifo_buf_sel, ram_waddr10}), .dina(ram_wdata10), .douta(ram_rdata10_2), .clkb(clk), .web({(4){ram_wr11}}), .addrb(~ram_wr11?ram_raddr11:ram_waddr11), .dinb(ram_wdata11[WIDTH_NBITS*3-1:WIDTH_NBITS*2]), .doutb(ram_rdata11[WIDTH_NBITS*3-1:WIDTH_NBITS*2]));
ram_dual_we_bram #(WIDTH_NBITS/4, PD_DEPTH_NBITS+1) u_ram_dual_we_bram_7(.clka(clk), .wea(ram_we10_3), .addra(~|ram_we10_3?{exec_fifo_buf_sel, ram_raddr10}:{exec_fifo_buf_sel, ram_waddr10}), .dina(ram_wdata10), .douta(ram_rdata10_3), .clkb(clk), .web({(4){ram_wr11}}), .addrb(~ram_wr11?ram_raddr11:ram_waddr11), .dinb(ram_wdata11[WIDTH_NBITS*4-1:WIDTH_NBITS*3]), .doutb(ram_rdata11[WIDTH_NBITS*4-1:WIDTH_NBITS*3]));

wire mem_fifo_wr = ~exec_fifo_end_program&mem_fifo_wr_en;
assign exec_fifo_rd = mem_fifo_wr_en;

logic [1:0] ram_raddr10_lsb_d1;
flop_en #(2) u_flop_en_141(.clk(clk), .en(mem_fifo_wr_en), .din({ram_raddr10_lsb}), .dout({ram_raddr10_lsb_d1}));
logic [WIDTH_NBITS-1:0] ram_rdata10;
always @(*) case(ram_raddr10_lsb_d1) 2'b00: ram_rdata10 = ram_rdata10_0; 2'b01: ram_rdata10 = ram_rdata10_1; 2'b10: ram_rdata10 = ram_rdata10_2; 2'b11: ram_rdata10 = ram_rdata10_3; endcase

wire buf_sel_fifo_wr = exec_fifo_rd&exec_fifo_end_program;
logic ras_fifo_full;
logic pending_ras_rd;
wire set_ras_rd = (buf_sel_fifo_wr|pending_ras_rd)&~ras_fifo_full;
wire set_pending_ras_rd = buf_sel_fifo_wr&ras_fifo_full;

assign io_req = mem_fifo_wr&exec_cmd_d1.mem_en&exec_cmd_d1.mem_addr[`PU_MEM_DEPTH_NBITS-1];
assign io_cmd.wr = exec_cmd_d1.mem_wr;
assign io_cmd.addr = exec_cmd_d1.mem_addr[`PU_MEM_DEPTH_NBITS-1:2];
assign io_cmd.wdata = exec_cmd_d1.mem_wdata;
assign io_cmd.atomic = exec_cmd_d1.atomic;
assign io_cmd.funct5 = exec_cmd_d1.funct5;
assign io_cmd.aq = exec_cmd_d1.aq;
assign io_cmd.rl = exec_cmd_d1.rl;
assign io_cmd.tid = exec_fifo_tid;
assign io_cmd.fid = exec_fifo_fid;

exec_type exec_cmd_d2;
always @(posedge clk) exec_cmd_d2 <= mem_fifo_wr?exec_cmd_d1:exec_cmd_d2;

logic mem_fifo_load00;
logic mem_fifo_load10;
logic mem_fifo_rd;
logic mem_fifo_empty;
sfifo1f #(2) u_sfifo1f_5(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(mem_fifo_wr), .din({load_mem00, load_mem10}), .dout({mem_fifo_load00, mem_fifo_load10}), .rd(mem_fifo_rd), .full(), .empty(mem_fifo_empty));

/* IO */

wire [WIDTH_NBITS-1:0] ram_rdata = mem_fifo_load00?ram_rdata00:ram_rdata10;

// "IO" memories: no LB, LBU, LH, LHU support
logic [WIDTH_NBITS-1:0] ram_rdata1;
always @(*)
	case (exec_cmd_d2.funct3[1:0])
		2'b00: 
			case(exec_cmd_d2.mem_addr[1:0])
				2'b00: ram_rdata1 = {{(24){~exec_cmd_d2.funct3[2]&ram_rdata[7]}}, ram_rdata[7:0]};
				2'b01: ram_rdata1 = {{(24){~exec_cmd_d2.funct3[2]&ram_rdata[15]}}, ram_rdata[15:8]};
				2'b10: ram_rdata1 = {{(24){~exec_cmd_d2.funct3[2]&ram_rdata[23]}}, ram_rdata[23:16]};
				2'b11: ram_rdata1 = {{(24){~exec_cmd_d2.funct3[2]&ram_rdata[31]}}, ram_rdata[31:24]};
			endcase
		2'b01: 
			case(exec_cmd_d2.mem_addr[1])
				1'b0: ram_rdata1 = {{(16){~exec_cmd_d2.funct3[2]&ram_rdata[15]}}, ram_rdata[15:0]};
				1'b1: ram_rdata1 = {{(16){~exec_cmd_d2.funct3[2]&ram_rdata[31]}}, ram_rdata[31:16]};
			endcase
		default: ram_rdata1 = ram_rdata;
	endcase

assign mem_fifo_rd = ~stall_pipeline&~mem_fifo_empty;

wb_type wb_cmd;
assign wb_cmd.wb_en = exec_cmd_d2.wb_en|exec_cmd_d2.load;
assign wb_cmd.wb_addr = exec_cmd_d2.wb_addr;
assign wb_cmd.wb_data = exec_cmd_d2.load?ram_rdata1:exec_cmd_d2.wb_data;

wire io_fifo_wr = mem_fifo_rd&wb_cmd.wb_en;

assign io_wb_en = io_fifo_wr&exec_cmd_d2.wb_en;
assign io_wb_addr_p1 = exec_cmd_d1.wb_addr;
assign io_wb_data = exec_cmd_d2.wb_data;

wire n_stall_pipeline = io_req?1'b1:io_ack?1'b0:stall_pipeline;

flop_rst #(1) u_flop_rst_15(.clk(clk), .`RESET_SIG(`RESET_SIG), .din(n_stall_pipeline), .dout(stall_pipeline));

logic io_rdata_fifo_rd;
logic io_rdata_fifo_empty;
logic [WIDTH_NBITS-1:0] io_rdata;
sfifo1f #(WIDTH_NBITS) u_sfifo1f_6(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(io_ack), .din(io_ack_data), .dout(io_rdata), .rd(io_rdata_fifo_rd), .full(), .empty(io_rdata_fifo_empty));

wb_type wb_cmd_d1;
always @(posedge clk) wb_cmd_d1 <= io_fifo_wr?wb_cmd:wb_cmd_d1;

logic io_fifo_rd;
logic io_fifo_empty;
sfifo1f #(1) u_sfifo1f_7(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(io_fifo_wr), .din(1'b1), .dout(), .rd(io_fifo_rd), .full(), .empty(io_fifo_empty));

/* write back */

assign wb_en0 = ~io_fifo_empty&wb_cmd_d1.wb_en;
assign wb_addr0_p1 = wb_cmd.wb_addr;
assign wb_data0 = io_rdata_fifo_empty?wb_cmd_d1.wb_data:io_rdata;

assign wb_en = init_wr|wb_en0;
assign wb_addr = init_wr?init_addr[RF_DEPTH_NBITS-1:0]:wb_cmd_d1.wb_addr;
assign wb_data = init_wr?0:wb_data0;

assign io_fifo_rd = wb_en0;
assign io_rdata_fifo_rd = io_fifo_rd&~io_rdata_fifo_empty;

/****************************************************************************/

wire rd_pd_len_fifo_wr = last_en_pd_wr;
logic rd_pd_len_fifo_rd;
wire [`PD_CHUNK_NBITS-1-4:0] rd_pd_len_fifo_din = pd_wr_addr_lsb;
logic [`PD_CHUNK_NBITS-1-4:0] rd_pd_len_fifo_dout;

sfifo2f1 #(`PD_CHUNK_NBITS-4) u_sfifo2f1_8(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(rd_pd_len_fifo_wr), .din(rd_pd_len_fifo_din), .dout(rd_pd_len_fifo_dout), .rd(rd_pd_len_fifo_rd), .count(), .full(), .empty(), .fullm1(), .emptyp2());

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

sfifo2f_fo #(2+`DATA_PATH_NBITS, PD_DEPTH_NBITS+1) u_sfifo2f_fo_10(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(pd_fifo_wr), .din({pd_fifo_sop_in, pd_fifo_eop_in, pd_fifo_din}), .dout({pd_fifo_sop, pd_fifo_eop, pd_fifo_dout}), .rd(pd_fifo_rd), .full(), .empty(pd_fifo_empty), .ncount(), .count(), .fullm1(), .emptyp2());

logic [2:0] ras_rd_cnt_d1;

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

sfifo2f_fo #(WIDTH_NBITS+1) u_sfifo2f_fo_12(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(ras_fifo_wr), .din({ras_fifo_eop_in, ras_fifo_din}), .dout({ras_fifo_eop, ras_fifo_dout}), .rd(ras_fifo_rd), .full(ras_fifo_full), .empty(ras_fifo_empty), .ncount(), .count(), .fullm1(), .emptyp2());

logic pu_done_fifo_din;
logic pu_done_fifo_dout;

assign pu_fid_done_out_p1 = pu_fid_done_in|pu_done_fifo_rd;
assign pu_fid_sel_out_p1 = pu_fid_done_in?pu_fid_sel_in:pu_done_fifo_dout;
assign pu_id_out_p1 = pu_fid_done_in?pu_id_in:PU_ID;

sfifo2f1 #(1) u_sfifo2f1_13(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(pu_done_fifo_wr), .din(pu_done_fifo_din), .dout(pu_done_fifo_dout), .rd(pu_done_fifo_rd), .full(), .empty(pu_done_fifo_empty), .count(), .fullm1(), .emptyp2());

localparam RAS_RAM_DEPTH_NBITS = `PU_ASA_TS_NBITS;
localparam RAS_RAM_DEPTH = `PU_ASA_TS;

localparam PD_RAM_DEPTH_NBITS = PD_DEPTH_NBITS;

typedef enum {
IDLE,
CHECK_PD,
RD_RAS,
RD_RAS_PD,
RD_PD,
PU_DONE
} state_t;

state_t pu_rd_st;

logic [RAS_RAM_DEPTH_NBITS-1:0] ras_rd_cnt;
wire last_ras_rd_cnt = ras_rd_cnt==RAS_RAM_DEPTH-1;
logic last_ras_rd_cnt_d1;

logic [PD_RAM_DEPTH_NBITS-1:0] pd_rd_cnt;
logic [PD_RAM_DEPTH_NBITS-1:0] pd_rd_cnt_d1;
wire first_pd_rd_cnt = pd_rd_cnt==0;
wire last_pd_rd_cnt = pd_rd_cnt==rd_pd_len_fifo_dout;
logic last_pd_rd_cnt_d1;

logic ras_rd_st;
logic ras_rd_st_d1;
wire reset_ras_rd = ras_rd_st&last_ras_rd_cnt;

wire set_pd_rd = (pu_rd_st==RD_PD)&(pd_rd_cnt==0);
logic pd_rd_st;
logic pd_rd_st_d1;
wire reset_pd_rd = pd_rd_st&last_pd_rd_cnt_d1;
logic rd_buf_sel;
logic rd_fid_sel;

assign pu_done_fifo_wr = ((pu_rd_st==RD_RAS)&reset_ras_rd)|((pu_rd_st==RD_PD)&reset_pd_rd)|((pu_rd_st==RD_RAS_PD)&reset_ras_rd&reset_pd_rd);
assign pu_done_fifo_din = rd_fid_sel;

wire buf_sel_fifo_rd = pu_done_fifo_wr;
sfifo2f1 #(2) u_sfifo2f1_14(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(buf_sel_fifo_wr), .din({exec_fifo_buf_sel, exec_fifo_fid_sel}), .dout({rd_buf_sel, rd_fid_sel}), .rd(buf_sel_fifo_rd), .full(), .empty(buf_sel_fifo_empty), .count(), .fullm1(), .emptyp2());

assign ram_raddr01 = {rd_buf_sel, {(HOP_MEM_DEPTH_NBITS-RAS_RAM_DEPTH_NBITS-4){1'b0}}, 4'h1, 1'b0, ras_rd_cnt};
assign ram_raddr11 = {rd_buf_sel, pd_rd_cnt};

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

	ras_fifo_din <= ras_rd_st?ram_rdata01:ras_fifo_din;
        last_ras_rd_cnt_d1 <= last_ras_rd_cnt;
	ras_fifo_eop_in <= last_ras_rd_cnt_d1;
	pd_fifo_din <= pd_rd_st_d1?ram_rdata11:pd_fifo_din;
	pd_fifo_sop_in <= pd_rd_cnt==0;
        last_pd_rd_cnt_d1 <= last_pd_rd_cnt;
	pd_fifo_eop_in <= last_pd_rd_cnt;
end
   
always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin

                init_wr <= 1'b0;
                init_addr <= 0;

                piarb_pu_valid <= 1'b0;
                piarb_pu_inst_valid <= 1'b0;

        	piarb_pu_valid_eop_d1 <= 1'b0;
        	piarb_pu_valid_eop_d2 <= 1'b0;

		pending_ras_rd <= 1'b0;

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

        	piarb_pu_valid_eop_d1 <= en_hop_wr1&piarb_pu_eop;
        	piarb_pu_valid_eop_d2 <= piarb_pu_valid_eop_d1;

		pending_ras_rd <= set_pending_ras_rd?1'b1:set_ras_rd?1'b0:pending_ras_rd;

                case (pu_rd_st)
                  IDLE: if(set_ras_rd) pu_rd_st <= CHECK_PD;
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
                  PU_DONE: if(pu_done_fifo_rd) pu_rd_st <= IDLE;
                         else pu_rd_st <= PU_DONE;
                  default: pu_rd_st <= IDLE;
  		endcase

		ras_rd_st <= set_ras_rd?1'b1:reset_ras_rd?1'b0:ras_rd_st;
		ras_rd_st_d1 <= ras_rd_st;
                ras_fifo_wr <= ras_rd_st_d1;
                ras_fifo_rd_en <= set_ras_fifo_rd_en?1'b1:reset_ras_fifo_rd_en?1'b0:ras_fifo_rd_en;
                pd_fifo_rd_en <= set_pd_fifo_rd_en?1'b1:reset_pd_fifo_rd_en?1'b0:pd_fifo_rd_en;
		pd_rd_st <= set_ras_rd?1'b1:reset_pd_rd?1'b0:pd_rd_st;
		pd_rd_st_d1 <= pd_rd_st;
                pd_fifo_wr <= pd_rd_st_d1;

		ras_rd_cnt <= set_ras_rd?0:~ras_rd_st?ras_rd_cnt:last_ras_rd_cnt?0:ras_rd_cnt+1;
		ras_rd_cnt_d1 <= ras_rd_cnt;
		pd_rd_cnt <= set_ras_rd?0:~pd_rd_st?pd_rd_cnt:last_pd_rd_cnt_d1?0:pd_rd_cnt+1;
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
			expansion[31:20] = {{(7){din[12]}}, din[4:3], din[5], din[2], din[6]};
			expansion[14:12] = 3'b000; // funct3
		end
		5'b01001: begin //JAL
			expansion[6:2] = 5'b11011;
			{expansion[31], expansion[19:12], expansion[20], expansion[30:21]} = {{(10){din[11]}}, din[4], din[9:8], din[10], din[6], din[7], din[3:1], din[5]};
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
			expansion[31:12] = {{(5){din[12]}}, din[6:2]};
		end
		5'b01100: begin 
			case (din[11:10])
				2'b00: begin //SRLI
					expansion[6:2] = 5'b00100;
					expansion[31:30] = 2'b00;
					expansion[29:20] = {din[12], din[6:2]};
					expansion[14:12] = 3'b101; // funct3
				end
				2'b01: begin //SRAI
					expansion[6:2] = 5'b00100;
					expansion[31:30] = 2'b01;
					expansion[29:20] = {din[12], din[6:2]};
					expansion[14:12] = 3'b101; // funct3
				end
				2'b10: begin //ANDI
					expansion[6:2] = 5'b00100;
					expansion[31:20] = {{(7){din[12]}}, din[6:2]};
					expansion[14:12] = 3'b111; // funct3
				end
				2'b11: begin 
					expansion[6:2] = 5'b01100;
					expansion[11:7] = din[9:7]; // rd
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
			{expansion[31], expansion[19:12], expansion[20], expansion[30:21]} = {{(10){din[11]}}, din[4], din[9:8], din[10], din[6], din[7], din[3:1], din[5]};
			expansion[11:7] = 5'b00000; // rd
		end
		5'b01110: begin //BEQZ
			expansion[6:2] = 5'b11000;
			{expansion[7], expansion[30:25], expansion[11:8]} = {{(4){din[12]}}, din[6:5], din[2], din[11:10], din[4:3]};
			expansion[19:15] = din[9:7]; // rs1
			expansion[24:20] = 5'b00000; // rs2
			expansion[14:12] = 3'b000; // funct3
		end
		5'b01111: begin //BNEZ
			expansion[6:2] = 5'b11000;
			{expansion[7], expansion[30:25], expansion[11:8]} = {{(4){din[12]}}, din[6:5], din[2], din[11:10], din[4:3]};
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
			expansion[31:20] = {din[12], din[6:2]};
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

