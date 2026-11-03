module top(input [3:0] a,b,c,d,z,q,input [4:0] s,output [3:0] y);
wire [3:0] low=s[1]?b:(s[0]?a:(z));
assign y=s[3]?d:(s[2]?c:low);
endmodule
