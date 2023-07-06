module tft_sv(
		input clk,
		input tft_sdo, output wire tft_sck, output wire tft_sdi, 
		output wire tft_dc, output reg tft_reset, output wire tft_cs,
		input[15:0] framebufferData, output wire framebufferClk);
		
		parameter INPUT_CLK_MHZ = 100;
		
		reg[8:0] spiData; 
		reg spiDataSet = 1'b0;
		wire spiIdle;
	
		reg frameBufferLowNibble = 1'b1;
		assign framebufferClk = !frameBufferLowNibble;
		
		initial 
		tft_reset = 1'b1;
		
		spi spi_inst (clk, spiData, spiDataSet, tft_sck, tft_sdi, tft_dc, tft_cs, spiIdle);
		
		parameter INIT_SEQ_LEN = 52;
		
		reg[5:0] initSeqCounter = 6'b0;
		
		reg[8:0] INIT_SEQ [0:INIT_SEQ_LEN-1] = '{
		// Turn off Display
		{1'b0, 8'h28},
		// Init (??)
		{1'b0, 8'hCF}, {1'b1, 8'h00}, {1'b1, 8'h83}, {1'b1, 8'h30}, 
		{1'b0, 8'hED}, {1'b1, 8'h64}, {1'b1, 8'h03}, {1'b1, 8'h12}, {1'b1, 8'h81},
		{1'b0, 8'hE8}, {1'b1, 8'h85}, {1'b1, 8'h01}, {1'b1, 8'h79}, 
		{1'b0, 8'hCB}, {1'b1, 8'h39}, {1'b1, 8'h2C}, {1'b1, 8'h00}, {1'b1, 8'h34}, {1'b1, 8'h02},
		{1'b0, 8'hF7}, {1'b1, 8'h20},
		{1'b0, 8'hEA}, {1'b1, 8'h00}, {1'b1, 8'h00},
		// Power Control
		{1'b0, 8'hC0}, {1'b1, 8'h26},
		{1'b0, 8'hC1}, {1'b1, 8'h11},
		// VCOM
		{1'b0, 8'hC5}, {1'b1, 8'h35}, {1'b1, 8'h3E},
		{1'b0, 8'hC7}, {1'b1, 8'hBE},
		// Memory Access Control
		{1'b0, 8'h3A}, {1'b1, 8'h55},
		// Frame Rate
		{1'b0, 8'hB1}, {1'b1, 8'h00}, {1'b1, 8'h1B},
		// Gamma
		{1'b0, 8'h26}, {1'b1, 8'h01},
		// Brightness
		{1'b0, 8'h51}, {1'b1, 8'hFF},
		// Display
		{1'b0, 8'hB7}, {1'b1, 8'h07},
		{1'b0, 8'hB6}, {1'b1, 8'h0A}, {1'b1, 8'h82}, {1'b1, 8'h27}, {1'b1, 8'h00},
		{1'b0, 8'h29}, // Enable Display
		{1'b0, 8'h2C} // Start  Memory-Write
	};
		
		reg[23:0] remainingDelayTicks = 24'b0;
		enum logic[2:0] { START, HOLD_RESET, WAIT_FOR_POWERUP, SEND_INIT_SEQ, LOOP} state = START;
		
		always @ (posedge clk)
		begin
			spiDataSet <= 1'b0;
			if (remainingDelayTicks > 0) 
			begin
				remainingDelayTicks <= remainingDelayTicks - 1'b1;
			end
			
			else if (spiIdle && !spiDataSet)
			begin
				case (state)
					START: 
					begin
					tft_reset <= 1'b0;
					remainingDelayTicks <= 24'(INPUT_CLK_MHZ * 10); // min: 10us
					state <= HOLD_RESET;
					end
				
					HOLD_RESET: begin
					tft_reset <= 1'b1;
					remainingDelayTicks <= 24'(INPUT_CLK_MHZ * 120000); // min: 120ms
					state <= WAIT_FOR_POWERUP;
					frameBufferLowNibble <= 1'b0;
					end
				
					WAIT_FOR_POWERUP: begin
					spiData <= {1'b0, 8'h11}; 
					spiDataSet <= 1'b1;
					remainingDelayTicks <= 24'(INPUT_CLK_MHZ * 5000); // min: 5ms
					state <= SEND_INIT_SEQ;
					frameBufferLowNibble <= 1'b1;
					end
				
					SEND_INIT_SEQ: begin
					if (initSeqCounter < INIT_SEQ_LEN) begin
						spiData <= INIT_SEQ[initSeqCounter];
						spiDataSet <= 1'b1;
						initSeqCounter <= initSeqCounter + 1'b1;
					end
					
					else begin
						state <= LOOP;
						remainingDelayTicks <= 24'(INPUT_CLK_MHZ * 10000); // min: 10ms
					end
					end
					
					default: begin
					spiData <= !frameBufferLowNibble ? {1'b1, framebufferData[15:8]} :
					{1'b1, framebufferData[7:0]};
					spiDataSet <= 1'b1;
					frameBufferLowNibble <= !frameBufferLowNibble;
					end
				endcase
				
			end
		end
		
endmodule