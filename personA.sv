module personA ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
									  is_killed,
                             frame_clk,
									  reset_corpse,
									  complete,
									  attack_out, 
						   input[9:0] death_X, death_Y, ballX, ballY,
            // Whether current pixel belongs to ball or backgroun
					output[9:0]  personA_X, personA_Y,
					output logic police_needed_A, witness_A
					
              );
    
    parameter [9:0] personA_X_Center=400;  // Center position on the X axis
    parameter [9:0] personA_Y_Center=250;  // Center position on the Y axis
    parameter [9:0] personA_X_Min=100;       // Leftmost point on the X axis
    parameter [9:0] personA_X_Max=400;     // Rightmost point on the X axis
    parameter [9:0] personA_Y_Min=200;       // Topmost point on the Y axis
    parameter [9:0] personA_Y_Max=250;     // Bottommost point on the Y axis
    parameter [9:0] personA_X_Step=1;      // Step size on the X axis
    parameter [9:0] personA_Y_Step=1;      // Step size on the Y axis
    
    logic [9:0] personA_X_Pos, personA_X_Motion, personA_Y_Pos, personA_Y_Motion;
    logic [9:0] personA_X_Pos_in, personA_X_Motion_in, personA_Y_Pos_in, personA_Y_Motion_in;
    
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
	 assign personA_X = personA_X_Pos;
	 assign personA_Y = personA_Y_Pos;
	 
	 enum logic [2:0] {reset, wander, call_police1, dead, corpse_removed, call_police2} State, Next_state;
	 
	 always_ff @ (posedge Clk)
	 begin: Assign_Next_State
			if(Reset)
				State <= reset;
			else
				State <= Next_state;
	 end
	 
	 always_comb
	 begin
			Next_state = State;
			
			unique case(State)
			reset: 
				Next_state = wander;
			wander:
				if(is_killed == 1'b1)
					Next_state = dead;
				else if(death_X <= personA_X_Pos + 10'd32 && death_Y <= personA_Y_Pos + 10'd15
			&& death_Y >= personA_Y_Pos - 10'd15 && death_X >= personA_X_Pos - 10'd32)
				begin
					if(ballX <= death_X + 10'd40 && ballY <= death_Y + 10'd40
			&& ballY >= death_Y - 10'd40 && ballX >= death_X - 10'd40)
						Next_state = call_police2;
					else
						Next_state = call_police1;
				end
				else
					Next_state = wander;
			call_police1:
				if(complete == 1'b1)
					Next_state = wander;
				else
					Next_state = call_police1;
			call_police2:
				if(complete == 1'b1)
					Next_state = wander;
				else
					Next_state = call_police2;
			dead:
				if(reset_corpse == 1'b1)
					Next_state = corpse_removed;
				else
					Next_state = dead;
			corpse_removed:
				Next_state = corpse_removed;
			default:;
			endcase
	 end
	 
	 always_comb
	 begin
			police_needed_A = 1'b0;
			witness_A = 1'b0;
			personA_X_Pos_in = personA_X_Pos + personA_X_Motion;
         personA_Y_Pos_in = personA_Y_Pos + personA_Y_Motion;
			personA_X_Motion_in = personA_X_Motion;
		   personA_Y_Motion_in = personA_Y_Motion;
			
			case(State)
				Reset:
				begin
					personA_X_Motion_in = 1'b0;
					personA_Y_Motion_in = 1'b0;
					personA_X_Pos_in = personA_X_Center;
					personA_Y_Pos_in = personA_Y_Center;
				end
				wander:
				begin
					if(personA_X_Pos == personA_X_Max && personA_Y_Pos < personA_Y_Max)  // Ball is at the bottom edge, BOUNCE!
					begin
						personA_Y_Motion_in = 1;
						personA_X_Motion_in = 0;
						personA_X_Pos_in = personA_X_Max;
					end
					else if(personA_X_Pos > personA_X_Min && personA_Y_Pos == personA_Y_Max)
					begin
						personA_X_Motion_in = (~(personA_X_Step) + 1'b1);  // 2's complement. 
						personA_Y_Motion_in = 0;
						personA_Y_Pos_in = personA_Y_Max;
					end
					else if(personA_X_Pos == personA_X_Min && personA_Y_Pos > personA_Y_Min)
					begin
						personA_X_Motion_in = 0;
						personA_Y_Motion_in = (~(personA_Y_Step) + 1'b1);
						personA_X_Pos_in = personA_X_Min;
					end
					else if(personA_Y_Pos == personA_Y_Min && personA_X_Pos < personA_X_Max)
					begin
						personA_X_Motion_in = 1;
						personA_Y_Motion_in = 0;
						personA_Y_Pos_in = personA_Y_Min;
					end
				end
				call_police1:
				begin
					police_needed_A = 1'b1;
					personA_X_Motion_in = 1'b0;
					personA_Y_Motion_in = 1'b0;
				end
				call_police2:
				begin
					police_needed_A = 1'b1;
					witness_A = 1'b1;
					personA_X_Motion_in = 1'b0;
					personA_Y_Motion_in = 1'b0;
				end
				dead:
				begin
					personA_X_Motion_in = 1'b0;
					personA_Y_Motion_in = 1'b0;
				end
				corpse_removed:
				begin
					personA_X_Motion_in = 1'b0;
					personA_Y_Motion_in = 1'b0;
					personA_X_Pos_in = 1'b0;
					personA_Y_Pos_in = 1'b0;
				end
			endcase
		end
			
    
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
            personA_X_Pos <= personA_X_Center;
            personA_Y_Pos <= personA_Y_Center;
            personA_X_Motion <= 10'd0;
            personA_Y_Motion <= 10'd0;
        end
        else if (frame_clk_rising_edge)        // Update only at rising edge of frame clock
        begin
            personA_X_Pos <= personA_X_Pos_in;
            personA_Y_Pos <= personA_Y_Pos_in;
            personA_X_Motion <= personA_X_Motion_in;
            personA_Y_Motion <= personA_Y_Motion_in;
        end
        // By defualt, keep the register values.
    end
    
endmodule
