//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module tm_association_acc (

input clk, 
input `RESET_SIG,

input asa_tm_poll_req, 
input [`FIRST_LVL_QUEUE_ID_NBITS-1:0] asa_tm_poll_qid,

input queue_association_ack,
input [`QUEUE_ASSOCIATION_NBITS-1:0] queue_association_rdata,

output reg queue_association_rd, 
output reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] queue_association_raddr,

output reg poll_association_ack,

output reg [`SECOND_LVL_QUEUE_ID_NBITS-1:0] association_conn_id,
output reg [`THIRD_LVL_QUEUE_ID_NBITS-1:0] association_conn_group_id,
output reg [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] association_port_queue_id,
output reg [`PORT_ID_NBITS-1:0] association_port_id

);

/***************************** LOCAL VARIABLES *******************************/

wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] ram_conn;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] ram_conn_group;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] ram_port_queue;
wire [`PORT_ID_NBITS-1:0] ram_port;

assign {ram_port, ram_port_queue, ram_conn_group, ram_conn} = queue_association_rdata;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
	
		association_conn_id <= ram_conn;
		association_conn_group_id <= ram_conn_group;
		association_port_queue_id <= ram_port_queue;
		association_port_id <= ram_port;

		queue_association_raddr <= asa_tm_poll_qid;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		queue_association_rd <= 0;
		poll_association_ack <= 0;
	end else begin
		queue_association_rd <= asa_tm_poll_req;
		poll_association_ack <= queue_association_ack;
	end

/***************************** PROGRAM BODY **********************************/



/***************************** FIFO ***************************************/

/***************************** MEMORY ***************************************/

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

