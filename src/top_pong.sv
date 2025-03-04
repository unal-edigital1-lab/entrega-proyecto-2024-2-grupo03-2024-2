// Altera Cyclone 4EPCE10, 1-bit VGA
// resolucion: 640x480
// led_1/led_2 Para indicar colisiones



`default_nettype none
`timescale 1ns / 1ps

module top_pong (
    input  wire logic clk_50m,      // 50 MHz clock
    input  wire logic btn_rst,      // botón refresco pantalla
    input  wire logic btn_up,       // botón arriba jugador 1
    input  wire logic btn_ctrl,     // botón de control
    input  wire logic btn_dn,       // botón abajo jugador 1
	 input  wire logic btn_up_p2,    // botón arriba jugador 2
	 input  wire logic btn_dn_p2,    // botón abajo jugador 2
	 
	 
    output      logic dvi_hsync,    // DVI horizontal sync
    output      logic dvi_vsync,    // DVI vertical sync
	 output      logic dvi_r,  // 1-bit VGA red
    output      logic dvi_g,  // 1-bit VGA green
    output      logic dvi_b   // 1-bit VGA blue
    );

	 
    // generar clock de pixeles
    logic clk_pix;
    logic clk_locked;
	 
	 
	 clock_gen clock_640x480 (
		.inclk0(clk_50m), //50Mhz
		.areset(!btn_rst),
		.c0(clk_pix),
		.locked(clk_locked));

    // display timings
    localparam CORDW = 10;  // screen coordinate width in bits
    logic [CORDW-1:0] sx, sy;
    logic hsync, vsync, de;
    display_timings_480p timings_640x480 (
        .clk_pix,
        .rst(!clk_locked),  // wait for clock lock
        .sx,
        .sy,
        .hsync,
        .vsync,
        .de
    );
	 

    // Tamaño de la pantalla
    localparam H_RES_FULL = 800;
    localparam V_RES_FULL = 525;
    localparam H_RES = 640;
    localparam V_RES = 480;
	
    logic animate;  
    always_comb animate = (sy == V_RES && sx == 0);

    // anti rebote
    logic sig_ctrl, move_up, move_dn, move_up_p2, move_dn_p2;
    debounce deb_ctrl
        (.clk(clk_pix), .in(!btn_ctrl), .out(), .ondn(), .onup(sig_ctrl));
    debounce deb_dn
        (.clk(clk_pix), .in(!btn_dn), .out(move_dn), .ondn(), .onup());
    debounce deb_up
        (.clk(clk_pix), .in(!btn_up), .out(move_up), .ondn(), .onup());
	 debounce deb_dn_p2
        (.clk(clk_pix), .in(!btn_dn_p2), .out(move_dn_p2), .ondn(), .onup());
    debounce deb_up_p2
        (.clk(clk_pix), .in(!btn_up_p2), .out(move_up_p2), .ondn(), .onup());
	 
    

    // Pelota
    localparam B_SIZE = 8;      // tamaño en pixeles
    logic [CORDW-1:0] bx, by;   // posicion
    logic dx, dy;               // direccion
    logic [CORDW-1:0] spx;      // velocidad en x
    logic [CORDW-1:0] spy;      // velocidad en y
    logic lft_col, rgt_col;     // condiciones lógicas de colision con bordes laterales
    logic b_draw;               // condición lógica que indica si se dibuja la pelota

    // Paletas
    localparam P_H = 40;         // altura en pixeles
    localparam P_W = 8;         // ancho en pixeles
    localparam P_SP = 4;         // velocidad
    localparam P_OFFS = 32;      // offset con respecto al borde de la pantalla
    logic [CORDW-1:0] p1y, p2y;  // posición vertical de las paletas 1 y 2
    logic p1_draw, p2_draw;      // condición lógica que indica si se dibuja las paletas
    logic p1_col, p2_col;        // condición lógica que indica si la pelota choca con una paleta

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
	 
	 
	 
	 
	 // Variables de puntuación
	logic [3:0] score_p1 = 0;  // Puntuación del jugador 1
	logic [3:0] score_p2 = 0;  // Puntuación del jugador 2

	// Posiciones del marcador
	localparam SCORE_X_P1 = 200;  // Posición X del marcador del jugador 1
	localparam SCORE_X_P2 = 400;  // Posición X del marcador del jugador 2
	localparam SCORE_Y = 50;      // Posición Y del marcador
	
	//Posicion del texto
	localparam TEXT_X = 280;  // Posición X del texto "PRESS START"
	localparam TEXT_Y = 200;  // Posición Y del texto "PRESS START"
	
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
	 
	 
	 
	 
	 

	 wire [12:0]aux;
	 
	 assign aux = V_RES - P_H - P_SP;
    // Animación paleta
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

    // Dibujo de las paletas y comprobación de límites
    always_comb begin
        p1_draw = (sx >= P_OFFS) && (sx < P_OFFS + P_W)
               && (sy >= p1y) && (sy < p1y + P_H);
        p2_draw = (sx >= H_RES - P_OFFS - P_W) && (sx < H_RES - P_OFFS)
               && (sy >= p2y) && (sy < p2y + P_H);
    end

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

    // control de velocidad de la pelota
    localparam SPEED_STEP = 5;  // cantidad de coliciones para aumento de velocidad
    logic [$clog2(SPEED_STEP)-1:0] cnt_sp;  // velocimetro
    always_ff @(posedge clk_pix) begin
        if (state == START) begin  // velocidad inicial
            spx <= 3;
            spy <= 1;
        end else if (state == PLAY && animate && (p1_col || p2_col)) begin
            if (cnt_sp == SPEED_STEP-1) begin
                spx <= spx + 1;
                spy <= spy + 1;
                cnt_sp <= 0;
            end else begin
                cnt_sp <= cnt_sp + 1;
            end
        end
    end

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

    // dibujo de pelota 
    always_comb begin
        b_draw = (sx >= bx) && (sx < bx + B_SIZE)
              && (sy >= by) && (sy < by + B_SIZE);
    end

	 
	 
	 
	 
	

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
	 //assign dvi_de    = de;
	 

endmodule
