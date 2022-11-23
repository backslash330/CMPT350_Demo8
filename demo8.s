# Nicholas Almeida
# 200385

.data 	
	id_prompt: .asciiz "Enter your ID Number: "
	name_length_prompt: .asciiz "Enter the length of your name: "
	name_prompt: .asciiz "Enter your name: "
	hexchars: .ascii "0123456789ABCDEF"
	node_address_message: .asciiz "Node Address: "
	id_message: .asciiz "Your ID Number is: "
	name_message: .asciiz "Your name is: "
	name_address_message: .asciiz "Name Address: "
	next_address_message: .asciiz "Next Address: "
	nl: .asciiz "\n"
.text

# The printaddrashex function converts the provided integer argument into 
# a fixed-width 8 character hexadecimal string, prints the string, and returns the address of the created string.
#
# Parameters
# ----------
#  $a0 - the value to convert to hexadecimal
#
# Return
# ------
#  Returns the address of the 8byte memory space allocated to hold the hex string in $v0
#
# !! WARNING !!
# This function destructively modifies the following registers:
# - $t0
# - $a0
# - $v0
# - $t1
# - $t2
# - $t3
# - $t4
# - $t5
# - $t6
# - $t7
# - $t8


printaddrashex:
	move $t0, $a0
	
	#allocate memory for the hex string
	li $a0, 8
	li $v0, 9
	syscall

	move $t1, $v0

	#initialize the memory in the string to be all zeros
	li $t2, 48		
	li $t3, 8
	move $t4, $t1

pah_initloop:
	beq $t3, $zero, pah_writehex
	sb $t2, 0($t4)
	addi $t4, $t4, 1
	sub $t3, $t3, 1
	j pah_initloop

pah_writehex:
	li $t2, 16
	li $t3, 8
	move $t4, $t1
	
pah_writehexloop:
	beq $t3, $zero, pah_revstr
	#compute the remainder of the value
	rem $t5, $t0, $t2
	#load the appropriate byte from the hexchar string
	la $t6, hexchars
	add $t6, $t6, $t5
	lb $t7, 0($t6)
	#store the character in the allocated memory
	sb $t7, 0($t4)
	addi $t4, $t4, 1
	
	#reduce $t0
	div $t0, $t0, $t2	
	#decrement the loop counter
	sub $t3, $t3, 1
	j pah_writehexloop

pah_revstr:
	li $t2, 8
	li $t3, 4
	move $t4, $t1
pah_revstrloop:
	beq $t3, $zero, pah_cleanup
	#swap mirrored characters ((0,7), (1,6), (2,5), or (3,4))
	#compute the large index to swap
	addi $t5, $t3, 3
	#compute the small index	
	sub $t6, $t2, $t5
	sub $t6, $t6, 1
	#load the two bytes into registers
	add $t6, $t4, $t6
	add $t5, $t4, $t5
	#store the chars in a temp register
	lb $t7, 0($t5)
	lb $t8, 0($t6)
	#write the chars to opposite positions
	sb $t7, 0($t6)
 	sb $t8, 0($t5)
	#subtract 1 from $t3
	sub $t3, $t3, 1
	j pah_revstrloop
		
pah_cleanup:
	#print the string
	move $a0, $t1
	li $v0, 4
	syscall

	move $v0, $t1
	jr $ra


#####################
# Main starts here  #
#####################
main:
	# prompt the user for their ID number
	la $a0, id_prompt
	li $v0, 4
	syscall

	# read the ID number
	li $v0, 5
	syscall

	# store it in s0
	move $s0, $v0

	# prompt the user for the length of their name
	la $a0, name_length_prompt
	li $v0, 4
	syscall

	# read the length of the name
	li $v0, 5
	syscall

	# store it in s1
	addi $v0, $v0, 1
	move $s1, $v0

	# allocate an appropriate amount of memory dynamically
	# to store the name using the value os s1
	move $a0, $s1
	li $v0, 9
	syscall

	# store the address of the allocated memory in s2
	move $s2, $v0

	# prompt the user for their name
	la $a0, name_prompt
	li $v0, 4
	syscall

	# read the name into the allocated memory
	move $a0, $s2
	move $a1, $s1
	li $v0, 8
	syscall

	# # print a newline
	# la $a0, nl
	# li $v0, 4
	# syscall

	# Dynamically allocate enough memory to hold one linked list node. The node holds 
	# o The value of the user’s id 
	# o The address of the memory location which holds the user’s name 
	# o The address of the next node in the linked list. Since this is the only node for this 
	#     assignment, this value should be set to zero (a.k.a the “null” address

	# allocate memory for the node
	li $a0, 12
	li $v0, 9
	syscall

	# store the address of the allocated memory in s3
	move $s3, $v0

	# store the id in the first 4 bytes of the node
	sw $s0, 0($s3)

	# store the address of the name in the next 4 bytes of the node
	sw $s2, 4($s3)

	# store the address of the next node in the last 4 bytes of the node
	li $t0, 0
	sw $t0, 8($s3)

	# Print out the address of the node, the id, the name and the address of the name, and the 
	# address of the next node.

	# print the node address
	la $a0, node_address_message
	li $v0, 4
	syscall

	# get the node address using the printaddrashex function
	# use $s3 as the argument	
	move $a0, $s3
	jal printaddrashex

	# save the address of the hex string in $s4
	move $s4, $v0

	# print a newline 
	la $a0, nl
	li $v0, 4
	syscall

	# print the id message
	la $a0, id_message
	li $v0, 4
	syscall

	# print the id from	the node
	lw $t0, 0($s3)
	move $a0, $t0
	li $v0, 1
	syscall

	# print a newline 
	la $a0, nl
	li $v0, 4
	syscall

	# print the name message
	la $a0, name_message
	li $v0, 4
	syscall

	# print the name from the node
	lw $t0, 4($s3)
	move $a0, $t0
	li $v0, 4
	syscall

	# print a newline 
	la $a0, nl
	li $v0, 4
	syscall

	# print the name address message
	la $a0, name_address_message
	li $v0, 4
	syscall

	# print the name address from the node
	la $t0, 4($s3)
	move $a0, $t0
	jal printaddrashex

	# print a newline 
	la $a0, nl
	li $v0, 4
	syscall

	# print the next node message
	la $a0, next_address_message
	li $v0, 4
	syscall

	# print the next node address from the node
	lw $t0, 8($s3)
	move $a0, $t0
	jal printaddrashex

	# print a newline 
	la $a0, nl
	li $v0, 4
	syscall

	li $v0, 10
	syscall
