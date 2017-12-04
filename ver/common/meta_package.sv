//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

package meta_package; 

typedef struct { 

	logic [`IP_SA_NBITS-1:0] ip_sa;
	logic [`IP_DA_NBITS-1:0] ip_da;
	logic [`FLOW_LABEL_NBITS-1:0] flow_label;

} flow_value_type; 

typedef struct { 

	logic [2-1:0] maskon;
	logic [`EA_NBITS-1:0] ea;
	logic [`FSPDA_NBITS-1:0] fspda;
	logic [`TSPDA_NBITS-1:0] tspda;

} flow_pu_type; 

typedef struct { 

	logic [`PORT_ID_NBITS-1:0] src_port;
	logic [`PACKET_LENGTH_NBITS-1:0] len;
	logic [`BUF_PTR_NBITS-1:0] buf_ptr;

} discard_info_type; 

typedef struct { 

	logic [3-1:0] east;
	logic [3-1:0] ufdast;
	logic uppp;
	logic uppd;
	logic [2-1:0] ufascf;
	logic [16-1:0] ptr;

} ras_flag_type; 

typedef struct { 

	logic ptr_update;
	logic [`RCI_NBITS+3-1:0] cur_ptr;
	logic [`HEADER_LENGTH_NBITS-1:0] ptr_loc;
	logic pd_update;
	logic [`PD_CHUNK_NBITS-1:0] pd_len;
	logic [`HEADER_LENGTH_NBITS-1:0] pd_loc;
	logic [`EM_BUF_PTR_NBITS-1:0] pd_buf_ptr;
	logic [`RCI_NBITS-1:0] out_rci;
	logic [`PACKET_LENGTH_NBITS-1:0] len;

} enq_ed_cmd_type; 

typedef struct { 

	enq_ed_cmd_type ed_cmd;
	logic [`BUF_PTR_NBITS-1:0] buf_ptr;
	logic [`FID_NBITS-1:0] fid;
	logic [`TID_NBITS-1:0] tid;
	logic type1;
	logic [`PORT_ID_NBITS-1:0] src_port;
	logic [`PORT_ID_NBITS-1:0] dst_port;
	logic [`RCI_NBITS-1:0] rci;
	logic [`DOMAIN_ID_NBITS-1:0] domain_id;
	logic [`REAL_TIME_NBITS-1:0] creation_time;
	logic discard;

} asa_proc_meta_type; 

typedef struct { 

	logic [`PORT_ID_NBITS-1:0] src_port;
	logic [`PORT_ID_NBITS-1:0] dst_port;
	logic [`BUF_PTR_NBITS-1:0] buf_ptr;
	enq_ed_cmd_type ed_cmd;

} enq_pkt_desc_type; 

typedef struct { 

	logic [`SECOND_LVL_QUEUE_ID_NBITS-1:0] conn_id;
	logic [`THIRD_LVL_QUEUE_ID_NBITS-1:0] conn_group_id;
	logic [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] port_queue_id;
	enq_pkt_desc_type enq_pkt_desc;

} ext_pkt_desc_type;


typedef struct { 

	logic [`PORT_ID_NBITS-1:0] src_port;
	logic [`PORT_ID_NBITS-1:0] dst_port;
	logic [`PACKET_LENGTH_NBITS-1:0] len;
	logic [`PKT_DESC_DEPTH_NBITS-1:0] idx;

} sch_pkt_desc_type; 

typedef struct { 

	logic [`FIRST_LVL_QUEUE_ID_NBITS-1:0] q_id;
	logic [`SECOND_LVL_QUEUE_ID_NBITS-1:0] conn_id;
	logic [`THIRD_LVL_QUEUE_ID_NBITS-1:0] conn_group_id;
	logic [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] port_queue_id;
	sch_pkt_desc_type sch_pkt_desc;

} pkt_desc_type; 

typedef struct { 

	logic [`ENQ_ED_CMD_PTR_LOC_NBITS-1:0] ptr_loc;
	logic [`ENQ_ED_CMD_PD_LOC_NBITS-1:0] pd_loc;
	logic [`DOMAIN_ID_NBITS-1:0] domain_id;
	logic [`HEADER_LENGTH_NBITS-1:0] hdr_len;
	logic [`BUF_PTR_NBITS-1:0] buf_ptr;
	logic [`PACKET_LENGTH_NBITS-1:0] len;
	logic [`PORT_ID_NBITS-1:0] port;
	logic [`RCI_NBITS-1:0] rci;
	logic fid_sel;
	logic [`FID_NBITS-1:0] fid;
	logic [`TID_NBITS-1:0] tid;
	logic type1;
	logic type3;
	logic [`REAL_TIME_NBITS-1:0] creation_time;
	logic discard;

} pp_piarb_meta_type; 

typedef struct { 

	logic [`HOP_ID_NBITS-1:0] len;
	logic [`PD_CHUNK_NBITS-1:0] pd_len;
	logic [`INST_CHUNK_NBITS-1:0] inst_len;
	logic [`PIARB_BUF_PTR_NBITS-1:0] buf_ptr;
	logic [`PIARB_INST_BUF_PTR_NBITS-1:0] inst_buf_ptr;
	pp_piarb_meta_type pp_piarb_meta;

} pu_queue_payload_type; 

typedef struct { 

	logic [`REAL_TIME_NBITS-1:0] creation_time;
	logic [`PACKET_LENGTH_NBITS-1:0] len;
	logic [`PORT_ID_NBITS-1:0] port;
	logic [`RCI_NBITS-1:0] rci;
	logic [`FID_NBITS-1:0] fid;
	logic [`TID_NBITS-1:0] tid;
	logic [8-1:0] pkt_type;
	logic [`FLOW_PU_NBITS-1:0] f_payload;
	logic [`SWITCH_TAG_NBITS-1:0] switch_tag;

} pp_pu_meta_type; 

typedef struct { 

	logic [`DOMAIN_ID_NBITS-1:0] domain_id;
	logic [`HEADER_LENGTH_NBITS-1:0] hdr_len;
	logic [`BUF_PTR_NBITS-1:0] buf_ptr;
	logic [`PACKET_LENGTH_NBITS-1:0] len;
	logic [`PORT_ID_NBITS-1:0] port;
	logic [`RCI_NBITS-1:0] rci;
	logic fid_sel;
	logic [`FID_NBITS-1:0] fid;
	logic [`TID_NBITS-1:0] tid;
	logic type1;
	logic type3;
	logic discard;

} pp_meta_type; 

typedef struct { 

	logic [`HEADER_LENGTH_NBITS-1:0] ptr_loc;
	logic [`HEADER_LENGTH_NBITS-1:0] pd_loc;
	logic [`HEADER_LENGTH_NBITS-1:0] pd_len;
	logic [`DOMAIN_ID_NBITS-1:0] domain_id;
	logic [`HEADER_LENGTH_NBITS-1:0] hdr_len;
	logic [`BUF_PTR_NBITS-1:0] buf_ptr;
	logic [`PACKET_LENGTH_NBITS-1:0] len;
	logic [`PORT_ID_NBITS-1:0] port;
	logic [`RCI_NBITS-1:0] rci;
	logic fid_sel;
	logic [`FID_NBITS-1:0] fid;
	logic [`TID_NBITS-1:0] tid;
	logic type1;
	logic type3;
	logic [`REAL_TIME_NBITS-1:0] creation_time;
	logic discard;

} piarb_asa_meta_type; 

typedef struct { 

	logic [`REAL_TIME_NBITS-1:0] creation_time;
	logic [`RCI_NBITS+3-1:0] rci_type;
	logic [8-1:0] pkt_type;
	logic [`SWITCH_TAG_NBITS-1:0] switch_tag;
	logic [`FLOW_PU_NBITS-1:0] f_payload;
	logic [`FID_NBITS-1:0] fid;
	logic [`TID_NBITS-1:0] tid;

} pu_hop_meta_type; 

typedef struct { 

	logic [8-1:0] flags;
	logic [8-1:0] pc;
	logic [`RCI_NBITS-1:0] rci;
	logic [1-1:0] ins;
	logic [3-1:0] rci_type;
	logic [16-1:0] byte_ptr;

} hop_info_type; 

typedef struct { 

	logic [`DOMAIN_ID_NBITS-1:0] domain_id;
	logic [`HEADER_LENGTH_NBITS-1:0] hdr_len;
	logic [`BUF_PTR_NBITS-1:0] buf_ptr;
	logic [`PACKET_LENGTH_NBITS-1:0] len;
	logic [`PORT_ID_NBITS-1:0] port;
	logic [`RCI_NBITS-1:0] rci;
	logic [`FID_NBITS-1:0] fid;
	logic [`TID_NBITS-1:0] tid;
	logic type1;
	logic type3;
	logic discard;

} ecdsa_pp_meta_type; 

typedef struct { 

	logic [`HEADER_LENGTH_NBITS-1:0] hdr_len;
	logic [`BUF_PTR_NBITS-1:0] buf_ptr;
	logic [`PACKET_LENGTH_NBITS-1:0] len;
	logic [`PORT_ID_NBITS-1:0] port;
	logic [`RCI_NBITS-1:0] rci;
	logic [`FID_NBITS-1:0] fid;
	logic [`TID_NBITS-1:0] tid;
	logic type1;
	logic type3;
	logic discard;

} lh_pp_meta_type; 

typedef struct { 

	logic [`TRAFFIC_CLASS_NBITS-1:0] traffic_class;
	logic [`HEADER_LENGTH_NBITS-1:0] hdr_len;
	logic [`BUF_PTR_NBITS-1:0] buf_ptr;
	logic [`PACKET_LENGTH_NBITS-1:0] len;
	logic [`PORT_ID_NBITS-1:0] port;
	logic [`RCI_NBITS-1:0] rci;
	logic [`FID_NBITS-1:0] fid;
	logic [`TID_NBITS-1:0] tid;
	logic type1;
	logic type3;
	logic discard;

} lh_ecdsa_meta_type; 

typedef struct { 

	logic [`TRAFFIC_CLASS_NBITS-1:0] traffic_class;
	logic [`HEADER_LENGTH_NBITS-1:0] hdr_len;
	logic [`BUF_PTR_NBITS-1:0] buf_ptr;
	logic [`PACKET_LENGTH_NBITS-1:0] len;
	logic [`PORT_ID_NBITS-1:0] port;
	logic [`RCI_NBITS-1:0] rci;
	logic [`FID_NBITS-1:0] fid;
	logic [`TID_NBITS-1:0] tid;
	logic type1;
	logic type3;
	logic discard;

} irl_lh_meta_type; 

typedef struct { 

	logic [`TRAFFIC_CLASS_NBITS-1:0] traffic_class;
	logic [`HEADER_LENGTH_NBITS-1:0] hdr_len;
	logic [`BUF_PTR_NBITS-1:0] buf_ptr;
	logic [`PACKET_LENGTH_NBITS-1:0] len;
	logic [`PORT_ID_NBITS-1:0] port;
	logic [`RCI_NBITS-1:0] rci;
	logic [`FID_NBITS-1:0] fid;
	logic [`TID_NBITS-1:0] tid;
	logic type1;
	logic type3;
	logic discard;

} cla_irl_meta_type; 

typedef struct { 

	logic [`HEADER_LENGTH_NBITS-1:0] hdr_len;
	logic [`BUF_PTR_NBITS-1:0] buf_ptr;
	logic [`PACKET_LENGTH_NBITS-1:0] len;
	logic [`PORT_ID_NBITS-1:0] port;
	logic [`RCI_NBITS-1:0] rci;
	logic discard;

} aggr_par_meta_type; 

endpackage
