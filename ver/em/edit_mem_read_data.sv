//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module edit_mem_read_data #(
parameter BPTR_NBITS = `EM_BUF_PTR_NBITS,
parameter BPTR_LSB_NBITS = `EM_BUF_PTR_LSB_NBITS,
parameter ID_NBITS = `PORT_ID_NBITS,
parameter ADDR_NBITS = `ENQ_ED_CMD_PD_BP_NBITS+`PD_CHUNK_DEPTH_NBITS-`DATA_PATH_VB_NBITS,
parameter LSB_NBITS = `PD_CHUNK_DEPTH_NBITS-BPTR_LSB_NBITS-`DATA_PATH_VB_NBITS
) (


input clk, 
input `RESET_SIG,

input edit_mem_req,
input [ADDR_NBITS-1:0] edit_mem_raddr,
input [ID_NBITS-1:0] edit_mem_port_id,
input edit_mem_sop,
input edit_mem_eop,

input buf_ack_valid,
input [BPTR_NBITS-1:0] buf_ack_ptr,

output logic buf_req,
output logic [BPTR_NBITS-1:0] buf_req_ptr,
			
output logic data_req,			
output logic [ID_NBITS-1:0] data_req_dst_port_id,
output logic data_req_sop,
output logic data_req_eop,
output logic [BPTR_LSB_NBITS-1:0] data_req_buf_ptr_lsb,
output logic [BPTR_NBITS-1:0] data_req_buf_ptr

);

/***************************** LOCAL VARIABLES *******************************/

localparam EDIT_REQ_FIFO_DEPTH_NBITS = 4;
localparam NUM_OF_PORTS = `NUM_OF_PORTS;

integer i;

logic buf_ack_valid_d1;
logic [BPTR_NBITS-1:0] buf_ack_ptr_d1;

wire [BPTR_NBITS-1:0] edit_mem_buf_ptr = edit_mem_raddr[ADDR_NBITS-1:ADDR_NBITS-BPTR_NBITS];
wire edit_mem_buf_ptr_more = edit_mem_raddr[BPTR_LSB_NBITS];
wire [BPTR_LSB_NBITS-1:0] edit_mem_buf_ptr_lsb = edit_mem_raddr[BPTR_LSB_NBITS-1:0];

logic edit_fifo_empty;
logic [ID_NBITS-1:0] edit_fifo_port_id;
logic edit_fifo_eop;
logic [BPTR_NBITS-1:0] edit_fifo_buf_ptr;
logic edit_fifo_buf_ptr_more;
logic [BPTR_LSB_NBITS-1:0] edit_fifo_buf_ptr_lsb;
logic edit_fifo_sop;

logic [NUM_OF_PORTS-1:0] pb_fifo_wr;
logic [NUM_OF_PORTS-1:0] pb_fifo_rd;
logic [NUM_OF_PORTS-1:0] pb_fifo_empty;
logic [BPTR_NBITS-1:0] pb_fifo_data[NUM_OF_PORTS-1:0];

logic [ID_NBITS-1:0] port_fifo_port_id;

wire n_data_req = ~edit_fifo_empty&(edit_fifo_buf_ptr_more==0:1'b1:~pb_fifo_empty[edit_fifo_port_id]);
wire n_buf_req = ~edit_fifo_empty&~edit_fifo_eop&(&edit_fifo_buf_ptr_lsb);

wire port_fifo_wr = n_buf_req;

wire edit_fifo_rd = n_data_req;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
		data_req_dst_port_id <= edit_fifo_port_id;
		data_req_sop <= edit_fifo_sop;
		data_req_eop <= edit_fifo_eop;
		data_req_buf_ptr <= edit_fifo_buf_ptr_more==0?edit_fifo_buf_ptr:pb_fifo_data[edit_fifo_port_id];
		data_req_buf_ptr_lsb <= edit_fifo_buf_ptr_lsb;
end

assign buf_req_ptr = data_req_buf_ptr;

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		buf_req <= 0;
		data_req <= 0;
	end else begin
		buf_req <= n_buf_req;
		data_req <= n_data_req;;
	end

/***************************** PROGRAM BODY **********************************/

always @* begin
	for(i=0; i<NUM_OF_PORTS; i++) begin
		pb_fifo_wr[i] = buf_ack_valid_d1&(port_fifo_port_id==i);
		pb_fifo_rd[i] =  ~edit_fifo_empty&edit_fifo_buf_ptr_more!=0&~pb_fifo_empty[i]&(&edit_fifo_buf_ptr_lsb|edit_fifo_eop);
	end
end



always @(posedge clk) begin
		buf_ack_ptr_d1 <= buf_ack_ptr;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		buf_ack_valid_d1 <= 0;

	end else begin

		buf_ack_valid_d1 <= buf_ack_valid;

	end

/***************************** FIFO ***************************************/
sfifo2f_fo #(BPTR_NBITS+1+BPTR_LSB_NBITS+1+ID_NBITS+1, EDIT_REQ_FIFO_DEPTH_NBITS) u_sfifo2f_fo_0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({edit_mem_buf_ptr, edit_mem_buf_ptr_more, edit_mem_buf_ptr_lsb, edit_mem_sop, edit_mem_port_id, edit_mem_eop}),				
		.rd(edit_fifo_rd),
		.wr(edit_mem_req),

		.ncount(),
		.count(),
		.full(),
		.empty(edit_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({edit_fifo_buf_ptr, edit_fifo_buf_ptr_more, edit_fifo_buf_ptr_lsb, edit_fifo_sop, edit_fifo_port_id, edit_fifo_eop})       
	);

genvar gi;

generate
begin
	for(gi=0; gi<NUM_OF_PORTS; gi++) begin

sfifo1f #(BPTR_NBITS) u_sfifo1f(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({buf_ack_ptr_d1}),				
		.rd(pb_fifo_rd[gi]),
		.wr(pb_fifo_wr[gi]),

		.full(),
		.empty(pb_fifo_empty[gi]),
		.dout({pb_fifo_data[gi]})       
);

	end
end
endgenerate


sfifo2f_fo #(ID_NBITS, 3) u_sfifo2f_fo_2(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({edit_fifo_port_id}),				
		.rd(buf_ack_valid_d1),
		.wr(n_buf_req),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout({port_fifo_port_id})       
);

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off

// synopsys translate_on

endmodule

