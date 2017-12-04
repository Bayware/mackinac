//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import type_package::*;
import meta_package::*;

module pu #(
parameter ID_NBITS = `PU_ID_NBITS,
parameter DATA_NBITS = `DATA_PATH_NBITS,
parameter WIDTH_NBITS = `PU_WIDTH_NBITS,
parameter INST_DEPTH_NBITS = `INST_CHUNK_NBITS-2,
parameter PD_DEPTH_NBITS = `PD_CHUNK_NBITS-2,
parameter HOP_DEPTH_NBITS = `PATH_CHUNK_NBITS-2,
parameter RF_DEPTH_NBITS = 6,
parameter PU_MEM_DEPTH_NBITS = `PU_MEM_DEPTH_NBITS,
parameter MEM_DEPTH_NBITS = `PU_MEM_DEPTH_NBITS-2-4,
parameter IO_DATA_NBITS = WIDTH_NBITS,
parameter IO_ADDR_NBITS = `PU_MEM_DEPTH_NBITS-2
) (

input clk, 
input `RESET_SIG,

input     pio_start,
input     pio_rw,
input [`PIO_RANGE] pio_addr_wdata,

output clk_div,
output pio_ack,
output pio_rvalid,
output [`PIO_RANGE] pio_rdata,
   
input   asa_pu_table_wr,
input [`RCI_NBITS-1:0] asa_pu_table_waddr,
input [`SCI_NBITS-1:0] asa_pu_table_wdata,

input piarb_pu_valid,
input [ID_NBITS-1:0] piarb_pu_pid,
input piarb_pu_sop,
input piarb_pu_eop,
input piarb_pu_fid_sel,
input [`HOP_INFO_NBITS-1:0] piarb_pu_data,
   
input pu_hop_meta_type piarb_pu_meta_data,

input piarb_pu_inst_valid,
input [ID_NBITS-1:0] piarb_pu_inst_pid,
input piarb_pu_inst_sop,
input piarb_pu_inst_eop,
input [DATA_NBITS-1:0] piarb_pu_inst_data,
input piarb_pu_inst_pd,
   
output pu_asa_start, 
output pu_asa_valid, 
output [WIDTH_NBITS-1:0] pu_asa_data, 
output pu_asa_eop, 
output [`PU_ID_NBITS-1:0] pu_asa_pu_id,

output pu_em_data_valid,
output pu_em_sop,
output pu_em_eop,
output [ID_NBITS-1:0] pu_em_port_id,        
output [DATA_NBITS-1:0] pu_em_packet_data,

output pu_fid_done,
output [`PU_ID_NBITS-1:0] pu_id,
output pu_fid_sel

);

/***************************** LOCAL VARIABLES *******************************/

logic         mem_bs;
logic         reg_bs;
logic         reg_wr;
logic         reg_rd;
logic [`PIO_RANGE] reg_addr;
logic [`PIO_RANGE] reg_din;

logic conn_context_mem_ack;
logic [`PIO_RANGE] conn_context_mem_rdata;

logic switch_info_mem_ack;
logic [`PIO_RANGE] switch_info_mem_rdata;

logic tag_hash_table_mem_ack;
logic [`PIO_RANGE] tag_hash_table_mem_rdata;

logic tag_value_mem_ack;
logic [`PIO_RANGE] tag_value_mem_rdata;

logic [`NUM_OF_PU-1:0] pu_registers_mem_ack;
logic [`PIO_RANGE] pu_registers_mem_rdata[`NUM_OF_PU-1:0];

logic reg_ms_conn_context;
logic reg_ms_switch_info;
logic reg_ms_tag_hash_table;
logic reg_ms_tag_value;
logic reg_ms_pu_registers;

logic tag_lookup_valid;
logic [`RCI_NBITS-1:0] tag_lookup_result;
logic [2:0] tag_lookup_result_num;
logic [`PU_ID_NBITS-1:0] tag_lookup_result_pid;

logic tag_lookup_status_valid;
logic [3:0] tag_lookup_status;
logic [`PU_ID_NBITS-1:0] tag_lookup_status_pid;

logic [`NUM_OF_PU-1:0] io_ack0; 
logic [WIDTH_NBITS-1:0] io_ack_data0[`NUM_OF_PU-1:0]; 

logic [`NUM_OF_PU-1:0] io_ack1; 
logic [WIDTH_NBITS-1:0] io_ack_data1[`NUM_OF_PU-1:0];

logic [`NUM_OF_PU-1:0] io_ack2; 
logic [WIDTH_NBITS-1:0] io_ack_data2[`NUM_OF_PU-1:0];

logic [`NUM_OF_PU-1:0] io_ack3; 
logic [WIDTH_NBITS-1:0] io_ack_data3[`NUM_OF_PU-1:0];

logic [`NUM_OF_PU-1:0] io_ack4; 
logic [WIDTH_NBITS-1:0] io_ack_data4[`NUM_OF_PU-1:0];

logic [`NUM_OF_PU-1:0] io_ack5; 
logic [WIDTH_NBITS-1:0] io_ack_data5[`NUM_OF_PU-1:0];

logic [`NUM_OF_PU-1:0] pu_gnt;

logic [`NUM_OF_PU:0] piarb_pu_valid_in;
logic [ID_NBITS-1:0] piarb_pu_pid_in[`NUM_OF_PU:0];
logic [`NUM_OF_PU:0] piarb_pu_sop_in;
logic [`NUM_OF_PU:0] piarb_pu_eop_in;
logic [`NUM_OF_PU:0] piarb_pu_fid_sel_in;
logic [`HOP_INFO_NBITS-1:0] piarb_pu_data_in[`NUM_OF_PU:0];
   
pu_hop_meta_type  piarb_pu_meta_data_in[`NUM_OF_PU:0];

logic [`NUM_OF_PU:0] piarb_pu_inst_valid_in;
logic [ID_NBITS-1:0] piarb_pu_inst_pid_in[`NUM_OF_PU:0];
logic [`NUM_OF_PU:0] piarb_pu_inst_sop_in;
logic [`NUM_OF_PU:0] piarb_pu_inst_eop_in;
logic [DATA_NBITS-1:0] piarb_pu_inst_data_in[`NUM_OF_PU:0];
logic [`NUM_OF_PU:0] piarb_pu_inst_pd_in;
   
wire [`NUM_OF_PU-1:0] io_ack = io_ack0|io_ack1|io_ack2|io_ack3|io_ack4|io_ack5; 
logic [WIDTH_NBITS-1:0] io_ack_data[`NUM_OF_PU-1:0];
integer j;
always @(*)
	for(j=0; j<`NUM_OF_PU; j++)
		io_ack_data[j] = io_ack_data0[j]|io_ack_data1[j]|io_ack_data2[j]|io_ack_data3[j]|io_ack_data4[j]|io_ack_data5[j]; 

logic [`NUM_OF_PU:0] pu_asa_start_out; 
logic [`NUM_OF_PU:0] pu_asa_valid_out; 
logic [`NUM_OF_PU:0] pu_asa_eop_out; 
logic [WIDTH_NBITS-1:0] pu_asa_data_out[`NUM_OF_PU:0]; 
logic [`PU_ID_NBITS-1:0] pu_asa_pu_id_out[`NUM_OF_PU:0];

logic [`NUM_OF_PU:0] pu_em_data_valid_out;
logic [`NUM_OF_PU:0] pu_em_sop_out;
logic [`NUM_OF_PU:0] pu_em_eop_out;
logic [ID_NBITS-1:0] pu_em_port_id_out[`NUM_OF_PU:0];        
logic [DATA_NBITS-1:0] pu_em_packet_data_out[`NUM_OF_PU:0];

logic [`NUM_OF_PU:0] pu_fid_done_out;
logic [`PU_ID_NBITS-1:0] pu_id_out[`NUM_OF_PU:0];
logic [`NUM_OF_PU:0] pu_fid_sel_out;

logic [`NUM_OF_PU-1:0] pu_req;

logic [`NUM_OF_PU:0] piarb_pu_valid_out;
logic [ID_NBITS-1:0] piarb_pu_pid_out[`NUM_OF_PU:0];
logic [`NUM_OF_PU:0] piarb_pu_sop_out;
logic [`NUM_OF_PU:0] piarb_pu_eop_out;
logic [`NUM_OF_PU:0] piarb_pu_fid_sel_out;
logic [`HOP_INFO_NBITS-1:0] piarb_pu_data_out[`NUM_OF_PU:0];
   
pu_hop_meta_type piarb_pu_meta_data_out[`NUM_OF_PU:0];

logic [`NUM_OF_PU:0] piarb_pu_inst_valid_out;
logic [ID_NBITS-1:0] piarb_pu_inst_pid_out[`NUM_OF_PU:0];
logic [`NUM_OF_PU:0] piarb_pu_inst_sop_out;
logic [`NUM_OF_PU:0] piarb_pu_inst_eop_out;
logic [DATA_NBITS-1:0] piarb_pu_inst_data_out[`NUM_OF_PU:0];
logic [`NUM_OF_PU:0] piarb_pu_inst_pd_out;
   
logic [`NUM_OF_PU-1:0] io_req; 
io_type io_cmd[`NUM_OF_PU-1:0]; 

assign piarb_pu_valid_out[`NUM_OF_PU] = piarb_pu_valid;
assign piarb_pu_pid_out[`NUM_OF_PU] = piarb_pu_pid;
assign piarb_pu_sop_out[`NUM_OF_PU] = piarb_pu_sop;
assign piarb_pu_eop_out[`NUM_OF_PU] = piarb_pu_eop;
assign piarb_pu_fid_sel_out[`NUM_OF_PU] = piarb_pu_fid_sel;
assign piarb_pu_data_out[`NUM_OF_PU] = piarb_pu_data;
assign piarb_pu_meta_data_out[`NUM_OF_PU] = piarb_pu_meta_data;

assign piarb_pu_inst_valid_out[`NUM_OF_PU] = piarb_pu_inst_valid;
assign piarb_pu_inst_pid_out[`NUM_OF_PU] = piarb_pu_inst_pid;
assign piarb_pu_inst_sop_out[`NUM_OF_PU] = piarb_pu_inst_sop;
assign piarb_pu_inst_eop_out[`NUM_OF_PU] = piarb_pu_inst_eop;
assign piarb_pu_inst_data_out[`NUM_OF_PU] = piarb_pu_inst_data;
assign piarb_pu_inst_pd_out[`NUM_OF_PU] = piarb_pu_inst_pd;

logic start;
assign pu_asa_start_out[`NUM_OF_PU] = start;
assign pu_asa_valid_out[`NUM_OF_PU] = 1'b0;
assign pu_asa_data_out[`NUM_OF_PU] = 0;
assign pu_asa_eop_out[`NUM_OF_PU] = 1'b0;
assign pu_asa_pu_id_out[`NUM_OF_PU] = 0;

assign pu_asa_start = pu_asa_start_out[0];
assign pu_asa_valid = pu_asa_valid_out[0];
assign pu_asa_data = pu_asa_data_out[0];
assign pu_asa_eop = pu_asa_eop_out[0];
assign pu_asa_pu_id = pu_asa_pu_id_out[0];

assign pu_em_data_valid_out[`NUM_OF_PU] = 1'b0;
assign pu_em_sop_out[`NUM_OF_PU] = 1'b0;
assign pu_em_eop_out[`NUM_OF_PU] = 1'b0;
assign pu_em_port_id_out[`NUM_OF_PU] = 0;
assign pu_em_packet_data_out[`NUM_OF_PU] = 0;

assign pu_em_data_valid = pu_em_data_valid_out[0];
assign pu_em_sop = pu_em_sop_out[0];
assign pu_em_eop = pu_em_eop_out[0];
assign pu_em_port_id = pu_em_port_id_out[0];
assign pu_em_packet_data = pu_em_packet_data_out[0];

assign pu_fid_done_out[`NUM_OF_PU] = 1'b0;
assign pu_id_out[`NUM_OF_PU] = 0;
assign pu_fid_sel_out[`NUM_OF_PU] = 1'b0;

assign pu_fid_done = pu_fid_done_out[0];
assign pu_id = pu_id_out[0];
assign pu_fid_sel = pu_fid_sel_out[0];

pu_arb u_pu_arb(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.pu_req(pu_req),
		.start(start),
		.pu_gnt(pu_gnt)
);

genvar i;

generate
for(i = 0; i<`NUM_OF_PU; i = i + 1)

	pu_core #(.PU_ID(i)) u_pu_core (

		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

    		.clk_div(clk_div),

    		.reg_addr(reg_addr),
    		.reg_din(reg_din),
    		.reg_rd(reg_rd),
    		.reg_wr(reg_wr),
    		.reg_ms(reg_ms_pu_registers),

		.mem_ack(pu_registers_mem_ack[i]),
		.mem_rdata(pu_registers_mem_rdata[i]),

		.pu_gnt(pu_gnt[i]),

		.piarb_pu_valid_in(piarb_pu_valid_out[i+1]),
		.piarb_pu_pid_in(piarb_pu_pid_out[i+1]),
		.piarb_pu_sop_in(piarb_pu_sop_out[i+1]),
		.piarb_pu_eop_in(piarb_pu_eop_out[i+1]),
		.piarb_pu_fid_sel_in(piarb_pu_fid_sel_out[i+1]),
		.piarb_pu_data_in(piarb_pu_data_out[i+1]),
   
		.piarb_pu_meta_data_in(piarb_pu_meta_data_out[i+1]),

		.piarb_pu_inst_valid_in(piarb_pu_inst_valid_out[i+1]),
		.piarb_pu_inst_pid_in(piarb_pu_inst_pid_out[i+1]),
		.piarb_pu_inst_sop_in(piarb_pu_inst_sop_out[i+1]),
		.piarb_pu_inst_eop_in(piarb_pu_inst_eop_out[i+1]),
		.piarb_pu_inst_data_in(piarb_pu_inst_data_out[i+1]),
		.piarb_pu_inst_pd_in(piarb_pu_inst_pd_out[i+1]),
   
		.io_ack(io_ack[i]), 
		.io_ack_data(io_ack_data[i]), 

		.pu_asa_start_in(pu_asa_start_out[i+1]), 
		.pu_asa_valid_in(pu_asa_valid_out[i+1]), 
		.pu_asa_data_in(pu_asa_data_out[i+1]), 
		.pu_asa_eop_in(pu_asa_eop_out[i+1]), 
		.pu_asa_pu_id_in(pu_asa_pu_id_out[i+1]), 

		.pu_em_data_valid_in(pu_em_data_valid_out[i+1]),
		.pu_em_sop_in(pu_em_sop_out[i+1]),
		.pu_em_eop_in(pu_em_eop_out[i+1]),
		.pu_em_port_id_in(pu_em_port_id_out[i+1]),
		.pu_em_packet_data_in(pu_em_packet_data_out[i+1]),

		.pu_fid_done_in(pu_fid_done_out[i+1]),
		.pu_id_in(pu_id_out[i+1]),
		.pu_fid_sel_in(pu_fid_sel_out[i+1]),

		.pu_req(pu_req[i]),

		.piarb_pu_valid_out(piarb_pu_valid_out[i]),
		.piarb_pu_pid_out(piarb_pu_pid_out[i]),
		.piarb_pu_sop_out(piarb_pu_sop_out[i]),
		.piarb_pu_eop_out(piarb_pu_eop_out[i]),
		.piarb_pu_fid_sel_out(piarb_pu_fid_sel_out[i]),
		.piarb_pu_data_out(piarb_pu_data_out[i]),
   
		.piarb_pu_meta_data_out(piarb_pu_meta_data_out[i]),

		.piarb_pu_inst_valid_out(piarb_pu_inst_valid_out[i]),
		.piarb_pu_inst_pid_out(piarb_pu_inst_pid_out[i]),
		.piarb_pu_inst_sop_out(piarb_pu_inst_sop_out[i]),
		.piarb_pu_inst_eop_out(piarb_pu_inst_eop_out[i]),
		.piarb_pu_inst_data_out(piarb_pu_inst_data_out[i]),
		.piarb_pu_inst_pd_out(piarb_pu_inst_pd_out[i]),
   
		.io_req(io_req[i]), 
		.io_cmd(io_cmd[i]), 

		.pu_asa_start_out(pu_asa_start_out[i]), 
		.pu_asa_valid_out(pu_asa_valid_out[i]), 
		.pu_asa_data_out(pu_asa_data_out[i]), 
		.pu_asa_eop_out(pu_asa_eop_out[i]), 
		.pu_asa_pu_id_out(pu_asa_pu_id_out[i]), 

		.pu_em_data_valid_out(pu_em_data_valid_out[i]),
		.pu_em_sop_out(pu_em_sop_out[i]),
		.pu_em_eop_out(pu_em_eop_out[i]),
		.pu_em_port_id_out(pu_em_port_id_out[i]),
		.pu_em_packet_data_out(pu_em_packet_data_out[i]),

		.pu_fid_done_out(pu_fid_done_out[i]),
		.pu_id_out(pu_id_out[i]),
		.pu_fid_sel_out(pu_fid_sel_out[i])
	);
endgenerate

pio2reg_bus #(
  .BLOCK_ADDR_LSB(`PU_BLOCK_ADDR_LSB),
  .BLOCK_ADDR(`PU_BLOCK_ADDR),
  .REG_BLOCK_ADDR_LSB(0),
  .REG_BLOCK_ADDR(0)
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

pu_pio u_pu_pio(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_div(clk_div),

    .reg_bs(mem_bs),
    .reg_wr(reg_wr),
    .reg_rd(reg_rd),
    .reg_addr(reg_addr),
    .reg_din(reg_din),

    .conn_context_mem_ack(conn_context_mem_ack),
    .conn_context_mem_rdata(conn_context_mem_rdata),

    .switch_info_mem_ack(switch_info_mem_ack),
    .switch_info_mem_rdata(switch_info_mem_rdata),

    .tag_hash_table_mem_ack(tag_hash_table_mem_ack),
    .tag_hash_table_mem_rdata(tag_hash_table_mem_rdata),

    .tag_value_mem_ack(tag_value_mem_ack),
    .tag_value_mem_rdata(tag_value_mem_rdata),

    .pu_registers_mem_ack(pu_registers_mem_ack[0]),
    .pu_registers_mem_rdata(pu_registers_mem_rdata[0]),

    .reg_ms_conn_context(reg_ms_conn_context),
    .reg_ms_switch_info(reg_ms_switch_info),
    .reg_ms_tag_hash_table(reg_ms_tag_hash_table),
    .reg_ms_tag_value(reg_ms_tag_value),
    .reg_ms_pu_registers(reg_ms_pu_registers),

    .pio_ack(pio_ack),
    .pio_rvalid(pio_rvalid),
    .pio_rdata(pio_rdata)

);

pu_conn_context_mem u_pu_conn_context_mem(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_div(clk_div),

    .reg_addr(reg_addr),
    .reg_din(reg_din),
    .reg_rd(reg_rd),
    .reg_wr(reg_wr),
    .reg_ms_conn_context(reg_ms_conn_context),

    .conn_context_mem_ack(conn_context_mem_ack),
    .conn_context_mem_rdata(conn_context_mem_rdata),

    .asa_pu_table_wr(asa_pu_table_wr),
    .asa_pu_table_waddr(asa_pu_table_waddr),
    .asa_pu_table_wdata(asa_pu_table_wdata),

    .io_req(io_req),
    .io_cmd(io_cmd),

    .io_ack(io_ack0),
    .io_ack_data(io_ack_data0)

);


pu_switch_info_mem u_pu_switch_info_mem(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_div(clk_div),

    .reg_ms_switch_info(reg_ms_switch_info),
    .reg_wr(reg_wr),
    .reg_rd(reg_rd),
    .reg_addr(reg_addr),
    .reg_din(reg_din),

    .switch_info_mem_ack(switch_info_mem_ack),
    .switch_info_mem_rdata(switch_info_mem_rdata),

    .io_req(io_req),
    .io_cmd(io_cmd),

    .io_ack(io_ack1),
    .io_ack_data(io_ack_data1)

);

pu_tag_req u_pu_tag_req(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_div(clk_div),

    .reg_ms_tag_hash_table(reg_ms_tag_hash_table),
    .reg_ms_tag_value(reg_ms_tag_value),
    .reg_wr(reg_wr),
    .reg_rd(reg_rd),
    .reg_addr(reg_addr),
    .reg_din(reg_din),

    .tag_hash_table_mem_ack(tag_hash_table_mem_ack),
    .tag_hash_table_mem_rdata(tag_hash_table_mem_rdata),

    .tag_value_mem_ack(tag_value_mem_ack),
    .tag_value_mem_rdata(tag_value_mem_rdata),

    .tag_lookup_valid(tag_lookup_valid),
    .tag_lookup_result(tag_lookup_result),
    .tag_lookup_result_num(tag_lookup_result_num),
    .tag_lookup_result_pid(tag_lookup_result_pid),

    .tag_lookup_status_valid(tag_lookup_status_valid),
    .tag_lookup_status(tag_lookup_status),
    .tag_lookup_status_pid(tag_lookup_status_pid),

    .io_req(io_req),
    .io_cmd(io_cmd),

    .io_ack(io_ack2),
    .io_ack_data(io_ack_data2)

);

pu_tag_result_mem u_pu_tag_result_mem(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_div(clk_div),

    .tag_lookup_valid(tag_lookup_valid),
    .tag_lookup_result(tag_lookup_result),
    .tag_lookup_result_num(tag_lookup_result_num),
    .tag_lookup_result_pid(tag_lookup_result_pid),

    .tag_lookup_status_valid(tag_lookup_status_valid),
    .tag_lookup_status(tag_lookup_status),
    .tag_lookup_status_pid(tag_lookup_status_pid),

    .io_req(io_req),
    .io_cmd(io_cmd),

    .io_ack(io_ack3),
    .io_ack_data(io_ack_data3)

);

pu_flow_pd_mem u_pu_flow_pd_mem(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .io_req(io_req),
    .io_cmd(io_cmd),

    .io_ack(io_ack4),
    .io_ack_data(io_ack_data4)

);

pu_topic_pd_mem u_pu_topic_pd_mem(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .io_req(io_req),
    .io_cmd(io_cmd),

    .io_ack(io_ack5),
    .io_ack_data(io_ack_data5)

);

endmodule
