`ifndef SPECIAL_PACKET_SVH
`define SPECIAL_PACKET_SVH

`include "defines.vh"

typedef bit [`RCI_NBITS-1:0] rci_type;
typedef bit [`SCI_NBITS-1:0] sci_type;
typedef bit [`PORT_ID_NBITS-1:0] port_id_type;

class mac_hdr_class extends uvm_object;
  rand bit [47:0] da;
  rand bit [47:0] sa;
  bit [15:0] etype;

  constraint mac_soft_const {
        soft da == 48'h1234_5678_9abc;
        soft sa == 48'hfedc_ba98_7654;
  }
    `uvm_object_utils_begin(mac_hdr_class)
      `uvm_field_int(da, UVM_ALL_ON)
      `uvm_field_int(sa, UVM_ALL_ON)
    `uvm_object_utils_end

  function void get_hdr_data(ref logic [7:0] data_array[14]);
     {data_array[0], data_array[1], data_array[2], data_array[3], data_array[4], data_array[5]} = da;
     {data_array[0+6], data_array[1+6], data_array[2+6], data_array[3+6], data_array[4+6], data_array[5+6]} = sa;
     data_array[12] = etype [15:8];
     data_array[13] = etype [7:0];
  endfunction

endclass

class vlan_hdr_class extends uvm_object;
  rand bit [15:0] tpid; 
  rand bit [2:0] pri;
  rand bit [0:0] cfi;
  rand bit [11:0] vlanid;

  constraint vlan_soft_const {
        soft tpid == 16'h8100;
	soft pri  == 0;
  }

    `uvm_object_utils_begin(vlan_hdr_class)
      `uvm_field_int(tpid, UVM_ALL_ON)
      `uvm_field_int(pri, UVM_ALL_ON)
      `uvm_field_int(cfi, UVM_ALL_ON)
      `uvm_field_int(vlanid, UVM_ALL_ON)
    `uvm_object_utils_end

  function void get_hdr_data(ref logic [7:0] data_array[4]);
     data_array[0] = tpid [15:8];
     data_array[1] = tpid [7:0];
     {data_array[2], data_array[3]} = {pri, cfi, vlanid};
  endfunction

endclass

class ipv4_hdr_class extends uvm_object;
  rand bit [3:0] version;
  rand bit [3:0] hdr_len; 
  rand bit [7:0] tos;
  rand bit [15:0] len;
  rand bit [15:0] id;
  rand bit [2:0] flags; 
  rand bit [12:0] frag_offset;
  rand bit [7:0] ttl;
  rand bit [7:0] protocol;
  rand bit [15:0] checksum;
  rand bit [31:0] sa;
  rand bit [31:0] da;

  constraint ipv4_soft_const {
        soft version == 4'h4; 
        soft hdr_len == 4'h5; 
        soft tos == 8'h56;
        soft len == 134; 
        soft id == 16'ha55a;
        soft flags == 3'h0;
        soft frag_offset == 13'h0;
        soft ttl == 8'hd1;
        soft protocol == 8'd47; 
        soft checksum == 16'h0;
        soft sa == 32'hfeed_1357;
        soft da == 32'hdeaf_2468;
  }
    `uvm_object_utils_begin(ipv4_hdr_class)
      `uvm_field_int(version, UVM_ALL_ON)
      `uvm_field_int(hdr_len, UVM_ALL_ON)
      `uvm_field_int(tos, UVM_ALL_ON)
      `uvm_field_int(len, UVM_ALL_ON)
      `uvm_field_int(id, UVM_ALL_ON)
      `uvm_field_int(flags, UVM_ALL_ON)
      `uvm_field_int(frag_offset, UVM_ALL_ON)
      `uvm_field_int(ttl, UVM_ALL_ON)
      `uvm_field_int(protocol, UVM_ALL_ON)
      `uvm_field_int(checksum, UVM_ALL_ON)
      `uvm_field_int(sa, UVM_ALL_ON)
      `uvm_field_int(da, UVM_ALL_ON)
    `uvm_object_utils_end

  function bit [15:0] ones_complement_add(bit [15:0] a, bit [15:0] b); 

    bit [16:0] sum;

    sum = a+b;

    while (sum[16]==1) sum = sum[15:0]+1;

    ones_complement_add = sum[15:0];
    
  endfunction

  function bit [15:0] ipv4_checksum(ref logic [7:0] data_array[20]);

    bit [15:0] sum = 16'h0;

    for (int i=0; i < 20; i=i+2) 
    	sum = ones_complement_add(sum, {data_array[i], data_array[i+1]});
    
    ipv4_checksum = ~sum;

  endfunction
 
  function void get_hdr_data(ref logic [7:0] data_array[20]);
        data_array[0] = {version, hdr_len};
        data_array[1] = tos;
        {data_array[2], data_array[3]} = len;
        {data_array[4], data_array[5]} = id;
        {data_array[6], data_array[7]} = {flags, frag_offset};
        data_array[8] = ttl;
        data_array[9] = protocol;
        {data_array[10], data_array[11]} = checksum;
        {data_array[12], data_array[13], data_array[14], data_array[15]} = sa;
        {data_array[16], data_array[17], data_array[18], data_array[19]} = da;
	checksum = ipv4_checksum(data_array);
        {data_array[10],data_array[11]} = checksum;
  endfunction

endclass

class gre_hdr_class extends uvm_object;
  rand bit c_flag; 
  rand bit k_flag; 
  rand bit s_flag; 
  rand bit [2:0] version; 
  bit [15:0] protocol_type;

  constraint gre_soft_const {
	soft c_flag  == 0;
	soft k_flag  == 0;
	soft s_flag  == 0;
	soft version  == 0;
  }

    `uvm_object_utils_begin(gre_hdr_class)
      `uvm_field_int(c_flag, UVM_ALL_ON)
      `uvm_field_int(k_flag, UVM_ALL_ON)
      `uvm_field_int(s_flag, UVM_ALL_ON)
      `uvm_field_int(version, UVM_ALL_ON)
    `uvm_object_utils_end

  function void get_hdr_data(ref logic [7:0] data_array[4]);
     {data_array[0], data_array[1]} = {c_flag, 1'b0, k_flag, s_flag, 9'b0, version};
     {data_array[2], data_array[3]} = protocol_type;
  endfunction

endclass

class ipv6_hdr_class extends uvm_object;
  rand bit [3:0] version;
  rand bit [7:0] traffic_class;
  rand bit [19:0] flow_label;
  rand bit [15:0] payload_length;
  bit [7:0] next_header;
  rand bit [7:0] hop_limit;
  rand bit [127:0] sa;
  bit [127:0] da;

  constraint ipv6_soft_const {
        soft version == 4'h6; 
        soft traffic_class == 8'h56;
        soft flow_label == 20'habcde;
        soft payload_length == 16'h01ff;
        soft hop_limit == 8'hd1;
        soft sa == 128'h1234_bead_5678_bead_9abc_bead_def0_bead;
  }
    `uvm_object_utils_begin(ipv6_hdr_class)
      `uvm_field_int(version, UVM_ALL_ON)
      `uvm_field_int(traffic_class, UVM_ALL_ON)
      `uvm_field_int(flow_label, UVM_ALL_ON)
      `uvm_field_int(payload_length, UVM_ALL_ON)
      `uvm_field_int(hop_limit, UVM_ALL_ON)
      `uvm_field_int(sa, UVM_ALL_ON)
    `uvm_object_utils_end

  function void get_hdr_data(ref logic [7:0] data_array[40]);
	bit [127:0] addr;
        data_array[0] = {version, traffic_class[7:4]};
        data_array[1] = {traffic_class[3:0], flow_label[19:16]};
        {data_array[2], data_array[3]} = flow_label[15:0];
        {data_array[4], data_array[5]} = payload_length;
        {data_array[6], data_array[7]} = {next_header, hop_limit};
	addr = sa;
	for (int i=0; i<16; i++) begin
		data_array[i+8] = addr[127:120];
		addr = addr<<8;
	end
	addr = da;
	for (int i=0; i<16; i++) begin
		data_array[i+8+16] = addr[127:120];
		addr = addr<<8;
	end
  endfunction

endclass

class ext_hdr_class extends uvm_object;
  rand bit [7:0] next_header; 
  rand bit [7:0] hdr_ext_len;

  constraint ext_soft_const {
  	 soft next_header == 4; 
  	 soft hdr_ext_len == 10;
  }

    `uvm_object_utils_begin(ext_hdr_class)
      `uvm_field_int(next_header, UVM_ALL_ON)
      `uvm_field_int(hdr_ext_len, UVM_ALL_ON)
    `uvm_object_utils_end

  function void get_hdr_data(ref logic [7:0] data_array[2]);
     {data_array[0], data_array[1]} = {next_header, hdr_ext_len};
  endfunction

endclass

class auth_hdr_class extends uvm_object;
  rand bit [3:0] chunk_type; 
  rand bit [11:0] chunk_length;
  rand bit [3:0] version;
  rand bit [3:0] sig_alg;
  rand bit [1:0] pt;
  rand bit [5:0] ppl;
  rand bit [15:0] issuer_identifier;
  rand bit [63:0] serial_number;
  rand bit [31:0] not_before;
  rand bit [31:0] not_after;
  rand bit [23:0] domain_identifier;
  rand bit [7:0] topic_role;
  rand bit [15:0] default_maskon;
  rand bit [5:0] ba;
  rand bit [3:0] ea;
  rand bit [2:0] fa;
  rand bit [2:0] ta;
  rand bit [255:0] logic_hash;

  constraint auth_soft_const {
  	 soft chunk_type == 1; 
  	 soft chunk_length == 60;
  	 soft version == 1;
  	 soft sig_alg == 1;
  	 soft pt == 1;
  	 soft ppl == 9;
  	 soft issuer_identifier == 16'habcd;
  	 soft serial_number == 64'h1357;
  	 soft not_before == 32'h0;
  	 soft not_after == 32'hffffffff;
  	 soft domain_identifier == 24'h123456;
  	 soft topic_role == 8'h55;
  	 soft default_maskon == 16'hff7f;
  	 soft ba == 63;
  	 soft ea == 0;
  	 soft fa == 0;
  	 soft ta == 0;
  	 soft logic_hash == 0;
  }

    `uvm_object_utils_begin(auth_hdr_class)
       `uvm_field_int(chunk_type, UVM_ALL_ON)
       `uvm_field_int(chunk_length, UVM_ALL_ON)
       `uvm_field_int(version, UVM_ALL_ON)
       `uvm_field_int(sig_alg, UVM_ALL_ON)
       `uvm_field_int(pt, UVM_ALL_ON)
       `uvm_field_int(ppl, UVM_ALL_ON)
       `uvm_field_int(issuer_identifier, UVM_ALL_ON)
       `uvm_field_int(serial_number, UVM_ALL_ON)
       `uvm_field_int(not_before, UVM_ALL_ON)
       `uvm_field_int(not_after, UVM_ALL_ON)
       `uvm_field_int(domain_identifier, UVM_ALL_ON)
       `uvm_field_int(topic_role, UVM_ALL_ON)
       `uvm_field_int(default_maskon, UVM_ALL_ON)
       `uvm_field_int(ba, UVM_ALL_ON)
       `uvm_field_int(ea, UVM_ALL_ON)
       `uvm_field_int(fa, UVM_ALL_ON)
       `uvm_field_int(ta, UVM_ALL_ON)
       `uvm_field_int(logic_hash, UVM_ALL_ON)
    `uvm_object_utils_end

  function void get_hdr_data(ref logic [7:0] data_array[62]);
     bit [255:0] lh;
     {data_array[0], data_array[1]} = {chunk_type, chunk_length};
     {data_array[2], data_array[3]} = {version, sig_alg, pt, ppl};
     {data_array[4], data_array[5]} = issuer_identifier;
     {data_array[6], data_array[7], data_array[8], data_array[9], data_array[10], data_array[11], data_array[12], data_array[13]} = serial_number;
     {data_array[14], data_array[15], data_array[16], data_array[17]} = not_before;
     {data_array[18], data_array[19], data_array[20], data_array[21]} = not_after;
     {data_array[22], data_array[23], data_array[24]} = domain_identifier;
     data_array[25] = topic_role;
     {data_array[26], data_array[27]} = default_maskon;
     {data_array[28], data_array[29]} = {ba, ea, fa, ta};
     lh = logic_hash;
     for (int i=0; i<16; i++) begin
	data_array[i+30] = lh[255:255-7];
	lh = lh<<8;
     end
  endfunction

endclass

class path_hdr_class extends uvm_object;
  rand bit [3:0] chunk_type; 
  rand bit [11:0] chunk_length;
  rand bit [31:0] creation_time; 
  bit [15:0] prev_hop = `INITIAL_HOP; 
  rand bit [15:0] default_pc; 
  bit [7:0] hop [];

  constraint path_soft_const {
  	 soft chunk_type == 2; 
  	 soft chunk_length == 8;
  	 soft creation_time == 32'h0;
  	 soft default_pc == 16'h0;
  }

    `uvm_object_utils_begin(path_hdr_class)
      `uvm_field_int(chunk_type, UVM_ALL_ON)
      `uvm_field_int(chunk_length, UVM_ALL_ON)
      `uvm_field_int(creation_time, UVM_ALL_ON)
      `uvm_field_int(default_pc, UVM_ALL_ON)
    `uvm_object_utils_end

  function void get_hdr_data(ref logic [7:0] data_array[]);
     {data_array[0], data_array[1]} = {chunk_type, chunk_length};
     {data_array[2], data_array[3], data_array[4], data_array[5]} = creation_time;
     {data_array[6], data_array[7]} = prev_hop;
     {data_array[8], data_array[9]} = default_pc;
     for (int i=0; i < (chunk_length-8); i=i+1) 
    	data_array[i+10] = hop[i];
  endfunction

endclass

class inst_hdr_class extends uvm_object;
  rand bit [3:0] chunk_type; 
  rand bit [11:0] chunk_length;
  bit [15:0] inst [];

  constraint inst_soft_const {
  	 soft chunk_type == 3; 
  	 soft chunk_length == 0;
  }

    `uvm_object_utils_begin(inst_hdr_class)
      `uvm_field_int(chunk_type, UVM_ALL_ON)
      `uvm_field_int(chunk_length, UVM_ALL_ON)
    `uvm_object_utils_end

  function void get_hdr_data(ref logic [7:0] data_array[]);
     {data_array[0], data_array[1]} = {chunk_type, chunk_length};
     for (int i=0; i < chunk_length; i=i+2) 
    	{data_array[i+2], data_array[i+3]} = inst[i/2];
  endfunction

endclass

class pd_hdr_class extends uvm_object;
  rand bit [3:0] chunk_type; 
  rand bit [11:0] chunk_length;
  bit [7:0] pd [];

  constraint pd_soft_const {
  	 soft chunk_type == 4; 
  	 soft chunk_length == 0;
  }

    `uvm_object_utils_begin(pd_hdr_class)
      `uvm_field_int(chunk_type, UVM_ALL_ON)
      `uvm_field_int(chunk_length, UVM_ALL_ON)
    `uvm_object_utils_end

  function void get_hdr_data(ref logic [7:0] data_array[]);
     {data_array[0], data_array[1]} = {chunk_type, chunk_length};
     for (int i=0; i < chunk_length; i=i+1) 
    	data_array[i+2] = pd[i];
  endfunction

endclass

class special_packet extends uvm_sequence_item;
  mac_hdr_class out_mac_hdr, in_mac_hdr;
  vlan_hdr_class in_vlan_hdr, out_vlan_hdr;
  ipv4_hdr_class ipv4_hdr;
  gre_hdr_class gre_hdr;
  ipv6_hdr_class out_ipv6_hdr, ipv6_hdr;
  ext_hdr_class ext_hdr;
  auth_hdr_class auth_hdr;
  path_hdr_class path_hdr;
  inst_hdr_class inst_hdr;
  pd_hdr_class pd_hdr;
  int padding;
  bit [7:0] payload [];

  rand bit out_ipv4;
  rand bit out_vlan;
  rand bit ah;
  rand bit l2_gre;
  rand bit in_vlan;
  bit type1 = 0;
  bit type1_payload = 1;
  bit type2 = 0;

  rand bit [2:0] s_src_port;
  rand bit [7:0]  s_packet_num;
  bit qw_aligned = 0;
  int packet_length = 260;
  bit [15:0] prev_hop = `INITIAL_HOP; 
  int prev_hop_idx = 0;
  int next_hop_idx [][];
  bit dummy_hop = 0;
  int inst_case = 0;
  int path_case = 0;
  int cur_rci_loc = 1000;
  bit [`RCI_NBITS-1:0] cur_rci = 1000;
  bit rand_path = 0;
  bit rand_pc = 0;
  bit [15:0] byte_ptr [];

  constraint format_const {
	soft out_vlan == 0;
	soft out_ipv4 == 1;
	soft ah == 0;
	soft l2_gre == 1;
	soft in_vlan == 0;
        soft s_packet_num == 1;
  }

  rand bit [47:0] s_out_da;
  rand bit [47:0] s_out_sa;
  rand bit [15:0] s_out_etype;

  rand bit [15:0] s_out_tpid;
  rand bit [2:0] s_out_pri;
  rand bit [0:0] s_out_cfi;
  rand bit [11:0] s_out_vlanid;

  rand bit [47:0] s_in_da;
  rand bit [47:0] s_in_sa;
  rand bit [15:0] s_in_etype;

  rand bit [15:0] s_in_tpid;
  rand bit [2:0] s_in_pri;
  rand bit [0:0] s_in_cfi;
  rand bit [11:0] s_in_vlanid;

  rand bit [19:0] s_flow_label;
  rand bit [15:0] s_payload_length;
  rand bit [7:0] s_next_header;
  rand bit [7:0] s_hop_limit;
  rand bit [127:0] s_sa;
  rand bit [127:0] s_da;

  bit [127:0] s_in_ip_da;

  rand bit [11:0] s_path_chunk_length;
  bit [11:0] s_inst_chunk_length = 26;
  bit [11:0] s_pd_chunk_length = 14;

   
  constraint field_const {
        soft s_src_port == 3'h0;
        soft s_out_etype == 16'h0800;
        soft s_out_da == 48'h1234_5678_9abc;
        soft s_out_sa == 48'hfedc_ba98_7654;
        soft s_out_vlanid == 12'hbed;
        soft s_out_cfi == 1'b0;
        soft s_out_pri == 3'h0;
	soft s_out_tpid == 16'h8100;
        soft s_in_etype == 16'h0800;
        soft s_in_da == 48'h89ab_0000_5555;
        soft s_in_sa == 48'hcdef_3333_5555;
        soft s_in_vlanid == 12'h753;
        soft s_in_cfi == 1'b0;
        soft s_in_pri == 3'h0;
	soft s_in_tpid == 16'h86dd;
        soft s_flow_label == 20'habcde;
        soft s_payload_length == 16'h0060;
        soft s_next_header == 8'd47; 
        soft s_hop_limit == 8'hd1;
        soft s_sa == 128'h5555_bead_aaaa_bead_0000_bead_3333_bead;
        soft s_da == 128'hcccc_dada_dddd_dada_eeee_dada_ffff_dada;
	soft s_path_chunk_length == 8+30;
  }

  function void set_cur_rci(int c_rci_loc, bit [`RCI_NBITS-1:0] c_rci);
        this.cur_rci_loc = c_rci_loc;
        this.cur_rci = c_rci;
  endfunction

  function void set_rand_path(bit rpath, bit rpc);
        this.rand_path = rpath;
        this.rand_pc = rpc;
  endfunction

  function void set_prev_hop(bit [15:0] p_hop);
        this.prev_hop = p_hop;
  endfunction

  function void set_prev_hop_idx(int p_hop_idx);
        this.prev_hop_idx = p_hop_idx;
  endfunction

  function void set_inst_case(int i_case);
        this.inst_case = i_case;
  endfunction

  function void set_path_case(int p_case);
        this.path_case = p_case;
  endfunction

  function void set_packet_length(int p_len);
        this.packet_length = p_len;
  endfunction

  function void set_qw_aligned(bit a);
        this.qw_aligned = a;
  endfunction

  function void set_type1(bit tp);
        this.type1 = tp;
  endfunction

  function void set_type2(bit tp);
        this.type2 = tp;
  endfunction

  function void set_in_ip_da(bit [127:0] ip_da);
        this.s_in_ip_da = ip_da;
  endfunction

  function void set_inst_len(bit [11:0] len);
        this.s_inst_chunk_length = len;
  endfunction

  function void set_pd_len(bit [11:0] len);
        this.s_pd_chunk_length = len;
  endfunction

  function void set_etype(bit [15:0] tp);
        this.s_out_etype = tp;
  endfunction

  function bit get_type1();
        return this.type1;
  endfunction

  function int get_next_hop_size(int idx);
        return this.next_hop_idx[idx-1].size();
  endfunction

  function bit [15:0] get_next_hop(int idx, h_idx);
        return this.next_hop_idx[idx-1][h_idx];
  endfunction

  function bit [15:0] get_next_hop_byte_ptr(int idx, h_idx);
        return this.byte_ptr[this.next_hop_idx[idx-1][h_idx]-1];
  endfunction

  rci_type dst_rci_array [];
  int prev_hop_loc;
  int pd_loc;
  bit [7:0] packet_data [];

    `uvm_object_utils_begin(special_packet)
      `uvm_field_int(s_src_port, UVM_ALL_ON)
      `uvm_field_int(s_packet_num, UVM_ALL_ON)
      `uvm_field_int(out_ipv4, UVM_ALL_ON)
      `uvm_field_int(out_vlan, UVM_ALL_ON)
      `uvm_field_int(ah, UVM_ALL_ON)
      `uvm_field_int(l2_gre, UVM_ALL_ON)
      `uvm_field_int(in_vlan, UVM_ALL_ON)
      `uvm_field_object(out_mac_hdr, UVM_ALL_ON)
      `uvm_field_object(in_mac_hdr, UVM_ALL_ON)
      `uvm_field_object(out_vlan_hdr, UVM_ALL_ON)
      `uvm_field_object(in_vlan_hdr, UVM_ALL_ON)
      `uvm_field_object(ipv4_hdr, UVM_ALL_ON)
      `uvm_field_object(gre_hdr, UVM_ALL_ON)
      `uvm_field_object(ipv6_hdr, UVM_ALL_ON)
      `uvm_field_object(out_ipv6_hdr, UVM_ALL_ON)
      `uvm_field_object(ext_hdr, UVM_ALL_ON)
      `uvm_field_object(auth_hdr, UVM_ALL_ON)
      `uvm_field_object(path_hdr, UVM_ALL_ON)
      `uvm_field_object(inst_hdr, UVM_ALL_ON)
      `uvm_field_object(pd_hdr, UVM_ALL_ON)
      `uvm_field_sarray_int(payload, UVM_ALL_ON)
      `uvm_field_array_int(packet_data, UVM_ALL_ON)
//      `uvm_field_queue_int(next_hop_idx, UVM_ALL_ON)
      `uvm_field_array_int(byte_ptr, UVM_ALL_ON)
      `uvm_field_int(prev_hop_loc, UVM_ALL_ON)
      `uvm_field_int(pd_loc, UVM_ALL_ON)
    `uvm_object_utils_end

  function new (string name="special_packet");
        super.new(name);
  endfunction

  function void do_copy(uvm_object rhs);
    special_packet sp;
    super.do_copy(rhs);
    if(rhs==null) return;
    if(!$cast(sp, rhs)) return;
    
    this.next_hop_idx = sp.next_hop_idx;

  endfunction

  function void post_randomize();
    super.post_randomize();
    create_packet();
    get_hdr_data();
    print_packet();
  endfunction

  extern function void create_packet();
  extern function void get_hdr_data();
  extern function void print_packet();
  extern virtual function int compare(uvm_sequence_item exp_item);
  extern function void generate_inst_case(int i);
  extern function void generate_path_case(int i, ref bit [2:0] rci_code);
  extern function bit [31:0] generate_inst32(string s, bit [4:0] rd = 5'b0, bit [4:0] rs1 = 5'b0, bit [4:0] rs2 = 5'b0, bit [31:0] simm = 32'b0);
  extern function bit [15:0] generate_inst16(string s, bit [4:0] rd = 5'b0, bit [4:0] rs1 = 5'b0, bit [4:0] rs2 = 5'b0, bit [17:0] simm = 18'b0);
  extern function bit [31:0] generate_atomic(string s, bit [1:0] aqrl = 2'b00, bit [4:0] rd = 5'b0, bit [4:0] rs1 = 5'b0, bit [4:0] rs2 = 5'b0);

endclass

class rand_num;
	rand bit [31:0] r_num;
endclass

function void special_packet::create_packet();

  int size=0;
  int v4len=0;
  int payload_size;
  int remainder;
  int j = 0;
  bit [`RCI_NBITS-1:0] rci_value;
  bit [2:0] rci_code;
  rand_num s_num;

        out_mac_hdr = new();
        void'(out_mac_hdr.randomize() with {da == s_out_da; sa == s_out_sa; });
	size += 14;
        if (out_vlan) begin
                out_vlan_hdr = new();
                out_vlan_hdr.randomize() with
                {pri == 0; cfi == s_out_cfi; vlanid == s_out_vlanid; tpid == s_out_tpid;};
		size += 4;
        end
        if (out_ipv4) begin
		out_mac_hdr.etype = 16'h0800;
                ipv4_hdr = new();
                ipv4_hdr.randomize();
		size += 20;
		v4len = 20;
	end else begin
		out_mac_hdr.etype = 16'h86dd;
                out_ipv6_hdr = new();
                out_ipv6_hdr.randomize() with {flow_label == s_flow_label; payload_length == s_payload_length; hop_limit == s_hop_limit; sa == s_sa; da == s_da; };
                out_ipv6_hdr.next_header = 47;
		size += 40; 
		v4len = 40;
        end
        gre_hdr = new();
        gre_hdr.randomize();
	size += 4;
	v4len += 4;
        if (l2_gre) begin
        	gre_hdr.protocol_type = 16'h6558;
        	in_mac_hdr = new();
        	in_mac_hdr.randomize() with {etype == s_in_etype; da == s_in_da; sa == s_in_sa; };
		in_mac_hdr.etype = 16'h86dd;
		size += 14;
		v4len += 14;
        end else gre_hdr.protocol_type = 16'h86dd;

        if (in_vlan) begin
                in_vlan_hdr = new();
                in_vlan_hdr.randomize() with
                {pri == s_in_pri; cfi == s_in_cfi; vlanid == s_in_vlanid; tpid == s_in_tpid;};
		size += 4;
		v4len += 4;
        end
        ipv6_hdr = new();
        ipv6_hdr.randomize();
        ipv6_hdr.next_header = 6;
        ipv6_hdr.da = this.s_in_ip_da;
	size += 40; 
	v4len += 40;
        if (type1|type2) begin
        	ipv6_hdr.next_header = 253;
                ext_hdr = new();
        	if (type1) begin
                	auth_hdr = new();
                	auth_hdr.randomize();
        	end
        	path_hdr = new();

		prev_hop_loc = type1?size+2+62+2+4:size+2+2+4;

		case (path_case)
			1, 2: s_path_chunk_length = s_path_chunk_length+3*2;
			3: s_path_chunk_length = s_path_chunk_length+4*2;
			4: s_path_chunk_length = s_path_chunk_length+1*2;
			5: s_path_chunk_length = s_path_chunk_length+7*2;
			6: s_path_chunk_length = s_path_chunk_length+8*2;
			8: s_path_chunk_length = s_path_chunk_length+5*2;
			default: s_path_chunk_length = s_path_chunk_length;
		endcase

		payload_size = s_path_chunk_length-8;
		s_num = new;
        	for (int i=0; i < payload_size/2; i++) begin
		    s_num.randomize();

			generate_path_case(i, rci_code);

      			byte_ptr = new[byte_ptr.size()+1] (byte_ptr);
			byte_ptr[byte_ptr.size()-1] = j+4;

		        if(this.dummy_hop==1) rci_value = 0;
		        else if(this.cur_rci_loc==i) rci_value = this.cur_rci; 
			else if(s_num.r_num[`RCI_NBITS-1:0]>256)
				rci_value = s_num.r_num[`RCI_NBITS-1:0];
			else rci_value = 256;

			if (rand_path&rand_pc&s_num.r_num[`RCI_NBITS]) begin
      				path_hdr.hop = new[path_hdr.hop.size()+3] (path_hdr.hop);
		    		{path_hdr.hop[j], path_hdr.hop[j+1], path_hdr.hop[j+2]} = {rci_code, 1'b1, rci_value, s_num.r_num[31:23]};
				s_path_chunk_length = s_path_chunk_length+1;
				j = j+3;
			end else if (rand_path&s_num.r_num[`RCI_NBITS]) begin
      				path_hdr.hop = new[path_hdr.hop.size()+3] (path_hdr.hop);
		    		{path_hdr.hop[j], path_hdr.hop[j+1], path_hdr.hop[j+2]} = {rci_code, 1'b1, rci_value, 8'b0};
				s_path_chunk_length = s_path_chunk_length+1;
				j = j+3;
			end else begin
      				path_hdr.hop = new[path_hdr.hop.size()+2] (path_hdr.hop);
		    		{path_hdr.hop[j], path_hdr.hop[j+1]} = {rci_code, 1'b0, rci_value};
				j = j+2;
		    	end
        	end

        	path_hdr.randomize() with {chunk_length == s_path_chunk_length; };
		path_hdr.prev_hop = this.prev_hop_idx==0?this.prev_hop:byte_ptr[this.prev_hop_idx-1];

        	inst_hdr = new();
        	inst_hdr.randomize() with {chunk_length == s_inst_chunk_length; };

		payload_size = s_inst_chunk_length;
		inst_hdr.inst = new [payload_size/2];
        	for (int i=0; i < payload_size/2; i++) begin
			generate_inst_case(i);
        	end

		pd_loc = type1?size+2+62+2+s_path_chunk_length+2+s_inst_chunk_length+2:size+2+2+s_path_chunk_length+2+s_inst_chunk_length+2;

        	pd_hdr = new();
        	pd_hdr.randomize() with {chunk_length == s_pd_chunk_length; };

		payload_size = s_pd_chunk_length;
		pd_hdr.pd = new [payload_size/2];
        	for (int i=0; i < payload_size/2; i++) begin
		    s_num.randomize();
		    pd_hdr.pd[i] = {s_num.r_num[7:0]};
        	end

		payload_size = 2+(type1?62:0)+s_path_chunk_length+2+s_inst_chunk_length+2+s_pd_chunk_length+2;
		remainder = payload_size%8;
		payload_size = payload_size/8;
		payload_size = remainder>0?payload_size:payload_size-1;
		padding = remainder==0?0:8-remainder;

                ext_hdr.randomize() with {hdr_ext_len == payload_size;};

		size += (payload_size+1)*8;
		v4len += (payload_size+1)*8;
        end

	if(type1 != 1 || type1_payload == 1) begin

		if(qw_aligned==1) begin
			if(packet_length<size) packet_length = size;
			if (packet_length%8>4)
				packet_length = packet_length+8+(8-packet_length%8);
			else
				packet_length = packet_length+(8-packet_length%8);
		end else if(packet_length<(size+4)) packet_length = size+4;

		payload_size = packet_length-size;
		payload = new [payload_size];
        	for (int i=0; i < payload_size; i++) begin
              	 	if (i == payload_size-1) payload[i] = s_src_port;
               		else if (i == payload_size-2) payload[i] = s_packet_num;
               		else if (i == payload_size-3) payload[i] = 8'ha5;
               		else if (i == payload_size-4) payload[i] = 8'h5a;
               		else payload[i] = s_packet_num+i-1;
        	end

	end else begin
      		`uvm_fatal("SPECIAL_PACKET", "type1 packet without payload not supported")
		payload_size = 0;
		packet_length = size;
	end
	size += payload_size;
	v4len += payload_size;
	if (out_ipv4) ipv4_hdr.len = v4len;
	packet_data = new [size];
endfunction

function void special_packet::get_hdr_data();

    logic [7:0] out_mac_array [14];
    logic [7:0] in_mac_array [14];
    logic [7:0] out_vlan_array [4];
    logic [7:0] in_vlan_array [4];
    logic [7:0] ipv4_array [20];
    logic [7:0] gre_array [4];
    logic [7:0] out_ipv6_array [40];
    logic [7:0] ipv6_array [40];
    logic [7:0] ext_array [2];
    logic [7:0] auth_array [62];
    logic [7:0] path_array [];
    logic [7:0] inst_array [];
    logic [7:0] pd_array [];
    int idx;

    out_mac_hdr.get_hdr_data(out_mac_array);
    if (out_vlan) out_vlan_hdr.get_hdr_data(out_vlan_array);
    if (out_ipv4) ipv4_hdr.get_hdr_data(ipv4_array);
    else out_ipv6_hdr.get_hdr_data(out_ipv6_array);
    gre_hdr.get_hdr_data (gre_array);
    if (l2_gre) in_mac_hdr.get_hdr_data(in_mac_array);
    if (l2_gre&in_vlan) in_vlan_hdr.get_hdr_data(in_vlan_array);
    ipv6_hdr.get_hdr_data(ipv6_array);
    if (type1|type2) begin
	    path_array = new [path_hdr.chunk_length+2];
	    inst_array = new [inst_hdr.chunk_length+2];
	    pd_array = new [pd_hdr.chunk_length+2];

	    ext_hdr.get_hdr_data(ext_array);
	    if(type1) auth_hdr.get_hdr_data(auth_array);
	    path_hdr.get_hdr_data(path_array);
	    inst_hdr.get_hdr_data(inst_array);
	    pd_hdr.get_hdr_data(pd_array);
    end
    for (int i=0; i < 12; i++) packet_data[i] = out_mac_array[i];
    idx=12;
    if (out_vlan) begin
        for (int i=0; i < 4; i++) packet_data[idx+i] = out_vlan_array[i];
        idx=idx+4;
    end
    packet_data[idx] = out_mac_array[12];
    packet_data[idx+1] = out_mac_array[13];
    idx=idx+2;

    if (out_ipv4) begin
        for (int i=0; i < 20; i++) packet_data[idx+i] = ipv4_array[i];
        idx=idx+20;
    end else begin
        for (int i=0; i < 40; i++) packet_data[idx+i] = out_ipv6_array[i];
        idx=idx+40;
    end
    for (int i=0; i < 4; i++) packet_data[idx+i] = gre_array[i];
    idx=idx+4;
    if (l2_gre) begin
        for (int i=0; i < 12; i++) packet_data[idx+i] = in_mac_array[i];
        idx=idx+12;
    	if (in_vlan) begin
        	for (int i=0; i < 4; i++) packet_data[idx+i] = in_vlan_array[i];
        	idx=idx+4;
    	end    
	packet_data[idx] = in_mac_array[12];
    	packet_data[idx+1] = in_mac_array[13];
    	idx=idx+2;
    end
    for (int i=0; i < 40; i++) packet_data[idx+i] = ipv6_array[i];
    idx=idx+40;
    if (type1|type2) begin
        for (int i=0; i < 2; i++) packet_data[idx+i] = ext_array[i];
        idx=idx+2;
	if(type1) begin
        	for (int i=0; i < 62; i++) packet_data[idx+i] = auth_array[i];
        	idx=idx+62;
	end
	for (int i=0; i < path_hdr.chunk_length+2; i++) begin
		packet_data[idx+i] = path_array[i];
	end
        idx=idx+path_hdr.chunk_length+2;
	for (int i=0; i < inst_hdr.chunk_length+2; i++) begin
		packet_data[idx+i] = inst_array[i];
	end
        idx=idx+inst_hdr.chunk_length+2;
	for (int i=0; i < pd_hdr.chunk_length+2; i++) begin
		packet_data[idx+i] = pd_array[i];
	end
        idx=idx+pd_hdr.chunk_length+2;
	for (int i=0; i < padding; i++) 
		packet_data[idx+i] = 0;
        idx=idx+padding;
    end

    for (int i=0; i < packet_length-idx; i++) begin
	packet_data[idx+i] = payload[i];
    end
endfunction

function void special_packet::print_packet();
    
    string pr_str;
    int packet_size = this.packet_data.size();
    int byte_ptr_size = this.byte_ptr.size();

    pr_str = "\n";

    for (int i=0; i<packet_size/16+1; i++) 
        $swrite(pr_str, "%s%h %h %h %h %h %h %h %h   %h %h %h %h %h %h %h %h\n", pr_str,
            packet_data[16*i+0], packet_data[16*i+1], packet_data[16*i+2], packet_data[16*i+3],
            packet_data[16*i+4], packet_data[16*i+5], packet_data[16*i+6], packet_data[16*i+7],
            packet_data[16*i+8], packet_data[16*i+9], packet_data[16*i+10], packet_data[16*i+11],
            packet_data[16*i+12], packet_data[16*i+13], packet_data[16*i+14], packet_data[16*i+15]);
    
    for (int i=0; i<byte_ptr_size/16+1; i++) 
        $swrite(pr_str, "\n%s%d %d %d %d %d %d %d %d   %d %d %d %d %d %d %d %d\n", pr_str,
            byte_ptr[16*i+0], byte_ptr[16*i+1], byte_ptr[16*i+2], byte_ptr[16*i+3],
            byte_ptr[16*i+4], byte_ptr[16*i+5], byte_ptr[16*i+6], byte_ptr[16*i+7],
            byte_ptr[16*i+8], byte_ptr[16*i+9], byte_ptr[16*i+10], byte_ptr[16*i+11],
            byte_ptr[16*i+12], byte_ptr[16*i+13], byte_ptr[16*i+14], byte_ptr[16*i+15]);
    

    `uvm_info("SPECIAL_PACKET", pr_str, UVM_HIGH);
endfunction

function int special_packet::compare(uvm_sequence_item exp_item);

   special_packet exp_pkt;

   int error_count = 0;

   int packet_size = this.packet_data.size();

   if (!$cast(exp_pkt, exp_item)) 
      `uvm_fatal("SPECIAL_PACKET", "cannot cast to the packet object");

   for (int i =0; i < packet_size; i++) begin
     if (this.packet_data[i]!==exp_pkt.packet_data[i]) begin
       `uvm_error("SPECIAL_PACKET",
         $sformatf("MISMATCH Byte %0d Received = %0h Expected = %0h",
         i, this.packet_data[i], exp_pkt.packet_data[i]));
       error_count++;
     end else begin
       `uvm_info("SPECIAL_PACKET",
         $sformatf("MATCH    Byte %0d Received = %0h Expected = %0h",
         i, this.packet_data[i], exp_pkt.packet_data[i]), UVM_DEBUG);
     end
   end

   compare = error_count;

endfunction

function bit [31:0] special_packet::generate_atomic(string s, bit [1:0] aqrl = 2'b00, bit [4:0] rd = 5'b0, bit [4:0] rs1 = 5'b0, bit [4:0] rs2 = 5'b0);
   case (s)
		   "AMOSWAP.W": return({5'b00001, aqrl, rs2, rs1, 3'b010, rd, 7'b0101111});
		   "AMOADD.W": return({5'b00000, aqrl, rs2, rs1, 3'b010, rd, 7'b0101111});
		   "AMOXOR.W": return({5'b00100, aqrl, rs2, rs1, 3'b010, rd, 7'b0101111});
		   "AMOOR.W": return({5'b01000, aqrl, rs2, rs1, 3'b010, rd, 7'b0101111});
		   "AMOAND.W": return({5'b01100, aqrl, rs2, rs1, 3'b010, rd, 7'b0101111});
		   "AMOMIN.W": return({5'b10000, aqrl, rs2, rs1, 3'b010, rd, 7'b0101111});
		   "AMOMAX.W": return({5'b10100, aqrl, rs2, rs1, 3'b010, rd, 7'b0101111});
		   "AMOMINU.W": return({5'b11000, aqrl, rs2, rs1, 3'b010, rd, 7'b0101111});
		   "AMOMAXU.W": return({5'b11100, aqrl, rs2, rs1, 3'b010, rd, 7'b0101111});
   endcase
endfunction

function bit [15:0] special_packet::generate_inst16(string s, bit [4:0] rd = 5'b0, bit [4:0] rs1 = 5'b0, bit [4:0] rs2 = 5'b0, bit [17:0] simm = 18'b0);
   case (s)
		   "C.ADDI4SPN": return({3'b000, simm[5:4], simm[9:6], simm[2], simm[3], rd[2:0], 2'b00});
		   "C.FLD": return({3'b001, simm[5:3], rs1[2:0], simm[7:6], rd[2:0], 2'b00});
		   "C.LW": return({3'b010, simm[5:3], rs1[2:0], simm[2], simm[6], rd[2:0], 2'b00});
		   "C.FLW": return({3'b011, simm[5:3], rs1[2:0], simm[2], simm[6], rd[2:0], 2'b00});
		   "C.FSD": return({3'b101, simm[5:3], rs1[2:0], simm[7:6], rs2[2:0], 2'b00});
		   "C.SW": return({3'b110, simm[5:3], rs1[2:0], simm[2], simm[6], rs2[2:0], 2'b00});
		   "C.FSW": return({3'b111, simm[5:3], rs1[2:0], simm[2], simm[6], rs2[2:0], 2'b00});
		   "C.NOP": return({3'b000, 1'b0, 5'b00000, 5'b00000, 2'b01});
		   "C.ADDI": return({3'b000, simm[5], rd, simm[4:0], 2'b01});
		   "C.JAL": return({3'b001, simm[11], simm[4], simm[9:8], simm[10], simm[6], simm[7], simm[3:1], simm[5], 2'b01});
		   "C.LI": return({3'b010, simm[5], rd, simm[4:0],  2'b01});
		   "C.ADDI16SP": return({3'b011, simm[9], 5'b00010, simm[4], simm[6], simm[8:7],  simm[5], 2'b01});
		   "C.LUI": return({3'b011, simm[17], rd, simm[16:12],  2'b01});
		   "C.SRLI": return({3'b100, 1'b0, 2'b0, rd[2:0], simm[4:0],  2'b01});
		   "C.SRAI": return({3'b100, 1'b0, 2'b01, rd[2:0], simm[4:0],  2'b01});
		   "C.ANDI": return({3'b100, simm[5], 2'b10, rd[2:0], simm[4:0],  2'b01});
		   "C.SUB": return({3'b100, 3'b011, rd[2:0], 2'b00, rs2[2:0],  2'b01});
		   "C.XOR": return({3'b100, 3'b011, rd[2:0], 2'b01, rs2[2:0],  2'b01});
		   "C.OR": return({3'b100, 3'b011, rd[2:0], 2'b10, rs2[2:0],  2'b01});
		   "C.AND": return({3'b100, 3'b011, rd[2:0], 2'b11, rs2[2:0],  2'b01});
		   "C.SUBW": return({3'b100, 3'b111, rd[2:0], 2'b00, rs2[2:0],  2'b01});
		   "C.ADDW": return({3'b100, 3'b111, rd[2:0], 2'b01, rs2[2:0],  2'b01});
		   "C.J": return({3'b101, simm[11], simm[4], simm[9:8], simm[10], simm[6], simm[7], simm[3:1], simm[5], 2'b01});
		   "C.BEQZ": return({3'b110, simm[8], simm[4:3], rs1[2:0], simm[7:6], simm[2:1], simm[5], 2'b01});
		   "C.BNEZ": return({3'b111, simm[8], simm[4:3], rs1[2:0], simm[7:6], simm[2:1], simm[5], 2'b01});
		   "C.SLLI": return({3'b000, 1'b0, rd, simm[4:0],  2'b10});
		   "C.FLDSP": return({3'b001, simm[5], rd, simm[4:3], simm[8:6], 2'b10});
		   "C.LWSP": return({3'b010, simm[5], rd, simm[4:2], simm[7:6], 2'b10});
		   "C.FLWSP": return({3'b011, simm[5], rd, simm[4:2], simm[7:6], 2'b10});
		   "C.JR": return({3'b100, 1'b0, rs1, 5'b0, 2'b10});
		   "C.MV": return({4'b1000, rd, rs2, 2'b10});
		   "C.EBREAK": return({3'b100, 1'b1, 5'b00000, 5'b00000, 2'b10});
		   "C.JALR": return({3'b100, 1'b1, rs1, 5'b0, 2'b10});
		   "C.ADD": return({4'b1001, rd, rs2, 2'b10});
		   "C.FSDSP": return({3'b101, simm[5:3], simm[8:6], rs2, 2'b10});
		   "C.SWSP": return({3'b110, simm[5:2], simm[7:6], rs2, 2'b10});
		   "C.FSWSP": return({3'b111, simm[5:2], simm[7:6], rs2, 2'b10});
   endcase
endfunction

function bit [31:0] special_packet::generate_inst32(string s, bit [4:0] rd = 5'b0, bit [4:0] rs1 = 5'b0, bit [4:0] rs2 = 5'b0, bit [31:0] simm = 32'b0);

   case (s)
		   "LUI": return({simm[31:12], rd, 7'b0110111});
		   "AUIPC": return({simm[31:12], rd, 7'b0010111});
		   "JAL": return({simm[20], simm[10:1], simm[11], simm[19:12], rd, 7'b1101111});
		   "JALR": return({simm[11:0], rs1, 3'b000, rd, 7'b1100111});
		   "BEQ": return({simm[12], simm[10:5], rs2, rs1, 3'b000, simm[4:1], simm[11] , 7'b1100011});
		   "BNE": return({simm[12], simm[10:5], rs2, rs1, 3'b001, simm[4:1], simm[11] , 7'b1100011});
		   "BLT": return({simm[12], simm[10:5], rs2, rs1, 3'b100, simm[4:1], simm[11] , 7'b1100011});
		   "BGE": return({simm[12], simm[10:5], rs2, rs1, 3'b101, simm[4:1], simm[11] , 7'b1100011});
		   "BLTU": return({simm[12], simm[10:5], rs2, rs1, 3'b110, simm[4:1], simm[11] , 7'b1100011});
		   "BGEU": return({simm[12], simm[10:5], rs2, rs1, 3'b111, simm[4:1], simm[11] , 7'b1100011});
		   "LB": return({simm[11:0], rs1, 3'b000, rd, 7'b0000011});
		   "LH": return({simm[11:0], rs1, 3'b001, rd, 7'b0000011});
		   "LW": return({simm[11:0], rs1, 3'b010, rd, 7'b0000011});
		   "LBU": return({simm[11:0], rs1, 3'b100, rd, 7'b0000011});
		   "LHU": return({simm[11:0], rs1, 3'b101, rd, 7'b0000011});
		   "SB": return({simm[11:5], rs2, rs1, 3'b000, simm[4:0], 7'b0100011});
		   "SH": return({simm[11:5], rs2, rs1, 3'b001, simm[4:0], 7'b0100011});
		   "SW": return({simm[11:5], rs2, rs1, 3'b010, simm[4:0], 7'b0100011});
		   "ADDI": return({simm[11:0], rs1, 3'b000, rd, 7'b0010011});
		   "SLTI": return({simm[11:0], rs1, 3'b010, rd, 7'b0010011});
		   "SLTIU": return({simm[11:0], rs1, 3'b011, rd, 7'b0010011});
		   "XORI": return({simm[11:0], rs1, 3'b100, rd, 7'b0010011});
		   "ORI": return({simm[11:0], rs1, 3'b110, rd, 7'b0010011});
		   "ANDI": return({simm[11:0], rs1, 3'b111, rd, 7'b0010011});
		   "SLLI": return({5'b0, 2'b0, simm[4:0], rs1, 3'b001, rd, 7'b0010011});
		   "SRLI": return({5'b0, 2'b0, simm[4:0], rs1, 3'b101, rd, 7'b0010011});
		   "SLAI": return({5'b00000, 2'b0, simm[4:0], rs1, 3'b101, rd, 7'b0010011});
		   "SRAI": return({5'b01000, 2'b0, simm[4:0], rs1, 3'b101, rd, 7'b0010011});
		   "ADD": return({5'b0, 2'b0, rs2, rs1, 3'b000, rd, 7'b0110011});
		   "SUB": return({5'b01000, 2'b0, rs2, rs1, 3'b000, rd, 7'b0110011});
		   "SLL": return({5'b0, 2'b0, rs2, rs1, 3'b001, rd, 7'b0110011});
		   "SLT": return({5'b0, 2'b0, rs2, rs1, 3'b010, rd, 7'b0110011});
		   "SLTU": return({5'b0, 2'b0, rs2, rs1, 3'b011, rd, 7'b0110011});
		   "XOR": return({5'b0, 2'b0, rs2, rs1, 3'b100, rd, 7'b0110011});
		   "SRL": return({5'b0, 2'b0, rs2, rs1, 3'b101, rd, 7'b0110011});
		   "SRA": return({5'b01000, 2'b0, rs2, rs1, 3'b101, rd, 7'b0110011});
		   "OR": return({5'b0, 2'b0, rs2, rs1, 3'b110, rd, 7'b0110011});
		   "AND": return({5'b0, 2'b0, rs2, rs1, 3'b111, rd, 7'b0110011});
		   "ERR": return({5'b0, 2'b0, rs2, rs1, 3'b111, rd, 7'b0000111});
   endcase
endfunction

function void special_packet::generate_inst_case(int i);
  	rand_num s_num;
	s_num = new;
	s_num.randomize();

	case (inst_case)
	    25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35: begin
            	    case (i)
			    0: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADDI", `SOME_DATA_REG, 5'b0, , 32'd2);
			    1: inst_hdr.inst[i] = inst_hdr.inst[i];
			    2: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `RAS_BASE_REG, `SOME_DATA_REG, 32'd7);
			    3: inst_hdr.inst[i] = inst_hdr.inst[i];
			    4: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADDI", `SOME_DATA_REG, 5'b0, , `DEFAULT_RCI);
			    5: inst_hdr.inst[i] = inst_hdr.inst[i];
			    6: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `RAS_BASE_REG, `SOME_DATA_REG, (32'd5<<2));
			    7: inst_hdr.inst[i] = inst_hdr.inst[i];
			    8: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ORI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'h1);
			    9: inst_hdr.inst[i] = inst_hdr.inst[i];
			    10: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `RAS_BASE_REG, `SOME_DATA_REG, (32'd6<<2));
			    11: inst_hdr.inst[i] = inst_hdr.inst[i];
			    12: case(inst_case)
			    	27, 28, 29, 30, 31, 32, 33, 34, 35:{inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("LUI", `SOME_DATA_REG2, , , {20'hc5aa5, 12'b0});
			    	default:{inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("LUI", `SOME_DATA_REG, , , {20'hc5aa5, 12'b0});
				endcase
			    13: inst_hdr.inst[i] = inst_hdr.inst[i];
			    14: case (inst_case)
			    	25: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `FLOW_BASE_REG, `SOME_DATA_REG, 32'h0);
			    	26: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `TOPIC_BASE_REG, `SOME_DATA_REG, 32'h0);
			    	27, 28, 29, 30, 31, 32, 33, 34, 35: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `TOPIC_BASE_REG, `SOME_DATA_REG2, 32'h0);
				endcase
			    15: inst_hdr.inst[i] = inst_hdr.inst[i];
			    16: case (inst_case)
			    	25: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("LW", `SOME_DATA_REG1, `FLOW_BASE_REG, , 32'd0);
			    	26: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("LW", `SOME_DATA_REG1, `TOPIC_BASE_REG, , 32'd0);
			    	27: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_atomic("AMOSWAP.W", 2'b00, `SOME_DATA_REG1, `TOPIC_BASE_REG, `SOME_DATA_REG);
			    	28: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_atomic("AMOADD.W", 2'b00, `SOME_DATA_REG1, `TOPIC_BASE_REG, `SOME_DATA_REG);
			    	29: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_atomic("AMOXOR.W", 2'b00, `SOME_DATA_REG1, `TOPIC_BASE_REG, `SOME_DATA_REG);
			    	30: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_atomic("AMOOR.W", 2'b00, `SOME_DATA_REG1, `TOPIC_BASE_REG, `SOME_DATA_REG);
			    	31: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_atomic("AMOAND.W", 2'b00, `SOME_DATA_REG1, `TOPIC_BASE_REG, `SOME_DATA_REG);
			    	32: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_atomic("AMOMIN.W", 2'b00, `SOME_DATA_REG1, `TOPIC_BASE_REG, `SOME_DATA_REG);
			    	33: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_atomic("AMOMAX.W", 2'b00, `SOME_DATA_REG1, `TOPIC_BASE_REG, `SOME_DATA_REG);
			    	34: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_atomic("AMOMINU.W", 2'b00, `SOME_DATA_REG1, `TOPIC_BASE_REG, `SOME_DATA_REG);
			    	35: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_atomic("AMOMAXU.W", 2'b00, `SOME_DATA_REG1, `TOPIC_BASE_REG, `SOME_DATA_REG);
				endcase
			    17: inst_hdr.inst[i] = inst_hdr.inst[i];
			    18: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `PD_BASE_REG, `SOME_DATA_REG1, 32'h0);
			    19: inst_hdr.inst[i] = inst_hdr.inst[i];
			    20: case(inst_case)
			    	27, 28, 29, 30, 31, 32, 33, 34, 35: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("LW", `SOME_DATA_REG, `TOPIC_BASE_REG, , 32'd0);
			    	default:{inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("AUIPC", `SOME_DATA_REG, , , {20'h0123c, 12'b0});
				endcase
			    21: inst_hdr.inst[i] = inst_hdr.inst[i];
			    22: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h4);
			    23: inst_hdr.inst[i] = inst_hdr.inst[i];
			    24: case (inst_case)
			    	27, 28, 29, 30, 31, 32, 33, 34, 35: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SLLI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'h4);
			    	default: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SRLI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'h8);
				endcase
			    25: inst_hdr.inst[i] = inst_hdr.inst[i];
			    26: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h5);
			    27: inst_hdr.inst[i] = inst_hdr.inst[i];
			    28: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ANDI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'h7f);
			    29: inst_hdr.inst[i] = inst_hdr.inst[i];
			    30: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h6);
			    31: inst_hdr.inst[i] = inst_hdr.inst[i];
			    32: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("XORI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'hbf);
			    33: inst_hdr.inst[i] = inst_hdr.inst[i];
			    34: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h7);
			    35: inst_hdr.inst[i] = inst_hdr.inst[i];
			    36: inst_hdr.inst[i] = generate_inst16("C.EBREAK", , , , );
			    default: inst_hdr.inst[i] = s_num.r_num[15:0];
		    endcase
	    end
	    23, 24: begin
            	    case (i)
			    0: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADDI", `SOME_DATA_REG, 5'b0, , 32'd2);
			    1: inst_hdr.inst[i] = inst_hdr.inst[i];
			    2: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `RAS_BASE_REG, `SOME_DATA_REG, 32'd7);
			    3: inst_hdr.inst[i] = inst_hdr.inst[i];
			    4: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADDI", `SOME_DATA_REG, 5'b0, , `DEFAULT_RCI);
			    5: inst_hdr.inst[i] = inst_hdr.inst[i];
			    6: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `RAS_BASE_REG, `SOME_DATA_REG, (32'd5<<2));
			    7: inst_hdr.inst[i] = inst_hdr.inst[i];
			    8: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ORI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'h1);
			    9: inst_hdr.inst[i] = inst_hdr.inst[i];
			    10: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `RAS_BASE_REG, `SOME_DATA_REG, (32'd6<<2));
			    11: inst_hdr.inst[i] = inst_hdr.inst[i];
			    12: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = inst_case==23?
				    					generate_inst32("ERR", `SOME_DATA_REG, , , {20'hc5aa5, 12'b0}):
				    					generate_inst32("LUI", `SOME_DATA_REG, , , {20'hc5aa5, 12'b0});
			    13: inst_hdr.inst[i] = inst_hdr.inst[i];
			    14: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SH", , `PD_BASE_REG, `SOME_DATA_REG, 32'h0);
			    15: inst_hdr.inst[i] = inst_hdr.inst[i];
			    16: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SRAI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'd20);
			    17: inst_hdr.inst[i] = inst_hdr.inst[i];
			    18: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SH", , `PD_BASE_REG, `SOME_DATA_REG, 32'h2);
			    19: inst_hdr.inst[i] = inst_hdr.inst[i];
			    20: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("AUIPC", `SOME_DATA_REG, , , {20'h0123c, 12'b0});
			    21: inst_hdr.inst[i] = inst_hdr.inst[i];
			    22: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h4);
			    23: inst_hdr.inst[i] = inst_hdr.inst[i];
			    24: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SRLI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'h8);
			    25: inst_hdr.inst[i] = inst_hdr.inst[i];
			    26: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h5);
			    27: inst_hdr.inst[i] = inst_hdr.inst[i];
			    28: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ANDI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'h7f);
			    29: inst_hdr.inst[i] = inst_hdr.inst[i];
			    30: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h6);
			    31: inst_hdr.inst[i] = inst_hdr.inst[i];
			    32: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("XORI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'hbf);
			    33: inst_hdr.inst[i] = inst_hdr.inst[i];
			    34: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h7);
			    35: inst_hdr.inst[i] = inst_hdr.inst[i];
			    36: inst_hdr.inst[i] = generate_inst16("C.EBREAK", , , , );
			    default: inst_hdr.inst[i] = s_num.r_num[15:0];
		    endcase
	    end
	    21, 22: begin
            	    case (i)
			    0: {inst_hdr.inst[i]} = generate_inst16("C.J", `SOME_DATA_REG2, , , 20);
			    1: {inst_hdr.inst[i]} = generate_inst16("C.NOP", , , , );
			    2: {inst_hdr.inst[i]} = generate_inst16("C.MV", `PD_BASE_REG16, , `PD_BASE_REG, );
			    3: {inst_hdr.inst[i]} = generate_inst16("C.SW", , `PD_BASE_REG16, `SOME_DATA_REG2, 32'h0);
			    4: {inst_hdr.inst[i]} = generate_inst16("C.ADD", `SOME_DATA_REG2, , `SOME_DATA_REG2, );
			    5: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SH", , `PD_BASE_REG16, `SOME_DATA_REG2, 32'h0);
			    6: inst_hdr.inst[i] = inst_hdr.inst[i];
			    7: {inst_hdr.inst[i]} = generate_inst16("C.LI", `SOME_DATA_REG1, , , 6'h29);
			    8: {inst_hdr.inst[i]} = generate_inst16("C.SUB", `SOME_DATA_REG2, , `SOME_DATA_REG1, );
			    9: {inst_hdr.inst[i]} = generate_inst16("C.SW", , `PD_BASE_REG16, `SOME_DATA_REG2, 32'h4);
			    10: {inst_hdr.inst[i]} = generate_inst16("C.AND", `SOME_DATA_REG2, , `SOME_DATA_REG1, );
			    11: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `RAS_BASE_REG16, `SOME_DATA_REG1, 32'd7);
			    12: inst_hdr.inst[i] = inst_hdr.inst[i];
			    13: {inst_hdr.inst[i]} = generate_inst16("C.LI", `SOME_DATA_REG1, , , `DEFAULT_RCI);
			    14: {inst_hdr.inst[i]} = generate_inst16("C.LI", `SOME_DATA_REG2, , , 1);
			    15: {inst_hdr.inst[i]} = generate_inst16("C.OR", `SOME_DATA_REG1, , `SOME_DATA_REG2, );
			    16: {inst_hdr.inst[i]} = generate_inst16("C.SW", , `RAS_BASE_REG16, `SOME_DATA_REG1, (32'd6<<2));
			    17: {inst_hdr.inst[i]} = generate_inst16("C.XOR", `SOME_DATA_REG1, , `SOME_DATA_REG2, );
			    18: {inst_hdr.inst[i]} = generate_inst16("C.SW", , `RAS_BASE_REG16, `SOME_DATA_REG1, (32'd5<<2));
			    19: inst_hdr.inst[i] = generate_inst16("C.EBREAK", , , , );
			    20: {inst_hdr.inst[i]} = generate_inst16("C.MV", `RAS_BASE_REG16, , `RAS_BASE_REG, );
			    21: {inst_hdr.inst[i]} = generate_inst16("C.LW", `SOME_DATA_REG2, `RAS_BASE_REG16, , 12'd4<<2);
			    22: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("LUI", `SOME_DATA_REG1, , , {8'd27, 12'h0, 12'h0});
			    23: inst_hdr.inst[i] = inst_hdr.inst[i];
			    24: {inst_hdr.inst[i]} = generate_inst16("C.SRLI", `SOME_DATA_REG1, , , 6'd24);
			    25: {inst_hdr.inst[i]} = inst_case==21?generate_inst16("C.JALR", , `SOME_DATA_REG1, , ):
			    					generate_inst16("C.BNEZ", , `SOME_DATA_REG1, , 27-25);
			    26: {inst_hdr.inst[i]} = generate_inst16("C.NOP", `SOME_DATA_REG1, , , );
			    27: {inst_hdr.inst[i]} = generate_inst16("C.LI", `SOME_DATA_REG1, , , 1);
			    28: {inst_hdr.inst[i]} = inst_case==21?generate_inst16("C.JR", , `SOME_DATA_REG1, , ):
			    					generate_inst16("C.BEQZ", , 5'd0, , 2-28);
			    default: inst_hdr.inst[i] = s_num.r_num[15:0];
		    endcase
	    end
	    20: begin
            	    case (i)
			    0: {inst_hdr.inst[i]} = generate_inst16("C.J", `SOME_DATA_REG2, , , 20);
			    1: {inst_hdr.inst[i]} = generate_inst16("C.NOP", , , , );
			    2: {inst_hdr.inst[i]} = generate_inst16("C.MV", `PD_BASE_REG16, , `PD_BASE_REG, );
			    3: {inst_hdr.inst[i]} = generate_inst16("C.SW", , `PD_BASE_REG16, `SOME_DATA_REG2, 32'h0);
			    4: {inst_hdr.inst[i]} = generate_inst16("C.ADD", `SOME_DATA_REG2, , `SOME_DATA_REG2, );
			    5: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SH", , `PD_BASE_REG16, `SOME_DATA_REG2, 32'h0);
			    6: inst_hdr.inst[i] = inst_hdr.inst[i];
			    7: {inst_hdr.inst[i]} = generate_inst16("C.LI", `SOME_DATA_REG1, , , 6'h29);
			    8: {inst_hdr.inst[i]} = generate_inst16("C.SUB", `SOME_DATA_REG2, , `SOME_DATA_REG1, );
			    9: {inst_hdr.inst[i]} = generate_inst16("C.SW", , `PD_BASE_REG16, `SOME_DATA_REG2, 32'h4);
			    10: {inst_hdr.inst[i]} = generate_inst16("C.AND", `SOME_DATA_REG2, , `SOME_DATA_REG1, );
			    11: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `RAS_BASE_REG16, `SOME_DATA_REG1, 32'd7);
			    12: inst_hdr.inst[i] = inst_hdr.inst[i];
			    13: {inst_hdr.inst[i]} = generate_inst16("C.LI", `SOME_DATA_REG1, , , `DEFAULT_RCI);
			    14: {inst_hdr.inst[i]} = generate_inst16("C.LI", `SOME_DATA_REG2, , , 1);
			    15: {inst_hdr.inst[i]} = generate_inst16("C.OR", `SOME_DATA_REG1, , `SOME_DATA_REG2, );
			    16: {inst_hdr.inst[i]} = generate_inst16("C.SW", , `RAS_BASE_REG16, `SOME_DATA_REG1, (32'd6<<2));
			    17: {inst_hdr.inst[i]} = generate_inst16("C.XOR", `SOME_DATA_REG1, , `SOME_DATA_REG2, );
			    18: {inst_hdr.inst[i]} = generate_inst16("C.SW", , `RAS_BASE_REG16, `SOME_DATA_REG1, (32'd5<<2));
			    19: inst_hdr.inst[i] = generate_inst16("C.EBREAK", , , , );
			    20: {inst_hdr.inst[i]} = generate_inst16("C.MV", `RAS_BASE_REG16, , `RAS_BASE_REG, );
			    21: {inst_hdr.inst[i]} = generate_inst16("C.LW", `SOME_DATA_REG2, `RAS_BASE_REG16, , 12'd4<<2);
			    22: {inst_hdr.inst[i]} = generate_inst16("C.JAL", `SOME_DATA_REG1, , , (2-22));
			    default: inst_hdr.inst[i] = s_num.r_num[15:0];
		    endcase
	    end
	    19: begin
            	    case (i)
			    0: {inst_hdr.inst[i]} = generate_inst16("C.MV", `RAS_BASE_REG16, , `RAS_BASE_REG, );
			    1: {inst_hdr.inst[i]} = generate_inst16("C.LW", `SOME_DATA_REG2, `RAS_BASE_REG16, , 12'd4<<2);
			    2: {inst_hdr.inst[i]} = generate_inst16("C.MV", `PD_BASE_REG16, , `PD_BASE_REG, );
			    3: {inst_hdr.inst[i]} = generate_inst16("C.SW", , `PD_BASE_REG16, `SOME_DATA_REG2, 32'h0);
			    4: {inst_hdr.inst[i]} = generate_inst16("C.ADD", `SOME_DATA_REG2, , `SOME_DATA_REG2, );
			    5: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SH", , `PD_BASE_REG16, `SOME_DATA_REG2, 32'h0);
			    6: inst_hdr.inst[i] = inst_hdr.inst[i];
			    7: {inst_hdr.inst[i]} = generate_inst16("C.LI", `SOME_DATA_REG1, , , 6'h29);
			    8: {inst_hdr.inst[i]} = generate_inst16("C.SUB", `SOME_DATA_REG2, , `SOME_DATA_REG1, );
			    9: {inst_hdr.inst[i]} = generate_inst16("C.SW", , `PD_BASE_REG16, `SOME_DATA_REG2, 32'h4);
			    10: {inst_hdr.inst[i]} = generate_inst16("C.AND", `SOME_DATA_REG2, , `SOME_DATA_REG1, );
			    11: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `RAS_BASE_REG16, `SOME_DATA_REG1, 32'd7);
			    12: inst_hdr.inst[i] = inst_hdr.inst[i];
			    13: {inst_hdr.inst[i]} = generate_inst16("C.LI", `SOME_DATA_REG1, , , `DEFAULT_RCI);
			    14: {inst_hdr.inst[i]} = generate_inst16("C.LI", `SOME_DATA_REG2, , , 1);
			    15: {inst_hdr.inst[i]} = generate_inst16("C.OR", `SOME_DATA_REG1, , `SOME_DATA_REG2, );
			    16: {inst_hdr.inst[i]} = generate_inst16("C.SW", , `RAS_BASE_REG16, `SOME_DATA_REG1, (32'd6<<2));
			    17: {inst_hdr.inst[i]} = generate_inst16("C.XOR", `SOME_DATA_REG1, , `SOME_DATA_REG2, );
			    18: {inst_hdr.inst[i]} = generate_inst16("C.SW", , `RAS_BASE_REG16, `SOME_DATA_REG1, (32'd5<<2));
			    19: inst_hdr.inst[i] = generate_inst16("C.EBREAK", , , , );
			    default: inst_hdr.inst[i] = s_num.r_num[15:0];
		    endcase
	    end
	    18: begin
            	    case (i)
			    0: {inst_hdr.inst[i]} = generate_inst16("C.MV", `PD_BASE_REG16, , `PD_BASE_REG, );
			    1: {inst_hdr.inst[i]} = generate_inst16("C.LUI", `SOME_DATA_REG2, , , {20'hc5aa5, 12'b0});
			    2: {inst_hdr.inst[i]} = generate_inst16("C.SW", , `PD_BASE_REG16, `SOME_DATA_REG2, 32'h0);
			    3: {inst_hdr.inst[i]} = generate_inst16("C.SRAI", `SOME_DATA_REG2, , , 32'd2);
			    4: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SH", , `PD_BASE_REG16, `SOME_DATA_REG2, 32'h2);
			    5: inst_hdr.inst[i] = inst_hdr.inst[i];
			    6: {inst_hdr.inst[i]} = generate_inst16("C.LI", `SOME_DATA_REG2, , , 6'h29);
			    7: {inst_hdr.inst[i]} = generate_inst16("C.SLLI", `SOME_DATA_REG2, , , 6'd9);
			    8: {inst_hdr.inst[i]} = generate_inst16("C.SRLI", `SOME_DATA_REG2, , , 6'd2);
			    9: {inst_hdr.inst[i]} = generate_inst16("C.SW", , `PD_BASE_REG16, `SOME_DATA_REG2, 32'h4);
			    10: {inst_hdr.inst[i]} = generate_inst16("C.MV", `RAS_BASE_REG16, , `RAS_BASE_REG, );
			    11: {inst_hdr.inst[i]} = generate_inst16("C.ADDI", `SOME_DATA_REG1, , , 32'd2);
			    12: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `RAS_BASE_REG16, `SOME_DATA_REG1, 32'd7);
			    13: inst_hdr.inst[i] = inst_hdr.inst[i];
			    14: {inst_hdr.inst[i]} = generate_inst16("C.ADDI", `SOME_DATA_REG1, , , `DEFAULT_RCI+1-2);
			    15: {inst_hdr.inst[i]} = generate_inst16("C.SW", , `RAS_BASE_REG16, `SOME_DATA_REG1, (32'd6<<2));
			    16: {inst_hdr.inst[i]} = generate_inst16("C.ANDI", `SOME_DATA_REG1, , , 32'hfffffffe);
			    17: {inst_hdr.inst[i]} = generate_inst16("C.SW", , `RAS_BASE_REG16, `SOME_DATA_REG1, (32'd5<<2));
			    18: inst_hdr.inst[i] = generate_inst16("C.EBREAK", , , , );
			    default: inst_hdr.inst[i] = s_num.r_num[15:0];
		    endcase
	    end
	    17: begin
            	    case (i)
			    0: {inst_hdr.inst[i]} = generate_inst16("C.MV", `RAS_BASE_REG16, , `RAS_BASE_REG, );
			    1: {inst_hdr.inst[i]} = generate_inst16("C.NOP", , , , );
			    2: {inst_hdr.inst[i]} = generate_inst16("C.ADDI", `SOME_DATA_REG1, , , 32'd2);
			    3: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `RAS_BASE_REG16, `SOME_DATA_REG1, 32'd7);
			    4: inst_hdr.inst[i] = inst_hdr.inst[i];
			    5: {inst_hdr.inst[i]} = generate_inst16("C.ADDI", `SOME_DATA_REG1, , , `DEFAULT_RCI+1-2);
			    6: {inst_hdr.inst[i]} = generate_inst16("C.SW", , `RAS_BASE_REG16, `SOME_DATA_REG1, (32'd6<<2));
			    7: {inst_hdr.inst[i]} = generate_inst16("C.ANDI", `SOME_DATA_REG1, , , 32'hfffffffe);
			    8: {inst_hdr.inst[i]} = generate_inst16("C.SW", , `RAS_BASE_REG16, `SOME_DATA_REG1, (32'd5<<2));
			    9: inst_hdr.inst[i] = generate_inst16("C.EBREAK", , , , );
			    default: inst_hdr.inst[i] = s_num.r_num[15:0];
		    endcase
		end
	    16: begin
            	    case (i)
			    0: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADD", `RAS_BASE_REG16, `RAS_BASE_REG, `SOME_DATA_REG1, );
			    1: inst_hdr.inst[i] = inst_hdr.inst[i];
			    2: {inst_hdr.inst[i]} = generate_inst16("C.ADDI", `SOME_DATA_REG1, , , 32'd2);
			    3: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `RAS_BASE_REG16, `SOME_DATA_REG1, 32'd7);
			    4: inst_hdr.inst[i] = inst_hdr.inst[i];
			    5: {inst_hdr.inst[i]} = generate_inst16("C.ADDI", `SOME_DATA_REG1, , , `DEFAULT_RCI+1-2);
			    6: {inst_hdr.inst[i]} = generate_inst16("C.SW", , `RAS_BASE_REG16, `SOME_DATA_REG1, (32'd6<<2));
			    7: {inst_hdr.inst[i]} = generate_inst16("C.ANDI", `SOME_DATA_REG1, , , 32'hfffffffe);
			    8: {inst_hdr.inst[i]} = generate_inst16("C.SW", , `RAS_BASE_REG16, `SOME_DATA_REG1, (32'd5<<2));
			    9: inst_hdr.inst[i] = generate_inst16("C.EBREAK", , , , );
			    default: inst_hdr.inst[i] = s_num.r_num[15:0];
		    endcase
		end
	    15: begin
            	    case (i)
			    0: {inst_hdr.inst[i]} = generate_inst16("C.ADDI", `SOME_DATA_REG1, , , 32'd2);
			    1: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADD", `RAS_BASE_REG16, `RAS_BASE_REG, `SOME_DATA_REG2, );
			    2: inst_hdr.inst[i] = inst_hdr.inst[i];
			    3: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `RAS_BASE_REG16, `SOME_DATA_REG1, 32'd7);
			    4: inst_hdr.inst[i] = inst_hdr.inst[i];
			    5: {inst_hdr.inst[i]} = generate_inst16("C.ADDI", `SOME_DATA_REG1, , , `DEFAULT_RCI+1-2);
			    6: {inst_hdr.inst[i]} = generate_inst16("C.SW", , `RAS_BASE_REG16, `SOME_DATA_REG1, (32'd6<<2));
			    7: {inst_hdr.inst[i]} = generate_inst16("C.ANDI", `SOME_DATA_REG1, , , 32'hfffffffe);
			    8: {inst_hdr.inst[i]} = generate_inst16("C.SW", , `RAS_BASE_REG16, `SOME_DATA_REG1, (32'd5<<2));
			    9: inst_hdr.inst[i] = generate_inst16("C.EBREAK", , , , );
			    default: inst_hdr.inst[i] = s_num.r_num[15:0];
		    endcase
		end
	    14: begin
            	    case (i)
			    0: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("LUI", `SOME_DATA_REG, , , {20'hc5aa5, 12'b0});
			    1: inst_hdr.inst[i] = inst_hdr.inst[i];
			    2: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SLTIU", `SOME_DATA_REG1, 5'd0, , 32'h1);
			    3: inst_hdr.inst[i] = inst_hdr.inst[i];
			    4: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SRA", `SOME_DATA_REG, `SOME_DATA_REG, `SOME_DATA_REG1, );
			    5: inst_hdr.inst[i] = inst_hdr.inst[i];
			    6: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `PD_BASE_REG, `SOME_DATA_REG, 32'h0);
			    7: inst_hdr.inst[i] = inst_hdr.inst[i];
			    8: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("AUIPC", `SOME_DATA_REG, , , {20'h0123c, 12'b0});
			    9: inst_hdr.inst[i] = inst_hdr.inst[i];
			    10: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h4);
			    11: inst_hdr.inst[i] = inst_hdr.inst[i];
			    12: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SRLI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'h8);
			    13: inst_hdr.inst[i] = inst_hdr.inst[i];
			    14: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h5);
			    15: inst_hdr.inst[i] = inst_hdr.inst[i];
			    16: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ANDI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'h7f);
			    17: inst_hdr.inst[i] = inst_hdr.inst[i];
			    18: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h6);
			    19: inst_hdr.inst[i] = inst_hdr.inst[i];
			    20: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("XORI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'hbf);
			    21: inst_hdr.inst[i] = inst_hdr.inst[i];
			    22: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h7);
			    23: inst_hdr.inst[i] = inst_hdr.inst[i];
			    24: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADDI", `SOME_DATA_REG, 5'b0, , 32'd2);
			    25: inst_hdr.inst[i] = inst_hdr.inst[i];
			    26: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `RAS_BASE_REG, `SOME_DATA_REG, 32'd7);
			    27: inst_hdr.inst[i] = inst_hdr.inst[i];
			    28: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADDI", `SOME_DATA_REG, 5'b0, , `DEFAULT_RCI);
			    29: inst_hdr.inst[i] = inst_hdr.inst[i];
			    30: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `RAS_BASE_REG, `SOME_DATA_REG, (32'd5<<2));
			    31: inst_hdr.inst[i] = inst_hdr.inst[i];
			    32: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ORI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'h1);
			    33: inst_hdr.inst[i] = inst_hdr.inst[i];
			    34: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `RAS_BASE_REG, `SOME_DATA_REG, (32'd6<<2));
			    35: inst_hdr.inst[i] = inst_hdr.inst[i];
			    36: inst_hdr.inst[i] = generate_inst16("C.EBREAK", , , , );
			    default: inst_hdr.inst[i] = s_num.r_num[15:0];
		    endcase
	    end
		7, 8, 9, 10, 11, 12, 13: begin
            	    case (i)
			    0: case (inst_case) 
			    	9:{inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("BEQ", , `SOME_DATA_REG2, 5'd0, 32'd38);
			    	10, 11:{inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("BLT", , `SOME_DATA_REG2, `RAS_BASE_REG, 32'd38);
			    	12, 13:{inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("BLTU", , `SOME_DATA_REG2, `RAS_BASE_REG, 32'd38);
			    	default:{inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("JAL", `SOME_DATA_REG2, , , 32'd38);
			       endcase
			    1: inst_hdr.inst[i] = inst_hdr.inst[i];
			    2: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SH", , `PD_BASE_REG, `SOME_DATA_REG1, 32'h0);
			    3: inst_hdr.inst[i] = inst_hdr.inst[i];
			    4: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SUB", `SOME_DATA_REG, 5'd0, `SOME_DATA_REG1, );
			    5: inst_hdr.inst[i] = inst_hdr.inst[i];
			    6: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SH", , `PD_BASE_REG, `SOME_DATA_REG, 32'h2);
			    7: inst_hdr.inst[i] = inst_hdr.inst[i];
			    8: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("LW", `SOME_DATA_REG, `RAS_BASE_REG, , (4<<2));
			    9: inst_hdr.inst[i] = inst_hdr.inst[i];
			    10: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h4);
			    11: inst_hdr.inst[i] = inst_hdr.inst[i];
			    12: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADD", `SOME_DATA_REG, `SOME_DATA_REG, `SOME_DATA_REG1, );
			    13: inst_hdr.inst[i] = inst_hdr.inst[i];
			    14: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h5);
			    15: inst_hdr.inst[i] = inst_hdr.inst[i];
			    16: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("OR", `SOME_DATA_REG, `SOME_DATA_REG, `SOME_DATA_REG1, );
			    17: inst_hdr.inst[i] = inst_hdr.inst[i];
			    18: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h6);
			    19: inst_hdr.inst[i] = inst_hdr.inst[i];
			    20: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("AND", `SOME_DATA_REG, `SOME_DATA_REG, `SOME_DATA_REG1, );
			    21: inst_hdr.inst[i] = inst_hdr.inst[i];
			    22: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h7);
			    23: inst_hdr.inst[i] = inst_hdr.inst[i];
			    24: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADDI", `SOME_DATA_REG, 5'b0, , 32'd2);
			    25: inst_hdr.inst[i] = inst_hdr.inst[i];
			    26: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `RAS_BASE_REG, `SOME_DATA_REG, 32'd7);
			    27: inst_hdr.inst[i] = inst_hdr.inst[i];
			    28: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADDI", `SOME_DATA_REG, 5'b0, , `DEFAULT_RCI);
			    29: inst_hdr.inst[i] = inst_hdr.inst[i];
			    30: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `RAS_BASE_REG, `SOME_DATA_REG, (32'd5<<2));
			    31: inst_hdr.inst[i] = inst_hdr.inst[i];
			    32: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ORI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'h1);
			    33: inst_hdr.inst[i] = inst_hdr.inst[i];
			    34: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `RAS_BASE_REG, `SOME_DATA_REG, (32'd6<<2));
			    35: inst_hdr.inst[i] = inst_hdr.inst[i];
			    36: inst_hdr.inst[i] = generate_inst16("C.EBREAK", , , , );
			    37: inst_hdr.inst[i] = 0;
			    38: case (inst_case)
			    	9: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SLT", `SOME_DATA_REG1, 5'd0, `RAS_BASE_REG, );
			    	10: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SLTU", `SOME_DATA_REG1, 5'd0, `PD_BASE_REG, );
			    	default: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SLTIU", `SOME_DATA_REG1, 5'd0, , 32'h1);
				endcase
			    39: inst_hdr.inst[i] = inst_hdr.inst[i];
			    40: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("AUIPC", `SOME_DATA_REG, , , 0);
			    41: inst_hdr.inst[i] = inst_hdr.inst[i];
			    42: case (inst_case)
			    	7: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("JALR", `SOME_DATA_REG, `SOME_DATA_REG2, , 0);
			    	8: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("JALR", `SOME_DATA_REG, `SOME_DATA_REG, , (2-40)*2);
			    	9: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("BNE", , `SOME_DATA_REG, `RAS_BASE_REG, (2-42));
			    	10: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("BGE", , `RAS_BASE_REG, `RAS_BASE_REG, (2-42));
			    	11: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("BGE", , `RAS_BASE_REG, `SOME_DATA_REG, (2-42));
			    	12: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("BGEU", , `PD_BASE_REG, `PD_BASE_REG, (2-42));
			    	13: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("BGEU", , `PD_BASE_REG, `SOME_DATA_REG, (2-42));
				endcase
			    43: inst_hdr.inst[i] = inst_hdr.inst[i];
			    default: inst_hdr.inst[i] = generate_inst16("C.NOP", , , , );
		    endcase
	    end
	    4, 5: begin
            	    case (i)
			    0: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SLTIU", `SOME_DATA_REG1, 5'd0, , 32'h1);
			    1: inst_hdr.inst[i] = inst_hdr.inst[i];
			    2: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SH", , `PD_BASE_REG, `SOME_DATA_REG1, 32'h0);
			    3: inst_hdr.inst[i] = inst_hdr.inst[i];
			    4: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SUB", `SOME_DATA_REG, 5'd0, `SOME_DATA_REG1, );
			    5: inst_hdr.inst[i] = inst_hdr.inst[i];
			    6: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SH", , `PD_BASE_REG, `SOME_DATA_REG, 32'h2);
			    7: inst_hdr.inst[i] = inst_hdr.inst[i];
			    8: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = inst_case==4?
				    generate_inst32("LB", `SOME_DATA_REG, `RAS_BASE_REG, , (4<<2)+3):
				    generate_inst32("LBU", `SOME_DATA_REG, `RAS_BASE_REG, , (4<<2)+3);
			    9: inst_hdr.inst[i] = inst_hdr.inst[i];
			    10: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h4);
			    11: inst_hdr.inst[i] = inst_hdr.inst[i];
			    12: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADD", `SOME_DATA_REG, `SOME_DATA_REG, `SOME_DATA_REG1, );
			    13: inst_hdr.inst[i] = inst_hdr.inst[i];
			    14: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h5);
			    15: inst_hdr.inst[i] = inst_hdr.inst[i];
			    16: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("OR", `SOME_DATA_REG, `SOME_DATA_REG, `SOME_DATA_REG1, );
			    17: inst_hdr.inst[i] = inst_hdr.inst[i];
			    18: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h6);
			    19: inst_hdr.inst[i] = inst_hdr.inst[i];
			    20: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("AND", `SOME_DATA_REG, `SOME_DATA_REG, `SOME_DATA_REG1, );
			    21: inst_hdr.inst[i] = inst_hdr.inst[i];
			    22: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h7);
			    23: inst_hdr.inst[i] = inst_hdr.inst[i];
			    24: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADDI", `SOME_DATA_REG, 5'b0, , 32'd2);
			    25: inst_hdr.inst[i] = inst_hdr.inst[i];
			    26: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `RAS_BASE_REG, `SOME_DATA_REG, 32'd7);
			    27: inst_hdr.inst[i] = inst_hdr.inst[i];
			    28: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADDI", `SOME_DATA_REG, 5'b0, , `DEFAULT_RCI);
			    29: inst_hdr.inst[i] = inst_hdr.inst[i];
			    30: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `RAS_BASE_REG, `SOME_DATA_REG, (32'd5<<2));
			    31: inst_hdr.inst[i] = inst_hdr.inst[i];
			    32: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ORI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'h1);
			    33: inst_hdr.inst[i] = inst_hdr.inst[i];
			    34: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `RAS_BASE_REG, `SOME_DATA_REG, (32'd6<<2));
			    35: inst_hdr.inst[i] = inst_hdr.inst[i];
			    36: inst_hdr.inst[i] = generate_inst16("C.EBREAK", , , , );
			    default: inst_hdr.inst[i] = s_num.r_num[15:0];
		    endcase
	    end
	    3, 6: begin
            	    case (i)
			    0: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SLTI", `SOME_DATA_REG1, 5'd0, , 32'h1);
			    1: inst_hdr.inst[i] = inst_hdr.inst[i];
			    2: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SH", , `PD_BASE_REG, `SOME_DATA_REG1, 32'h0);
			    3: inst_hdr.inst[i] = inst_hdr.inst[i];
			    4: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SLLI", `SOME_DATA_REG1, `SOME_DATA_REG1, , 32'd1);
			    5: inst_hdr.inst[i] = inst_hdr.inst[i];
			    6: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SH", , `PD_BASE_REG, `SOME_DATA_REG1, 32'h2);
			    7: inst_hdr.inst[i] = inst_hdr.inst[i];
			    8: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = inst_case==3?
				    			generate_inst32("LH", `SOME_DATA_REG, `RAS_BASE_REG, , (4<<2)+2):
				    			generate_inst32("LW", `SOME_DATA_REG, `RAS_BASE_REG, , (4<<2));
			    9: inst_hdr.inst[i] = inst_hdr.inst[i];
			    10: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h4);
			    11: inst_hdr.inst[i] = inst_hdr.inst[i];
			    12: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SLL", `SOME_DATA_REG, `SOME_DATA_REG, `SOME_DATA_REG1, );
			    13: inst_hdr.inst[i] = inst_hdr.inst[i];
			    14: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h5);
			    15: inst_hdr.inst[i] = inst_hdr.inst[i];
			    16: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SRL", `SOME_DATA_REG, `SOME_DATA_REG, `SOME_DATA_REG1, );
			    17: inst_hdr.inst[i] = inst_hdr.inst[i];
			    18: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h6);
			    19: inst_hdr.inst[i] = inst_hdr.inst[i];
			    20: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("XOR", `SOME_DATA_REG, `SOME_DATA_REG, `SOME_DATA_REG1, );
			    21: inst_hdr.inst[i] = inst_hdr.inst[i];
			    22: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h7);
			    23: inst_hdr.inst[i] = inst_hdr.inst[i];
			    24: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADDI", `SOME_DATA_REG, 5'b0, , 32'd2);
			    25: inst_hdr.inst[i] = inst_hdr.inst[i];
			    26: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `RAS_BASE_REG, `SOME_DATA_REG, 32'd7);
			    27: inst_hdr.inst[i] = inst_hdr.inst[i];
			    28: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADDI", `SOME_DATA_REG, 5'b0, , `DEFAULT_RCI);
			    29: inst_hdr.inst[i] = inst_hdr.inst[i];
			    30: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `RAS_BASE_REG, `SOME_DATA_REG, (32'd5<<2));
			    31: inst_hdr.inst[i] = inst_hdr.inst[i];
			    32: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ORI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'h1);
			    33: inst_hdr.inst[i] = inst_hdr.inst[i];
			    34: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `RAS_BASE_REG, `SOME_DATA_REG, (32'd6<<2));
			    35: inst_hdr.inst[i] = inst_hdr.inst[i];
			    36: inst_hdr.inst[i] = generate_inst16("C.EBREAK", , , , );
			    default: inst_hdr.inst[i] = s_num.r_num[15:0];
		    endcase
	    end
	    2: begin
            	    case (i)
			    0: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("LUI", `SOME_DATA_REG, , , {20'hc5aa5, 12'b0});
			    1: inst_hdr.inst[i] = inst_hdr.inst[i];
			    2: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SH", , `PD_BASE_REG, `SOME_DATA_REG, 32'h0);
			    3: inst_hdr.inst[i] = inst_hdr.inst[i];
			    4: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SRAI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'd20);
			    5: inst_hdr.inst[i] = inst_hdr.inst[i];
			    6: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SH", , `PD_BASE_REG, `SOME_DATA_REG, 32'h2);
			    7: inst_hdr.inst[i] = inst_hdr.inst[i];
			    8: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("AUIPC", `SOME_DATA_REG, , , {20'h0123c, 12'b0});
			    9: inst_hdr.inst[i] = inst_hdr.inst[i];
			    10: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h4);
			    11: inst_hdr.inst[i] = inst_hdr.inst[i];
			    12: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SRLI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'h8);
			    13: inst_hdr.inst[i] = inst_hdr.inst[i];
			    14: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h5);
			    15: inst_hdr.inst[i] = inst_hdr.inst[i];
			    16: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ANDI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'h7f);
			    17: inst_hdr.inst[i] = inst_hdr.inst[i];
			    18: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h6);
			    19: inst_hdr.inst[i] = inst_hdr.inst[i];
			    20: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("XORI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'hbf);
			    21: inst_hdr.inst[i] = inst_hdr.inst[i];
			    22: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `PD_BASE_REG, `SOME_DATA_REG, 32'h7);
			    23: inst_hdr.inst[i] = inst_hdr.inst[i];
			    24: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADDI", `SOME_DATA_REG, 5'b0, , 32'd2);
			    25: inst_hdr.inst[i] = inst_hdr.inst[i];
			    26: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `RAS_BASE_REG, `SOME_DATA_REG, 32'd7);
			    27: inst_hdr.inst[i] = inst_hdr.inst[i];
			    28: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADDI", `SOME_DATA_REG, 5'b0, , `DEFAULT_RCI);
			    29: inst_hdr.inst[i] = inst_hdr.inst[i];
			    30: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `RAS_BASE_REG, `SOME_DATA_REG, (32'd5<<2));
			    31: inst_hdr.inst[i] = inst_hdr.inst[i];
			    32: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ORI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'h1);
			    33: inst_hdr.inst[i] = inst_hdr.inst[i];
			    34: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `RAS_BASE_REG, `SOME_DATA_REG, (32'd6<<2));
			    35: inst_hdr.inst[i] = inst_hdr.inst[i];
			    36: inst_hdr.inst[i] = generate_inst16("C.EBREAK", , , , );
			    default: inst_hdr.inst[i] = s_num.r_num[15:0];
		    endcase
	    end
	    1: begin
            	    case (i)
			    0: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("LHU", `SOME_DATA_REG, `META_BASE_REG, , `EGRESS_RCI4);
			    1: inst_hdr.inst[i] = inst_hdr.inst[i];
			    2: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `SCRATCH_BASE_REG/*`RAS_BASE_REG*/, `SOME_DATA_REG, `NEW_FLOW_ACTION_SET_CONN7);
			    3: inst_hdr.inst[i] = inst_hdr.inst[i];
			    //0: inst_hdr.inst[i] = 16'hdf03;
			    //1: inst_hdr.inst[i] = 16'h0085;
			    //2: inst_hdr.inst[i] = 16'ha623;
			    //3: inst_hdr.inst[i] = 16'h01ef;
			    4: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADDI", `SOME_DATA_REG, 5'b0, , 32'd2);
			    5: inst_hdr.inst[i] = inst_hdr.inst[i];
			    6: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `RAS_BASE_REG, `SOME_DATA_REG, 32'd7);
			    7: inst_hdr.inst[i] = inst_hdr.inst[i];
			    8: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADDI", `SOME_DATA_REG, 5'b0, , `DEFAULT_RCI);
			    9: inst_hdr.inst[i] = inst_hdr.inst[i];
			    10: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `RAS_BASE_REG, `SOME_DATA_REG, (32'd5<<2));
			    11: inst_hdr.inst[i] = inst_hdr.inst[i];
			    12: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADDI", `SOME_DATA_REG, 5'b0, , `DEFAULT_RCI+1);
			    13: inst_hdr.inst[i] = inst_hdr.inst[i];
			    14: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `RAS_BASE_REG, `SOME_DATA_REG, (32'd6<<2));
			    15: inst_hdr.inst[i] = inst_hdr.inst[i];
			    //4: inst_hdr.inst[i] = 16'h9002;
			    16: inst_hdr.inst[i] = generate_inst16("C.EBREAK", , , , );
			    default: inst_hdr.inst[i] = s_num.r_num[15:0];
		    endcase
	    end
	    0: begin
            	    case (i)
			    0: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADDI", `SOME_DATA_REG, 5'b0, , 32'd2);
			    1: inst_hdr.inst[i] = inst_hdr.inst[i];
			    2: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SB", , `RAS_BASE_REG, `SOME_DATA_REG, 32'd7);
			    3: inst_hdr.inst[i] = inst_hdr.inst[i];
			    4: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ADDI", `SOME_DATA_REG, 5'b0, , `DEFAULT_RCI);
			    5: inst_hdr.inst[i] = inst_hdr.inst[i];
			    6: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `RAS_BASE_REG, `SOME_DATA_REG, (32'd5<<2));
			    7: inst_hdr.inst[i] = inst_hdr.inst[i];
			    8: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("ORI", `SOME_DATA_REG, `SOME_DATA_REG, , 32'h1);
			    9: inst_hdr.inst[i] = inst_hdr.inst[i];
			    10: {inst_hdr.inst[i+1], inst_hdr.inst[i]} = generate_inst32("SW", , `RAS_BASE_REG, `SOME_DATA_REG, (32'd6<<2));
			    11: inst_hdr.inst[i] = inst_hdr.inst[i];
			    12: inst_hdr.inst[i] = generate_inst16("C.EBREAK", , , , );
			    default: inst_hdr.inst[i] = s_num.r_num[15:0];
		    endcase
		end
   	endcase

endfunction

function void special_packet::generate_path_case(int i, ref bit [2:0] rci_code);

localparam NULL   = 3'b000;
localparam START_PROCESS   = 3'b001;
localparam END_PROCESS   = 3'b101;
localparam START_THREAD   = 3'b010;
localparam END_THREAD   = 3'b110;
localparam START_END_THREAD   = 3'b100;
localparam START_PROCESS_THREAD   = 3'b011;
localparam END_THREAD_PROCESS = 3'b111;

		case (path_case)
		  8:
            	    case (i)
			    0: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+3] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 2;
				    next_hop_idx[i][1] = 3;
				    next_hop_idx[i][2] = 5;
			    end
			    1: begin
				    rci_code = START_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+3] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 6;
				    next_hop_idx[i][1] = 7;
				    next_hop_idx[i][2] = 9;
			    end
			    2: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+3] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 6;
				    next_hop_idx[i][1] = 7;
				    next_hop_idx[i][2] = 9;
			    end
			    3: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
				    dummy_hop = 1;
			    end
			    4: begin
				    rci_code = END_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+3] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 6;
				    next_hop_idx[i][1] = 7;
				    next_hop_idx[i][2] = 9;
				    dummy_hop = 0;
			    end
			    5: begin
				    rci_code = START_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+3] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 10;
				    next_hop_idx[i][1] = 11;
				    next_hop_idx[i][2] = 13;
			    end
			    6: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+3] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 10;
				    next_hop_idx[i][1] = 11;
				    next_hop_idx[i][2] = 13;
			    end
			    7: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
				    dummy_hop = 1;
			    end
			    8: begin
				    rci_code = END_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+3] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 10;
				    next_hop_idx[i][1] = 11;
				    next_hop_idx[i][2] = 13;
				    dummy_hop = 0;
			    end
			    9: begin
				    rci_code = START_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+4] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 14;
				    next_hop_idx[i][1] = 15;
				    next_hop_idx[i][2] = 17;
				    next_hop_idx[i][3] = 19;
			    end
			    10: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+4] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 14;
				    next_hop_idx[i][1] = 15;
				    next_hop_idx[i][2] = 17;
				    next_hop_idx[i][3] = 19;
			    end
			    11: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
				    dummy_hop = 1;
			    end
			    12: begin
				    rci_code = END_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+4] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 14;
				    next_hop_idx[i][1] = 15;
				    next_hop_idx[i][2] = 17;
				    next_hop_idx[i][3] = 19;
				    dummy_hop = 0;
			    end
			    13: begin
				    rci_code = START_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 20;
			    end
			    14: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 20;
			    end
			    15: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
				    dummy_hop = 1;
			    end
			    16: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 20;
				    dummy_hop = 0;
			    end
			    17: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
				    dummy_hop = 1;
			    end
			    18: begin
				    rci_code = END_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 20;
				    dummy_hop = 0;
			    end
			    19: begin
				    rci_code = END_THREAD;
			    end
		    endcase
		  7:
            	    case (i)
			    0: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+3] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 2;
				    next_hop_idx[i][1] = 3;
				    next_hop_idx[i][2] = 4;
			    end
			    1: begin
				    rci_code = START_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+3] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 5;
				    next_hop_idx[i][1] = 6;
				    next_hop_idx[i][2] = 7;
			    end
			    2: begin
				    rci_code = START_END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+3] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 5;
				    next_hop_idx[i][1] = 6;
				    next_hop_idx[i][2] = 7;
			    end
			    3: begin
				    rci_code = END_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+3] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 5;
				    next_hop_idx[i][1] = 6;
				    next_hop_idx[i][2] = 7;
			    end
			    4: begin
				    rci_code = START_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+3] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 8;
				    next_hop_idx[i][1] = 9;
				    next_hop_idx[i][2] = 10;
			    end
			    5: begin
				    rci_code = START_END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+3] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 8;
				    next_hop_idx[i][1] = 9;
				    next_hop_idx[i][2] = 10;
			    end
			    6: begin
				    rci_code = END_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+3] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 8;
				    next_hop_idx[i][1] = 9;
				    next_hop_idx[i][2] = 10;
			    end
			    7: begin
				    rci_code = START_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+4] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 11;
				    next_hop_idx[i][1] = 12;
				    next_hop_idx[i][2] = 13;
				    next_hop_idx[i][3] = 14;
			    end
			    8: begin
				    rci_code = START_END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+4] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 11;
				    next_hop_idx[i][1] = 12;
				    next_hop_idx[i][2] = 13;
				    next_hop_idx[i][3] = 14;
			    end
			    9: begin
				    rci_code = END_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+4] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 11;
				    next_hop_idx[i][1] = 12;
				    next_hop_idx[i][2] = 13;
				    next_hop_idx[i][3] = 14;
			    end
			    10: begin
				    rci_code = START_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 15;
			    end
			    11: begin
				    rci_code = START_END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 15;
			    end
			    12: begin
				    rci_code = START_END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 15;
			    end
			    13: begin
				    rci_code = END_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 15;
			    end
			    14: begin
				    rci_code = END_THREAD;
			    end
		    endcase
		  6:
            	    case (i)
			    0: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+4] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 2;
				    next_hop_idx[i][1] = 20;
				    next_hop_idx[i][2] = 21;
				    next_hop_idx[i][3] = 22;
			    end
			    1: begin
				    rci_code = START_PROCESS_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+8] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 3;
				    next_hop_idx[i][1] = 5;
				    next_hop_idx[i][2] = 7;
				    next_hop_idx[i][3] = 9;
				    next_hop_idx[i][4] = 11;
				    next_hop_idx[i][5] = 13;
				    next_hop_idx[i][6] = 15;
				    next_hop_idx[i][7] = 17;
			    end
			    2: begin
				    rci_code = START_PROCESS_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 4;
			    end
			    3: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 23;
			    end
			    4: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 6;
			    end
			    5: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 23;
			    end
			    6: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 8;
			    end
			    7: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 23;
			    end
			    8: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 10;
			    end
			    9: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 23;
			    end
			    10: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 12;
			    end
			    11: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 23;
			    end
			    12: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 14;
			    end
			    13: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 23;
			    end
			    14: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 16;
			    end
			    15: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 23;
			    end
			    16: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 18;
			    end
			    17: begin
				    rci_code = END_THREAD_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 23;
			    end
			    18: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
				    dummy_hop = 1;
			    end
			    19: begin
				    rci_code = START_END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 23;
				    dummy_hop = 0;
			    end
			    20: begin
				    rci_code = START_END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 23;
			    end
			    21: begin
				    rci_code = END_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 23;
			    end
			    22: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
			    end
		    endcase
		  5:
            	    case (i)
			    0: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+4] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 2;
				    next_hop_idx[i][1] = 3;
				    next_hop_idx[i][2] = 5;
				    next_hop_idx[i][3] = 7;
			    end
			    1: begin
				    rci_code = START_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 22;
			    end
			    2: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 22;
			    end
			    3: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
				    dummy_hop = 1;
			    end
			    4: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 22;
				    dummy_hop = 0;
			    end
			    5: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
				    dummy_hop = 1;
			    end
			    6: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+4] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 8;
				    next_hop_idx[i][1] = 9;
				    next_hop_idx[i][2] = 11;
				    next_hop_idx[i][3] = 13;
				    dummy_hop = 0;
			    end
			    7: begin
				    rci_code = START_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 22;
			    end
			    8: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 22;
			    end
			    9: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
				    dummy_hop = 1;
			    end
			    10: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 22;
				    dummy_hop = 0;
			    end
			    11: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
				    dummy_hop = 1;
			    end
			    12: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+4] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 14;
				    next_hop_idx[i][1] = 15;
				    next_hop_idx[i][2] = 17;
				    next_hop_idx[i][3] = 19;
				    dummy_hop = 0;
			    end
			    13: begin
				    rci_code = START_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 22;
			    end
			    14: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 22;
			    end
			    15: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
				    dummy_hop = 1;
			    end
			    16: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 22;
				    dummy_hop = 0;
			    end
			    17: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
				    dummy_hop = 1;
			    end
			    18: begin
				    rci_code = END_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 22;
				    dummy_hop = 0;
			    end
			    19: begin
				    rci_code = END_THREAD_PROCESS;
				    dummy_hop = 1;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
			    end
			    20: begin
				    rci_code = END_THREAD_PROCESS;
				    dummy_hop = 1;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
			    end
			    21: begin
				    rci_code = END_THREAD;
				    dummy_hop = 0;
			    end
		    endcase
		  4:
            	    case (i)
			    0: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+4] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 2;
				    next_hop_idx[i][1] = 3;
				    next_hop_idx[i][2] = 4;
				    next_hop_idx[i][3] = 5;
			    end
			    1: begin
				    rci_code = START_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 16;
			    end
			    2: begin
				    rci_code = START_END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 16;
			    end
			    3: begin
				    rci_code = START_END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 16;
			    end
			    4: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+4] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 6;
				    next_hop_idx[i][1] = 7;
				    next_hop_idx[i][2] = 8;
				    next_hop_idx[i][3] = 9;
			    end
			    5: begin
				    rci_code = START_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 16;
			    end
			    6: begin
				    rci_code = START_END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 16;
			    end
			    7: begin
				    rci_code = START_END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 16;
			    end
			    8: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+4] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 10;
				    next_hop_idx[i][1] = 11;
				    next_hop_idx[i][2] = 12;
				    next_hop_idx[i][3] = 13;
			    end
			    9: begin
				    rci_code = START_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 16;
			    end
			    10: begin
				    rci_code = START_END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 16;
			    end
			    11: begin
				    rci_code = START_END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 16;
			    end
			    12: begin
				    rci_code = END_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 16;
			    end
			    13: begin
				    rci_code = END_THREAD_PROCESS;
				    dummy_hop = 1;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
			    end
			    14: begin
				    rci_code = END_THREAD_PROCESS;
				    dummy_hop = 1;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
			    end
			    15: begin
				    rci_code = END_THREAD;
				    dummy_hop = 0;
			    end
		    endcase
		  1, 2, 3:
            	    case (i)
			    0: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+2] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 2;
				    next_hop_idx[i][1] = 9;
			    end
			    1: begin
				    rci_code = START_PROCESS_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 3;
			    end
			    2: begin
				    rci_code = NULL;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+2] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 4;
				    next_hop_idx[i][1] = 5;
			    end
			    3: begin
				    rci_code = START_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 8;
			    end
			    4: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 6;
			    end
			    5: begin
				    rci_code = NULL;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 7;
			    end
			    6: begin
				    rci_code = END_THREAD_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 8;
			    end
			    7: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+3] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 15;
				    next_hop_idx[i][1] = 16;
				    next_hop_idx[i][2] = path_case==3?18:17;
			    end
			    8: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 10;
			    end
			    9: begin
				    rci_code = NULL;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+2] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 11;
				    next_hop_idx[i][1] = 12;
			    end
			    10: begin
				    rci_code = START_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+3] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 15;
				    next_hop_idx[i][1] = 16;
				    next_hop_idx[i][2] = path_case==3?18:17;
			    end
			    11: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 13;
			    end
			    12: begin
				    rci_code = END_THREAD_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+3] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 15;
				    next_hop_idx[i][1] = 16;
				    next_hop_idx[i][2] = path_case==3?18:17;
			    end
			    13: begin
				    rci_code = END_PROCESS;
				    dummy_hop = 1;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
			    end
			    14: begin
				    dummy_hop = 0;
				    rci_code = START_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = path_case==3?19:18;
			    end
			    15: begin
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    if(path_case==3) begin
				    rci_code = START_THREAD;
				    next_hop_idx[i][0] = 19;
				    end else begin
				    //rci_code = NULL;
				    rci_code = START_END_THREAD;
				    next_hop_idx[i][0] = 18;
				    end 
			    end
			    16: begin
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
				    if(path_case==3) begin
				    dummy_hop = 1;
				    rci_code = END_THREAD;
				    end else begin
				    rci_code = END_PROCESS;
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 18;
				    end 
			    end
			    17: begin
				    if(path_case==3) begin
				    dummy_hop = 0;
				    rci_code = END_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 19;
				    end else begin
				    rci_code = END_THREAD;
				    dummy_hop = path_case==1?1:0;
				    end 
			    end
			    18: begin
				    rci_code = END_THREAD;
			    end
		    endcase
		  0:
            	    case (i)
			    0: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+3] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 2;
				    next_hop_idx[i][1] = 5;
				    next_hop_idx[i][2] = 7;
			    end
			    1: begin
				    rci_code = START_PROCESS_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 3;
			    end
			    2: begin
				    rci_code = NULL;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 4;
			    end
			    3: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+2] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 13;
				    next_hop_idx[i][1] = 14;
			    end
			    4: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 6;
			    end
			    5: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+2] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 13;
				    next_hop_idx[i][1] = 14;
			    end
			    6: begin
				    rci_code = START_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 8;
			    end
			    7: begin
				    rci_code = NULL;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+2] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 9;
				    next_hop_idx[i][1] = 11;
			    end
			    8: begin
				    rci_code = START_PROCESS_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 10;
			    end
			    9: begin
				    rci_code = END_THREAD;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 12;
			    end
			    10: begin
				    rci_code = END_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 12;
			    end
			    11: begin
				    rci_code = END_THREAD_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+2] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 13;
				    next_hop_idx[i][1] = 14;
			    end
			    12: begin
				    rci_code = START_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 15;
			    end
			    13: begin
				    rci_code = END_PROCESS;
      				    next_hop_idx = new[next_hop_idx.size()+1] (next_hop_idx);
      				    next_hop_idx[i] = new[next_hop_idx[i].size()+1] (next_hop_idx[i]);
				    next_hop_idx[i][0] = 15;
			    end
			    14: begin
				    rci_code = END_THREAD;
				    dummy_hop = 1;
			    end
		    endcase
	    endcase
endfunction

`endif
