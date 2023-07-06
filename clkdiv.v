module clkdiv(input inClk, output reg outClk = 1'b0);
	parameter div = 4;
	parameter bitSize = 2**div;
	
	reg[1:bitSize] counter = 0;
	always @ (posedge inClk) begin
		if (counter >= div/2 - 1) begin
			counter <= 1'b0;
			outClk <= !outClk;
		end
		else
			counter <= counter + 1'b1;
	end
endmodule