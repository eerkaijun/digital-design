`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/30/2021 11:51:28 PM
// Design Name: 
// Module Name: TenHz_cnt
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


module TenHz_cnt(
    input CLK,
    input RESET,
    output SEND_PACKET
    );
    
    //Timing counter to convert the 100MHz internal clock frequency to a 10Hz frequency 
    Generic_counter # (.COUNTER_WIDTH(24),
                       .COUNTER_MAX(9999999)
                       )
                       PacketFrequency (
                        .CLK(CLK),
                        .RESET(RESET),
                        .ENABLE(1'b1),
                        .TRIG_OUT(trigger)
                       );
    
    assign SEND_PACKET = trigger;
                       
endmodule
