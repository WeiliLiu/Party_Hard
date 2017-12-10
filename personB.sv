module  personB ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
									  is_killed,
                             frame_clk,
									  reset_corpse,
									  complete,
						   input[9:0] death_X, death_Y,
            // Whether current pixel belongs to ball or backgroun
					output[9:0]  personB_X, personB_Y,
					output logic police_needed_B
					
              );
    
    parameter [9:0] personB_X_Center=100;  // Center position on the X axis
    parameter [9:0] personB_Y_Center=200;  // Center position on the Y axis
    parameter [9:0] personB_X_Min=100;       // Leftmost point on the X axis
    parameter [9:0] personB_X_Max=400;     // Rightmost point on the X axis
    parameter [9:0] personB_Y_Min=200;       // Topmost point on the Y axis
    parameter [9:0] personB_Y_Max=250;     // Bottommost point on the Y axis
    parameter [9:0] personB_X_Step=1;      // Step size on the X axis
    parameter [9:0] personB_Y_Step=1;      // Step size on the Y axis
    
    logic [9:0] personB_X_Pos, personB_X_Motion, personB_Y_Pos, personB_Y_Motion;
    logic [9:0] personB_X_Pos_in, personB_X_Motion_in, personB_Y_Pos_in, personB_Y_Motion_in;
    
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
	 assign personB_X = personB_X_Pos;
	 assign personB_Y = personB_Y_Pos;
	 
	 enum logic [2:0] {reset, wander, call_police, dead, corpse_removed} State, Next_state;
	 
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
				else if(death_X <= personB_X_Pos + 10'd32 && death_Y <= personB_Y_Pos + 10'd15
			&& death_Y >= personB_Y_Pos - 10'd15 && death_X >= personB_X_Pos - 10'd32)
					Next_state = call_police;
				else
					Next_state = wander;
			call_police:
				if(complete == 1'b1)
					Next_state = wander;
				else
					Next_state = call_police;
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
			police_needed_B = 1'b0;
			personB_X_Pos_in = personB_X_Pos + personB_X_Motion;
         personB_Y_Pos_in = personB_Y_Pos + personB_Y_Motion;
			personB_X_Motion_in = personB_X_Motion;
		   personB_Y_Motion_in = personB_Y_Motion;
			
			case(State)
				Reset:
				begin
					personB_X_Motion_in = 1'b0;
					personB_Y_Motion_in = 1'b0;
					personB_X_Pos_in = personB_X_Center;
					personB_Y_Pos_in = personB_Y_Center;
				end
				wander:
				begin
					if(personB_X_Pos == personB_X_Max && personB_Y_Pos < personB_Y_Max )  // Ball is at the bottom edge, BOUNCE!
					begin
						personB_Y_Motion_in = 1;
						personB_X_Motion_in = 0;
						personB_X_Pos_in = personB_X_Max;
					end
					else if(personB_X_Pos > personB_X_Min && personB_Y_Pos == personB_Y_Max)
					begin
						personB_X_Motion_in = (~(personB_X_Step) + 1'b1);  // 2's complement. 
						personB_Y_Motion_in = 0;
						personB_Y_Pos_in = personB_Y_Max;
					end
					else if(personB_X_Pos == personB_X_Min && personB_Y_Pos > personB_Y_Min)
					begin
						personB_X_Motion_in = 0;
						personB_Y_Motion_in = (~(personB_Y_Step) + 1'b1);
						personB_X_Pos_in = personB_X_Min;
					end
					else if(personB_Y_Pos == personB_Y_Min && personB_X_Pos < personB_X_Max)
					begin
						personB_X_Motion_in = 1;
						personB_Y_Motion_in = 0;
						personB_Y_Pos_in = personB_Y_Min;
					end
				end
				call_police:
				begin
					police_needed_B = 1'b1;
					personB_X_Motion_in = 1'b0;
					personB_Y_Motion_in = 1'b0;
				end
				dead:
				begin
					personB_X_Motion_in = 1'b0;
					personB_Y_Motion_in = 1'b0;
				end
				corpse_removed:
				begin
					personB_X_Motion_in = 1'b0;
					personB_Y_Motion_in = 1'b0;
					personB_X_Pos_in = 1'b0;
					personB_Y_Pos_in = 1'b0;
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
            personB_X_Pos <= personB_X_Center;
            personB_Y_Pos <= personB_Y_Center;
            personB_X_Motion <= 10'd0;
            personB_Y_Motion <= 10'd0;
        end
        else if (frame_clk_rising_edge)        // Update only at rising edge of frame clock
        begin
            personB_X_Pos <= personB_X_Pos_in;
            personB_Y_Pos <= personB_Y_Pos_in;
            personB_X_Motion <= personB_X_Motion_in;
            personB_Y_Motion <= personB_Y_Motion_in;
        end
        // By defualt, keep the register values.
    end
    
endmodule
