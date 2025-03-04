module char_gen (
    input wire logic clk_pix,          // Reloj de píxeles
    input wire logic [9:0] sx,        // Posición horizontal en la pantalla
    input wire logic [9:0] sy,        // Posición vertical en la pantalla
    input wire logic [3:0] digit,     // Dígito a mostrar (0-9)
    input wire logic [9:0] char_x,    // Posición X del carácter en la pantalla
    input wire logic [9:0] char_y,    // Posición Y del carácter en la pantalla
    output logic pixel                // Salida: 1 si el píxel debe estar encendido
);

    // Memoria ROM para los caracteres (5x7 píxeles)
    logic [6:0] char_rom [0:9][0:6];  // 10 dígitos, 7 filas cada uno

    // Inicialización de la ROM con los caracteres (0-9)
    initial begin
        // Dígito 0
        char_rom[0] = '{7'b0111110, 7'b1000001, 7'b1000001, 7'b1000001, 7'b1000001, 7'b1000001, 7'b0111110};
        // Dígito 1
		  char_rom[1] = '{7'b0001000, 7'b0001100, 7'b0001000, 7'b0001000, 7'b0001000, 7'b0001000, 7'b0011100};
        // Dígito 2
		  char_rom[2] = '{7'b0111110, 7'b1000001, 7'b0100000, 7'b0010000, 7'b0001000, 7'b0000100, 7'b1111111};
		  // Digito 3
		  char_rom[3] = '{7'b1111110, 7'b0110000, 7'b0011000, 7'b0111110, 7'b1100000, 7'b1100011, 7'b0111110};
        // Dígito 4
		  char_rom[4] = '{7'b0111000, 7'b0111100, 7'b0110110, 7'b0110011, 7'b1111111, 7'b0110000, 7'b0110000};
        // Dígito 5
		  char_rom[5] = '{7'b0111111, 7'b0000011, 7'b0111111, 7'b1100000, 7'b1100000, 7'b1100011, 7'b0111110};
		  // Dígito 6
		  char_rom[6] = '{7'b0011100, 7'b0000110, 7'b0000011, 7'b0111111, 7'b1100011, 7'b1100011, 7'b0111110};
        // Digito 7
		  char_rom[7] = '{7'b1111111, 7'b1100011, 7'b0110000, 7'b0011000, 7'b0001100, 7'b0001100, 7'b0001100};
        // Dígito 8
		  char_rom[8] = '{7'b0011110, 7'b0100011, 7'b0100111, 7'b0011110, 7'b1111001, 7'b1100001, 7'b0111110};
        // Dígito 9
		  char_rom[9] = '{7'b0111110, 7'b1100011, 7'b1100011, 7'b1111110, 7'b1100000, 7'b0110000, 7'b0011110};
		 end

    // Lógica para determinar si el píxel actual debe estar encendido
    always_comb begin
        if (sx >= char_x && sx < char_x + 7 && sy >= char_y && sy < char_y + 7) begin
            pixel = char_rom[digit][sy - char_y][sx - char_x];
        end else begin
            pixel = 0;
        end
    end

endmodule