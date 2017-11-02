/*
 * Path Parser state machine
 */

`include "defines.vh"

module pp_sm
  (
   input      hop_fifo_reset0,
   input      hop_fifo_wr0,
   input [`HOP_INFO_RANGE] hop_fifo_wdata0,
   input      hop_fifo_eop0,
   input      hop_fifo_reset1,
   input      hop_fifo_wr1,
   input [`HOP_INFO_RANGE] hop_fifo_wdata1,
   input      hop_fifo_eop1,

   input      pp_meta_valid,
   input [`PP_META_RCI_RANGE] pp_meta_rci,

   input      pu_pp_hop_ready,

   output     hop_fifo_full0,
   output     hop_fifo_fullm10,
   output     hop_fifo_full1,
   output     hop_fifo_fullm11,
   output     logic parse_done0,
   output     logic parse_done1,

   output     pp_pu_hop_valid,
   output [`HOP_INFO_RANGE] pp_pu_hop_data,
   output     pp_pu_hop_sop,
   output     pp_pu_hop_eop,
   output     pp_pu_hop_error,

   input      clk,
   input      `RESET_SIG
   );

localparam FIFO_DEPTH_NBITS   = 2;

localparam NULL   = 3'b000;
localparam START_PROCESS   = 3'b001;
localparam END_PROCESS   = 3'b101;
localparam START_THREAD   = 3'b010;
localparam END_THREAD   = 3'b110;
localparam START_END_THREAD   = 3'b100;
localparam START_PROCESS_THREAD   = 3'b011;
localparam END_THREAD_PROCESS = 3'b111;

typedef enum {
PREV_START,
FIND_END_PROCESS,
CUR_START,
FIND_END_PROCESS1,
FIND_RCI_MATCH,
NXT_START,
FIND_LIST} state_t;
   
state_t c_st, n_st;
logic inc_rptr;
logic rptr;
logic hop_fifo_rd;
logic reset_process_lev;
logic inc_process_lev;
logic dec_process_lev;
logic [`PROC_LEV_RANGE] process_lev;
logic reset_thread_lev;
logic set_thread_lev;
logic thread_lev;

logic pp_pu_fifo_wr;
logic pp_pu_fifo_error;
logic pp_pu_fifo_sop;
logic pp_pu_fifo_eop;

logic pp_pu_fifo_empty;

wire hop_fifo_rd0 = hop_fifo_rd&~rptr;
logic hop_fifo_empty0;
logic [FIFO_DEPTH_NBITS:0] hop_fifo_count0;
logic [`HOP_INFO_RANGE] hop_fifo_rdata0;
wire hop_fifo_rd1 = hop_fifo_rd&rptr;
logic hop_fifo_empty1;
logic [FIFO_DEPTH_NBITS:0] hop_fifo_count1;
logic [`HOP_INFO_RANGE] hop_fifo_rdata1;

wire hop_fifo_reop0;
wire hop_fifo_reop1;

wire hop_fifo_empty = rptr?hop_fifo_empty1:hop_fifo_empty0;
wire hop_fifo_reop = rptr?hop_fifo_reop1:hop_fifo_reop0;
wire [`HOP_INFO_RANGE] hop_fifo_rdata = rptr?hop_fifo_rdata1:hop_fifo_rdata0;
wire [`HOP_INFO_TYPE_RANGE] hop_fifo_type = hop_fifo_rdata[`HOP_INFO_TYPE];
wire [`HOP_INFO_RCI_RANGE] hop_fifo_rci = hop_fifo_rdata[`HOP_INFO_RCI];
wire [`HOP_INFO_BYTE_POINTER_RANGE] hop_fifo_byte_pointer = hop_fifo_rdata[`HOP_INFO_BYTE_POINTER];
wire dummy_hop = hop_fifo_rci==0;
wire dynamic_hop = hop_fifo_rci==1;
wire initial_hop = hop_fifo_byte_pointer==`INITIAL_HOP;

logic [`HOP_INFO_BYTE_POINTER_RANGE] prev_hop_pointer;

logic [`HOP_INFO_RANGE] mhop_fifo_rdata;
always @* begin
	mhop_fifo_rdata = hop_fifo_rdata;
	if(dynamic_hop)
		mhop_fifo_rdata[`HOP_INFO_BYTE_POINTER] = prev_hop_pointer;
end

logic [`PP_META_RCI_RANGE] pp_meta_fifo_rci;

wire pp_meta_fifo_rd = parse_done0|parse_done1;

logic load_prev_hop_pointer;

wire rci_match = (hop_fifo_rci==pp_meta_fifo_rci)|dynamic_hop;

/**************************************************************************/
assign pp_pu_hop_valid = ~pp_pu_fifo_empty;

/**************************************************************************/
always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	parse_done0 <= 1'b0;
	parse_done1 <= 1'b0;
    end else begin
	parse_done0 <= inc_rptr&~rptr;
	parse_done1 <= inc_rptr&rptr;
    end

/**************************************************************************/
always @(*) begin
  n_st = c_st;
  load_prev_hop_pointer = 1'b0;
  inc_rptr = 1'b0;
  reset_process_lev = 1'b0;
  inc_process_lev = 1'b0;
  dec_process_lev = 1'b0;
  set_thread_lev = 1'b0;
  reset_thread_lev = 1'b0;
  hop_fifo_rd = 1'b0;
  pp_pu_fifo_wr = 1'b0;
  pp_pu_fifo_sop = 1'b0;
  pp_pu_fifo_eop = 1'b0;
  pp_pu_fifo_error = 1'b0;

  case (c_st)
    PREV_START: 
      if(~hop_fifo_empty) begin
  	load_prev_hop_pointer = 1'b1;
        if(initial_hop) n_st = CUR_START;
	else begin
          hop_fifo_rd = 1'b1;
          case (hop_fifo_type)
            START_PROCESS, END_THREAD, START_END_THREAD: begin
              n_st = FIND_END_PROCESS;
            end
            default: begin
              n_st = CUR_START;
            end
          endcase
	end
      end
    FIND_END_PROCESS: 
      if(~hop_fifo_empty) begin
        hop_fifo_rd = 1'b1;
        case (hop_fifo_type)
          START_PROCESS, START_PROCESS_THREAD: 
            inc_process_lev = 1'b1;
          END_PROCESS, END_THREAD_PROCESS: 
            if(process_lev=={(`PROC_LEV_NBITS){1'b0}}) 
              n_st = CUR_START;
	    else 
              dec_process_lev = 1'b1;
        endcase
      end
    CUR_START: 
      if(~hop_fifo_empty) begin
        hop_fifo_rd = 1'b1;
	if (dummy_hop)
          case (hop_fifo_type)
            END_THREAD: 
              n_st = FIND_END_PROCESS;
	    default: n_st = CUR_START;
	  endcase
        else
          case (hop_fifo_type)
            START_PROCESS_THREAD: begin
              	inc_process_lev = 1'b1;
        	if(rci_match) begin
          		n_st = NXT_START;
          		pp_pu_fifo_wr = 1'b1;
  			pp_pu_fifo_sop = 1'b1;
		end else begin 
              		n_st = FIND_RCI_MATCH;
      		end
            end
            START_PROCESS: begin
        	if(rci_match) begin
          		n_st = FIND_END_PROCESS1;
          		pp_pu_fifo_wr = 1'b1;
  			pp_pu_fifo_sop = 1'b1;
		end else begin 
              		inc_process_lev = 1'b1;
              		n_st = FIND_RCI_MATCH;
      		end
            end
            START_END_THREAD, END_THREAD: begin
              pp_pu_fifo_wr = 1'b1;
              pp_pu_fifo_sop = 1'b1;
              if(~rci_match) begin
              	n_st = PREV_START;
              	reset_process_lev = 1'b1;
              	inc_rptr = 1'b1;
                pp_pu_fifo_error = 1'b1;
              	pp_pu_fifo_eop = 1'b1;
	      end else if(hop_fifo_reop) begin
              	n_st = PREV_START;
              	reset_process_lev = 1'b1;
              	inc_rptr = 1'b1;
              	pp_pu_fifo_eop = 1'b1;
	      end else
              	n_st = FIND_END_PROCESS1;
            end
            default: begin
                pp_pu_fifo_wr = 1'b1;
                pp_pu_fifo_sop = 1'b1;
              if(~rci_match) begin
              	n_st = PREV_START;
              	reset_process_lev = 1'b1;
              	inc_rptr = 1'b1;
                pp_pu_fifo_error = 1'b1;
              	pp_pu_fifo_eop = 1'b1;
	      end else begin
                n_st = NXT_START;
	      end 
            end
          endcase
      end
    FIND_END_PROCESS1: 
      if(~hop_fifo_empty) begin
        hop_fifo_rd = 1'b1;
        case (hop_fifo_type)
          START_PROCESS, START_PROCESS_THREAD: 
            inc_process_lev = 1'b1;
          END_PROCESS, END_THREAD_PROCESS: 
            if(process_lev=={(`PROC_LEV_NBITS){1'b0}}) 
              n_st = NXT_START;
	    else 
              dec_process_lev = 1'b1;
        endcase
      end
    FIND_RCI_MATCH: 
      if(~hop_fifo_empty) begin
        hop_fifo_rd = 1'b1;
        if(process_lev==1&&rci_match) begin
          	pp_pu_fifo_wr = 1'b1;
  	  	pp_pu_fifo_sop = 1'b1;
          case (hop_fifo_type)
	    START_END_THREAD: begin
                reset_process_lev = 1'b1;
		n_st = FIND_END_PROCESS1;
  	    end
	    default: begin
          	n_st = NXT_START;
  	    end
          endcase
  	end else if (hop_fifo_reop) begin
                n_st = PREV_START;
                reset_process_lev = 1'b1;
                inc_rptr = 1'b1;
                pp_pu_fifo_wr = 1'b1;
                pp_pu_fifo_eop = 1'b1;
                pp_pu_fifo_error = 1'b1;
        end else 
          case (hop_fifo_type)
            END_PROCESS, END_THREAD_PROCESS: 
              if(process_lev=={(`PROC_LEV_NBITS){1'b0}}) begin
                n_st = PREV_START;
                reset_process_lev = 1'b1;
                inc_rptr = 1'b1;
                pp_pu_fifo_wr = 1'b1;
                pp_pu_fifo_eop = 1'b1;
                pp_pu_fifo_error = 1'b1;
                // synopsys translate_off
                $display("%t END_PROCESS or END_THREAD_PROCESS encountered when process_lev==0", $time);
                // synopsys translate_on
	      end else 
                dec_process_lev = 1'b1;
            START_PROCESS, START_PROCESS_THREAD: 
              inc_process_lev = 1'b1;
          endcase
      end
    NXT_START: 
      if(~hop_fifo_empty)
	if(dummy_hop) begin
          hop_fifo_rd = 1'b1;
          case (hop_fifo_type)
            END_THREAD: 
	    	if (~hop_fifo_reop) begin
              			reset_process_lev = 1'b1;
              			n_st = FIND_END_PROCESS1;
		end else begin
              			n_st = PREV_START;
              			reset_process_lev = 1'b1;
              			inc_rptr = 1'b1;
              			pp_pu_fifo_wr = 1'b1;
              			pp_pu_fifo_eop = 1'b1;
      		end
            default: 
              n_st = NXT_START;
          endcase
  	end else begin
          hop_fifo_rd = 1'b1;
          pp_pu_fifo_wr = 1'b1;
          case (hop_fifo_type)
            START_PROCESS: begin
              n_st = FIND_LIST;
              reset_process_lev = 1'b1;
              reset_thread_lev = 1'b1;
            end
            START_PROCESS_THREAD: begin
              n_st = FIND_LIST;
              reset_process_lev = 1'b1;
              set_thread_lev = 1'b1;
            end
            default: begin
              n_st = PREV_START;
              reset_process_lev = 1'b1;
              inc_rptr = 1'b1;
              pp_pu_fifo_eop = 1'b1;
            end
          endcase
        end
    FIND_LIST: 
      if(~hop_fifo_empty) begin
        hop_fifo_rd = 1'b1;
        case (hop_fifo_type)
          START_PROCESS, START_PROCESS_THREAD: 
            inc_process_lev = 1'b1;
          END_THREAD_PROCESS: 
            if(process_lev==0) begin
              n_st = PREV_START;
              reset_process_lev = 1'b1;
              inc_rptr = 1'b1;
              pp_pu_fifo_wr = 1'b1;
              pp_pu_fifo_eop = 1'b1;
            end else 
              dec_process_lev = 1'b1;
          END_PROCESS: 
            if(process_lev=={(`PROC_LEV_NBITS){1'b0}}) begin
              n_st = PREV_START;
              reset_process_lev = 1'b1;
              inc_rptr = 1'b1;
              pp_pu_fifo_wr = 1'b1;
              pp_pu_fifo_eop = 1'b1;
            end else 
              dec_process_lev = 1'b1;
          NULL: 
            pp_pu_fifo_wr = (process_lev=={(`PROC_LEV_NBITS){1'b0}})&&(thread_lev==1'b0);
          END_THREAD: 
            reset_thread_lev = (process_lev=={(`PROC_LEV_NBITS){1'b0}});
          START_THREAD: 
            if(process_lev=={(`PROC_LEV_NBITS){1'b0}}&&dummy_hop) begin
              n_st = PREV_START;
              reset_process_lev = 1'b1;
              inc_rptr = 1'b1;
              pp_pu_fifo_wr = 1'b1;
              pp_pu_fifo_eop = 1'b1;
              pp_pu_fifo_error = 1'b1;
              // synopsys translate_off
              $display("%t START_THREAD dummy_hop not supported", $time);
              // synopsys translate_on
            end else if(process_lev=={(`PROC_LEV_NBITS){1'b0}}) begin
              set_thread_lev = 1'b1;
              pp_pu_fifo_wr = 1'b1;
	    end
          START_END_THREAD: 
            if(process_lev=={(`PROC_LEV_NBITS){1'b0}}) begin
              pp_pu_fifo_wr = 1'b1;
	    end
        endcase
      end
  endcase
end

always @(posedge clk) 
	prev_hop_pointer <= load_prev_hop_pointer?hop_fifo_byte_pointer:prev_hop_pointer;

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	rptr <= 1'b0;
	process_lev <= {(`PROC_LEV_NBITS){1'b0}};
	thread_lev <= 1'b0;
	c_st <= PREV_START;
    end else begin
	rptr <= rptr+inc_rptr;
	process_lev <= reset_process_lev?{(`PROC_LEV_NBITS){1'b0}}:inc_process_lev?process_lev+1'b1:dec_process_lev?process_lev-1'b1:process_lev;
	thread_lev <= set_thread_lev?1'b1:reset_thread_lev?1'b0:thread_lev;
	c_st <= n_st;
    end

/***************************** FIFO ***************************************/

sfifo2f_fo #(1+`HOP_INFO_NBITS, FIFO_DEPTH_NBITS) u_sfifo2f_fo0(
        .clk(clk),
        .`RESET_SIG(`COMBINE_RESET(hop_fifo_reset0)),

        .din({hop_fifo_eop0, hop_fifo_wdata0}),              
        .rd(hop_fifo_rd0),
        .wr(hop_fifo_wr0),

        .ncount(),
        .count(hop_fifo_count0),
        .full(hop_fifo_full0),
        .empty(hop_fifo_empty0),
        .fullm1(hop_fifo_fullm10),
        .emptyp2(),
        .dout({hop_fifo_reop0, hop_fifo_rdata0})       
    );

sfifo2f_fo #(1+`HOP_INFO_NBITS, FIFO_DEPTH_NBITS) u_sfifo2f_fo1(
        .clk(clk),
        .`RESET_SIG(`COMBINE_RESET(hop_fifo_reset1)),

        .din({hop_fifo_eop1, hop_fifo_wdata1}),              
        .rd(hop_fifo_rd1),
        .wr(hop_fifo_wr1),

        .ncount(),
        .count(hop_fifo_count1),
        .full(hop_fifo_full1),
        .empty(hop_fifo_empty1),
        .fullm1(hop_fifo_fullm11),
        .emptyp2(),
        .dout({hop_fifo_reop1, hop_fifo_rdata1})       
    );

sfifo2f_fo #(`PP_META_RCI_NBITS, FIFO_DEPTH_NBITS) u_sfifo2f_fo2(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din(pp_meta_rci),              
        .rd(pp_meta_fifo_rd),
        .wr(pp_meta_valid),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout(pp_meta_fifo_rci)       
    );

logic p_pp_pu_fifo_empty;
logic p_pp_pu_fifo_sop;
logic p_pp_pu_fifo_eop;
logic [`HOP_INFO_RANGE] p_pp_pu_hop_data;

logic pp_pu_pkt_fifo_empty;
logic p_pp_pu_fifo_error;

wire p_pp_pu_fifo_rd  = ~p_pp_pu_fifo_empty&~pp_pu_pkt_fifo_empty;
wire fifo_wr = p_pp_pu_fifo_rd&(p_pp_pu_fifo_eop|~p_pp_pu_fifo_error);
wire fifo_sop = p_pp_pu_fifo_sop|p_pp_pu_fifo_error;

sfifo2f_fo #(1+1+`HOP_INFO_NBITS, `PP_PU_FIFO_DEPTH_NBITS) u_sfifo2f_fo3(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({pp_pu_fifo_sop, pp_pu_fifo_eop, mhop_fifo_rdata}),              
        .rd(p_pp_pu_fifo_rd),
        .wr(pp_pu_fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(p_pp_pu_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({p_pp_pu_fifo_sop, p_pp_pu_fifo_eop, p_pp_pu_hop_data})       
    );

sfifo2f_fo #(1, 2) u_sfifo2f_fo4(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({pp_pu_fifo_error}),              
        .rd(p_pp_pu_fifo_rd&p_pp_pu_fifo_eop),
        .wr(pp_pu_fifo_wr&pp_pu_fifo_eop),

        .ncount(),
        .count(),
        .full(),
        .empty(pp_pu_pkt_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({p_pp_pu_fifo_error})       
    );

sfifo2f_fo #(1+1+1+`HOP_INFO_NBITS, `PP_PU_FIFO_DEPTH_NBITS) u_sfifo2f_fo5(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({fifo_sop, p_pp_pu_fifo_eop, p_pp_pu_hop_data, p_pp_pu_fifo_error}),              
        .rd(pp_pu_hop_valid&pu_pp_hop_ready),
        .wr(fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(pp_pu_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({pp_pu_hop_sop, pp_pu_hop_eop, pp_pu_hop_data, pp_pu_hop_error})       
    );

endmodule 
