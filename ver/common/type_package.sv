//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

package type_package; 

typedef struct { 

	logic [4:0] rs1;
	logic [4:0] rs2;
	logic [4:0] rd;
	logic [2:0] funct3;
	logic [4:0] funct5;
	logic [6:0] funct7;
	logic [31:0] imm;
	logic op;
	logic opi;
	logic jalr;
	logic jal;
	logic branch;
	logic lui;
	logic auipc;
	logic store;
	logic load;
	logic atomic;
	logic aq;
	logic rl;
	logic end_program;
	logic use_imm;
	logic take_branch;
} dec_type; 

typedef struct { 

	logic [2:0] funct3;
	logic load;
	logic atomic;
	logic aq;
	logic rl;
	logic [4:0] funct5;
	logic wb_en;
	logic [4:0] wb_addr;
	logic [31:0] wb_data;
	logic mem_en;
	logic mem_wr;
	logic [`PU_MEM_DEPTH_NBITS-1:0] mem_addr;
	logic [31:0] mem_wdata;
} exec_type; 

typedef struct { 

	logic wb_en;
	logic [4:0] wb_addr;
	logic [31:0] wb_data;
} wb_type; 

typedef struct { 

	logic atomic;
	logic aq;
	logic rl;
	logic [4:0] funct5;
	logic wr;
	logic [`PU_MEM_DEPTH_NBITS-1:0] addr;
	logic [31:0] wdata;
	logic [`TID_NBITS-1:0] tid;
	logic [`FID_NBITS-1:0] fid;
} io_type; 

endpackage
