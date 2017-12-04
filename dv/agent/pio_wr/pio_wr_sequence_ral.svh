`include "defines.vh"

class pio_wr_sequence_ral extends uvm_reg_sequence;

  `uvm_object_utils(pio_wr_sequence_ral)

  bit [31:0] pio_wr_addr;
  bit [31:0] pio_wr_data;

  function new (string name="");
    super.new(name);
  endfunction

  extern virtual task body ();

endclass

task pio_wr_sequence_ral::body ();

   encap_reg_block encap_reg;
   uvm_status_e status;

      $cast( encap_reg, model );

      case (pio_wr_addr[`ENCR_REG_ADDR_RANGE])
	      `ENCR_FLOW_LABEL: write_reg( encap_reg.flow_label_reg, status, pio_wr_data );
	      `ENCR_MAC_SA_LSB: write_reg( encap_reg.mac_sa_lsb_reg, status, pio_wr_data );
	      `ENCR_MAC_SA_MSB: write_reg( encap_reg.mac_sa_msb_reg, status, pio_wr_data );
	      `ENCR_ID_TTL_DSCP: write_reg( encap_reg.traffic_class_reg, status, pio_wr_data );

      endcase

endtask

