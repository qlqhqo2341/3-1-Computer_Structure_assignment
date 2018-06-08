.data
prompt: .ascii  "Factorial Example  Program\n\n"
        .asciiz "Enter N value: "
results:.asciiz "\nFactorial of N = "

n:      .word 0
answer: .word 0

.text
.globl  main
main:
    li	$v0, 4		# $v0 = 4, print promt string
    la	$a0, prompt		# print prompt string
    syscall

    li $v0, 5
    syscall

    sw $v0, n

#call factorial function

    lw $a0, n
    jal fact

    sw $v0, answer

#display result    

    li $v0,4
    la $a0, results
    syscall

    li $v0, 1
    lw $a0, answer
    syscall

# terminate program
    li $v0, 10
    syscall

.globl fact
.ent fact
fact:
    subu $sp, $sp, 8
    sw $ra, ($sp)
    sw $s0, 4($sp)

    li $v0, 1       #check base case
    beq $a0, 0, factDone

    move $s0, $a0
    sub $a0, $a0, 1
    jal fact

    mul $v0, $s0, $v0

factDone:
    lw $ra, ($sp)
    lw $s0, 4($sp)
    addu $sp, $sp, 8
    jr $ra
.end fact