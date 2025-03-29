module main
(
	input wire clk,           // FPGA system clock
   input wire rst_n,         // Active low reset
   input wire sclk,          // SPI clock from Arduino
   input wire cs_n,          // Chip select (active low)
   input wire mosi,           // Master out, slave in
	output VGA_HS,
	output VGA_VS,
	output [2:0] VGA_R,
	output [2:0] VGA_G,
	output [1:0] VGA_B,
	output [7:0] debug
);

parameter ADDR_WIDTH = 11;

wire miso;
wire [7:0] rx_data;
wire rx_valid;
wire vram_ready;
reg read_en;
wire [7:0] vram_out;
wire [(ADDR_WIDTH - 1) : 0] r_address;

spiSlave spiSlave_instance(.clk(clk), .rst_n(rst_n), .sclk(sclk), .cs_n(cs_n), .mosi(mosi), .miso(miso), .rx_data(rx_data), .rx_valid(rx_valid));
vram vram_instance(.clk(clk), .rx_valid(rx_valid), .data_in(rx_data), .ready_flag(vram_ready), .read_en(read_en), .data_out(vram_out), .rst_n(rst_n), .read_addr(r_address));
top_vga top_vga_instance(.CLOCK_50(clk), .RESET_n(rst_n), .DATA(vram_out), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .r_address(r_address));

assign debug = vram_out;

always @(posedge clk) begin
	if (!rst_n) 
		read_en <= 1'b0;
	
	// Start reading from vram
	if (vram_ready) begin
		read_en <= 1'b1;
	end
end

endmodule