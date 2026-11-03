module top(input [15:0] a,b,c,d,z,q,input [4:0] s,output [15:0] y);
wire [15:0] low=s[1]?b:(s[0]?a:('0));
assign y=s[3]?d:(s[2]?c:low);
endmodule
