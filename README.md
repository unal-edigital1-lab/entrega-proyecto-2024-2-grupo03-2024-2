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
