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


module  ball ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
					input [15:0]  keycode,
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
             // Whether current pixel belongs to ball or background
					output logic [9:0]ballX, ballY,
					output left_out, attack_out
              );

    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis
    parameter [9:0] Ball_X_Size=15;        // Ball size
	 parameter [9:0] Ball_Y_Size=28;

    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
	 logic left, left_in, attack, attack_in;


    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
    int Size_X, Size_Y;
    assign Size_X = Ball_X_Size;
	 assign Size_Y = Ball_Y_Size;
	 assign ballX = Ball_X_Pos;
	 assign ballY = Ball_Y_Pos;
	 assign left_out = left;
	 assign attack_out = attack;

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
        end
        else if (frame_clk_rising_edge)        // Update only at rising edge of frame clock
        begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
            Ball_X_Motion <= Ball_X_Motion_in;
            Ball_Y_Motion <= Ball_Y_Motion_in;
				left <= left_in;
				attack <= attack_in;
        end
        // By defualt, keep the register values.
    end

    // You need to modify always_comb block.
    always_comb
    begin
        // By default, keep motion unchanged
        Ball_X_Motion_in = 10'd0;
        Ball_Y_Motion_in = 10'd0;
		  left_in = left;
		  attack_in = 10'd0;


	    unique case(keycode[15:0])

				16'h001A: //w (up)
					begin
						Ball_X_Motion_in=0;
						Ball_Y_Motion_in=(~(Ball_Y_Step)+1'b1);
					end
				16'h0007: //d(right)
					begin
						Ball_Y_Motion_in=0;
						Ball_X_Motion_in=Ball_X_Step;
					

					end
				16'h0016: //s(down)
					begin
						Ball_X_Motion_in=0;
						Ball_Y_Motion_in=Ball_Y_Step;
					end
				16'h0004: //a(left)
					begin
						Ball_X_Motion_in=(~(Ball_X_Step)+1'b1);
						Ball_Y_Motion_in=0;
						
					end
				16'h0008: //e(attack)
					begin
						Ball_X_Motion_in = 0;
						Ball_Y_Motion_in = 0;
						attack_in = 1;
					end
		    
		   		 16'h071A: //w&d (up&right)
					begin
						Ball_X_Motion_in=Ball_X_Step;
						Ball_Y_Motion_in=(~(Ball_Y_Step)+1'b1);
					end
				16'h1A07: //w&d (up&right)
					begin
						Ball_Y_Motion_in=0;
						Ball_X_Motion_in=Ball_X_Step;
					end
		    
		    		16'h041A: //w&a (up& left)
			    		begin
						Ball_Y_Motion_in=(~(Ball_Y_Step)+1'b1);
						Ball_X_Motion_in=(~(Ball_X_Step)+1'b1);
					end
		    		16'h1A04: //w&a (up& left)
			    		begin
						Ball_Y_Motion_in=(~(Ball_Y_Step)+1'b1);
						Ball_X_Motion_in=(~(Ball_X_Step)+1'b1);
					end
		    		16'h0716: //s&d(down&right)
					begin
						Ball_X_Motion_in=Ball_X_Step;
						Ball_Y_Motion_in=Ball_Y_Step;
					end
		    
		    		16'h1607: //s&d(down&right)
					begin
						Ball_X_Motion_in=Ball_X_Step;
						Ball_Y_Motion_in=Ball_Y_Step;
					end
		    
		    		16'h0416: //s&d(down&left)
					begin
						Ball_X_Motion_in=(~(Ball_X_Step)+1'b1);
						Ball_Y_Motion_in=Ball_Y_Step;
					end
		    
			     	16'h1604: //s&d(down&left)
					begin
						Ball_X_Motion_in=(~(Ball_X_Step)+1'b1);
						Ball_Y_Motion_in=Ball_Y_Step;
					end
		    		
		    		
				default: ;
			endcase

        // Be careful when using comparators with "logic" datatype because compiler treats
        //   both sides of the operator UNSIGNED numbers. (unless with further type casting)
        // e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min
        // If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
        if( Ball_Y_Pos + Ball_Y_Size >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
				begin
				Ball_X_Motion_in = 0;
            Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);  // 2's complement.
				end
        else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Y_Size )  // Ball is at the top edge, BOUNCE!
				begin
				Ball_X_Motion_in = 0;
            Ball_Y_Motion_in = Ball_Y_Step;
				end

		  else if (Ball_X_Pos+Ball_X_Size>=Ball_X_Max)
				begin
				Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
				Ball_Y_Motion_in = 0;
				end
			else if (Ball_X_Pos <= Ball_X_Min + Ball_X_Size )
				begin
				Ball_X_Motion_in = Ball_X_Step;
				Ball_Y_Motion_in = 0;
				end

	    else if(Ball_X_Pos+14 == 184 && ((Ball_Y_Pos-21<=230 && Ball_Y_Pos-21>=66) || (Ball_Y_Pos+21<=230 && Ball_Y_Pos+21>=66)
			|| (Ball_Y_Pos<=230 && Ball_Y_Pos>=66)))
				begin
				Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
				Ball_Y_Motion_in = 0;
				end
	    else if(Ball_X_Pos-14 == 191 && ((Ball_Y_Pos-21<=230 && Ball_Y_Pos-21>=66) || (Ball_Y_Pos+21<=230 && Ball_Y_Pos+21>=66)
			|| (Ball_Y_Pos<=230 && Ball_Y_Pos>=66)))
				begin
				Ball_X_Motion_in = Ball_X_Step;
				Ball_Y_Motion_in = 0;
				end
	    else if (Ball_Y_Pos-21 == 230 && Ball_X_Pos-14<=191 && Ball_X_Pos+14>=184)
				begin
				Ball_X_Motion_in =0;
				Ball_Y_Motion_in =Ball_Y_Step;
				end
	    else if(Ball_Y_Pos+21 ==66 && Ball_X_Pos-14<=191 && Ball_X_Pos+14>=184)
				begin
				Ball_X_Motion_in = 0;
				Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
				end


	    else if(Ball_X_Pos+14 == 184 && ((Ball_Y_Pos-21<=72 && Ball_Y_Pos-21>=66) || (Ball_Y_Pos+21<=72 && Ball_Y_Pos+21>=66)
			|| (Ball_Y_Pos<=72 && Ball_Y_Pos>=66)))
				begin
				Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
				Ball_Y_Motion_in = 0;
				end
	    else if(Ball_X_Pos-14 == 540 && ((Ball_Y_Pos-21<=72 && Ball_Y_Pos-21>=66) || (Ball_Y_Pos+21<=72 && Ball_Y_Pos+21>=66)
			|| (Ball_Y_Pos<=72 && Ball_Y_Pos>=66)))
				begin
				Ball_X_Motion_in = Ball_X_Step;
				Ball_Y_Motion_in = 0;
				end
	    else if (Ball_Y_Pos-21 == 72 && Ball_X_Pos-14<=540 && Ball_X_Pos+14>=184)
				begin
				Ball_X_Motion_in =0;
				Ball_Y_Motion_in =Ball_Y_Step;
				end
	    else if(Ball_Y_Pos+21 ==66 && Ball_X_Pos-14<=540 && Ball_X_Pos+14>=184)
				begin
				Ball_X_Motion_in = 0;
				Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
				end


	    else if(Ball_X_Pos+14 == 412 && ((Ball_Y_Pos-21<=230 && Ball_Y_Pos-21>=66) || (Ball_Y_Pos+21<=230 && Ball_Y_Pos+21>=66)
			|| (Ball_Y_Pos<=230 && Ball_Y_Pos>=66)))
				begin
				Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
				Ball_Y_Motion_in = 0;
				end
	    else if(Ball_X_Pos-14 == 415 && ((Ball_Y_Pos-21<=230 && Ball_Y_Pos-21>=66) || (Ball_Y_Pos+21<=230 && Ball_Y_Pos+21>=66)
			|| (Ball_Y_Pos<=230 && Ball_Y_Pos>=66)))
				begin
				Ball_X_Motion_in = Ball_X_Step;
				Ball_Y_Motion_in = 0;
				end
	    else if (Ball_Y_Pos-21 == 230 && Ball_X_Pos-14<=415 && Ball_X_Pos+14>=412)
				begin
				Ball_X_Motion_in =0;
				Ball_Y_Motion_in =Ball_Y_Step;
				end
	    else if(Ball_Y_Pos+21 ==66 && Ball_X_Pos-14<=415 && Ball_X_Pos+14>=412)
				begin
				Ball_X_Motion_in = 0;
				Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
				end






	    else if(Ball_X_Pos+14 == 532 && ((Ball_Y_Pos-21<=286 && Ball_Y_Pos-21>=64) || (Ball_Y_Pos+21<=286 && Ball_Y_Pos+21>=64)
			|| (Ball_Y_Pos<=286 && Ball_Y_Pos>=66)))
				begin
				Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
				Ball_Y_Motion_in = 0;
				end
	    else if(Ball_X_Pos-14 == 540 && ((Ball_Y_Pos-21<=286 && Ball_Y_Pos-21>=64) || (Ball_Y_Pos+21<=286 && Ball_Y_Pos+21>=64)
			|| (Ball_Y_Pos<=286 && Ball_Y_Pos>=66)))
				begin
				Ball_X_Motion_in = Ball_X_Step;
				Ball_Y_Motion_in = 0;
				end
	    else if (Ball_Y_Pos-21 == 286 && Ball_X_Pos-14<=540 && Ball_X_Pos+14>=532)
				begin
				Ball_X_Motion_in =0;
				Ball_Y_Motion_in =Ball_Y_Step;
				end
	    else if(Ball_Y_Pos+21 ==66 && Ball_X_Pos-14<=540 && Ball_X_Pos+14>=532)
				begin
				Ball_X_Motion_in = 0;
				Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
				end


//


        else if(Ball_X_Pos+14 == 55 && ((Ball_Y_Pos-21<=108 && Ball_Y_Pos-21>=102) || (Ball_Y_Pos+21<=108 && Ball_Y_Pos+21>=102)
  			|| (Ball_Y_Pos<=108 && Ball_Y_Pos>=102)))
  				begin
  				Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
  				Ball_Y_Motion_in = 0;
  				end
  	    else if(Ball_X_Pos-14 == 186 && ((Ball_Y_Pos-21<=250 && Ball_Y_Pos-21>=66) || (Ball_Y_Pos+21<=108 && Ball_Y_Pos+21>=102)
  			|| (Ball_Y_Pos<=108 && Ball_Y_Pos>=102)))
  				begin
  				Ball_X_Motion_in = Ball_X_Step;
  				Ball_Y_Motion_in = 0;
  				end
  	    else if (Ball_Y_Pos-21 == 108 && Ball_X_Pos-14<=186 && Ball_X_Pos+14>=55)
  				begin
  				Ball_X_Motion_in =0;
  				Ball_Y_Motion_in =Ball_Y_Step;
  				end
  	    else if(Ball_Y_Pos+21 ==102 && Ball_X_Pos-14<=186 && Ball_X_Pos+14>=55)
  				begin
  				Ball_X_Motion_in = 0;
  				Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
  				end


//

          else if(Ball_X_Pos+14 == 55 && ((Ball_Y_Pos-21<=250 && Ball_Y_Pos-21>=102) || (Ball_Y_Pos+21<=250 && Ball_Y_Pos+21>=102)
    			|| (Ball_Y_Pos<=250 && Ball_Y_Pos>=102)))
    				begin
    				Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
    				Ball_Y_Motion_in = 0;
    				end
    	    else if(Ball_X_Pos-14 == 60 && ((Ball_Y_Pos-21<=250 && Ball_Y_Pos-21>=102) || (Ball_Y_Pos+21<=250 && Ball_Y_Pos+21>=66)
    			|| (Ball_Y_Pos<=250 && Ball_Y_Pos>=66)))
    				begin
    				Ball_X_Motion_in = Ball_X_Step;
    				Ball_Y_Motion_in = 0;
    				end
    	    else if (Ball_Y_Pos-21 == 250 && Ball_X_Pos-14<=60 && Ball_X_Pos+14>=55)
    				begin
    				Ball_X_Motion_in =0;
    				Ball_Y_Motion_in =Ball_Y_Step;
    				end
    	    else if(Ball_Y_Pos+21 ==102 && Ball_X_Pos-14<=60 && Ball_X_Pos+14>=55)
    				begin
    				Ball_X_Motion_in = 0;
    				Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
    				end

//
            else if(Ball_X_Pos+14 == 55 && ((Ball_Y_Pos-21<=175 && Ball_Y_Pos-21>=179) || (Ball_Y_Pos+21<=175 && Ball_Y_Pos+21>=175)
      			|| (Ball_Y_Pos<=179 && Ball_Y_Pos>=175)))
      				begin
      				Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
      				Ball_Y_Motion_in = 0;
      				end
      	    else if(Ball_X_Pos-14 == 100 && ((Ball_Y_Pos-21<=175 && Ball_Y_Pos-21>=179) || (Ball_Y_Pos+21<=175 && Ball_Y_Pos+21>=179)
      			|| (Ball_Y_Pos<=179 && Ball_Y_Pos>=175)))
      				begin
      				Ball_X_Motion_in = Ball_X_Step;
      				Ball_Y_Motion_in = 0;
      				end
      	    else if (Ball_Y_Pos-21 == 179 && Ball_X_Pos-14<=100 && Ball_X_Pos+14>=55)
      				begin
      				Ball_X_Motion_in =0;
      				Ball_Y_Motion_in =Ball_Y_Step;
      				end
      	    else if(Ball_Y_Pos+21 ==175 && Ball_X_Pos-14<=100 && Ball_X_Pos+14>=55)
      				begin
      				Ball_X_Motion_in = 0;
      				Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
      				end



//
              else if(Ball_X_Pos+14 == 140 && ((Ball_Y_Pos-21<=180 && Ball_Y_Pos-21>=102) || (Ball_Y_Pos+21<=180 && Ball_Y_Pos+21>=102)
              || (Ball_Y_Pos<=180 && Ball_Y_Pos>=102)))
                begin
                Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
                Ball_Y_Motion_in = 0;
                end
              else if(Ball_X_Pos-14 == 141 && ((Ball_Y_Pos-21<=180 && Ball_Y_Pos-21>=102) || (Ball_Y_Pos+21<=180 && Ball_Y_Pos+21>=102)
              || (Ball_Y_Pos<=180 && Ball_Y_Pos>=102)))
                begin
                Ball_X_Motion_in = Ball_X_Step;
                Ball_Y_Motion_in = 0;
                end
              else if (Ball_Y_Pos-21 == 180 && Ball_X_Pos-14<=141 && Ball_X_Pos+14>=140)
                begin
                Ball_X_Motion_in =0;
                Ball_Y_Motion_in =Ball_Y_Step;
                end
              else if(Ball_Y_Pos+21 ==102 && Ball_X_Pos-14<=141 && Ball_X_Pos+14>=140)
                begin
                Ball_X_Motion_in = 0;
                Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
                end



//
                else if(Ball_X_Pos+14 == 133 && ((Ball_Y_Pos-21<=179 && Ball_Y_Pos-21>=174) || (Ball_Y_Pos+21<=179 && Ball_Y_Pos+21>=174)
          			|| (Ball_Y_Pos<=179 && Ball_Y_Pos>=174)))
          				begin
          				Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
          				Ball_Y_Motion_in = 0;
          				end
          	    else if(Ball_X_Pos-14 == 146 && ((Ball_Y_Pos-21<=179 && Ball_Y_Pos-21>=174) || (Ball_Y_Pos+21<=179 && Ball_Y_Pos+21>=174)
          			|| (Ball_Y_Pos<=179 && Ball_Y_Pos>=174)))
          				begin
          				Ball_X_Motion_in = Ball_X_Step;
          				Ball_Y_Motion_in = 0;
          				end
          	    else if (Ball_Y_Pos-21 == 179 && Ball_X_Pos-14<=146 && Ball_X_Pos+14>=133)
          				begin
          				Ball_X_Motion_in =0;
          				Ball_Y_Motion_in =Ball_Y_Step;
          				end
          	    else if(Ball_Y_Pos+21 ==174 && Ball_X_Pos-14<=146 && Ball_X_Pos+14>=133)
          				begin
          				Ball_X_Motion_in = 0;
          				Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
          				end




//
                  else if(Ball_X_Pos+14 == 178 && ((Ball_Y_Pos-21<=179 && Ball_Y_Pos-21>=174) || (Ball_Y_Pos+21<=179 && Ball_Y_Pos+21>=174)
            			|| (Ball_Y_Pos<=179 && Ball_Y_Pos>=174)))
            				begin
            				Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
            				Ball_Y_Motion_in = 0;
            				end
            	    else if(Ball_X_Pos-14 == 192 && ((Ball_Y_Pos-21<=179 && Ball_Y_Pos-21>=174) || (Ball_Y_Pos+21<=179 && Ball_Y_Pos+21>=174)
            			|| (Ball_Y_Pos<=179 && Ball_Y_Pos>=174)))
            				begin
            				Ball_X_Motion_in = Ball_X_Step;
            				Ball_Y_Motion_in = 0;
            				end
            	    else if (Ball_Y_Pos-21 == 179 && Ball_X_Pos-14<=192 && Ball_X_Pos+14>=178)
            				begin
            				Ball_X_Motion_in =0;
            				Ball_Y_Motion_in =Ball_Y_Step;
            				end
            	    else if(Ball_Y_Pos+21 ==174 && Ball_X_Pos-14<=192 && Ball_X_Pos+14>=178)
            				begin
            				Ball_X_Motion_in = 0;
            				Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
            				end



//
                    else if(Ball_X_Pos+14 == 414 && ((Ball_Y_Pos-21<=194 && Ball_Y_Pos-21>=188) || (Ball_Y_Pos+21<=194 && Ball_Y_Pos+21>=188)
              			|| (Ball_Y_Pos<=194 && Ball_Y_Pos>=188)))
              				begin
              				Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
              				Ball_Y_Motion_in = 0;
              				end
              	    else if(Ball_X_Pos-14 == 432 && ((Ball_Y_Pos-21<=194 && Ball_Y_Pos-21>=188) || (Ball_Y_Pos+21<=194 && Ball_Y_Pos+21>=188)
              			|| (Ball_Y_Pos<=194 && Ball_Y_Pos>=188)))
              				begin
              				Ball_X_Motion_in = Ball_X_Step;
              				Ball_Y_Motion_in = 0;
              				end
              	    else if (Ball_Y_Pos-21 == 194 && Ball_X_Pos-14<=432 && Ball_X_Pos+14>=414)
              				begin
              				Ball_X_Motion_in =0;
              				Ball_Y_Motion_in =Ball_Y_Step;
              				end
              	    else if(Ball_Y_Pos+21 ==188 && Ball_X_Pos-14<=432 && Ball_X_Pos+14>=414)
              				begin
              				Ball_X_Motion_in = 0;
              				Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
              				end





//
                      else if(Ball_X_Pos+14 == 475 && ((Ball_Y_Pos-21<=194 && Ball_Y_Pos-21>=188) || (Ball_Y_Pos+21<=194 && Ball_Y_Pos+21>=188)
                      || (Ball_Y_Pos<=194 && Ball_Y_Pos>=188)))
                        begin
                        Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
                        Ball_Y_Motion_in = 0;
                        end
                      else if(Ball_X_Pos-14 == 540 && ((Ball_Y_Pos-21<=194 && Ball_Y_Pos-21>=188) || (Ball_Y_Pos+21<=194 && Ball_Y_Pos+21>=188)
                      || (Ball_Y_Pos<=194 && Ball_Y_Pos>=188)))
                        begin
                        Ball_X_Motion_in = Ball_X_Step;
                        Ball_Y_Motion_in = 0;
                        end
                      else if (Ball_Y_Pos-21 == 194 && Ball_X_Pos-14<=540 && Ball_X_Pos+14>=475)
                        begin
                        Ball_X_Motion_in =0;
                        Ball_Y_Motion_in =Ball_Y_Step;
                        end
                      else if(Ball_Y_Pos+21 ==188 && Ball_X_Pos-14<=540 && Ball_X_Pos+14>=475)
                        begin
                        Ball_X_Motion_in = 0;
                        Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
                        end


//
                        else if(Ball_X_Pos+14 == 475 && ((Ball_Y_Pos-21<=287 && Ball_Y_Pos-21>=280) || (Ball_Y_Pos+21<=287 && Ball_Y_Pos+21>=280)
                        || (Ball_Y_Pos<=287 && Ball_Y_Pos>=280)))
                          begin
                          Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
                          Ball_Y_Motion_in = 0;
                          end
                        else if(Ball_X_Pos-14 == 540 && ((Ball_Y_Pos-21<=287 && Ball_Y_Pos-21>=280) || (Ball_Y_Pos+21<=287 && Ball_Y_Pos+21>=280)
                        || (Ball_Y_Pos<=287 && Ball_Y_Pos>=280)))
                          begin
                          Ball_X_Motion_in = Ball_X_Step;
                          Ball_Y_Motion_in = 0;
                          end
                        else if (Ball_Y_Pos-21 == 287 && Ball_X_Pos-14<=540 && Ball_X_Pos+14>=475)
                          begin
                          Ball_X_Motion_in =0;
                          Ball_Y_Motion_in =Ball_Y_Step;
                          end
                        else if(Ball_Y_Pos+21 ==280 && Ball_X_Pos-14<=540 && Ball_X_Pos+14>=475)
                          begin
                          Ball_X_Motion_in = 0;
                          Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
                          end

//
                          else if(Ball_X_Pos+14 == 321 && ((Ball_Y_Pos-21<=287 && Ball_Y_Pos-21>=280) || (Ball_Y_Pos+21<=287 && Ball_Y_Pos+21>=280)
                          || (Ball_Y_Pos<=287 && Ball_Y_Pos>=280)))
                            begin
                            Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
                            Ball_Y_Motion_in = 0;
                            end
                          else if(Ball_X_Pos-14 == 428 && ((Ball_Y_Pos-21<=287 && Ball_Y_Pos-21>=280) || (Ball_Y_Pos+21<=287 && Ball_Y_Pos+21>=280)
                          || (Ball_Y_Pos<=287 && Ball_Y_Pos>=280)))
                            begin
                            Ball_X_Motion_in = Ball_X_Step;
                            Ball_Y_Motion_in = 0;
                            end
                          else if (Ball_Y_Pos-21 == 287 && Ball_X_Pos-14<=428 && Ball_X_Pos+14>=321)
                            begin
                            Ball_X_Motion_in =0;
                            Ball_Y_Motion_in =Ball_Y_Step;
                            end
                          else if(Ball_Y_Pos+21 ==280 && Ball_X_Pos-14<=428 && Ball_X_Pos+14>=321)
                            begin
                            Ball_X_Motion_in = 0;
                            Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
                            end

//
                            else if(Ball_X_Pos+14 == 185 && ((Ball_Y_Pos-21<=287 && Ball_Y_Pos-21>=280) || (Ball_Y_Pos+21<=287 && Ball_Y_Pos+21>=280)
                            || (Ball_Y_Pos<=287 && Ball_Y_Pos>=280)))
                              begin
                              Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
                              Ball_Y_Motion_in = 0;
                              end
                            else if(Ball_X_Pos-14 == 257 && ((Ball_Y_Pos-21<=287 && Ball_Y_Pos-21>=280) || (Ball_Y_Pos+21<=287 && Ball_Y_Pos+21>=280)
                            || (Ball_Y_Pos<=287 && Ball_Y_Pos>=280)))
                              begin
                              Ball_X_Motion_in = Ball_X_Step;
                              Ball_Y_Motion_in = 0;
                              end
                            else if (Ball_Y_Pos-21 == 287 && Ball_X_Pos-14<=257 && Ball_X_Pos+14>=185)
                              begin
                              Ball_X_Motion_in =0;
                              Ball_Y_Motion_in =Ball_Y_Step;
                              end
                            else if(Ball_Y_Pos+21 ==280 && Ball_X_Pos-14<=257 && Ball_X_Pos+14>=185)
                              begin
                              Ball_X_Motion_in = 0;
                              Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
                              end






//

                              else if(Ball_X_Pos+14 == 10 && ((Ball_Y_Pos-21<=287 && Ball_Y_Pos-21>=280) || (Ball_Y_Pos+21<=287 && Ball_Y_Pos+21>=280)
                              || (Ball_Y_Pos<=287 && Ball_Y_Pos>=280)))
                                begin
                                Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
                                Ball_Y_Motion_in = 0;
                                end
                              else if(Ball_X_Pos-14 == 60 && ((Ball_Y_Pos-21<=287 && Ball_Y_Pos-21>=280) || (Ball_Y_Pos+21<=287 && Ball_Y_Pos+21>=280)
                              || (Ball_Y_Pos<=287 && Ball_Y_Pos>=280)))
                                begin
                                Ball_X_Motion_in = Ball_X_Step;
                                Ball_Y_Motion_in = 0;
                                end
                              else if (Ball_Y_Pos-21 == 287 && Ball_X_Pos-14<=60 && Ball_X_Pos+14>=10)
                                begin
                                Ball_X_Motion_in =0;
                                Ball_Y_Motion_in =Ball_Y_Step;
                                end
                              else if(Ball_Y_Pos+21 ==280 && Ball_X_Pos-14<=60 && Ball_X_Pos+14>=10)
                                begin
                                Ball_X_Motion_in = 0;
                                Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
                                end





//
                                else if(Ball_X_Pos+14 == 15 && ((Ball_Y_Pos-21<=191 && Ball_Y_Pos-21>=183) || (Ball_Y_Pos+21<=191 && Ball_Y_Pos+21>=183)
                                || (Ball_Y_Pos<=191 && Ball_Y_Pos>=183)))
                                  begin
                                  Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
                                  Ball_Y_Motion_in = 0;
                                  end
                                else if(Ball_X_Pos-14 == 60 && ((Ball_Y_Pos-21<=191 && Ball_Y_Pos-21>=280) || (Ball_Y_Pos+21<=191 && Ball_Y_Pos+21>=280)
                                || (Ball_Y_Pos<=191 && Ball_Y_Pos>=183)))
                                  begin
                                  Ball_X_Motion_in = Ball_X_Step;
                                  Ball_Y_Motion_in = 0;
                                  end
                                else if (Ball_Y_Pos-21 == 191 && Ball_X_Pos-14<=60 && Ball_X_Pos+14>=15)
                                  begin
                                  Ball_X_Motion_in =0;
                                  Ball_Y_Motion_in =Ball_Y_Step;
                                  end
                                else if(Ball_Y_Pos+21 ==183 && Ball_X_Pos-14<=60 && Ball_X_Pos+14>=15)
                                  begin
                                  Ball_X_Motion_in = 0;
                                  Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
                                  end


//

                                else if(Ball_X_Pos+14 == 185 && ((Ball_Y_Pos-21<=350 && Ball_Y_Pos-21>=280) || (Ball_Y_Pos+21<=350 && Ball_Y_Pos+21>=280)
                                || (Ball_Y_Pos<=350 && Ball_Y_Pos>=280)))
                                begin
                                Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
                                Ball_Y_Motion_in = 0;
                                end
                                else if(Ball_X_Pos-14 == 191 && ((Ball_Y_Pos-21<=350 && Ball_Y_Pos-21>=280) || (Ball_Y_Pos+21<=350 && Ball_Y_Pos+21>=280)
                                || (Ball_Y_Pos<=350 && Ball_Y_Pos>=280)))
                                begin
                                Ball_X_Motion_in = Ball_X_Step;
                                Ball_Y_Motion_in = 0;
                                end
                                else if (Ball_Y_Pos-21 == 191 && Ball_X_Pos-14<=350 && Ball_X_Pos+14>=280)
                                begin
                                Ball_X_Motion_in =0;
                                Ball_Y_Motion_in =Ball_Y_Step;
                                end
                                else if(Ball_Y_Pos+21 ==183 && Ball_X_Pos-14<=350 && Ball_X_Pos+14>=280)
                                begin
                                Ball_X_Motion_in = 0;
                                Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
                                end

//

else if(Ball_X_Pos+14 == 75 && ((Ball_Y_Pos-21<=350 && Ball_Y_Pos-21>=345) || (Ball_Y_Pos+21<=350 && Ball_Y_Pos+21>=345)
|| (Ball_Y_Pos<=350 && Ball_Y_Pos>=345)))
begin
Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
Ball_Y_Motion_in = 0;
end
else if(Ball_X_Pos-14 == 170 && ((Ball_Y_Pos-21<=350 && Ball_Y_Pos-21>=345) || (Ball_Y_Pos+21<=350 && Ball_Y_Pos+21>=345)
|| (Ball_Y_Pos<=350 && Ball_Y_Pos>=345)))
begin
Ball_X_Motion_in = Ball_X_Step;
Ball_Y_Motion_in = 0;
end
else if (Ball_Y_Pos-21 == 350 && Ball_X_Pos-14<=170 && Ball_X_Pos+14>=75)
begin
Ball_X_Motion_in =0;
Ball_Y_Motion_in =Ball_Y_Step;
end
else if(Ball_Y_Pos+21 ==345 && Ball_X_Pos-14<=170 && Ball_X_Pos+14>=75)
begin
Ball_X_Motion_in = 0;
Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
end

//
else if(Ball_X_Pos+14 == 185 && ((Ball_Y_Pos-21<=336 && Ball_Y_Pos-21>=329) || (Ball_Y_Pos+21<=336 && Ball_Y_Pos+21>=329)
|| (Ball_Y_Pos<=336 && Ball_Y_Pos>=329)))
begin
Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
Ball_Y_Motion_in = 0;
end
else if(Ball_X_Pos-14 == 255 && ((Ball_Y_Pos-21<=336 && Ball_Y_Pos-21>=329) || (Ball_Y_Pos+21<=336 && Ball_Y_Pos+21>=329)
|| (Ball_Y_Pos<=350 && Ball_Y_Pos>=345)))
begin
Ball_X_Motion_in = Ball_X_Step;
Ball_Y_Motion_in = 0;
end
else if (Ball_Y_Pos-21 == 336 && Ball_X_Pos-14<=255 && Ball_X_Pos+14>=185)
begin
Ball_X_Motion_in =0;
Ball_Y_Motion_in =Ball_Y_Step;
end
else if(Ball_Y_Pos+21 ==329 && Ball_X_Pos-14<=255 && Ball_X_Pos+14>=185)
begin
Ball_X_Motion_in = 0;
Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
end


//
else if(Ball_X_Pos+14 == 385 && ((Ball_Y_Pos-21<=334 && Ball_Y_Pos-21>=280) || (Ball_Y_Pos+21<=334 && Ball_Y_Pos+21>=280)
|| (Ball_Y_Pos<=350 && Ball_Y_Pos>=345)))
begin
Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
Ball_Y_Motion_in = 0;
end
else if(Ball_X_Pos-14 == 391 && ((Ball_Y_Pos-21<=334 && Ball_Y_Pos-21>=280) || (Ball_Y_Pos+21<=334 && Ball_Y_Pos+21>=280)
|| (Ball_Y_Pos<=334 && Ball_Y_Pos>=280)))
begin
Ball_X_Motion_in = Ball_X_Step;
Ball_Y_Motion_in = 0;
end
else if (Ball_Y_Pos-21 == 334 && Ball_X_Pos-14<=391 && Ball_X_Pos+14>=385)
begin
Ball_X_Motion_in =0;
Ball_Y_Motion_in =Ball_Y_Step;
end
else if(Ball_Y_Pos+21 ==280 && Ball_X_Pos-14<=391 && Ball_X_Pos+14>=385)
begin
Ball_X_Motion_in = 0;
Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
end

//
else if(Ball_X_Pos+14 == 405 && ((Ball_Y_Pos-21<=350 && Ball_Y_Pos-21>=345) || (Ball_Y_Pos+21<=350 && Ball_Y_Pos+21>=345)
|| (Ball_Y_Pos<=350 && Ball_Y_Pos>=345)))
begin
Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
Ball_Y_Motion_in = 0;
end
else if(Ball_X_Pos-14 == 502 && ((Ball_Y_Pos-21<=350 && Ball_Y_Pos-21>=345) || (Ball_Y_Pos+21<=350 && Ball_Y_Pos+21>=345)
|| (Ball_Y_Pos<=350 && Ball_Y_Pos>=345)))
begin
Ball_X_Motion_in = Ball_X_Step;
Ball_Y_Motion_in = 0;
end
else if (Ball_Y_Pos-21 == 350 && Ball_X_Pos-14<=502 && Ball_X_Pos+14>=405)
begin
Ball_X_Motion_in =0;
Ball_Y_Motion_in =Ball_Y_Step;
end
else if(Ball_Y_Pos+21 ==345 && Ball_X_Pos-14<=502 && Ball_X_Pos+14>=405)
begin
Ball_X_Motion_in = 0;
Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
end

//
else if(Ball_X_Pos+14 == 325 && ((Ball_Y_Pos-21<=337 && Ball_Y_Pos-21>=332) || (Ball_Y_Pos+21<=337 && Ball_Y_Pos+21>=332)
|| (Ball_Y_Pos<=337 && Ball_Y_Pos>=332)))
begin
Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
Ball_Y_Motion_in = 0;
end
else if(Ball_X_Pos-14 == 390 && ((Ball_Y_Pos-21<=337 && Ball_Y_Pos-21>=332) || (Ball_Y_Pos+21<=337 && Ball_Y_Pos+21>=332)
|| (Ball_Y_Pos<=337 && Ball_Y_Pos>=332)))
begin
Ball_X_Motion_in = Ball_X_Step;
Ball_Y_Motion_in = 0;
end
else if (Ball_Y_Pos-21 == 337 && Ball_X_Pos-14<=390 && Ball_X_Pos+14>=325)
begin
Ball_X_Motion_in =0;
Ball_Y_Motion_in =Ball_Y_Step;
end
else if(Ball_Y_Pos+21 ==332 && Ball_X_Pos-14<=390 && Ball_X_Pos+14>=325)
begin
Ball_X_Motion_in = 0;
Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
end


//
else if(Ball_X_Pos+14 == 517 && ((Ball_Y_Pos-21<=350 && Ball_Y_Pos-21>=280) || (Ball_Y_Pos+21<=350 && Ball_Y_Pos+21>=280)
|| (Ball_Y_Pos<=350 && Ball_Y_Pos>=280)))
begin
Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
Ball_Y_Motion_in = 0;
end
else if(Ball_X_Pos-14 == 523 && ((Ball_Y_Pos-21<=350 && Ball_Y_Pos-21>=280) || (Ball_Y_Pos+21<=191 && Ball_Y_Pos+21>=280)
|| (Ball_Y_Pos<=350 && Ball_Y_Pos>=280)))
begin
Ball_X_Motion_in = Ball_X_Step;
Ball_Y_Motion_in = 0;
end
else if (Ball_Y_Pos-21 == 350 && Ball_X_Pos-14<=523 && Ball_X_Pos+14>=517)
begin
Ball_X_Motion_in =0;
Ball_Y_Motion_in =Ball_Y_Step;
end
else if(Ball_Y_Pos+21 ==280 && Ball_X_Pos-14<=523 && Ball_X_Pos+14>=517)
begin
Ball_X_Motion_in = 0;
Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
end

//
else if(Ball_X_Pos+14 == 186 && ((Ball_Y_Pos-21<=336 && Ball_Y_Pos-21>=330) || (Ball_Y_Pos+21<=336 && Ball_Y_Pos+21>=330)
|| (Ball_Y_Pos<=336 && Ball_Y_Pos>=330)))
begin
Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
Ball_Y_Motion_in = 0;
end
else if(Ball_X_Pos-14 == 255 && ((Ball_Y_Pos-21<=336 && Ball_Y_Pos-21>=330) || (Ball_Y_Pos+21<=336 && Ball_Y_Pos+21>=330)
|| (Ball_Y_Pos<=336 && Ball_Y_Pos>=330)))
begin
Ball_X_Motion_in = Ball_X_Step;
Ball_Y_Motion_in = 0;
end
else if (Ball_Y_Pos-21 == 336 && Ball_X_Pos-14<=255 && Ball_X_Pos+14>=186)
begin
Ball_X_Motion_in =0;
Ball_Y_Motion_in =Ball_Y_Step;
end
else if(Ball_Y_Pos+21 ==330 && Ball_X_Pos-14<=255 && Ball_X_Pos+14>=186)
begin
Ball_X_Motion_in = 0;
Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
end












        // TODO: Add other boundary conditions and handle keypress here.
		  // Update the ball's position with its motion
        Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
        Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;


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
