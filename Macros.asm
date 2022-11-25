###########################################################################
#  libreria de funciones macro para RiscV programado por Heizel Gonzalez
##########################################################################
#  DICCIONARIO DE FUNCIONES:
##############################
#  leerArchivo (archivo,buffer,error) almacena en buffer la cadena que se obtuvo del archivo
#  guardarArchivo(ArchivoSalida,buffer,error) guarda en un archivo la cadena que se manda como un buffer
#  charToInt(cadena) lee la cadena que sea de 2 bytes por ejemplo 12 y lo convierte a decimal soporta desde 00-99 guarda el resultado en a0
#  subStrSpace(%origen,%destino)  busca en la cadena hasta encontrar el primer espacio guarda el resultado en a0
#  countChars(%cadena)  obtiene el total de caracteres de una cadena es desde 0 hasta encontrar un asterisco
#  factorizar(%num1)  factoriza un numero.
#  dimensionesMatriz(%original)   obtiene las primeros 4 bytes del buffer  y calcula tamanio de la matriz
#  origenLaberinto(cadena,origenLaberinto) obtiene el origen del laberinto
#  finalLaberinto(cadena,finalLaberinto) obtiene el final del laberinto
#  getToken(%original) obtenemos el token del archivo para procesarlo
#  runMatrix(%bufferl) en esta funcion recorremos el archivo y buscamos la siguiente posicion
#  guardarCamino(%camino) guardamos el output del camino 

##################################
# DICCIONARIO DE REGISTROS
#################################
# s1 = es un apuntador
# s3 = tamanio en x
# s4 = tamanio en y
# s5 = total tamanio de la cadena del buffer
# s6 = tortal del tamanio de la dimension de la matriz 
# s7 = origen
# s8 = destino
# x2 y x3 son contadores de loops
# las t2 - t6 para lo que necesite :)
# t4 = variable temporal x
# t5 = variable temporal y
# s2 = contador o para comparar caracteres
# a3 = proxima posicion
####################################### 



.macro   laberinto(%archivo,%buffer,%error,%destino,%origenLaberinto,%finalLaberinto,%matriz,%archivoSalida)
# ACA ES DONDEPROGRAMO LAS BUSQUEDAS.
  leerArchivo(%archivo,%buffer,%error) 		#abrimos el archivo
  countChars(%buffer)  					# contamos el total de la cadena
  dimensionesMatriz(%buffer)   				# obtenemos la dimension de la matriz
  origenLaberinto(%buffer,%origenLaberinto) 			#obtenemos el origen del laberinto
  finalLaberinto(%buffer,%finalLaberinto)  			#obtenemos el destino del laberinto
  runMatrix(%buffer,%matriz)   # aca analizamos todo lo del laberinto con lexicografico

  
  
 finalizar:
 # mv   a0, s0 		# impresion de lo que se ha leido
 # li   a7, 93
 # ecall
.end_macro  



.macro leerArchivo(%archivo,%buffer,%error)
  la   s0, %buffer   
  li   s1, 501     

  la   a0, %archivo  # param nombre de archivo
  li   a1, 0        # param 0 leer, param 1 escribir
  li   a7, 1024     # abrir archivo
  ecall

  bltz a0, errorlectura # Salto si a0 es menor a 0, es decir si no existe
  mv   s6, a0        # sguardar contenido del archivo

ciclolectura:
  mv   a0, s6       # descripcion del archivo 
  mv   a1, s0       # direccion de buffer
  mv   a2, s1       # cantidad de caracteres a leer
  li   a7, 63       # parametro para leer archivo
  ecall               
  bltz a0, cerrararchivo # en caso de error, cerrar el archivo es importante
  mv   t0, a0       
  add  t1, s0, a0   
  sb   zero, 0(t1)  

  beq  t0, s1, ciclolectura
  
cerrararchivo: 
  mv   a0, s6       # informacion del archivo / descriptor
  li   a7, 57       # parametro para cerrar archivo
  ecall             # Cerrar el archivo
  
finalizar:
  mv   a0, s0 		# impresion de lo que se ha leido
  li   a7, 4
  ecall

errorlectura:  # tuve qe comentarlo porque me sacaba ese error por ser falso positivo
#  la   a0, %error
# li   a7, 4
# ecall
.end_macro  

.macro guardarArchivo(%archivoSalida,%buffer,%error)
  la   s0, %buffer
  li   s1, 501      

  la   a0, %archivoSalida      # param nombre de archivo
  li   a1, 1        # param 0 leer, param 1 escribir
  li   a7, 1024     # abrir archivo
  ecall

  bltz a0, errorlectura # Salto si a0 es menor a 0, es decir si no existe
  mv   s6, a0        # sguardar info del archivo

  bltz a0, cerrararchivo # en caso de error, cerrar el archivo es importante
  mv   t0, a0       
  add  t1, s0, a0   
  sb   zero, 14(t1)  

  # impresion de lo que se ha leido
  mv   a0, s0
  li   a7, 4
  ecall
  mv   a0, s6       # descripcion del archivo 
  mv   a1, s0       # direccion de buffer
  mv   a2, s1       # cantidad de caracteres a leer
  li   a7, 64       # parametro para gardarr archivo
  ecall  

cerrararchivo: 
  mv   a0, s6       # informacion del archivo / descriptor
  li   a7, 57       # parametro para cerrar archivo
  ecall             # Cerrar el archivo

finalizar:
  li   a7, 10
  ecall

errorlectura:
  la   a0, %error
  li   a7, 4
  ecall

.end_macro  

.macro subStrSpace(%origen,%destino)  
    la	a0,%destino
    la	a1,%origen
    addi s2,zero,32    # busca la cadena hasta encontrar el primer espacio
  loop: 
    lb      t0, 0(a1)        # Load a char from the src
    sb      t0, 0(a0)        # Store the value of the src
    beq     t0, s2, imprimir  # Check if it's space
    addi    a0, a0, 1    # Advance destination one byte
    addi    a1, a1, 1    # Advance source one byte
 j loop
 
 imprimir:
        la a0,%destino
  	li a7, 4
    	ecall   
.end_macro


.macro countChars(%cadena)
 	la a1,%cadena
    	addi s2,zero,42    # busca la cadena hasta encontrar el asterisco
    	addi x3,x0,0       # contador=0
  	loop: 
    		lb      t0, 0(a1)        	# cargamos el caracter del inicio
    		beq     t0, s2, imprimir  	# Check if it's space
    		addi    a1, a1, 1   	 	# Advance source one byte
    		addi    x3,x3,1  	     		#contador=contador+1
 	j loop
 imprimir:
        mv t3,x3   # asignamos el valor del contador
        mv a0,x3   # regresamos el valor del contador 
        mv s5,x3
 # 	li a7, 93    #imprimimos el resultado del contado, deshabilitado porque se sale del programa por alguna razon je je je
 #  	ecall   
.end_macro

.macro dimensionesMatriz(%original)  
# obtenemos las primeros cuatro caracteres de la cadena para obtener las dimensionales de la matriz
	#asignar las cadenas
	la a1, %original
	addi s2,zero,10  
	#recorrer cadenas, esta es la clave  transformarlo tomando en cuenta el corrieniento
	# obtenemos el nmero de filas de la matriz 07
	lb t1, 0(a1) # t1 es decena en ascii
	lb t2, 1(a1) # t2 es el numero ascii
	#obtenemos el numero de columnas de la matriz 06 y lo convertimos
	lb t3, 3(a1) # t3 es la decena en asccii 
	lb t4, 4(a1) # t4 es el unidad en asscii
	
        #ahora hacemos el loop t1 para las  filas 
        addi s1,zero,48       # this is the ascii 
	 addi x3,x0,0           # i=0
		loop:				#mientras num no sea igual a 0 entonces multiplicamos
			bge  s1,t1,convertirT1 #comparamos el caracter asciic con el valor 
			addi x3,x3,1  	     		#contador=contador+1
			addi s1,s1,1            #  ascii = ascii +1   
		j loop
 
	convertirT1:
		addi t1,x3,0   # le asignamos el valor de las decenas 
       #ahora hacemos el loop t2
         addi s1,zero,48       # this is the ascii 
	  addi x3,x0,0           # i=0
		loop1:				#mientras num no sea igual a 0 entonces multiplicamos
			bge  s1,t2,convertirT2 #comparamos el caracter asciic con el valor 
			addi x3,x3,1  	     		#contador=contador+1
			addi s1,s1,1            #  ascii = ascii +1   
		j loop1
	convertirT2:
		addi t2,x3,0   # le asignamos el valor de las unidades	
	addi s0,zero,10
	mul  s1,s0,t1
	add  t5,s1,t2  # el valor se guarda en t5
	       #ahora hacemos el loop t1 para las columnas 
        addi s1,zero,48       # this is the ascii 
	 addi x3,x0,0           # i=0
		loop2:				#mientras num no sea igual a 0 entonces multiplicamos
			bge  s1,t3,convertirT3 #comparamos el caracter asciic con el valor 
			addi x3,x3,1  	     		#contador=contador+1
			addi s1,s1,1            #  ascii = ascii +1   
		j loop2
 
	convertirT3:
		addi t3,x3,0   # le asignamos el valor de las decenas 
       #ahora hacemos el loop t2
        addi s1,zero,48       # this is the ascii 
	 addi x3,x0,0           # i=0
		loop3:				#mientras num no sea igual a 0 entonces multiplicamos
			bge  s1,t4,convertirT4 #comparamos el caracter asciic con el valor 
			addi x3,x3,1  	     		#contador=contador+1
			addi s1,s1,1            #  ascii = ascii +1   
		j loop3
	convertirT4:
		addi t4,x3,0   # le asignamos el valor de las unidades	
	addi s0,zero,10
	mul  s1,s0,t1
	add  t6,s1,t4  # el valor se guarda en t6
	mv   s3,t5   # asignamos las filas x
	mv   s4,t6   # asignamos las columnas y
	mul  t3,t5,t6  # multiplicamos los valores para tamanio de matrizy lo guardamos en  
	mv   s6,t3
	mv   a0,t3  # multiplicamos los valores para tamanio de matriz
      # li a7, 93   #imprimimos el valor 
  	#ecall  
.end_macro

.macro  origenLaberinto(%cadena, %origenLaberinto)
    la	a1,%cadena
    la  a0,%origenLaberinto
    addi s2,zero,32    
  loop: 
    lb      t0, 6(a1)        # Load a char from the src
    sb      t0, 0(a0)        # Store the value of the src
    beq     t0, s2, imprimir  # Check if it's space
    addi    a0, a0, 1    # Advance destination one byte
    addi    a1, a1, 1    # Advance source one byte
 j loop
 imprimir:
        la s7,%origenLaberinto
  #      mv a0,s7
 # 	li a7, 4
 #   	ecall       	
.end_macro



.macro  finalLaberinto(%cadena, %finalLaberinto)
    la	a1,%cadena
    la  a0,%finalLaberinto
    addi s2,zero,32    
  loop: 
    lb      t0, 10(a1)        # Load a char from the src
    sb      t0, 0(a0)        # Store the value of the src
    beq     t0, s2, imprimir  # Check if it's space
    addi    a0, a0, 1    # Advance destination one byte
    addi    a1, a1, 1    # Advance source one byte
 j loop
 imprimir:
        la s8,%finalLaberinto
  #      mv a0,s8
 # 	li a7, 4
    	ecall   
.end_macro






.macro charToInt(%original)
	#asignar las cadenas
	la a1, %original
	addi s2,zero,10
	#recorrer cadenas, esta es la clave  transformarlo tomando en cuenta el corrieniento
	lb t1, 0(a1) # t1 es decena
	lb t2, 1(a1) # t2 es el numero ascii
	
        #ahora hacemos el loop t1
        addi s1,zero,48       # this is the ascii 
	 addi x3,x0,0           # i=0
		loop:				#mientras num no sea igual a 0 entonces multiplicamos
			bge  s1,t1,convertirT1 #comparamos el caracter asciic con el valor 
			addi x3,x3,1  	     		#contador=contador+1
			addi s1,s1,1            #  ascii = ascii +1   
		j loop
 
	convertirT1:
		addi t1,x3,0   # le asignamos el valor de las decenas 
       #ahora hacemos el loop t2
         addi s1,zero,48       # this is the ascii 
	 addi x3,x0,0           # i=0
		loop1:				#mientras num no sea igual a 0 entonces multiplicamos
			bge  s1,t2,convertirT2 #comparamos el caracter asciic con el valor 
			addi x3,x3,1  	     		#contador=contador+1
			addi s1,s1,1            #  ascii = ascii +1   
		j loop1
	convertirT2:
		addi t2,x3,0   # le asignamos el valor de las unidades
		
	addi s0,zero,10
	mul  s1,s0,t1
	add a0,s1,t2  # el valor se guarda en t3
	li a7, 93   #imprimimos el valor 
  	ecall  
.end_macro


.macro getToken(%original)
	#asignar las cadenas en este caso original es un token 01A
	la a1, %original
	addi s2,zero,10
	#recorrer cadenas, esta es la clave  transformarlo tomando en cuenta el corrieniento
	lb t1, 0(a1) # t1 es decenaen ascii
	lb t2, 1(a1) # t2 es el numero ascii
	lb s10, 2(a1)  # obtenemos el caracter si es A B C o D  
	
        #ahora hacemos el loop t1
        addi s1,zero,48       # this is the ascii 
	 addi x3,zero,0           # i=0
		loop:				#mientras num no sea igual a 0 entonces multiplicamos
			bge  s1,t1,convertirT1 #comparamos el caracter asciic con el valor 
			addi x3,x3,1  	     		#contador=contador+1
			addi s1,s1,1            #  ascii = ascii +1   
		j loop
 
	convertirT1:
		addi t1,x3,0   # le asignamos el valor de las decenas 
       #ahora hacemos el loop t2
         addi s1,zero,48       # this is the ascii 
	  addi x3,zero,0           # i=0
		loop1:				#mientras num no sea igual a 0 entonces multiplicamos
			bge  s1,t2,convertirT2 #comparamos el caracter asciic con el valor 
			addi x3,x3,1  	     		#contador=contador+1
			addi s1,s1,1            #  ascii = ascii +1   
		j loop1
	convertirT2:
		addi t2,x3,0   # le asignamos el valor de las unidades	
       addi  s0,zero,10
	mul  s1,s0,t1
	add  s7,s1,t2  # el valor se guarda en s7 posicion actual.
.end_macro


.macro runMatrix(%origen,%destino)
# s3 = tamanio en x
# s4 = tamanio en y
        # vamos a recorrer la cadena y obtener el token, primero nos posicionamos en 14 porque aca comienza la matriz
        addi t4,zero,1   # aca inicializamos las coordenadas en X
        addi t5,zero,1   # aca inicializamos las coordenadas en Y
        la a0,%destino
        la s9,%origen
        
    	addi t6,zero,32    # aca comparamos que sea espacio para obtener el token
    	addi t3,zero,42   #aca tenemos el final de la cadena que es asterisco
  	loop: 
     		lb      t0, 14(s9)        	# Load a char from the src
    		sb      t0, 0(a0)        	# Store the value of the src
    		beq     t0, t3, finalizar   	# Check if it's * or end
    		beq     t0, t6, token  	# Check if it's space
   		addi    a0, a0, 1    		# Advance destination one byte
    		addi    s9, s9, 1    		# Advance source one byte
 	j loop
token:
        la a0,%destino  # en teoria ya tenemos el token hasta espacio
        li a7, 4
        ecall 
        getToken(%destino)# a0 recibe el valor de la cadena
        addi    s9, s9, 1    		# Advance source one byte del buffer
        # beq  s8,a0,haySalida   # comparamos si hay salidasi la hay entonces sacamos mensaje
        #vamos a reutilizar las variables dentro de la funcion
	addi s5,zero,65  # a s2 le ponermos el valor 65 ASCII A
	addi s6,zero,66  # a s1 le ponemos el valor 66 ASCII B
	addi s2,zero,67  # a T1 le puedo poner el valor 67 ASCII C
	addi s8,zero,68  # a x3 le puedo asignar el valor 68 ASCII D
	addi s11,zero,0   # nos va a servir para comparar el cero
	
	# en esta seccion hacemos las comparaciones respectivas 
	beq  s10,s2,sumarX  #C
	beq  s10,s8,sumarY  #D
	beq  s10,s5,restarX #A
	beq  s10,s6,restarY #B

sumarX:
     addi t4,t4,1  # a x3 le puedo asignar el valor 68 ASCII D
      j siguientePosicion    # calculamos la siguiente posicion
sumarY:
     addi t5,t5,1  # a x3 le puedo asignar el valor 68 ASCII D
      j siguientePosicion   
restarX:
     bge t4,s11,errorZero #comparamos si es cero
     addi t4,t4,-1  # le resto 1 a x
      j siguientePosicion   
restarY:
     bge t5,s11,errorZero  #comparamos si es cero
     addi t5,t5,-1  # le resto 1 a Y
     j siguientePosicion    
errorZero:
       la a0,errorCero # en teoria ya tenemos el token hasta espacio
       li a7, 4
       ecall 
siguientePosicion:   
# aca hacemos el calculo lexicografico
# s4(t5-1)+t4-1  
# primero tenemos que calcular t5 -1
   addi a3,t5,-1   # aca x0 = t5-1
   mul  a3,a3,s4   # aca x0 = x0*s4
   add  a3,a3,t4   # aca x0= x0+t4
   j loop    # regresamos al loop para obtener el siguiuente token
# bueno, tenemos la siguiente posicion, ahora tenemos que obtener el valor del token y comparar si el tamanio el numero es correcto
# si el sigiuente token no coincide buscamos el siguiente token hasta obtener el valor de x0 y ver la siguiente posicion

# end Macro
finalizar:
# si llegamos al asterisco entonces no hay salida
#li a7,10
#ecall

.end_macro


