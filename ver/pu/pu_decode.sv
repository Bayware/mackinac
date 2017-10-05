//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import type_package::*;

module pu_decode #(
parameter IN_WIDTH = 32
) (

	input [IN_WIDTH-1:0] inst, 

	output dec_type dec_cmd 

);

logic [4:0] opcode;

always @(*) begin
	opcode = inst[6:2];
	dec_cmd.rs1 = inst[19:15];
	dec_cmd.rs2 = inst[24:20];
	dec_cmd.rd = inst[11:7];
	dec_cmd.funct3 = inst[14:12];
	dec_cmd.funct7 = inst[31:25];
	dec_cmd.funct5 = inst[31:27];
	dec_cmd.aq = inst[26];
	dec_cmd.rl = inst[25];
	dec_cmd.imm = 0;
	dec_cmd.op = 1'b0;
	dec_cmd.opi = 1'b0;
	dec_cmd.jalr = 1'b0;
	dec_cmd.jal = 1'b0;
	dec_cmd.branch = 1'b0;
	dec_cmd.lui = 1'b0;
	dec_cmd.auipc = 1'b0;
	dec_cmd.store = 1'b0;
	dec_cmd.load = 1'b0;
	dec_cmd.atomic = 1'b0;
	dec_cmd.end_program = 1'b0;
	dec_cmd.use_imm = 1'b0;
	dec_cmd.take_branch = 1'b0;
	case (opcode)
		5'b01100: begin // R
			dec_cmd.op = 1'b1;
		end
		5'b01011: begin // R
			dec_cmd.atomic = dec_cmd.funct3==3'b010;
		end
		5'b00000: begin 
			dec_cmd.imm = {{(21){inst[31]}}, inst[30:20]}; // I
			dec_cmd.load = 1'b1;
			dec_cmd.use_imm = 1'b1;
		end
		5'b00100: begin
			dec_cmd.imm = {{(21){inst[31]}}, inst[30:20]}; // I
			dec_cmd.opi = 1'b1;
			dec_cmd.use_imm = 1'b1;
		end
		5'b11001: begin
			dec_cmd.imm = {{(21){inst[31]}}, inst[30:20]}; // I
			dec_cmd.jalr = 1'b1; // rd=x0, no write back, pc+4
			dec_cmd.use_imm = 1'b1;
		end
		5'b01000: begin
			dec_cmd.imm = {{(21){inst[31]}}, inst[30:25], inst[11:7]}; // S
			dec_cmd.store = 1'b1;
			dec_cmd.use_imm = 1'b1;
		end
		5'b11000: begin
			dec_cmd.imm = {{(20){inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0}; // B
			dec_cmd.branch = 1'b1;
			dec_cmd.use_imm = 1'b1;
			case (inst[14:12])
				3'b000: begin
					dec_cmd.funct3 = 3'b000;
					dec_cmd.funct5 = 5'b01000;
					dec_cmd.take_branch = 1'b1;
				end
				3'b001: begin
					dec_cmd.funct3 = 3'b000;
					dec_cmd.funct5 = 5'b01000;
				end
				3'b100: begin
					dec_cmd.funct3 = 3'b010;
				end
				3'b101: begin
					dec_cmd.funct3 = 3'b010;
					dec_cmd.take_branch = 1'b1;
				end
				3'b110: begin
					dec_cmd.funct3 = 3'b011;
				end
				3'b111: begin
					dec_cmd.funct3 = 3'b011;
					dec_cmd.take_branch = 1'b1;
				end
			endcase
		end
		5'b01101: begin
			dec_cmd.imm = {inst[31:12], 12'b0}; // U
			dec_cmd.lui = 1'b1;
			dec_cmd.use_imm = 1'b1;
		end
		5'b00101: begin
			dec_cmd.imm = {inst[31:12], 12'b0}; // U
			dec_cmd.auipc = 1'b1;
			dec_cmd.use_imm = 1'b1;
		end
		5'b11011: begin
			dec_cmd.imm = {{(12){inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0}; // UJ
			dec_cmd.jal = 1'b1; // rd=x0, no write back
			dec_cmd.use_imm = 1'b1;
		end
		5'b11100: begin
			dec_cmd.end_program = 1'b1;
		end
	endcase
end

endmodule            
