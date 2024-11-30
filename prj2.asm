#recieve multiplier and multiplicand, detect incorrect inputs
.data
input: .space 32
errorText: .asciiz "input error!\n"
newline: .asciiz "\n"
printX: .asciiz "X"
space: .asciiz " "
dash: .asciiz "----------\n"

.text
main:

#get multiplicand
li $v0, 8
la $a0, input
la $a1, 32
syscall

jal startConversion
move $s1, $v0 #move result to $s1

#get multiplier
li $v0, 8
la $a0, input
la $a1, 32
syscall

jal startConversion
move $s2, $v0 #move result to $s2

li $v0, 4
la $a0, space
syscall

#print multiplicand
move $v0, $s1
jal binary

li $v0, 4
la $a0, newline
syscall

#printX
li $v0, 4
la $a0, printX
syscall

#print multiplier
move $v0, $s2
jal binary

li $v0, 4
la $a0, newline
syscall

li $v0, 4
la $a0, dash
syscall

j booth
#j finish

startConversion:
    addi $s0, $zero, 0 #initialize
    addi $t1, $zero, 10 # set equal to 10
    lb $t0, 0($a0) # get ascii of first character of string
    
    bne $t0, 45, posConversion
    #lb $t0, 1($a0)
    #beq $t0, $t1, inputError
    addi $t3, $a0, 1
    lb $t3, 0($t3)
    beq $t3, $t1, inputError
    beq $t0, 45, negConversion #branch if negative

posConversion:  
    lb $t0, 0($a0)
    beq $t0, $t1, exit
    bgt $t0, 57, inputError
    blt $t0, 48, inputError
    addi $t0, $t0, -48 # get decimal value
    mult $s0, $t1 # multiply by 10
    mflo $s0
    mfhi $t2
    #blt $s0, 0, inputError #overflow at >2147483647
    bne $t2, 0, inputError #overflow at >2147483647
    addu $s0, $s0, $t0 
    blt $s0, 0, inputError #overflow at >2147483647
    addi $a0, $a0, 1
    j posConversion

negConversion:  
    lb $t0, 1($a0)
    beq $t0, $t1, exit
    bgt $t0, 57, inputError
    blt $t0, 48, inputError
    addi $t0, $t0, -48 # get decimal value
    mult $s0, $t1 # multiply by 10 
    mflo $s0
    mfhi $t2
    #bgt $s0, 0, inputError #overflow at >-2147483648
    #bne $t2, 0, inputError #overflow at >-2147483648
    bgt $t2, 0, inputError
    sub $s0, $s0, $t0 
    addi $a0, $a0, 1
    j negConversion

exit:
    move $v0, $s0
    jr $ra

inputError:
    li $v0, 4
    la $a0, errorText
    syscall
    li $v0, 10
    syscall
    #j finish

binary:
    add $t0, $v0, $zero
    addi $t4, $zero, 32 #counter

binaryLoop:
    addi $t4, $t4, -1 #decrease counter by 1
    srlv $t2, $t0, $t4 #shift right by counter
    andi $t2, $t2, 1

    li $v0, 1 #print
    add $a0, $t2, $zero
    syscall
    bne $t4, $zero, binaryLoop
    jr $ra

booth:
    addi $s7, $zero, 0 #initialize A
    addi $s3, $zero, 0 #Q0
    addi $s4, $zero, 32 #counter
    addi $s5, $zero, 0 #Q-1
    addi $s6, $zero, 0 #hold answer

    #multipicand s1 M
    #multiplier s2 Q
    #sra
boothLoop:
    andi $s3, $s2, 1 #find Q0
    beq $s3, $s5, shift #skips
    beq $s3, $zero, when01
    #when 10 A=A-M
    sub $s7, $s7, $s1
    j shift

when01: #A=A+M
    add $s7, $s7, $s1

shift:
    #add $s6, $s6, $s7 #load A
    add $s5, $s3, $zero #Q1<-Q0
    srl $s2, $s2, 1
    andi $t0, $s7, 1 #find A0
    sll $t0, $t0, 31
    or $s2, $s2, $t0 #combine A0 with Q
    sra $s7, $s7, 1 #shift A right 1 keep msb
    
    li $v0, 4
    la $a0, space
    syscall

    move $v0, $s7
    jal binary

    move $v0, $s2
    jal binary
    
    li $v0, 4
    la $a0, newline
    syscall
    
    addi $s4, $s4, -1
    beq $s4, $zero, finish
    j boothLoop

finish:
    li $v0, 4
    la $a0, dash
    syscall

    li $v0, 4
    la $a0, space
    syscall

    move $v0, $s7 #2,147,483,647
    jal binary

    move $v0, $s2
    jal binary

    li $v0, 4
    la $a0, newline
    syscall
    
    li $v0, 10
    syscall

    