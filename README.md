[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=17798990&assignment_repo_type=AssignmentRepo)
# Entrega Final del Proyecto Pong

Proyecto Electrónica Digital 2024-2 Grupo 3

Juan Esteban Otavo García


# Planteamiento del Problema

Se propuso implementar en la FPGA el clásico videojuego Pong. El video juego consiste en dos jugadores que se enfrentan entre sí, moviendo una paleta cada uno y evitando que la pelota caiga en su lado. El prototipo será creado usando una FPGA Cyclone V, una pantalla usando protocolo VGA, dos botones por jugador para el control de las paletas y dos botones extra para control de la partida y refrescar la pantalla en caso de bugs visuales.

Para realizar esta implementación se requería de realizar un dispositivo que permitiera jugar a dos jugadores entre sí, llevar un sistema de conteo, cambiar las condiciones de juego a lo largo de la partida y reiniciar el juego con la pulsación de un botón. Por la naturaleza del proyecto fue necesario estudiar principalmente máquinas de estado, ya que el funcionamiento principal de este juego requiere cambiar entre varios estados.
 
## Requisitos funcionales

* Sistema de control de paletas para dos jugadores
* Sistema de conteo de puntuación
* Control de reinicio

# Análisis de diseño

## Selección de pantalla

Al principio, se tenía pensado trabajar con una pantalla LCD ILI9341, pero por temas de fácilidad a la hora de encontrar información en línea se optó por trabajar con protocolo VGA.

## Inicio/reinicio: 
El juego debe permitir que el jugador decida en que momento se da el inicio y el reinicio, por lo que se va a programar mediante un botón.


## Operación: 
El control del jugador se limita a definir la posición de la paleta en el eje Y usando dos botones. 


## Comportamiento independiente: 
Cada vez que el juego se reinicie la pelota será colocada en el centro de la pantalla, posteriormente será disparada con un ángulo variable (reflejo) y una velocidad predeterminada, la pelota rebotara en los bordes horizontales de la pantalla, reflejando su posición, manteniendo su dirección en el componente paralelo al muro e invirtiendo la dirección perpendicular al mismo, detrás de las paletas no hay muros. Cada vez que la pelota toque el borde lateral del rival, el puntaje aumenta en 1 y se debe poder reiniciar el juego.

## Registro de puntaje: 
El juego mostrará el puntaje de los dos jugadores en tiempo real

## Diagrama de estados
El sistema contará con la máquina de estados que será mostrada a continuación:

Poner diagrama máquina de estados

En el estado INIT se inicializarán las variables del sistema, los jugadores no ven esta inicialización, posteriormente pasa a Menu, el cual es un estado estático. Al presionar el botón de control, el sistema debe pasar al estado START, en el que los jugadores se preparan para iniciar a jugar. Posteriormente, al volver a presional el botón de control el sistema debe pasar al estado PLAY, en el que la pelota se empieza a mover, este estado se mantiene hasta que la pelota choca con uno de los bordes laterales de la pantalla, donde pasa al estado END, el cual también es un estado estático. Para volver a jugar, el usuario puede presionar el botón de control y pasará del estado END hasta el estado START nuevamente.

# Arquitectura inicial:
A continuación se va a mostrar una idea preliminar de los datos y formas en las que se cumplirán las funciones mencionadas previamente:


## Datos constantes: 
Tamaño xy de la pantalla, 0 en xy, posición x de la paleta, puntaje inicial, posición xy inicial de la pelota, definición de tamaño xy de los muros, definición de forma de la pelota, definición de forma de la paleta, definición de forma de los muros, velocidad xy inicial de la pelota, valores RGB111 de todos los elemento gráficos.
## Datos variables: 
Posición en xy de la pelota, posición y de la paleta, dirección xy de la pelota, velocidad xy de la pelota, puntaje actual

## Descripción de operación:

### Inicio y reinicio: 
Se reescriben todos los datos variables a unos valores predeterminados.

### Operación: 
El periférico de los botones da 2 señales de entrada, cada vez que uno de los botones se presione se le suma o resta al valor de posición y de la paleta, cambiando su posición en la pantalla, el valor estara limitado a un intervalo entre 0 y el largo de la pantalla menos el largo de la paleta.


## Comportamiento independiente:

### Rebote de la pelota: 
Hay 2 componentes en la velocidad de la pelota, los cuales cambian segun la magnitud de la velocidad y el valor de la direccion, el valor de la direccion determina si el valor de la velocidad de la pelota es sumado o restado de la posición xy actual.

### Cambio de la velocidad de la pelota con la paleta: 
La pelota aumentará su magnitud de velocidad cada rebotes con paletas.

### Registro de puntaje: 
Cada vez que la pelota toque uno de los bordes laterales de la pantalla, se sumará un punto al contador de puntaje de ese jugador. Ambos puntajes serán mostrados en todo momento.

# Análisis del código

## Movimiento de la pelota

El movimiento de la pelota se realizó de la siguiente forma:

```` verilog
// animacion pelota
    always_ff @(posedge clk_pix) begin
        if (state ==INIT || state == START) begin  // reset posición pelota
            bx <= (H_RES - B_SIZE) >> 1;
            by <= (V_RES - B_SIZE) >> 1;
            dx <= 0;
            dy <= ~dy;
            lft_col <= 0;
            rgt_col <= 0;
        end else if (animate && state != POINT_END) begin
            if (p1_col) begin  // colicion con paleta izq
                dx <= 0;
                bx <= bx + spx;
                dy <= (by + B_SIZE/2 < p1y + P_H/2) ? 1 : 0;
            end else if (p2_col) begin  // colicion con paleta izq der 
                dx <= 1;
                bx <= bx - spx;
                dy <= (by + B_SIZE/2 < p1y + P_H/2) ? 1 : 0;
					 //led_2 <= 1;
					 //led_1 <= 0;
            end else if (bx >= H_RES - (spx + B_SIZE)) begin  // borde der
                rgt_col <= 1;
            end else if (bx < spx) begin  // borde izq
                lft_col <= 1;
            end else bx <= (dx) ? bx - spx : bx + spx;

            if (by >= V_RES - (spy + B_SIZE)) begin  // borde inf
                dy <= 1;
                by <= by - spy;
            end else if (by < spy) begin  // borde sup
                dy <= 0;
                by <= by + spy;
            end else by <= (dy) ? by - spy : by + spy;
        end
    end

````
Primero se utiliza un bloque secuencial que se ejecuta en cada flanco de subida del reloj clk_pix, actualizando la posición y dirección de la pelota. En los estados INIT y START, la pelota se posiciona en el centro de la pantalla, con bx y by calcuados a partir de resolución horizontal establecida H_RES y V_RES y el tamaño de la pelota que está dado por B_SIZE.  Durante la animación si la pelota impacta una de las paletas su dirección horizontal cambia dependiendo del lado de la colisión y su dirección vertical se ajusta según la posición relativa de la pelota con respecto a la paleta. Asimismo, si la pelota alcanza los límites de la pantalla, se activan las señales de colisión lft_col o rgt_col, lo que indica que se ha anotado un punto. En caso contrario, la pelota continúa su trayectoria en función de su dirección actual.

## Detección de colisiones con las paletas

El código se muestra a continuación:


```` verilog
// Detección de colición de las paletas
    always_ff @(posedge clk_pix) begin
        if (animate) begin
            p1_col <= 0;
            p2_col <= 0;
        end else if (b_draw) begin
            if (p1_draw) p1_col <= 1;
            if (p2_draw) p2_col <= 1;
        end
    end

````
Una colisión es detectada si se tiene que dibujar la pelota y también tiene que dibujar una de las paletas en pixeles repetidos. Para esto, se utiliza el clock de pixeles y se verifica en cada subida.

## Movimiento de las paletas

El código se muestra a continuación:

```` verilog
always_ff @(posedge clk_pix) begin
        if (state == START) begin  // reinicia posición de las paletas
            p1y <= (V_RES - P_H) >> 1;
            p2y <= (V_RES - P_H) >> 1;
        end else if (animate && state != POINT_END) begin
            if (state == PLAY) begin
					if(!move_dn && !move_up)begin
						p1y <= p1y;
					end
					
					if (!move_up) begin
						if (move_dn) begin
								if (p1y < aux)begin
									p1y <= p1y + P_SP;
								end
						end
					end
					
					if (move_up && !move_dn) begin		// paleta jugador 1
								if (p1y > P_SP) begin 
									p1y <= p1y - P_SP; 
								end
					end
						
					if(!move_dn_p2 && !move_up_p2)begin
						p2y <= p2y;
					end
					 
					if (!move_up_p2) begin
						if (move_dn_p2) begin
								if (p2y < aux)begin
									p2y <= p2y + P_SP;
								end
						end
					end
					
					if (move_up_p2 && !move_dn_p2) begin		// paleta jugador 2
								if (p2y > P_SP) begin 
									p2y <= p2y - P_SP; 
								end
					end
				  end
        end
    end
````

La lógica del movimiento de las paletas se planteó de forma que en el momento que el jugador presione uno de los dos botones de movimiento (Arriba o abajo), se enviara un 1 lógico y la paleta se empezara a mover en dicha dirección. Fue necesario agregar una condición que no permita que las paletas se salgan de la pantalla.

## Generación de señal VGA

Para la señal VGA se requiere utilizar dos variables para la sincronización vertical y horizontal (hsync, vsync). Además, dos variables que indican la posición actual de un pixel en la pantalla. Se utilizó una resolución de 640x480 pixeles y una tasa de refresco de 60Hz debido al estándar VGA. Finalmente, por limitaciones de la FPGA utilizada se utilizó un código RGB111 para los colores de los pixeles. La asignación de colores se muestra a continuación:

```` verilog
// Generación de colores
	logic [2:0] rgb;
	always_comb begin
		 if (press_start_pixel && (state== INIT  ||  state== POINT_END ||  state== IDLE)) begin
			  rgb <= 3'b111;  // Color del texto "PRESS START" (blanco)
		 end else if (de && b_draw && (state == START || state== PLAY|| state== POINT_END)) begin
			  rgb <= 3'b100;  // Color de la pelota (rojo)
		 end else if (de && p1_draw &&(state == START || state== PLAY|| state== POINT_END)) begin
			  rgb <= 3'b010;  // Color de la paleta 1 (verde)
		 end else if (de && p2_draw &&(state == START || state== PLAY|| state== POINT_END)) begin
			  rgb <= 3'b001;  // Color de la paleta 2 (azul)
		 end else if (de && (score_p1_pixel || score_p2_pixel) &&(state == START || state== PLAY || state== POINT_END)) begin
			  rgb <= 3'b111;  // Color del marcador (blanco)
		 end else begin
			  rgb <= 3'b000;  // Fondo (negro)
		 end
	end
	
	//output pins
	 assign dvi_r = rgb[2];
	 assign dvi_g = rgb[1];
	 assign dvi_b = rgb[0];
	 assign dvi_hsync = hsync;
	 assign dvi_vsync = vsync;

````
## Marcador de puntuación

Se definió el módulo chargen el cual genera carácteres numéricos en la pantalla y almacena los datos de dibujado en una memoria ROM. La ROM almacena la representación de los digitos del 0 al 9 mediante una matriz de 7x7 pixeles, donde cada bit indica si el pixel debe estar encendido o no.

Luego, a partir de las coordenadas sx y sy, la posición dentro del carácter charx y chary y el dígito a mostrar digit, el código accedea la ROM y activa los pixeles marcados en la salida pixel. 

```` verilog

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

````
Finalmente, se muestra la implementación del módulo char_gen y la lógica de como se aumenta el puntaje de jugador
```` verilog
// Instanciación del módulo char_gen
	logic score_p1_pixel, score_p2_pixel;

	char_gen char_p1 (
		 .clk_pix(clk_pix),
		 .sx(sx),
		 .sy(sy),
		 .digit(score_p1),
		 .char_x(SCORE_X_P1),
		 .char_y(SCORE_Y),
		 .pixel(score_p1_pixel)
	);

	char_gen char_p2 (
		 .clk_pix(clk_pix),
		 .sx(sx),
		 .sy(sy),
		 .digit(score_p2),
		 .char_x(SCORE_X_P2),
		 .char_y(SCORE_Y),
		 .pixel(score_p2_pixel)
	);
	
// Actualización de la puntuación
	always_ff @(posedge clk_pix) begin
		 if (state == PLAY) begin
			  if (lft_col) score_p2 <= score_p2 + 1;  // Jugador 2 anota
			  if (rgt_col) score_p1 <= score_p1 + 1;  // Jugador 1 anota
			  if (score_p2 == 10)begin
			  score_p2 <= 0 ; 
			  score_p1 <= 0;
			  end
			  if (score_p1 == 10) begin
			  score_p1 <= 0; 
			  score_p2 <= 0 ; 
			  end
		 end
	end



````

## Módulo de dibujado del texto "PRESS START"

Al igual que el marcador de jugador, se utiliza una lógica similar para el dibujado del texto press start. También se guardan los bits que deben estar encendidos por carácter en una memoria ROM y se acceden a ellos cuando se necesitan. A continuación se muestra el código del módulo de dibujado text_gen
```` verilog
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
        end else begin
            pixel = 0;
        end
    end
	 
endmodule

````

Finalmente, se muestra el llamado del módulo en el archivo top y la lógica de cuando se dibuja:

```` verilog

// Instanciación del módulo text_gen

	logic press_start_pixel;  // Señal para los píxeles del texto "PRESS START"

	text_gen press_start_text (
		 .clk_pix(clk_pix),
		 .sx(sx),
		 .sy(sy),
		 .text_x(TEXT_X),
		 .text_y(TEXT_Y),
		 .pixel(press_start_pixel)
	);
````

## Máquina de estados

A continuación se muestra el código de la máquina de estados descrita anteriormente:

```` verilog
// Maquina de estados
    enum {INIT, IDLE, START, PLAY, POINT_END} state, state_next;
    always_comb begin
        case(state)
            INIT: state_next = IDLE;
            IDLE: state_next = (sig_ctrl) ? START : IDLE;
            START: state_next = (sig_ctrl) ? PLAY : START;
            PLAY: state_next = (lft_col || rgt_col) ? POINT_END : PLAY;
            POINT_END: state_next = (sig_ctrl) ? START : POINT_END;
            default: state_next = IDLE;
        endcase
    end

    always_ff @(posedge clk_pix) begin
        state <= state_next;
    end

````
