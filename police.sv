//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  police ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
									  police_out,
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
					input [9:0]   dead_X, dead_Y,
            // Whether current pixel belongs to ball or backgroun
					output[9:0]  ballX, ballY,
					output collected,
					output reached
              );
    
    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=440;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=100;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=300;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=200;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=300;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis
    parameter [9:0] Ball_Size=4;        // Ball size
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
	 logic collected_in;
    
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
    int DistX, DistY, Size;
    assign DistX = DrawX - Ball_X_Pos;
    assign DistY = DrawY - Ball_Y_Pos;
    assign Size = Ball_Size;
	 assign ballX = Ball_X_Pos;
	 assign ballY = Ball_Y_Pos;
    
    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed;
    logic frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
    end
    assign frame_clk_rising_edge = (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    // Update ball position and motion
    always_ff @ (posedge Clk)
    begin
        if (Reset)
        begin
            Ball_X_Pos <= Ball_X_Center;
            Ball_Y_Pos <= Ball_Y_Center;
            Ball_X_Motion <= 10'd0;
            Ball_Y_Motion <= 10'd0;
				collected <= 0;
        end
        else if (frame_clk_rising_edge)        // Update only at rising edge of frame clock
        begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
            Ball_X_Motion <= Ball_X_Motion_in;
            Ball_Y_Motion <= Ball_Y_Motion_in;
				collected<=collected_in;
        end
        // By defualt, keep the register values.
    end
    
    // You need to modify always_comb block.
    always_comb
	 begin
		reached=0;
		if(police_out && collected==0)
		begin
			collected_in=0;
			Ball_X_Motion_in = 0;
			Ball_Y_Motion_in = 0;
			if(Ball_X_Pos > dead_X)
			begin
				Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
			end
			if(Ball_X_Pos < dead_X)
			begin
				Ball_X_Motion_in = 1;
			end
			if(Ball_Y_Pos > dead_Y)
			begin
				Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
			end
			if(Ball_Y_Pos == dead_Y && Ball_X_Pos == dead_X)
			begin
				collected_in= 1;
			end
		end
		else if(police_out && collected==1)
		begin
			collected_in=1;
			Ball_X_Motion_in = 0;
			Ball_Y_Motion_in = 0;
			if(Ball_X_Pos > 320)
			begin
				Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
			end
			if(Ball_X_Pos < 320)
			begin
				Ball_X_Motion_in = 1;
			end
			if(Ball_Y_Pos < 440)
			begin
				Ball_Y_Motion_in =1;
			end
			if(Ball_Y_Pos == 440 && Ball_X_Pos == 320)
			begin
				reached = 1;
			end
		end
			
		else
		begin
			Ball_X_Motion_in = Ball_X_Motion;
         Ball_Y_Motion_in = Ball_Y_Motion;
			collected_in=collected;
		end
	 end
    
    // You need to modify always_comb block.
    always_comb
    begin
        // Update the ball's position with its motion
		  Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
		  Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
		  
		  if(Ball_X_Pos == dead_X && collected==0)
		  begin
				Ball_X_Pos_in = Ball_X_Pos;
		  end 
		  if(Ball_Y_Pos == dead_Y && collected==0)
		  begin
				Ball_Y_Pos_in = Ball_Y_Pos;
		  end
		  if(Ball_X_Pos == 320 && collected==1)
		  begin
				Ball_X_Pos_in = Ball_X_Pos;
		  end 
		  if(Ball_Y_Pos == 440 && collected==1)
		  begin
				Ball_Y_Pos_in = Ball_Y_Pos;
		  end
		 
    
        // By default, keep motion unchanged
        
        // Be careful when using comparators with "logic" datatype because compiler treats 
        //   both sides of the operator UNSIGNED numbers. (unless with further type casting)
        // e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min 
        // If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
        /*if( Ball_Y_Pos + Ball_Size >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
            Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);  // 2's complement.  
        else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size )  // Ball is at the top edge, BOUNCE!
            Ball_Y_Motion_in = Ball_Y_Step;*/
        
        // TODO: Add other boundary conditions and handle keypress here.
        
    /**************************************************************************************
        ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
        Hidden Question #2/2:
          Notice that Ball_Y_Pos is updated using Ball_Y_Motion. 
          Will the new value of Ball_Y_Motion be used when Ball_Y_Pos is updated, or the old? 
          What is the difference between writing
            "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;" and 
            "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion_in;"?
          How will this impact behavior of the ball during a bounce, and how might that interact with a response to a keypress?
          Give an answer in your Post-Lab.
    **************************************************************************************/
        
        // Compute whether the pixel corresponds to ball or background
        
        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */
        
    end
    
endmodule