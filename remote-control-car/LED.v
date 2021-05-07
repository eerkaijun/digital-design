`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: School of Engineering, University of Edinburgh
// Engineer: Yijun Cheng
// 
// Create Date: 2021/02/20 23:12:32
// Design Name: DSL_4_Mouse_Interface_assignment_1
// Module Name: LED
// Project Name: Mouse Interface
// Target Devices: Xilinx Basys 3
// Tool Versions: Xilinx Vivado 2015.2
// Description: 
// ------------------------------------
// |   BTNL   |      Status Bytes     |
// |   BTNU   |   X Direction Bytes   |
// |   BTNR   |   Y Direction Bytes   |
// ------------------------------------
// Dependencies: 
// 
// Revision: 2.1
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module LED(
    input CLK,
    input [7:0] BUS_ADDR,
    input [7:0] BUS_DATA, 
    output [7:0] LED_out
    );
    reg [7:0] out;
    parameter [7:0] LEDBaseAddr = 8'hC0; //LED Base Address in the Memory Map
    always@(posedge CLK)begin
        if(BUS_ADDR == LEDBaseAddr)  
            out  <= BUS_DATA;    
    end   
    
    assign LED_out = out;
endmodule




