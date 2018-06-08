.data
prompt: .ascii  "Fibonacci Example Program\n\n"
        .asciiz "Enter N Value: "

results: .asciiz "\nFibonacci of N = "

n:      .word 0
answer: .word 0

.text
.globl main
main:

# Read n value from user

    li		$v0, 4		# #v0 = 4
    la		$a0, prompt		# 
    syscall

    li		$v0, 5		# $v0 = 5
    syscall

    sw		$v0, n		
    
    #call fibo func
    lw      $a0, n
    jal		fib				# jump to fibo and save position to $ra
    
    sw      $v0, answer

    #display
    li      $v0, 4
    la		$a0, results	
    syscall

    li      $v0, 1
    lw      $a0, answer
    syscall

    li  $v0, 10
    syscall
.end main

.globl fib
.ent fib
fib:
    subu $sp, $sp, 8
    sw  $ra, ($sp)
    sw  $s0, 4($sp)

    move $v0, $a0
    ble $a0, 1, fibDone

    move $s0, $a0
    sub $a0, $a0, 1
    jal fib

    move $a0, $s0
    sub $a0, $a0, 2
    move $s0, $v0
    jal fib

    add $v0, $s0, $v0

fibDone:
    lw  $ra, ($sp)
    lw  $s0, 4($sp)
    addu $sp, $sp, 8
    jr  $ra
.end fib