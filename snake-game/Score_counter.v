`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.11.2019 10:18:46
// Design Name: 
// Module Name: Score_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Score_counter(
    input CLK,
    input RESET,
    input REACHED,
    output WIN,
    output [3:0] SEG_SELECT,
    output [7:0] HEX_OUT
    );
    
    wire [1:0] DecCount;
    
    Generic_counter # (.COUNTER_WIDTH(2),
                       .COUNTER_MAX(2)
                       )
                       Bit2Counter (
                       .CLK(CLK),
                       .RESET(RESET),
                       .ENABLE(REACHED),
                       .TRIG_OUT(WIN),
                       .COUNT(DecCount)
                      );
    
    Seg7_display Seg7(
      .SEG_SELECT_IN(2'b00),
      .BIN_IN(DecCount),
      .DOT_IN(1'b1),
      .SEG_SELECT_OUT(SEG_SELECT),
      .HEX_OUT(HEX_OUT)
    );
    
    
endmodule
