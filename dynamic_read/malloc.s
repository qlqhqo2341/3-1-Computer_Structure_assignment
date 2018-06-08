.data
buffer: .space 1024

.text
.globl main
main:
    li $v0,8
    la $a0,buffer
    li $a1,1024
    syscall

    move $v1,$v0

    li $v0,10
    syscall