//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module edit_mem_shared_memory #(
parameter BPTR_NBITS = `EM_BUF_PTR_NBITS,
parameter BPTR_LSB_NBITS = `EM_BUF_PTR_LSB_NBITS,
parameter DATA_NBITS = `DATA_PATH_NBITS,
parameter ID_NBITS = `PORT_ID_NBITS
) (

input clk, 
input `RESET_SIG,

input pu_data_valid,
input [BPTR_NBITS-1:0] pu_data_buf_ptr,
input [BPTR_LSB_NBITS-1:0] pu_data_buf_ptr_lsb,
input [DATA_NBITS-1:0] pu_data,

input data_req,
input [ID_NBITS-1:0] data_req_dst_port_id,
input data_req_sop,
input data_req_eop,
input [BPTR_NBITS-1:0] data_req_buf_ptr,
input [BPTR_LSB_NBITS-1:0] data_req_buf_ptr_lsb,


	// outputs
output reg em_rel_buf_valid,
output reg [BPTR_NBITS-1:0] em_rel_buf_ptr,

output reg edit_mem_ack,
output reg [DATA_NBITS-1:0] edit_mem_rdata


);


/***************************** LOCAL VARIABLES *******************************/
reg data_req_d1;
reg [ID_NBITS-1:0] data_req_dst_port_id_d1;
reg data_req_sop_d1;
reg data_req_eop_d1;
reg [BPTR_NBITS-1:0] data_req_buf_ptr_d1;
reg [BPTR_LSB_NBITS-1:0] data_req_buf_ptr_lsb_d1;

reg data_req_d2;
reg [ID_NBITS-1:0] data_req_dst_port_id_d2;
reg data_req_sop_d2;
reg data_req_eop_d2;

reg pu_data_valid_d1;
reg [BPTR_NBITS-1:0] pu_data_buf_ptr_d1;
reg [BPTR_LSB_NBITS-1:0] pu_data_buf_ptr_lsb_d1;
reg [DATA_NBITS-1:0] pu_data_d1;


(* keep = "true" *) wire [DATA_NBITS-1:0] pb_dout  ;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
		em_rel_buf_ptr <= data_req_buf_ptr_d1;
	        edit_mem_rdata <= pb_dout;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		em_rel_buf_valid <= 0;
		edit_mem_ack <= 0;
	end else begin
		em_rel_buf_valid <= data_req_d1&(&data_req_buf_ptr_lsb_d1|data_req_eop_d1);
		edit_mem_ack <= data_req_d2;
	end

/***************************** PROGRAM BODY **********************************/

always @(posedge clk) begin
		data_req_dst_port_id_d1 <= data_req_dst_port_id;
		data_req_sop_d1 <= data_req_sop;
		data_req_eop_d1 <= data_req_eop;
		data_req_buf_ptr_d1 <= data_req_buf_ptr;
		data_req_buf_ptr_lsb_d1 <= data_req_buf_ptr_lsb;
		data_req_dst_port_id_d2 <= data_req_dst_port_id_d1;
		data_req_sop_d2 <= data_req_sop_d1;
		data_req_eop_d2 <= data_req_eop_d1;
		pu_data_buf_ptr_d1 <= pu_data_buf_ptr;
		pu_data_buf_ptr_lsb_d1 <= pu_data_buf_ptr_lsb;
		pu_data_d1 <= pu_data;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		data_req_d1 <= 0;
		data_req_d2 <= 0;
		pu_data_valid_d1 <= 0;
	end else begin
		data_req_d1 <= data_req;
		data_req_d2 <= data_req_d1;
		pu_data_valid_d1 <= pu_data_valid;
	end


/***************************** MEMORY ***************************************/

ram_1r1w_ultra #(DATA_NBITS, BPTR_NBITS+BPTR_LSB_NBITS) u_ram_1r1w_ultra(
        .clk(clk),
        .wr(pu_data_valid_d1),
        .raddr({data_req_buf_ptr_d1, data_req_buf_ptr_lsb_d1}),
	.waddr({pu_data_buf_ptr_d1, pu_data_buf_ptr_lsb_d1}),
        .din(pu_data_d1),

        .dout(pb_dout));

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

