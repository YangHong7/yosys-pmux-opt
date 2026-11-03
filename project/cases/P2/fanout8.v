module top(input [7:0] a,b,c,d,z,q,input [4:0] s,output [7:0] y,output [7:0] tap);
wire [7:0] low=s[1]?b:(s[0]?a:(z));
assign y=s[3]?d:(s[2]?c:low);
assign tap=low;
endmodule
