//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module pu_alu #(
parameter IN_WIDTH = `PU_WIDTH_NBITS,
parameter RF_WIDTH = 32,
parameter OUT_WIDTH = `PU_WIDTH_NBITS
) ( 
	input use_imm,
	input [IN_WIDTH-1:0] imm, 
	input [RF_WIDTH-1:0] rs1, rs2, 
	input [2:0] funct3,
	input [4:0] funct5,
	output logic [OUT_WIDTH-1:0] alu
);

logic [RF_WIDTH-1:0] in_a = rs1;
logic [RF_WIDTH-1:0] in_b = use_imm?imm:rs2;

logic [2:0] f3 = funct3;
logic f5_3 = funct5[3];

always @(*) 
	case (f3)
		3'b000: begin
			alu = in_a + (f5_3?~in_b+1:in_b);
		end
		3'b001: begin
			alu = in_a << in_b;
		end
		3'b010: begin
			alu = ($signed(in_a) < $signed(in_b))?1:0;
		end
		3'b011: begin
			alu = in_a < in_b?1:0;
		end
		3'b100: begin
			alu = in_a ^ in_b;
		end
		3'b101: begin
			alu = (f5_3?{{(RF_WIDTH){in_a[RF_WIDTH-1]}}, in_a}:in_a) >> in_b;
		end
		3'b110: begin
			alu = in_a | in_b;
		end
		3'b111: begin
			alu = in_a & in_b;
		end
	endcase

endmodule            
