//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : buffer manager packet shared memory
//===========================================================================

`include "defines.vh"

module bm_shared_memory (

input clk, 
input `RESET_SIG,

input aggr_bm_packet_valid,
input [`BUF_PTR_NBITS-1:0] aggr_bm_buf_ptr,
input [`BUF_PTR_LSB_RANGE] aggr_bm_buf_ptr_lsb,
input [`DATA_PATH_NBITS-1:0] aggr_bm_packet_data,

input packet_req,
input [`PORT_ID_NBITS-1:0] packet_req_src_port_id,
input [`PORT_ID_NBITS-1:0] packet_req_dst_port_id,
input packet_req_sop,
input packet_req_eop,
input [`DATA_PATH_VB_NBITS-1:0] packet_req_valid_bytes,
input [`BUF_PTR_NBITS-1:0] packet_req_buf_ptr,
input [`BUF_PTR_LSB_RANGE] packet_req_buf_ptr_lsb,


	// outputs
output reg tm_rel_buf_valid,
output reg [`PORT_ID_NBITS-1:0] tm_rel_buf_port_id,
output reg [`BUF_PTR_NBITS-1:0] tm_rel_buf_ptr,

output reg packet_ack_data_valid,
output reg [`PORT_ID_NBITS-1:0] packet_ack_port_id,
output reg packet_ack_sop,

output reg bm_ed_data_valid,
output reg [`PORT_ID_NBITS-1:0] bm_ed_port_id,
output reg bm_ed_sop,
output reg bm_ed_eop,
output reg [`DATA_PATH_VB_NBITS-1:0] bm_ed_valid_bytes,
output reg [`DATA_PATH_NBITS-1:0] bm_ed_packet_data


);


/***************************** LOCAL VARIABLES *******************************/
reg packet_req_d1;
reg [`PORT_ID_NBITS-1:0] packet_req_src_port_id_d1;
reg [`PORT_ID_NBITS-1:0] packet_req_dst_port_id_d1;
reg packet_req_sop_d1;
reg packet_req_eop_d1;
reg [`DATA_PATH_VB_NBITS-1:0] packet_req_valid_bytes_d1;
reg [`BUF_PTR_NBITS-1:0] packet_req_buf_ptr_d1;
reg [`BUF_PTR_LSB_RANGE] packet_req_buf_ptr_lsb_d1;

reg packet_req_d2;
reg [`PORT_ID_NBITS-1:0] packet_req_dst_port_id_d2;
reg packet_req_sop_d2;
reg packet_req_eop_d2;
reg [`DATA_PATH_VB_NBITS-1:0] packet_req_valid_bytes_d2;

reg aggr_bm_packet_valid_d1;
reg [`BUF_PTR_NBITS-1:0] aggr_bm_buf_ptr_d1;
reg [`BUF_PTR_LSB_RANGE] aggr_bm_buf_ptr_lsb_d1;
reg [`DATA_PATH_NBITS-1:0] aggr_bm_packet_data_d1;


(* dont_touch = "true" *) wire [`DATA_PATH_NBITS-1:0] pb_dout  ;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
		tm_rel_buf_port_id <= packet_req_src_port_id_d1;
		tm_rel_buf_ptr <= packet_req_buf_ptr_d1;
	    packet_ack_port_id <= packet_req_dst_port_id;
	    packet_ack_sop <= packet_req_sop;
		bm_ed_port_id <= packet_req_dst_port_id_d2;
		bm_ed_sop <= packet_req_sop_d2;
	    bm_ed_eop <= packet_req_eop_d2;
	    bm_ed_valid_bytes <= packet_req_valid_bytes_d2;
	    bm_ed_packet_data <= pb_dout;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		tm_rel_buf_valid <= 0;
		packet_ack_data_valid <= 0;
		bm_ed_data_valid <= 0;
	end else begin
		tm_rel_buf_valid <= packet_req_d1&(packet_req_eop_d1|(&packet_req_buf_ptr_lsb_d1));
		packet_ack_data_valid <= packet_req;
		bm_ed_data_valid <= packet_req_d2;
	end

/***************************** PROGRAM BODY **********************************/

always @(posedge clk) begin
		packet_req_src_port_id_d1 <= packet_req_src_port_id;
		packet_req_dst_port_id_d1 <= packet_req_dst_port_id;
		packet_req_sop_d1 <= packet_req_sop;
		packet_req_eop_d1 <= packet_req_eop;
		packet_req_valid_bytes_d1 <= packet_req_valid_bytes;
		packet_req_buf_ptr_d1 <= packet_req_buf_ptr;
		packet_req_buf_ptr_lsb_d1 <= packet_req_buf_ptr_lsb;
		packet_req_dst_port_id_d2 <= packet_req_dst_port_id_d1;
		packet_req_sop_d2 <= packet_req_sop_d1;
		packet_req_eop_d2 <= packet_req_eop_d1;
		packet_req_valid_bytes_d2 <= packet_req_valid_bytes_d1;
		aggr_bm_buf_ptr_d1 <= aggr_bm_buf_ptr;
	        aggr_bm_buf_ptr_lsb_d1 <= aggr_bm_buf_ptr_lsb;
		aggr_bm_packet_data_d1 <= aggr_bm_packet_data;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		packet_req_d1 <= 0;
		packet_req_d2 <= 0;
		aggr_bm_packet_valid_d1 <= 0;
	end else begin
		packet_req_d1 <= packet_req;
		packet_req_d2 <= packet_req_d1;
		aggr_bm_packet_valid_d1 <= aggr_bm_packet_valid;
	end


/***************************** MEMORY ***************************************/

ram_1r1w_ultra #(`DATA_PATH_NBITS, (`BUF_PTR_NBITS+`BUF_PTR_LSB_NBITS)) u_ram_1r1w_ultra(
        .clk(clk),
        .wr(aggr_bm_packet_valid_d1),
        .raddr({packet_req_buf_ptr_d1, packet_req_buf_ptr_lsb_d1}),
		.waddr({aggr_bm_buf_ptr_d1, aggr_bm_buf_ptr_lsb_d1}),
        .din(aggr_bm_packet_data_d1),

        .dout(pb_dout));

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

