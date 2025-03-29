module top_vga (
    input  wire        CLOCK_50,  // Reloj de 50 MHz de la DE0-CV
    input  wire        RESET_n,   // Botón / Reset activo en bajo
    output wire        VGA_HS,    // Hsync hacia el monitor
    output wire        VGA_VS,    // Vsync hacia el monitor
    output wire [2:0]  VGA_R,     // 3 bits de rojo
    output wire [2:0]  VGA_G,     // 3 bits de verde
    output wire [1:0]  VGA_B,      // 3 bits de azul
	 output reg [(ADDR_WIDTH - 1) :0] r_address,
	 input [7:0] DATA
);

parameter ADDR_WIDTH = 11;
parameter DIVISION = 16;

//---------------------------------------------------------------------
// 1) Señales internas para el PLL y la lógica VGA
//---------------------------------------------------------------------
wire clk_25MHz;    // Reloj generado por el PLL a 25 MHz
wire locked_pll;   // Indica que el PLL está estabilizado

//---------------------------------------------------------------------
// 2) Instancia del PLL (código generado por el IP de Quartus)
//    Archivo llamado "prueba_0002.v"
//    nombre de módulo "prueba_0002"
//---------------------------------------------------------------------
pll pll_inst (
    .refclk   (CLOCK_50),     // Conecta el reloj de 50 MHz
    .rst      (~RESET_n),     // Reset activo en bajo => invertimos
    .outclk_0 (clk_25MHz),    // Salida de 25 MHz
    .locked   (locked_pll)
);

//---------------------------------------------------------------------
// 3) Señales para la sincronía VGA
//---------------------------------------------------------------------
wire hsync_sig, vsync_sig;
wire video_enable;
wire [9:0] hcount, vcount;

//---------------------------------------------------------------------
// 4) Instanciamos un módulo de sincronización VGA
//---------------------------------------------------------------------
vga_sync sync_unit (
    .clk_25MHz    (clk_25MHz),
    .reset        (~RESET_n),   // Se puede usar (!locked_pll) para mayor control -> .reset (~RESET_n | ~locked_pll)
    .hsync        (hsync_sig),
    .vsync        (vsync_sig),
    .video_enable (video_enable),
    .hcount       (hcount),
    .vcount       (vcount)
);

// Enlazamos las señales hsync y vsync a las salidas top-level
assign VGA_HS = hsync_sig;
assign VGA_VS = vsync_sig;

//---------------------------------------------------------------------
// 5) Lógica de generación de color
//---------------------------------------------------------------------
reg [2:0] color_r;
reg [2:0] color_g;
reg [2:0] color_b;

always @(posedge clk_25MHz) begin
    // Mientras el PLL no esté bloqueado, podríamos forzar negro
    if (!locked_pll) begin
        color_r <= 3'b000;
        color_g <= 3'b000;
        color_b <= 3'b000;
    end
    // Si estamos fuera de la zona visible, pintamos negro
    else if (!video_enable) begin
        color_r <= 3'b000;
        color_g <= 3'b000;
        color_b <= 3'b000;
    end
    // En la zona visible, generamos un patrón sencillo. Ej: mitad rojo / mitad azul
    else begin
		r_address <= (hcount / DIVISION) + (vcount / DIVISION) * (640 / DIVISION);
		
		color_r <= DATA[7:5];
		color_g <= DATA[4:2];
		color_b <= DATA[1:0];
	 end
end

// Asignamos las salidas
assign VGA_R = color_r;
assign VGA_G = color_g;
assign VGA_B = color_b;

endmodule

