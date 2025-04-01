from PIL import Image

def image_to_spi_array(image_path):
    # Cargar y redimensionar la imagen a 40x30
    width, height = 40, 30
    img = Image.open(image_path).resize((width, height))
    
    # Procesar cada píxel a formato 3-3-2 bits
    spi_bytes = []
    rgb_reconstructed = []
    
    for y in range(height):
        for x in range(width):
            r, g, b = img.getpixel((x, y))[:3]
            byte = ((r >> 5) << 5) | ((g >> 5) << 2) | (b >> 6)
            spi_bytes.append(byte)
            
            # Reconstruir RGB para visualización
            r_recon = (byte >> 5) & 0x07
            g_recon = (byte >> 2) & 0x07
            b_recon = byte & 0x03
            
            # Escalar a 8 bits
            rgb_reconstructed.append((
                (r_recon * 255) // 7,
                (g_recon * 255) // 7,
                (b_recon * 255) // 3
            ))
    
    # Formatear como array C/C++
    c_array = "uint8_t image_data[1200] = {\n"
    for i in range(0, 1200, height):  # 30 bytes por línea
        line = spi_bytes[i:i+height]
        c_array += "    " + ", ".join(f"0x{byte:02X}" for byte in line) + ",\n"
    c_array += "};"
    print(c_array)  # Imprimir el array C/C++
    
    return 0
