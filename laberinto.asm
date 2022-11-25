.global programa   #Directiva punto de arranque del programa
.data              #Inicio segmento de datos
error:
  .string  "No se ha podido abrir el archivo"
archivo:
  .string  "testo.txt"
archivoSalida:
  .string  "out_salida.txt"
buffer:
  .string "501"
Laberinto:
   .string "        "
cadena:
  .string "56"
hola:
	.string "Heizel Gonzalez 1202101!"
destino:
	.string "  "
resultado1:
           .string "si hay salida"
	
origenLaberinto:
		.string "	"
finalLaberinto:
		.asciz "      "
errorCero:
             .string "no se puede restar a cero"
matriz:
             .string "              "


	
.include "Macros.asm"	# aca vamos a poner las funciones en macro para facilitar codigo
.text              #Inicio segmento de codigo	
programa:
	 
        laberinto(archivo,buffer,error,destino,origenLaberinto,finalLaberinto,matriz,archivoSalida)
  #      guardarArchivo(archivoSalida,matriz,error)
        guardarArchivo(archivoSalida,resultado1,error)
 	la  a0, matriz  #ahora se que la cadena esta en el buffer
  	li   a7, 4
  	ecall     
      
finalizar:
	li a7, 10  #Parametro para finalizar programa
	ecall      #int 21h
