//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module piarb_lookup (

input clk,
input `RESET_SIG,

input ecdsa_piarb_wr,
input [`FID_NBITS-1:0] ecdsa_piarb_waddr,
input [`FLOW_PU_NBITS-1:0] ecdsa_piarb_wdata,

input data_ack_valid,
input [`PU_ID_NBITS-1:0] data_ack_port_id,
input data_ack_sop,
input data_ack_eop,
input [`HOP_INFO_NBITS-1:0] data_ack_data,
input pp_piarb_meta_type data_ack_meta,

input [`FLOW_PU_NBITS-1:0] flow_value_rdata,

input topic_value_ack,
input [`SWITCH_TAG_NBITS-1:0] topic_value_rdata,

output logic topic_value_rd,
output logic [`TID_NBITS-1:0]   topic_value_raddr,

output logic flow_value_wr,
output logic [`FLOW_PU_NBITS-1:0] flow_value_wdata,
output logic [`FID_NBITS-1:0]   flow_value_raddr,
output logic [`FID_NBITS-1:0]   flow_value_waddr,

output logic piarb_pu_valid,
output logic [`PU_ID_NBITS-1:0] piarb_pu_pid,
output logic [`HOP_INFO_NBITS-1:0] piarb_pu_data,
output pu_hop_meta_type piarb_pu_meta_data,
output logic piarb_pu_fid_sel,
output logic piarb_pu_sop,
output logic piarb_pu_eop

);


/***************************** LOCAL VARIABLES *******************************/

logic data_ack_valid_d1;
logic [`PU_ID_NBITS-1:0] data_ack_port_id_d1;
logic data_ack_sop_d1;
logic data_ack_eop_d1;
logic [`HOP_INFO_NBITS-1:0] data_ack_data_d1;
pp_piarb_meta_type data_ack_meta_d1;

logic data_ack_valid_d2;
logic [`PU_ID_NBITS-1:0] data_ack_port_id_d2;
logic data_ack_sop_d2;
logic data_ack_eop_d2;
logic [`HOP_INFO_NBITS-1:0] data_ack_data_d2;
pp_piarb_meta_type data_ack_meta_d2;

logic data_ack_valid_d3;
logic [`PU_ID_NBITS-1:0] data_ack_port_id_d3;
logic data_ack_sop_d3;
logic data_ack_eop_d3;
logic [`HOP_INFO_NBITS-1:0] data_ack_data_d3;
pp_piarb_meta_type data_ack_meta_d3;

wire [`FID_NBITS-1:0] fid = data_ack_meta.fid;
wire [`TID_NBITS-1:0] tid = data_ack_meta.tid;

logic [`FLOW_PU_NBITS-1:0] flow_value_rdata_d1;

wire piarb_pu_fid_sel_p1 = data_ack_meta_d3.fid_sel;

pu_hop_meta_type piarb_pu_meta_data_p1;
assign piarb_pu_meta_data_p1.creation_time = data_ack_meta_d3.creation_time;
assign piarb_pu_meta_data_p1.rci_type = data_ack_meta_d3.rci;
assign piarb_pu_meta_data_p1.pkt_type = ~data_ack_meta_d3.type1?0:2;
assign piarb_pu_meta_data_p1.switch_tag = topic_value_rdata;
assign piarb_pu_meta_data_p1.f_payload = flow_value_rdata_d1;
assign piarb_pu_meta_data_p1.fid = data_ack_meta_d3.fid;
assign piarb_pu_meta_data_p1.tid = data_ack_meta_d3.tid;

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin

	topic_value_raddr <= tid;
	flow_value_raddr <= fid;
	flow_value_waddr <= ecdsa_piarb_waddr;
	flow_value_wdata <= ecdsa_piarb_wdata;

	piarb_pu_data <= data_ack_data_d3;
	piarb_pu_pid <= data_ack_port_id_d3;
	piarb_pu_sop <= data_ack_sop_d3;
	piarb_pu_eop <= data_ack_eop_d3;
	piarb_pu_fid_sel <= piarb_pu_fid_sel_p1;
	piarb_pu_meta_data <= piarb_pu_meta_data_p1;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	topic_value_rd <= 1'b0;
	flow_value_wr <= 1'b0;
	piarb_pu_valid <= 1'b0;
    end else begin

	topic_value_rd <= data_ack_valid;
	flow_value_wr <= ecdsa_piarb_wr;
	piarb_pu_valid <= data_ack_valid_d3;
    end

/***************************** PROGRAM BODY **********************************/

always @(posedge clk) begin
        
	data_ack_data_d1 <= data_ack_data;
	data_ack_data_d2 <= data_ack_data_d1;
	data_ack_data_d3 <= data_ack_data_d2;
	data_ack_meta_d1 <= data_ack_meta;
	data_ack_meta_d2 <= data_ack_meta_d1;
	data_ack_meta_d3 <= data_ack_meta_d2;
	data_ack_port_id_d1 <= data_ack_port_id;
	data_ack_port_id_d2 <= data_ack_port_id_d1;
	data_ack_port_id_d3 <= data_ack_port_id_d2;
	data_ack_sop_d1 <= data_ack_sop;
	data_ack_sop_d2 <= data_ack_sop_d1;
	data_ack_sop_d3 <= data_ack_sop_d2;
	data_ack_eop_d1 <= data_ack_eop;
	data_ack_eop_d2 <= data_ack_eop_d1;
	data_ack_eop_d3 <= data_ack_eop_d2;

	flow_value_rdata_d1 <= flow_value_rdata;

end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin

	data_ack_valid_d1 <= 1'b0;
	data_ack_valid_d2 <= 1'b0;
	data_ack_valid_d3 <= 1'b0;

    end else begin

	data_ack_valid_d1 <= data_ack_valid;
	data_ack_valid_d2 <= data_ack_valid_d1;
	data_ack_valid_d3 <= data_ack_valid_d2;
    end


/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

