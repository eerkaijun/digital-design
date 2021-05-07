`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/19/2021 11:32:37 AM
// Design Name: 
// Module Name: IRTransmitterSM
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


module IRTransmitterSM(
    input CLK,
    input RESET,
    input [3:0] COMMAND,
    input SEND_PACKET,
    output IR_LED
    );
    
    parameter StartBurstSize = 88;
    parameter CarSelectBurstSize = 22;
    parameter GapSize = 40;
    parameter AssertBurstSize = 44;
    parameter DeAssertBurstSize = 22;
    
    wire trigger;
    wire switch; 
    
    //Timing counter to convert the 100MHz internal clock frequency to a 40kHz frequency 
    //Pulses should be sent at this frequency
    Generic_counter # (.COUNTER_WIDTH(12),
                       .COUNTER_MAX(2499)
                       )
                       PulseFrequency (
                        .CLK(CLK),
                        .RESET(RESET),
                        .ENABLE(1'b1),
                        .TRIG_OUT(trigger)
                       );
    
    //Timing counter to convert the 100MHz internal clock frequency to a 80kHz frequency for clock signal
    Generic_counter # (.COUNTER_WIDTH(11),
                       .COUNTER_MAX(1249)
                       )
                       ClockShape (
                        .CLK(CLK),
                        .RESET(RESET),
                        .ENABLE(1'b1),
                        .TRIG_OUT(switch)
                       );
    
    reg [3:0] Curr_state = 4'd0;
    reg [3:0] Next_state = 4'd0;
    reg [7:0] Curr_burst_counter = 0;
    reg [7:0] Next_burst_counter = 0;
    reg LED = 0;
    reg Next_LED = 0;
    reg clock = 0;
    reg Start_SM = 0; 
    reg [3:0] DIRECTION;
    
    // sequential logic
    always@(posedge CLK) begin
      if (RESET) begin
        Curr_state <= 4'd0;
        Curr_burst_counter <= 0;
        LED <= 0;
      end
      else begin
        Curr_state <= Next_state;
        LED <= Next_LED; 
        Curr_burst_counter <= Next_burst_counter;
      end
    end
    
    // store the send_packet signal in a register until it triggers a state change
    always@(SEND_PACKET) begin
      Start_SM <= 1;
      DIRECTION <= COMMAND;
    end
    
    // combinational logic for clock signal
    always@(posedge switch) begin
      clock <= ~clock;
    end
    
    // combinational logic for state machine
    always@(posedge trigger) begin
      
      case(Curr_state)
       
        // idle state
        4'd0: begin
          if (Start_SM) begin
            Next_state <= 4'd1;
            Next_LED <= 1;
            Start_SM <= 0;
          end
          else
            Next_state <= Curr_state;
        end
        
        // start burst
        4'd1: begin
          if (Curr_burst_counter == StartBurstSize-1) begin
            Next_state <= 4'd2;
            Next_burst_counter <= 0;
            Next_LED <= 0;
          end
          else begin
           Next_burst_counter <= Curr_burst_counter + 1;
           Next_LED <= 1;
          end
        end
        
        // gap 
        4'd2: begin
          if (Curr_burst_counter == GapSize-1) begin
            Next_state <= 4'd3;
            Next_burst_counter <= 0;
            Next_LED <= 1;
          end
          else begin
            Next_burst_counter <= Curr_burst_counter + 1;
            Next_LED <= 0;
          end
        end
        
        // car select burst 
        4'd3: begin
          if (Curr_burst_counter == CarSelectBurstSize-1) begin
            Next_state <= 4'd4;
            Next_burst_counter <= 0;
            Next_LED <= 0;
          end
          else begin
            Next_burst_counter <= Curr_burst_counter + 1;
            Next_LED <= 1;
          end
        end  
        
        // gap 
        4'd4: begin
          if (Curr_burst_counter == GapSize-1) begin
            Next_state <= 4'd5;
            Next_burst_counter <= 0;
            Next_LED <= 1;
          end
          else begin
            Next_burst_counter <= Curr_burst_counter + 1;
            Next_LED <= 0;
          end
        end  
        
        // right assert burst 
        4'd5: begin
          if (DIRECTION[0]) begin // assert right
            if (Curr_burst_counter == AssertBurstSize-1) begin
              Next_state <= 4'd6;
              Next_burst_counter <= 0;
              Next_LED <= 0;
            end
            else begin 
              Next_burst_counter <= Curr_burst_counter + 1;
              Next_LED <= 1;
            end 
          end
          else begin // deassert right
            if (Curr_burst_counter == DeAssertBurstSize-1) begin
              Next_state <= 4'd6;
              Next_burst_counter <= 0;
              Next_LED <= 0;
            end
            else begin 
              Next_burst_counter <= Curr_burst_counter + 1;
              Next_LED <= 1;
            end
          end
        end

        // gap 
        4'd6: begin
          if (Curr_burst_counter == GapSize-1) begin
            Next_state <= 4'd7;
            Next_burst_counter <= 0;
            Next_LED <= 1;
          end
          else begin
            Next_burst_counter <= Curr_burst_counter + 1;
            Next_LED <= 0;
          end
        end

        // left assert burst 
        4'd7: begin
          if (DIRECTION[1]) begin // assert left
            if (Curr_burst_counter == AssertBurstSize-1) begin
              Next_state <= 4'd8;
              Next_burst_counter <= 0;
              Next_LED <= 0;
            end
            else begin 
              Next_burst_counter <= Curr_burst_counter + 1;
              Next_LED <= 1;
            end 
          end
          else begin // deassert left
            if (Curr_burst_counter == DeAssertBurstSize-1) begin
              Next_state <= 4'd8;
              Next_burst_counter <= 0;
              Next_LED <= 0;
            end
            else begin 
              Next_burst_counter <= Curr_burst_counter + 1;
              Next_LED <= 1;
            end
          end 
        end
      
        // gap 
        4'd8: begin
          if (Curr_burst_counter == GapSize-1) begin
            Next_state <= 4'd9;
            Next_burst_counter <= 0;
            Next_LED <= 1;
          end
          else begin
            Next_burst_counter <= Curr_burst_counter + 1;
            Next_LED <= 0;
          end
        end
        
        // backward assert burst 
        4'd9: begin
          if (DIRECTION[2]) begin // assert backward
            if (Curr_burst_counter == AssertBurstSize-1) begin
              Next_state <= 4'd10;
              Next_burst_counter <= 0;
              Next_LED <= 0;
            end
            else begin 
              Next_burst_counter <= Curr_burst_counter + 1;
              Next_LED <= 1;
            end 
          end
          else begin // deassert backward
            if (Curr_burst_counter == DeAssertBurstSize-1) begin
              Next_state <= 4'd10;
              Next_burst_counter <= 0;
              Next_LED <= 0;
            end
            else begin 
              Next_burst_counter <= Curr_burst_counter + 1;
              Next_LED <= 1;
            end
          end
        end
        
        // gap 
        4'd10: begin
          if (Curr_burst_counter == GapSize-1) begin
            Next_state <= 4'd11;
            Next_burst_counter <= 0;
            Next_LED <= 1;
          end
          else begin
            Next_burst_counter <= Curr_burst_counter + 1;
            Next_LED <= 0;
          end
        end
        
        // forward assert burst 
        4'd11: begin
          if (DIRECTION[3]) begin // assert forward
            if (Curr_burst_counter == AssertBurstSize-1) begin
              Next_state <= 4'd12;
              Next_burst_counter <= 0;
              Next_LED <= 0;
            end
            else begin 
              Next_burst_counter <= Curr_burst_counter + 1;
              Next_LED <= 1;
            end 
          end
          else begin // deassert forward
            if (Curr_burst_counter == DeAssertBurstSize-1) begin
              Next_state <= 4'd12;
              Next_burst_counter <= 0;
              Next_LED <= 0;
            end
            else begin 
              Next_burst_counter <= Curr_burst_counter + 1;
              Next_LED <= 1;
            end
          end 
        end   
        
        // gap 
        4'd12: begin
          if (Curr_burst_counter == GapSize-1) begin
            Next_state <= 4'd0;
            Next_burst_counter <= 0;
          end
          else begin
            Next_burst_counter <= Curr_burst_counter + 1;
          end
          Next_LED <= 0;
        end
        
        default: begin
          Next_state <= 4'd0;       
          Next_burst_counter <= 0;
          Next_LED <= 0;
        end 
        
      endcase
    end
    
    assign IR_LED = LED & clock;
    
endmodule

module Generic_counter(
    CLK,
    RESET,
    ENABLE,
    TRIG_OUT,
    COUNT
    );
    
    parameter COUNTER_WIDTH = 4;
    parameter COUNTER_MAX = 9;
    
    input CLK;
    input RESET;
    input ENABLE;
    output TRIG_OUT;
    output [COUNTER_WIDTH-1:0] COUNT;
    
    //Declare registers that hold the current count value and trigger out between clock cycles
    reg [COUNTER_WIDTH-1:0] count_value = 0;
    reg Trigger_out;
    
    //Synchronous logic for value of count_value
    always@(posedge CLK) begin 
      if (RESET) 
        count_value <= 0; 
      else begin 
        if(ENABLE) begin 
          if (count_value == COUNTER_MAX)
            count_value <= 0;
          else 
            count_value <= count_value + 1;
        end
      end
    end
    
    //Syncchronous logic for Trigger_out
    always@(posedge CLK) begin 
      if(RESET) 
        Trigger_out <= 0;
      else begin 
        if (ENABLE && (count_value == COUNTER_MAX)) 
          Trigger_out <= 1;
        else 
          Trigger_out <= 0; 
      end
    end
    
    assign COUNT = count_value;
    assign TRIG_OUT = Trigger_out; 
    
endmodule
