`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: School of Engineering, University of Edinburgh
// Engineer: Yijun Cheng
// 
// Create Date: 11/26/2019 03:27:55 PM
// Design Name: DSL_4_Mouse_Interface_assignment_1
// Module Name: bit_divider
// Project Name: Mouse Interface
// Target Devices: Xilinx Basys 3
// Tool Versions: Xilinx Vivado 2015.2
// Description: divid incoming 2 8-bit regs to 4 bit display
// 
// Dependencies: 
// 
// Revision: 2.1
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bit_divider(
    input CLK,
    input [7:0] Number_IN_L,
    input [7:0] Number_IN_R,
    output reg [3:0] Bit_0_out,
    output reg [3:0] Bit_1_out,
    output reg [3:0] Bit_2_out,
    output reg [3:0] Bit_3_out
    );
    
    //divid data to hex display for seven segments
    always@(posedge CLK)begin
        Bit_3_out = Number_IN_L[7:4];
        Bit_2_out = Number_IN_L[3:0];
        Bit_1_out = Number_IN_R[7:4];
        Bit_0_out = Number_IN_R[3:0];        
    end
endmodule
