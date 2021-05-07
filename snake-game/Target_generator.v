`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.11.2019 10:13:50
// Design Name: 
// Module Name: Target_generator
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


module Target_generator(
    input CLK,
    input REACHED,
    input TRIG,
    input [1:0] MASTER_STATE,
    output reg [7:0] RAND_ADDRH,
    output reg [6:0] RAND_ADDRV
    );
   
    reg [7:0] horz;
    reg [6:0] vert;
    
    //Linear feedback shift register
    always@(posedge CLK) begin 
      if (MASTER_STATE == 2'b00) begin
        horz <= 50;
        vert <= 50;
      end
      else begin 
        horz[7] <= horz[6];
        horz[6] <= horz[5];
        horz[5] <= horz[4];
        horz[4] <= horz[3];
        horz[3] <= horz[2];
        horz[2] <= horz[1];
        horz[1] <= horz[0];
        horz[0] <= ((horz[7]~^horz[5])~^horz[4])~^horz[3];
        
        vert[6] <= vert[5];
        vert[5] <= vert[4];
        vert[4] <= vert[3];
        vert[3] <= vert[2];
        vert[2] <= vert[1];
        vert[1] <= vert[0];
        vert[0] <= vert[6]~^vert[5];
      end
    end
    
    //Position of target only changes when REACHED is true
    //The random target must be within pixel range
    //When out of range, divide by 2
    always@(REACHED or TRIG) begin
      
      if (REACHED || TRIG) begin
        if (horz < 160 && vert < 120) begin
          RAND_ADDRH <= horz;
          RAND_ADDRV <= vert;
        end
        else if (horz >= 160 && vert < 120) begin
          RAND_ADDRH <= {1'b0, horz[7:1]};
          RAND_ADDRV <= vert;
        end
        else if (horz < 160 && vert >= 120) begin
          RAND_ADDRH <= horz;
          RAND_ADDRV <= {1'b0, vert[6:1]};
        end
        else begin
          RAND_ADDRH <= {1'b0, horz[7:1]};
          RAND_ADDRV <= {1'b0, vert[6:1]};
        end
      end
    
    end
    
endmodule
