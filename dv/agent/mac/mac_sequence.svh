`include "defines.vh"

class mac_sequence extends uvm_sequence #(special_packet);

  special_packet s_pkt;

  mac_config mac_config_0;

  rand bit out_vlan;
  rand bit out_ipv4;
  rand bit ah;
  rand bit l2_gre;
  rand bit in_vlan;
  bit type1 = 0;
  bit type2 = 0;
  bit rand_len = 1;
  int packet_length;
  bit [15:0] prev_hop = `INITIAL_HOP;
  int prev_hop_idx = 0;
  int inst_case = 0;
  int path_case = 0;
  int cur_rci_loc = 1000;
  bit [`RCI_NBITS-1:0] cur_rci = 1000;
  bit rand_path = 0;
  bit rand_pc = 0;
  bit [127:0] in_ip_da = 128'h0fde_dada_4321_dada_8765_dada_cba9_dada;
  bit [11:0] inst_len = 26;
  bit [11:0] pd_len = 14;
  bit qw_aligned = 0;

  `uvm_object_utils_begin (mac_sequence)
      `uvm_field_int(out_vlan, UVM_ALL_ON)
      `uvm_field_int(out_ipv4, UVM_ALL_ON)
      `uvm_field_int(ah, UVM_ALL_ON)
      `uvm_field_int(l2_gre, UVM_ALL_ON)
      `uvm_field_int(in_vlan, UVM_ALL_ON)
  `uvm_object_utils_end

  function new (string name="mac_sequence");
    super.new(name);
  endfunction

  function void set_inst_case(int i_case);
        this.inst_case = i_case;
	case(this.inst_case)
		21, 22: inst_len = 58;	
		20: inst_len = 46;	
		19: inst_len = 40;	
		18: inst_len = 38;	
		1: inst_len = 34;	
		15, 16, 17: inst_len = 20;	
		2, 3, 4, 5, 6, 14, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35: inst_len = 74;	
		7, 8, 9, 10, 11, 12, 13: inst_len = 100;	
	endcase
  endfunction

  function void set_qw_aligned(bit a);
        this.qw_aligned = a;
  endfunction

  function void set_path_case(int p_case);
        this.path_case = p_case;
  endfunction

  function void set_type1(bit ty);
        this.type1 = ty;
  endfunction

  function void set_type2(bit ty);
        this.type2 = ty;
  endfunction

  function void set_in_ip_da(bit [127:0] ip_da);
        this.in_ip_da = ip_da;
  endfunction

  function void set_inst_len(bit [11:0] len);
        this.inst_len = len;
  endfunction

  function void set_pd_len(bit [11:0] len);
        this.pd_len = len;
  endfunction

  function void set_prev_hop(bit [15:0] p_hop);
        this.prev_hop = p_hop;
  endfunction

  function void set_prev_hop_idx(int p_hop_idx);
        this.prev_hop_idx = p_hop_idx;
  endfunction

  function void set_cur_rci(int c_rci_loc, bit [`RCI_NBITS-1:0] c_rci);
        this.cur_rci_loc = c_rci_loc;
        this.cur_rci = c_rci;
  endfunction

  function void set_rand_path(bit rpath, bit rpc);
        this.rand_path = rpath;
        this.rand_pc = rpc;
  endfunction

  function bit get_type1();
        return this.type1;
  endfunction

  constraint def_c {
	soft out_vlan == 0;
	soft out_ipv4 == 1;
	soft ah == 0;
	soft l2_gre == 1;
	soft in_vlan == 0;
  }

  extern virtual task body ();

endclass

task mac_sequence::body ();
  
  if (starting_phase != null) 
	starting_phase.raise_objection(this);

  if (!(uvm_config_db#(mac_config)::get(m_sequencer,"","mac_config",mac_config_0)))
      `uvm_fatal("MAC_SEQUENCE","mac_config not found")

  if (rand_len == 1) 
    std::randomize(packet_length) with {packet_length dist{78 :=50, [79:321] :/ 25, [322:381] :/25};};
  else packet_length = 78;

   s_pkt = new("special_packet");
   req = new("special_packet");
   req.set_type1(this.type1);
   req.set_type2(this.type2);
   req.set_packet_length(this.packet_length);
   req.set_in_ip_da(this.in_ip_da);
   req.set_prev_hop(this.prev_hop);
   req.set_prev_hop_idx(this.prev_hop_idx);
   req.set_cur_rci(this.cur_rci_loc, this.cur_rci);
   req.set_rand_path(this.rand_path, this.rand_pc);
   req.set_inst_case(this.inst_case);
   req.set_path_case(this.path_case);
   req.set_inst_len(this.inst_len);
   req.set_pd_len(this.pd_len);
   req.set_qw_aligned(qw_aligned);
   start_item(req);
   req.randomize() with {s_src_port == mac_config_0.mac_num; s_packet_num == mac_config_0.packet_num; out_vlan == this.out_vlan; out_ipv4 == this.out_ipv4; ah==this.ah; l2_gre==this.l2_gre; in_vlan==this.in_vlan;}; 
   s_pkt.copy(req);
   finish_item(req);
  
   mac_config_0.packet_num++;

   if (starting_phase != null) 
	starting_phase.drop_objection(this);

endtask
