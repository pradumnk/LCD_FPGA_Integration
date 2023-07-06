module spi(
input spiClk, input[8:0] data, input dataAvailable,
output wire tft_sck, output reg tft_sdi, output reg tft_dc, output wire tft_cs,
output reg idle);

		reg internalSck, cs;
		reg[0:2] counter = 3'b0;
		reg[8:0] internalData;
		wire dataDc = internalData[8];
		wire[0:7] dataShift = internalData[7:0];
		
		assign tft_sck = internalSck & cs;
		assign tft_cs = !cs;
		
		initial
		begin
			internalSck <= 1'b1;
			idle <= 1'b1;
			cs <= 1'b0;
		end

		always @ (posedge spiClk) 
		begin
			if (dataAvailable) 
			begin
				internalData <= data;
				idle <= 1'b0;
			end
			
			if (!idle)
			begin
				internalSck <= !internalSck;
				if (internalSck) 
				begin
					tft_dc <= dataDc;
					tft_sdi <= dataShift[counter];
					cs <= 1'b1;
					counter <= counter + 1'b1;
					idle <= &counter;
				end
				
			end
			
			else
			begin
				internalSck <= 1'b1;
				if (internalSck) 
					cs <= 1'b0;
			end
			
		end
		
endmodule