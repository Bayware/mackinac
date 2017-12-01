`ifndef PIO_WR_ADAPTER_SVH
`define PIO_WR_ADAPTER_SVH

class pio_wr_adapter extends uvm_reg_adapter;
  `uvm_object_utils(pio_wr_adapter)

  function new (string name="pio_wr_adapter");
    super.new(name);
  endfunction

  extern virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
  extern virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
endclass

function uvm_sequence_item pio_wr_adapter::reg2bus(const ref uvm_reg_bus_op rw);
   pio_wr_transaction tx;
   tx = pio_wr_transaction::type_id::create ("tx");
   tx.addr = rw.addr;
   tx.data = rw.data;
   return tx;
endfunction

function void pio_wr_adapter::bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
  pio_wr_transaction tx;
  if (!$cast(tx, bus_item)) `uvm_fatal("PIO_WR_ADAPTOR","bus_item is not correct");
 
  rw.addr = tx.addr;
  rw.data = tx.data;
  rw.status = UVM_IS_OK;

endfunction

`endif
