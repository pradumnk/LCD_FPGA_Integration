
module tft(
		input clk,
		input tft_sdo, output wire tft_sck, output wire tft_sdi, 
		output wire tft_dc, output reg tft_reset, output wire tft_cs,
		input[15:0] framebufferData, output wire framebufferClk);
		
		parameter INPUT_CLK_MHZ = 100;
		parameter INIT_SEQ_LEN = 52;
		
		reg[8:0] spiData; 
		reg spiDataSet = 1'b0;
		wire spiIdle;
	
		reg frameBufferLowNibble = 1'b1;
		assign framebufferClk = !frameBufferLowNibble;
		
		spi spi_inst (clk, spiData, spiDataSet, tft_sck, tft_sdi, tft_dc, tft_cs, spiIdle);
		
		reg[5:0] initSeqCounter = 6'b0;
		integer remainingDelayTicks = 0;
		
		initial 			
			tft_reset = 1'b1;

		parameter START=0, HOLD_RESET=1, WAIT_FOR_POWERUP=2, SEND_INIT_SEQ=3, LOOP=4;
		reg [2:0] state = START;
		
		reg [8:0] INIT_SEQ [0:INIT_SEQ_LEN-1];
		initial
		begin
			INIT_SEQ[0]=9'd40;INIT_SEQ[1]=9'd207;INIT_SEQ[2]=9'd256;INIT_SEQ[3]=9'd387;
			INIT_SEQ[4]=9'd304;INIT_SEQ[5]=9'd237;INIT_SEQ[6]=9'd356;INIT_SEQ[7]=9'd259;
			INIT_SEQ[8]=9'd274;INIT_SEQ[9]=9'd385;INIT_SEQ[10]=9'd232;INIT_SEQ[11]=9'd389;
			INIT_SEQ[12]=9'd257;INIT_SEQ[13]=9'd377;INIT_SEQ[14]=9'd203;INIT_SEQ[15]=9'd313;
			INIT_SEQ[16]=9'd300;INIT_SEQ[17]=9'd256;INIT_SEQ[18]=9'd308;INIT_SEQ[19]=9'd258;
			INIT_SEQ[20]=9'd247;INIT_SEQ[21]=9'd288;INIT_SEQ[22]=9'd234;INIT_SEQ[23]=9'd256;
			INIT_SEQ[24]=9'd256;INIT_SEQ[25]=9'd192;INIT_SEQ[26]=9'd294;INIT_SEQ[27]=9'd193;
			INIT_SEQ[28]=9'd273;INIT_SEQ[29]=9'd197;INIT_SEQ[30]=9'd309;INIT_SEQ[31]=9'd318;
			INIT_SEQ[32]=9'd199;INIT_SEQ[33]=9'd446;INIT_SEQ[34]=9'd58;INIT_SEQ[35]=9'd341;
			INIT_SEQ[36]=9'd177;INIT_SEQ[37]=9'd256;INIT_SEQ[38]=9'd283;INIT_SEQ[39]=9'd38;
			INIT_SEQ[40]=9'd257;INIT_SEQ[41]=9'd81;INIT_SEQ[42]=9'd511;INIT_SEQ[43]=9'd183;
			INIT_SEQ[44]=9'd263;INIT_SEQ[45]=9'd182;INIT_SEQ[46]=9'd266;INIT_SEQ[47]=9'd386;
			INIT_SEQ[48]=9'd295;INIT_SEQ[49]=9'd256;INIT_SEQ[50]=9'd44;
		end
		
//		wire [8:0] q;
//		integer itr=0;
//		
//		rom_init_seq rom_inst (itr, clk, q);
//		
//		always @ (posedge clk)
//		begin 
//			INIT_SEQ[itr] = q;
//			if(itr<INIT_SEQ_LEN-1) itr = itr +1;
//		end
		
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
					remainingDelayTicks <= INPUT_CLK_MHZ * 1000; // min:= 1ms
					state <= HOLD_RESET;
					end
					
					HOLD_RESET: begin
					tft_reset <= 1'b1;
					remainingDelayTicks <= INPUT_CLK_MHZ * 120000; // min:= 120ms
					state <= WAIT_FOR_POWERUP;
					frameBufferLowNibble <= 1'b0;
					end
					
					WAIT_FOR_POWERUP: begin
					spiData <= {1'b0, 8'h11}; 
					spiDataSet <= 1'b1;
					remainingDelayTicks <= INPUT_CLK_MHZ * 5000; // min: 5ms
					state <= SEND_INIT_SEQ;
					frameBufferLowNibble <= 1'b1;
					end
					
					SEND_INIT_SEQ: 
					begin
						if (initSeqCounter < INIT_SEQ_LEN) 
						begin
							spiData <= INIT_SEQ[initSeqCounter];
							spiDataSet <= 1'b1;
							initSeqCounter <= initSeqCounter + 1'b1;
						end
					
						else 
						begin
							state <= LOOP;
							remainingDelayTicks <= INPUT_CLK_MHZ * 10000; // min: 10ms
						end
					end
					
					default: begin
					spiData <= !frameBufferLowNibble ? {1'b1, framebufferData[15:8]} :{1'b1, framebufferData[7:0]};
					spiDataSet <= 1'b1;
					frameBufferLowNibble <= !frameBufferLowNibble;
					end
					
				endcase
			end
		end
		
		
		
endmodule