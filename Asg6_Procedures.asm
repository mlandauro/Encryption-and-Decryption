# Asg6_Procedures.asm 
# functions for Asg6
# Author: Micaela Landauro
# 4/25/22 - 4/27/22

.include "SysCalls.asm"

.text

.globl reset
.globl printString
.globl getString

reset:
	move $t6, $0		# reset temp registers
	move $t7, $0
	move $t4, $0
	move $t5, $0
	
	jr $ra			# return
	
printString:
	li $v0, SysPrintString	# print prompted message
	syscall
	jr $ra			# return to main
	
getString:
	li $v0, SysReadString	# read in string from keyboard
	syscall
	jr $ra
