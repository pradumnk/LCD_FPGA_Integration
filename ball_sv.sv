module ball_sv(input[8:0] checkX, input[7:0] checkY, output wire isSet, input wire physicsClk);
    parameter X = 240;
	parameter Y = 200;
	parameter DX = 3;
	parameter DY = 3;
	parameter RADIUS = 32;
	
	localparam MIN_Y = (0 + RADIUS/6) << 6;
	localparam MAX_Y = (240 - RADIUS/6) << 6;
	localparam MIN_X = (0 + RADIUS/6) << 6;
	localparam MAX_X = (320 - RADIUS/6) << 6;	
	
	reg signed [15:0] x = 16'(X) <<< 6;
	reg signed [15:0] y = 16'(Y) <<< 6;
	reg signed [15:0] dx = 10'(DX) <<< 4;
	reg signed [15:0] dy = 10'(DY) <<< 4;
	
	// Logic
	wire signed [15:0] newX = x + dx;
	wire signed [15:0] newY = y - dy;
	
	always @ (posedge physicsClk) begin
		if (newY < MIN_Y || newY > MAX_Y) dy <= -dy;
		else begin
			y <= newY;
		end
		
		if (newX < MIN_X || newX > MAX_X) dx <= -dx;
		else x <= newX;
	end

	// Rendering
	wire[15:0] pixelX = (x >>> 6);
	wire[15:0] pixelY = (y >>> 6);
	wire[15:0] signedCheckX = checkX;
	wire[15:0] signedCheckY = checkY;
	wire[31:0] squaredDist = (pixelX - signedCheckX) * (pixelX - signedCheckX) 
								  + (pixelY - signedCheckY) * (pixelY - signedCheckY);
	assign isSet = squaredDist <= RADIUS;
endmodule