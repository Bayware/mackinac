//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module edit_mem_write_data #(
parameter BPTR_NBITS = `EM_BUF_PTR_NBITS,
parameter ID_NBITS = `PU_ID_NBITS,
parameter DATA_NBITS = `DATA_PATH_NBITS,
parameter LEN_NBITS = `PD_CHUNK_NBITS
) (
    input clk,
    input `RESET_SIG,

    input pu_em_data_valid,    
    input pu_em_sop,            
    input pu_em_eop,            
    input [DATA_NBITS-1:0] pu_em_packet_data,
    input [ID_NBITS-1:0] pu_em_port_id,        

    input pu_buf_valid, 
    input [BPTR_NBITS-1:0] pu_buf_ptr,    
    input pu_buf_available,  

    // outputs

    output logic         em_asa_valid,
    output logic [BPTR_NBITS-1:0] em_asa_buf_ptr,				
    output logic [`PU_ID_NBITS-1:0] em_asa_pu_id,				
    output logic [LEN_NBITS-1:0] em_asa_len,				
    output logic         em_asa_discard,

    output logic enq_buf_valid,
    output logic [BPTR_NBITS-1:0] enq_buf_ptr_cur,
    output logic [BPTR_NBITS-1:0] enq_buf_ptr_nxt,

    output logic pu_buf_req, 

    output logic pu_data_valid, 
    output logic [BPTR_NBITS-1:0] pu_data_buf_ptr,
    output logic [DATA_NBITS-1:0] pu_data

);


/***************************** LOCAL VARIABLES *******************************/

localparam PREFETCH_FIFO_DEPTH_NBITS = 4;
localparam PREFETCH_FIFO_NEAR_FULL = (1<<PREFETCH_FIFO_DEPTH_NBITS)-2;

logic [LEN_NBITS-1:0] len[`NUM_OF_PU-1:0];
logic [BPTR_NBITS-1:0] first_pu_buf_ptr_saved[`NUM_OF_PU-1:0];
logic [BPTR_NBITS-1:0] pu_buf_ptr_saved[`NUM_OF_PU-1:0];
logic [`NUM_OF_PU-1:0] discard_saved;
logic [`NUM_OF_PU-1:0] sop_discard_saved;

logic pu_buf_valid_d1; 
logic pu_buf_available_d1;  

logic pu_em_data_valid_d1;
logic pu_em_sop_d1;            
logic pu_em_eop_d1;            
logic [DATA_NBITS-1:0] pu_em_packet_data_d1;
logic [ID_NBITS-1:0] pu_em_port_id_d1;


integer i;

logic [BPTR_NBITS-1:0] prefetch_fifo_dout;
logic prefetch_fifo_empty;
logic [PREFETCH_FIFO_DEPTH_NBITS:0] prefetch_fifo_count;

wire pu_buf_req_p1 = prefetch_fifo_count<PREFETCH_FIFO_NEAR_FULL;

wire pu_data_valid_p1 = pu_em_data_valid_d1&~prefetch_fifo_empty&~discard_saved[pu_em_port_id_d1];
wire prefetch_fifo_rd = pu_data_valid_p1;

wire inc_prefetch_fifo = pu_buf_req_p1;
wire dec_prefetch_fifo = pu_buf_valid_d1&~pu_buf_available_d1;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
        pu_data_buf_ptr <= prefetch_fifo_dout;
        pu_data <= pu_em_packet_data_d1;

        em_asa_pu_id <= pu_em_port_id_d1;
        em_asa_len <= sop_discard_saved[pu_em_port_id_d1]?0:prefetch_fifo_empty?len[pu_em_port_id_d1]:len[pu_em_port_id_d1]+1;
        em_asa_discard <= discard_saved[pu_em_port_id_d1];
        em_asa_buf_ptr <= first_pu_buf_ptr_saved[pu_em_port_id_d1];

        enq_buf_ptr_cur <= pu_buf_ptr_saved[pu_em_port_id_d1];
        enq_buf_ptr_nxt <= prefetch_fifo_dout;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
        pu_buf_req <= 0;
        pu_data_valid <= 0;
        em_asa_valid <= 0;
        enq_buf_valid <= 0;
    end else begin
        pu_buf_req <= pu_buf_req_p1;
        pu_data_valid <= pu_data_valid_p1;
        em_asa_valid <= pu_em_data_valid_d1&pu_em_eop_d1;
        enq_buf_valid <= pu_em_data_valid_d1&~pu_em_sop_d1&~(prefetch_fifo_empty|discard_saved[pu_em_port_id_d1]);
    end

/***************************** PROGRAM BODY **********************************/


always @(posedge clk) begin
        
	pu_buf_available_d1 <= pu_buf_available;

        pu_em_port_id_d1 <= pu_em_port_id;
        pu_em_sop_d1 <= pu_em_sop;

        for (i = 0; i < `NUM_OF_PU; i = i + 1) begin 
            first_pu_buf_ptr_saved[i] <= pu_em_data_valid_d1&(pu_em_port_id_d1==i)&pu_em_sop_d1?prefetch_fifo_dout:pu_buf_ptr_saved[i];
            pu_buf_ptr_saved[i] <= pu_em_data_valid_d1&(pu_em_port_id_d1==i)?prefetch_fifo_dout:pu_buf_ptr_saved[i];
            discard_saved[i] <= pu_em_data_valid_d1&(pu_em_port_id_d1==i)?(pu_em_eop_d1?1'b0:prefetch_fifo_empty|discard_saved[i]):discard_saved[i];
            sop_discard_saved[i] <= pu_em_data_valid_d1&(pu_em_port_id_d1==i)&pu_em_sop_d1&prefetch_fifo_empty?1'b1:pu_em_data_valid_d1&(pu_em_port_id_d1==i)&pu_em_eop_d1?1'b0:sop_discard_saved[i];
        end
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	pu_buf_valid_d1 <= 1'b0;
        pu_em_data_valid_d1 <= 0;
        for (i = 0; i < `NUM_OF_PU; i = i + 1) 
          len[i] <= 0;
        prefetch_fifo_count <= 0;
    end else begin
	pu_buf_valid_d1 <= pu_buf_valid;
        pu_em_data_valid_d1 <= pu_em_data_valid;
        for (i = 0; i < `NUM_OF_PU; i = i + 1) 
          len[i] <= ~pu_em_data_valid_d1&(pu_em_port_id_d1==i)?len[i]:pu_em_eop_d1?0:prefetch_fifo_empty|discard_saved[i]?len[i]:len[i]+1;
	case ({inc_prefetch_fifo, dec_prefetch_fifo, prefetch_fifo_rd})
		3'b000: prefetch_fifo_count <= prefetch_fifo_count;
		3'b001: prefetch_fifo_count <= prefetch_fifo_count-1;
		3'b010: prefetch_fifo_count <= prefetch_fifo_count-1;
		3'b011: prefetch_fifo_count <= prefetch_fifo_count-2;
		3'b100: prefetch_fifo_count <= prefetch_fifo_count+1;
		3'b101: prefetch_fifo_count <= prefetch_fifo_count;
		3'b110: prefetch_fifo_count <= prefetch_fifo_count;
		default: prefetch_fifo_count <= prefetch_fifo_count-1;
	endcase

    end
 
/***************************** FIFO ***************************************/

sfifo2f_fo #(BPTR_NBITS, PREFETCH_FIFO_DEPTH_NBITS) sfifo2f_fo_inst(
    .clk(clk),
    .`RESET_SIG(`RESET_SIG),

    .din(pu_buf_ptr),                
    .rd(prefetch_fifo_rd),
    .wr(pu_buf_valid&pu_buf_available),

    .ncount(),
    .count(),
    .full(),
    .empty(prefetch_fifo_empty),
    .fullm1(),
    .emptyp2(),
    .dout(prefetch_fifo_dout)       
);

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

