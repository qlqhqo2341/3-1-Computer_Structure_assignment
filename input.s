        .data
str:        .asciiz "Welcome :\n"
fin:        .asciiz "C:/Users/qlqhq/Desktop/mips_input.txt"
buffer:     .space 1024

    .text
    .globl main
main:
        la $a0,str
        li $v0,4
        syscall
#open file
    li $v0, 13               #open a file
    la $a0, fin          # load file name
    li $a1, 0                # Open for reading
    li $a2, 0
    syscall
    move $s6, $v0           # load file descriptor

    li $v0, 14               #read from file
    add $a0, $s6, $0           #file descriptor
    la $a1, buffer          # address of buffer to which to read
    li $a2, 1024            # hardcoded buffer length
    syscall  

    li   $v0, 16         # system call for close file
    add $a0, $s6, $0        # file descriptor to close
    syscall

Exit:
        li $v0,10
        syscall