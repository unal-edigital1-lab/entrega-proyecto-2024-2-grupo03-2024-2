`default_nettype none
`timescale 1ns / 1ps

module debounce (
    input wire logic clk,   // Reloj del sistema
    input wire logic in,    // Señal de entrada (con rebote)
    output logic out,       // Señal de salida (sin rebote)
    output logic ondn,      // Pulso de un ciclo cuando la señal baja (1 -> 0)
    output logic onup       // Pulso de un ciclo cuando la señal sube (0 -> 1)
);

    // Sincronización con el reloj para evitar metastabilidad
    logic sync_0, sync_1;
    always_ff @(posedge clk) sync_0 <= in;
    always_ff @(posedge clk) sync_1 <= sync_0;

    // Contador para eliminar el rebote
    logic [16:0] cnt;  // Contador de 17 bits (2^17 = 131,072 ciclos)
    logic max;
    assign max = &cnt;  // True si el contador alcanza su máximo

    // Lógica del contador y actualización de la señal de salida
    always_ff @(posedge clk) begin
        if (sync_1 != out) begin  // Si la señal de entrada es diferente a la salida
            if (cnt == 0) begin
                out <= sync_1;  // Actualiza la salida
                if (sync_1) onup <= 1;  // Pulso onup si la señal sube
                else ondn <= 1;         // Pulso ondn si la señal baja
            end else begin
                cnt <= cnt + 1;  // Incrementa el contador
            end
        end else begin
            cnt <= 0;  // Reinicia el contador si la señal está estable
            onup <= 0;
            ondn <= 0;
        end
    end

endmodule 