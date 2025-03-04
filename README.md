[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=17798990&assignment_repo_type=AssignmentRepo)
# Entrega 1 del proyecto WP01

Proyecto Electrónica Digital 2024-2 Grupo 3

Juan Esteban Otavo García


Detalles generales:
El proyecto de curso para este semestre es la creación de un juego de PONG de dos jugadores en una FPGA con un sistema de puntaje, cambio de dificultad y multiples vidas.

# Especificaciones del sistema:
Hardware: El prototipo será creado usando una FPGA Cyclone V, una pantalla usando protocolo VGA, dos botones por jugador para el control de las paletas y dos botones extra para control de la partida y refrescar la pantalla en caso de bugs visuales.
# Software: El prototipo debe realizar estas funciones para que se pueda considerar como funcional:
## Inicio/reinicio: 
El juego debe permitir que el jugador decida en que momento se da el inicio y el reinicio, por lo que se va a programar mediante un botón.
## Operación: 
El control del jugador se limita a definir la posición de la paleta en el eje Y usando dos botones. 
## Comportamiento independiente: 
Cada vez que el juego se reinicie la pelota será colocada en el centro de la pantalla, posteriormente será disparada con un ángulo variable y una velocidad predeterminada, la pelota rebotara en los bordes horizontales de la pantalla, reflejando su posición, manteniendo su dirección en el componente paralelo al muro e invirtiendo la dirección perpendicular al mismo, detrás de la paleta no hay un muro. Cada vez que la pelota toque la paleta el puntaje aumenta en 1. Cada vez que la pelota llegue al área detrás de la paleta el jugador perderá una vida y se reiniciara su puntaje, una vez el jugador pierde todas sus vidas (empezando con un número predeterminado) se acabara el juego, más allá de este punto la única interacción posible será reiniciar el juego.
## Registro de puntaje: 
El juego mostrará el puntaje que se logre en la vida actual, en caso de que dicho puntaje supere al mejor puntaje previo este va a sobrescribir al puntaje más alto.

# Arquitectura inicial:
A continuación se va a mostrar una idea preliminar de los datos y formas en las que se cumplirán las funciones mencionadas previamente:
## Datos constantes: 
Tamaño xy de la pantalla, 0 en xy, posición x de la paleta, puntaje inicial, posición xy inicial de la pelota, definición de tamaño xy de los muros, definición de forma de la pelota, definición de forma de la paleta, definición de forma de los muros, velocidad xy inicial de la pelota, caracteres ASCII 0-9, A-Z, valores RGB de todos los elemento gráficos.
## Datos variables: 
Posición en xy de la pelota, posición y de la paleta, dirección xy de la pelota, velocidad xy de la pelota, puntaje actual, puntaje más alto, número de vidas.
 Funciones/módulos": Sumadores, restadores, divisores, comparadores, reloj interno, preservación de datos en memoria.
Descripción de operación:
### Inicio y reinicio: 
Se reescriben todos los datos variables a unos valores predeterminados.
### Operación: 
El periférico de los botones da 2 señales de entrada, cada vez que uno de los botones se presione se le suma o resta al valor de posición y de la paleta, cambiando su posición en la pantalla, el valor estara limitado a un intervalo entre 0 y el largo de la pantalla menos el largo de la paleta.
## Comportamiento independiente:
### Rebote de la pelota: 
Hay 2 componentes en la velocidad de la pelota, los cuales cambian segun la magnitud de la velocidad y el valor de la direccion, el valor de la direccion determina si el valor de la velocidad de la pelota es sumado o restado de la posición xy actual.
### Ángulo/física para cambio de las velocidades de la pelota con la paleta: 
Según el intervalo en el que la pelota golpeé la paleta se le darán valores de velocidad xy diferentes para que no se vuelva predecible
### Aumento de dificultad: 
Multiplicar por 2 los valores de xy cada 10 puntos. X2, X4, x6 etc con el objetivo de hacer el juego más desafiante.
### Pérdida de vidas: 
Comparar el valor x de la pelota con el de la paleta, si es menr al de la paleta se reduce el contador de vidas en uno y se reescriben los valores de velocidad y posicion (pero no el de direccion)
### Registro de puntaje: 
Cada vez que el valor de x de la pelota sea igual al de la paleta y el valor y este en el intervalo en el que está la paleta se suma un punto al puntaje, cada vez que esto ocurre se compara el número del puntaje con el del puntaje máximo, y en caso de que el puntaje máximo sea menor este se sobreescribe con el puntaje actual.



## plan de trabajo acordado con el profesor 

# semana 1
1. diseño driver pantalla ili9341 se recomienda usar lo trabajado de los  grupos de 2024-1
