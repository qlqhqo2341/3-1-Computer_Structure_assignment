.data

x:  .word 3
y:  .word 5
answer: .word 0

.text
.globl  main
.ent    main
main:
    lw $a0,x
    lw $a1,y
    jal power
    sw $v0,answer

    move $a0, $v0
    li $v0,1
    syscall

    li $v0, 10
    syscall
.end main

.globl power
.ent power
power:
    li  $v0,1
    li  $t0,0

powLoop:
    mul $v0, $v0, $a0
    add $t0, $t0, 1
    blt $t0, $a1, powLoop

    jr  $ra
.end power