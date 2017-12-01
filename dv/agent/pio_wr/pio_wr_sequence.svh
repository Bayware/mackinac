class pio_wr_sequence extends uvm_sequence #(pio_wr_transaction);

  bit [31:0] pio_wr_addr;
  bit [31:0] pio_wr_data;

  `uvm_object_utils_begin (pio_wr_sequence)
  `uvm_object_utils_end

  function new (string name="pio_wr_sequence");
    super.new(name);
  endfunction

  extern virtual task body ();

endclass

task pio_wr_sequence::body ();

   if (starting_phase != null) 
	starting_phase.raise_objection(this);

   `uvm_do_with(req, {req.addr == pio_wr_addr; req.data == pio_wr_data;});

   if (starting_phase != null) 
	starting_phase.drop_objection(this);

endtask

