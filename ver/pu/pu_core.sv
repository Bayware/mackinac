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
parameter MEM_DEPTH_NBITS = HOP_DEPTH_NBITS+4,
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

logic en_hop_wr0 = piarb_pu_valid&piarb_pu_pid==PU_ID;
logic piarb_pu_valid_eop_d1, piarb_pu_valid_eop_d2;
logic toggle_wr0 = piarb_pu_valid_eop_d2;

logic [2:0] hop_wr_cnt;
logic en_hop_wr1;
logic last_en_hop_wr0 = en_hop_wr0&piarb_pu_eop;
logic en_hop_wr1_p1 = last_en_hop_wr0?1'b1:hop_wr_cnt==7?1'b0:en_hop_wr1;
flop_rst #(1, 0) u_flop_rst_0(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({en_hop_wr1_p1}), .dout({en_hop_wr1}));
logic [2:0] hop_wr_cnt_p1 = last_en_hop_wr0?0:hop_wr_cnt+1;
flop_rst #(3, 0) u_flop_rst_1(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({hop_wr_cnt_p1}), .dout({hop_wr_cnt}));

pu_hop_meta_type piarb_pu_meta_data_d1;
always @(posedge clk) piarb_pu_meta_data_d1 <= last_en_hop_wr0?piarb_pu_meta_data:piarb_pu_meta_data_d1;

logic wr_hop_buf_sel;
flop_rst_en #(1) u_flop_rst_en_3(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(toggle_wr0), .din({~wr_hop_buf_sel}), .dout({wr_hop_buf_sel}));

logic en_hop_wr = en_hop_wr0|en_hop_wr1;
logic [HOP_DEPTH_NBITS-1:0] hop_wr_addr;
logic [HOP_DEPTH_NBITS-1:0] hop_wr_addr_p1 = ~en_hop_wr?hop_wr_addr:(en_hop_wr0?piarb_pu_eop:|hop_wr_cnt==4)?0:hop_wr_addr+1;
flop_rst #(HOP_DEPTH_NBITS, 3) u_flop_rst_4(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({hop_wr_addr_p1}), .dout({hop_wr_addr}));

logic ram_wr01 = en_hop_wr0|en_hop_wr1;
logic [WIDTH_NBITS-1:0] ram_wdata01 = en_hop_wr0?piarb_pu_data:hop_wr_cnt==0?piarb_pu_meta_data_d1.creation_time:hop_wr_cnt==1?{piarb_pu_meta_data_d1.rci_type, 8'b0, piarb_pu_meta_data_d1.pkt_type}:hop_wr_cnt==2?piarb_pu_meta_data_d1.switch_tag:hop_wr_cnt==3?{piarb_pu_meta_data_d1.f_payload}:{piarb_pu_meta_data_d1.fid, {(16-`TID_NBITS){1'b0}}, piarb_pu_meta_data_d1.tid};

logic [MEM_DEPTH_NBITS:0] ram_waddr01 = {wr_hop_buf_sel, {(MEM_DEPTH_NBITS-HOP_DEPTH_NBITS-4){1'b0}}, (hop_wr_cnt>2?`PU_RAS_MEM_RAS:`PU_RAS_MEM_META), hop_wr_addr};

logic en_inst_wr = piarb_pu_inst_valid&piarb_pu_inst_pd&piarb_pu_inst_pid==PU_ID;
logic toggle_wr1 = en_inst_wr&piarb_pu_inst_eop;

logic wr_inst_buf_sel;
flop_rst_en #(1) u_flop_rst_en_5(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(toggle_wr1), .din({~wr_inst_buf_sel}), .dout({wr_inst_buf_sel}));

logic [INST_DEPTH_NBITS-1:0] inst_wr_addr_lsb;
logic [INST_DEPTH_NBITS-1:0] inst_wr_addr_lsb_p1 = ~en_inst_wr?inst_wr_addr_lsb:piarb_pu_inst_eop?0:inst_wr_addr_lsb+1;
flop_rst_en #(INST_DEPTH_NBITS) u_flop_rst_en_6(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(en_inst_wr), .din({inst_wr_addr_lsb_p1}), .dout({inst_wr_addr_lsb}));
logic [INST_DEPTH_NBITS:0] inst_wr_addr = {wr_inst_buf_sel, inst_wr_addr_lsb};

logic [PD_DEPTH_NBITS-1:0] pd_cnt;
logic en_pd_wr = piarb_pu_inst_valid&~piarb_pu_inst_pd&piarb_pu_inst_pid==PU_ID;

logic [PD_DEPTH_NBITS-1:0] nxt_pd_cnt = pd_cnt+1;
logic [PD_DEPTH_NBITS-1:0] pd_cnt_p1 = ~en_pd_wr?pd_cnt:piarb_pu_inst_eop?0:nxt_pd_cnt;
logic last_en_pd_wr = en_pd_wr&piarb_pu_inst_eop;
flop_rst #(PD_DEPTH_NBITS) u_flop_rst_60(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({pd_cnt_p1}), .dout({pd_cnt}));

logic toggle_wr2 = en_pd_wr&piarb_pu_inst_eop;

logic wr_pd_buf_sel;
flop_rst_en #(1) u_flop_rst_en_61(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(toggle_wr2), .din({~wr_pd_buf_sel}), .dout({wr_pd_buf_sel}));

logic [PD_DEPTH_NBITS-1:0] pd_wr_addr_lsb;
logic [PD_DEPTH_NBITS-1:0] pd_wr_addr_lsb_p1 = ~en_pd_wr?pd_wr_addr_lsb:piarb_pu_inst_eop?0:pd_wr_addr_lsb+1;
flop_rst_en #(PD_DEPTH_NBITS) u_flop_rst_en_62(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(en_pd_wr), .din({pd_wr_addr_lsb_p1}), .dout({pd_wr_addr_lsb}));

logic end_program;
logic dec_update_pc;
logic exec_update_pc;

logic [`TID_NBITS-1:0] db_fifo_tid;
logic [`FID_NBITS-1:0] db_fifo_fid;
logic db_fifo_fid_sel;
logic db_fifo_buf_sel;
logic db_fifo_empty;
logic db_fifo_wr = last_en_hop_wr0;
logic db_fifo_rd = dec_update_pc&end_program;

logic buf_sel;
flop_rst_en #(1) u_flop_rst_en_7(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(db_fifo_rd), .din({~buf_sel}), .dout({buf_sel}));

sfifo2f1 #(2+`TID_NBITS+`FID_NBITS) u_sfifo2f1_0(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(db_fifo_wr), .din({piarb_pu_meta_data.tid, piarb_pu_meta_data.fid, piarb_pu_fid_sel, buf_sel}), .dout({db_fifo_tid, db_fifo_fid, db_fifo_fid_sel, db_fifo_buf_sel}), .rd(db_fifo_rd), .full(), .empty(db_fifo_empty), .count(), .fullm1(), .emptyp2());

/* issue */

logic en_update_pc = ~db_fifo_empty;

logic inst_fifo_full;
logic inst_fifo_rd;

logic inst_fifo_av = ~inst_fifo_full|inst_fifo_rd;

logic stall_pipeline;
logic update_pc = ~stall_pipeline&en_update_pc&inst_fifo_av;

logic [PC_NBITS-1:0] dec_pc;
logic [PC_NBITS-1:0] exec_pc;

logic [PC_NBITS-1:0] pc;
logic [PC_NBITS-1:0] next_pc = dec_update_pc?(end_program?0:dec_pc):exec_update_pc?exec_pc:pc+2;
logic load_pc = toggle_wr1|dec_update_pc|exec_update_pc;
logic load_pc_d1;

logic dec_flag;
logic exec_flag;

flop_rst_en #(1) u_flop_rst_en_8(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(dec_update_pc), .din({~dec_flag}), .dout({dec_flag}));
flop_rst_en #(1) u_flop_rst_en_9(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(exec_update_pc), .din({~exec_flag}), .dout({exec_flag}));

logic pc_msb;
flop_rst_en #(1) u_pc_msb(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(toggle_wr1), .din(~pc_msb), .dout(pc_msb));
flop_rst_en #(PC_NBITS) u_pc(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(update_pc), .din(next_pc), .dout(pc));

logic [WIDTH_NBITS-1:0] ram_inst0, ram_inst1, ram_inst2, ram_inst3, ram_inst;
ram_1r1w_bram #(WIDTH_NBITS, INST_DEPTH_NBITS+1) u_ram_1r1w_bram_0(.clk(clk), .wr(en_inst_wr), .raddr({pc_msb, pc[PC_NBITS-1:3]}), .waddr(inst_wr_addr), .din(piarb_pu_inst_data[WIDTH_NBITS-1:0]), .dout(ram_inst0));
ram_1r1w_bram #(WIDTH_NBITS, INST_DEPTH_NBITS+1) u_ram_1r1w_bram_1(.clk(clk), .wr(en_inst_wr), .raddr({pc_msb, pc[PC_NBITS-1:3]}), .waddr(inst_wr_addr), .din(piarb_pu_inst_data[WIDTH_NBITS*2-1:WIDTH_NBITS*1]), .dout(ram_inst1));
ram_1r1w_bram #(WIDTH_NBITS, INST_DEPTH_NBITS+1) u_ram_1r1w_bram_2(.clk(clk), .wr(en_inst_wr), .raddr({pc_msb, pc[PC_NBITS-1:3]}), .waddr(inst_wr_addr), .din(piarb_pu_inst_data[WIDTH_NBITS*3-1:WIDTH_NBITS*2]), .dout(ram_inst2));
ram_1r1w_bram #(WIDTH_NBITS, INST_DEPTH_NBITS+1) u_ram_1r1w_bram_3(.clk(clk), .wr(en_inst_wr), .raddr({pc_msb, pc[PC_NBITS-1:3]}), .waddr(inst_wr_addr), .din(piarb_pu_inst_data[WIDTH_NBITS*4-1:WIDTH_NBITS*3]), .dout(ram_inst3));

logic [2:0] pc_d1;
logic update_pc_d1;
flop_rst #(5) u_flop_rst_10(.clk(clk), .`RESET_SIG(`RESET_SIG), .din({load_pc, update_pc, pc[2:0]}), .dout({load_pc_d1, update_pc_d1, pc_d1}));
always @(*) case(pc_d1[2:1]) 2'b00: ram_inst = ram_inst0; 2'b01: ram_inst = ram_inst1; 2'b10: ram_inst = ram_inst2; 2'b11: ram_inst = ram_inst3; endcase
logic upper_av;
logic [15:0] inst_sv;
flop_rst_en #(16+1) u_flop_rst_en_11(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(update_pc_d1), .din({ram_inst[31:16], pc_d1[0]}), .dout({inst_sv, upper_av}));

logic upper_av1 = upper_av&~load_pc_d1;
logic [WIDTH_NBITS-1:0] instruction = upper_av1?{ram_inst[15:0], inst_sv}:ram_inst;

logic inst_fifo_wr = update_pc&(~pc[0]|upper_av1);

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

logic inst_32b = up_half_av?&inst_up_half[1:0]:&instruction[1:0];

logic inst_16b_av = ~inst_32b&up_half_av;
logic fetch_fifo_wr = ~stall_pipeline&(inst_16b_av|~inst_fifo_empty);
assign inst_fifo_rd = ~stall_pipeline&~inst_fifo_empty&~inst_16b_av;

logic up_half = inst_32b&up_half_av;

flop_rst_en #(16+1) u_flop_rst_en_12(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(fetch_fifo_wr), .din({instruction[31:16], up_half}), .dout({inst_up_half, up_half_av}));

logic [`TID_NBITS-1:0] fetch_fifo_tid;
logic [`FID_NBITS-1:0] fetch_fifo_fid;
logic [PC_NBITS-1:0] fetch_fifo_pc;
logic fetch_fifo_inst_32b;
logic fetch_fifo_fid_sel;
logic fetch_fifo_buf_sel;
logic fetch_fifo_dec_flag;
logic fetch_fifo_exec_flag;
logic [WIDTH_NBITS-1:0] fetch_fifo_din1 = up_half_av?{instruction[15:0], inst_up_half}:instruction;
logic [WIDTH_NBITS-1:0] fetch_fifo_din = inst_32b?fetch_fifo_din1:expansion(fetch_fifo_din1[15:0]);
logic fetch_fifo_empty;
logic fetch_fifo_rd;
logic [WIDTH_NBITS-1:0] fetch_fifo_dout;
sfifo1f #(1+WIDTH_NBITS+2+`TID_NBITS+`FID_NBITS+2+PC_NBITS) u_sfifo1f_2(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(update_pc), .din({inst_32b, fetch_fifo_din, inst_fifo_dec_flag, inst_fifo_exec_flag, inst_fifo_tid, inst_fifo_fid, inst_fifo_fid_sel, inst_fifo_buf_sel, inst_fifo_pc}), .dout({fetch_fifo_inst_32b, fetch_fifo_dout, fetch_fifo_dec_flag, fetch_fifo_exec_flag, fetch_fifo_tid, fetch_fifo_fid, fetch_fifo_fid_sel, fetch_fifo_buf_sel, fetch_fifo_pc}), .rd(fetch_fifo_rd), .full(), .empty(fetch_fifo_empty));

/* decode */

dec_type dec_cmd;
pu_decode u_pu_decode(.inst(fetch_fifo_dout), .dec_cmd(dec_cmd));

logic wb_en;
logic [WIDTH_NBITS-1:0] wb_data;
logic [RF_DEPTH_NBITS-1:0] wb_addr;

logic [WIDTH_NBITS-1:0] rf_data0, rf_data1;

pu_rf #(WIDTH_NBITS, RF_DEPTH_NBITS) u_pu_rf(.clk(clk), .wr(wb_en), .raddr0(dec_cmd.rs1), .raddr1(dec_cmd.rs2), .waddr(wb_addr), .din(wb_data), .dout0(rf_data0), .dout1(rf_data1));

logic inst_16b = ~fetch_fifo_inst_32b;

logic dec_fifo_wr_en = ~stall_pipeline&~inst_fifo_empty;
assign fetch_fifo_rd = dec_fifo_wr_en;

assign end_program = dec_cmd.end_program;
assign dec_update_pc = dec_fifo_wr_en&end_program;
assign dec_pc = 0;

logic dec_dec_flag;
flop_rst_en #(1) u_flop_rst_en_13(.clk(clk), .`RESET_SIG(`RESET_SIG), .en(dec_update_pc), .din({~dec_dec_flag}), .dout({dec_dec_flag}));

logic dec_fifo_wr = dec_fifo_wr_en&(dec_dec_flag==fetch_fifo_dec_flag)&~(dec_update_pc&~end_program);

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
logic [WIDTH_NBITS-1:0] mem_wb_data;
logic [RF_DEPTH_NBITS-1:0] mem_wb_addr;

logic io_wb_en;
logic [WIDTH_NBITS-1:0] io_wb_data;
logic [RF_DEPTH_NBITS-1:0] io_wb_addr;

logic [WIDTH_NBITS-1:0] mrf_data0 = dec_cmd_d1.rs1==0?0:
				mem_wb_en&(dec_cmd_d1.rs1==mem_wb_addr)?mem_wb_data:
				io_wb_en&(dec_cmd_d1.rs1==io_wb_addr)?io_wb_data:rf_data0;

logic [WIDTH_NBITS-1:0] mrf_data1 = dec_cmd_d1.rs2==0?0:
				mem_wb_en&(dec_cmd_d1.rs2==mem_wb_addr)?mem_wb_data:
				io_wb_en&(dec_cmd_d1.rs2==io_wb_addr)?io_wb_data:rf_data1;

logic [WIDTH_NBITS-1:0] alu_out;
pu_alu u_pu_alu(.use_imm(dec_cmd_d1.use_imm), .imm(dec_cmd_d1.imm), .rs1(mrf_data0), .rs2(mrf_data1), .funct3(dec_cmd_d1.funct3), .funct5(dec_cmd_d1.funct5), .alu(alu_out));

logic exec_fifo_wr_en = ~stall_pipeline&~dec_fifo_empty;
assign dec_fifo_rd = exec_fifo_wr_en;

logic [INST_DEPTH_NBITS-1:0] pc_offset = dec_cmd_d1.imm;
assign exec_pc = (dec_cmd_d1.jalr?mrf_data0:dec_fifo_pc)+pc_offset;
assign exec_update_pc = exec_fifo_wr_en&(dec_cmd_d1.jal|dec_cmd_d1.jalr|(dec_cmd_d1.branch&(dec_cmd_d1.take_branch?alu_out==0:alu_out!=0)));

logic [WIDTH_NBITS-1:0] exec_update_pc_wb_data = dec_fifo_inst_32b?dec_fifo_pc+4:dec_fifo_pc+2;
logic exec_update_pc_wb = (dec_cmd_d1.jal|dec_cmd_d1.jalr)&dec_cmd_d1.rd!=0;

logic [WIDTH_NBITS-1:0] auipc_wb_data = exec_pc;
logic auipc_wb = dec_cmd_d1.auipc;

logic [WIDTH_NBITS-1:0] lui_wb_data = dec_cmd_d1.imm;
logic lui_wb = dec_cmd_d1.lui;

logic [WIDTH_NBITS-1:0] op_wb_data = alu_out;
logic op_wb = dec_cmd_d1.op|dec_cmd_d1.opi;

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

logic exec_fifo_wr = exec_fifo_wr_en&(exec_exec_flag==dec_fifo_exec_flag)&~(exec_update_pc&~exec_update_pc_wb);

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

assign mem_wb_en = exec_cmd_d1.wb_en;
assign mem_wb_data = exec_cmd_d1.wb_data;
assign mem_wb_addr = exec_cmd_d1.wb_addr;

logic load_mem00 = (exec_cmd_d1.mem_addr[`PU_MEM_DEPTH_MSB_RANGE]==`PU_RAS_MEM);
logic ram_wr00 = ~exec_fifo_end_program&exec_cmd_d1.mem_wr&(exec_cmd_d1.mem_addr[`PU_MEM_DEPTH_MSB_RANGE]==`PU_RAS_MEM);
logic [3:0] ram_we;
always @(*)
	case (exec_cmd_d1.funct3[2:0])
		2'b0: for (i=0; i<4; i=i+1) ram_we[i] = i==exec_cmd_d1.mem_addr[1:0];
		2'b1: for (i=0; i<4; i=i+1) ram_we[i] = (i>>1)==exec_cmd_d1.mem_addr[1];
		default: ram_we = 4'hf;
	endcase
logic [3:0] ram_we00 = ram_we;

logic [MEM_DEPTH_NBITS-1:0] ram_waddr00 = exec_cmd_d1.mem_addr[`PU_MEM_DEPTH_LSB_RANGE];
logic [WIDTH_NBITS-1:0] ram_wdata00 = exec_cmd_d1.mem_wdata;
logic [MEM_DEPTH_NBITS-1:0] ram_raddr00 = ram_waddr00;
logic [WIDTH_NBITS-1:0] ram_rdata00;

logic [MEM_DEPTH_NBITS-1+1:0] ram_raddr01;
logic [WIDTH_NBITS-1:0] ram_rdata01;

ram_dual_we_bram #(WIDTH_NBITS, MEM_DEPTH_NBITS+1) u_ram_dual_we_bram(.clk1(clk), .wr1(ram_wr00), .we1(), .raddr1({exec_fifo_buf_sel, ram_raddr00}), .waddr1({exec_fifo_buf_sel, ram_waddr00}), .din1(ram_wdata00), .dout1(ram_rdata00), .clk2(clk), .wr2(ram_wr01), .we2({(4){ram_wr01}}), .raddr2(ram_raddr01), .waddr2(ram_waddr01), .din2(ram_wdata01), .dout2(ram_rdata01));

logic load_mem10 = (exec_cmd_d1.mem_addr[`PU_MEM_DEPTH_MSB_RANGE]==`PU_PD_MEM);
logic ram_wr10_0 = ~exec_fifo_end_program&exec_cmd_d1.mem_wr&(exec_cmd_d1.mem_addr[`PU_MEM_DEPTH_MSB_RANGE]==`PU_PD_MEM)&(exec_cmd_d1.mem_addr[1:0]==2'b00);
logic [WIDTH_NBITS-1:0] ram_rdata10_0;
logic ram_wr10_1 = ~exec_fifo_end_program&exec_cmd_d1.mem_wr&(exec_cmd_d1.mem_addr[`PU_MEM_DEPTH_MSB_RANGE]==`PU_PD_MEM)&(exec_cmd_d1.mem_addr[1:0]==2'b01);
logic [WIDTH_NBITS-1:0] ram_rdata10_1;
logic ram_wr10_2 = ~exec_fifo_end_program&exec_cmd_d1.mem_wr&(exec_cmd_d1.mem_addr[`PU_MEM_DEPTH_MSB_RANGE]==`PU_PD_MEM)&(exec_cmd_d1.mem_addr[1:0]==2'b10);
logic [WIDTH_NBITS-1:0] ram_rdata10_2;
logic ram_wr10_3 = ~exec_fifo_end_program&exec_cmd_d1.mem_wr&(exec_cmd_d1.mem_addr[`PU_MEM_DEPTH_MSB_RANGE]==`PU_PD_MEM)&(exec_cmd_d1.mem_addr[1:0]==2'b11);
logic [WIDTH_NBITS-1:0] ram_rdata10_3;
logic [PD_DEPTH_NBITS-1:0] ram_waddr10 = exec_cmd_d1.mem_addr[`PU_MEM_DEPTH_LSB_RANGE];
logic [WIDTH_NBITS-1:0] ram_wdata10 = exec_cmd_d1.mem_wdata;
logic [PD_DEPTH_NBITS-1:0] ram_raddr10 = ram_waddr10;
logic [1:0] ram_raddr10_lsb = exec_cmd_d1.mem_addr[3:2];
logic [3:0] ram_we10 = ram_we;

logic ram_wr11 = en_pd_wr;
logic [PD_DEPTH_NBITS:0] ram_waddr11 = {wr_pd_buf_sel, pd_wr_addr_lsb};
logic [`DATA_PATH_NBITS-1:0] ram_wdata11 = piarb_pu_inst_data;
logic [PD_DEPTH_NBITS:0] ram_raddr11;
logic [`DATA_PATH_NBITS-1:0] ram_rdata11;

ram_dual_we_bram #(WIDTH_NBITS, PD_DEPTH_NBITS+1) u_ram_dual_we_bram_4(.clk1(clk), .wr1(ram_wr10_0), .we1(ram_we10), .raddr1({exec_fifo_buf_sel, ram_raddr10}), .waddr1({exec_fifo_buf_sel, ram_waddr10}), .din1(ram_wdata10), .dout1(ram_rdata10_0), .clk2(clk), .wr2(ram_wr11), .we2({(4){ram_wr11}}), .raddr2(ram_raddr11), .waddr2(ram_waddr11), .din2(ram_wdata11[WIDTH_NBITS*1-1:WIDTH_NBITS*0]), .dout2(ram_rdata11[WIDTH_NBITS*1-1:WIDTH_NBITS*0]));
ram_dual_we_bram #(WIDTH_NBITS, PD_DEPTH_NBITS+1) u_ram_dual_we_bram_5(.clk1(clk), .wr1(ram_wr10_1), .we1(ram_we10), .raddr1({exec_fifo_buf_sel, ram_raddr10}), .waddr1({exec_fifo_buf_sel, ram_waddr10}), .din1(ram_wdata10), .dout1(ram_rdata10_1), .clk2(clk), .wr2(ram_wr11), .we2({(4){ram_wr11}}), .raddr2(ram_raddr11), .waddr2(ram_waddr11), .din2(ram_wdata11[WIDTH_NBITS*2-1:WIDTH_NBITS*1]), .dout2(ram_rdata11[WIDTH_NBITS*2-1:WIDTH_NBITS*1]));
ram_dual_we_bram #(WIDTH_NBITS, PD_DEPTH_NBITS+1) u_ram_dual_we_bram_6(.clk1(clk), .wr1(ram_wr10_2), .we1(ram_we10), .raddr1({exec_fifo_buf_sel, ram_raddr10}), .waddr1({exec_fifo_buf_sel, ram_waddr10}), .din1(ram_wdata10), .dout1(ram_rdata10_2), .clk2(clk), .wr2(ram_wr11), .we2({(4){ram_wr11}}), .raddr2(ram_raddr11), .waddr2(ram_waddr11), .din2(ram_wdata11[WIDTH_NBITS*3-1:WIDTH_NBITS*2]), .dout2(ram_rdata11[WIDTH_NBITS*3-1:WIDTH_NBITS*2]));
ram_dual_we_bram #(WIDTH_NBITS, PD_DEPTH_NBITS+1) u_ram_dual_we_bram_7(.clk1(clk), .wr1(ram_wr10_3), .we1(ram_we10), .raddr1({exec_fifo_buf_sel, ram_raddr10}), .waddr1({exec_fifo_buf_sel, ram_waddr10}), .din1(ram_wdata10), .dout1(ram_rdata10_3), .clk2(clk), .wr2(ram_wr11), .we2({(4){ram_wr11}}), .raddr2(ram_raddr11), .waddr2(ram_waddr11), .din2(ram_wdata11[WIDTH_NBITS*4-1:WIDTH_NBITS*3]), .dout2(ram_rdata11[WIDTH_NBITS*4-1:WIDTH_NBITS*3]));

logic mem_fifo_wr_en = ~stall_pipeline&~exec_fifo_empty;
logic mem_fifo_wr = ~exec_fifo_end_program&mem_fifo_wr_en;
assign exec_fifo_rd = mem_fifo_wr_en;

logic [1:0] ram_raddr10_lsb_d1;
flop_en #(2) u_flop_en_141(.clk(clk), .en(mem_fifo_wr_en), .din({ram_raddr10_lsb}), .dout({ram_raddr10_lsb_d1}));
logic [WIDTH_NBITS-1:0] ram_rdata10;
always @(*) case(ram_raddr10_lsb_d1) 2'b00: ram_rdata10 = ram_rdata10_0; 2'b01: ram_rdata10 = ram_rdata10_1; 2'b10: ram_rdata10 = ram_rdata10_2; 2'b11: ram_rdata10 = ram_rdata10_3; endcase

logic buf_sel_fifo_wr = exec_fifo_rd&exec_fifo_end_program;
logic ras_fifo_empty;
logic pending_ras_rd;
logic set_ras_rd = (buf_sel_fifo_wr|pending_ras_rd)&~ras_fifo_empty;
logic set_pending_ras_rd = buf_sel_fifo_wr&ras_fifo_empty;

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

logic [WIDTH_NBITS-1:0] ram_rdata = mem_fifo_load00?ram_rdata00:ram_rdata10;

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

wb_type wb_cmd;
assign wb_cmd.wb_en = exec_cmd_d2.wb_en|exec_cmd_d2.load;
assign wb_cmd.wb_addr = exec_cmd_d2.wb_addr;
assign wb_cmd.wb_data = exec_cmd_d2.load?ram_rdata1:exec_cmd_d2.wb_data;

assign io_wb_en = wb_cmd.wb_en;
assign io_wb_data = wb_cmd.wb_data;
assign io_wb_addr = wb_cmd.wb_addr;

logic n_stall_pipeline = io_req?1'b1:io_ack?1'b0:stall_pipeline;

flop_rst #(1) u_flop_rst_15(.clk(clk), .`RESET_SIG(`RESET_SIG), .din(n_stall_pipeline), .dout(stall_pipeline));

logic io_rdata_fifo_empty;
logic [WIDTH_NBITS-1:0] io_rdata;
sfifo1f #(WIDTH_NBITS) u_sfifo1f_6(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(io_ack), .din(io_ack_data), .dout(io_rdata), .rd(), .full(), .empty(io_rdata_fifo_empty));

logic io_fifo_wr = ~stall_pipeline&~mem_fifo_empty;
assign mem_fifo_rd = io_fifo_wr;

wb_type wb_cmd_d1;
always @(posedge clk) wb_cmd_d1 <= io_fifo_wr?wb_cmd:wb_cmd_d1;

logic io_fifo_rd;
logic io_fifo_empty;
sfifo1f #(1) u_sfifo1f_7(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(io_fifo_wr), .din(1'b1), .dout(), .rd(io_fifo_rd), .full(), .empty(io_fifo_empty));

/* write back */

assign wb_en = ~io_fifo_empty&wb_cmd.wb_en;
assign wb_addr = wb_cmd.wb_addr;
assign wb_data = io_rdata_fifo_empty?wb_cmd.wb_data:io_rdata;

assign io_fifo_rd = wb_en;

/****************************************************************************/

logic rd_pd_len_fifo_wr = last_en_pd_wr;
logic rd_pd_len_fifo_rd;
logic [`PD_CHUNK_NBITS-1-4:0] rd_pd_len_fifo_din = nxt_pd_cnt;
logic [`PD_CHUNK_NBITS-1-4:0] rd_pd_len_fifo_dout;

sfifo1f #(`PD_CHUNK_NBITS-4) u_sfifo1f_8(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(rd_pd_len_fifo_wr), .din(rd_pd_len_fifo_din), .dout(rd_pd_len_fifo_dout), .rd(rd_pd_len_fifo_rd), .full(), .empty());

logic pd_fifo_wr;
logic pd_fifo_eop_in;

logic pd_fifo_empty;
logic pd_fifo_sop_in;
logic pd_fifo_sop;
logic pd_fifo_eop;
logic [`DATA_PATH_NBITS-1:0] pd_fifo_din;
logic [`DATA_PATH_NBITS-1:0] pd_fifo_dout;

assign pu_em_data_valid_out_p1 = pu_em_data_valid_in|~pd_fifo_empty;
assign pu_em_sop_out_p1 = pu_em_data_valid_in?pu_em_sop_in:pd_fifo_sop;
assign pu_em_eop_out_p1 = pu_em_data_valid_in?pu_em_eop_in:pd_fifo_eop;
assign pu_em_port_id_out_p1 = pu_em_data_valid_in?pu_em_port_id_in:PU_ID;
assign pu_em_packet_data_out_p1 = pu_em_data_valid_in?pu_em_packet_data_in:pd_fifo_dout;

logic pu_done_fifo_empty;
logic pu_gnt_fifo_empty;
logic pu_done_fifo_rd = ~pu_fid_done_in&~pu_done_fifo_empty&~pu_gnt_fifo_empty;
logic pu_gnt_fifo_rd = pu_done_fifo_rd;
sfifo2f1 #(1) u_sfifo2f1_9(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(pu_gnt_d1), .din(1'b1), .dout(), .rd(pu_gnt_fifo_rd), .full(), .empty(pu_gnt_fifo_empty), .count(), .fullm1(), .emptyp2());

logic pd_fifo_rd = ~pu_em_data_valid_in&~pd_fifo_empty&~pu_gnt_fifo_empty;

sfifo2f_fo #(2+`DATA_PATH_NBITS, PD_DEPTH_NBITS+1) u_sfifo2f_fo_10(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(pd_fifo_wr), .din({pd_fifo_sop_in, pd_fifo_eop_in, pd_fifo_din}), .dout({pd_fifo_sop, pd_fifo_eop, pd_fifo_dout}), .rd(pd_fifo_rd), .full(), .empty(pd_fifo_empty), .ncount(), .count(), .fullm1(), .emptyp2());

logic intf_pd_len_fifo_wr = rd_pd_len_fifo_rd;
logic intf_pd_len_fifo_rd;
logic [PD_DEPTH_NBITS-1:0] intf_pd_len_fifo_din = rd_pd_len_fifo_dout;
logic [PD_DEPTH_NBITS-1:0] intf_pd_len_fifo_dout;

sfifo2f1 #(PD_DEPTH_NBITS) u_sfifo2f1_11(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(intf_pd_len_fifo_wr), .din(intf_pd_len_fifo_din), .dout(intf_pd_len_fifo_dout), .rd(intf_pd_len_fifo_rd), .full(), .empty(), .count(), .fullm1(), .emptyp2());

logic [2:0] ras_rd_cnt_d1;
logic set_ras_fifo_rd_en = pu_asa_start_in&~pu_asa_valid_in&~pu_gnt_fifo_empty;
logic ras_fifo_rd_en;
logic ras_fifo_rd_mode = set_ras_fifo_rd_en|ras_fifo_rd_en;

logic ras_fifo_eop;
logic ras_fifo_rd = ras_fifo_rd_mode&~ras_fifo_empty&~pu_gnt_fifo_empty;

logic reset_ras_fifo_rd_en = ras_fifo_rd&ras_fifo_eop;
logic [WIDTH_NBITS-1:0] ras_fifo_din;
logic [WIDTH_NBITS-1:0] ras_fifo_dout;

assign pu_asa_valid_out_p1 = pu_asa_valid_in|ras_fifo_rd;
assign pu_asa_eop_out_p1 = pu_asa_eop_in|ras_fifo_eop;
assign pu_asa_data_out_p1 = pu_asa_data_in|ras_fifo_dout;
assign pu_asa_pu_id_out_p1 = ~ras_fifo_rd_mode?pu_asa_pu_id_in:PU_ID;

sfifo2f_fo #(WIDTH_NBITS+1) u_sfifo2f_fo_12(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(ras_fifo_wr), .din({ras_fifo_eop_in, ras_fifo_din}), .dout({ras_fifo_eop, ras_fifo_dout}), .rd(ras_fifo_rd), .full(), .empty(ras_fifo_empty), .ncount(), .count(), .fullm1(), .emptyp2());

logic pu_done_fifo_din;
logic pu_done_fifo_dout;

assign pu_fid_done_out_p1 = pu_fid_done_in|~pu_done_fifo_empty;
assign pu_fid_sel_out_p1 = pu_fid_done_in?pu_fid_sel_in:pu_done_fifo_dout;
assign pu_id_out_p1 = pu_fid_done_in?pu_id_in:PU_ID;

sfifo2f1 #(1) u_sfifo2f1_13(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(pu_done_fifo_wr), .din(pu_done_fifo_din), .dout(pu_done_fifo_dout), .rd(pu_done_fifo_rd), .full(), .empty(), .count(), .fullm1(), .emptyp2());

localparam RAS_RAM_DEPTH_NBITS = `PU_ASA_TS_NBITS;
localparam RAS_RAM_DEPTH = `PU_ASA_TS;

localparam PD_RAM_DEPTH_NBITS = 5;

localparam IDLE = 0,
            CHECK_PD = 1,
            RD_RAS = 2,
            RD_RAS_PD = 3,
            RD_PD = 4,
            PU_DONE = 5;

logic [2:0] pu_rd_st;

logic [RAS_RAM_DEPTH_NBITS-1:0] ras_rd_cnt;
logic last_ras_rd_cnt = ras_rd_cnt==RAS_RAM_DEPTH-1;
logic last_ras_rd_cnt_d1;

logic [PD_RAM_DEPTH_NBITS-1:0] pd_rd_cnt;
logic [PD_RAM_DEPTH_NBITS-1:0] pd_rd_cnt_d1;
logic first_pd_rd_cnt = pd_rd_cnt==0;
logic last_pd_rd_cnt = pd_rd_cnt==rd_pd_len_fifo_dout;
logic last_pd_rd_cnt_d1;

logic ras_rd_st;
logic ras_rd_st_d1;
logic reset_ras_rd = ras_rd_st&last_ras_rd_cnt;

logic set_pd_rd = (pu_rd_st==RD_PD)&(pd_rd_cnt==0);
logic pd_rd_st;
logic pd_rd_st_d1;
logic reset_pd_rd = pd_rd_st&last_pd_rd_cnt;
logic rd_buf_sel;
logic rd_fid_sel;

assign pu_done_fifo_wr = ((pu_rd_st==RD_RAS)&reset_ras_rd)|((pu_rd_st==RD_PD)&reset_pd_rd)|((pu_rd_st==RD_RAS_PD)&reset_ras_rd&reset_pd_rd);
assign pu_done_fifo_din = rd_fid_sel;

logic buf_sel_fifo_rd = pu_done_fifo_wr;
sfifo2f1 #(2) u_sfifo2f1_14(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(buf_sel_fifo_wr), .din({exec_fifo_buf_sel, exec_fifo_fid_sel}), .dout({rd_buf_sel, rd_fid_sel}), .rd(buf_sel_fifo_rd), .full(), .empty(buf_sel_fifo_empty), .count(), .fullm1(), .emptyp2());

assign ram_raddr01 = {rd_buf_sel, {(MEM_DEPTH_NBITS-RAS_RAM_DEPTH_NBITS-4){1'b0}}, 4'h1, ras_rd_cnt};
assign ram_raddr11 = {rd_buf_sel, {(MEM_DEPTH_NBITS-PD_RAM_DEPTH_NBITS){1'b0}}, pd_rd_cnt};

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

	ras_fifo_din <= ras_rd_st_d1?ram_rdata01:ras_fifo_din;
        last_ras_rd_cnt_d1 <= last_ras_rd_cnt;
	ras_fifo_eop_in <= last_ras_rd_cnt_d1;
	pd_fifo_din <= pd_rd_st_d1?ram_rdata11:pd_fifo_din;
	pd_fifo_sop_in <= pd_rd_st_d1?pd_rd_cnt_d1==0:pd_fifo_sop_in;
        last_pd_rd_cnt_d1 <= last_pd_rd_cnt;
	pd_fifo_eop_in <= pd_rd_st_d1?last_pd_rd_cnt_d1:pd_fifo_eop_in;
end
   
always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin

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

                piarb_pu_valid <= piarb_pu_valid_in;
                piarb_pu_inst_valid <= piarb_pu_inst_valid_in;

        	piarb_pu_valid_eop_d1 <= en_hop_wr1&piarb_pu_eop;
        	piarb_pu_valid_eop_d2 <= piarb_pu_valid_eop_d1;

		pending_ras_rd <= set_pending_ras_rd?1'b1:set_ras_rd?1'b0:pending_ras_rd;

                case (pu_rd_st)
                  IDLE: if(set_ras_rd) pu_rd_st <= CHECK_PD;
                        else pu_rd_st <= IDLE;
                  CHECK_PD: if(ram_rdata01[PD_UPDATE_LOC]) pu_rd_st <= RD_RAS_PD;
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
                ras_fifo_rd_en <= set_ras_rd?1'b1:reset_ras_fifo_rd_en?1'b0:ras_fifo_rd_en;
		pd_rd_st <= set_ras_rd?1'b1:reset_pd_rd?1'b0:pd_rd_st;
		pd_rd_st_d1 <= pd_rd_st;
                pd_fifo_wr <= pd_rd_st_d1;

		ras_rd_cnt <= set_ras_rd?1:~ras_rd_st?ras_rd_cnt:last_ras_rd_cnt?0:ras_rd_cnt+1;
		ras_rd_cnt_d1 <= ras_rd_cnt;
		pd_rd_cnt <= set_ras_rd?1:~pd_rd_st?pd_rd_cnt:last_pd_rd_cnt?0:pd_rd_cnt+1;
		pd_rd_cnt_d1 <= pd_rd_cnt;

		pu_gnt_d1 <= pu_gnt;

		reset_pd_rd_d1 <= reset_pd_rd;

	end

function [31:0] expansion;
input[15:0] din;

begin
	expansion[1:0] = 2'b11;
	expansion[14:12] = din[15:13]; // funct3
	expansion[11:7] = din[11:7]; // rd
	expansion[19:15] = din[11:7]; // rs1
	expansion[24:20] = din[6:2]; // rs2
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

