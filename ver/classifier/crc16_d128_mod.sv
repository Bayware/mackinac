////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 1999-2008 Easics NV.
// This source file may be used and distributed without restriction
// provided that this copyright statement is not removed from the file
// and that any derivative work contains the original copyright notice
// and the associated disclaimer.
//
// THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
// OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
// WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
//
// Purpose : synthesizable CRC function
//   * polynomial: x^16 + x^15 + x^2 + 1
//   * data width: 128
//
// Info : tools@easics.be
//        http://www.easics.com
////////////////////////////////////////////////////////////////////////////////

module crc16_d128_mod
(
    // system
    input logic clk,
    input logic rst_n,

    input logic [ 127:0 ] data,
    input logic [ 15:0 ] crc,

    output logic [ 15:0 ] next_crc
);

// polynomial: x^16 + x^15 + x^2 + 1
// data width: 128
// convention: the first serial bit is D[127]

// =======================================================================
// Declarations & Parameters

logic [127:0] d;
logic [15:0] c;
logic [15:0] newcrc;

// =======================================================================
// Combinational Logic

assign d = data;
assign c = crc;

always_comb
begin
    newcrc[0] = d[127] ^ d[125] ^ d[124] ^ d[123] ^ d[122] ^ d[121] ^ d[120] ^ d[111] ^ d[110] ^ d[109] ^ d[108] ^ d[107] ^ d[106] ^ d[105] ^ d[103] ^ d[101] ^ d[99] ^ d[97] ^ d[96] ^ d[95] ^ d[94] ^ d[93] ^ d[92] ^ d[91] ^ d[90] ^ d[87] ^ d[86] ^ d[83] ^ d[82] ^ d[81] ^ d[80] ^ d[79] ^ d[78] ^ d[77] ^ d[76] ^ d[75] ^ d[73] ^ d[72] ^ d[71] ^ d[69] ^ d[68] ^ d[67] ^ d[66] ^ d[65] ^ d[64] ^ d[63] ^ d[62] ^ d[61] ^ d[60] ^ d[55] ^ d[54] ^ d[53] ^ d[52] ^ d[51] ^ d[50] ^ d[49] ^ d[48] ^ d[47] ^ d[46] ^ d[45] ^ d[43] ^ d[41] ^ d[40] ^ d[39] ^ d[38] ^ d[37] ^ d[36] ^ d[35] ^ d[34] ^ d[33] ^ d[32] ^ d[31] ^ d[30] ^ d[27] ^ d[26] ^ d[25] ^ d[24] ^ d[23] ^ d[22] ^ d[21] ^ d[20] ^ d[19] ^ d[18] ^ d[17] ^ d[16] ^ d[15] ^ d[13] ^ d[12] ^ d[11] ^ d[10] ^ d[9] ^ d[8] ^ d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[8] ^ c[9] ^ c[10] ^ c[11] ^ c[12] ^ c[13] ^ c[15];
    newcrc[1] = d[126] ^ d[125] ^ d[124] ^ d[123] ^ d[122] ^ d[121] ^ d[112] ^ d[111] ^ d[110] ^ d[109] ^ d[108] ^ d[107] ^ d[106] ^ d[104] ^ d[102] ^ d[100] ^ d[98] ^ d[97] ^ d[96] ^ d[95] ^ d[94] ^ d[93] ^ d[92] ^ d[91] ^ d[88] ^ d[87] ^ d[84] ^ d[83] ^ d[82] ^ d[81] ^ d[80] ^ d[79] ^ d[78] ^ d[77] ^ d[76] ^ d[74] ^ d[73] ^ d[72] ^ d[70] ^ d[69] ^ d[68] ^ d[67] ^ d[66] ^ d[65] ^ d[64] ^ d[63] ^ d[62] ^ d[61] ^ d[56] ^ d[55] ^ d[54] ^ d[53] ^ d[52] ^ d[51] ^ d[50] ^ d[49] ^ d[48] ^ d[47] ^ d[46] ^ d[44] ^ d[42] ^ d[41] ^ d[40] ^ d[39] ^ d[38] ^ d[37] ^ d[36] ^ d[35] ^ d[34] ^ d[33] ^ d[32] ^ d[31] ^ d[28] ^ d[27] ^ d[26] ^ d[25] ^ d[24] ^ d[23] ^ d[22] ^ d[21] ^ d[20] ^ d[19] ^ d[18] ^ d[17] ^ d[16] ^ d[14] ^ d[13] ^ d[12] ^ d[11] ^ d[10] ^ d[9] ^ d[8] ^ d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ c[0] ^ c[9] ^ c[10] ^ c[11] ^ c[12] ^ c[13] ^ c[14];
    newcrc[2] = d[126] ^ d[121] ^ d[120] ^ d[113] ^ d[112] ^ d[106] ^ d[98] ^ d[91] ^ d[90] ^ d[89] ^ d[88] ^ d[87] ^ d[86] ^ d[85] ^ d[84] ^ d[76] ^ d[74] ^ d[72] ^ d[70] ^ d[61] ^ d[60] ^ d[57] ^ d[56] ^ d[46] ^ d[42] ^ d[31] ^ d[30] ^ d[29] ^ d[28] ^ d[16] ^ d[14] ^ d[1] ^ d[0] ^ c[0] ^ c[1] ^ c[8] ^ c[9] ^ c[14];
    newcrc[3] = d[127] ^ d[122] ^ d[121] ^ d[114] ^ d[113] ^ d[107] ^ d[99] ^ d[92] ^ d[91] ^ d[90] ^ d[89] ^ d[88] ^ d[87] ^ d[86] ^ d[85] ^ d[77] ^ d[75] ^ d[73] ^ d[71] ^ d[62] ^ d[61] ^ d[58] ^ d[57] ^ d[47] ^ d[43] ^ d[32] ^ d[31] ^ d[30] ^ d[29] ^ d[17] ^ d[15] ^ d[2] ^ d[1] ^ c[1] ^ c[2] ^ c[9] ^ c[10] ^ c[15];
    newcrc[4] = d[123] ^ d[122] ^ d[115] ^ d[114] ^ d[108] ^ d[100] ^ d[93] ^ d[92] ^ d[91] ^ d[90] ^ d[89] ^ d[88] ^ d[87] ^ d[86] ^ d[78] ^ d[76] ^ d[74] ^ d[72] ^ d[63] ^ d[62] ^ d[59] ^ d[58] ^ d[48] ^ d[44] ^ d[33] ^ d[32] ^ d[31] ^ d[30] ^ d[18] ^ d[16] ^ d[3] ^ d[2] ^ c[2] ^ c[3] ^ c[10] ^ c[11];
    newcrc[5] = d[124] ^ d[123] ^ d[116] ^ d[115] ^ d[109] ^ d[101] ^ d[94] ^ d[93] ^ d[92] ^ d[91] ^ d[90] ^ d[89] ^ d[88] ^ d[87] ^ d[79] ^ d[77] ^ d[75] ^ d[73] ^ d[64] ^ d[63] ^ d[60] ^ d[59] ^ d[49] ^ d[45] ^ d[34] ^ d[33] ^ d[32] ^ d[31] ^ d[19] ^ d[17] ^ d[4] ^ d[3] ^ c[3] ^ c[4] ^ c[11] ^ c[12];
    newcrc[6] = d[125] ^ d[124] ^ d[117] ^ d[116] ^ d[110] ^ d[102] ^ d[95] ^ d[94] ^ d[93] ^ d[92] ^ d[91] ^ d[90] ^ d[89] ^ d[88] ^ d[80] ^ d[78] ^ d[76] ^ d[74] ^ d[65] ^ d[64] ^ d[61] ^ d[60] ^ d[50] ^ d[46] ^ d[35] ^ d[34] ^ d[33] ^ d[32] ^ d[20] ^ d[18] ^ d[5] ^ d[4] ^ c[4] ^ c[5] ^ c[12] ^ c[13];
    newcrc[7] = d[126] ^ d[125] ^ d[118] ^ d[117] ^ d[111] ^ d[103] ^ d[96] ^ d[95] ^ d[94] ^ d[93] ^ d[92] ^ d[91] ^ d[90] ^ d[89] ^ d[81] ^ d[79] ^ d[77] ^ d[75] ^ d[66] ^ d[65] ^ d[62] ^ d[61] ^ d[51] ^ d[47] ^ d[36] ^ d[35] ^ d[34] ^ d[33] ^ d[21] ^ d[19] ^ d[6] ^ d[5] ^ c[5] ^ c[6] ^ c[13] ^ c[14];
    newcrc[8] = d[127] ^ d[126] ^ d[119] ^ d[118] ^ d[112] ^ d[104] ^ d[97] ^ d[96] ^ d[95] ^ d[94] ^ d[93] ^ d[92] ^ d[91] ^ d[90] ^ d[82] ^ d[80] ^ d[78] ^ d[76] ^ d[67] ^ d[66] ^ d[63] ^ d[62] ^ d[52] ^ d[48] ^ d[37] ^ d[36] ^ d[35] ^ d[34] ^ d[22] ^ d[20] ^ d[7] ^ d[6] ^ c[0] ^ c[6] ^ c[7] ^ c[14] ^ c[15];
    newcrc[9] = d[127] ^ d[120] ^ d[119] ^ d[113] ^ d[105] ^ d[98] ^ d[97] ^ d[96] ^ d[95] ^ d[94] ^ d[93] ^ d[92] ^ d[91] ^ d[83] ^ d[81] ^ d[79] ^ d[77] ^ d[68] ^ d[67] ^ d[64] ^ d[63] ^ d[53] ^ d[49] ^ d[38] ^ d[37] ^ d[36] ^ d[35] ^ d[23] ^ d[21] ^ d[8] ^ d[7] ^ c[1] ^ c[7] ^ c[8] ^ c[15];
    newcrc[10] = d[121] ^ d[120] ^ d[114] ^ d[106] ^ d[99] ^ d[98] ^ d[97] ^ d[96] ^ d[95] ^ d[94] ^ d[93] ^ d[92] ^ d[84] ^ d[82] ^ d[80] ^ d[78] ^ d[69] ^ d[68] ^ d[65] ^ d[64] ^ d[54] ^ d[50] ^ d[39] ^ d[38] ^ d[37] ^ d[36] ^ d[24] ^ d[22] ^ d[9] ^ d[8] ^ c[2] ^ c[8] ^ c[9];
    newcrc[11] = d[122] ^ d[121] ^ d[115] ^ d[107] ^ d[100] ^ d[99] ^ d[98] ^ d[97] ^ d[96] ^ d[95] ^ d[94] ^ d[93] ^ d[85] ^ d[83] ^ d[81] ^ d[79] ^ d[70] ^ d[69] ^ d[66] ^ d[65] ^ d[55] ^ d[51] ^ d[40] ^ d[39] ^ d[38] ^ d[37] ^ d[25] ^ d[23] ^ d[10] ^ d[9] ^ c[3] ^ c[9] ^ c[10];
    newcrc[12] = d[123] ^ d[122] ^ d[116] ^ d[108] ^ d[101] ^ d[100] ^ d[99] ^ d[98] ^ d[97] ^ d[96] ^ d[95] ^ d[94] ^ d[86] ^ d[84] ^ d[82] ^ d[80] ^ d[71] ^ d[70] ^ d[67] ^ d[66] ^ d[56] ^ d[52] ^ d[41] ^ d[40] ^ d[39] ^ d[38] ^ d[26] ^ d[24] ^ d[11] ^ d[10] ^ c[4] ^ c[10] ^ c[11];
    newcrc[13] = d[124] ^ d[123] ^ d[117] ^ d[109] ^ d[102] ^ d[101] ^ d[100] ^ d[99] ^ d[98] ^ d[97] ^ d[96] ^ d[95] ^ d[87] ^ d[85] ^ d[83] ^ d[81] ^ d[72] ^ d[71] ^ d[68] ^ d[67] ^ d[57] ^ d[53] ^ d[42] ^ d[41] ^ d[40] ^ d[39] ^ d[27] ^ d[25] ^ d[12] ^ d[11] ^ c[5] ^ c[11] ^ c[12];
    newcrc[14] = d[125] ^ d[124] ^ d[118] ^ d[110] ^ d[103] ^ d[102] ^ d[101] ^ d[100] ^ d[99] ^ d[98] ^ d[97] ^ d[96] ^ d[88] ^ d[86] ^ d[84] ^ d[82] ^ d[73] ^ d[72] ^ d[69] ^ d[68] ^ d[58] ^ d[54] ^ d[43] ^ d[42] ^ d[41] ^ d[40] ^ d[28] ^ d[26] ^ d[13] ^ d[12] ^ c[6] ^ c[12] ^ c[13];
    newcrc[15] = d[127] ^ d[126] ^ d[124] ^ d[123] ^ d[122] ^ d[121] ^ d[120] ^ d[119] ^ d[110] ^ d[109] ^ d[108] ^ d[107] ^ d[106] ^ d[105] ^ d[104] ^ d[102] ^ d[100] ^ d[98] ^ d[96] ^ d[95] ^ d[94] ^ d[93] ^ d[92] ^ d[91] ^ d[90] ^ d[89] ^ d[86] ^ d[85] ^ d[82] ^ d[81] ^ d[80] ^ d[79] ^ d[78] ^ d[77] ^ d[76] ^ d[75] ^ d[74] ^ d[72] ^ d[71] ^ d[70] ^ d[68] ^ d[67] ^ d[66] ^ d[65] ^ d[64] ^ d[63] ^ d[62] ^ d[61] ^ d[60] ^ d[59] ^ d[54] ^ d[53] ^ d[52] ^ d[51] ^ d[50] ^ d[49] ^ d[48] ^ d[47] ^ d[46] ^ d[45] ^ d[44] ^ d[42] ^ d[40] ^ d[39] ^ d[38] ^ d[37] ^ d[36] ^ d[35] ^ d[34] ^ d[33] ^ d[32] ^ d[31] ^ d[30] ^ d[29] ^ d[26] ^ d[25] ^ d[24] ^ d[23] ^ d[22] ^ d[21] ^ d[20] ^ d[19] ^ d[18] ^ d[17] ^ d[16] ^ d[15] ^ d[14] ^ d[12] ^ d[11] ^ d[10] ^ d[9] ^ d[8] ^ d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[7] ^ c[8] ^ c[9] ^ c[10] ^ c[11] ^ c[12] ^ c[14] ^ c[15];
end

// =======================================================================
// Registered Logic

always @( posedge clk )
    if ( !rst_n )
        next_crc <= 16'd0;

    else
        next_crc <= newcrc;

endmodule
