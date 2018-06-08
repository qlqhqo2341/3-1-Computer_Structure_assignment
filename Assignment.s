# 2014920037 LeeJeongHan NearestNeighborhood Assignment

    .data
read_file:      .asciiz "C:/Users/qlqhq/Desktop/mips_input.txt"
read_buffer:    .space 524288
read_pointer:     .word 0
read_pointer_limit: .word 0
rootNode:       .word 0

guideStr:   .ascii "Input query point like 1 3 Then enter\n"
            .ascii "If you want to quit : press q, enter\n"
guideNextStr: .asciiz "\nQueryPoint : "
querySpace : .word -1 -1

# Node structure
# .word x, .word y .word leftPointer, .word rightPointer

    .text
    .globl main
main:
    jal initialize
    jal insertSegment
    jal query
    jr Exit
    
#read file
initialize:
    #Get file discripter
    li $v0,13
    la $a0,read_file
    li $a1,0
    li $a2,0
    syscall

    #Only read 524288byte.
    move $s6,$v0 #save file discripter
    #Read file
    li $v0,14
    move $a0,$s6
    la $a1,read_buffer
    li $a2,524288
    syscall

    move $t0, $v0 # move buffer_length read
    add $t0,$t0,$a1 # $t0 = read_pointer + buffer_length
    sw $t0, read_pointer_limit
    sw $a1,read_pointer # init read_pointer to begin of read_buffer 
	
    #Close File
    li $v0,16
    move $a0,$s6
    syscall
    
    jr $ra

getPoint:
    subu $sp, $sp, 4 # start of getPoint
    sw $ra,($sp)
    
	lw $s6, read_pointer
    lw $s5, read_pointer_limit
    	
	li $s0,0
	li $s1,0
	li $s2,1
    li $t1,1 # s1 sign
    li $t2,1 # s2 sign
	#s2 => 1:s1 sum, 0:s2 sum
    
readNextChar:
    #read Pointer check
    ble $s5,$s6,getPointSetNull  # start of readNextChar

    #read
    lbu $t0,($s6)
    addi $s6,$s6,1
    
    beq $t0,0x0a,getPointDone #If char is enter, jump Done
    beq $t0,0x20,getPointswitch #If char is space, switch
    beq $t0,0x2D,getPointSetSign #If char is -, set sign bit
    
addNum:
    blt $t0,0x30,readNextChar #check digit.
    bgt $t0,0x39,readNextChar
    subu $t0,$t0,0x30
    beq $s2,0,getPointSetY
getPointSetX:
    mul $s0,$s0,10
    add $s0,$s0,$t0
    j readNextChar
getPointSetY:   
    mul $s1,$s1,10
    add $s1,$s1,$t0
    j readNextChar
    
getPointSetNull:
    bne $s2,1,getPointDone
    li $s2,-1
    j getPointDone

getPointDone:
    mul $v0,$s0,$t1
    mul $v1,$s1,$t2
	sw $s6,read_pointer
    lw $ra,($sp)
    addu $sp,$sp,4
	jr $ra
getPointswitch:
    li $s2,0
    j readNextChar
getPointSetSign:
    bne $s2,1,getPointSetSignY
    li $t1,-1
    j readNextChar
getPointSetSignY:
    li $t2,-1
    j readNextChar
insertSegment:
    subu $sp,$sp,12
    sw $ra,8($sp)
    
insertNextNode:
    jal getPoint
    beq $s2,-1,insertSegmentDone
    sw $v0,($sp)
    sw $v1,4($sp)
    
    li $t7,4 # x,y switch var, 0:x, 4:y
    li $t1,0 # address of slot in parent's node.
    lw $t0,rootNode
    
    beq $t0,0,insertRoot
    
insertFindNode:
    xor $t7,$t7,4 # start of insertFindNode, $t7 switch.
    
    # get vaule of now node
    add $t6,$t7,$t0
    lw $t5,($t6)

    # get value of new node
    add $t6,$t7,$sp
    lw $t4,($t6)
    
    sge $t1,$t4,$t5 # $t1 = (newNode->(x,y) >= nowNode-> (x,y)
    #check null Pointer
    mul $t1,$t1,4
    add $t1,$t1,8
    add $t1,$t1,$t0
    
    lw $t6,($t1)
    beq $t6,0,insertAddNode # Found slot in parent's node
    move $t0,$t6
    j insertFindNode
    
insertAddNode:
    li $v0,9 # start of insertAddNode
    li $a0,16
    syscall
    
    lw $s0,($sp)
    lw $s1,4($sp)

    sw $s0,($v0)
    sw $s1,4($v0)
    sw $zero,8($v0)
    sw $zero,12($v0)

    sw $v0,($t1)
    j insertNextNode
    
insertRoot:
    li $v0,9 # start of insert Root
    li $a0,16 # malloc 4*word size
    syscall
    
    lw $s0,($sp)
    lw $s1,4($sp)

    sw $s0,($v0)
    sw $s1,4($v0)
    sw $zero,8($v0)
    sw $zero,12($v0)

    sw $v0,rootNode
    j insertNextNode
    
insertSegmentDone:
    lw $ra,8($sp)
    addu $sp,$sp,12
    jr $ra
    
query:
    subu $sp,$sp,4
    sw $ra,($sp)

    #print guide string
    li $v0, 4
    la $a0, guideStr
    syscall

queryNext:
    # Read String
    li $v0,8
    la $a0,read_buffer
    li $a1,1024
    syscall

    lbu $t0,($a0)
    beq $t0,0x71,queryDone # if enter q,query exit.
    
    sw $a0,read_pointer
    add $a0,$a0,1024
    sw $a0,read_pointer_limit

    jal getPoint

    la $t0,querySpace
    sw $v0,($t0)
    sw $v1,4($t0)

    lw $a0,rootNode
    li $a1,0
    jal getNeighbor
    move $t0,$v0

# ($t0) is nearest node.
queryFound:
    #print x
    li $v0,1
    lw $a0,($t0)
    syscall

    #print space
    li $v0,11
    li $a0,0x20
    syscall

    #print y
    li $v0,1
    lw $a0,4($t0)
    syscall

    #print nextGuideStr
    li $v0,4
    la $a0,guideNextStr
    syscall
    j queryNext
    
queryDone:
    lw $ra,($sp)
    addu $sp,$sp,4
    jr $ra

#Traversal from rootnode($a0) to leafnode.
#compare lavel of rootnode : ($a1), 0:x, 4:y,
#query point x, y in querySpace
#and follow path backward.
getNeighbor:
    # store $ra
    subu $sp,$sp,4
    sw $ra,($sp)

    move $t0,$a0
    move $t7,$a1
    xor $t7,$t7,4 # before enter traversal, Need to be switch.
    la $v0,querySpace # $v0 is pointer to query point x,y

getNeighborTraversal:
    xor $t7,$t7,4
    # get value of NowNode
    add $t6,$t7,$t0
    lw $t5,($t6)

    # get value of query point
    add $t6,$t7,$v0
    lw $t4,($t6)

    sge $t1,$t4,$t5 # $t1 = (qur->(x,y) >= now->(x,y))
    mul $t1,$t1,4
    add $t1,$t1,8
    add $t1,$t1,$t0

    lw $t2,($t1)
    beq $t2,$zero,getNeighborTraversalLeaf

    # store tree traversal path.    
    subu $sp,$sp,4
    sw $t0,($sp)

    move $t0,$t2
    j getNeighborTraversal
    
getNeighborTraversalLeaf:
    move $s0,$t0 # current nearest node
    move $s1,$a0 # current root node.
    move $s2,$t0 # current node., $s3 is child's node.
    move $s7,$t7 # switch x,y
    
    move $a0,$t0
    jal getDistanceQuery
    move $s6,$v0 # current nearest distance!!
    
getNeighborReverse:
    xor $s7,$s7,4

    beq $s1,$s2,getNeighborDone # if approach root. Done
    
    move $s3,$s2 # preserve child's node
    lw $s2,($sp) # get parent's node
    addu $sp,$sp,4
    
    # intersection check.
    add $t0, $s7, $s2 
    lw $t0,($t0) # load parent's node compare var

    la $t1,querySpace
    add $t1, $s7, $t1
    lw $t1,($t1)

    sub $t0,$t0,$t1
 #   abs $t0,$t0 # distance between parent's node wall and query point.
    mul $t0,$t0,$t0

    blt $s6,$t0,getNeighborReverse

    #compare nearest and parent's node
    move $a0,$s2
    jal getDistanceQuery
    slt $t0,$v0,$s6
    beq $t0,$zero,getNeighborReverseCheckAnotherBranch
    
    #update nearest node
    move $s6,$v0
    move $s0,$s2

getNeighborReverseCheckAnotherBranch:
    #find another branch.
    lw $t0,8($s2)
    seq $t0, $s3, $t0 # if child is left branch, set 1(*4) => right branch
    mul $t0,$t0,4
    add $t0,$t0,8
    add $t0,$t0,$s2
    lw $t0,($t0) # get another branch node.
    beq $t0,$zero,getNeighborReverse # If it is null. next loop.
    
    subu $sp,$sp,24
    sw $s0,($sp)
    sw $s1,4($sp)
    sw $s2,8($sp)
    sw $s3,12($sp)
    sw $s6,16($sp)
    sw $s7,20($sp)
    
    move $a0,$t0 # root is another branch node.
    move $a1,$s7 # current switch var.
    jal getNeighbor
    lw $s0,($sp)
    lw $s1,4($sp)
    lw $s2,8($sp)
    lw $s3,12($sp)
    lw $s6,16($sp)
    lw $s7,20($sp)
    addu $sp,$sp,24

    move $s5,$v0 # candidate nearest node.
    move $a0,$s5
    jal getDistanceQuery
    slt $t0,$v0,$s6 # comapre another branch nearest node and now nearest
    beq $t0,$zero,getNeighborReverse

    #update current nearest node
    move $s6,$v0
    move $s0,$s5
    j getNeighborReverse

getNeighborDone:
    move $v0,$s0
    lw $ra,($sp)
    addu $sp,$sp,4
    jr $ra

getDistanceQuery:
    subu $sp,$sp,4
    sw $ra,($sp)

    la $t1,querySpace
    lw $t0,($t1)
    lw $t1,4($t1)
    
    lw $t2,($a0)
    lw $t3,4($a0)

    sub $t0,$t0,$t2
    sub $t1,$t1,$t3

    mul $t0,$t0,$t0
    mul $t1,$t1,$t1

    add $v0,$t0,$t1

    lw $ra,($sp)
    addu $sp,$sp,4
    jr $ra

    
Exit:
    li $v0,10
    syscall