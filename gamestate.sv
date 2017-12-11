module gamestate(input Reset, Clk, gameover_caught, scoring_A, scoring_B, scoring_C,
						input [7:0] key,
					  output ready,
					  output lost,
					  output [10:0] totalscore,
					  output [3:0] hextotal,hextotal2,
					  output logic game_start);
					  
enum logic [3:0] {Start, Playing, Game_Over, set_game}   State, Next_state;   // Internal state logic
logic lost_game;
logic [10:0] score_total;
logic [10:0] score_total_in;
logic [3:0] hex_score, hex_score2;
logic score_added_A, score_added_B, score_added_C;
logic score_added_A_in, score_added_B_in, score_added_C_in;


  always_ff @ (posedge Reset or posedge Clk  )
    begin : Assign_Next_State
        if (Reset) 
		  begin
            State <= Start;
				score_total <= 0;
				score_added_A <= 1;
				score_added_B <= 1;
				score_added_C <= 1;
		  end
        else 
		  begin
				score_total <= score_total_in;
				score_added_A <= score_added_A_in;
				score_added_B <= score_added_B_in;
				score_added_C <= score_added_C_in;
            State <= Next_state;
		  end
    end	


//NEXT STAte
	always_comb
    begin 
	    Next_state  = State;

	 
        unique case (State)
            Start : 
              if (key == 8'h28)//press enter to play
						Next_state = set_game;
				set_game:
					Next_state = Playing;
            Playing : 
              if(gameover_caught || score_total == 3)
						Next_state = Game_Over;
						
				Game_Over: 
                  if(key==8'h28)//press enter to restart
                    	Next_state<=Start;
          			else
                      	Next_state=Game_Over;
     
            
			default : ;

	     endcase
    end	
	

	always_ff @ (posedge Reset or posedge Clk)
    begin 

		ready = 0;
		hex_score = hex_score;
		score_total_in = score_total;
		score_added_B_in = score_added_B;
		score_added_A_in = score_added_A;
		score_added_C_in = score_added_C;
		lost_game=0;
		game_start = 0;
		 
	    case (State)
			Start : 
				begin 
					score_total_in = 0;
					score_added_A_in = 1;
					score_added_B_in = 1;
					score_added_C_in = 1;
					hex_score = 0;
					hex_score2 = 0;
					ready = 0;
					game_start = 1;
				end
			set_game:
				begin
					ready = 1;
				end
			Playing : 
				begin
				
				if(scoring_A && score_added_A)
				begin
					score_total_in++;
					hex_score= hex_score + 1;
					hex_score2= hex_score2;
					score_added_A_in = 0;
				end
				
				if(scoring_B && score_added_B)
				begin
					score_total_in++;
					hex_score= hex_score + 1;
					hex_score2= hex_score2;
					score_added_B_in = 0;
				end
				
				if(scoring_C && score_added_C)
				begin
					score_total_in++;
					hex_score= hex_score + 1;
					hex_score2= hex_score2;
					score_added_C_in = 0;
				end
				
				
				/*if(hex_score >= 'd10)
					begin
						hex_score = 0;
						hex_score2 = hex_score2 + 1;
					
					end*/
				
				
				lost_game=0;
				end
			Game_Over : 
				begin 
	
					ready = 0;
					hex_score = hex_score;
					hex_score2= hex_score2;
					lost_game=1;
         end
        
          default : ;
           
			  
		endcase
		
	
       
	end 	

		assign totalscore = score_total;
		assign hextotal = hex_score;
		assign hextotal2 = hex_score2;
		assign lost= lost_game;
	
endmodule
