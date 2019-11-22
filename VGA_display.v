`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.11.2019 13:39:23
// Design Name: 
// Module Name: VGA_display
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


module VGA_display(
    input CLK,
    input [1:0] MASTER_STATE,
    input [9:0] ADDRH,
    input [8:0] ADDRV,
    input [11:0] COLOUR_SNAKE,
    output reg [11:0] COLOUR_OUT
    );
    
    reg [15:0] FrameCount;
    
    always@(posedge CLK) begin
      if (ADDRV==479) begin
        FrameCount <= FrameCount + 1;
      end
    end
    
    always@(posedge CLK) begin
      case (MASTER_STATE)
      
        //Blank blue screen before the start of snake game
        2'b00: begin
          COLOUR_OUT <= 12'hF00;
        end
        
        //Snake game display
        2'b01: begin
          if (ADDRH >= 0 && ADDRH < 160 && ADDRV >= 0 && ADDRV < 120) 
            COLOUR_OUT <= COLOUR_SNAKE;
          else 
            COLOUR_OUT <= 12'h000;
        end
        
        //Colourful display when snake game is won
        2'b10: begin
          if (ADDRV > 240) begin
            if (ADDRH > 320) 
              COLOUR_OUT <= FrameCount[15:8] + ADDRV[7:0] + ADDRH[7:0] - 240 - 320;
            else 
              COLOUR_OUT <= FrameCount[15:8] + ADDRV[7:0] - ADDRH[7:0] - 240 + 320;
          end
          else begin
            if (ADDRH > 320) 
              COLOUR_OUT <= FrameCount[15:8] - ADDRV[7:0] + ADDRH[7:0] + 240 - 320;
            else 
              COLOUR_OUT <= FrameCount[15:8] - ADDRV[7:0] - ADDRH[7:0] + 240 + 320;
          end
        end
        
        default: 
          COLOUR_OUT <= 12'h000;
        
      endcase
        
    end
    
endmodule
