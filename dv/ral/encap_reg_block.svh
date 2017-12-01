class encap_reg_block extends uvm_reg_block;
   `uvm_object_utils( encap_reg_block )
 
   rand encap_flow_label_reg flow_label_reg;
   rand encap_traffic_class_reg traffic_class_reg;
   rand encap_mac_sa_lsb_reg mac_sa_lsb_reg;
   rand encap_mac_sa_msb_reg mac_sa_msb_reg;

   uvm_reg_map reg_map;
 
   function new( string name = "encap_reg_block" );
      super.new( .name( name ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new
 
   virtual function void build();
      flow_label_reg = encap_flow_label_reg::type_id::create( "flow_label_reg" );
      flow_label_reg.configure( .blk_parent( this ) );
      flow_label_reg.build();
 
      traffic_class_reg = encap_traffic_class_reg::type_id::create( "traffic_class_reg" );
      traffic_class_reg.configure( .blk_parent( this ) );
      traffic_class_reg.build();
 
      mac_sa_lsb_reg = encap_mac_sa_lsb_reg::type_id::create( "mac_sa_lsb_reg" );
      mac_sa_lsb_reg.configure( .blk_parent( this ) );
      mac_sa_lsb_reg.build();
 
      mac_sa_msb_reg = encap_mac_sa_msb_reg::type_id::create( "mac_sa_msb_reg" );
      mac_sa_msb_reg.configure( .blk_parent( this ) );
      mac_sa_msb_reg.build();
 
      reg_map = create_map( .name( "reg_map" ), .base_addr( {`ENCR_REG_BLOCK_ADDR, 8'h00} ),
                            .n_bytes( 4 ), .endian( UVM_LITTLE_ENDIAN ) );

      reg_map.add_reg( .rg( flow_label_reg ), .offset( `ENCR_FLOW_LABEL<<2 ), .rights( "RW" ) );
      reg_map.add_reg( .rg( traffic_class_reg ), .offset( `ENCR_ID_TTL_DSCP<<2 ), .rights( "RW" ) );
      reg_map.add_reg( .rg( mac_sa_lsb_reg ), .offset( `ENCR_MAC_SA_LSB<<2 ), .rights( "RW" ) );
      reg_map.add_reg( .rg( mac_sa_msb_reg ), .offset( `ENCR_MAC_SA_MSB<<2 ), .rights( "RW" ) );

      lock_model(); 
   endfunction: build
 
endclass
