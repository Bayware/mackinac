//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module pu_rf
             ( clk, `RESET_SIG, wr, raddr0, raddr1, waddr, din, dout0, dout1);

parameter WIDTH = 32,
	      DEPTH_NBITS = 5,
	      DEPTH = (16'h1<<DEPTH_NBITS);

output  [WIDTH-1:0] dout0, dout1;

input    clk, `RESET_SIG;  
(* max_fanout = 100 *) input    wr;  
input   [DEPTH_NBITS-1:0] raddr0, raddr1, waddr;
input   [WIDTH-1:0] din;

integer i;

logic  [WIDTH-1:0] dout0, dout1;
logic  [WIDTH-1:0] mem_d[DEPTH-1:0];

always @(posedge clk) begin
	dout0 <= mem_d[raddr0];
	dout1 <= mem_d[raddr1];
end

always @(`CLK_RST) 
	if (`ACTIVE_RESET) 
	    for (i=0; i<DEPTH; i=i+1)
		    case(i)
			    8: mem_d[i] <= `CONNECTION_CONTEXT_BASE;
			    9: mem_d[i] <= `SWITCH_INFO_BASE;
			    10: mem_d[i] <= `INST_BASE;
			    11: mem_d[i] <= `META_BASE;
			    12: mem_d[i] <= `TOPIC_MEM_BASE;
			    13: mem_d[i] <= `FLOW_MEM_BASE;
			    14: mem_d[i] <= `PD_BASE;
			    15: mem_d[i] <= `SCRATCH_BASE;
			    16: mem_d[i] <= `REGISTERS_BASE;
			    17: mem_d[i] <= `TAG_LOOKUP_REQ_MEM_BASE;
			    18: mem_d[i] <= `TAG_LOOKUP_RESULT_MEM_BASE;
			    31: mem_d[i] <= `RAS_BASE;
			    default: mem_d[i] <= 0;
		    endcase
	else
	    for (i=0; i<DEPTH; i=i+1)
	    	if(wr&waddr==i)
			    mem_d[i] <= din;
	    	else
			    mem_d[i] <= mem_d[i];


endmodule            
