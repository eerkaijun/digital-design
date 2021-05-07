`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.11.2019 16:29:04
// Design Name: 
// Module Name: Snake_controller
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


module Snake_controller(
    input CLK,
    input RESET,
    input [1:0] DIRECTION,
    input [9:0] ADDRH,
    input [8:0] ADDRV,
    input [7:0] RAND_ADDRH,
    input [6:0] RAND_ADDRV,
    input [1:0] MASTER_STATE,
    output reg [11:0] COLOUR_OUT,
    output reg REACHED
    );
     
    parameter SnakeLength = 10; //Length of the snake
    parameter MaxX = 159; //Maximum horizontal screen resolution
    parameter MaxY = 119; //Maximum vertical screen resolution
    
    reg [7:0] SnakeState_X [0: SnakeLength-1];
    reg [6:0] SnakeState_Y [0: SnakeLength-1];
    
    wire trigger;
    
    //Adjust the frequency for the moving snake
    Generic_counter # (.COUNTER_WIDTH(24),
                       .COUNTER_MAX(10000000)
                      )
                      FrequencyAdjuster (
                        .CLK(CLK),
                        .ENABLE(1'b1),
                        .TRIG_OUT(trigger)
                      );
    
    //Changing the position of the snake registers
    //Shift the SnakeState X and Y
    genvar PixNo;
    generate 
      for (PixNo=0; PixNo < SnakeLength-1; PixNo = PixNo+1)
      begin: PixShift
        always@(posedge trigger) begin
          if(RESET) begin
            SnakeState_X[PixNo+1] <= 80;
            SnakeState_Y[PixNo+1] <= 100;
          end
          else if (MASTER_STATE == 2'b01) begin
            SnakeState_X[PixNo+1] <= SnakeState_X[PixNo];
            SnakeState_Y[PixNo+1] <= SnakeState_Y[PixNo];
          end
        end
      end
    endgenerate
    
    always@(posedge trigger) begin 
      //Initial position of the snake
      if (RESET) begin
        SnakeState_X[0] <= 80;
        SnakeState_Y[0] <= 100;
      end
      else if (MASTER_STATE == 2'b01) begin
        case(DIRECTION)
        
          //Direction UP
          2'b00 : begin
            if(SnakeState_Y[0] == 0)
              SnakeState_Y[0] <= MaxY;
            else 
              SnakeState_Y[0] <= SnakeState_Y[0] -1;
          end
          
          //Direction DOWN
          2'b01 : begin
            if(SnakeState_Y[0] == MaxY)
              SnakeState_Y[0] <= 0;
            else 
              SnakeState_Y[0] <= SnakeState_Y[0] +1;
          end
          
          //Direction LEFT
          2'b10 : begin
            if(SnakeState_X[0] == 0)
              SnakeState_X[0] <= MaxX;
            else 
              SnakeState_X[0] <= SnakeState_X[0] -1;
          end
          
          //Direction RIGHT
          2'b11 : begin
            if(SnakeState_X[0] == MaxX)
              SnakeState_X[0] <= 0;
            else 
              SnakeState_X[0] <= SnakeState_X[0] +1;
          end
              
        endcase
      end
    end
    
    //Synchronous logic to determine whether the target is reached
    always@(posedge CLK) begin
      if (SnakeState_X[0] == RAND_ADDRH && SnakeState_Y[0] == RAND_ADDRV) 
        REACHED <= 1;
      else 
        REACHED <= 0;
    end
    
    //Temporary register to determine whether pixel address belongs to snake
    reg [SnakeLength-1: 0] snake;
    genvar Pix;
        generate
        for (Pix=0; Pix < SnakeLength-1; Pix = Pix+1)
        begin: PixColour
          always@(posedge CLK) begin  
            if (ADDRH == {2'b00, SnakeState_X[Pix]} && ADDRV == {2'b00, SnakeState_Y[Pix]})  
              snake[Pix] <= 1;
            else
              snake[Pix] <= 0;
          end
        end  
    endgenerate
    
    //Temporary register to determine whether pixel address belongs to target
    reg target;
    always@(posedge CLK) begin
      if (ADDRH == {2'b00, RAND_ADDRH} && ADDRV == {2'b00, RAND_ADDRV})
        target <= 1;
      else 
        target <= 0;
    end
    
    //Logic to determine whether the pixel addres belongs to the snake or target or neither
    always@(snake or target) begin
      if (snake > 0)
        COLOUR_OUT <= 12'h00F;
      else if (target == 1)
        COLOUR_OUT <= 12'hF00;
      else 
        COLOUR_OUT <= 12'hAAA;
    end
    
endmodule
