module memory(CLK, ADDR , DIN , DOUT );

parameter wordSize = 1; 
parameter addressSize=1;

input ADDR, CLK;
input [wordSize-1:0] DIN;
output reg [wordSize-1:0] DOUT;
reg [wordSize:0] mem [0:(1<<addressSize)-1];

always @ (posedge CLK ) begin 
	mem[ADDR] <= DIN;
	DOUT <= mem[ADDR];
end

endmodule

