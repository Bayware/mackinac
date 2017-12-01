
class encap_tunnel_hash_table_mem extends uvm_mem;

   `uvm_object_utils( encap_tunnel_hash_table_mem )
 
   rand uvm_vreg_field valid;
   rand uvm_vreg_field hash_idx0;
   rand uvm_vreg_field value_ptr0;
   rand uvm_vreg_field hash_idx1;
   rand uvm_vreg_field value_ptr1;
 
   function new( string name = "encap_tunnel_hash_table_mem" );
      super.new( .name( name ), .n_bits( `TUNNEL_HASH_BUCKET_NBITS ));
   endfunction: new
 
endclass
