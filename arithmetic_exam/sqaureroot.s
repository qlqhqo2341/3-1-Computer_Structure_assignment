.data
querypoint: .word -10 10

.text
.globl main
main:
    la $t0,querypoint
    lw $t1,4($t0)
    lw $t0,($t0)

    abs $t1,$t1
    abs $t0,$t0

    li $v0,5
    syscall

    move $a0,$v0
    jal squareRoot

    move $a0,$v0
    li $v0,1
    syscall

    li $v0,10
    syscall



squareRoot:
    move $v0,$a0
    li $t1,0
sqaureRootLoop:
    div $t0,$a0,$v0
    add $v0,$v0,$t0
    div $v0,$v0,2
    
    add $t1,$t1,1
    blt $t1,20,sqaureRootLoop
    jr $ra