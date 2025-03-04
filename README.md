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
