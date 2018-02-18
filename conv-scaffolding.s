.text

conv:

addi $sp, $sp, -28       # save registers on stack
sw   $ra, 0($sp)
sw   $s0, 4($sp)
sw   $s1, 8($sp)
sw   $s2, 12($sp)
sw   $s3, 16($sp)
sw   $s4, 20($sp)
sw   $s5, 24($sp)

move $s0, $a0          # s0 = pointer to image 
move $s5, $a2
lw   $s1, 0($s0)       # s1 = N
move $s2, $s1          # s2 = N 
move $s4, $a1          # s4 = pointer to kernel
addi $s0, $s0, 4       # advance pointer to first pixel

advance:
addi $s0, $s0, 3       # Move one pixels
addi $s2, $s2, -1      # decrement s2
beqz $s2, start        # if s2 == 0 move on to start

b advance		# repeat 


start:

addi $s0, $s0, 3        # skip first pixel
addi $s2, $s1, -2       # s2 = Columns left (N-2)
add  $s3, $s2, $zero     # s3 = Rows left (N-2)
sw   $s2, 0($s5)
addi $s5, $s5, 4


row:

beqz $s2, next_row	 # if no more columns go to next row
move $a0, $s0		 # a0 = pointer to position
move $a1, $s4		 # a1 = pointer to kernel
move $a2, $s1		 # a2 = N  


jal  pixel
sb   $v0, 0($s5)	 #save output	
 		
addi $s0, $s0, 1	#set up argument	 
move $a0, $s0
		
jal pixel
sb   $v0, 1($s5)	 #save output

addi $s0, $s0, 1	#set up argument
move $a0, $s0

jal pixel  
sb   $v0, 2($s5)	 #save output

addi $s5, $s5, 3  	
addi $s2, $s2, -1       # decrement Columns LEFT
addi $s0, $s0, 1	#set up argument

b row


next_row:

addi $s3, $s3, -1       # decrement Rows LEFT
beqz $s3, end
addi $s0, $s0,  6       # skip first the next 2 pixels
add  $s2, $s1, -2           # s2 is set back
b row


pixel:
move $t0, $a0
addi $t1, $zero,  3     # t1 = 3
mult $t1, $a2		 
mflo $t2                # t2 = 3N
add  $t2, $t1, $t2      # t2 = 3N + 3

sub  $t0, $t0, $t2      # t0 = pos - (3N + 3)
lb   $t1, 0($a1)        # t1 = a
lbu  $t3, 0($t0)	 # t3 = &pos
mult $t3, $t1		 # &pos * a 
mflo $t4                # t4 = addition of all

addi $t0, $t0, 3        #t0 = pos - (3N)
lb   $t1, 1($a1)        #t1 = b
lbu  $t3  0($t0)	 
mult $t3, $t1
mflo $t1
add  $t4, $t4, $t1

addi $t0, $t0, 3         #t0 = pos - (3N) + 3
lb   $t1, 2($a1)         #t1 = c
lbu  $t3, 0($t0)
mult $t3, $t1
mflo $t1
add  $t4, $t4, $t1

move $t0 $a0             #reset t0

add $t0, $t0, -3        #t0 = pos - 3
lb   $t1, 3($a1)         #t1 = d
lbu  $t3, 0($t0)
mult $t3, $t1
mflo $t1
add  $t4, $t4, $t1

addi $t0, $t0, 3         #t0 = pos
lb   $t1, 4($a1)         #t1 = e
lbu  $t3, 0($t0)
mult $t3, $t1
mflo $t1
add  $t4, $t4, $t1

addi $t0, $t0, 3         #t0 = pos + 3
lb   $t1, 5($a1)         #t1 = f
lbu  $t3, 0($t0)
mult $t3, $t1
mflo $t1
add  $t4, $t4, $t1

move $t0 $a0            #reset t0

add  $t0, $t0, $t2
addi $t0, $t0, -6       #t0 = pos + (3N) - 3
lb   $t1, 6($a1)        #t1 = g
lbu   $t3,  0($t0)
mult $t3, $t1
mflo $t1                #t4 = addition of all
add  $t4, $t4, $t1

addi $t0, $t0, 3        #t0 = pos + (3N)
lb   $t1, 7($a1)        #t1 = h
lbu  $t3  0($t0)
mult $t3, $t1
mflo $t1
add  $t4, $t4, $t1

addi $t0, $t0, 3        #t0 = pos + (3N) + 3
lb  $t1, 8($a1)        #t1 = i
lbu   $t3  0($t0)
mult $t3, $t1
mflo $t1
add  $t4, $t4, $t1
move $v0, $t4          # write t4 to the return value 


jr $ra


end:

lw   $ra, 0($sp)
lw   $s0, 4($sp)
lw   $s1, 8($sp)
lw   $s2, 12($sp)
lw   $s3, 16($sp)
lw   $s4, 20($sp)
lw   $s5, 24($sp)
addi $sp, $sp, 28
jr $ra


#################################################################################
## Your complete implementation solution should appear above this separator.
#################################################################################


main:

	addi $sp, $sp, -4
	sw $ra, 0($sp)

##      Some initial test code.  Substitute your own as needed.
##	
	la $a0, tiny
	la $a1, emboss
	la $a2, tiny_out
	jal conv
	la $a0, tiny_out
	jal print_ppm

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
print_int:
	# a0: integer to print
	li $v0, 1
	syscall
	jr $ra

print_newline:
 	li $v0, 11
 	li $a0, 10
 	syscall
	jr $ra
	
print_space:
	li $a0, 32
	li $v0, 11
	syscall
	jr $ra

print_kernel:
	# a0: pointer to kernel
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s0, 4($sp)

	move $s0, $a0  # s0 = pointer to kernel
	
	lb $a0, 0($s0)
	jal print_int
	jal print_space

	lb $a0, 1($s0)
	jal print_int
	jal print_space

	lb $a0, 2($s0)
	jal print_int
	jal print_newline

	lb $a0, 3($s0)
	jal print_int
	jal print_space

	lb $a0, 4($s0)
	jal print_int
	jal print_space

	lb $a0, 5($s0)
	jal print_int
	jal print_newline

	lb $a0, 6($s0)
	jal print_int
	jal print_space

	lb $a0, 7($s0)
	jal print_int
	jal print_space

	lb $a0, 8($s0)
	jal print_int
	jal print_newline
	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	
	
print_ppm:
	# a0: pointer to image in memory
	addi $sp, $sp, -4
	sw   $ra, 0($sp)
	
	move $t0, $a0          # t0 = pointer to image
	lw   $t1, 0($t0)       # t1 = N 

	li $a0, 80    # print P
	li $v0, 11
	syscall
	li $a0, 51    # print 3
	li $v0, 11
	syscall
	li $a0, 10    # print newline
	li $v0, 11
	syscall

	move $a0, $t1  # print N
	li $v0, 1
	syscall
	li $a0, 32     # print space
	li $v0, 11
	syscall
	move $a0, $t1  # print N
	li $v0, 1
	syscall
	li $a0, 10     # print newline
	li $v0, 11
	syscall

	li $a0, 255    # print 255
	li $v0, 1
	syscall
	li $a0, 10     # print newline
	li $v0, 11
	syscall

	addi $t0, $t0, 4    # advance pointer to first pixel
	move $t2, $t1       # t2 = rows to go

print_ppm__start_row:	
	beqz $t2, print_ppm__image_done

	move $t3, $t1       # t3 = cols to go
print_ppm__start_pixel:	
	beqz $t3, print_ppm__row_done   # check if row done
	
	lbu $a0, 0($t0) # print R
	li $v0, 1
	syscall
	li $a0, 32     # print space
	li $v0, 11
	syscall
	lbu $a0, 1($t0) # print G
	li $v0, 1
	syscall
	li $a0, 32     # print space
	li $v0, 11
	syscall
	lbu $a0, 2($t0) # print B
	li $v0, 1
	syscall
	li $a0, 32     # print space
	li $v0, 11
	syscall

	addi $t0, $t0, 3  # advance pointer
	addi $t3, $t3, -1 # decrement cols to go
	b print_ppm__start_pixel

print_ppm__row_done:
	li $a0, 10   # print newline
	li $v0, 11
	syscall
	addi $t2, $t2, -1  # decrement rows to go
	b print_ppm__start_row

print_ppm__image_done:
	lw   $ra, 0($sp)
	addi $sp, $sp, 4	
	jr $ra

.data

tiny:
	.word 4
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 255, 0, 0, 0, 0, 255, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 128, 0, 0, 0,	255, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0

tiny_out:	.space 16

identity:	.byte 0, 0, 0, 0, 1, 0, 0, 0, 0
sharpen:        .byte 0, -1, 0, -1, 5, -1, 0, -1, 0
emboss:         .byte -2, -1, 0, -1, 1, 1, 0, 1, 2
outline:        .byte -1, -1, -1, -1, 8, -1, -1, -1, -1
left_sobel:     .byte 1, 0, -1, 2, 0, -2, 1, 0, -1

