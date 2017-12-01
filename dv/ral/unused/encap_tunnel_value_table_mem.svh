
class encap_tunnel_value_table_mem extends uvm_vreg;

   `uvm_object_utils( encap_tunnel_value_table_mem )
 
   rand uvm_vreg_field key;
   rand uvm_vreg_field ip_da;
   rand uvm_vreg_field ip_sa;
   rand uvm_vreg_field vlan;
   rand uvm_vreg_field mac;
   rand uvm_vreg_field spi;
   rand uvm_vreg_field sn;
 
   function new( string name = "encap_tunnel_value_table_mem" );
      super.new( .name( name ), .n_bits( `TUNNEL_VALUE_NBITS ));
   endfunction: new
 
   virtual function void build();
      key = uvm_vreg_field::type_id::create("key");
      key.configure( .parent            ( this ),
                       .size                   ( `TUNNEL_KEY_NBITS    ),
                       .lsb_pos                ( 0    ) );
   
      ip_da = uvm_vreg_field::type_id::create("ip_da");
      ip_da.configure( .parent            ( this ),
                       .size                   ( `TUNNEL_VALUE_IP_DA_NBITS    ),
                       .lsb_pos                ( `TUNNEL_KEY_NBITS    ) );
   
      ip_sa = uvm_vreg_field::type_id::create("ip_sa");
      ip_sa.configure( .parent            ( this ),
                       .size                   ( `TUNNEL_VALUE_IP_SA_NBITS    ),
                       .lsb_pos                ( `TUNNEL_KEY_NBITS+`TUNNEL_VALUE_IP_DA_POS+1    ) );
   
      vlan = uvm_vreg_field::type_id::create("vlan");
      vlan.configure( .parent            ( this ),
                       .size                   ( `TUNNEL_VALUE_VLAN_NBITS    ),
                       .lsb_pos                ( `TUNNEL_KEY_NBITS+`TUNNEL_VALUE_IP_SA_POS+1    ) );
   
      mac = uvm_vreg_field::type_id::create("mac");
      mac.configure( .parent            ( this ),
                       .size                   ( `TUNNEL_VALUE_MAC_NBITS    ),
                       .lsb_pos                ( `TUNNEL_KEY_NBITS+`TUNNEL_VALUE_VLAN_POS+1    ) );
   
      spi = uvm_vreg_field::type_id::create("spi");
      spi.configure( .parent            ( this ),
                       .size                   ( `TUNNEL_VALUE_SPI_NBITS    ),
                       .lsb_pos                ( `TUNNEL_KEY_NBITS+`TUNNEL_VALUE_MAC_POS+1    ) );
   
      sn = uvm_vreg_field::type_id::create("sn");
      sn.configure( .parent            ( this ),
                       .size                   ( `TUNNEL_VALUE_SN_NBITS    ),
                       .lsb_pos                ( `TUNNEL_KEY_NBITS+`TUNNEL_VALUE_SPI_POS+1    ) );
   endfunction
endclass
