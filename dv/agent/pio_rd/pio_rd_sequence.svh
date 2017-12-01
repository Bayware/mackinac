class pio_rd_sequence extends uvm_sequence #(pio_rd_transaction);

  bit [31:0] pio_rd_addr;
  bit [31:0] pio_rd_data;

  `uvm_object_utils_begin (pio_rd_sequence)
  `uvm_object_utils_end

  function new (string name="pio_rd_sequence");
    super.new(name);
  endfunction

  extern virtual task body ();

endclass

task pio_rd_sequence::body ();
  
   if (starting_phase != null) 
	starting_phase.raise_objection(this);

   `uvm_do_with(req, {req.addr == pio_rd_addr; req.data == pio_rd_data;});

   if (starting_phase != null) 
	starting_phase.drop_objection(this);

endtask

