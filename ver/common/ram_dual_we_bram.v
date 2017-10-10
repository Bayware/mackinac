//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : dual port memory model
//===========================================================================

module ram_dual_we_bram
             ( clka, wea, addra, dina, douta, clkb, web, addrb, dinb, doutb);

parameter DI_WIDTH = 8,
	      ADDR_WIDTH = 4,
	      SIZE = 16'h1<<ADDR_WIDTH;

output  [4*DI_WIDTH-1:0] douta;

input    clka;  
input   [3:0] wea;
input   [ADDR_WIDTH-1:0] addra;
input   [4*DI_WIDTH-1:0] dina;

output  [4*DI_WIDTH-1:0] doutb;

input    clkb;  
input   [3:0] web;
input   [ADDR_WIDTH-1:0] addrb;
input   [4*DI_WIDTH-1:0] dinb;

reg [4*DI_WIDTH-1:0] douta;
reg [4*DI_WIDTH-1:0] doutb;
reg [DI_WIDTH-1:0] dina0, dina1, dina2, dina3;
reg [DI_WIDTH-1:0] douta0, douta1, douta2, douta3;
reg [DI_WIDTH-1:0] dinb0, dinb1, dinb2, dinb3;
reg [DI_WIDTH-1:0] doutb0, doutb1, doutb2, doutb3;
(* ram_style = "block" *)
reg [4*DI_WIDTH-1:0] RAM[SIZE-1:0];

always @* begin
	if(wea[3]) begin
		dina3 = dina[4*DI_WIDTH-1:3*DI_WIDTH];
		douta3 = dina[4*DI_WIDTH-1:3*DI_WIDTH];
	end else begin
		dina3 = RAM[addra][4*DI_WIDTH-1:3*DI_WIDTH];
		douta3 = RAM[addra][4*DI_WIDTH-1:3*DI_WIDTH];
	end
	if(wea[2]) begin
		dina2 = dina[3*DI_WIDTH-1:2*DI_WIDTH];
		douta2 = dina[3*DI_WIDTH-1:2*DI_WIDTH];
	end else begin
		dina2 = RAM[addra][3*DI_WIDTH-1:2*DI_WIDTH];
		douta2 = RAM[addra][3*DI_WIDTH-1:2*DI_WIDTH];
	end
	if(wea[1]) begin
		dina1 = dina[2*DI_WIDTH-1:1*DI_WIDTH];
		douta1 = dina[2*DI_WIDTH-1:1*DI_WIDTH];
	end else begin
		dina1 = RAM[addra][2*DI_WIDTH-1:1*DI_WIDTH];
		douta1 = RAM[addra][2*DI_WIDTH-1:1*DI_WIDTH];
	end
	if(wea[0]) begin
		dina0 = dina[1*DI_WIDTH-1:0*DI_WIDTH];
		douta0 = dina[1*DI_WIDTH-1:0*DI_WIDTH];
	end else begin
		dina0 = RAM[addra][1*DI_WIDTH-1:0*DI_WIDTH];
		douta0 = RAM[addra][1*DI_WIDTH-1:0*DI_WIDTH];
	end
end


always @(posedge clka) begin
	RAM[addra] <= {dina3, dina2, dina1, dina0};
	douta <= {douta3, douta2, douta1, douta0};
end

always @* begin
	if(web[3]) begin
		dinb3 = dinb[4*DI_WIDTH-1:3*DI_WIDTH];
		doutb3 = dinb[4*DI_WIDTH-1:3*DI_WIDTH];
	end else begin
		dinb3 = RAM[addrb][4*DI_WIDTH-1:3*DI_WIDTH];
		doutb3 = RAM[addrb][4*DI_WIDTH-1:3*DI_WIDTH];
	end
	if(web[2]) begin
		dinb2 = dinb[3*DI_WIDTH-1:2*DI_WIDTH];
		doutb2 = dinb[3*DI_WIDTH-1:2*DI_WIDTH];
	end else begin
		dinb2 = RAM[addrb][3*DI_WIDTH-1:2*DI_WIDTH];
		doutb2 = RAM[addrb][3*DI_WIDTH-1:2*DI_WIDTH];
	end
	if(web[1]) begin
		dinb1 = dinb[2*DI_WIDTH-1:1*DI_WIDTH];
		doutb1 = dinb[2*DI_WIDTH-1:1*DI_WIDTH];
	end else begin
		dinb1 = RAM[addrb][2*DI_WIDTH-1:1*DI_WIDTH];
		doutb1 = RAM[addrb][2*DI_WIDTH-1:1*DI_WIDTH];
	end
	if(web[0]) begin
		dinb0 = dinb[1*DI_WIDTH-1:0*DI_WIDTH];
		doutb0 = dinb[1*DI_WIDTH-1:0*DI_WIDTH];
	end else begin
		dinb0 = RAM[addrb][1*DI_WIDTH-1:0*DI_WIDTH];
		doutb0 = RAM[addrb][1*DI_WIDTH-1:0*DI_WIDTH];
	end
end


always @(posedge clka) begin
	RAM[addrb] <= {dinb3, dinb2, dinb1, dinb0};
	doutb <= {doutb3, doutb2, doutb1, doutb0};
end

endmodule            
