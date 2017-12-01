class pio_rd_config extends uvm_object;

   virtual pio_rd_if pio_rd_0;

   rand bit [31:0]  min_delay;
   rand bit [31:0]  max_delay;

   `uvm_object_utils_begin(pio_rd_config)
     `uvm_field_int      (min_delay, UVM_ALL_ON)
     `uvm_field_int      (max_delay, UVM_ALL_ON)
   `uvm_object_utils_end

   constraint pio_rd_seq {
      min_delay   inside {[0:4]};
      max_delay   inside {[4:8]};
      max_delay > min_delay;
   }

   function new (string name = "pio_rd_config");
     super.new (name);
   endfunction : new

endclass
