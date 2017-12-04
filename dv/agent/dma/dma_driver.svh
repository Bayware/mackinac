
class dma_driver extends uvm_driver #(special_packet);

  virtual dma_if dma_if_0;
  dma_config dma_config_0;

  `uvm_component_utils(dma_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task drive_pins(special_packet req);

endclass

  function void dma_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual dma_if)::get(this, "", "dma_if", dma_if_0)) 
      `uvm_fatal("DMA_DRIVER", "dma_if not found");

    if (!(uvm_config_db#(dma_config)::get(this,"","dma_config", dma_config_0)))
       `uvm_fatal("DMA_DRIVER"," dma_config not found")

  endfunction

  task dma_driver::run_phase(uvm_phase phase);

    super.run_phase(phase);

    dma_if_0.drv_cb.last <= '0;
    dma_if_0.drv_cb.data <= '0;
    dma_if_0.drv_cb.valid <= '0;

    forever begin
      seq_item_port.get_next_item(req);
      drive_pins(req);
      seq_item_port.item_done();
    end

  endtask

  task dma_driver::drive_pins (special_packet req);

    int delay, pkt_size, if_width, num_of_data, idx;
    bit [2:0] left_over;

    `uvm_info("DMA_DRIVER", $sformatf("DMA_NO %0d PACKET_NO %0d", dma_config_0.dma_num, dma_config_0.packet_num), UVM_HIGH);

    delay = $urandom_range(dma_config_0.min_delay, dma_config_0.max_delay);
    repeat (delay) @ (dma_if_0.drv_cb);

    dma_if_0.drv_cb.last <= '0;
    dma_if_0.drv_cb.data <= '0;
    dma_if_0.drv_cb.valid <= '0;

    pkt_size = req.packet_data.size();
    idx = 0;
    if_width = 8;
    left_over = pkt_size%if_width;
    num_of_data = pkt_size/if_width+(left_over==0?0:1);

    for (int i=0; i < num_of_data; i++) begin

    	dma_if_0.drv_cb.valid <= 1'b1;
	dma_if_0.drv_cb.last  <= (i==num_of_data-1)?1'b1:1'b0;
        dma_if_0.drv_cb.data <= 
             {req.packet_data[idx], req.packet_data[idx+1],
              req.packet_data[idx+2], req.packet_data[idx+3],
              req.packet_data[idx+4], req.packet_data[idx+5],
              req.packet_data[idx+6], req.packet_data[idx+7]};

        while (dma_if_0.drv_cb.ready == 1'b0) @(dma_if_0.drv_cb);

        @(dma_if_0.drv_cb);

        idx +=8;
    end

    dma_if_0.drv_cb.last <= 1'b0;
    dma_if_0.drv_cb.valid <= 1'b0;

  endtask
