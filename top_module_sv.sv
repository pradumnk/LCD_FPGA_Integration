module top_module_sv(
	input clk,
	input tft_sdo, output wire tft_sck, output wire tft_sdi, 
	output wire tft_dc, output wire tft_reset, output wire tft_cs,
	output wire[3:0] leds);
	
	wire tft_clk;
	wire clk_10khz;
	wire clk_120hz;
	
	pll pll_inst(clk, tft_clk);
	
	clkdiv #(.div(500), .bitSize(9)) clk10khz_generation (clk, clk_10khz);
	clkdiv #(.div(84), .bitSize(16)) clk_120hz_div(clk_10khz, clk_120hz);
	
	reg ledA = 1'b1;
	assign leds = ~{ledA, 1'b0, 1'b0, 1'b0};
	
	reg[16:0] framebufferIndex = 17'd0;
	wire fbClk;
	
	initial framebufferIndex = 17'd0;
	
	always @ (posedge fbClk) 
	begin
		framebufferIndex <= (framebufferIndex + 1'b1) % 17'(320*240);
	end
	
	wire[8:0] x = 9' (framebufferIndex / 240);
	wire[7:0] y = 8' (framebufferIndex % 240);
	
	wire b1;
	wire b2;
	wire b3;
	wire b4;
	ball_sv #(.X(240), .Y(200), .DX(3),  .DY(3), .RADIUS(48)) 	ball1(x, y, b1, clk_120hz);
	ball_sv #(.X(120), .Y(130), .DX(-4),  .DY(-4), .RADIUS(48))  ball2(x, y, b2, clk_120hz);
	ball_sv #(.X(150), .Y(210), .DX(2),  .DY(2), .RADIUS(48)) 	ball3(x, y, b3, clk_120hz);
	
	wire[15:0] currentPixel = (b1 ?      16'b1111110000000000 : 16'd0) |
									  (b2 ?      16'b1111110000000101 : 16'd0) |
									  (b3 ?      16'b0000011111100000 : 16'd0);
	
	tft_sv #(.INPUT_CLK_MHZ(100)) tft_inst(tft_clk, tft_sdo, tft_sck, tft_sdi, tft_dc, tft_reset, 
	tft_cs, currentPixel, fbClk);
	
endmodule
