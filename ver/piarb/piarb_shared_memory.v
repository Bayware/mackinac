//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module piarb_shared_memory #(
parameter ID_NBITS = `PU_ID_NBITS,
parameter BPTR_NBITS = `PIARB_BUF_PTR_NBITS,
parameter BPTR_LSB_NBITS = `PIARB_BUF_PTR_LSB_NBITS,
parameter DATA_NBITS = `HOP_INFO_NBITS
) (

input clk, 
input `RESET_SIG,

input write_data_valid,
input [BPTR_NBITS-1:0] write_buf_ptr,
input [BPTR_LSB_NBITS-1:0] write_buf_ptr_lsb,
input [DATA_NBITS-1:0] write_data,

input data_req,
input [ID_NBITS-1:0] data_req_src_port_id,
input [ID_NBITS-1:0] data_req_dst_port_id,
input data_req_sop,
input data_req_eop,
input [BPTR_NBITS-1:0] data_req_buf_ptr,
input [BPTR_LSB_NBITS-1:0] data_req_buf_ptr_lsb,
input data_req_inst,


	// outputs
output reg rel_buf_valid,
output reg [ID_NBITS-1:0] rel_buf_port_id,
output reg [BPTR_NBITS-1:0] rel_buf_ptr,

output reg data_ack_valid,
output reg [ID_NBITS-1:0] data_ack_port_id,
output reg data_ack_sop,
output reg data_ack_eop,
output reg data_ack_inst,
output reg [DATA_NBITS-1:0] data_ack_data


);


/***************************** LOCAL VARIABLES *******************************/
reg data_req_d1;
reg [ID_NBITS-1:0] data_req_src_port_id_d1;
reg [ID_NBITS-1:0] data_req_dst_port_id_d1;
reg data_req_sop_d1;
reg data_req_eop_d1;
reg [BPTR_NBITS-1:0] data_req_buf_ptr_d1;
reg [BPTR_LSB_NBITS-1:0] data_req_buf_ptr_lsb_d1;
reg data_req_inst_d1;

reg data_req_d2;
reg [ID_NBITS-1:0] data_req_dst_port_id_d2;
reg data_req_sop_d2;
reg data_req_eop_d2;
reg data_req_inst_d2;

reg write_data_valid_d1;
reg [BPTR_NBITS-1:0] write_buf_ptr_d1;
reg [BPTR_LSB_NBITS-1:0] write_buf_ptr_lsb_d1;
reg [DATA_NBITS-1:0] write_data_d1;


wire [DATA_NBITS-1:0] sm_dout  /* synthesis keep = 1 */;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
		rel_buf_port_id <= data_req_src_port_id_d1;
		rel_buf_ptr <= data_req_buf_ptr_d1;
		data_ack_port_id <= data_req_dst_port_id_d2;
		data_ack_sop <= data_req_sop_d2;
	    data_ack_eop <= data_req_eop_d2;
	    data_ack_inst <= data_req_inst_d2;
	    data_ack_data <= sm_dout;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		rel_buf_valid <= 0;
		data_ack_valid <= 0;
	end else begin
		rel_buf_valid <= data_req_d1&(data_req_eop_d1|(&data_req_buf_ptr_lsb_d1));
		data_ack_valid <= data_req_d2;
	end

/***************************** PROGRAM BODY **********************************/

always @(posedge clk) begin
		data_req_src_port_id_d1 <= data_req_src_port_id;
		data_req_dst_port_id_d1 <= data_req_dst_port_id;
		data_req_sop_d1 <= data_req_sop;
		data_req_eop_d1 <= data_req_eop;
		data_req_inst_d1 <= data_req_inst;
		data_req_buf_ptr_d1 <= data_req_buf_ptr;
		data_req_buf_ptr_lsb_d1 <= data_req_buf_ptr_lsb;
		data_req_dst_port_id_d2 <= data_req_dst_port_id_d1;
		data_req_sop_d2 <= data_req_sop_d1;
		data_req_eop_d2 <= data_req_eop_d1;
		data_req_inst_d2 <= data_req_inst_d1;
		write_buf_ptr_d1 <= write_buf_ptr;
		write_buf_ptr_lsb_d1 <= write_buf_ptr_lsb;
		write_data_d1 <= write_data;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		data_req_d1 <= 0;
		data_req_d2 <= 0;
		write_data_valid_d1 <= 0;
	end else begin
		data_req_d1 <= data_req;
		data_req_d2 <= data_req_d1;
		write_data_valid_d1 <= write_data_valid;
	end


/***************************** MEMORY ***************************************/

ram_1r1w #(DATA_NBITS, BPTR_NBITS+BPTR_LSB_NBITS) u_ram_1r1w(
        .clk(clk),
        .wr(write_data_valid_d1),
        .raddr({data_req_buf_ptr_d1, data_req_buf_ptr_lsb_d1}),
		.waddr({write_buf_ptr_d1, write_buf_ptr_lsb_d1}),
        .din(write_data_d1),

        .dout(sm_dout));

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

