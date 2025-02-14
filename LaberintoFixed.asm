###########################################################################
#  Libreria de funciones macro para RISC-V programado por Heizel Gonzalez
###########################################################################

.macro printError(%msg)
    la   a0, %msg
    li   a7, 4
    ecall
    li   a7, 10
    ecall
.end_macro

.macro asciiToInt(%ascii, %dest)
    addi %dest, %ascii, -48   # Convierte ASCII en número
.end_macro

.macro leerArchivo(%archivo, %buffer, %error)
    la   s0, %buffer   
    li   s1, 501

    la   a0, %archivo  # Nombre del archivo
    li   a1, 0        # Modo de lectura
    li   a7, 1024     # Syscall para abrir archivo
    ecall

    bltz a0, errorlectura
    mv   s6, a0  

ciclolectura:
    mv   a0, s6
    mv   a1, s0
    mv   a2, s1
    li   a7, 63
    ecall
    bltz a0, cerrararchivo

    mv   t0, a0
    add  t1, s0, a0
    sb   zero, 0(t1)
    beq  t0, s1, ciclolectura

cerrararchivo:
    mv   a0, s6
    li   a7, 57
    ecall

errorlectura:
    printError(%error)
.end_macro

.macro guardarArchivo(%archivoSalida, %buffer, %error)
    la   s0, %buffer
    li   s1, 501

    la   a0, %archivoSalida
    li   a1, 1        # Modo de escritura
    li   a7, 1024     # Syscall abrir archivo
    ecall

    bltz a0, errorlectura
    mv   s6, a0

    mv   a0, s6
    mv   a1, s0
    mv   a2, s1
    li   a7, 64   # Escribir archivo
    ecall  

cerrararchivo: 
    mv   a0, s6
    li   a7, 57
    ecall

errorlectura:
    printError(%error)
.end_macro

.macro countChars(%cadena)
    la a1, %cadena
    addi s2, zero, 42  # Asterisco (*) como terminador
    li x3, 0  # Contador
loop:
    lb t0, 0(a1)
    beq t0, s2, fin
    addi a1, a1, 1
    addi x3, x3, 1
    j loop
fin:
    mv a0, x3
    mv s5, x3
.end_macro

.macro dimensionesMatriz(%original)
    la a1, %original
    lb t1, 0(a1)
    lb t2, 1(a1)
    lb t3, 3(a1)
    lb t4, 4(a1)
    
    asciiToInt(t1, t1)
    asciiToInt(t2, t2)
    asciiToInt(t3, t3)
    asciiToInt(t4, t4)
    
    li s0, 10
    mul s1, t1, s0
    add s3, s1, t2
    mul s1, t3, s0
    add s4, s1, t4
    mul s6, s3, s4  # Tamaño de la matriz
.end_macro

.macro origenLaberinto(%cadena, %origenLaberinto)
    la a1, %cadena
    la a0, %origenLaberinto
    addi s2, zero, 32  # Espacio
loop:
    lb t0, 6(a1)
    sb t0, 0(a0)
    beq t0, s2, fin
    addi a0, a0, 1
    addi a1, a1, 1
    j loop
fin:
    mv s7, a0
.end_macro

.macro finalLaberinto(%cadena, %finalLaberinto)
    la a1, %cadena
    la a0, %finalLaberinto
    addi s2, zero, 32  # Espacio
loop:
    lb t0, 10(a1)
    sb t0, 0(a0)
    beq t0, s2, fin
    addi a0, a0, 1
    addi a1, a1, 1
    j loop
fin:
    mv s8, a0
.end_macro

.macro runMatrix(%origen, %destino)
    addi t4, zero, 1  # Coordenada X
    addi t5, zero, 1  # Coordenada Y
    la a0, %destino
    la s9, %origen
    addi t6, zero, 32  # Espacio
    addi t3, zero, 42  # Asterisco (*)
loop:
    lb t0, 14(s9)
    sb t0, 0(a0)
    beq t0, t3, finalizar
    beq t0, t6, token
    addi a0, a0, 1
    addi s9, s9, 1
    j loop

token:
    la a0, %destino
    li a7, 4
    ecall
    addi s9, s9, 1

    # Comparación con direcciones
    addi s5, zero, 65  # 'A'
    addi s6, zero, 66  # 'B'
    addi s2, zero, 67  # 'C'
    addi s8, zero, 68  # 'D'
    addi s11, zero, 0

    beq s10, s2, sumarX
    beq s10, s8, sumarY
    beq s10, s5, restarX
    beq s10, s6, restarY

sumarX:
    addi t4, t4, 1
    j siguientePosicion
sumarY:
    addi t5, t5, 1
    j siguientePosicion
restarX:
    blt t4, s11, errorZero
    addi t4, t4, -1
    j siguientePosicion
restarY:
    blt t5, s11, errorZero
    addi t5, t5, -1
    j siguientePosicion

errorZero:
    printError(errorCero)

siguientePosicion:
    addi a3, t5, -1
    mul a3, a3, s4
    add a3, a3, t4
    j loop

finalizar:
    li a7, 10
    ecall
.end_macro
