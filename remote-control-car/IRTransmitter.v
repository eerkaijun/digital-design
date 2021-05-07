`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2021 07:18:33 PM
// Design Name: 
// Module Name: IRTransmitter
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


module IRTransmitter(
    input CLK,
    input RESET,
    input [7:0] BUS_ADDR,
    input [7:0] BUS_DATA,
    input BUS_WE,
    output IR_LED
    );
    
    reg [3:0] COMMAND;
    wire trigger;
    
    parameter IRTransmitterAddr = 8'h90;
    
    always@(posedge CLK) begin
      if(RESET)
        COMMAND <= 4'h0;
      else if((BUS_ADDR == IRTransmitterAddr) & BUS_WE)
        COMMAND <= BUS_DATA[3:0];
    end
    
    // Generate a packet at 10Hz frequency
    TenHz_cnt counter (
      .CLK(CLK),
      .RESET(RESET),
      .SEND_PACKET(trigger)
    );
    
    IRTransmitterSM sm (
      .CLK(CLK),
      .RESET(RESET),
      .COMMAND(COMMAND),
      .SEND_PACKET(trigger),
      .IR_LED(IR_LED)
    );
    
endmodule
