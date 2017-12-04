
class mac_monitor extends uvm_monitor;

  virtual mac_if  mac_if_0;
  mac_config mac_config_0;

  logic [7:0] pkt_data[];

  uvm_analysis_port #(special_packet) analysis_port;

  `uvm_component_utils(mac_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  extern function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task probe_pins(special_packet s_pkt);

endclass

  function void mac_monitor::build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db#(virtual mac_if)::get( this, "", "mac_if", mac_if_0)) 
      `uvm_fatal("MAC_MONITOR", "mac_if not found");
    
    if (!(uvm_config_db#(mac_config)::get(this,"","mac_config",mac_config_0)))
       `uvm_fatal("MAC_MONITOR", "mac_config not found")
    
    analysis_port = new("analysis_port", this);

  endfunction

  task mac_monitor::run_phase(uvm_phase phase);

    special_packet s_pkt;

    forever begin
      s_pkt = new ("special_packet"); 
     
      probe_pins(s_pkt);
//      `uvm_info("MAC_MONITOR", s_pkt.sprint(), UVM_MEDIUM);

      analysis_port.write(s_pkt);
     
    end
  endtask

  task mac_monitor::probe_pins(special_packet s_pkt);

    bit [31:0] data;
    logic      eop;
    int        first_pkt_size, pkt_size, vld_bytes;

    eop = 0;
    pkt_data.delete();

    while (mac_if_0.mon_cb.valid !== 1'b1) @(mac_if_0.mon_cb);

    while (eop != 1) begin

      data = mac_if_0.mon_cb.data;
    
      if (mac_if_0.mon_cb.last == 1'b0) 
        vld_bytes = 4;
      else begin
        eop = 1;
         case (mac_if_0.mon_cb.keep)
		4'hf: vld_bytes = 4;
		4'he: vld_bytes = 3;
		4'hc: vld_bytes = 2;
		4'h8: vld_bytes = 1;
		default: vld_bytes = 1;
	 endcase
      end

      pkt_data = new[pkt_data.size()+vld_bytes] (pkt_data);
      pkt_size = pkt_data.size();

      case (vld_bytes) 
	  4: begin
            pkt_data[pkt_size-4] = data[31:24];
            pkt_data[pkt_size-3] = data[23:16];
            pkt_data[pkt_size-2] = data[15:8];
            pkt_data[pkt_size-1] = data[7:0];
	  end 
	  3: begin
            pkt_data[pkt_size-3] = data[31:24];
            pkt_data[pkt_size-2] = data[23:16];
            pkt_data[pkt_size-1] = data[15:8];
	  end 
	  2: begin
            pkt_data[pkt_size-2] = data[31:24];
            pkt_data[pkt_size-1] = data[23:16];
	  end 
	  1: begin
            pkt_data[pkt_size-1] = data[31:24];
	  end
     endcase

     if (eop == 0) begin
       @(mac_if_0.mon_cb);
       while (mac_if_0.mon_cb.valid !== 1'b1) @(mac_if_0.mon_cb);
     end

    end
    
    first_pkt_size = pkt_size;

    while (pkt_data[pkt_size-3]!=8'ha5&&pkt_data[pkt_size-4]!=8'h5a) begin
	pkt_size = pkt_size-1;
	if (pkt_size==34) begin
/*
       		`uvm_info("MAC_MONITOR",
         		$sformatf("Packet size = %0d pkt_data[pkt_size-4] = %0h pkt_data[pkt_size-3] = %0h",
         		first_pkt_size, pkt_data[first_pkt_size-4], pkt_data[first_pkt_size-3]), UVM_HIGH)

    		s_pkt.packet_data = new[first_pkt_size];

    		foreach (pkt_data[i]) 
      			s_pkt.packet_data[i] = pkt_data[i];

      		s_pkt.print_packet();

    		s_pkt.s_src_port = 0;
    		s_pkt.s_packet_num = 15;
*/
      		`uvm_fatal("MAC_MONITOR", "last byte of the packet not found")
	end
    end

    s_pkt.packet_data = new[pkt_size];

    foreach (pkt_data[i]) 
      s_pkt.packet_data[i] = pkt_data[i];

    s_pkt.s_src_port = pkt_data[pkt_size-1];
    s_pkt.s_packet_num = pkt_data[pkt_size-2];

    repeat (1) @(mac_if_0.mon_cb);

  endtask
