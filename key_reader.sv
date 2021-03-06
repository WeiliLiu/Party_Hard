module keycode_reader(
input logic[31:0] keycode,
output logic w_on, a_on, s_on, d_on,e_on,space_on,up_on,down_on,right_on,left_on
)
; 
 
assign w_on = (keycode[31:24] == 8'h1A |
               keycode[23:16] == 8'h1A |
               keycode[15: 8] == 8'h1A |
               keycode[ 7: 0] == 8'h1A); 
 
assign a_on = (keycode[31:24] == 8'h04 |
               keycode[23:16] == 8'h04 |
               keycode[15: 8] == 8'h04 |
               keycode[ 7: 0] == 8'h04); 
               
assign s_on = (keycode[31:24] == 8'h16 |
               keycode[23:16] == 8'h16 |
               keycode[15: 8] == 8'h16 |
               keycode[ 7: 0] == 8'h16); 
               
assign d_on = (keycode[31:24] == 8'h07 |
               keycode[23:16] == 8'h07 |
               keycode[15: 8] == 8'h07 |
               keycode[ 7: 0] == 8'h07); 
 assign e_on = (keycode[31:24] == 8'h1A |
               keycode[23:16] == 8'h1A |
               keycode[15: 8] == 8'h1A |
               keycode[ 7: 0] == 8'h1A);
 assign up_on = (keycode[31:24] == 8'h1A |
               keycode[23:16] == 8'h1A |
               keycode[15: 8] == 8'h1A |
               keycode[ 7: 0] == 8'h1A);
 assign left_on = (keycode[31:24] == 8'h1A |
               keycode[23:16] == 8'h1A |
               keycode[15: 8] == 8'h1A |
               keycode[ 7: 0] == 8'h1A);
 assign right_on = (keycode[31:24] == 8'h1A |
               keycode[23:16] == 8'h1A |
               keycode[15: 8] == 8'h1A |
               keycode[ 7: 0] == 8'h1A);
 assign down_on = (keycode[31:24] == 8'h1A |
               keycode[23:16] == 8'h1A |
               keycode[15: 8] == 8'h1A |
               keycode[ 7: 0] == 8'h1A);
  assign space_on = (keycode[31:24] == 8'h1A |
               keycode[23:16] == 8'h1A |
               keycode[15: 8] == 8'h1A |
               keycode[ 7: 0] == 8'h1A);
               
               
endmodule
