module text_gen(
    input wire logic clk_pix,          // Reloj de píxeles
    input wire logic [9:0] sx,        // Posición horizontal en la pantalla
    input wire logic [9:0] sy,        // Posición vertical en la pantalla
    input wire logic [9:0] text_x,    // Posición X del texto en la pantalla
    input wire logic [9:0] text_y,    // Posición Y del texto en la pantalla
    output logic pixel                // Salida: 1 si el píxel debe estar encendido
);

    // Memoria ROM para los caracteres (5x7 píxeles)
    logic [6:0] char_rom [0:5][0:6];  // 128 caracteres, 7 filas cada uno

    // Inicialización de la ROM con los caracteres (A-Z, 0-9, y algunos símbolos)
    initial begin
		 // Letra 'P'
		 char_rom[0] = '{7'b0111000, 7'b1000100, 7'b1000100, 7'b0111100, 7'b0000100, 7'b0000100, 7'b0000100};
		 // Letra 'R'
		 char_rom[1] = '{7'b0111100, 7'b1000100, 7'b1000100, 7'b0111100, 7'b0010100, 7'b0100100, 7'b1000100};
		 // Letra 'E'
		 char_rom[2] = '{7'b1111100, 7'b0000100, 7'b0000100, 7'b0111100, 7'b0000100, 7'b0000100, 7'b1111100};
       // Letra 'S'
		 char_rom[3] = '{7'b0111100, 7'b0000100, 7'b0000100, 7'b0111000, 7'b1000000, 7'b1000000, 7'b0111100};
       // Letra 'T'
       char_rom[4] = '{7'b1111100, 7'b0010000, 7'b0010000, 7'b0010000, 7'b0010000, 7'b0010000, 7'b0010000};
       // Letra 'A'
       char_rom[5] = '{7'b0010000, 7'b0101000, 7'b1000100, 7'b1111100, 7'b1000100, 7'b1000100, 7'b1000100};
    end

    // Lógica para mostrar el texto "PRESS START"
    always_comb begin
        if (sx >= text_x && sx < text_x + 70 && sy >= text_y && sy < text_y + 7) begin
			case ((sx - text_x)/7)
						0: pixel = char_rom[0][sy - text_y][((sx - text_x) % 7)];
                  1: pixel = char_rom[1][sy - text_y][(sx - text_x - 7) % 7];
						2: pixel = char_rom[2][sy - text_y][(sx - text_x - 14) % 7];
						3: pixel = char_rom[3][sy - text_y][(sx - text_x - 21) %7];
						4: pixel = char_rom[3][sy - text_y][(sx - text_x - 28)%7];
						5: pixel = char_rom[3][sy - text_y][(sx - text_x - 35)%7];
						6: pixel = char_rom[4][sy - text_y][(sx - text_x - 42)%7];
						7: pixel = char_rom[5][sy - text_y][(sx - text_x - 49)%7];
						8: pixel = char_rom[1][sy - text_y][(sx - text_x - 56)%7];
						9: pixel = char_rom[4][sy - text_y][(sx - text_x - 63)%7];
                default: pixel=0;
				endcase 
//			end if (sx >= text_x && sx < text_x +7 && sy >= text_y && sy < text_y + 6) begin
//				pixel = char_rom[1][sy - text_y][sx - text_x-7];
        end else begin
            pixel = 0;
        end
    end
	 
//	 always_comb begin
//        if (sx >= char_x && sx < char_x + 7 && sy >= char_y && sy < char_y + 7) begin
//            pixel = char_rom[digit][sy - char_y][sx - char_x];
//        end else begin
//            pixel = 0;
//        end
//    end

endmodule 