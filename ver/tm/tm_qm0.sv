//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module tm_qm0 (


input clk, 
input `RESET_SIG, 

input clk_div,

input  [3:0] alpha,

input reg_ms,
input reg_rd,
input reg_wr,
input [`PIO_RANGE] reg_addr,
input [`PIO_RANGE] reg_din,


input asa_tm_poll_req, 
input [`FIRST_LVL_QUEUE_ID_NBITS-1:0] asa_tm_poll_qid,
input [`PORT_ID_NBITS-1:0] asa_tm_poll_src_port,

input asa_tm_enq_req, 
input [`FIRST_LVL_QUEUE_ID_NBITS-1:0] asa_tm_enq_qid,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] asa_tm_enq_conn_id,
input [`THIRD_LVL_QUEUE_ID_NBITS-1:0] asa_tm_enq_conn_group_id,
input [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] asa_tm_enq_port_queue_id,
input sch_pkt_desc_type asa_tm_enq_pkt_desc,

input sch_deq_req, 
input [`FIRST_LVL_QUEUE_ID_NBITS-1:0] sch_deq_qid,

input [`NUM_OF_PORTS-1:0] next_qm_enq_src_available0,	
input [`NUM_OF_PORTS-1:0] next_qm_enq_src_available1,	
input [`NUM_OF_PORTS-1:0] next_qm_enq_src_available2,	


output mem_ack,
output [`PIO_RANGE] mem_rdata,

output reg tm_asa_poll_ack,
output reg tm_asa_poll_drop,
output reg [`SECOND_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_conn_id,
output reg [`THIRD_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_conn_group_id,
output reg [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_port_queue_id,
output reg [`PORT_ID_NBITS-1:0] tm_asa_poll_port_id,

output active_enq_ack,            
output active_enq_to_empty,
output [`PORT_ID_NBITS-1:0] active_enq_ack_dst_port,
output [`FIRST_LVL_QUEUE_ID_NBITS-1:0] active_enq_ack_qid,

output sch_deq_depth_ack,
output sch_deq_depth_from_emptyp2,

output sch_deq_ack,
output [`FIRST_LVL_QUEUE_ID_NBITS-1:0] sch_deq_ack_qid,
output sch_pkt_desc_type sch_deq_pkt_desc
);

/***************************** LOCAL VARIABLES *******************************/
reg asa_tm_poll_req_d1; 
reg [`PORT_ID_NBITS-1:0] asa_tm_poll_src_port_d1;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] asa_tm_poll_qid_d1;

reg [`NUM_OF_PORTS-1:0] next_qm_enq_src_available0_d1;	
reg [`NUM_OF_PORTS-1:0] next_qm_enq_src_available1_d1;	
reg [`NUM_OF_PORTS-1:0] next_qm_enq_src_available2_d1;	

wire [`PORT_ID_NBITS-1:0] fifo_asa_tm_poll_src_port;

wire queue_association_rd; 
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] queue_association_raddr;

wire queue_association_ack; 
wire [`QUEUE_ASSOCIATION_NBITS-1:0] queue_association_rdata;

wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] lat_fifo_qid;

wire poll_association_ack;
wire enq_prop_ack;
wire deq_prop_ack;

wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] association_conn_id;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] association_conn_group_id;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] association_port_queue_id;
wire [`PORT_ID_NBITS-1:0] association_port_id;

wire ll_queue_depth_ack;
wire ll_queue_depth_drop;

wire enq_association_req; 

wire sch_deq_association_req; 
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] sch_deq_association_qid;
wire [`PORT_ID_NBITS-1:0] sch_deq_association_dst_port;

wire queue_depth_ack;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] queue_depth;

wire conn_depth_ack;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] conn_depth;

wire conn_group_depth_ack;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] conn_group_depth;

wire port_queue_depth_ack;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] port_queue_depth;

wire q_poll_ack; 
wire q_poll_drop;

wire conn_poll_ack; 
wire conn_poll_drop;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] conn_poll_qid;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] align_poll_conn_id;

wire conn_group_poll_ack; 
wire conn_group_poll_drop;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] conn_group_poll_qid;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] align_poll_conn_group_id;

wire port_poll_ack; 
wire port_poll_drop;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] port_poll_qid;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] align_poll_port_queue_id;


wire queue_depth_req; 
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] depth_req_queue_id;

wire conn_depth_req; 
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] depth_req_conn_id;

wire conn_group_depth_req; 
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] depth_req_conn_group_id;

wire port_queue_depth_req; 
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] depth_req_port_queue_id;

wire depth_enq_req; 
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] depth_enq_qid;


wire depth_deq_req; 
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] depth_deq_qid;

wire depth_deq_req1; 
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] depth_deq_qid1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] depth_deq_conn_id;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] depth_deq_conn_group_id;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] depth_deq_port_queue_id;

wire depth_enq_ack;         
wire depth_enq_to_empty;

wire depth_deq_ack;
wire depth_deq_from_emptyp2;

wire [`FIRST_LVL_QUEUE_ID_NBITS:0] queue_threshold;

wire [`PORT_ID_NBITS-1:0] f_lat_fifo_port_id;

wire align_fifo_empty0;
wire align_fifo_empty1;
wire align_fifo_empty2;
wire align_fifo_empty3;

wire align_fifo_drop0;
wire align_fifo_drop1;
wire align_fifo_drop2;
wire align_fifo_drop3;

wire align_fifo_rd = ~align_fifo_empty0&~align_fifo_empty1&~align_fifo_empty2&~align_fifo_empty3;
wire align_fifo_drop = align_fifo_drop0|align_fifo_drop1|align_fifo_drop2|align_fifo_drop3|
					 ~next_qm_enq_src_available0_d1[fifo_asa_tm_poll_src_port]|
					 ~next_qm_enq_src_available1_d1[fifo_asa_tm_poll_src_port]|
					 ~next_qm_enq_src_available2_d1[fifo_asa_tm_poll_src_port];

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

assign sch_deq_depth_ack = depth_deq_ack;
assign sch_deq_depth_from_emptyp2 = depth_deq_from_emptyp2;

always @(posedge clk) begin
        tm_asa_poll_drop <= align_fifo_drop;
	tm_asa_poll_conn_id <= align_poll_conn_id;
	tm_asa_poll_conn_group_id <= align_poll_conn_group_id;
	tm_asa_poll_port_queue_id <= align_poll_port_queue_id;
	tm_asa_poll_port_id <= f_lat_fifo_port_id;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
        tm_asa_poll_ack <= 0;
    end else begin
        tm_asa_poll_ack <= align_fifo_rd;
    end

/***************************** PROGRAM BODY **********************************/

always @(posedge clk) begin
        asa_tm_poll_qid_d1 <= asa_tm_poll_qid;
        asa_tm_poll_src_port_d1 <= asa_tm_poll_src_port;

	next_qm_enq_src_available0_d1 <= next_qm_enq_src_available0;
	next_qm_enq_src_available1_d1 <= next_qm_enq_src_available1;
	next_qm_enq_src_available2_d1 <= next_qm_enq_src_available2;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
        asa_tm_poll_req_d1 <= 0;
    end else begin
        asa_tm_poll_req_d1 <= asa_tm_poll_req;
    end

sfifo2f_fo #(`PORT_ID_NBITS, 5) u_sfifo2f_fo_10(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din(asa_tm_poll_src_port_d1),             
        .rd(align_fifo_rd),
        .wr(asa_tm_poll_req_d1),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout(fifo_asa_tm_poll_src_port)       
    );

tm_association_acc u_tm_association_acc(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .asa_tm_poll_req(asa_tm_poll_req),
        .asa_tm_poll_qid(asa_tm_poll_qid), 

        .queue_association_ack(queue_association_ack),
        .queue_association_rdata(queue_association_rdata),

        // outputs

        .queue_association_rd(queue_association_rd),
        .queue_association_raddr(queue_association_raddr),

        .poll_association_ack(poll_association_ack), 

        .association_conn_id(association_conn_id),
        .association_conn_group_id(association_conn_group_id),
        .association_port_queue_id(association_port_queue_id),
        .association_port_id(association_port_id)

    );


sfifo2f_fo #(`FIRST_LVL_QUEUE_ID_NBITS, 3) u_sfifo2f_fo_0(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({asa_tm_poll_qid_d1}),             
        .rd(poll_association_ack),
        .wr(asa_tm_poll_req_d1),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout({lat_fifo_qid})       
    );

wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] f_lat_fifo_qid;

sfifo2f_fo #(`FIRST_LVL_QUEUE_ID_NBITS+`PORT_ID_NBITS, 4) u_sfifo2f_fo_11(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({lat_fifo_qid, association_port_id}),				
		.rd(align_fifo_rd),
		.wr(poll_association_ack),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout({f_lat_fifo_qid, f_lat_fifo_port_id})       
	);

tm_poll_depth #(`FIRST_LVL_QUEUE_ID_NBITS) u_tm_poll_depth_0(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),
    
        .poll_req(poll_association_ack),      
        .qid(lat_fifo_qid),            

        .ll_queue_depth_ack(ll_queue_depth_ack),
        .ll_queue_depth_drop(ll_queue_depth_drop),
        .queue_threshold(queue_threshold),

        .queue_depth_ack(queue_depth_ack),
        .queue_depth(queue_depth),

        // outputs

        .poll_ack(q_poll_ack),
        .poll_drop(q_poll_drop),
        .poll_ack_qid(),

        .queue_depth_req(queue_depth_req),
        .queue_id(depth_req_queue_id) 

);

sfifo2f_fo #(1, 2) u_sfifo2f_fo_1(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({q_poll_drop}),              
        .rd(align_fifo_rd),
        .wr(q_poll_ack),

        .ncount(),
        .count(),
        .full(),
        .empty(align_fifo_empty0),
        .fullm1(),
        .emptyp2(),
        .dout({align_fifo_drop0})       
    );

tm_poll_depth #(`SECOND_LVL_QUEUE_ID_NBITS) u_tm_poll_depth_1(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),
    
        .poll_req(poll_association_ack),      
        .qid(association_conn_id),    

        .ll_queue_depth_ack(ll_queue_depth_ack),
        .ll_queue_depth_drop(ll_queue_depth_drop),
        .queue_threshold({(`FIRST_LVL_QUEUE_ID_NBITS+1){1'b1}}),

        .queue_depth_ack(conn_depth_ack),
        .queue_depth(conn_depth),

        // outputs

        .poll_ack(conn_poll_ack),
        .poll_drop(conn_poll_drop),
        .poll_ack_qid(conn_poll_qid),

        .queue_depth_req(conn_depth_req),  
        .queue_id(depth_req_conn_id) 

);

sfifo2f_fo #(1+`SECOND_LVL_QUEUE_ID_NBITS, 2) u_sfifo2f_fo_2(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({conn_poll_drop, conn_poll_qid}),                
        .rd(align_fifo_rd),
        .wr(conn_poll_ack),

        .ncount(),
        .count(),
        .full(),
        .empty(align_fifo_empty1),
        .fullm1(),
        .emptyp2(),
        .dout({align_fifo_drop1, align_poll_conn_id})       
    );

tm_poll_depth #(`THIRD_LVL_QUEUE_ID_NBITS) u_tm_poll_depth_2(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),
    
        .poll_req(poll_association_ack),     
        .qid(association_conn_group_id),     

        .ll_queue_depth_ack(ll_queue_depth_ack),
        .ll_queue_depth_drop(ll_queue_depth_drop),
        .queue_threshold({(`FIRST_LVL_QUEUE_ID_NBITS+1){1'b1}}),

        .queue_depth_ack(conn_group_depth_ack),
        .queue_depth(conn_group_depth),

        // outputs

        .poll_ack(conn_group_poll_ack),
        .poll_drop(conn_group_poll_drop),
        .poll_ack_qid(conn_group_poll_qid),

        .queue_depth_req(conn_group_depth_req),
        .queue_id(depth_req_conn_group_id) 

);

sfifo2f_fo #(1+`THIRD_LVL_QUEUE_ID_NBITS, 2) u_sfifo2f_fo_3(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({conn_group_poll_drop, conn_group_poll_qid}),             
        .rd(align_fifo_rd),
        .wr(conn_group_poll_ack),

        .ncount(),
        .count(),
        .full(),
        .empty(align_fifo_empty2),
        .fullm1(),
        .emptyp2(),
        .dout({align_fifo_drop2, align_poll_conn_group_id})       
    );

tm_poll_depth #(`FOURTH_LVL_QUEUE_ID_NBITS) u_tm_poll_depth_3(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),
    
        .poll_req(poll_association_ack),   
        .qid(association_port_queue_id),

        .ll_queue_depth_ack(ll_queue_depth_ack),
        .ll_queue_depth_drop(ll_queue_depth_drop),
        .queue_threshold({(`FIRST_LVL_QUEUE_ID_NBITS+1){1'b1}}),

        .queue_depth_ack(port_queue_depth_ack),
        .queue_depth(port_queue_depth),

        // outputs

        .poll_ack(port_poll_ack),
        .poll_drop(port_poll_drop),
        .poll_ack_qid(port_poll_qid),

        .queue_depth_req(port_queue_depth_req), 
        .queue_id(depth_req_port_queue_id) 

);

sfifo2f_fo #(1+`FOURTH_LVL_QUEUE_ID_NBITS, 2) u_sfifo2f_fo_4(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({port_poll_drop, port_poll_qid}),               
        .rd(align_fifo_rd),
        .wr(port_poll_ack),

        .ncount(),
        .count(),
        .full(),
        .empty(align_fifo_empty3),
        .fullm1(),
        .emptyp2(),
        .dout({align_fifo_drop3, align_poll_port_queue_id})       
    );

tm_qm0_depth u_tm_qm0_depth(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .enq_req(depth_enq_req),
        .enq_qid(depth_enq_qid),

        .deq_req(depth_deq_req),
        .deq_qid(depth_deq_qid),

        // outputs

        .enq_ack(depth_enq_ack),
        .enq_to_empty(depth_enq_to_empty),   

        .deq_ack(depth_deq_ack),
        .deq_from_emptyp2(depth_deq_from_emptyp2) 
);

tm_depth_acc u_tm_depth_acc(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .queue_depth_req(queue_depth_req),
        .queue_id(depth_req_queue_id), 

        .conn_depth_req(conn_depth_req),
        .conn_id(depth_req_conn_id),

        .conn_group_depth_req(conn_group_depth_req),
        .conn_group_id(depth_req_conn_group_id),

        .port_queue_depth_req(port_queue_depth_req),
        .port_queue_id(depth_req_port_queue_id),

        .depth_deq_req(depth_deq_req1),
        .depth_deq_qid(depth_deq_qid1),
        .depth_deq_conn_id(depth_deq_conn_id),
        .depth_deq_conn_group_id(depth_deq_conn_group_id),
        .depth_deq_port_queue_id(depth_deq_port_queue_id),

        // outputs

        .queue_depth_ack(queue_depth_ack),
        .queue_depth(queue_depth),

        .conn_depth_ack(conn_depth_ack),
        .conn_depth(conn_depth),

        .conn_group_depth_ack(conn_group_depth_ack),
        .conn_group_depth(conn_group_depth),

        .port_queue_depth_ack(port_queue_depth_ack),
        .port_queue_depth(port_queue_depth)
);

tm_linked_list u_tm_linked_list(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

	.alpha(alpha),

        .queue_depth_req(queue_depth_req),     

        .poll_ack(align_fifo_rd),
        .poll_drop(align_fifo_drop),

        .enq_req(asa_tm_enq_req),              
        .enq_qid(asa_tm_enq_qid),              
        .enq_conn_id(asa_tm_enq_conn_id),              
        .enq_conn_group_id(asa_tm_enq_conn_group_id),         
        .enq_port_queue_id(asa_tm_enq_port_queue_id),          
        .enq_pkt_desc(asa_tm_enq_pkt_desc),    

        .deq_req(sch_deq_req),                  
        .deq_qid(sch_deq_qid),

        .depth_enq_ack(depth_enq_ack),              
        .depth_enq_to_empty(depth_enq_to_empty),   

        .depth_deq_ack(depth_deq_ack),
        .depth_deq_from_emptyp2(depth_deq_from_emptyp2), 

        // outputs

        .queue_threshold(queue_threshold),

        .ll_queue_depth_ack(ll_queue_depth_ack),   
        .ll_queue_depth_drop(ll_queue_depth_drop), 
                         
        .depth_enq_req(depth_enq_req),         
        .depth_enq_qid(depth_enq_qid),

        .depth_deq_req(depth_deq_req),          
        .depth_deq_qid(depth_deq_qid),

        .depth_deq_req1(depth_deq_req1),          
        .depth_deq_qid1(depth_deq_qid1),
        .depth_deq_conn_id(depth_deq_conn_id),
        .depth_deq_conn_group_id(depth_deq_conn_group_id),
        .depth_deq_port_queue_id(depth_deq_port_queue_id),

        .active_enq_ack(active_enq_ack),                
        .active_enq_ack_qid(active_enq_ack_qid),
        .active_enq_ack_dst_port(active_enq_ack_dst_port),
        .active_enq_to_empty(active_enq_to_empty),

        .sch_deq_ack(sch_deq_ack),                  
        .sch_deq_ack_qid(sch_deq_ack_qid),
        .sch_deq_pkt_desc(sch_deq_pkt_desc)

);

tm_qm_mem0 u_tm_qm_mem0(
    .clk(clk),
    .`RESET_SIG(`RESET_SIG),

    .clk_div(clk_div),

    .reg_ms(reg_ms),
    .reg_rd(reg_rd),
    .reg_wr(reg_wr),
    .reg_addr(reg_addr),
    .reg_din(reg_din),

    .queue_association_rd(queue_association_rd),
    .queue_association_raddr(queue_association_raddr),

    // outputs

    .mem_ack(mem_ack),
    .mem_rdata(mem_rdata),

    .queue_association_ack(queue_association_ack), 
    .queue_association_rdata(queue_association_rdata)

);

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

