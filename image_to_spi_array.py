from PIL import Image

def image_to_spi_array(image_path):
    # Cargar y redimensionar la imagen a 40x30
    img = Image.open(image_path).resize((40, 30))
    
    # Procesar cada píxel a formato 3-3-2 bits
    spi_bytes = []
    for y in range(30):
        for x in range(40):
            r, g, b = img.getpixel((x, y))[:3]
            byte = ((r >> 5) << 5) | ((g >> 5) << 2) | (b >> 6)
            spi_bytes.append(byte)
    
    # Formatear como array C/C++
    c_array = "uint8_t image_data[1200] = {\n"
    for i in range(0, 1200, 30):  # 30 bytes por línea
        line = spi_bytes[i:i+30]
        c_array += "    " + ", ".join(f"0x{byte:02X}" for byte in line) + ",\n"
    c_array += "};"
    print(c_array)  # Imprimir el array C/C++
    
    return c_array
