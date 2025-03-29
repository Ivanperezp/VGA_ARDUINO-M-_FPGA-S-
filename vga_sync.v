module vga_sync (
    input  wire       clk_25MHz,    // Reloj 25 MHz
    input  wire       reset,        // Reset asíncrono (alto = reset)
    output reg        hsync,
    output reg        vsync,
    output wire       video_enable, // 1 = zona visible, 0 = zona de retrazo
    output reg [9:0]  hcount,       // Contador horizontal (0..799)
    output reg [9:0]  vcount        // Contador vertical   (0..524)
);

// Parámetros de 640x480@60Hz (simplificados)
localparam H_VISIBLE_AREA = 640;
localparam H_FRONT_PORCH  = 16; //16
localparam H_SYNC_PULSE   = 96; //96
localparam H_BACK_PORCH   = 48; //48
localparam H_TOTAL        = H_VISIBLE_AREA + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH; // 800

localparam V_VISIBLE_AREA = 480;
localparam V_FRONT_PORCH  = 10;
localparam V_SYNC_PULSE   = 2;
localparam V_BACK_PORCH   = 33;
localparam V_TOTAL        = V_VISIBLE_AREA + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH; // 525

// Contadores horizontal y vertical
always @(posedge clk_25MHz or posedge reset) begin
    if (reset) begin
        hcount <= 0;
        vcount <= 0;
    end else begin
        if (hcount == H_TOTAL - 1) begin
            hcount <= 0;
            // Incrementa vcount al terminar la línea
            if (vcount == V_TOTAL - 1)
                vcount <= 0;
            else
                vcount <= vcount + 1;
        end else begin
            hcount <= hcount + 1;
        end
    end
end

// hsync (activo en bajo durante H_SYNC_PULSE)
always @* begin
    // rangos de pulso horizontal
    if (hcount >= (H_VISIBLE_AREA + H_FRONT_PORCH) &&
        hcount <  (H_VISIBLE_AREA + H_FRONT_PORCH + H_SYNC_PULSE))
        hsync = 0;
    else
        hsync = 1;
end

// vsync (activo en bajo durante V_SYNC_PULSE)
always @* begin
    if (vcount >= (V_VISIBLE_AREA + V_FRONT_PORCH) &&
        vcount <  (V_VISIBLE_AREA + V_FRONT_PORCH + V_SYNC_PULSE))
        vsync = 0;
    else
        vsync = 1;
end

// Zona visible: hcount < 640 y vcount < 480
assign video_enable = (hcount < H_VISIBLE_AREA) && (vcount < V_VISIBLE_AREA);

endmodule