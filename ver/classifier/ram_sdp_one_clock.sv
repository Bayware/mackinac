// Based off Xilinx example:
// Simple Dual-Port Block RAM with One Clock
// File: simple_dual_one_clock.v

module ram_sdp_one_clock
#(
    parameter DWIDTH = 64,
    parameter DEPTH = 32,
    localparam AWIDTH = $clog2( DEPTH )
)
(
    input logic clk,
    input logic ena, enb,
    input logic wea,

    input logic [ AWIDTH - 1:0 ] addra,
    input logic [ AWIDTH - 1:0 ] addrb,
    input logic [ WIDTH - 1:0 ] dia,

    output logic [ DWIDTH - 1:0 ] dob
);

logic [ DWIDTH - 1:0 ] mem [ DEPTH ];

always_ff @( posedge clk )
begin 
    if ( ena )
    begin
        if ( wea )
            mem[ addra ] <= dia;
    end
end

always_ff @( posedge clk )
    if ( enb )
        dob <= mem[ addrb ];

endmodule
