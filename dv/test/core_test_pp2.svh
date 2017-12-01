import uvm_pkg::*;
import mac_agent_pkg::*;
import dma_agent_pkg::*;
import pio_wr_agent_pkg::*;
import pio_rd_agent_pkg::*;
import ral_pkg::*;

import table_package::*;

`include "defines.vh"

class core_test_pp2 extends core_test_base;

  `uvm_component_utils_begin (core_test_pp2)
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

task core_test_pp2::main_phase (uvm_phase phase);

  int next_hop_size;
  bit rand_path = 0;

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
  reg [`PORT_ID_NBITS-1:0] tm_port_id;
  reg [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] tm_port_queue;
  reg [`THIRD_LVL_QUEUE_ID_NBITS-1:0] tm_conn_group;
  reg [`SECOND_LVL_QUEUE_ID_NBITS-1:0] tm_conn;

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
  uvm_reg_addr_t mem_addr;
  uvm_reg_data_t mem_data;

  rci_type src_rci;
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

  tm_port_id = 1;
  tm_port_queue = 2;
  tm_conn_group = 3;
  tm_conn = tm_pri;

  dst_port = tm_port_id;
  dst_sci = sci0;
  env.sb.sci2port[dst_sci] = dst_port;
  dst_sci = sci1;
  env.sb.sci2port[dst_sci] = dst_port;

  /**************************************************************/
  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  mem_addr = tm_1st_queue0;
  mem_data = tm_shaping_profile;
  env.tm_mem.tm_shaping_profile_eir0.write(status, mem_addr, mem_data);
 
  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  mem_addr = tm_1st_queue1;
  mem_data = tm_shaping_profile;
  env.tm_mem.tm_shaping_profile_eir0.write(status, mem_addr, mem_data);
 
  /**************************************************************/
  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  mem_addr = tm_1st_queue0;
  mem_data = tm_shaping_profile;
  env.tm_mem.tm_shaping_profile_cir0.write(status, mem_addr, mem_data);
 
  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  mem_addr = tm_1st_queue1;
  mem_data = tm_shaping_profile;
  env.tm_mem.tm_shaping_profile_cir0.write(status, mem_addr, mem_data);
 
  /**************************************************************/
  tm_sch_id0 = tm_conn;
  tm_pri0 = tm_pri;
  tm_en_pri0 = 1;
  tm_q_profile0 = {tm_sch_id0, tm_pri0, tm_en_pri0};

  mem_addr = tm_1st_queue0;
  mem_data = tm_q_profile0;
  env.tm_mem.tm_queue_profile0.write(status, mem_addr, mem_data);
 
  tm_sch_id0 = tm_conn;
  tm_pri0 = tm_pri;
  tm_en_pri0 = 1;
  tm_q_profile0 = {tm_sch_id0, tm_pri0, tm_en_pri0};

  mem_addr = tm_1st_queue1;
  mem_data = tm_q_profile0;
  env.tm_mem.tm_queue_profile0.write(status, mem_addr, mem_data);
 
  /**************************************************************/
  tm_1st_loc0 = 2;
  tm_last_loc0 = 3;
  tm_pri_sch_ctrl0 = {tm_last_loc0, tm_1st_loc0};

  mem_addr = tm_sch_id0;
  mem_data = tm_pri_sch_ctrl0;
  env.tm_mem.tm_pri_sch_ctrl00.write(status, mem_addr, mem_data);
 
  /**************************************************************/
  mem_addr = tm_1st_queue0;
  mem_data = tm_port_id;
  env.tm_mem.tm_fill_tb_dst0.write(status, mem_addr, mem_data);
 
  mem_addr = tm_1st_queue1;
  mem_data = tm_port_id;
  env.tm_mem.tm_fill_tb_dst0.write(status, mem_addr, mem_data);
 
  /**************************************************************/
  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  mem_addr = tm_conn;
  mem_data = tm_shaping_profile;
  env.tm_mem.tm_shaping_profile_eir1.write(status, mem_addr, mem_data);
 
  /**************************************************************/
  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  mem_addr = tm_conn;
  mem_data = tm_shaping_profile;
  env.tm_mem.tm_shaping_profile_cir1.write(status, mem_addr, mem_data);
 
  /**************************************************************/
  tm_sch_id1 = tm_conn_group;
  tm_pri1 = 3;
  tm_en_pri1 = 1;
  tm_q_profile1 = {tm_sch_id1, tm_pri1, tm_en_pri1};

  mem_addr = tm_conn;
  mem_data = tm_q_profile1;
  env.tm_mem.tm_queue_profile1.write(status, mem_addr, mem_data);
 
  /**************************************************************/
  tm_1st_loc1 = 4;
  tm_last_loc1 = 4;
  tm_pri_sch_ctrl1 = {tm_last_loc1, tm_1st_loc1};

  mem_addr = tm_sch_id1;
  mem_data = tm_pri_sch_ctrl1;
  env.tm_mem.tm_pri_sch_ctrl13.write(status, mem_addr, mem_data);
 
  /**************************************************************/
  env.tm_mem.tm_fill_tb_dst1.write(status, tm_conn, tm_port_id);
 
  /**************************************************************/
  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  env.tm_mem.tm_shaping_profile_eir2.write(status, tm_conn_group, tm_shaping_profile);

  /**************************************************************/
  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  env.tm_mem.tm_shaping_profile_cir2.write(status, tm_conn_group, tm_shaping_profile);

  /**************************************************************/
  tm_sch_id2 = tm_port_queue;
  tm_pri2 = 7;
  tm_en_pri2 = 1;
  tm_q_profile2 = {tm_sch_id2, tm_pri2, tm_en_pri2};

  env.tm_mem.tm_queue_profile2.write(status, tm_conn_group, tm_q_profile2);

  /**************************************************************/
  tm_1st_loc2 = 1;
  tm_last_loc2 = 1;
  tm_pri_sch_ctrl2 = {tm_last_loc2, tm_1st_loc2};

  env.tm_mem.tm_pri_sch_ctrl27.write(status, tm_sch_id2, tm_pri_sch_ctrl2);

  /**************************************************************/
  env.tm_mem.tm_fill_tb_dst2.write(status, tm_conn_group, tm_port_id);

  /**************************************************************/
  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  env.tm_mem.tm_shaping_profile_eir3.write(status, tm_port_queue, tm_shaping_profile);

  /**************************************************************/
  tm_cir_token = {(`CIR_NBITS){1'b1}};
  tm_cir_burst = {(`CIR_NBITS){1'b1}};
  tm_shaping_profile = {tm_cir_burst, tm_cir_token};

  env.tm_mem.tm_shaping_profile_cir3.write(status, tm_port_queue, tm_shaping_profile);

  /**************************************************************/
  tm_sch_id3 = tm_port_id;
  tm_pri3 = 6;
  tm_en_pri3 = 1;
  tm_q_profile3 = {tm_sch_id3, tm_pri3, tm_en_pri3};

  env.tm_mem.tm_queue_profile3.write(status, tm_port_queue, tm_q_profile3);

  /**************************************************************/
  tm_1st_loc3 = 5;
  tm_last_loc3 = 5;
  tm_pri_sch_ctrl3 = {tm_last_loc3, tm_1st_loc3};

  env.tm_mem.tm_pri_sch_ctrl36.write(status, tm_sch_id3, tm_pri_sch_ctrl3);

  /**************************************************************/
  env.tm_mem.tm_fill_tb_dst3.write(status, tm_port_queue, tm_port_id);

  /**************************************************************/
  tm_q_association = {tm_port_id, tm_port_queue, tm_conn_group, tm_conn};

  env.tm_mem.tm_queue_association.write(status, tm_1st_queue0, tm_q_association);

  tm_q_association = {tm_port_id, tm_port_queue, tm_conn_group, tm_conn};

  env.tm_mem.tm_queue_association.write(status, tm_1st_queue1, tm_q_association);

  /**************************************************************/

  src_rci = 1000;

  mem_addr = `DEFAULT_RCI;
  mem_data = sci0;
  env.asa_mem.asa_sci_mem.write(status, mem_addr, mem_data);
 
  dst_rci = `DEFAULT_RCI;
  dst_sci = sci0;
  env.sb.rci2sci[dst_rci] = dst_sci;

  mem_addr = `DEFAULT_RCI+1;
  mem_data = sci1;
  env.asa_mem.asa_sci_mem.write(status, mem_addr, mem_data);
 
  dst_rci = `DEFAULT_RCI+1;
  dst_sci = sci1;
  env.sb.rci2sci[dst_rci] = dst_sci;

  mem_addr = src_rci;
  mem_data = 5;
  env.asa_mem.asa_sci_mem.write(status, mem_addr, mem_data);
 
  dst_rci = src_rci;
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

  f_bucket = {1'b0, fid, flow_hash1, 1'b0, fid, flow_hash1};

  mem_addr = flow_hash0;
  mem_data = f_bucket;
  env.class_mem.flow_hash_table0.write(status, mem_addr, mem_data);
 
  f_bucket = {1'b0, fid, flow_hash0, 1'b0, fid, flow_hash0};

  mem_addr = flow_hash1;
  mem_data = f_bucket;
  env.class_mem.flow_hash_table1.write(status, mem_addr, mem_data);
 
  topic_hash0 = hash_class_topic(topic_key);
  topic_hash1 = hash_class_topic(transpose_class_topic(topic_key));

  tid = {(`TID_NBITS){1'b1}};

  t_bucket = {1'b0, tid, topic_hash1, 1'b0, tid, topic_hash1};

  mem_addr = topic_hash0;
  mem_data = t_bucket;
  env.class_mem.topic_hash_table0.write(status, mem_addr, mem_data);
 
  t_bucket = {1'b0, tid, topic_hash0, 1'b0, tid, topic_hash0};

  mem_addr = topic_hash1;
  mem_data = t_bucket;
  env.class_mem.topic_hash_table1.write(status, mem_addr, mem_data);
 
  ///////////////////////////////////////////////////////////////
  in_ipv6_da = 128'h0fde_cafe_4321_cafe_8765_cafe_cba9_cafe;

  flow_key = {in_ipv6_da, in_ipv6_sa, in_label};
  topic_key = in_ipv6_da;

  flow_hash0 = hash_class_flow(flow_key);
  flow_hash1 = hash_class_flow(transpose_class_flow(flow_key));

  f_bucket = {1'b0, fid, flow_hash1, 1'b0, fid, flow_hash1};

  mem_addr = flow_hash0;
  mem_data = f_bucket;
  env.class_mem.flow_hash_table0.write(status, mem_addr, mem_data);
 
  f_bucket = {1'b0, fid, flow_hash0, 1'b0, fid, flow_hash0};

  mem_addr = flow_hash1;
  mem_data = f_bucket;
  env.class_mem.flow_hash_table1.write(status, mem_addr, mem_data);
 
  topic_hash0 = hash_class_topic(topic_key);
  topic_hash1 = hash_class_topic(transpose_class_topic(topic_key));

  t_bucket = {1'b0, tid, topic_hash1, 1'b0, tid, topic_hash1};

  mem_addr = topic_hash0;
  mem_data = t_bucket;
  env.class_mem.topic_hash_table0.write(status, mem_addr, mem_data);
 
  t_bucket = {1'b0, tid, topic_hash0, 1'b0, tid, topic_hash0};

  mem_addr = topic_hash1;
  mem_data = t_bucket;
  env.class_mem.topic_hash_table1.write(status, mem_addr, mem_data);
 
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

  mem_addr = tunnel_hash;
  mem_data = {tunnel_hash_entry1.valid, tunnel_hash_entry1.value_ptr, tunnel_hash_entry1.hash_idx, tunnel_hash_entry0.valid, tunnel_hash_entry0.value_ptr, tunnel_hash_entry0.hash_idx};
  env.encap_mem.tunnel_hash_table0.write(status, mem_addr, mem_data);
 
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

  mem_addr = {tunnel_hash_entry1.value_ptr};
  mem_data = tunnel_value;
  env.encap_mem.tunnel_value_table.write(status, mem_addr, mem_data);
 
  ///////////////////////////////////////////////////////////////
  
  tunnel_hash_entry0.valid = 1;
  tunnel_hash_entry0.value_ptr = 23;
  tunnel_hash_entry0.hash_idx = tunnel_hash;

  tunnel_hash_entry1.valid = 0;
  tunnel_hash_entry1.value_ptr = 57;
  tunnel_hash_entry1.hash_idx = tunnel_hash;

  mem_addr = tunnel_hash1;
  mem_data = {tunnel_hash_entry1.valid, tunnel_hash_entry1.value_ptr, tunnel_hash_entry1.hash_idx, tunnel_hash_entry0.valid, tunnel_hash_entry0.value_ptr, tunnel_hash_entry0.hash_idx};
  env.encap_mem.tunnel_hash_table1.write(status, mem_addr, mem_data);
 
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

  mem_addr = {tunnel_hash_entry0.value_ptr};
  mem_data = tunnel_value;
  env.encap_mem.tunnel_value_table.write(status, mem_addr, mem_data);
 
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

  mem_addr = tunnel_hash;
  mem_data = {tunnel_hash_entry1.valid, tunnel_hash_entry1.value_ptr, tunnel_hash_entry1.hash_idx, tunnel_hash_entry0.valid, tunnel_hash_entry0.value_ptr, tunnel_hash_entry0.hash_idx};
  env.encap_mem.tunnel_hash_table0.write(status, mem_addr, mem_data);
 
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

  mem_addr = {tunnel_hash_entry0.value_ptr};
  mem_data = tunnel_value;
  env.encap_mem.tunnel_value_table.write(status, mem_addr, mem_data);
 
  ///////////////////////////////////////////////////////////////
  
  tunnel_hash_entry0.valid = 0;
  tunnel_hash_entry0.value_ptr = 24;
  tunnel_hash_entry0.hash_idx = tunnel_hash;

  tunnel_hash_entry1.valid = 1;
  tunnel_hash_entry1.value_ptr = 58;
  tunnel_hash_entry1.hash_idx = tunnel_hash;

  mem_addr = tunnel_hash1;
  mem_data = {tunnel_hash_entry1.valid, tunnel_hash_entry1.value_ptr, tunnel_hash_entry1.hash_idx, tunnel_hash_entry0.valid, tunnel_hash_entry0.value_ptr, tunnel_hash_entry0.hash_idx};
  env.encap_mem.tunnel_hash_table1.write(status, mem_addr, mem_data);
 
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

  mem_addr = {tunnel_hash_entry1.value_ptr};
  mem_data = tunnel_value;
  env.encap_mem.tunnel_value_table.write(status, mem_addr, mem_data);
 
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

  mem_addr = rci_hash;
  mem_data = {rci_hash_entry1.valid, rci_hash_entry1.value_ptr, rci_hash_entry1.hash_idx, rci_hash_entry0.valid, rci_hash_entry0.value_ptr, rci_hash_entry0.hash_idx};
  env.decap_mem.rci_hash_table0.write(status, mem_addr, mem_data);
 
  rci_value_entry0.key = decap_key;
  rci_value_entry0.rci = src_rci;

  mem_addr = {rci_hash_entry0.value_ptr};
  mem_data = {rci_value_entry0.rci, rci_value_entry0.key};
  env.decap_mem.rci_value_table.write(status, mem_addr, mem_data);
 
  rci_hash_entry0.valid = 0;
  rci_hash_entry0.value_ptr = 15;
  rci_hash_entry0.hash_idx = 1;

  rci_hash_entry1.valid = 1;
  rci_hash_entry1.value_ptr = 37;
  rci_hash_entry1.hash_idx = rci_hash;

  mem_addr = rci_hash1;
  mem_data = {rci_hash_entry1.valid, rci_hash_entry1.value_ptr, rci_hash_entry1.hash_idx, rci_hash_entry0.valid, rci_hash_entry0.value_ptr, rci_hash_entry0.hash_idx};
  env.decap_mem.rci_hash_table1.write(status, mem_addr, mem_data);
 
  rci_value_entry0.key = decap_key;
  rci_value_entry0.rci = src_rci;

  mem_addr = {rci_hash_entry1.value_ptr};
  mem_data = {rci_value_entry0.rci, rci_value_entry0.key};
  env.decap_mem.rci_value_table.write(status, mem_addr, mem_data);
 
//  #1000ns;

  ///////////////////////////////////////////////////////////////
  
  limiter_no = 0;
  cir = 16'h0100;
  cir_burst = 16'h0800;
  eir = 16'h0020;
  eir_burst = 16'h0100;

  mem_addr = limiter_no;
  mem_data = {cir_burst, cir};
  env.irl_mem.irl_cir_mem.write(status, mem_addr, mem_data);
 
  mem_data = {eir_burst, eir};
  env.irl_mem.irl_eir_mem.write(status, mem_addr, mem_data);
 
  limiter_no = 17;
  cir = 16'h1000;
  cir_burst = 16'h8000;
  eir = 16'h0200;
  eir_burst = 16'h1000;

  mem_addr = limiter_no;
  mem_data = {cir_burst, cir};
  env.irl_mem.irl_cir_mem.write(status, mem_addr, mem_data);
 
  mem_data = {eir_burst, eir};
  env.irl_mem.irl_eir_mem.write(status, mem_addr, mem_data);

  limiter_no = 23;
  cir = 16'h0800;
  cir_burst = 16'h2000;
  eir = 16'h0100;
  eir_burst = 16'h1000;

  mem_addr = limiter_no;
  mem_data = {cir_burst, cir};
  env.irl_mem.irl_cir_mem.write(status, mem_addr, mem_data);
 
  mem_data = {eir_burst, eir};
  env.irl_mem.irl_eir_mem.write(status, mem_addr, mem_data);
 
  ///////////////////////////////////////////////////////////////
  
  in_label = 20'habcde;
  in_ipv6_sa = 128'h1234_beef_5678_beef_9abc_beef_def0_beef;
  in_ipv6_da = 128'h0fde_addd_4321_addd_8765_addd_cba9_addd;

  ///////////////////////////////////////////////////////////////
  for(i=0; i<2; i=i+1) begin
  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type1(1);
  mac_seq.set_cur_rci(1-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = 8'd4;
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  #700ns;

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type2(1);
  mac_seq.set_prev_hop_idx(1);
  mac_seq.set_cur_rci(2-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  if(mac_seq.s_pkt.get_next_hop_size(1)>=1)
	  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = mac_seq.s_pkt.get_next_hop_byte_ptr(1, 0);
  else `uvm_error ("CORE_TEST", "next_hop size is 0");
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type2(1);
  mac_seq.set_prev_hop_idx(1);
  mac_seq.set_cur_rci(9-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  if(mac_seq.s_pkt.get_next_hop_size(1)>=2)
	  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = mac_seq.s_pkt.get_next_hop_byte_ptr(1, 1);
  else `uvm_error ("CORE_TEST", "next_hop size is less than 2");
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type2(1);
  mac_seq.set_prev_hop_idx(2);
  mac_seq.set_cur_rci(3-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  if(mac_seq.s_pkt.get_next_hop_size(2)>=1)
	  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = mac_seq.s_pkt.get_next_hop_byte_ptr(2, 0);
  else `uvm_error ("CORE_TEST", "next_hop size is 0");
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type2(1);
  mac_seq.set_prev_hop_idx(3);
  mac_seq.set_cur_rci(4-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  if(mac_seq.s_pkt.get_next_hop_size(3)>=1)
	  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = mac_seq.s_pkt.get_next_hop_byte_ptr(3, 0);
  else `uvm_error ("CORE_TEST", "next_hop size is 0");
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type2(1);
  mac_seq.set_prev_hop_idx(3);
  mac_seq.set_cur_rci(5-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  if(mac_seq.s_pkt.get_next_hop_size(3)>=2)
	  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = mac_seq.s_pkt.get_next_hop_byte_ptr(3, 1);
  else `uvm_error ("CORE_TEST", "next_hop size is less than 2");
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type2(1);
  mac_seq.set_prev_hop_idx(4);
  mac_seq.set_cur_rci(8-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  if(mac_seq.s_pkt.get_next_hop_size(4)>=1)
	  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = mac_seq.s_pkt.get_next_hop_byte_ptr(4, 0);
  else `uvm_error ("CORE_TEST", "next_hop size is 0");
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type2(1);
  mac_seq.set_prev_hop_idx(5);
  mac_seq.set_cur_rci(6-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  if(mac_seq.s_pkt.get_next_hop_size(5)>=1)
	  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = mac_seq.s_pkt.get_next_hop_byte_ptr(5, 0);
  else `uvm_error ("CORE_TEST", "next_hop size is 0");
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type2(1);
  mac_seq.set_prev_hop_idx(6);
  mac_seq.set_cur_rci(7-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  if(mac_seq.s_pkt.get_next_hop_size(6)>=1)
	  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = mac_seq.s_pkt.get_next_hop_byte_ptr(6, 0);
  else `uvm_error ("CORE_TEST", "next_hop size is 0");
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type2(1);
  mac_seq.set_prev_hop_idx(7);
  mac_seq.set_cur_rci(8-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  if(mac_seq.s_pkt.get_next_hop_size(7)>=1)
	  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = mac_seq.s_pkt.get_next_hop_byte_ptr(7, 0);
  else `uvm_error ("CORE_TEST", "next_hop size is 0");
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type2(1);
  mac_seq.set_prev_hop_idx(8);
  mac_seq.set_cur_rci(15-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  if(mac_seq.s_pkt.get_next_hop_size(8)>=1)
	  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = mac_seq.s_pkt.get_next_hop_byte_ptr(8, 0);
  else `uvm_error ("CORE_TEST", "next_hop size is 0");
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type2(1);
  mac_seq.set_prev_hop_idx(8);
  mac_seq.set_cur_rci(16-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  if(mac_seq.s_pkt.get_next_hop_size(8)>=2)
	  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = mac_seq.s_pkt.get_next_hop_byte_ptr(8, 1);
  else `uvm_error ("CORE_TEST", "next_hop size is less than 2");
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type2(1);
  mac_seq.set_prev_hop_idx(8);
  mac_seq.set_cur_rci(17-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  if(mac_seq.s_pkt.get_next_hop_size(8)>=3)
	  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = mac_seq.s_pkt.get_next_hop_byte_ptr(8, 2);
  else `uvm_error ("CORE_TEST", "next_hop size is less than 3");
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type2(1);
  mac_seq.set_prev_hop_idx(9);
  mac_seq.set_cur_rci(10-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  if(mac_seq.s_pkt.get_next_hop_size(9)>=1)
	  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = mac_seq.s_pkt.get_next_hop_byte_ptr(9, 0);
  else `uvm_error ("CORE_TEST", "next_hop size is 0");
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type2(1);
  mac_seq.set_prev_hop_idx(10);
  mac_seq.set_cur_rci(11-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  if(mac_seq.s_pkt.get_next_hop_size(10)>=1)
	  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = mac_seq.s_pkt.get_next_hop_byte_ptr(10, 0);
  else `uvm_error ("CORE_TEST", "next_hop size is 0");
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type2(1);
  mac_seq.set_prev_hop_idx(10);
  mac_seq.set_cur_rci(12-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  if(mac_seq.s_pkt.get_next_hop_size(10)>=2)
	  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = mac_seq.s_pkt.get_next_hop_byte_ptr(10, 1);
  else `uvm_error ("CORE_TEST", "next_hop size is less than 2");
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type2(1);
  mac_seq.set_prev_hop_idx(11);
  mac_seq.set_cur_rci(15-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  if(mac_seq.s_pkt.get_next_hop_size(11)>=1)
	  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = mac_seq.s_pkt.get_next_hop_byte_ptr(11, 0);
  else `uvm_error ("CORE_TEST", "next_hop size is 0");
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type2(1);
  mac_seq.set_prev_hop_idx(11);
  mac_seq.set_cur_rci(16-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  if(mac_seq.s_pkt.get_next_hop_size(11)>=2)
	  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = mac_seq.s_pkt.get_next_hop_byte_ptr(11, 1);
  else `uvm_error ("CORE_TEST", "next_hop size is less than 2");
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type2(1);
  mac_seq.set_prev_hop_idx(11);
  mac_seq.set_cur_rci(17-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  if(mac_seq.s_pkt.get_next_hop_size(11)>=3)
	  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = mac_seq.s_pkt.get_next_hop_byte_ptr(11, 2);
  else `uvm_error ("CORE_TEST", "next_hop size is less than 3");
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type2(1);
  mac_seq.set_prev_hop_idx(12);
  mac_seq.set_cur_rci(13-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  if(mac_seq.s_pkt.get_next_hop_size(12)>=1)
	  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = mac_seq.s_pkt.get_next_hop_byte_ptr(12, 0);
  else `uvm_error ("CORE_TEST", "next_hop size is 0");
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type2(1);
  mac_seq.set_prev_hop_idx(13);
  mac_seq.set_cur_rci(15-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  if(mac_seq.s_pkt.get_next_hop_size(13)>=1)
	  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = mac_seq.s_pkt.get_next_hop_byte_ptr(13, 0);
  else `uvm_error ("CORE_TEST", "next_hop size is 0");
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type2(1);
  mac_seq.set_prev_hop_idx(13);
  mac_seq.set_cur_rci(16-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  if(mac_seq.s_pkt.get_next_hop_size(13)>=2)
	  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = mac_seq.s_pkt.get_next_hop_byte_ptr(13, 1);
  else `uvm_error ("CORE_TEST", "next_hop size is less than 2");
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  mac_seq = mac_sequence::type_id::create("mac_seq", this);
  mac_seq.set_type2(1);
  mac_seq.set_prev_hop_idx(13);
  mac_seq.set_cur_rci(17-1, src_rci);
  if(rand_path==1) mac_seq.set_rand_path(1, 0);
  mac_seq.set_path_case(1);
  mac_seq.start (env.mac0_rx_agt.seqr);
  mac_seq.s_pkt.dst_rci_array = new [2];
  mac_seq.s_pkt.dst_rci_array[0] = `DEFAULT_RCI;
  mac_seq.s_pkt.dst_rci_array[1] = `DEFAULT_RCI+1;
  if(mac_seq.s_pkt.get_next_hop_size(13)>=3)
	  mac_seq.s_pkt.packet_data[mac_seq.s_pkt.prev_hop_loc+1] = mac_seq.s_pkt.get_next_hop_byte_ptr(13, 2);
  else `uvm_error ("CORE_TEST", "next_hop size is less than 3");
  env.port_q.port_queue[0].push_back(mac_seq.s_pkt);

  end

  `uvm_info ("CORE_TEST","End test",UVM_HIGH);
  #20000ns;
  phase.drop_objection (this);

endtask
