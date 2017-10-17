//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

package table_package; 

typedef struct { 

	logic valid;
	logic [`TUNNEL_VALUE_DEPTH_NBITS-1:0] value_ptr;
	logic [`TUNNEL_HASH_TABLE_DEPTH_NBITS-1:0] hash_idx;

} tunnel_hash_entry; 

typedef struct { 

	tunnel_hash_entry entry0;
	tunnel_hash_entry entry1;

} tunnel_hash_bucket; 


typedef struct { 

	logic [`SEQUENCE_NUMBER_NBITS-1:0] sn;
	logic [`SPI_NBITS-1:0] spi;
	logic [`MAC_NBITS-1:0] mac;
	logic [`VLAN_NBITS-1:0] vlan;
	logic [`IP_SA_NBITS-1:0] ip_sa;
	logic [`IP_DA_NBITS-1:0] ip_da;
	logic [`TUNNEL_KEY_NBITS-1:0] key;

} tunnel_value_entry; 

typedef struct { 

	logic valid;
	logic [`RCI_VALUE_DEPTH_NBITS-1:0] value_ptr;
	logic [`RCI_HASH_TABLE_DEPTH_NBITS-1:0] hash_idx;

} rci_hash_entry; 

typedef struct { 

	rci_hash_entry entry0;
	rci_hash_entry entry1;

} rci_hash_bucket; 


typedef struct { 

	logic [`RCI_KEY_NBITS-1:0] key;
	logic [`RCI_NBITS-1:0] rci;

} rci_value_entry; 


endpackage
