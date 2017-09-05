/*
 * Path Parser Read Control
 */

`include "defines.vh"

module pp_rd_ctrl
  (
   input      pp_valid,
   input pp_eop,
   input [1:0] pp_id,

   input rd_ptr,

   input hop_fifo_full,
   input hop_fifo_fullm1,
   input     parser_done,
   input [`DATA_PATH_RANGE] ram_rdata,

   output reg path_parser_ready,

   output reg ram_rd,
   output reg [`PATH_CHUNK_ADDR_RANGE] ram_raddr,

   output reg hop_fifo_reset,
   output reg hop_fifo_wr,
   output reg [`HOP_INFO_RANGE] hop_fifo_wdata,
   
   input      clk,
   input      `RESET_SIG
   );

parameter PP_ID   = 0;
parameter PTR_ID   = 0;

localparam INSTRUCTION   = 3'b100;

typedef enum {
IDLE, WRITE, WAIT_4_RAM, GET_PREV_PTR, GO_TO_PREV_HOP, WAIT_4_RAM1, WAIT_4_RAM2, WAIT_4_RAM3, GET_HOP
} state_t;

state_t c_st, n_st;
reg n_hop_fifo_wr;
reg [`HOP_INFO_RANGE] n_hop_fifo_wdata;
reg [`PATH_CHUNK_ADDR_RANGE] n_ram_raddr;
reg n_hop_fifo_reset;
reg set_path_parser_ready;
reg reset_path_parser_ready;
reg n_ram_rd;
reg ram_rd_d1;
reg get_prev;
reg shift_1byte;
reg shift_2byte;
reg shift_4byte;
reg shift_8byte;
reg [15:0] prev_hop_ptr;
reg [15:0] exec;
reg [15:0] hop_ptr;
reg [15:0] n_hop_ptr;
reg [`DATA_PATH_RANGE] hop_data;
reg initial_flag;
reg set_initial_flag;
reg reset_initial_flag;
reg prev_flag;
reg set_prev_flag;
reg reset_prev_flag;
reg shift_2byte_more;
reg set_shift_2byte_more;
reg reset_shift_2byte_more;

wire selected = (rd_ptr==PTR_ID)&&(pp_id==PP_ID);
wire [2:0] hop_type = hop_data[`DATA_PATH_NBITS-1:`DATA_PATH_NBITS-1-2];
wire ins_type = hop_type==INSTRUCTION;

/**************************************************************************/
always @(posedge clk) begin
        hop_fifo_wdata <= n_hop_fifo_wdata;
        ram_raddr <= n_ram_raddr;
end
always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	path_parser_ready <= 1'b1;
        hop_fifo_reset <= 1'b0;
        hop_fifo_wr <= 1'b0;
        ram_rd <= 1'b0;
    end else begin
	path_parser_ready <= set_path_parser_ready?1'b1:reset_path_parser_ready?1'b0:path_parser_ready;
        hop_fifo_reset <= n_hop_fifo_reset;
        hop_fifo_wr <= n_hop_fifo_wr;
        ram_rd <= n_ram_rd;
    end

/**************************************************************************/
always @(*) begin
  n_st = c_st;
  set_path_parser_ready = 1'b0;
  reset_path_parser_ready = 1'b0;
  n_hop_fifo_reset = 1'b0;
  n_hop_fifo_wr = 1'b0;
  n_hop_fifo_wdata = hop_fifo_wdata;
  n_ram_rd = 1'b0;
  n_ram_raddr = ram_raddr;
  get_prev = 1'b0;
  shift_1byte = 1'b0;
  shift_2byte = 1'b0;
  shift_4byte = 1'b0;
  shift_8byte = 1'b0;
  set_shift_2byte_more = 1'b0;
  reset_shift_2byte_more = 1'b0;
  n_hop_ptr = hop_ptr;
  set_prev_flag = 1'b0;
  reset_prev_flag = 1'b0;
  set_initial_flag = 1'b0;
  reset_initial_flag = 1'b0;

  case(c_st)
    IDLE: 
      if(selected&pp_valid) begin
        n_st = WRITE;
        reset_path_parser_ready = 1'b1;
      end
    WRITE: 
      if(selected&pp_valid&pp_eop) begin
        n_st = WAIT_4_RAM;
        n_ram_rd = 1'b1;
        n_ram_raddr = {(`PATH_CHUNK_DEPTH_NBITS+1){1'b0}}; 
        n_hop_ptr = 15;
      end
    WAIT_4_RAM: 
        n_st = GET_PREV_PTR;
    GET_PREV_PTR: begin
        n_st = GO_TO_PREV_HOP;
        get_prev = 1'b1;
    end  
    GO_TO_PREV_HOP: 
      if(prev_hop_ptr==`INITIAL_HOP) begin
        n_st = WAIT_4_RAM2;
        n_hop_fifo_wr = 1'b1;
        n_hop_fifo_wdata = {prev_hop_ptr, hop_data[`DATA_PATH_NBITS-1:`DATA_PATH_NBITS-1-31]};
        set_initial_flag = 1'b1;
      end else if(prev_hop_ptr>hop_ptr) begin
        n_ram_rd = 1'b1;
        n_ram_raddr = ram_raddr+1'b1;
        n_hop_ptr = hop_ptr+16;
      end else begin
        n_st = WAIT_4_RAM2;
        set_prev_flag = 1'b1;
      end
    WAIT_4_RAM1: 
        n_st = WAIT_4_RAM2;
    WAIT_4_RAM2: 
        n_st = WAIT_4_RAM3;
    WAIT_4_RAM3: begin 
        n_st = GET_HOP;
        if (initial_flag) begin
          n_hop_ptr = 4;
          shift_4byte = 1'b1;
          reset_initial_flag <= 1'b1;
        end else if (prev_flag) begin
          n_hop_ptr = prev_hop_ptr;
          {shift_8byte, shift_4byte, shift_2byte, shift_1byte} = prev_hop_ptr[3:0];
          reset_prev_flag = 1'b1;
        end else if (shift_2byte_more) begin
          shift_2byte = 1'b1;
          reset_shift_2byte_more <= 1'b1;
        end
    end
    GET_HOP: 
      if(parser_done) begin
        n_st = IDLE;
        set_path_parser_ready = 1'b1;
        n_hop_fifo_reset = 1'b1;
      end else if (~hop_fifo_full&(hop_fifo_wr&~hop_fifo_fullm1)) begin
        n_hop_fifo_wr = 1'b1;
        if (ins_type) begin
          n_hop_fifo_wdata = {hop_ptr, hop_data[`DATA_PATH_NBITS-1:`DATA_PATH_NBITS-1-31]};
          shift_4byte = 1'b1;
          n_hop_ptr = hop_ptr+4;
          if (hop_ptr[3:0]>11) begin
            n_ram_rd = 1'b1;
            n_ram_raddr = ram_raddr+1'b1;
            n_st = WAIT_4_RAM1;
            if (hop_ptr[3:0]>13) set_shift_2byte_more = 1'b1;
          end
        end else begin
          n_hop_fifo_wdata = {hop_ptr, exec, hop_data[`DATA_PATH_NBITS-1:`DATA_PATH_NBITS-1-15]};
          shift_2byte = 1'b1;
          n_hop_ptr = hop_ptr+2;
          if (hop_ptr[3:0]>13) begin
            n_ram_rd = 1'b1;
            n_ram_raddr = ram_raddr+1'b1;
            n_st = WAIT_4_RAM1;
          end
        end 
      end 
  endcase
end

always @(posedge clk) begin
  ram_rd_d1 <= ram_rd;
  {prev_hop_ptr, exec} <= get_prev?ram_rdata:{prev_hop_ptr, exec};
  hop_ptr <= n_hop_ptr;
  hop_data <= ram_rd_d1?ram_rdata:shift(hop_data, {shift_8byte, shift_4byte, shift_2byte, shift_1byte});
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
      initial_flag <= 1'b1;
      prev_flag <= 1'b1;
      shift_2byte_more <= 1'b0;
      c_st <= IDLE;
    end else begin
      initial_flag <= set_initial_flag?1'b1:reset_initial_flag?1'b0:initial_flag;
      prev_flag <= set_prev_flag?1'b1:reset_prev_flag?1'b0:prev_flag;
      shift_2byte_more <= set_shift_2byte_more?1'b1:reset_shift_2byte_more?1'b0:shift_2byte_more;
      c_st <= n_st;
    end

/**************************************************************************/
   
function shift;
input [`DATA_PATH_RANGE] data_in;
input [3:0] s_cnt;
reg [`DATA_PATH_RANGE] data3, data2, data1;
  data3 = s_cnt[3]?{data_in[`DATA_PATH_NBITS-1-8*8:0], {(8*8){1'b0}}}:data_in;
  data2 = s_cnt[2]?{data3[`DATA_PATH_NBITS-1-8*4:0], {(8*4){1'b0}}}:data3;
  data1 = s_cnt[1]?{data2[`DATA_PATH_NBITS-1-8*2:0], {(8*2){1'b0}}}:data2;
  shift = s_cnt[0]?{data1[`DATA_PATH_NBITS-1-8*1:0], {(8*1){1'b0}}}:data1;
  
endfunction

endmodule 
