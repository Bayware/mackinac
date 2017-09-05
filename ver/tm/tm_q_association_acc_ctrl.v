//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"
`include "datapath.vh"

module tm_q_association_acc_ctrl (
	clk,
    reset,

    shim_tm_wred_req,
	shim_tm_wred_qid, 

	queue_association_ack,
	queue_association_rdata,

	// outputs

	queue_association_rd,
	queue_association_raddr,

	wred_prop_ack,

	prop_queue_group_id,
	prop_tunnel_id,
	prop_port_queue_id,
	prop_port_id

);

input clk, reset;

// wred req for queue properties
input shim_tm_wred_req; 
input [`QUEUE_BITS-1:0] shim_tm_wred_qid;

input queue_association_ack;
input [`QUEUE_PROPERTY_DATA_BITS-1:0] queue_association_rdata;

output queue_association_rd; 
output [`QUEUE_BITS-1:0] queue_association_raddr;

output wred_prop_ack;

// queue properties returned
output [`QUEUE_GROUP_BITS-1:0] prop_queue_group_id;
output [`TUNNEL_BITS-1:0] prop_tunnel_id;
output [`FOURTH_QUEUE_BITS-1:0] prop_port_queue_id;
output [`PORT_BITS-1:0] prop_port_id;


/***************************** LOCAL VARIABLES *******************************/

reg [`QUEUE_GROUP_BITS-1:0] prop_queue_group_id;
reg [`TUNNEL_BITS-1:0] prop_tunnel_id;
reg [`FOURTH_QUEUE_BITS-1:0] prop_port_queue_id;
reg [`PORT_BITS-1:0] prop_port_id;

reg queue_association_rd; 
reg [`QUEUE_BITS-1:0] queue_association_raddr;

reg wred_prop_ack;

wire [`QUEUE_GROUP_BITS-1:0] ram_queue_group;
wire [`TUNNEL_BITS-1:0] ram_tunnel;
wire [`FOURTH_QUEUE_BITS-1:0] ram_port_queue;
wire [`PORT_BITS-1:0] ram_port;

assign {ram_port, ram_port_queue, ram_tunnel, ram_queue_group} = queue_association_rdata;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
		// properties from fifo for enq req; otherwise from the memory
		prop_queue_group_id <= ram_queue_group;
		prop_tunnel_id <= ram_tunnel;
		prop_port_queue_id <= ram_port_queue;
		prop_port_id <= ram_port;

		queue_association_raddr <= shim_tm_wred_qid;
end

always @(`CLK_RST) 
    if (reset) begin
		queue_association_rd <= 0;
		wred_prop_ack <= 0;
	end else begin
		queue_association_rd <= shim_tm_wred_req;
		wred_prop_ack <= queue_association_ack;
	end

/***************************** PROGRAM BODY **********************************/



/***************************** FIFO ***************************************/

/***************************** MEMORY ***************************************/

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

