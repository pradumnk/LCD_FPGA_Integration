`timescale 10ns/1ns
module tb_top_module();

reg clk=0;
wire tft_sdo, tft_sck, tft_sdi, tft_dc, tft_reset, tft_cs;
wire [3:0] leds;

top_module_sv dut (clk, tft_sdo, tft_sck, tft_sdi, tft_dc, tft_reset, tft_cs, leds);

initial
begin
	forever #1 clk <= ~clk;
end

endmodule