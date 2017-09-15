//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::enq_pkt_desc_type;

module sfifo_enq_pkt_desc (

	// inputs

	clk,
	`RESET_SIG,

	din,
	rd,
	wr,

	//outputs

	ncount,
	count,
	full,
	empty,
	fullm1,
	emptyp2,
	dout 

	);

parameter DEPTH_NBITS = 3;
parameter DEPTH = (16'h1  << DEPTH_NBITS);


input clk;
input `RESET_SIG;

input enq_pkt_desc_type din;
input rd, wr;

output [DEPTH_NBITS:0] ncount, count;
output full, empty, fullm1, emptyp2;

output enq_pkt_desc_type dout;


/***************************** LOCAL VARIABLES *******************************/

logic empty;
logic [DEPTH_NBITS:0] count;

logic ff_full, ff_empty, ff_fullm1, ff_emptyp1, ff_emptyp2;
enq_pkt_desc_type ff_dout;
logic unused;
logic [(DEPTH_NBITS - 1):0] ff_ncount;

wire nempty = ~(wr^rd)?empty:~wr&rd&ff_empty;

/***************************** NON REGISTERED OUTPUTS ***********************/

assign ncount = ff_ncount+(nempty?1'b0:1'b1);

/***************************** REGISTERED OUTPUTS ***************************/

assign full = ff_full;
assign fullm1 = ff_fullm1;
assign emptyp2 = ff_emptyp1;

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		empty <= 1'b1;
		count <= 1'b0;
	end else begin
		empty <= nempty;
		count <= ncount;
	end

always @(posedge clk) dout <= ~((wr&empty)|rd)?dout:rd&~ff_empty?ff_dout:din;

/***************************** PROGRAM BODY ********************************/

wire ff_rd = rd&~ff_empty;
wire ff_wr = wr&~(empty|(ff_empty&rd));

logic [DEPTH_NBITS-1:0] ff_rptr, ff_wptr;

/**************************** INSTANTIATION ********************************/

sfifo_ctrl #(DEPTH_NBITS, DEPTH-1) u_sfifo_ctrl(

		// inputs

		.clk			(clk),
		.`RESET_SIG		(`RESET_SIG),

		.rd			(ff_rd),
		.wr			(ff_wr),

		//outputs

		.pfull			(),
		.pempty			(),
		.ncount			({unused, ff_ncount}),
		.count			(),
		.full			(ff_full),
		.empty			(ff_empty),
		.fullm1			(ff_fullm1),
		.emptyp1		(ff_emptyp1),
		.emptyp2		(ff_emptyp2),
		.nrptr			(),
		.rptr			(ff_rptr),
		.wptr			(ff_wptr)
);
	
enq_pkt_desc_type fifod [DEPTH-1:0];

assign ff_dout = fifod[ff_rptr];

always @(posedge clk) if (ff_wr) fifod[ff_wptr] <= din;

/***************************** DIAGNOSTICS *********************************/

// synopsys translate_off 
always @(posedge clk) begin
	if (`INACTIVE_RESET & wr & full) $display("ERROR: %d %m write when FIFO full", $time);
	if (`INACTIVE_RESET & rd & empty) $display("ERROR: %d %m read when FIFO empty", $time);
end
// synopsys translate_on

endmodule

