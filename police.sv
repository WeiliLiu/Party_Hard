module  police ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
									  police_out,
                             frame_clk,          // The clock indicating a new frame (~60Hz)
					input [9:0]  death_X, death_Y,
					output[9:0]  police_X, police_Y,
					output logic police_back
              );

    parameter [9:0] police_X_Step=1;      // Step size on the X axis
    parameter [9:0] police_Y_Step=1;      // Step size on the Y axis

    logic [9:0] police_X_Pos, police_X_Motion, police_Y_Pos, police_Y_Motion;
    logic [9:0] police_X_Pos_in, police_X_Motion_in;
	 logic [9:0] police_Y_Pos_in, police_Y_Motion_in;
	 
	 assign police_X = police_X_Pos;
	 assign police_Y = police_Y_Pos;

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
            police_X_Pos <= 10'd320;
            police_Y_Pos <= 10'd450;
            police_X_Motion <= 10'd0;
            police_Y_Motion <= 10'd0;
        end
        else if (frame_clk_rising_edge)        // Update only at rising edge of frame clock
        begin
            police_X_Pos <= police_X_Pos_in;
            police_Y_Pos <= police_Y_Pos_in;
            police_X_Motion <= police_X_Motion_in;
            police_Y_Motion <= police_Y_Motion_in;
        end
        // By defualt, keep the register values.
    end

    //Start of the police_car FSM

	 enum logic [2:0] {Wait, start, collect, back} State, Next_state;

	 always_ff @ (posedge Clk)
	 begin: Assign_Next_State
			if(Reset)
				State <= Wait;
			else
				State <= Next_state;
	 end

	 always_comb
	 begin
			Next_state = State;

			unique case(State)
			Wait:
				if(police_out == 1'b1)
					Next_state = start;
				else
					Next_state = Wait;
			start:
				if(police_X_Pos == death_X && police_Y_Pos == death_Y)
					Next_state = collect;
				else
					Next_state = start;
			collect:
				if(police_X_Pos == 10'd320 && police_Y_Pos == 10'd450)
					Next_state = back;
				else
					Next_state = collect;
			back:
				Next_state = Wait;

			default:;
			endcase
	 end

	 always_comb
	 begin
			police_back = 1'b0;
			police_X_Motion_in = police_X_Motion;
			police_Y_Motion_in = police_Y_Motion;
			police_X_Pos_in = police_X_Pos + police_X_Motion;
			police_Y_Pos_in = police_Y_Pos + police_Y_Motion;
			case(State)
				Wait:
				begin
					police_X_Motion_in = 1'b0;
					police_Y_Motion_in = 1'b0;
					police_X_Pos_in = 12'd320;
					police_Y_Pos_in = 10'd450;
				end
				start:
				begin
					if(police_X_Pos < death_X)
						police_X_Motion_in = 1'b1;
					if(police_X_Pos > death_X)
						police_X_Motion_in = (~(police_X_Step) + 1'b1);
					if(police_X_Pos == death_X)
					begin
						police_X_Motion_in = 1'b0;
						police_X_Pos_in = police_X_Pos;
					end
					if(police_Y_Pos < death_Y)
						police_Y_Motion_in = 1'b1;
					if(police_Y_Pos > death_Y)
						police_Y_Motion_in = (~(police_Y_Step) + 1'b1);
					if(police_Y_Pos == death_Y)
					begin
						police_Y_Motion_in = 1'b0;
						police_Y_Pos_in = police_Y_Pos;
					end
				end
				collect:
				begin
					if(police_X_Pos < 10'd320)
						police_X_Motion_in = 1'b1;
					if(police_X_Pos > 10'd320)
						police_X_Motion_in = (~(police_X_Step) + 1'b1);
					if(police_X_Pos == 10'd320)
					begin
						police_X_Motion_in = 1'b0;
						police_X_Pos_in = police_X_Pos;
					end
					if(police_Y_Pos < 10'd450)
						police_Y_Motion_in = 1'b1;
					if(police_Y_Pos > 10'd450)
						police_Y_Motion_in = (~(police_Y_Step) + 1'b1);
					if(police_Y_Pos == 10'd450)
					begin
						police_Y_Motion_in = 1'b0;
						police_Y_Pos_in = police_Y_Pos;
					end
				end
				back:
				begin
					police_back = 1'b1;
				end
			endcase
		end



endmodule
