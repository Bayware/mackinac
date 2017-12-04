class mac_driver extends uvm_driver #(special_packet);

  virtual mac_if mac_if_0;
  mac_config mac_config_0;

  `uvm_component_utils(mac_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task drive_pins(special_packet req);

endclass

  function void mac_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual mac_if)::get(this, "", "mac_if", mac_if_0)) 
      `uvm_fatal("MAC_DRIVER", "mac_if not found");

    if (!(uvm_config_db#(mac_config)::get(this, "", "mac_config", mac_config_0)))
       `uvm_fatal("MAC_DRIVER", "mac_config not found")

  endfunction

  task mac_driver::run_phase(uvm_phase phase);

    super.run_phase(phase);

    mac_if_0.drv_cb.last <= '0;
    mac_if_0.drv_cb.data <= '0;
    mac_if_0.drv_cb.valid <= '0;
    mac_if_0.drv_cb.keep <= '0;
    mac_if_0.drv_cb.user <= '0;

    forever begin
      seq_item_port.get_next_item(req);
      drive_pins (req);
      seq_item_port.item_done();
    end

  endtask

  task mac_driver::drive_pins (special_packet req);

    int delay, pkt_size, if_width, num_of_data, idx;
    bit [31:0] data;
    bit [1:0] left_over;

    `uvm_info("MAC_DRIVER", $sformatf("MAC_NO %0d PACKET_NO %0d", mac_config_0.mac_num, mac_config_0.packet_num), UVM_HIGH);

    delay = $urandom_range(mac_config_0.min_delay, mac_config_0.max_delay);
    repeat (delay) @ (mac_if_0.drv_cb);

    mac_if_0.drv_cb.last <= '0;
    mac_if_0.drv_cb.data <= '0;
    mac_if_0.drv_cb.valid <= '0;
    mac_if_0.drv_cb.keep <= 4'hf;
    mac_if_0.drv_cb.user <= '0;

    pkt_size = req.packet_data.size();
    idx = 0;
    if_width = 4;
    left_over = pkt_size%if_width;
    num_of_data = pkt_size/if_width+(left_over==0?0:1);

    for (int i=0; i < num_of_data; i++) begin
    	mac_if_0.drv_cb.valid <= 1'b1;
        if ( i == num_of_data-1) begin
	   mac_if_0.drv_cb.last  <= 1'b1;
	   case (left_over)
	       4:mac_if_0.drv_cb.keep <= 4'hf;
	       3:mac_if_0.drv_cb.keep <= 4'he;
	       2:mac_if_0.drv_cb.keep <= 4'hc;
	       1:mac_if_0.drv_cb.keep <= 4'h8;
   	   endcase
        end
        mac_if_0.drv_cb.data <= 
             {req.packet_data[idx], req.packet_data[idx+1],
              req.packet_data[idx+2], req.packet_data[idx+3]};

        @ (mac_if_0.drv_cb);

        idx +=4;
    end

    mac_if_0.drv_cb.last <= 1'b0;
    mac_if_0.drv_cb.valid <= 1'b0;

  endtask
