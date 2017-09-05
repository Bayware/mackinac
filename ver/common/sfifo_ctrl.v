//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : parameterized synchronous FIFO control
//===========================================================================

`include "defines.vh"

module sfifo_ctrl (

	// inputs

	clk,
	`RESET_SIG,

	rd,
	wr,

	//outputs

	pfull,
	pempty,
	ncount,
	count,
	full,
	empty,
	fullm1,
	emptyp1,
	emptyp2,
	nrptr,
	rptr,
	wptr


	);

parameter DEPTH_BITS = 3;
parameter DEPTH = (16'h1  << DEPTH_BITS);
parameter MAXM1 = DEPTH-1'b1;
parameter DELAY_WR_COUNT = 1'b0;
parameter MAXM2 = MAXM1-1'b1;


input clk;
input `RESET_SIG;

input rd, wr;

output pfull, pempty;
output [DEPTH_BITS:0] ncount, count;
output full, empty, fullm1, emptyp1, emptyp2;
output [DEPTH_BITS-1:0] nrptr, rptr, wptr;

/***************************** LOCAL VARIABLES *******************************/

reg wr_f;

reg pfull, pempty;
reg [DEPTH_BITS:0] count;
reg full, empty, fullm1, emptyp1, emptyp2;
reg [DEPTH_BITS-1:0] rptr /* synthesis maxfan = 16 preserve */;
reg [DEPTH_BITS-1:0] wptr /* synthesis maxfan = 16 preserve */;

wire [DEPTH_BITS-1:0] nwptr = ~wr?wptr:(wptr==MAXM1)?1'b0:wptr+1'b1;

wire up_cnt = DELAY_WR_COUNT?wr_f:wr;

/***************************** NON REGISTERED OUTPUTS ***********************/

assign ncount = ~(up_cnt^rd)?count:rd?(count-1'b1):(count+1'b1);
assign nrptr = ~rd?rptr:(rptr==MAXM1)?1'b0:rptr+1'b1;

/***************************** REGISTERED OUTPUTS ***************************/

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		pfull <= 1'b0;
		pempty <= 1'b1;
		count <= {(DEPTH_BITS+1){1'b0}};
		full <= 1'b0;
		empty <= 1'b1;
		fullm1 <= 1'b0;
		emptyp1 <= 1'b0;
		emptyp2 <= 1'b0;
		rptr <= {(DEPTH_BITS){1'b0}};
		wptr <= {(DEPTH_BITS){1'b0}};
	end else begin
		// pfull not affected by DELAY_WR_COUNT
		pfull <= ~pempty&(nwptr==rptr)&~rd;	
		pempty <= ~pfull&(nrptr==wptr)&~wr;
		count <= ncount;
//		full <= (ncount==DEPTH);
		full <= ~(up_cnt^rd)?(count==DEPTH):rd?1'b0:(count==MAXM1);
//		empty <= (ncount=={(DEPTH_BITS+1){1'b0}});
		empty <= ~(up_cnt^rd)?(count=={(DEPTH_BITS+1){1'b0}}):rd?(count=={{(DEPTH_BITS){1'b0}}, 1'b1}):1'b0;
//		fullm1 <= (ncount==MAXM1);
		fullm1 <= ~(up_cnt^rd)?(count==MAXM1):rd?(count==DEPTH):(count==MAXM2);
		emptyp1 <= (ncount=={{(DEPTH_BITS){1'b0}}, 1'b1});
//		emptyp2 <= (ncount>{{(DEPTH_BITS){1'b0}}, 1'b1});
		emptyp2 <= ~(up_cnt^rd)?(count>{{(DEPTH_BITS){1'b0}}, 1'b1}):rd?(count>{{(DEPTH_BITS-1){1'b0}}, 1'b1, 1'b0}):(count>{(DEPTH_BITS+1){1'b0}});
		rptr <= nrptr;
		wptr <= nwptr;
	end

/***************************** PROGRAM BODY ********************************/

always @(`CLK_RST) 
	if (`ACTIVE_RESET)
		wr_f <= 1'b0;
	else 
		wr_f <= wr;
	

/***************************** DIAGNOSTICS *********************************/

// synopsys translate_off 
always @(posedge clk) begin
	if (`INACTIVE_RESET & wr & full) $display("WARNING: %m write when FIFO full", $time);
	if (`INACTIVE_RESET & rd & empty) $display("WARNING: %m read when FIFO empty", $time);
end
// synopsys translate_on

endmodule

