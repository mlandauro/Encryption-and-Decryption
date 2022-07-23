# CS2340_Asg6_MXL190030.asm 
# program that encrypts and decrypts files
# Author: Micaela Landauro
# 4/25/22 - 4/27/22

.include "SysCalls.asm"

.data
menuMsg: .asciiz "1: Encrypt the file\n2: Decrypt the file\n3: Exit\n\n"
selectMsg: .asciiz "Select an option: "
getFileMsg: .asciiz "Enter a File name: "
error: 	.asciiz "File could not be opened\n"
keyErrorMsg: .asciiz "Key length must be greater than 0\n\n"
getKeyMsg: .asciiz "Enter the key: "

txtExtension: .asciiz "txt"
encExtension: .asciiz "enc"

filename: .space 50 # buffer for filename
outputFile: .space 50 # buffer for output file
key: .space 60 # encryption/decryption key
readBuffer: .space 1024 #read 1024 bytes from file
writeBuffer: .space 1024 #buffer where to store encrypted contents

# REGISTERS
# $s0 >> user option
# $s1 >> input file descriptor
# $s2 >> output file descriptor
# $s3 >> key length (does NOT include new line char)

.text
# display menu for user
#reset:
#	move $t6, $0
#	move $t7, $0
#	move $t4, $0
#	move $t5, $0

menu:
	jal reset
	
	la $a0, menuMsg		# message to display
	jal printString
	
	la $a0, selectMsg		# prompt user to select option
	jal printString
	
	li $v0, SysReadInt		# read user input from keyboard
	syscall
	
	move $s0, $v0		# store user input in $s0

	beq $s0, 3, exit		# user wants to exit
	
getFile:
	la $a0, getFileMsg		# prompt user for a filename
	jal printString
	
	la $a0, filename		# get fileName from user
	li $a1, 50
	jal getString

# subroutine to replace new line terminitaing char with null terminating char
removeNewLine:
	lb $a3, filename($t7)	# load char at index
	addi $t7, $t7, 1		# increment pointer
	bnez $a3, removeNewLine	# loop until end of string
	beq $a1, $t7, openFile	# if string is max length dont remove \n
	subiu $t7, $t7, 2		# backtrack to new line index
	sb $0, filename($t7)	# add terminating char in place

openFile: 
	la $a0,filename		# load in address of filename
	li $a1, 0			# flags
	li $a2, 0			# mode
	li $v0, SysOpenFile
	syscall
	
	bltz $v0, fileError		# if file descriptor negative file couldn't be opened
	
	move $s1, $v0		# store file descriptor for later use in $s1
	
	li $t4, '.'		# store '.'
	move $t7, $0		# reset 7

extension:			# check appropriate extension and create appropriate output file
	lb $a3, filename($t6)
	sb $a3, outputFile($t7)
	addi $t6, $t6, 1		# increment counters
	addi $t7, $t7, 1		# increment counters
	
	bne $t4, $a3, extension		# if not equal to period
	
	li $t4, '\0'	# load null char
	move $t6, $0
	beq $s0, 1, outFile	# if encrypting, create output file, otherwise create inputfile

inFile:
	lb $a3, txtExtension($t6)	# get extension char
	sb $a3, outputFile($t7)		# copy extension char
	addi $t7, $t7, 1		# increment counters
	addi $t6, $t6, 1
	bne $t4, $a3, inFile		# while null char has not been reached
	
	j getKey
		
outFile:
	lb $a3, encExtension($t6)	#get extension char
	sb $a3, outputFile($t7)		# copy extension char
	addi $t7, $t7, 1		# increment counters
	addi $t6, $t6, 1
	bne $t4, $a3, outFile		# while null char has not been reached
	
getKey:
	la $a0, getKeyMsg		# prompt user for key
	jal printString
	
	la $a0, key		# read in key from user
	li $a1, 60
	jal getString
	
	# check if zero length
	lb $t1, key($t0) 		# get first char of string
	li $t2, '\n'
	beq $t2, $t1, keyError	# if first char is newline, jump to menu
	
	move $t0, $0		# reset $t0
	
	# get key length
keyLength:
	lb $t1, key($t0)
	addi $t0, $t0, 1		# increment index
	addi $s3, $s3, 1		# increment key length
	bne $t2, $t1, keyLength		# check if newline
	
	subi $s3, $s3, 1 		# remove newline from length
	
#	beq $s0, 2, decrypt		# go to appropriate option
	
openOutput:
	
	# open file
	la $a0,outputFile		# load in address of filename
	li $a1, 1			# flags
	li $a2, 0			# mode
	li $v0, SysOpenFile
	syscall
	
	bltz $v0, fileError		# if file descriptor negative file couldn't be opened
	
	move $s2, $v0			# output fd in $s2

read:	
	#read from input file
	move $a0, $s1			# move file descriptor
	la $a1, readBuffer		# where to read to
	li $a2, 1024			# how much to read
	li $v0, SysReadFile
	syscall
	
	beq $v0, 0, done		# 0 chars read, close and return
	
	move $t5, $0
	move $t6, $0		# reset register indeces
	move $t7, $0

# begin algorithm
algorithm:
	beq $t6, $v0, write		# if reached end of buffer
	bne $s3, $t7, cont		# check if reached end of key
	
	move $t7, $0			# reset key index
	
cont:	
	lb $a3, readBuffer($t6)		# get char from buffer
	lb $a2, key($t7)
	
	beq $s0, 2, subAlg		# for decryption subtract
	
	addu $a3, $a3, $a2		# add for encryption
	j cont2
	
subAlg:
	subu $a3, $a3, $a2		# subtract for decryption

cont2:
	sb $a3, writeBuffer($t5)		# add to outputFile
	
	addi $t6 $t6, 1
	addi $t7, $t7, 1
	addi $t5, $t5, 1
	
	j algorithm
	
write:
	# write to output file
	move $a0, $s2		# get fd
	la $a1, writeBuffer	# output buffer address
	li $a2, 1024		# num of chars to write
	li $v0, SysWriteFile	
	syscall
	
	j read


done: 
	move $a0, $s1
	li $v0, SysCloseFile
	syscall
	
	move $a0, $s2
	li $v0, SysCloseFile
	syscall
	
	j menu

fileError:
	la $a0, error		# load address of error message
	jal printString
	
	j menu		# jump back to menu
	
keyError:
	la $a0, keyErrorMsg		# load address of error message
	jal printString
	
	j menu		# jump back to menu

exit:
	li $v0, SysExit
	syscall
	
	
	
	
	
