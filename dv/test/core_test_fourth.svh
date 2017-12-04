import uvm_pkg::*;
import mac_agent_pkg::*;
import dma_agent_pkg::*;
import pio_wr_agent_pkg::*;
import pio_rd_agent_pkg::*;
import ral_pkg::*;

import table_package::*;

`include "defines.vh"

class core_test_fourth extends core_test_base;

  `uvm_component_utils_begin (core_test_fourth)
  `uvm_component_utils_end

  function new (string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction

  extern virtual task main_phase (uvm_phase phase);

`HASH(hash_encap, `TUNNEL_KEY_NBITS, `TUNNEL_HASH_TABLE_DEPTH_NBITS)
`HASH(hash_decap, `RCI_KEY_NBITS, `RCI_HASH_TABLE_DEPTH_NBITS)
`HASH(hash_class_flow, `FLOW_KEY_NBITS, `FLOW_HASH_TABLE_DEPTH_NBITS)
`HASH(hash_class_topic, `TOPIC_KEY_NBITS, `TOPIC_HASH_TABLE_DEPTH_NBITS)

`TRANSPOSE(transpose_encap, `TUNNEL_KEY_NBITS)
`TRANSPOSE(transpose_decap, `RCI_KEY_NBITS)
`TRANSPOSE(transpose_class_flow, `FLOW_KEY_NBITS)
`TRANSPOSE(transpose_class_topic, `TOPIC_KEY_NBITS)

endclass

task core_test_fourth::main_phase (uvm_phase phase);

  mac_sequence mac_seq;
  dma_sequence dma_seq1;
  dma_sequence dma_seq2;
  pio_wr_sequence pio_wr_seq1;
  pio_rd_sequence pio_rd_seq1;

  tunnel_hash_entry tunnel_hash_entry0, tunnel_hash_entry1;
  tunnel_value_entry tunnel_value_entry0;
  reg [`TUNNEL_VALUE_NBITS-1:0] tunnel_value;
  rci_hash_entry rci_hash_entry0, rci_hash_entry1;
  rci_value_entry rci_value_entry0;

  reg [`DECR_MEM_ADDR_MSB:0] decr_addr_lsb;
  reg [`CLASSIFIER_MEM_ADDR_MSB:0] classifier_addr_lsb;
  reg [`IRL_MEM_ADDR_MSB:0] irl_addr_lsb;
  reg [`ASA_MEM_ADDR_MSB:0] asa_addr_lsb;
  reg [`TM_MEM_ADDR_MSB:0] tm_addr_lsb;
  reg [`ENCR_MEM_ADDR_MSB:0] encr_addr_lsb;

  reg [`ENCR_REG_ADDR_RANGE] encr_reg_addr;

  integer i, j;

  reg [`FIRST_LVL_QUEUE_PROFILE_NBITS-1:0] tm_q_profile0;
  reg [`FIRST_LVL_SCH_ID_NBITS-1:0] tm_sch_id0;
  reg [`PRI_NBITS-1:0] tm_pri0;
  reg tm_en_pri0;

  reg [((`FIRST_LVL_QUEUE_ID_NBITS)<<1)-1:0] tm_pri_sch_ctrl0;
  reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] tm_1st_loc0;
  reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] tm_last_loc0;

  reg [`SECOND_LVL_QUEUE_PROFILE_NBITS-1:0] tm_q_profile1;
  reg [`SECOND_LVL_SCH_ID_NBITS-1:0] tm_sch_id1;
  reg [`PRI_NBITS-1:0] tm_pri1;
  reg tm_en_pri1;

  reg [((`SECOND_LVL_QUEUE_ID_NBITS)<<1)-1:0] tm_pri_sch_ctrl1;
  reg [`SECOND_LVL_QUEUE_ID_NBITS-1:0] tm_1st_loc1;
  reg [`SECOND_LVL_QUEUE_ID_NBITS-1:0] tm_last_loc1;

  reg [`THIRD_LVL_QUEUE_PROFILE_NBITS-1:0] tm_q_profile2;
  reg [`THIRD_LVL_SCH_ID_NBITS-1:0] tm_sch_id2;
  reg [`PRI_NBITS-1:0] tm_pri2;
  reg tm_en_pri2;

  reg [((`THIRD_LVL_QUEUE_ID_NBITS)<<1)-1:0] tm_pri_sch_ctrl2;
  reg [`THIRD_LVL_QUEUE_ID_NBITS-1:0] tm_1st_loc2;
  reg [`THIRD_LVL_QUEUE_ID_NBITS-1:0] tm_last_loc2;

  reg [`FOURTH_LVL_QUEUE_PROFILE_NBITS-1:0] tm_q_profile3;
  reg [`FOURTH_LVL_SCH_ID_NBITS-1:0] tm_sch_id3;
  reg [`PRI_NBITS-1:0] tm_pri3;
  reg tm_en_pri3;

  reg [((`FOURTH_LVL_QUEUE_ID_NBITS)<<1)-1:0] tm_pri_sch_ctrl3;
  reg [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] tm_1st_loc3;
  reg [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] tm_last_loc3;

  reg [`PRI_NBITS-1:0] tm_pri;
  reg [`QUEUE_ASSOCIATION_NBITS-1:0] tm_q_association;

  reg [`PORT_ID_NBITS-1:0] tm_port_id0;
  reg [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] tm_port_queue0;
  reg [`THIRD_LVL_QUEUE_ID_NBITS-1:0] tm_conn_group0;
  reg [`SECOND_LVL_QUEUE_ID_NBITS-1:0] tm_conn0;

  reg [`PORT_ID_NBITS-1:0] tm_port_id1;
  reg [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] tm_port_queue1;
  reg [`THIRD_LVL_QUEUE_ID_NBITS-1:0] tm_conn_group1;
  reg [`SECOND_LVL_QUEUE_ID_NBITS-1:0] tm_conn1;

  reg [`SHAPING_PROFILE_NBITS-1:0] tm_shaping_profile;
  reg [`CIR_NBITS-1:0] tm_cir_token;
  reg [`CIR_NBITS-1:0] tm_cir_burst;

  reg [31:0] ipv4_da;
  reg [31:0] ipv4_sa;

  reg [127:0] in_ipv6_da;
  reg [127:0] in_ipv6_sa;
  reg [19:0] in_label;

  reg [`TUNNEL_KEY_NBITS-1:0] encap_key;
  reg [255:0] decap_key;
  reg [275:0] flow_key;
  reg [127:0] topic_key;

  reg [`TUNNEL_HASH_TABLE_DEPTH_NBITS-1:0] tunnel_hash;
  reg [`TUNNEL_HASH_TABLE_DEPTH_NBITS-1:0] tunnel_hash1;
  reg [`RCI_HASH_TABLE_DEPTH_NBITS-1:0] rci_hash;
  reg [`RCI_HASH_TABLE_DEPTH_NBITS-1:0] rci_hash1;
  reg [`FLOW_HASH_TABLE_DEPTH_NBITS-1:0] flow_hash0;
  reg [`FLOW_HASH_TABLE_DEPTH_NBITS-1:0] flow_hash1;
  reg [`TOPIC_HASH_TABLE_DEPTH_NBITS-1:0] topic_hash0;
  reg [`TOPIC_HASH_TABLE_DEPTH_NBITS-1:0] topic_hash1;
  reg [`CIR_NBITS-1:0] cir;
  reg [`CIR_NBITS-1:0] cir_burst;
  reg [`EIR_NBITS-1:0] eir;
  reg [`EIR_NBITS-1:0] eir_burst;
  reg [`LIMITER_NBITS-1:0] limiter_no;

  reg [`TID_NBITS-1:0] tid;
  reg [`FID_NBITS-1:0] fid;

  reg [`FLOW_HASH_BUCKET_NBITS-1:0] f_bucket;
  reg [`TOPIC_HASH_BUCKET_NBITS-1:0] t_bucket;

  reg [`SCI_NBITS-1:0] sci0;
  reg [`SCI_NBITS-1:0] sci1;
  reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] tm_1st_queue0;
  reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] tm_1st_queue1;

  uvm_status_e status;

  rci_type dst_rci;
  sci_type dst_sci;
  port_id_type dst_port;

  super.main_phase (phase);
  phase.raise_objection (this);

  /**************************************************************/
  
  env.encap_reg.flow_label_reg.write( status, 20'habcde);
  env.encap_reg.traffic_class_reg.write( status, {16'ha55a, 8'hd1, 8'h56});
  env.encap_reg.mac_sa_lsb_reg.write( status, 32'hba98_7654);
  env.encap_reg.mac_sa_msb_reg.write( status, 16'hfedc);

  /**************************************************************/
  pio_wr_seq1 = pio_wr_sequence::type_id::create("pio_wr_seq1", this);
  pio_rd_seq1 = pio_rd_sequence::type_id::create("pio_rd_seq1", this);

  /**************************************************************/
  `uvm_info ("CORE_TEST","Programming TM",UVM_HIGH);

  tm_pri = 0;
  sci0 = 8;
  sci1 = 62;

  tm_1st_queue0 = {tm_pri, sci0};
  tm_1st_queue1 = {tm_pri, sci1};

  tm_port_id0 = 1;
  tm_port_queue0 = 2;
  tm_conn_group0 = 3;
  tm_conn0 = 0;

  tm_port_id1 = 3;
  tm_port_queue1 = 12;
  tm_conn_group1 = 13;
  tm_conn1 = 10;

  dst_port = tm_port_id0;
  dst_sci = sci0;
  env.sb.sci2port[dst_sci] = dst_port;

  dst_port = tm_port_id1;
  dst_sci = sci1;
  env.sb.sci2port[dst_sci] = dst_port;

  /**************************************************************/
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_SHAPING_PROFILE_EIR0;
  tm_addr_lsb[`FIRST_LVL_QUEUE_ID_NBITS+2-1:0] = tm_1st_queue0<<2;

  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_shaping_profile;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_SHAPING_PROFILE_CIR0;
  tm_addr_lsb[`FIRST_LVL_QUEUE_ID_NBITS+2-1:0] = tm_1st_queue0<<2;

  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_shaping_profile;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  ///////////////////////////
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_SHAPING_PROFILE_EIR0;
  tm_addr_lsb[`FIRST_LVL_QUEUE_ID_NBITS+2-1:0] = tm_1st_queue1<<2;

  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_shaping_profile;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_SHAPING_PROFILE_CIR0;
  tm_addr_lsb[`FIRST_LVL_QUEUE_ID_NBITS+2-1:0] = tm_1st_queue1<<2;

  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_shaping_profile;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  /**************************************************************/
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_QUEUE_PROFILE0;
  tm_addr_lsb[`FIRST_LVL_QUEUE_ID_NBITS+2-1:0] = tm_1st_queue0<<2;

  tm_sch_id0 = tm_conn0;
  tm_pri0 = tm_pri;
  tm_en_pri0 = 1;
  tm_q_profile0 = {tm_sch_id0, tm_pri0, tm_en_pri0};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_q_profile0;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  ///////////////////////////
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_QUEUE_PROFILE0;
  tm_addr_lsb[`FIRST_LVL_QUEUE_ID_NBITS+2-1:0] = tm_1st_queue1<<2;

  tm_sch_id0 = tm_conn1;
  tm_pri0 = tm_pri;
  tm_en_pri0 = 1;
  tm_q_profile0 = {tm_sch_id0, tm_pri0, tm_en_pri0};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_q_profile0;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  /**************************************************************/
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_PRI_SCH_CTRL00;
  tm_addr_lsb[`FIRST_LVL_SCH_ID_NBITS+2-1:0] = tm_conn0<<2;

  tm_1st_loc0 = 2;
  tm_last_loc0 = 2;
  tm_pri_sch_ctrl0 = {tm_last_loc0, tm_1st_loc0};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_pri_sch_ctrl0;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  ///////////////////////////
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_PRI_SCH_CTRL00;
  tm_addr_lsb[`FIRST_LVL_SCH_ID_NBITS+2-1:0] = tm_conn1<<2;

  tm_1st_loc0 = 3;
  tm_last_loc0 = 3;
  tm_pri_sch_ctrl0 = {tm_last_loc0, tm_1st_loc0};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_pri_sch_ctrl0;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  /**************************************************************/
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_FILL_TB_DST0;
  tm_addr_lsb[`FIRST_LVL_QUEUE_ID_NBITS+2-1:0] = tm_1st_queue0<<2;

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_port_id0;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  ///////////////////////////
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_FILL_TB_DST0;
  tm_addr_lsb[`FIRST_LVL_QUEUE_ID_NBITS+2-1:0] = tm_1st_queue1<<2;

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_port_id1;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  /**************************************************************/
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_SHAPING_PROFILE_EIR1;
  tm_addr_lsb[`SECOND_LVL_QUEUE_ID_NBITS+2-1:0] = tm_conn0<<2;

  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_shaping_profile;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_SHAPING_PROFILE_CIR1;
  tm_addr_lsb[`SECOND_LVL_QUEUE_ID_NBITS+2-1:0] = tm_conn0<<2;

  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_shaping_profile;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  ///////////////////////////
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_SHAPING_PROFILE_EIR1;
  tm_addr_lsb[`SECOND_LVL_QUEUE_ID_NBITS+2-1:0] = tm_conn1<<2;

  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_shaping_profile;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_SHAPING_PROFILE_CIR1;
  tm_addr_lsb[`SECOND_LVL_QUEUE_ID_NBITS+2-1:0] = tm_conn1<<2;

  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_shaping_profile;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  /**************************************************************/
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_QUEUE_PROFILE1;
  tm_addr_lsb[`SECOND_LVL_QUEUE_ID_NBITS+2-1:0] = tm_conn0<<2;

  tm_sch_id1 = tm_conn_group0;
  tm_pri1 = 3;
  tm_en_pri1 = 1;
  tm_q_profile1 = {tm_sch_id1, tm_pri1, tm_en_pri1};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_q_profile1;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  ///////////////////////////
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_QUEUE_PROFILE1;
  tm_addr_lsb[`SECOND_LVL_QUEUE_ID_NBITS+2-1:0] = tm_conn1<<2;

  tm_sch_id1 = tm_conn_group1;
  tm_pri1 = 5;
  tm_en_pri1 = 1;
  tm_q_profile1 = {tm_sch_id1, tm_pri1, tm_en_pri1};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_q_profile1;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  /**************************************************************/
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_PRI_SCH_CTRL13;
  tm_addr_lsb[`SECOND_LVL_SCH_ID_NBITS+2-1:0] = tm_conn_group0<<2;

  tm_1st_loc1 = 4;
  tm_last_loc1 = 4;
  tm_pri_sch_ctrl1 = {tm_last_loc1, tm_1st_loc1};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_pri_sch_ctrl1;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  ///////////////////////////
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_PRI_SCH_CTRL15;
  tm_addr_lsb[`SECOND_LVL_SCH_ID_NBITS+2-1:0] = tm_conn_group1<<2;

  tm_1st_loc1 = 5;
  tm_last_loc1 = 5;
  tm_pri_sch_ctrl1 = {tm_last_loc1, tm_1st_loc1};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_pri_sch_ctrl1;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  /**************************************************************/
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_FILL_TB_DST1;
  tm_addr_lsb[`SECOND_LVL_QUEUE_ID_NBITS+2-1:0] = tm_conn0<<2;

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_port_id0;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  ///////////////////////////
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_FILL_TB_DST1;
  tm_addr_lsb[`SECOND_LVL_QUEUE_ID_NBITS+2-1:0] = tm_conn1<<2;

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_port_id1;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  /**************************************************************/
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_SHAPING_PROFILE_EIR2;
  tm_addr_lsb[`THIRD_LVL_QUEUE_ID_NBITS+2-1:0] = tm_conn_group0<<2;

  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_shaping_profile;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_SHAPING_PROFILE_CIR2;
  tm_addr_lsb[`THIRD_LVL_QUEUE_ID_NBITS+2-1:0] = tm_conn_group0<<2;

  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_shaping_profile;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  ///////////////////////////
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_SHAPING_PROFILE_EIR2;
  tm_addr_lsb[`THIRD_LVL_QUEUE_ID_NBITS+2-1:0] = tm_conn_group1<<2;

  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_shaping_profile;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_SHAPING_PROFILE_CIR2;
  tm_addr_lsb[`THIRD_LVL_QUEUE_ID_NBITS+2-1:0] = tm_conn_group1<<2;

  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_shaping_profile;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  /**************************************************************/
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_QUEUE_PROFILE2;
  tm_addr_lsb[`THIRD_LVL_QUEUE_ID_NBITS+2-1:0] = tm_conn_group0<<2;

  tm_sch_id2 = tm_port_queue0;
  tm_pri2 = 4;
  tm_en_pri2 = 1;
  tm_q_profile2 = {tm_sch_id2, tm_pri2, tm_en_pri2};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_q_profile2;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  ///////////////////////////
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_QUEUE_PROFILE2;
  tm_addr_lsb[`THIRD_LVL_QUEUE_ID_NBITS+2-1:0] = tm_conn_group1<<2;

  tm_sch_id2 = tm_port_queue1;
  tm_pri2 = 7;
  tm_en_pri2 = 1;
  tm_q_profile2 = {tm_sch_id2, tm_pri2, tm_en_pri2};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_q_profile2;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  /**************************************************************/
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_PRI_SCH_CTRL24;
  tm_addr_lsb[`THIRD_LVL_SCH_ID_NBITS+2-1:0] = tm_port_queue0<<2;

  tm_1st_loc2 = 1;
  tm_last_loc2 = 1;
  tm_pri_sch_ctrl2 = {tm_last_loc2, tm_1st_loc2};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_pri_sch_ctrl2;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  ///////////////////////////
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_PRI_SCH_CTRL27;
  tm_addr_lsb[`THIRD_LVL_SCH_ID_NBITS+2-1:0] = tm_port_queue1<<2;

  tm_1st_loc2 = 2;
  tm_last_loc2 = 2;
  tm_pri_sch_ctrl2 = {tm_last_loc2, tm_1st_loc2};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_pri_sch_ctrl2;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  /**************************************************************/
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_FILL_TB_DST2;
  tm_addr_lsb[`THIRD_LVL_QUEUE_ID_NBITS+2-1:0] = tm_conn_group0<<2;

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_port_id0;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  ///////////////////////////
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_FILL_TB_DST2;
  tm_addr_lsb[`THIRD_LVL_QUEUE_ID_NBITS+2-1:0] = tm_conn_group1<<2;

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_port_id1;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  /**************************************************************/
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_SHAPING_PROFILE_EIR3;
  tm_addr_lsb[`FOURTH_LVL_QUEUE_ID_NBITS+2-1:0] = tm_port_queue0<<2;

  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_shaping_profile;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_SHAPING_PROFILE_CIR3;
  tm_addr_lsb[`FOURTH_LVL_QUEUE_ID_NBITS+2-1:0] = tm_port_queue0<<2;

  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_shaping_profile;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  ///////////////////////////
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_SHAPING_PROFILE_EIR3;
  tm_addr_lsb[`FOURTH_LVL_QUEUE_ID_NBITS+2-1:0] = tm_port_queue1<<2;

  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_shaping_profile;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_SHAPING_PROFILE_CIR3;
  tm_addr_lsb[`FOURTH_LVL_QUEUE_ID_NBITS+2-1:0] = tm_port_queue1<<2;

  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_shaping_profile;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  /**************************************************************/
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_QUEUE_PROFILE3;
  tm_addr_lsb[`FOURTH_LVL_QUEUE_ID_NBITS+2-1:0] = tm_port_queue0<<2;

  tm_sch_id3 = tm_port_id0;
  tm_pri3 = 6;
  tm_en_pri3 = 1;
  tm_q_profile3 = {tm_sch_id3, tm_pri3, tm_en_pri3};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_q_profile3;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  ///////////////////////////
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_QUEUE_PROFILE3;
  tm_addr_lsb[`FOURTH_LVL_QUEUE_ID_NBITS+2-1:0] = tm_port_queue1<<2;

  tm_sch_id3 = tm_port_id1;
  tm_pri3 = 7;
  tm_en_pri3 = 1;
  tm_q_profile3 = {tm_sch_id3, tm_pri3, tm_en_pri3};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_q_profile3;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  /**************************************************************/
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_PRI_SCH_CTRL36;
  tm_addr_lsb[`THIRD_LVL_SCH_ID_NBITS+2-1:0] = tm_port_id0<<2;

  tm_1st_loc3 = 5;
  tm_last_loc3 = 5;
  tm_pri_sch_ctrl3 = {tm_last_loc3, tm_1st_loc3};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_pri_sch_ctrl3;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  ///////////////////////////
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_PRI_SCH_CTRL37;
  tm_addr_lsb[`THIRD_LVL_SCH_ID_NBITS+2-1:0] = tm_port_id1<<2;

  tm_1st_loc3 = 6;
  tm_last_loc3 = 6;
  tm_pri_sch_ctrl3 = {tm_last_loc3, tm_1st_loc3};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_pri_sch_ctrl3;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  /**************************************************************/
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_FILL_TB_DST3;
  tm_addr_lsb[`FOURTH_LVL_QUEUE_ID_NBITS+2-1:0] = tm_port_queue0<<2;

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_port_id0;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  ///////////////////////////
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_FILL_TB_DST3;
  tm_addr_lsb[`FOURTH_LVL_QUEUE_ID_NBITS+2-1:0] = tm_port_queue1<<2;

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_port_id1;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  /**************************************************************/
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_QUEUE_ASSOCIATION;
  tm_addr_lsb[`FIRST_LVL_QUEUE_ID_NBITS+2-1:0] = tm_1st_queue0<<2;

  tm_q_association = {tm_port_id0, tm_port_queue0, tm_conn_group0, tm_conn0};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_q_association;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  ///////////////////////////
  tm_addr_lsb[`TM_MEM_ADDR_RANGE] = `TM_QUEUE_ASSOCIATION;
  tm_addr_lsb[`FIRST_LVL_QUEUE_ID_NBITS+2-1:0] = tm_1st_queue1<<2;

  tm_q_association = {tm_port_id1, tm_port_queue1, tm_conn_group1, tm_conn1};

  pio_wr_seq1.pio_wr_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_wr_seq1.pio_wr_data = tm_q_association;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`TM_BLOCK_ADDR, tm_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  /**************************************************************/
  asa_addr_lsb = `DEFAULT_RCI<<2;

  pio_wr_seq1.pio_wr_addr = {`ASA_BLOCK_ADDR, asa_addr_lsb};    
  pio_wr_seq1.pio_wr_data = sci0;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`ASA_BLOCK_ADDR, asa_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  dst_rci = `DEFAULT_RCI;
  dst_sci = sci0;
  env.sb.rci2sci[dst_rci] = dst_sci;

  asa_addr_lsb = (`DEFAULT_RCI+1)<<2;

  pio_wr_seq1.pio_wr_addr = {`ASA_BLOCK_ADDR, asa_addr_lsb};    
  pio_wr_seq1.pio_wr_data = sci1;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`ASA_BLOCK_ADDR, asa_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  dst_rci = `DEFAULT_RCI+1;
  dst_sci = sci1;
  env.sb.rci2sci[dst_rci] = dst_sci;

  asa_addr_lsb = 1000<<2;

  pio_wr_seq1.pio_wr_addr = {`ASA_BLOCK_ADDR, asa_addr_lsb};    
  pio_wr_seq1.pio_wr_data = 5;
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`ASA_BLOCK_ADDR, asa_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  dst_rci = 1000;
  dst_sci = 5;
  env.sb.rci2sci[dst_rci] = dst_sci;

  /**************************************************************/
  in_label = 20'habcde;
  in_ipv6_sa = 128'h1234_bead_5678_bead_9abc_bead_def0_bead;
  in_ipv6_da = 128'h0fde_dada_4321_dada_8765_dada_cba9_dada;

  flow_key = {in_ipv6_da, in_ipv6_sa, in_label};
  topic_key = in_ipv6_da;

  flow_hash0 = hash_class_flow(flow_key);
  flow_hash1 = hash_class_flow(transpose_class_flow(flow_key));

  fid = {(`FID_NBITS){1'b1}};

  f_bucket = {fid, flow_hash1, fid, flow_hash1};

  classifier_addr_lsb[`CLASSIFIER_MEM_ADDR_RANGE] = `CLASSIFIER_FLOW_HASH_TABLE;
  classifier_addr_lsb[`FLOW_HASH_TABLE_DEPTH_NBITS+3] = 0;
  classifier_addr_lsb[`FLOW_HASH_TABLE_DEPTH_NBITS+3-1:0] = flow_hash0<<3;

  pio_wr_seq1.pio_wr_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_wr_seq1.pio_wr_data = f_bucket[31:0];
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  classifier_addr_lsb[`FLOW_HASH_TABLE_DEPTH_NBITS+3-1:0] = (flow_hash0<<3)|3'b100;

  pio_wr_seq1.pio_wr_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_wr_seq1.pio_wr_data = f_bucket[`FLOW_HASH_BUCKET_NBITS-1:32];
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  classifier_addr_lsb[`FLOW_HASH_TABLE_DEPTH_NBITS+3-1:0] = flow_hash0<<3;
  pio_rd_seq1.pio_rd_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  classifier_addr_lsb[`FLOW_HASH_TABLE_DEPTH_NBITS+3-1:0] = (flow_hash0<<3)|3'b100;
  pio_rd_seq1.pio_rd_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  f_bucket = {fid, flow_hash0, fid, flow_hash0};

  classifier_addr_lsb[`CLASSIFIER_MEM_ADDR_RANGE] = `CLASSIFIER_FLOW_HASH_TABLE;
  classifier_addr_lsb[`FLOW_HASH_TABLE_DEPTH_NBITS+3] = 1;
  classifier_addr_lsb[`FLOW_HASH_TABLE_DEPTH_NBITS+3-1:0] = flow_hash1<<3;

  pio_wr_seq1.pio_wr_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_wr_seq1.pio_wr_data = f_bucket[31:0];
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  classifier_addr_lsb[`FLOW_HASH_TABLE_DEPTH_NBITS+3-1:0] = (flow_hash1<<3)|3'b100;

  pio_wr_seq1.pio_wr_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_wr_seq1.pio_wr_data = f_bucket[`FLOW_HASH_BUCKET_NBITS-1:32];
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  classifier_addr_lsb[`FLOW_HASH_TABLE_DEPTH_NBITS+3-1:0] = flow_hash1<<3;
  pio_rd_seq1.pio_rd_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  classifier_addr_lsb[`FLOW_HASH_TABLE_DEPTH_NBITS+3-1:0] = (flow_hash1<<3)|3'b100;
  pio_rd_seq1.pio_rd_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  topic_hash0 = hash_class_topic(topic_key);
  topic_hash1 = hash_class_topic(transpose_class_topic(topic_key));

  tid = {(`TID_NBITS){1'b1}};

  t_bucket = {tid, topic_hash1, tid, topic_hash1};

  classifier_addr_lsb[`CLASSIFIER_MEM_ADDR_RANGE] = `CLASSIFIER_TOPIC_HASH_TABLE;
  classifier_addr_lsb[`CLASSIFIER_MEM_ADDR_LSB-1:`TOPIC_HASH_TABLE_DEPTH_NBITS+3] = 0;
  classifier_addr_lsb[`TOPIC_HASH_TABLE_DEPTH_NBITS+3-1:0] = topic_hash0<<3;

  pio_wr_seq1.pio_wr_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_wr_seq1.pio_wr_data = t_bucket[31:0];
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  classifier_addr_lsb[`TOPIC_HASH_TABLE_DEPTH_NBITS+3-1:0] = (topic_hash0<<3)|3'b100;

  pio_wr_seq1.pio_wr_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_wr_seq1.pio_wr_data = t_bucket[`TOPIC_HASH_BUCKET_NBITS-1:32];
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  classifier_addr_lsb[`TOPIC_HASH_TABLE_DEPTH_NBITS+3-1:0] = topic_hash0<<3;
  pio_rd_seq1.pio_rd_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  classifier_addr_lsb[`TOPIC_HASH_TABLE_DEPTH_NBITS+3-1:0] = (topic_hash0<<3)|3'b100;
  pio_rd_seq1.pio_rd_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  t_bucket = {tid, topic_hash0, tid, topic_hash0};

  classifier_addr_lsb[`CLASSIFIER_MEM_ADDR_RANGE] = `CLASSIFIER_TOPIC_HASH_TABLE;
  classifier_addr_lsb[`CLASSIFIER_MEM_ADDR_LSB-1:`TOPIC_HASH_TABLE_DEPTH_NBITS+3] = 1;
  classifier_addr_lsb[`TOPIC_HASH_TABLE_DEPTH_NBITS+3-1:0] = topic_hash1<<3;

  pio_wr_seq1.pio_wr_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_wr_seq1.pio_wr_data = t_bucket[31:0];
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  classifier_addr_lsb[`TOPIC_HASH_TABLE_DEPTH_NBITS+3-1:0] = (topic_hash1<<3)|3'b100;

  pio_wr_seq1.pio_wr_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_wr_seq1.pio_wr_data = t_bucket[`TOPIC_HASH_BUCKET_NBITS-1:32];
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  classifier_addr_lsb[`TOPIC_HASH_TABLE_DEPTH_NBITS+3-1:0] = topic_hash1<<3;
  pio_rd_seq1.pio_rd_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  classifier_addr_lsb[`TOPIC_HASH_TABLE_DEPTH_NBITS+3-1:0] = (topic_hash1<<3)|3'b100;
  pio_rd_seq1.pio_rd_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  in_ipv6_da = 128'h0fde_cafe_4321_cafe_8765_cafe_cba9_cafe;

  flow_key = {in_ipv6_da, in_ipv6_sa, in_label};
  topic_key = in_ipv6_da;

  flow_hash0 = hash_class_flow(flow_key);
  flow_hash1 = hash_class_flow(transpose_class_flow(flow_key));

  f_bucket = {fid, flow_hash1, fid, flow_hash1};

  classifier_addr_lsb[`CLASSIFIER_MEM_ADDR_RANGE] = `CLASSIFIER_FLOW_HASH_TABLE;
  classifier_addr_lsb[`FLOW_HASH_TABLE_DEPTH_NBITS+3] = 0;
  classifier_addr_lsb[`FLOW_HASH_TABLE_DEPTH_NBITS+3-1:0] = flow_hash0<<3;

  pio_wr_seq1.pio_wr_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_wr_seq1.pio_wr_data = f_bucket[31:0];
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  classifier_addr_lsb[`FLOW_HASH_TABLE_DEPTH_NBITS+3-1:0] = (flow_hash0<<3)|3'b100;

  pio_wr_seq1.pio_wr_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_wr_seq1.pio_wr_data = f_bucket[`FLOW_HASH_BUCKET_NBITS-1:32];
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  classifier_addr_lsb[`FLOW_HASH_TABLE_DEPTH_NBITS+3-1:0] = flow_hash0<<3;
  pio_rd_seq1.pio_rd_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  classifier_addr_lsb[`FLOW_HASH_TABLE_DEPTH_NBITS+3-1:0] = (flow_hash0<<3)|3'b100;
  pio_rd_seq1.pio_rd_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  f_bucket = {fid, flow_hash0, fid, flow_hash0};

  classifier_addr_lsb[`CLASSIFIER_MEM_ADDR_RANGE] = `CLASSIFIER_FLOW_HASH_TABLE;
  classifier_addr_lsb[`FLOW_HASH_TABLE_DEPTH_NBITS+3] = 1;
  classifier_addr_lsb[`FLOW_HASH_TABLE_DEPTH_NBITS+3-1:0] = flow_hash1<<3;

  pio_wr_seq1.pio_wr_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_wr_seq1.pio_wr_data = f_bucket[31:0];
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  classifier_addr_lsb[`FLOW_HASH_TABLE_DEPTH_NBITS+3-1:0] = (flow_hash1<<3)|3'b100;

  pio_wr_seq1.pio_wr_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_wr_seq1.pio_wr_data = f_bucket[`FLOW_HASH_BUCKET_NBITS-1:32];
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  classifier_addr_lsb[`FLOW_HASH_TABLE_DEPTH_NBITS+3-1:0] = flow_hash1<<3;
  pio_rd_seq1.pio_rd_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  classifier_addr_lsb[`FLOW_HASH_TABLE_DEPTH_NBITS+3-1:0] = (flow_hash1<<3)|3'b100;
  pio_rd_seq1.pio_rd_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  topic_hash0 = hash_class_topic(topic_key);
  topic_hash1 = hash_class_topic(transpose_class_topic(topic_key));

  t_bucket = {tid, topic_hash1, tid, topic_hash1};

  classifier_addr_lsb[`CLASSIFIER_MEM_ADDR_RANGE] = `CLASSIFIER_TOPIC_HASH_TABLE;
  classifier_addr_lsb[`CLASSIFIER_MEM_ADDR_LSB-1:`TOPIC_HASH_TABLE_DEPTH_NBITS+3] = 0;
  classifier_addr_lsb[`TOPIC_HASH_TABLE_DEPTH_NBITS+3-1:0] = topic_hash0<<3;

  pio_wr_seq1.pio_wr_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_wr_seq1.pio_wr_data = t_bucket[31:0];
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  classifier_addr_lsb[`TOPIC_HASH_TABLE_DEPTH_NBITS+3-1:0] = (topic_hash0<<3)|3'b100;

  pio_wr_seq1.pio_wr_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_wr_seq1.pio_wr_data = t_bucket[`TOPIC_HASH_BUCKET_NBITS-1:32];
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  classifier_addr_lsb[`TOPIC_HASH_TABLE_DEPTH_NBITS+3-1:0] = topic_hash0<<3;
  pio_rd_seq1.pio_rd_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  classifier_addr_lsb[`TOPIC_HASH_TABLE_DEPTH_NBITS+3-1:0] = (topic_hash0<<3)|3'b100;
  pio_rd_seq1.pio_rd_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  t_bucket = {tid, topic_hash0, tid, topic_hash0};

  classifier_addr_lsb[`CLASSIFIER_MEM_ADDR_RANGE] = `CLASSIFIER_TOPIC_HASH_TABLE;
  classifier_addr_lsb[`CLASSIFIER_MEM_ADDR_LSB-1:`TOPIC_HASH_TABLE_DEPTH_NBITS+3] = 1;
  classifier_addr_lsb[`TOPIC_HASH_TABLE_DEPTH_NBITS+3-1:0] = topic_hash1<<3;

  pio_wr_seq1.pio_wr_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_wr_seq1.pio_wr_data = t_bucket[31:0];
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  classifier_addr_lsb[`TOPIC_HASH_TABLE_DEPTH_NBITS+3-1:0] = (topic_hash1<<3)|3'b100;

  pio_wr_seq1.pio_wr_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_wr_seq1.pio_wr_data = t_bucket[`TOPIC_HASH_BUCKET_NBITS-1:32];
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  classifier_addr_lsb[`TOPIC_HASH_TABLE_DEPTH_NBITS+3-1:0] = topic_hash1<<3;
  pio_rd_seq1.pio_rd_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  classifier_addr_lsb[`TOPIC_HASH_TABLE_DEPTH_NBITS+3-1:0] = (topic_hash1<<3)|3'b100;
  pio_rd_seq1.pio_rd_addr = {`CLASSIFIER_BLOCK_ADDR, classifier_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  ///////////////////////////////////////////////////////////////
  
  encap_key = sci0;

  tunnel_hash = hash_encap(encap_key);
  tunnel_hash1 = hash_encap(transpose_encap(encap_key));

  $display("encap_key=%h, tunnel_hash=%h, tunnel_hash1=%h", encap_key, tunnel_hash, tunnel_hash1);

  tunnel_hash_entry0.valid = 0;
  tunnel_hash_entry0.value_ptr = 51;
  tunnel_hash_entry0.hash_idx = tunnel_hash1;

  tunnel_hash_entry1.valid = 1;
  tunnel_hash_entry1.value_ptr = 26;
  tunnel_hash_entry1.hash_idx = tunnel_hash1;

  encr_addr_lsb[`ENCR_MEM_ADDR_RANGE] = `ENCR_TUNNEL_HASH_TABLE;
  encr_addr_lsb[`ENCR_MEM_ADDR_LSB-1:`TUNNEL_HASH_TABLE_DEPTH_NBITS+2] = 0;
  encr_addr_lsb[`TUNNEL_HASH_TABLE_DEPTH_NBITS+2-1:0] = tunnel_hash<<2;

  pio_wr_seq1.pio_wr_addr = {`ENCR_BLOCK_ADDR, encr_addr_lsb};    
  pio_wr_seq1.pio_wr_data = {tunnel_hash_entry1.valid, tunnel_hash_entry1.value_ptr, tunnel_hash_entry1.hash_idx, tunnel_hash_entry0.valid, tunnel_hash_entry0.value_ptr, tunnel_hash_entry0.hash_idx};
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`ENCR_BLOCK_ADDR, encr_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  tunnel_value_entry0.key = encap_key;
  tunnel_value_entry0.sn = 0;
  tunnel_value_entry0.spi = 0;
  tunnel_value_entry0.mac = 48'h1234_5678_9abc;
  tunnel_value_entry0.vlan = 0;
  tunnel_value_entry0.ip_sa = 32'hfeed_1357;
  tunnel_value_entry0.ip_da = 32'hdeaf_2468;

  tunnel_value = {
  tunnel_value_entry0.sn,
  tunnel_value_entry0.spi,
  tunnel_value_entry0.mac,
  tunnel_value_entry0.vlan,
  tunnel_value_entry0.ip_sa,
  tunnel_value_entry0.ip_da,
  tunnel_value_entry0.key};

  encr_addr_lsb[`ENCR_MEM_ADDR_RANGE] = `ENCR_TUNNEL_VALUE;
  for (i = 0; i < 13; i = i+1) begin
  	encr_addr_lsb[`ENCR_MEM_ADDR_LSB-1:6] = tunnel_hash_entry1.value_ptr;
  	encr_addr_lsb[5:0] = i<<2;

  	pio_wr_seq1.pio_wr_addr = {`ENCR_BLOCK_ADDR, encr_addr_lsb};    
  	for (j = 0; j < 32; j = j+1) 
		pio_wr_seq1.pio_wr_data[j] = tunnel_value[32*i+j];

  	pio_wr_seq1.start (env.core_pio_wr_agt.seqr);
  end


  for (i = 0; i < 13; i = i+1) begin
  	encr_addr_lsb[`ENCR_MEM_ADDR_LSB-1:6] = tunnel_hash_entry1.value_ptr;
  	encr_addr_lsb[5:0] = i<<2;

  	pio_rd_seq1.pio_rd_addr = {`ENCR_BLOCK_ADDR, encr_addr_lsb};    
  	pio_rd_seq1.start (env.core_pio_rd_agt.seqr);
  end

  ///////////////////////////////////////////////////////////////
  
  tunnel_hash_entry0.valid = 1;
  tunnel_hash_entry0.value_ptr = 23;
  tunnel_hash_entry0.hash_idx = tunnel_hash;

  tunnel_hash_entry1.valid = 0;
  tunnel_hash_entry1.value_ptr = 57;
  tunnel_hash_entry1.hash_idx = tunnel_hash;

  encr_addr_lsb[`ENCR_MEM_ADDR_RANGE] = `ENCR_TUNNEL_HASH_TABLE;
  encr_addr_lsb[`ENCR_MEM_ADDR_LSB-1:`TUNNEL_HASH_TABLE_DEPTH_NBITS+2] = 1;
  encr_addr_lsb[`TUNNEL_HASH_TABLE_DEPTH_NBITS+2-1:0] = tunnel_hash1<<2;

  pio_wr_seq1.pio_wr_addr = {`ENCR_BLOCK_ADDR, encr_addr_lsb};    
  pio_wr_seq1.pio_wr_data = {tunnel_hash_entry1.valid, tunnel_hash_entry1.value_ptr, tunnel_hash_entry1.hash_idx, tunnel_hash_entry0.valid, tunnel_hash_entry0.value_ptr, tunnel_hash_entry0.hash_idx};
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`ENCR_BLOCK_ADDR, encr_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  tunnel_value_entry0.key = encap_key-1;
  tunnel_value_entry0.sn = 0;
  tunnel_value_entry0.spi = 0;
  tunnel_value_entry0.mac = 48'h1234_5678_9abc;
  tunnel_value_entry0.vlan = 0;
  tunnel_value_entry0.ip_sa = 32'hfeed_1357;
  tunnel_value_entry0.ip_da = 32'hdeaf_2468;

  tunnel_value = {
  tunnel_value_entry0.sn,
  tunnel_value_entry0.spi,
  tunnel_value_entry0.mac,
  tunnel_value_entry0.vlan,
  tunnel_value_entry0.ip_sa,
  tunnel_value_entry0.ip_da,
  tunnel_value_entry0.key};

  encr_addr_lsb[`ENCR_MEM_ADDR_RANGE] = `ENCR_TUNNEL_VALUE;
  for (i = 0; i < 13; i = i+1) begin
  	encr_addr_lsb[`ENCR_MEM_ADDR_LSB-1:6] = tunnel_hash_entry0.value_ptr;
  	encr_addr_lsb[5:0] = i<<2;

  	pio_wr_seq1.pio_wr_addr = {`ENCR_BLOCK_ADDR, encr_addr_lsb};    
  	for (j = 0; j < 32; j = j+1) 
		pio_wr_seq1.pio_wr_data[j] = tunnel_value[32*i+j];

  	pio_wr_seq1.start (env.core_pio_wr_agt.seqr);
  end


  for (i = 0; i < 13; i = i+1) begin
  	encr_addr_lsb[`ENCR_MEM_ADDR_LSB-1:6] = tunnel_hash_entry1.value_ptr;
  	encr_addr_lsb[5:0] = i<<2;

  	pio_rd_seq1.pio_rd_addr = {`ENCR_BLOCK_ADDR, encr_addr_lsb};    
  	pio_rd_seq1.start (env.core_pio_rd_agt.seqr);
  end

  ///////////////////////////////////////////////////////////////
  
  encap_key = sci1;

  tunnel_hash = hash_encap(encap_key);
  tunnel_hash1 = hash_encap(transpose_encap(encap_key));

  tunnel_hash_entry0.valid = 1;
  tunnel_hash_entry0.value_ptr = 61;
  tunnel_hash_entry0.hash_idx = tunnel_hash1;

  tunnel_hash_entry1.valid = 0;
  tunnel_hash_entry1.value_ptr = 32;
  tunnel_hash_entry1.hash_idx = tunnel_hash1;

  encr_addr_lsb[`ENCR_MEM_ADDR_RANGE] = `ENCR_TUNNEL_HASH_TABLE;
  encr_addr_lsb[`ENCR_MEM_ADDR_LSB-1:`TUNNEL_HASH_TABLE_DEPTH_NBITS+2] = 0;
  encr_addr_lsb[`TUNNEL_HASH_TABLE_DEPTH_NBITS+2-1:0] = tunnel_hash<<2;

  pio_wr_seq1.pio_wr_addr = {`ENCR_BLOCK_ADDR, encr_addr_lsb};    
  pio_wr_seq1.pio_wr_data = {tunnel_hash_entry1.valid, tunnel_hash_entry1.value_ptr, tunnel_hash_entry1.hash_idx, tunnel_hash_entry0.valid, tunnel_hash_entry0.value_ptr, tunnel_hash_entry0.hash_idx};
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`ENCR_BLOCK_ADDR, encr_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  tunnel_value_entry0.key = encap_key-1;
  tunnel_value_entry0.sn = 0;
  tunnel_value_entry0.spi = 0;
  tunnel_value_entry0.mac = 48'h1234_5678_9abc;
  tunnel_value_entry0.vlan = 0;
  tunnel_value_entry0.ip_sa = 32'hfeed_1357;
  tunnel_value_entry0.ip_da = 32'hdeaf_2468;

  tunnel_value = {
  tunnel_value_entry0.sn,
  tunnel_value_entry0.spi,
  tunnel_value_entry0.mac,
  tunnel_value_entry0.vlan,
  tunnel_value_entry0.ip_sa,
  tunnel_value_entry0.ip_da,
  tunnel_value_entry0.key};

  encr_addr_lsb[`ENCR_MEM_ADDR_RANGE] = `ENCR_TUNNEL_VALUE;
  for (i = 0; i < 13; i = i+1) begin
  	encr_addr_lsb[`ENCR_MEM_ADDR_LSB-1:6] = tunnel_hash_entry0.value_ptr;
  	encr_addr_lsb[5:0] = i<<2;

  	pio_wr_seq1.pio_wr_addr = {`ENCR_BLOCK_ADDR, encr_addr_lsb};    
  	for (j = 0; j < 32; j = j+1) 
		pio_wr_seq1.pio_wr_data[j] = tunnel_value[32*i+j];

  	pio_wr_seq1.start (env.core_pio_wr_agt.seqr);
  end


  for (i = 0; i < 13; i = i+1) begin
  	encr_addr_lsb[`ENCR_MEM_ADDR_LSB-1:6] = tunnel_hash_entry1.value_ptr;
  	encr_addr_lsb[5:0] = i<<2;

  	pio_rd_seq1.pio_rd_addr = {`ENCR_BLOCK_ADDR, encr_addr_lsb};    
  	pio_rd_seq1.start (env.core_pio_rd_agt.seqr);
  end

  ///////////////////////////////////////////////////////////////
  
  tunnel_hash_entry0.valid = 0;
  tunnel_hash_entry0.value_ptr = 24;
  tunnel_hash_entry0.hash_idx = tunnel_hash;

  tunnel_hash_entry1.valid = 1;
  tunnel_hash_entry1.value_ptr = 58;
  tunnel_hash_entry1.hash_idx = tunnel_hash;

  encr_addr_lsb[`ENCR_MEM_ADDR_RANGE] = `ENCR_TUNNEL_HASH_TABLE;
  encr_addr_lsb[`ENCR_MEM_ADDR_LSB-1:`TUNNEL_HASH_TABLE_DEPTH_NBITS+2] = 1;
  encr_addr_lsb[`TUNNEL_HASH_TABLE_DEPTH_NBITS+2-1:0] = tunnel_hash1<<2;

  pio_wr_seq1.pio_wr_addr = {`ENCR_BLOCK_ADDR, encr_addr_lsb};    
  pio_wr_seq1.pio_wr_data = {tunnel_hash_entry1.valid, tunnel_hash_entry1.value_ptr, tunnel_hash_entry1.hash_idx, tunnel_hash_entry0.valid, tunnel_hash_entry0.value_ptr, tunnel_hash_entry0.hash_idx};
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`ENCR_BLOCK_ADDR, encr_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  tunnel_value_entry0.key = encap_key;
  tunnel_value_entry0.sn = 0;
  tunnel_value_entry0.spi = 0;
  tunnel_value_entry0.mac = 48'h1234_5678_9abc;
  tunnel_value_entry0.vlan = 0;
  tunnel_value_entry0.ip_sa = 32'hfeed_1357;
  tunnel_value_entry0.ip_da = 32'hdeaf_2468;

  tunnel_value = {
  tunnel_value_entry0.sn,
  tunnel_value_entry0.spi,
  tunnel_value_entry0.mac,
  tunnel_value_entry0.vlan,
  tunnel_value_entry0.ip_sa,
  tunnel_value_entry0.ip_da,
  tunnel_value_entry0.key};

  encr_addr_lsb[`ENCR_MEM_ADDR_RANGE] = `ENCR_TUNNEL_VALUE;
  for (i = 0; i < 13; i = i+1) begin
  	encr_addr_lsb[`ENCR_MEM_ADDR_LSB-1:6] = tunnel_hash_entry1.value_ptr;
  	encr_addr_lsb[5:0] = i<<2;

  	pio_wr_seq1.pio_wr_addr = {`ENCR_BLOCK_ADDR, encr_addr_lsb};    
  	for (j = 0; j < 32; j = j+1) 
		pio_wr_seq1.pio_wr_data[j] = tunnel_value[32*i+j];

  	pio_wr_seq1.start (env.core_pio_wr_agt.seqr);
  end


  for (i = 0; i < 13; i = i+1) begin
  	encr_addr_lsb[`ENCR_MEM_ADDR_LSB-1:6] = tunnel_hash_entry1.value_ptr;
  	encr_addr_lsb[5:0] = i<<2;

  	pio_rd_seq1.pio_rd_addr = {`ENCR_BLOCK_ADDR, encr_addr_lsb};    
  	pio_rd_seq1.start (env.core_pio_rd_agt.seqr);
  end

  ///////////////////////////////////////////////////////////////
  ipv4_sa = 32'hfeed_1357;
  ipv4_da = 32'hdeaf_2468;

  decap_key = {ipv4_sa, ipv4_da};

  rci_hash = hash_decap(decap_key);
  rci_hash1 = hash_decap(transpose_decap(decap_key));

  $display("decap_key=%h, rci_hash=%h", decap_key, rci_hash);

  rci_hash_entry0.valid = 1;
  rci_hash_entry0.value_ptr = 15;
  rci_hash_entry0.hash_idx = rci_hash1;

  rci_hash_entry1.valid = 0;
  rci_hash_entry1.value_ptr = 62;
  rci_hash_entry1.hash_idx = rci_hash;

  decr_addr_lsb[`DECR_MEM_ADDR_RANGE] = `DECR_RCI_HASH_TABLE;
  decr_addr_lsb[`DECR_MEM_ADDR_LSB-1:`RCI_HASH_TABLE_DEPTH_NBITS+2] = 0;
  decr_addr_lsb[`RCI_HASH_TABLE_DEPTH_NBITS+2-1:0] = rci_hash<<2;

  pio_wr_seq1.pio_wr_addr = {`DECR_BLOCK_ADDR, decr_addr_lsb};    
  pio_wr_seq1.pio_wr_data = {rci_hash_entry1.valid, rci_hash_entry1.value_ptr, rci_hash_entry1.hash_idx, rci_hash_entry0.valid, rci_hash_entry0.value_ptr, rci_hash_entry0.hash_idx};
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`DECR_BLOCK_ADDR, decr_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  rci_value_entry0.key = decap_key;
  rci_value_entry0.rci = 1000;

  decr_addr_lsb[`DECR_MEM_ADDR_RANGE] = `DECR_RCI_VALUE;
  for (i = 0; i < 9; i = i+1) begin
  	decr_addr_lsb[`DECR_MEM_ADDR_LSB-1:6] = rci_hash_entry0.value_ptr;
  	decr_addr_lsb[5:0] = i<<2;

  	pio_wr_seq1.pio_wr_addr = {`DECR_BLOCK_ADDR, decr_addr_lsb};    
	if(i<8)
  		for (j = 0; j < 32; j = j+1) 
			pio_wr_seq1.pio_wr_data[j] = rci_value_entry0.key[32*i+j];
	else
		pio_wr_seq1.pio_wr_data = rci_value_entry0.rci;

  	pio_wr_seq1.start (env.core_pio_wr_agt.seqr);
  end


  for (i = 0; i < 9; i = i+1) begin
  	decr_addr_lsb[`DECR_MEM_ADDR_LSB-1:6] = rci_hash_entry0.value_ptr;
  	decr_addr_lsb[5:0] = i<<2;

  	pio_rd_seq1.pio_rd_addr = {`DECR_BLOCK_ADDR, decr_addr_lsb};    
  	pio_rd_seq1.start (env.core_pio_rd_agt.seqr);
  end

  rci_hash_entry0.valid = 0;
  rci_hash_entry0.value_ptr = 15;
  rci_hash_entry0.hash_idx = 1;

  rci_hash_entry1.valid = 1;
  rci_hash_entry1.value_ptr = 37;
  rci_hash_entry1.hash_idx = rci_hash;

  decr_addr_lsb[`DECR_MEM_ADDR_RANGE] = `DECR_RCI_HASH_TABLE;
  decr_addr_lsb[`DECR_MEM_ADDR_LSB-1:`RCI_HASH_TABLE_DEPTH_NBITS+2] = 1;
  decr_addr_lsb[`RCI_HASH_TABLE_DEPTH_NBITS+2-1:0] = rci_hash1<<2;

  pio_wr_seq1.pio_wr_addr = {`DECR_BLOCK_ADDR, decr_addr_lsb};    
  pio_wr_seq1.pio_wr_data = {rci_hash_entry1.valid, rci_hash_entry1.value_ptr, rci_hash_entry1.hash_idx, rci_hash_entry0.valid, rci_hash_entry0.value_ptr, rci_hash_entry0.hash_idx};
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  rci_value_entry0.key = decap_key;
  rci_value_entry0.rci = 1000;

  decr_addr_lsb[`DECR_MEM_ADDR_RANGE] = `DECR_RCI_VALUE;
  for (i = 0; i < 9; i = i+1) begin
  	decr_addr_lsb[`DECR_MEM_ADDR_LSB-1:6] = rci_hash_entry1.value_ptr;
  	decr_addr_lsb[5:0] = i<<2;

  	pio_wr_seq1.pio_wr_addr = {`DECR_BLOCK_ADDR, decr_addr_lsb};    

	if(i<8)
  		for (j = 0; j < 32; j = j+1) 
			pio_wr_seq1.pio_wr_data[j] = rci_value_entry0.key[32*i+j];
	else
		pio_wr_seq1.pio_wr_data = rci_value_entry0.rci;

  	pio_wr_seq1.start (env.core_pio_wr_agt.seqr);
  end

  for (i = 0; i < 9; i = i+1) begin
  	decr_addr_lsb[`DECR_MEM_ADDR_LSB-1:6] = rci_hash_entry1.value_ptr;
  	decr_addr_lsb[5:0] = i<<2;

  	pio_rd_seq1.pio_rd_addr = {`DECR_BLOCK_ADDR, decr_addr_lsb};    
  	pio_rd_seq1.start (env.core_pio_rd_agt.seqr);
  end

//  #1000ns;

  ///////////////////////////////////////////////////////////////
  
  limiter_no = 0;
  cir = 16'h0100;
  cir_burst = 16'h0800;
  eir = 16'h0020;
  eir_burst = 16'h0100;

  irl_addr_lsb[`IRL_MEM_ADDR_RANGE] = `IRL_LIMITING_PROFILE_CIR;
  irl_addr_lsb[`LIMITER_NBITS+2-1:0] = limiter_no<<2;

  pio_wr_seq1.pio_wr_addr = {`IRL_BLOCK_ADDR, irl_addr_lsb};    
  pio_wr_seq1.pio_wr_data = {cir_burst, cir};
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`IRL_BLOCK_ADDR, irl_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  irl_addr_lsb[`IRL_MEM_ADDR_RANGE] = `IRL_LIMITING_PROFILE_EIR;
  irl_addr_lsb[`LIMITER_NBITS+2-1:0] = limiter_no<<2;

  pio_wr_seq1.pio_wr_addr = {`IRL_BLOCK_ADDR, irl_addr_lsb};    
  pio_wr_seq1.pio_wr_data = {eir_burst, eir};
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`IRL_BLOCK_ADDR, irl_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  in_label = 20'habcde;
  in_ipv6_sa = 128'h1234_beef_5678_beef_9abc_beef_def0_beef;
  in_ipv6_da = 128'h0fde_addd_4321_addd_8765_addd_cba9_addd;

  limiter_no = 17;
  cir = 16'h1000;
  cir_burst = 16'h8000;
  eir = 16'h0200;
  eir_burst = 16'h1000;

  irl_addr_lsb[`IRL_MEM_ADDR_RANGE] = `IRL_LIMITING_PROFILE_CIR;
  irl_addr_lsb[`LIMITER_NBITS+2-1:0] = limiter_no<<2;

  pio_wr_seq1.pio_wr_addr = {`IRL_BLOCK_ADDR, irl_addr_lsb};    
  pio_wr_seq1.pio_wr_data = {cir_burst, cir};
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`IRL_BLOCK_ADDR, irl_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  irl_addr_lsb[`IRL_MEM_ADDR_RANGE] = `IRL_LIMITING_PROFILE_EIR;
  irl_addr_lsb[`LIMITER_NBITS+2-1:0] = limiter_no<<2;

  pio_wr_seq1.pio_wr_addr = {`IRL_BLOCK_ADDR, irl_addr_lsb};    
  pio_wr_seq1.pio_wr_data = {eir_burst, eir};
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`IRL_BLOCK_ADDR, irl_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  limiter_no = 23;
  cir = 16'h0800;
  cir_burst = 16'h2000;
  eir = 16'h0100;
  eir_burst = 16'h1000;

  irl_addr_lsb[`IRL_MEM_ADDR_RANGE] = `IRL_LIMITING_PROFILE_CIR;
  irl_addr_lsb[`LIMITER_NBITS+2-1:0] = limiter_no<<2;

  pio_wr_seq1.pio_wr_addr = {`IRL_BLOCK_ADDR, irl_addr_lsb};    
  pio_wr_seq1.pio_wr_data = {cir_burst, cir};
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`IRL_BLOCK_ADDR, irl_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  irl_addr_lsb[`IRL_MEM_ADDR_RANGE] = `IRL_LIMITING_PROFILE_EIR;
  irl_addr_lsb[`LIMITER_NBITS+2-1:0] = limiter_no<<2;

  pio_wr_seq1.pio_wr_addr = {`IRL_BLOCK_ADDR, irl_addr_lsb};    
  pio_wr_seq1.pio_wr_data = {eir_burst, eir};
  pio_wr_seq1.start (env.core_pio_wr_agt.seqr);

  pio_rd_seq1.pio_rd_addr = {`IRL_BLOCK_ADDR, irl_addr_lsb};    
  pio_rd_seq1.start (env.core_pio_rd_agt.seqr);

  ///////////////////////////////////////////////////////////////
  
  for(i=0; i<19; i=i+1) begin
  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_qw_aligned(1);
  mac_seq.set_type1(1);
  mac_seq.set_cur_rci(1-1, 1000);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = 8'h4;
//  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.pd_loc+8] = 8'hff;
//  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.pd_loc+9] = 8'hff;
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  #700ns;

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_qw_aligned(1);
  mac_seq.set_type2(1);
  mac_seq.set_cur_rci(1-1, 1000);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = 8'h4;
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  #700ns;

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_qw_aligned(1);
  mac_seq.start (env.mac1_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  env.port_q.port_queue[1].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_qw_aligned(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_qw_aligned(1);
  mac_seq.start (env.mac1_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  env.port_q.port_queue[1].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_qw_aligned(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_qw_aligned(1);
  mac_seq.start (env.mac1_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  env.port_q.port_queue[1].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_qw_aligned(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_qw_aligned(1);
  mac_seq.start (env.mac1_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  env.port_q.port_queue[1].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_qw_aligned(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  dma_seq2 = dma_sequence::type_id::create("dma_seq2", this);
  dma_seq2.start (env.dma2_rx_agt.seqr);
  if(i>0) begin
  dma_seq2.s_pkt.dst_rci_array = new [2];
  dma_seq2.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  dma_seq2.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  end
  env.port_q.port_queue[4].push_back(dma_seq2.s_pkt);

  dma_seq2 = dma_sequence::type_id::create("dma_seq2", this);
  dma_seq2.start (env.dma3_rx_agt.seqr);
  if(i>0) begin
  dma_seq2.s_pkt.dst_rci_array = new [2];
  dma_seq2.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  dma_seq2.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  end
  env.port_q.port_queue[5].push_back(dma_seq2.s_pkt);

  dma_seq2 = dma_sequence::type_id::create("dma_seq2", this);
  dma_seq2.start (env.dma2_rx_agt.seqr);
  if(i>0) begin
  dma_seq2.s_pkt.dst_rci_array = new [2];
  dma_seq2.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  dma_seq2.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  end
  env.port_q.port_queue[4].push_back(dma_seq2.s_pkt);

  dma_seq2 = dma_sequence::type_id::create("dma_seq2", this);
  dma_seq2.start (env.dma3_rx_agt.seqr);
  if(i>0) begin
  dma_seq2.s_pkt.dst_rci_array = new [2];
  dma_seq2.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  dma_seq2.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  end
  env.port_q.port_queue[5].push_back(dma_seq2.s_pkt);

  #700ns;

  dma_seq1 = dma_sequence::type_id::create("dma_seq1", this);
  dma_seq1.set_type1(1);
  dma_seq1.set_cur_rci(1-1, 1000);
  dma_seq1.start (env.dma0_rx_agt.seqr);
  dma_seq1.s_pkt.dst_rci_array = new [2];
  dma_seq1.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  dma_seq1.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  dma_seq1.s_pkt.packet_data[dma_seq1.s_pkt.prev_hop_loc+1] = 8'h4;
//  dma_seq1.s_pkt.packet_data[dma_seq1.s_pkt.pd_loc+8] = 8'hff;
//  dma_seq1.s_pkt.packet_data[dma_seq1.s_pkt.pd_loc+9] = 8'hff;
  env.port_q.port_queue[2].push_back(dma_seq1.s_pkt);

  #700ns;

  dma_seq1 = dma_sequence::type_id::create("dma_seq1", this);
  dma_seq1.set_type2(1);
  dma_seq1.set_cur_rci(1-1, 1000);
  dma_seq1.start (env.dma0_rx_agt.seqr);
  dma_seq1.s_pkt.dst_rci_array = new [2];
  dma_seq1.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  dma_seq1.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  dma_seq1.s_pkt.packet_data[dma_seq1.s_pkt.prev_hop_loc+1] = 8'h4;
  env.port_q.port_queue[2].push_back(dma_seq1.s_pkt);

  #700ns;

  dma_seq1 = dma_sequence::type_id::create("dma_seq1", this);
  dma_seq1.start (env.dma1_rx_agt.seqr);
  dma_seq1.s_pkt.dst_rci_array = new [2];
  dma_seq1.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  dma_seq1.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  env.port_q.port_queue[3].push_back(dma_seq1.s_pkt);

  dma_seq1 = dma_sequence::type_id::create("dma_seq1", this);
  dma_seq1.start (env.dma0_rx_agt.seqr);
  dma_seq1.s_pkt.dst_rci_array = new [2];
  dma_seq1.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  dma_seq1.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  env.port_q.port_queue[2].push_back(dma_seq1.s_pkt);

  dma_seq1 = dma_sequence::type_id::create("dma_seq1", this);
  dma_seq1.start (env.dma1_rx_agt.seqr);
  dma_seq1.s_pkt.dst_rci_array = new [2];
  dma_seq1.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  dma_seq1.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  env.port_q.port_queue[3].push_back(dma_seq1.s_pkt);

  dma_seq1 = dma_sequence::type_id::create("dma_seq1", this);
  dma_seq1.start (env.dma0_rx_agt.seqr);
  dma_seq1.s_pkt.dst_rci_array = new [2];
  dma_seq1.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  dma_seq1.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  env.port_q.port_queue[2].push_back(dma_seq1.s_pkt);

  dma_seq1 = dma_sequence::type_id::create("dma_seq1", this);
  dma_seq1.start (env.dma0_rx_agt.seqr);
  dma_seq1.s_pkt.dst_rci_array = new [2];
  dma_seq1.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  dma_seq1.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  env.port_q.port_queue[2].push_back(dma_seq1.s_pkt);

  dma_seq1 = dma_sequence::type_id::create("dma_seq1", this);
  dma_seq1.start (env.dma0_rx_agt.seqr);
  dma_seq1.s_pkt.dst_rci_array = new [2];
  dma_seq1.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  dma_seq1.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  env.port_q.port_queue[2].push_back(dma_seq1.s_pkt);

  dma_seq1 = dma_sequence::type_id::create("dma_seq1", this);
  dma_seq1.start (env.dma1_rx_agt.seqr);
  dma_seq1.s_pkt.dst_rci_array = new [2];
  dma_seq1.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  dma_seq1.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  env.port_q.port_queue[3].push_back(dma_seq1.s_pkt);

  dma_seq2 = dma_sequence::type_id::create("dma_seq2", this);
  dma_seq2.start (env.dma2_rx_agt.seqr);
  dma_seq2.s_pkt.dst_rci_array = new [2];
  dma_seq2.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  dma_seq2.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  env.port_q.port_queue[4].push_back(dma_seq2.s_pkt);

  dma_seq2 = dma_sequence::type_id::create("dma_seq2", this);
  dma_seq2.start (env.dma3_rx_agt.seqr);
  dma_seq2.s_pkt.dst_rci_array = new [2];
  dma_seq2.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  dma_seq2.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  env.port_q.port_queue[5].push_back(dma_seq2.s_pkt);

  dma_seq2 = dma_sequence::type_id::create("dma_seq2", this);
  dma_seq2.start (env.dma2_rx_agt.seqr);
  dma_seq2.s_pkt.dst_rci_array = new [2];
  dma_seq2.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  dma_seq2.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  env.port_q.port_queue[4].push_back(dma_seq2.s_pkt);

  dma_seq2 = dma_sequence::type_id::create("dma_seq2", this);
  dma_seq2.start (env.dma3_rx_agt.seqr);
  dma_seq2.s_pkt.dst_rci_array = new [2];
  dma_seq2.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  dma_seq2.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  env.port_q.port_queue[5].push_back(dma_seq2.s_pkt);

  end

  `uvm_info ("CORE_TEST","End test",UVM_HIGH);
  #190000ns;
  phase.drop_objection (this);

endtask
