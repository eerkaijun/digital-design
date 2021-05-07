`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: School of Engineering, University of Edinburgh
// Engineer: Yijun Cheng
// 
// Create Date: 11/26/2019 03:38:15 PM
// Design Name: DSL_4_Mouse_Interface_assignment_1
// Module Name: Multiplexer
// Project Name: Mouse Interface
// Target Devices: Xilinx Basys 3 
// Tool Versions: Xilinx Vivado 2015.2
// Description: generate selection signal
// 
// Dependencies: 
// 
// Revision: 2.1
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module Multiplexer(
    input CLK,
    input [1:0] Selection_Signal,
    input [3:0] IN0,
    input [3:0] IN1,
    input [3:0] IN2,
    input [3:0] IN3,
    output reg [3:0] OUT
    );
    always@(posedge CLK)
    begin 
        case(Selection_Signal)
            2'b00 : OUT <= IN0;
            2'b01 : OUT <= IN1;
            2'b10 : OUT <= IN2; 
            2'b11 : OUT <= IN3; 
            default : OUT <= 4'b0000;
        endcase
    end
endmodule