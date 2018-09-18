##### Authors: Rembler Group (Lan Vu, Tung Vu, Keyur Savjani, Roman Chernov).
##### File: rembler_reversi.asm
##### MIPS reversi game implementation.
##### Bitmap Display settings: unit 4 x 4, display 1024 x 1024 or
##### unit 2 x 2, display 512 x 512.

.data
frameBuffer: 	.space 	0x80000
array1: 	.space 	20			# array for move assigned number
array2: 	.space 	68			# array for move assigned number
array3: 	.space 	52			# array for move assigned number
array4: 	.space 	68			# array for move assigned number
mode: 		.space 	4			# game mode
validMoves: 	.space 	60 			
board: 		.space 	400			# update array functon use.
conv_buffer: 	.space 	20
userName1: 	.space 	50			# player's 1 name.
userName2: 	.space 	50			# player's 2 name.
ua_list: 	.word 	4, -4, 36, -36, 40, -40, 44, -44		# possible moves.
lo_letters: 	.byte 	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'
hi_letters: 	.byte 	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'
validprompt: 	.asciiz "\nvalid moves: "
endgame: 	.asciiz "\nGame ended, thank you for playing!"
gamecon: 	.asciiz "\ncontinue the game, get input or select best move"
prompt: 	.asciiz "\nEnter move position or 0 to end game, "
newline:	.asciiz	"\n"
colon: 		.asciiz ": " 
multi: 		.asciiz "\nMultiplayer mode, enter 1 for yes or any other number for no (69 for COM vs COM): "
again: 		.asciiz "\nPlay again, enter 1 for yes or any other number for no: "
invalid: 	.asciiz "\nYou must create >= 1 straight occupied line between the new piece and another piece, with >= 1 contiguous pieces of the other color between them."
conv_output1:	.asciiz "Incorrect input format! * A1 - H8 *"
conv_output2:	.asciiz "Incorrect input range! * A-H and 1-8 *"
win:  		.asciiz "\b wins with score (out of 64): "
comWin: 	.asciiz "\nComputer wins with score (out of 64): "
gameDraw: 	.asciiz "\nGame draw."
time: 		.asciiz "\nTotal time played is: "
name1: 		.asciiz "Enter player 1 name: "
name2: 		.asciiz "Enter player 2 name: "
minute: 	.asciiz "\b minutes "
second:		.asciiz "\b seconds."
.text
##### game start, initial $s3 = 6 (Black), $s6 = 6, $s7 = 9.
main:

##### Array initialization.
	# fill out an array with initial 0:
	addiu $t5, $0, 0			# Set $t5 to 0.
	addiu $t6, $0, 0			# Set $t6 to 0.
label1:
	beq $t5, 400, out1			# iterrate trough each cell.
	sw $t6, board($t5)			# set all array cells to 0.
	addi $t5, $t5, 4			# increment counter.
	j label1				# jump to label.
out1:	
	# fill out border fields with 1:
	addiu $t5, $0, 0			# Set $t5 to 0.
	addiu $t6, $0, 1			# Set $t6 to 1.
label2:	
	beq $t5, 40, out2			# iterrate trough left border.
	sw $t6, board($t5)			# set left border to 1.
	addi $t5, $t5, 4			# increment counter.
	j label2				# jump to label.
out2:
	addiu $t5, $0, 0			# Set $t5 to 0.
	addiu $t6, $0, 1			# Set $t6 to 1.
label3:			
	beq $t5, 400, out3			# iterrate trough upper border.
	sw $t6, board($t5)			# set upper border to 1.
	addi $t5, $t5, 40			# increment counter.
	j label3				# jump to label.
out3:
	addiu $t5, $0, 36			# Set $t5 to 36.
	addiu $t6, $0, 1			# Set $t6 to 1.
label4:			
	beq $t5, 436, out4			# iterrate trough lower border.
	sw $t6, board($t5)			# set lower border to 1.
	addi $t5, $t5,40			# increment counter.
	j label4				# jump to label.
out4:
	addiu $t5, $0, 360			# Set $t5 to 360.
	addiu $t6, $0, 1			# Set $t6 to 1.
label5:			
	beq $t5, 400, out5			# iterrate trough right border.
	sw $t6, board($t5)			# set right border to 1.
	addi $t5, $t5, 4			# increment counter.
	j label5				# jump to label.
out5:
	# apply initial disk positions:
	addiu $t5, $0, 176			# Set $t5 to 176.
	addiu $t6, $0, 9			# Set $t6 to 9.
	sw $t6, board($t5)			# Store the value into the array.
	addiu $t5, $0, 220			# Set $t5 to 220.
	addiu $t6, $0, 9			# Set $t6 to 9.
	sw $t6, board($t5)			# Store the value into the array.
	addiu $t5, $0, 216			# Set $t5 to 216.
	addiu $t6, $0, 6			# Set $t6 to 6.
	sw $t6, board($t5)			# Store the value into the array.
	addiu $t5, $0, 180			# Set $t5 to 180.
	addiu $t6, $0, 6			# Set $t6 to 6.
	sw $t6, board($t5)			# Store the value into the array.
	
##### Draw the board.
	jal DRAW				# call draw procedure.
	
##### Play startup sound.
	jal sound_game_start			# call game start sound procedure.

##### Ask for game mode: single or multi.
	la $a0, multi				# ask for multiplayer mode
	li $v0, 4
	syscall

	li $v0, 5				# get choice and store	
	syscall
	sw $v0, mode 

##### Ask for name.
	jal Name				# call name procedure.

##### Get system time.
	li $v0, 30 				# get system time - start time.
	syscall
	move $s1, $a0

##### Set color and constants.
	addiu $s6, $0, 6			# constant $s6 = 6.
	addiu $s7, $0, 9			# constant $s7 = 9.
	addiu $s3, $0, 9			# $s3 initialized to white.
	addiu $s5, $0, 0			# death counter, set to 0.
						# $s3 needs to be initialized to white so when it is passed.
						# to turnswitch for the 1st time it changes to black turn go 1st.
	
TURNSWITCH:
	jal turnSwitch				# call turn switch procedure.
	jal CHECKMOVE				# call check move procedure.
	jal sound_move_ok			# call sound move ok procedure.
	# valid move of human/computer is in $t1
	# now update array
	jal UPDATE 				# call array update procedure.
	jal DRAW				# call draw procedure.
	j TURNSWITCH				# call turn switch procedure.

##### Get player(s) name(s).
Name:
	# Preservation:
	addi $sp, $sp, -16 			# allocate stack space.
        sw  $a0, 0($sp)				
        sw  $a1, 4($sp)					
        sw  $v0, 8($sp)					
        sw  $t0, 12($sp)
        
        lw $t0, mode				# ask name 2 if multiplayer mode is on	
	beq $t0, 69, single
        															
	la $a0, name1				# asking for name 1
	li $v0, 4
	syscall

	li $v0, 8				# get name and store
	la $a0, userName1 
	li $a1, 50
	syscall

	lw $t0, mode				# ask name 2 if multiplayer mode is on	
	bne $t0, 1, single

	la $a0, name2				# asking for name 2
	li $v0, 4
	syscall

	li $v0, 8				# get name and store
	la $a0, userName2 
	li $a1, 50
	syscall
single:
	# Restoration:
        lw  $a0, 0($sp)
        lw  $a1, 4($sp)
        lw  $v0, 8($sp)
        lw  $t0, 12($sp)
    	addi $sp, $sp, 16			# free stack space.
	jr $ra

##### Check move.
CHECKMOVE:
	lw $t8, mode				# check if multiplayer mode is on
	beq $t8, 69, computer
	beq $s3, 6, convert_input		# check if turn for human
						# if not, select the best move for computer 

	lw $t8, mode				# check if multiplayer mode is on
	beq $t8, 1, convert_input
computer:
	la $t6, array1				# begin at the start of array
	li $t7, 1
	li $t8, 4
init1:						# initialize array from 1 
	beqz $t8, done1
	sw $t7, ($t6)
	addi $t7, $t7, 1
	addi $t6, $t6, 4			# move to next position in array
	addi $t8, $t8, -1
	j init1
done1:						# store 69 as endpoint of array
	li $t7, 69
	sw $t7, ($t6)

	la $t6, array2				# begin at the start of array
	li $t7, 1
	li $t8, 16
init2:						# initialize array from 1 
	beqz $t8, done2
	sw $t7, ($t6)
	addi $t7, $t7, 1
	addi $t6, $t6, 4			# move to next position in array
	addi $t8, $t8, -1
	j init2
done2:						# store 69 as endpoint of array
	li $t7, 69
	sw $t7, ($t6)

	la $t6, array3				# begin at the start of array
	li $t7, 1
	li $t8, 12
init3:						# initialize array from 1 
	beqz $t8, done3
	sw $t7, ($t6)
	addi $t7, $t7, 1
	addi $t6, $t6, 4			# move to next position in array
	addi $t8, $t8, -1
	j init3
done3:						# store 69 as endpoint of array
	li $t7, 69
	sw $t7, ($t6)

	la $t6, array4				# begin at the start of array
	li $t7, 1
	li $t8, 16
init4:						# initialize array from 1 
	beqz $t8, done4
	sw $t7, ($t6)
	addi $t7, $t7, 1
	addi $t6, $t6, 4			# move to next position in array
	addi $t8, $t8, -1
	j init4
done4:						# store 69 as endpoint of array
	li $t7, 69
	sw $t7, ($t6)
	
	
start1:
	li $t2, 0
	la $t4, array1				# begin at the start of array
check1:
	lw $t3, ($t4)			 	# calculate sum of all values in array except 69
	beq $t3, 69, test1 
	add $t2, $t2, $t3
	addi $t4, $t4, 4			# move to next position in array
	j check1
test1:
	beqz $t2, start2			# check if all numbers are used up in array 
	li $a1, 4
	li $v0, 42				# generate a random number
	syscall
	addi $a0, $a0, 1
	la $t4, array1				# begin at the start of array
delete1:
	lw $t3, ($t4)
	beq $t3, 69, start1 			# keep using number until the end of array
	beq $a0, $t3, erase1
	addi $t4, $t4, 4			# move to next position in array
	j delete1
erase1:						# assign each move with a number
	beq $a0, 1, m44
	beq $a0, 2, m72				# check move based on its assigned number
	beq $a0, 3, m324
	beq $a0, 4, m352			# check move based on its assigned number
cont1:
	sw $zero, ($t4)				# delete the used number from array
	j start1		
m44:						
	li $t5, 44				# load position of move and check for validity
	j run1
m72:
	li $t5, 72				# load position of move and check for validity
	j run1
m324:
	li $t5, 324				# load position of move and check for validity
	j run1
m352:
	li $t5, 352				# load position of move and check for validity
	j run1
run1:
	la $t0, validMoves			# begin at the start of array.
choose1:
	lw $t1, ($t0)				# examine a move.
	beq $t1, $t5, nextMove			# #1 priority.
	beq $t1, 0, cont1			# move to #2 priority selection if no move is selected.
	addi $t0, $t0, 4			# move to next position in array.
	j choose1
	
	
start2:
	li $t2, 0
	la $t4, array2				# begin at the start of array
check2:
	lw $t3, ($t4)			 	# calculate sum of all values in array except 69
	beq $t3, 69, test2 
	add $t2, $t2, $t3
	addi $t4, $t4, 4			# move to next position in array
	j check2
test2:
	beqz $t2, start3			# check if all numbers are used up in array 
	li $a1, 16
	li $v0, 42				# generate a random number
	syscall
	addi $a0, $a0, 1
	la $t4, array2				# begin at the start of array
delete2:
	lw $t3, ($t4)
	beq $t3, 69, start2  			# keep using number until the end of array
	beq $a0, $t3, erase2
	addi $t4, $t4, 4			# move to next position in array
	j delete2
erase2:						# assign each move with a number
	beq $a0, 1, m124
	beq $a0, 2, m164			# check move based on its assigned number
	beq $a0, 3, m204
	beq $a0, 4, m244			# check move based on its assigned number
	beq $a0, 5, m52
	beq $a0, 6, m56				# check move based on its assigned number
	beq $a0, 7, m60
	beq $a0, 8, m64				# check move based on its assigned number
	beq $a0, 9, m152
	beq $a0, 10, m192			# check move based on its assigned number
	beq $a0, 11, m232
	beq $a0, 12, m272			# check move based on its assigned number
	beq $a0, 13, m332
	beq $a0, 14, m336			# check move based on its assigned number
	beq $a0, 15, m340
	beq $a0, 16, m344			# check move based on its assigned number
cont2:
	sw $zero, ($t4)				# delete the used number from array
	j start2	
m124:
	li $t5, 124				# #2 priority.
	j run124
m164:
	li $t5, 164				# select if move is in this set.
	j run2
m204:
	li $t5, 204				# load position of move and check for validity
	j run2
m244:
	li $t5, 244		 		# this move is skipped if opponent can take corner from it
	j run244
m52:
	li $t5, 52		 		# this move is skipped if opponent can take corner from it
	j run52
m56:
	li $t5, 56				# load position of move and check for validity
	j run2
m60:
	li $t5, 60				# load position of move and check for validity
	j run2
m64:
	li $t5, 64		 		# this move is skipped if opponent can take corner from it
	j run64
m152:
	li $t5, 152		 		# this move is skipped if opponent can take corner from it
	j run152
m192:
	li $t5, 192				# load position of move and check for validity
	j run2
m232:
	li $t5, 232				# load position of move and check for validity
	j run2
m272:
	li $t5, 272		 		# this move is skipped if opponent can take corner from it
	j run272
m332:
	li $t5, 332		 		# this move is skipped if opponent can take corner from it
	j run332
m336:
	li $t5, 336				# load position of move and check for validity
	j run2
m340:
	li $t5, 340				# load position of move and check for validity
	j run2
m344:
	li $t5, 344		 		# this move is skipped if opponent can take corner from it
	j run344
run2:
	la $t0, validMoves			# begin at the start of array.
choose2:
	lw $t1, ($t0)				# examine a move.
	beq $t1, $t5, nextMove			# #1 priority.
	beq $t1, 0, cont2			# move to #3 priority selection if no move is selected.
	addi $t0, $t0, 4			# move to next position in array.
	j choose2
run52:
	la $t0, validMoves			# begin at the start of array.
choose52:
	lw $t1, ($t0)				# examine a move.
	beq $t1, $t5, check124			# #1 priority.
	beq $t1, 0, cont2			# move to #3 priority selection if no move is selected.
	addi $t0, $t0, 4			# move to next position in array.
	j choose52
check124:
	li $t7, 124
	lw $t9, board($t7)			# check if move is taken
	beq $t9, 9, check88
	j nextMove
run124:
	la $t0, validMoves			# begin at the start of array.
choose124:
	lw $t1, ($t0)				# examine a move.
	beq $t1, $t5, check52			# #1 priority.
	beq $t1, 0, cont2			# move to #3 priority selection if no move is selected.
	addi $t0, $t0, 4			# move to next position in array.
	j choose124
check52:
	li $t7, 52
	lw $t9, board($t7)			# check if move is taken
	beq $t9, 9, check88
	j nextMove
check88:
	li $t7, 88
	lw $t9, board($t7)			# check if move is taken
	beq $t9, 6, cont2
	j nextMove
run64:
	la $t0, validMoves			# begin at the start of array.
choose64:
	lw $t1, ($t0)				# examine a move.
	beq $t1, $t5, check152			# #1 priority.
	beq $t1, 0, cont2			# move to #3 priority selection if no move is selected.
	addi $t0, $t0, 4			# move to next position in array.
	j choose64
check152:
	li $t7, 152
	lw $t9, board($t7)			# check if move is taken
	beq $t9, 9, check88
	j nextMove
run152:
	la $t0, validMoves			# begin at the start of array.
choose152:
	lw $t1, ($t0)				# examine a move.
	beq $t1, $t5, check64			# #1 priority.
	beq $t1, 0, cont2			# move to #3 priority selection if no move is selected.
	addi $t0, $t0, 4			# move to next position in array.
	j choose152
check64:
	li $t7, 64
	lw $t9, board($t7)			# check if move is taken
	beq $t9, 9, check108
	j nextMove
check108:
	li $t7, 108
	lw $t9, board($t7)			# check if move is taken
	beq $t9, 6, cont2
	j nextMove
run244:
	la $t0, validMoves			# begin at the start of array.
choose244:
	lw $t1, ($t0)				# examine a move.
	beq $t1, $t5, check332			# #1 priority.
	beq $t1, 0, cont2			# move to #3 priority selection if no move is selected.
	addi $t0, $t0, 4			# move to next position in array.
	j choose244
check332:
	li $t7, 332
	lw $t9, board($t7)			# check if move is taken
	beq $t9, 9, check288
	j nextMove
run332:
	la $t0, validMoves			# begin at the start of array
choose332:
	lw $t1, ($t0)				# examine a move
	beq $t1, $t5, check244			# #1 priority
	beq $t1, 0, cont2			# move to #3 priority selection if no move is selected
	addi $t0, $t0, 4			# move to next position in array
	j choose332
check244:
	li $t7, 244
	lw $t9, board($t7)			# check if move is taken
	beq $t9, 9, check288
	j nextMove
check288:
	li $t7, 288
	lw $t9, board($t7)			# check if move is taken
	beq $t9, 6, cont2
	j nextMove
run272:
	la $t0, validMoves			# begin at the start of array.
choose272:
	lw $t1, ($t0)				# examine a move.
	beq $t1, $t5, check344			# #1 priority.
	beq $t1, 0, cont2			# move to #3 priority selection if no move is selected.
	addi $t0, $t0, 4			# move to next position in array.
	j choose272
check344:
	li $t7, 344
	lw $t9, board($t7)			# check if move is taken
	beq $t9, 9, check308
	j nextMove
run344:
	la $t0, validMoves			# begin at the start of array.
choose344:
	lw $t1, ($t0)				# examine a move.
	beq $t1, $t5, check272			# #1 priority.
	beq $t1, 0, cont2			# move to #3 priority selection if no move is selected.
	addi $t0, $t0, 4			# move to next position in array.
	j choose344
check272:
	li $t7, 272
	lw $t9, board($t7)			# check if move is taken
	beq $t9, 9, check308
	j nextMove
check308:
	li $t7, 308
	lw $t9, board($t7)			# check if move is taken
	beq $t9, 6, cont2
	j nextMove
	
	
	
start3:
	li $t2, 0
	la $t4, array3				# begin at the start of array
check3:
	lw $t3, ($t4)			 	# calculate sum of all values in array except 69
	beq $t3, 69, test3 
	add $t2, $t2, $t3
	addi $t4, $t4, 4			# move to next position in array
	j check3
test3:
	beqz $t2, start4			# check if all numbers are used up in array 
	li $a1, 12
	li $v0, 42				# generate a random number
	syscall
	addi $a0, $a0, 1
	la $t4, array3				# begin at the start of array
delete3:
	lw $t3, ($t4)
	beq $t3, 69, start3  			# keep using number until the end of array
	beq $a0, $t3, erase3
	addi $t4, $t4, 4			# move to next position in array
	j delete3
erase3:						# assign each move with a number
	beq $a0, 1, m132
	beq $a0, 2, m172			# check move based on its assigned number
	beq $a0, 3, m212
	beq $a0, 4, m252			# check move based on its assigned number
	beq $a0, 5, m136
	beq $a0, 6, m256			# check move based on its assigned number
	beq $a0, 7, m140
	beq $a0, 8, m260			# check move based on its assigned number
	beq $a0, 9, m144
	beq $a0, 10, m184			# check move based on its assigned number
	beq $a0, 11, m224
	beq $a0, 12, m264			# check move based on its assigned number
cont3:
	sw $zero, ($t4)				# delete the used number from array
	j start3	
m132:
	li $t5, 132				# load position of move and check for validity
	j run3
m172:
	li $t5, 172				# load position of move and check for validity
	j run3
m212:
	li $t5, 212				# load position of move and check for validity
	j run3
m252:
	li $t5, 252				# load position of move and check for validity
	j run3
m136:
	li $t5, 136				# load position of move and check for validity
	j run3
m256:
	li $t5, 256				# load position of move and check for validity
	j run3
m140:
	li $t5, 140				# load position of move and check for validity
	j run3
m260:
	li $t5, 260				# load position of move and check for validity
	j run3
m144:
	li $t5, 144				# load position of move and check for validity
	j run3
m184:
	li $t5, 184				# load position of move and check for validity
	j run3
m224:
	li $t5, 224				# load position of move and check for validity
	j run3
m264:
	li $t5, 264				# load position of move and check for validity
	j run3
run3:
	la $t0, validMoves			# begin at the start of array.
choose3:
	lw $t1, ($t0)				# examine a move.
	beq $t1, $t5, nextMove			# #1 priority.
	beq $t1, 0, cont3			# move to #3 priority selection if no move is selected.
	addi $t0, $t0, 4			# move to next position in array.
	j choose3
	
	
start4:
	li $t2, 0
	la $t4, array4				# begin at the start of array
check4:
	lw $t3, ($t4)			 	# calculate sum of all values in array except 69
	beq $t3, 69, test4
	add $t2, $t2, $t3
	addi $t4, $t4, 4			# move to next position in array
	j check4
test4:
	beqz $t2, choose5			# check if all numbers are used up in array 
	li $a1, 16
	li $v0, 42				# generate a random number
	syscall
	addi $a0, $a0, 1
	la $t4, array4				# begin at the start of array
delete4:
	lw $t3, ($t4)
	beq $t3, 69, start4  			# keep using number until the end of array
	beq $a0, $t3, erase4
	addi $t4, $t4, 4			# move to next position in array
	j delete4
erase4:						# assign each move with a number
	beq $a0, 1, m128
	beq $a0, 2, m168			# check move based on its assigned number
	beq $a0, 3, m208
	beq $a0, 4, m248			# check move based on its assigned number
	beq $a0, 5, m92
	beq $a0, 6, m96				# check move based on its assigned number
	beq $a0, 7, m100
	beq $a0, 8, m104			# check move based on its assigned number
	beq $a0, 9, m292
	beq $a0, 10, m296			# check move based on its assigned number
	beq $a0, 11, m300
	beq $a0, 12, m148			# check move based on its assigned number
	beq $a0, 13, m188
	beq $a0, 14, m228			# check move based on its assigned number
	beq $a0, 15, m304
	beq $a0, 16, m268			# check move based on its assigned number
cont4:
	sw $zero, ($t4)				# delete the used number from array
	j start4	
m128:
	li $t5, 128				# load position of move and check for validity
	j run4
m168:
	li $t5, 168				# load position of move and check for validity
	j run4
m208:
	li $t5, 208				# load position of move and check for validity
	j run4
m248:
	li $t5, 248				# load position of move and check for validity
	j run4
m92:
	li $t5, 92				# load position of move and check for validity
	j run4
m96:
	li $t5, 96				# load position of move and check for validity
	j run4
m100:
	li $t5, 100				# load position of move and check for validity
	j run4
m104:
	li $t5, 104				# load position of move and check for validity
	j run4
m292:
	li $t5, 292				# load position of move and check for validity
	j run4
m296:
	li $t5, 296				# load position of move and check for validity
	j run4
m300:
	li $t5, 300				# load position of move and check for validity
	j run4
m304:
	li $t5, 304				# load position of move and check for validity
	j run4
m148:
	li $t5, 148				# load position of move and check for validity
	j run4
m188:
	li $t5, 188				# load position of move and check for validity
	j run4
m228:
	li $t5, 228				# load position of move and check for validity
	j run4
m268:
	li $t5, 268				# load position of move and check for validity
	j run4
run4:
	la $t0, validMoves			# begin at the start of array.
choose4:
	lw $t1, ($t0)				# examine a move.
	beq $t1, $t5, nextMove			# #1 priority.
	beq $t1, 0, cont4			# move to the leftover selection if no move is selected.
	addi $t0, $t0, 4			# move to next position in array.
	j choose4
choose5:
	la $t0, validMoves			# select 1 of the leftover moves.
	lw $t1, ($t0)
	j nextMove


##### Check player's input.
checkValid:
	la $a0, invalid				# ask for input.
	li $v0, 4
	syscall
sound_move_not_ok:
	# Preservation:
	addi $sp, $sp, -16 			# allocate stack space.
        sw  $a0, 0($sp)				# will be used for sound pitch.
        sw  $a1, 4($sp)				# will be used for sound duration.	
        sw  $a2, 8($sp)				# will be used for sound instrument.	
        sw  $a3, 12($sp)			# will be used for sound volume.	
        # Sound generation:
	li $v0, 33
	li $a0, 0				# pitch.
	li $a1, 300				# duration in milisecond.
	li $a2, 0				# instrument.
	li $a3, 0				# volume.
	syscall
	li $v0, 33
	li $a0, 50				# pitch.
	li $a1, 300				# duration in milisecond.
	li $a2, 110				# instrument.
	li $a3, 400				# volume.
	syscall
	li $v0, 33
	li $a0, 38				# pitch.
	li $a1, 1000				# duration in milisecond.
	li $a2, 110				# instrument.
	li $a3, 400				# volume.
	syscall
	# Restoration:
        lw  $a0, 0($sp)
        lw  $a1, 4($sp)
        lw  $a2, 8($sp)
        lw  $a3, 12($sp)
    	addi $sp, $sp, 16			# aree stack space.
    	
##### Convert player's input.
convert_input:	
	#Preservation:
	addi $sp, $sp, -40 			# allocate stack space.
        sw  $a0, 0($sp)		
        sw  $a1, 4($sp)		
        sw  $t0, 8($sp)		
        sw  $t1, 12($sp)	
        sw  $t2, 16($sp)
        sw  $t3, 20($sp)
        sw  $t4, 24($sp)
        sw  $t5, 28($sp)
        sw  $t6, 32($sp)
        sw  $t7, 36($sp)
	# Read the player's move:			
	la $a0, prompt				# ask for input.
	li $v0, 4
	syscall
	beq $s3, 9, conv2
	la $a0, userName1			# ask for input.
	li $v0, 4
	syscall
	la $a0, colon				# ask for input.
	li $v0, 4
	syscall
	j convCont
conv2:
	la $a0, userName2			# ask for input.
	li $v0, 4
	syscall
	la $a0, colon				# ask for input.
	li $v0, 4
	syscall
convCont:
	la $a0, conv_buffer			# save string to buffer.
	li $a1, 20				# allocate space.
	li $v0, 8
	syscall
	# Load the buffer:
	la $t0, conv_buffer   			# get base address for buffer.  
	# Program termination in case an input is a 0.
	lb $t2, 0($t0)  			# load the first byte from buffer to $t2. 
	beq $t2, 0x30, end  			# if $t2 = 0 then terminate the game.
	# Input validation - string must be 2 characters, first a or A to h or H, second a number 0 to 8.
	li $t1, 0    				# $t1 counter set to 0.  
convert_input_count:  
	lb $t2, 0($t0)  			# load the first byte from buffer to $t2. 
	beqz $t2, convert_input_count_end   	# if $t2 = 0 then go to label convert_input_count_end. 
	add $t0, $t0, 1      			# else increment the address.
	add $t1, $t1, 1 			# and increment the counter. 
	j convert_input_count      		# loop.
convert_input_count_end: 
	add $t1, $t1, -1			# decrement counter to remove end line character.	
	bne $t1, 2, convert_input_error1	# if not 2 characters, error, ask for input again.
	la $t0, conv_buffer   			# get base address for buffer.  
	lb $t6, 1($t0)				# number into $t6.
	lb $t7, 0($t0)				# letter into $t7.
	ble $t6, 0x30, convert_input_error2 	# if number less or equal 0, not good.
	bgt $t6, 0x38, convert_input_error2	# if number greater then 8, not good.
	blt $t7, 0x41, convert_input_lc		# if letter less then 0x41, check low case.
	bgt $t7, 0x48, convert_input_lc		# if letter greater then 0x48, check low case.
	j convert_input_ok
convert_input_lc:
	blt $t7, 0x61, convert_input_error2	# if letter less then 0x61, not good.
	bgt $t7, 0x68, convert_input_error2	# if letter greater then 0x68, not good.
	j convert_input_ok
convert_input_error1:				# error 1.
	li $v0, 4 				# Load a request to print.
        la $a0, conv_output1 			# Load an address of string input.
        syscall
        j checkValid				# repeat input.
convert_input_error2:				# error 2.
	li $v0, 4 				# Load a request to print.
        la $a0, conv_output2 			# Load an address of string input.
        syscall
        j checkValid				# repeat input.
convert_input_ok:				# comparison based on LETTER NUMBER combination, like A5.
	# Let's check low case first:
	la $t0, conv_buffer   			# get base address for buffer.
	la $t3, lo_letters   			# get base address for lo_letters. 
	li $t1, 1    				# $t1 counter set to 1. 
convert_input_low:  
	lb $t2, 0($t0)  			# load the first byte from buffer to $t2. 
	lb $t4, 0($t3)  			# load the byte from lo_letters to $t4. 
	beq $t2, $t4, convert_input_result   	# if $t2 = $t4 then go to label convert_input_result. 
	add $t3, $t3, 1      			# else increment the address.
	add $t1, $t1, 1 			# and increment the counter. 
	beq $t1, 9, convert_input_try_upper	# 8 chars, but no success, quit low.
	j convert_input_low      		# loop.
convert_input_try_upper:
	# Let's check upper case now:
	la $t0, conv_buffer   			# get base address for buffer.
	la $t3, hi_letters   			# get base address for hi_letters. 
	li $t1, 1    				# $t1 counter set to 1. 
convert_input_upper:  
	lb $t2, 0($t0)  			# load the first byte from buffer to $t2. 
	lb $t4, 0($t3)  			# load the byte from lo_letters to $t4.  
	beq $t2, $t4, convert_input_result   	# if $t2 = $t4 then go to label convert_input_result. 
	add $t3, $t3, 1      			# else increment the address.
	add $t1, $t1, 1 			# and increment the counter. 
	beq $t1, 9, convert_input_result	# 8 chars, but no success, quit with number 9.
	j convert_input_upper      		# loop.
convert_input_result:
						# $t1 contains the needed first number.
						# If number is 9 then the input was out of range - ask again.
	beq $t1, 9, checkValid			# rerun the program - out of range.
	# Let's compose the number together:
	mulu $t1, $t1, 10			# shift first to second position.
	addi $t0, $t0, 1			# next memory adress
	lb $t5, 0($t0)				# get the first element to $t5. 
	addi $t5, $t5, -0x30 			# convert from ASCII to int.
	add $t5, $t5, $t1			# combine two digits in one number.
	move $v0, $t5				# put result in $v0 for return.
	# Restoration:
        lw  $a0, 0($sp)		
        lw  $a1, 4($sp)		
        lw  $t0, 8($sp)		
        lw  $t1, 12($sp)	
        lw  $t2, 16($sp)
        lw  $t3, 20($sp)
        lw  $t4, 24($sp)
        lw  $t5, 28($sp)
        lw  $t6, 32($sp)
        lw  $t7, 36($sp)
    	addi $sp, $sp, 40			# aree stack space.
	move $t4, $v0
	mul $t4, $t4, 4				# compute the position.
	beqz $t4, end
	la $t0, validMoves			# begin at the start of array.
checkMove:					# check if human move is valid.
	lw $t1, ($t0)
	beq $t1, 0, checkValid			# ask again for move.
	beq $t4, $t1, nextMove			# continue if move is valid.
	addi $t0, $t0, 4
	j checkMove
nextMove:
	jr $ra

##### Turn switch.
turnSwitch: 					# get input old $s3.
	beq $s3, $s6, whiteturn			# if the previous turn was back -> white.
	move $s3, $s6				# else set to black.
	j next
whiteturn:
	move $s3, $s7				# set to white turn.
next: 
						# now $s3 holds either black or white.
						# pass it to valid moves.
validmoves:
						# board is the array.
	#addi $t0, $0, 0			# $t0 is index of board array.
	addi $t0, $0, 44
	addi $t3, $0, 0				# $t3 is index of validmoves array or $s4.
	#addiu $t9, $0, 400			# $t9 could be 356 for efficiency.
	addiu $t9, $0, 356
	#addi $s5, $0, 0			# death counter set to 0.
						#set validmoves aray to 0.
zeroloop:
	beq $t3, 64, zeroed 			# was 36 -> 64.
	sw $0, validMoves($t3)
	addi $t3, $t3, 4
	j zeroloop
zeroed:
	addi $t3, $0, 0				# $t3 is index of validmoves array, set $t3 back to 0.
loop:						# go through every cell of the board.
	beq $t0, $t9, exit
	lw $t1, board($t0)			# $t1 is temporary element of the board.
	beq $t1, 0, empty			# check if the cell is taken.
	addi $t0, $t0, 4
	j loop
empty:
east: 						# the cell is now empty, go right direction.
	addi $t1, $t0, 40			# $t1 is now the index of next cell.
	lw $t2, board($t1)			# $t2 is the element of that cell.
	beq $t2, 0, invalidE			# if the next cell is blank.
	beq $t2, 1, invalidE			# if the next cell is border.
	beq $t2, $s3, invalidE 			# if the next cell is the same.
						# else the next cell is opposite color.
loopE:
	addi $t1,$t1, 40			# go to the cell after it.
	lw $t2, board($t1)			# element of this cell.
	beq $t2, 1, invalidE			# if reach the border then invalid.
	beq $t2, 0, invalidE			# if the cell after it blank.
	beq $t2, $s3, validE			# if it meets another cell with same color.
	j loopE
validE:
	sw $t0, validMoves($t3)			# store the index of the valid cell to array.
	addi $t3, $t3, 4			# increase the index of array by 1 for next use.
	j validCell				# skip checking other directions for this cell.
invalidE: 					# go other direction.
west: 						# still have $t0 is the emptyce.
	addi $t1, $t0, -40			# $t1 is now the index of next cell.
	lw $t2, board($t1)			# $t2 is the element of that cell.
	beq $t2, 0, invalidW			# if the next cell is blank.
	beq $t2, 1, invalidW			# if the next cell is border.
	beq $t2, $s3, invalidW 			# if the next cell is the same.
						# else the next cell is opposite color.
loopW:
	addi $t1,$t1, -40			# go to the cell after it.
	lw $t2, board($t1)			# element of this cell.
	beq $t2, 1, invalidW			# if reach the border then invalid.
	beq $t2, 0, invalidW			# if the cell after it blank.
	beq $t2, $s3, validW			# if it meets another cell with same color.
	j loopW
validW:
	sw $t0, validMoves($t3)			# store the index of the valid cell to array.
	addi $t3, $t3, 4			# increase the index of array by 1 for next use.
	j validCell				# skip checking other directions for this cell.
invalidW: 					# go other direction.
north:
	addi $t1, $t0, -4			# $t1 is now the index of next cell.
	lw $t2, board($t1)			# $t2 is the element of that cell.
	beq $t2, 0, invalidN			# if the next cell is blank.
	beq $t2, 1, invalidN			# if the next cell is border.
	beq $t2, $s3, invalidN 			# if the next cell is the same.
						# else the next cell is opposite color.
loopN:
	addi $t1,$t1, -4			# go to the cell after it.
	lw $t2, board($t1)			# element of this cell.
	beq $t2, 1, invalidN			# if reach the border then invalid.
	beq $t2, 0, invalidN			# if the cell after it blank.
	beq $t2, $s3, validN			# if it meets another cell with same color.
	j loopN
validN:
	sw $t0, validMoves($t3)			# store the index of the valid cell to array.
	addi $t3, $t3, 4			# increase the index of array by 1 for next use.
	j validCell				# skip checking other directions for this cell.
invalidN: 					# go other direction.
south:
	addi $t1, $t0, 4			# $t1 is now the index of next cell.
	lw $t2, board($t1)			# $t2 is the element of that cell.
	beq $t2, 0, invalidS			# if the next cell is blank.
	beq $t2, 1, invalidS			# if the next cell is border.
	beq $t2, $s3, invalidS 			# if the next cell is the same.
						# else the next cell is opposite color.
loopS:
	addi $t1,$t1, 4				# go to the cell after it.
	lw $t2, board($t1)			# element of this cell.
	beq $t2, 1, invalidS			# if reach the border then invalid.
	beq $t2, 0, invalidS			# if the cell after it blank.
	beq $t2, $s3, validS			# if it meets another cell with same color.
	j loopS
validS:
	sw $t0, validMoves($t3)			# store the index of the valid cell to array
	addi $t3, $t3, 4			# increase the index of array by 1 for next use
	j validCell				# skip checking other directions for this cell
invalidS: 					# go other direction
northeast:
	addi $t1, $t0, 36			# $t1 is now the index of next cell
	lw $t2, board($t1)			# $t2 is the element of that cell
	beq $t2, 0, invalidNE			# if the next cell is blank
	beq $t2, 1, invalidNE			# if the next cell is border
	beq $t2, $s3, invalidNE 		# if the next cell is the same
						# else the next cell is opposite color
loopNE:
	addi $t1,$t1, 36			# go to the cell after it.
	lw $t2, board($t1)			# element of this cell.
	beq $t2, 1, invalidNE			# if reach the border then invalid.
	beq $t2, 0, invalidNE			# if the cell after it blank.
	beq $t2, $s3, validNE			# if it meets another cell with same color.
	j loopNE
validNE:
	sw $t0, validMoves($t3)			# store the index of the valid cell to array.
	addi $t3, $t3, 4			# increase the index of array by 1 for next use.
	j validCell				# skip checking other directions for this cell.
invalidNE: 					# go other direction.
southeast:
	addi $t1, $t0, 44			# $t1 is now the index of next cell.
	lw $t2, board($t1)			# $t2 is the element of that cell.
	beq $t2, 0, invalidSE			# if the next cell is blank.
	beq $t2, 1, invalidSE			# if the next cell is border.
	beq $t2, $s3, invalidSE 		# if the next cell is the same.
						# else the next cell is opposite color.
loopSE:
	addi $t1,$t1, 44			# go to the cell after it.
	lw $t2, board($t1)			# element of this cell.
	beq $t2, 1, invalidSE			# if reach the border then invalid.
	beq $t2, 0, invalidSE			# if the cell after it blank.
	beq $t2, $s3, validSE			# if it meets another cell with same color.
	j loopSE
validSE:
	sw $t0, validMoves($t3)			# store the index of the valid cell to array.
	addi $t3, $t3, 4			# increase the index of array by 1 for next use.
	j validCell				# skip checking other directions for this cell.
invalidSE: 					# go other direction.
northwest:
	addi $t1, $t0, -44			# $t1 is now the index of next cell.
	lw $t2, board($t1)			# $t2 is the element of that cell.
	beq $t2, 0, invalidNW			# if the next cell is blank.
	beq $t2, 1, invalidNW			# if the next cell is border.
	beq $t2, $s3, invalidNW 		# if the next cell is the same.
						# else the next cell is opposite color.
loopNW:
	addi $t1,$t1, -44			# go to the cell after it.
	lw $t2, board($t1)			# element of this cell.
	beq $t2, 1, invalidNW			# if reach the border then invalid.
	beq $t2, 0, invalidNW			# if the cell after it blank.
	beq $t2, $s3, validNW			# if it meets another cell with same color.
	j loopNW
validNW:
	sw $t0, validMoves($t3)			# store the index of the valid cell to array.
	addi $t3, $t3, 4			# increase the index of array by 1 for next use.
	j validCell				# skip checking other directions for this cell.
invalidNW: 					# go other direction.
southwest:
	addi $t1, $t0, -36			# $t1 is now the index of next cell.
	lw $t2, board($t1)			# $t2 is the element of that cell.
	beq $t2, 0, invalidSW			# if the next cell is blank.
	beq $t2, 1, invalidSW			# if the next cell is border.
	beq $t2, $s3, invalidSW 		# if the next cell is the same.
						# else the next cell is opposite color.
loopSW:
	addi $t1,$t1, -36			# go to the cell after it.
	lw $t2, board($t1)			# element of this cell.
	beq $t2, 1, invalidSW			# if reach the border then invalid.
	beq $t2, 0, invalidSW			# if the cell after it blank.
	beq $t2, $s3, validSW			# if it meets another cell with same color.
	j loopSW
validSW:
	sw $t0, validMoves($t3)			# store the index of the valid cell to array.
	addi $t3, $t3, 4			# increase the index of array by 1 for next use.
	j validCell				# skip checking other directions for this cell.
invalidSW: 					# go other direction.
						# after valid jump to here to avoid double count, 
						# if the cell is valid in more than 1 direction.
validCell:
	addi $t0, $t0, 4
	j loop
exit: 						# after went through all cells in the array,
						# return c and array of valid moves.
						# now if there is no valid move the 1st element
						# in the valid array will be 0.
	lw $t1, validMoves($0)			# let $t1 temporary hold the 1st element of the array.
	bne $t1, 0, Exist			# check if the validmves array empty or not.
	addi $s5, $s5, 1			# increase death counter if array empty.
	j once
Exist:
	addi $s5, $0, 0				# if exist then set $s5 back to 0.

once:
	beq $s5, 1, turnSwitch			# for the 1st time, switch turn and check if opponent has valid moves.
	beq $s5, 2, endGame			# for the 2nd time, end program.
	j continue

##### End game or play another prompt.
endGame:
	li $t6, 0
	li $t9, 0
	li $t0, 40
endB:						# traverse through board
	lw $t1, board($t0)
	beq $t1, 6, countB			# count black score
	beq $t0, 356, endW
	addi $t0, $t0, 4			# move to next position in board
	j endB
countB:
	addi $t6, $t6, 1
	addi $t0, $t0, 4			# move to next position in board
	j endB
endW:
	lw $t1, board($t0)
	beq $t1, 9, countW			# count white score
	beq $t0, 0, result
	addi $t0, $t0, -4			# move to previous position in board
	j endW
countW:
	addi $t9, $t9, 1
	addi $t0, $t0, -4			# move to prevous position in board
	j endW
result:
	beq $t6, $t9, endDraw			# check if game is draw
	slt $t3, $t6, $t9    
	beqz $t3, bWin				# check for winner
	beq $t3, 1, wWin
endDraw:
	la $a0, gameDraw			# print game draw
	li $v0, 4
	syscall
	j end
bWin:

##### Sound game over player won.
sound_game_over_won:	
	# Preservation:
	addi $sp, $sp, -16 			# allocate stack space.
        sw  $a0, 0($sp)				# will be used for sound pitch.
        sw  $a1, 4($sp)				# will be used for sound duration.	
        sw  $a2, 8($sp)				# will be used for sound instrument.	
        sw  $a3, 12($sp)			# will be used for sound volume.	
        # Sound generation:	
	li $v0, 33
	li $a0, 0				# pitch.
	li $a1, 300				# duration in milisecond.
	li $a2, 0				# instrument.
	li $a3, 0				# volume.
	syscall	
	li $v0, 33
	li $a0, 40				# pitch.
	li $a1, 300				# duration in milisecond.
	li $a2, 62				# instrument.
	li $a3, 300				# volume.
	syscall	
	li $v0, 33
	li $a0, 50				# pitch.
	li $a1, 300				# duration in milisecond.
	li $a2, 62				# instrument.
	li $a3, 300				# volume.
	syscall	
	li $v0, 33
	li $a0, 60				# pitch.
	li $a1, 300				# duration in milisecond.
	li $a2, 63				# instrument.
	li $a3, 300				# volume.
	syscall
	li $v0, 33
	li $a0, 50				# pitch.
	li $a1, 300				# duration in milisecond.
	li $a2, 62				# instrument.
	li $a3, 300				# volume.
	syscall	
	li $v0, 33
	li $a0, 65				# pitch.
	li $a1, 1200				# duration in milisecond.
	li $a2, 63				# instrument. 
	li $a3, 300				# volume.
	syscall
	# Restoration:
        lw  $a0, 0($sp)
        lw  $a1, 4($sp)
        lw  $a2, 8($sp)
        lw  $a3, 12($sp)
    	addi $sp, $sp, 16			# free stack space.
    	
    	la $a0, newline
	li $v0, 4
	syscall
	la $a0, userName1			# print username
	li $v0, 4
	syscall
	la $a0, win				# print winner
	li $v0, 4
	syscall
	move $a0, $t6				# print score of winner
	li $v0,1
	syscall
	j end
wWin:

##### Sound game over player lost.
sound_game_over_lost:	
	# Preservation:
	addi $sp, $sp, -16 			# allocate stack space.
        sw  $a0, 0($sp)				# will be used for sound pitch.
        sw  $a1, 4($sp)				# will be used for sound duration.	
        sw  $a2, 8($sp)				# will be used for sound instrument.	
        sw  $a3, 12($sp)			# will be used for sound volume.	
        # Sound generation:
	li $v0, 33
	li $a0, 0				# pitch.
	li $a1, 300				# duration in milisecond.
	li $a2, 0				# instrument.
	li $a3, 0				# volume.
	syscall
	li $v0, 33
	li $a0, 60				# pitch.
	li $a1, 300				# duration in milisecond.
	li $a2, 62				# instrument.
	li $a3, 400				# volume.
	syscall
	li $v0, 33
	li $a0, 50				# pitch.
	li $a1, 300				# duration in milisecond.
	li $a2, 62				# instrument.
	li $a3, 400				# volume.
	syscall	
	li $v0, 33
	li $a0, 40				# pitch.
	li $a1, 300				# duration in milisecond.
	li $a2, 63				# instrument.
	li $a3, 400				# volume.
	syscall		
	li $v0, 33
	li $a0, 50				# pitch.
	li $a1, 300				# duration in milisecond.
	li $a2, 62				# instrument.
	li $a3, 400				# volume.
	syscall			
	li $v0, 33
	li $a0, 35				# pitch.
	li $a1, 1200				# duration in milisecond.
	li $a2, 63				# instrument.
	li $a3, 400				# volume.
	syscall
	# Restoration:
        lw  $a0, 0($sp)
        lw  $a1, 4($sp)
        lw  $a2, 8($sp)
        lw  $a3, 12($sp)
    	addi $sp, $sp, 16			# free stack space.   	
    	lw $t0, mode
    	bne $t0, 1, endCom			# check if multiplayer or not
	la $a0, newline
	li $v0, 4
	syscall
	la $a0, userName2			# print username
	li $v0, 4
	syscall
	la $a0, win				# print winner
	li $v0, 4
	syscall
	move $a0, $t9				# print score of winner
	li $v0,1
	syscall
	j end
endCom:
	la $a0, newline
	li $v0, 4
	syscall
	la $a0, comWin				# print computer as winner
	li $v0, 4
	syscall
	move $a0, $t9				# print score of winner
	li $v0,1
	syscall
	j end
end: 						# print the final result who won.
	li $v0, 4
	la $a0, time
	syscall
	li $v0,30 				# get system time - finish time.
	syscall
	sub $a0, $a0, $s1  			# get time played in a game
	div $a0, $a0, 1000 
	li $t1, 60
	div $a0, $t1
	mflo $a0
	mfhi $t0
	li $v0, 1				# print time
	syscall
	li $v0, 4
	la $a0, minute				# ask to play again
	syscall
	move $a0, $t0
	li $v0, 1				# print time
	syscall
	li $v0, 4
	la $a0, second				# ask to play again
	syscall
	li $v0, 4
	la $a0, again				# ask to play again
	syscall
	li $v0, 5
	syscall
	beq $v0, 1, main			# restart the game if asked
	li $v0, 4
	la $a0, endgame				# otherwise end game
	syscall

	li $v0, 10
	syscall
continue:					# program keeps running to another parts.
	jr $ra

##### Update array.
UPDATE:	
	addi $a0, $t1, 0
	addi $a1, $s3, 0
	# Preservation:
	addi $sp, $sp, -52 			# allocate stack space.
        sw  $t0, 0($sp)				# will be used for current player's color.
        sw  $t1, 4($sp)				# will be used for opponent's color.
        sw  $t2, 8($sp)				# 8 moves array.
        sw  $t3, 12($sp)			# 8 moves array counter.
        sw  $t4, 16($sp)			# possible flip candidates counter.
        sw  $t5, 20($sp) 			# ua_loop1 check.
        sw  $t6, 24($sp)			# operational array parameter.
        sw  $t7, 28($sp)			# ua_loop2 check.
        sw  $t8, 32($sp)
        sw  $t9, 36($sp)
        sw  $a0, 40($sp)
        sw  $a1, 44($sp)
        sw  $s3, 48($sp)
        					# incoming $t1 as current move, $s3 as current color.
	addi $a0, $t1, 0			# $t1 -> $a0 current move.
	addi $a1, $s3, 0			# $s3 -> $a1 current color.
	# Color assignment for opponent:     
	addi $t0, $zero, 6              	# $t0 - current color.        
        addi $t1, $zero, 9              	# $t1 - opponent's color.
        beq $t0, $a1, ua_nochange		# if match no need to flip.
        addi $t0, $zero, 9
        addi $t1, $zero, 6			# flip the colors otherwise.    
ua_nochange:    
	# Updste an array with the actual move:
        sw  $a1, board($a0) 
	# Setup the ua_loop1 params:
        li $t3, 0				# zero out array loop counter.
        li $t5, 32     				# 8 elements in array, step 4.
    	# Go through all the moves (8 moves array):
ua_loop1:
	li $t4, 0				# zero out flip candidates counter.
        lw $t2, ua_list($t3)			# an element of 8 moves array will be a step size.
        add $t6, $t2, $a0       		# determine next operational field.
        lw $t8, board($t6)
        beq $t1, $t8, ua_else1			# check the color of next operational field.
        j ua_skip                       	# if next operational field color is equal, no need to proceed.
    ua_else1:                           	# if next operational field color is different, go ahead.
        addi $t4, $t4, 1                	# increase the count of possible candidates to flip.
        add $t6, $t6, $t2               	# move to the next operational field in same direction.
        lw $t8, board($t6)
        beq $t1, $t8, ua_else1			# if next operational field color is equal, continue, repeat.
        beq $t0, $t8, ua_else2			# if next operational field color is different, we got good line to flip.
        addi $t4, $zero, 0			# line ends with a blank or edge, no good.
        j ua_skip				# not good direction, skip the rest.
    ua_else2:                           	# succssess, close the circut and flip.    
        li $t7, 0				# zero out sequential flip counter.
        addiu $t6, $a0, 0			# reset operation field position to start from paly position.
    ua_loop2:
        add $t6, $t6, $t2			# determine next from played operational field for flipping.
        sw  $t0, board($t6)			# update that operational field with the color that was playing.
        addi $t7, $t7, 1                	# increment sequential flip counter.
        beq $t7, $t4, ua_skip			# sequential flip counter must be no more then number of candidates to flip.
        j ua_loop2				# if counter less, continue flipping next operational field.
    ua_skip:   
        addi $t3, $t3, 4                	# Increment 8 moves array counter by 4.
        bne $t3, $t5, ua_loop1          	# untill index reaches 32, repeat the loop.
	# Restoration:
        lw  $t0, 0($sp)
        lw  $t1, 4($sp)
        lw  $t2, 8($sp)
        lw  $t3, 12($sp)
        lw  $t4, 16($sp)
        lw  $t5, 20($sp)
        lw  $t6, 24($sp)
        lw  $t7, 28($sp)
    	lw  $t8, 32($sp)
    	lw  $t9, 36($sp)
    	lw  $a0, 40($sp)
        lw  $a1, 44($sp)
        lw  $s3, 48($sp)
    	addi $sp, $sp, 52			# free stack space.
    	jr  $ra					# return back, no return value from function.

##### Draw.
DRAW:
	li $a2, 0x00b2b200			# color yellow for border.
	li $a3, 0x00228B22			# color green for the board.
	li $t9, 0x00FFFFFF			# color white.
	li $t6, 0x00000000			# color black.
	la $t0, frameBuffer			# set the bitmap.
	addi $s0, $0, 0				# counter for setting the table green.
	# set the table green:
	addi $t1, $t0, 0			# $t1 = $t0.
	addi $t2, $0, 0 			# $t2 = counter.
table:
	sw $a3, ($t1)
	addi $t1, $t1 ,4
	addi $t2, $t2, 2
	bne $t2, 262144, table
	#draw the lines:
	addi $s0, $0, 2048			# counter of row and column
rows:
	add $t1, $t0, $s0			# $t1 = $t0.
	addi $t2, $0, 0 			# $t2 = counter.
loop1:
	sw $a2, ($t1)
	addi $t1, $t1, 4
	addi $t2, $t2, 2
	bne $t2, 512, loop1
	addi $s0, $s0, 25600
	bne $s0, 283648, rows

	addi $s0, $0, 2048			# counter of row and column set back to 0.
columns:
	add $t1, $t0, $s0			# $t1 = $t0.
	addi $t2, $0, 0 			# $t2 = counter of each row or column.
loop2:
	sw $a2, ($t1)
	addi $t1, $t1, 1024
	addi $t2, $t2, 2
	bne $t2, 500, loop2
	addi $s0, $s0, 104
	bne $s0, 3088, columns

##### Traverse through the board array and draw the chess onto the board.
						# $t4 will hold the color.
	addi $t5, $0, 44			# $t5 = index of board array.
draw:
	beq $t5, 400, finish
	lw $t8, board($t5)			# $t8 = color, either 6 9 0 1.
	bne $t8, 6, next1			# if $t8 = 6.
	move $t4, $t6				# set $t4 to black.
	j colored
next1:
	bne $t8, 9, next2			# if $t8 = 9.
	move $t4, $t9				# set $t4 to white.
	j colored
next2:
	bne $t8, 0, dontdraw			# if $t8 = 0, else $t8 = 1, which is border so dont draw.
	move $t4, $a3				# set $t4 to green.
colored:
	addi $s0, $t5, 0			# pass the index of board array to calculate position on the bitmap that to start drawing.
	# addi $s0, $0, 44 			# -> get the grd, calculate the corner.
	blt $s0, 84, row1
	blt $s0, 124, row2
	blt $s0, 164, row3
	blt $s0, 204, row4
	blt $s0, 244, row5
	blt $s0, 284, row6
	blt $s0, 324, row7
	blt $s0, 364, row8
row1:
	addi $s0, $s0, -44
	mul $s0, $s0, 26
	addi $s0, $s0, 27752
	j dothemath
row2:
	addi $s0, $s0, -84
	mul $s0, $s0, 26
	addi $s0, $s0, 53352
	j dothemath
row3:
	addi $s0, $s0, -124
	mul $s0, $s0, 26
	addi $s0, $s0, 78952
	j dothemath
row4:
	addi $s0, $s0, -164
	mul $s0, $s0, 26
	addi $s0, $s0, 104552
	j dothemath
row5:
	addi $s0, $s0, -204
	mul $s0, $s0, 26
	addi $s0, $s0, 130152
	j dothemath
row6:
	addi $s0, $s0, -244
	mul $s0, $s0, 26
	addi $s0, $s0, 155752
	j dothemath
row7:
	addi $s0, $s0, -284
	mul $s0, $s0, 26
	addi $s0, $s0, 181352
	j dothemath
row8:
	addi $s0, $s0, -324
	mul $s0, $s0, 26
	addi $s0, $s0, 206952
	j dothemath
dothemath:
	addi $s0, $s0, 3084
	add $t1, $t0, $s0			# $t1 is now the pixel need to start drawing.
						# $t1 now is the bit next to the corner.
						# draw the chess inside the box.
	addi $t3, $0, 0				# $t3 = counter column set to 0.
looprow:
	addi $t2, $0, 0				# $t2 = counter row set to 0.
loopcol:
	sw $t4, ($t1)				# $t4 is the color.
	addi $t1, $t1, 4
	addi $t2, $t2, 1
	bne $t2, 21, loopcol

	addi $t1, $t1, 940			# to next row.
	addi $t3, $t3, 1
	bne $t3, 20, looprow
dontdraw:
	addi $t5, $t5, 4			# $t5++, move to next chess in the array.
	j draw
finish:

##### Blacken the border
	# top:
	addi $t1, $t0, 0			# $t1 = copy of $t0.
	addi $t3, $0, 0				# $t3 = counter column.
blackrow:
	addi $t2, $0, 0				# $t2 = counter row.
blackcol:
	sw $t6, ($t1)
	addi $t1, $t1, 4
	addi $t2, $t2, 1
	bne $t2, 255, blackcol
	addi $t1, $t1, 4
	addi $t3, $t3, 1
	bne $t3, 27, blackrow 
	# left:
	addi $t1, $t0, 0			# $t1 = copy of $t0.
	addi $t3, $0, 0				# $t3 = counter column.
blackrowl:
	addi $t2, $0, 0				# $t2 = counter row.
blackcoll:
	sw $t6, ($t1)
	addi $t1, $t1, 4
	addi $t2, $t2, 1
	bne $t2, 26, blackcoll
	addi $t1, $t1,  920
	addi $t3, $t3, 1
	bne $t3, 511, blackrowl 
	# right:
	addi $t1, $t0, 940			# $t1 = copy of $t0.
	addi $t3, $0, 0				# $t3 = counter column.
blackrowr:
	addi $t2, $0, 0				# $t2 = counter row.
blackcolr:
	sw $t6, ($t1)
	addi $t1, $t1, 4
	addi $t2, $t2, 1
	bne $t2, 26, blackcolr
	addi $t1, $t1,  920
	addi $t3, $t3, 1
	bne $t3, 256, blackrowr
	# bottom:
	addi $t1, $t0, 233472			# $t1 = copy of $t0.
	addi $t3, $0, 0				# $t3 = counter column.
blackrowb:
	addi $t2, $0, 0				# $t2 = counter row.
blackcolb:
	sw $t6, ($t1)
	addi $t1, $t1, 4
	addi $t2, $t2, 1
	bne $t2, 255, blackcolb
	addi $t1, $t1, 4
	addi $t3, $t3, 1
	bne $t3, 28, blackrowb

##### Draw numbers.
	# 6176 = 1st cell
	# Letter A:
	addi $t1, $t0, 31776			# $t1 = grid to draw
	addi $t2, $t1, 0			# $t2  = copy of $t1
	addi $t4, $0, 0				# counter to draw nverA
nverA:
	addi $t3, $0, 0				# counter to draw verA
verA:
	sw $t9, ($t2)
	addi $t2, $t2, 4
	addi $t3, $t3, 1
	bne $t3, 10, verA
	addi $t2, $t2, 8152
	addi $t4, $t4, 1
	bne $t4, 2, nverA
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nhorA.
nhorA:
	addi $t3, $0, 0				# counter to draw hor.

horA:
	sw $t9, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 17, horA
	addi $t2, $t1, 40
	addi $t4, $t4, 1
	bne $t4, 2, nhorA
	# Letter B:
	addi $t1, $t0, 57376			# $t1 = grid to draw.
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nverA.
nverB:
	addi $t3, $0, 0				# counter to draw verA.
verB:
	sw $t9, ($t2)
	addi $t2, $t2, 4
	addi $t3, $t3, 1
	bne $t3, 10, verB
	addi $t2, $t2, 8152
	addi $t4, $t4, 1
	bne $t4, 3, nverB
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nhorA.
nhorB:
	addi $t3, $0, 0				# counter to draw hor.

horB:
	sw $t9, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 17, horB

	addi $t2, $t1, 40
	addi $t4, $t4, 1
	bne $t4, 2, nhorB
	# Letter C:
	addi $t1, $t0, 82976			# $t1 = grid to draw.
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nverA.
nverC:
	addi $t3, $0, 0				# counter to draw verA.
verC:
	sw $t9, ($t2)
	addi $t2, $t2, 4
	addi $t3, $t3, 1
	bne $t3, 10, verC
	addi $t2, $t2, 16344
	addi $t4, $t4, 1
	bne $t4, 2, nverC
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nhorA.
nhorC:
	addi $t3, $0, 0				# counter to draw hor.

horC:
	sw $t9, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 17, horC
	addi $t2, $t1, 40
	addi $t4, $t4, 1
	bne $t4, 1, nhorC
	# letter D:
	addi $t1, $t0, 108576			# $t1 = grid to draw.
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nverA.
nverD:
	addi $t3, $0, 0				# counter to draw verA
verD:
	sw $t9, ($t2)
	addi $t2, $t2, 4
	addi $t3, $t3, 1
	bne $t3, 10, verD
	addi $t2, $t2, 16344
	addi $t4, $t4, 1
	bne $t4, 2, nverD
	addi $t2, $t1, 0			# $t2  = copy of $t1
	addi $t4, $0, 0				# counter to draw nhorA
nhorD:
	addi $t3, $0, 0				# counter to draw hor.
horD:
	sw $t9, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 17, horD
	addi $t2, $t1, 40
	addi $t4, $t4, 1
	bne $t4, 2, nhorD
	# Letter E:
	addi $t1, $t0, 134176			# $t1 = grid to draw.
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nverA.
nverE:
	addi $t3, $0, 0				# counter to draw verA.
verE:
	sw $t9, ($t2)
	addi $t2, $t2, 4
	addi $t3, $t3, 1
	bne $t3, 10, verE
	addi $t2, $t2, 8152
	addi $t4, $t4, 1
	bne $t4, 3, nverE
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nhorA.
nhorE:
	addi $t3, $0, 0				# counter to draw hor.
horE:
	sw $t9, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 17, horE
	addi $t2, $t1, 40
	addi $t4, $t4, 1
	bne $t4, 1, nhorE
	# Letter F:
	addi $t1, $t0, 159776			# $t1 = grid to draw.
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nverA.
nverF:
	addi $t3, $0, 0				# counter to draw verA.
verF:
	sw $t9, ($t2)
	addi $t2, $t2, 4
	addi $t3, $t3, 1
	bne $t3, 10, verF
	addi $t2, $t2, 8152
	addi $t4, $t4, 1
	bne $t4, 2, nverF
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nhorA.
nhorF:
	addi $t3, $0, 0				# counter to draw hor.
horF:
	sw $t9, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 17, horF
	addi $t2, $t1, 40
	addi $t4, $t4, 1
	bne $t4, 1, nhorF
	# Letter G:
	addi $t1, $t0, 185376			# $t1 = grid to draw.
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nverA.
nverG:
	addi $t3, $0, 0				# counter to draw verA.
verG:
	sw $t9, ($t2)
	addi $t2, $t2, 4
	addi $t3, $t3, 1
	bne $t3, 10, verG
	addi $t2, $t2, 16344
	addi $t4, $t4, 1
	bne $t4, 2, nverG
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nhorA.
nhorG:
	addi $t3, $0, 0				# counter to draw horG.
horG:
	sw $t9, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 17, horG
	addi $t2, $t1, 40
	addi $t4, $t4, 1
	bne $t4, 2, nhorG
	addi $t2, $t1, 1064
	addi $t3, $0, 0				# counter to draw olG.
olG:
	sw $t6, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 8, olG
	# Letter H:
	addi $t1, $t0, 210976			# $t1 = grid to draw.
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nverA.
nverH:
	addi $t3, $0, 0				# counter to draw verA.
verH:
	sw $t9, ($t2)
	addi $t2, $t2, 4
	addi $t3, $t3, 1
	bne $t3, 10, verH
	addi $t2, $t2, 8152
	addi $t4, $t4, 1
	bne $t4, 2, nverH
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nhorA.
nhorH:
	addi $t3, $0, 0				# counter to draw hor.
horH:
	sw $t9, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 17, horH
	addi $t2, $t1, 40
	addi $t4, $t4, 1
	bne $t4, 2, nhorH
	addi $t2, $t1, 4
	addi $t3, $0, 0				# counter to draw olH.
olH:
	sw $t6, ($t2)
	addi $t2, $t2, 4
	addi $t3, $t3, 1
	bne $t3, 9, olH
	# number 1:
	addi $t1, $t0, 6276			# $t1 = grid to draw.
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t2, $t2, 44
	addi $t3, $0, 0
hor1:
	sw $t9, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 17, hor1
	# number 2:
	addi $t1, $t0, 6384			# $t1 = grid to draw.
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nverA.
nver2:
	addi $t3, $0, 0				# counter to draw verA.
ver2:
	sw $t9, ($t2)
	addi $t2, $t2, 4
	addi $t3, $t3, 1
	bne $t3, 10, ver2
	addi $t2, $t2, 8152
	addi $t4, $t4, 1
	bne $t4, 3, nver2
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nhorA.
nhor2:
	addi $t3, $0, 0				# counter to draw hor.

hor2:
	sw $t9, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 17, hor2
	addi $t2, $t1, 40
	addi $t4, $t4, 1
	bne $t4, 2, nhor2
	addi $t2, $t1, 1024
	addi $t3, $0, 0				# counter to draw olG.
ol2:
	sw $t6, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 7, ol2
	addi $t2, $t1, 9256
	addi $t3, $0, 0				# counter to draw olG.
ol22:
	sw $t6, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 7, ol22
	# number 3:
	addi $t1, $t0, 6488			# $t1 = grid to draw.
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nverA.
nver3:
	addi $t3, $0, 0				# counter to draw verA.
ver3:
	sw $t9, ($t2)
	addi $t2, $t2, 4
	addi $t3, $t3, 1
	bne $t3, 10, ver3
	addi $t2, $t2, 8152
	addi $t4, $t4, 1
	bne $t4, 3, nver3
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nhorA.
nhor3:
	addi $t3, $0, 0				# counter to draw hor.
	addi $t2, $t1, 40
hor3:
	sw $t9, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 17, hor3
	# number 4:
	addi $t1, $t0, 6592			# $t1 = grid to draw.
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nverA.
nver4:
	addi $t3, $0, 0				# counter to draw verA.
ver4:
	sw $t9, ($t2)
	addi $t2, $t2, 4
	addi $t3, $t3, 1
	bne $t3, 10, ver4
	addi $t2, $t2, 8152
	addi $t4, $t4, 1
	bne $t4, 2, nver4

	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nhorA.
nhor4:
	addi $t3, $0, 0				# counter to draw hor.
hor4:
	sw $t9, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 17, hor4
	addi $t2, $t1, 40
	addi $t4, $t4, 1
	bne $t4, 2, nhor4
	addi $t2, $t1, 4
	addi $t3, $0, 0				# counter to draw olH.
ol4:
	sw $t6, ($t2)
	addi $t2, $t2, 4
	addi $t3, $t3, 1
	bne $t3, 9, ol4
	addi $t2, $t1, 9216
	addi $t3, $0, 0				# counter to draw olH.
ol42:
	sw $t6, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 9, ol42
	# number 5:
	addi $t1, $t0, 6696			# $t1 = grid to draw.
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nverA.
nver5:
	addi $t3, $0, 0				# counter to draw verA.
ver5:
	sw $t9, ($t2)
	addi $t2, $t2, 4
	addi $t3, $t3, 1
	bne $t3, 10, ver5
	addi $t2, $t2, 8152
	addi $t4, $t4, 1
	bne $t4, 3, nver5
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nhorA.
nhor5:
	addi $t3, $0, 0				# counter to draw hor.
hor5:
	sw $t9, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 17, hor5
	addi $t2, $t1, 40
	addi $t4, $t4, 1
	bne $t4, 2, nhor5
	addi $t2, $t1, 1064
	addi $t3, $0, 0				# counter to draw olG.
ol5:
	sw $t6, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 7, ol5
	addi $t2, $t1, 9216
	addi $t3 $0, 0				# counter to draw olG.
ol52:
	sw $t6, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 7, ol52
	# number 6:
	addi $t1, $t0, 6800			# $t1 = grid to draw.
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nverA.
nver6:
	addi $t3, $0, 0				# counter to draw verA.
ver6:
	sw $t9, ($t2)
	addi $t2, $t2, 4
	addi $t3, $t3, 1
	bne $t3, 10, ver6
	addi $t2, $t2, 8152
	addi $t4, $t4, 1
	bne $t4, 3, nver6
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nhorA.
nhor6:
	addi $t3, $0, 0				# counter to draw hor.
hor6:
	sw $t9, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 17, hor6
	addi $t2, $t1, 40
	addi $t4, $t4, 1
	bne $t4, 2, nhor6
	addi $t2, $t1, 1064
	addi $t3, $0, 0				# counter to draw olG.
ol6:
	sw $t6, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 7, ol6
	# number 7:
	addi $t1, $t0, 6904			# $t1 = grid to draw.
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nverA.
nver7:
	addi $t3, $0, 0				# counter to draw verA.
ver7:
	sw $t9, ($t2)
	addi $t2, $t2, 4
	addi $t3, $t3, 1
	bne $t3, 10, ver7
	addi $t2, $t2, 16344
	addi $t4, $t4, 1
	bne $t4, 1, nver7
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nhorA.
nhor7:
	addi $t3, $0, 0				# counter to draw hor.
	addi $t2, $t1, 40
hor7:
	sw $t9, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 17, hor7
	addi $t2, $t1, 40
	addi $t4, $t4, 1
	bne $t4, 1, nhor7
	# number 8:
	addi $t1, $t0, 7008			# $t1 = grid to draw.
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nverA.
nver8:
	addi $t3, $0, 0				# counter to draw verA.
ver8:
	sw $t9, ($t2)
	addi $t2, $t2, 4
	addi $t3, $t3, 1
	bne $t3, 10, ver8
	addi $t2, $t2, 8152
	addi $t4, $t4, 1
	bne $t4, 3, nver8
	addi $t2, $t1, 0			# $t2  = copy of $t1.
	addi $t4, $0, 0				# counter to draw nhorA.
nhor8:
	addi $t3, $0, 0				# counter to draw hor.
hor8:
	sw $t9, ($t2)
	addi $t2, $t2, 1024
	addi $t3, $t3, 1
	bne $t3, 17, hor8
	addi $t2, $t1, 40
	addi $t4, $t4, 1
	bne $t4, 2, nhor8
	jr $ra

##### Game start sound.
sound_game_start:
	# Preservation:
	addi $sp, $sp, -16 			# allocate stack space.
        sw  $a0, 0($sp)				# will be used for sound pitch.
        sw  $a1, 4($sp)				# will be used for sound duration.	
        sw  $a2, 8($sp)				# will be used for sound instrument.	
        sw  $a3, 12($sp)			# will be used for sound volume.	
        # Sound generation:
	li $v0, 33
	li $a0, 0				# pitch.
	li $a1, 300				# duration in milisecond.
	li $a2, 0				# instrument.
	li $a3, 0				# volume.
	syscall
	li $v0, 33
	li $a0, 80				# pitch.
	li $a1, 150				# duration in milisecond.
	li $a2, 24				# instrument.
	li $a3, 400				# volume.
	syscall
	li $v0, 33
	li $a0, 90				# pitch.
	li $a1, 150				# duration in milisecond.
	li $a2, 24				# instrument.
	li $a3, 400				# volume.
	syscall
	li $v0, 33
	li $a0, 100				# pitch.
	li $a1, 150				# duration in milisecond.
	li $a2, 24				# instrument.
	li $a3, 400				# volume.
	syscall
	li $v0, 33
	li $a0, 110				# pitch.
	li $a1, 150				# duration in milisecond.
	li $a2, 24				# instrument.
	li $a3, 400				# volume.
	syscall
	li $v0, 33
	li $a0, 90				# pitch.
	li $a1, 150				# duration in milisecond.
	li $a2, 24				# instrument.
	li $a3, 400				# volume.
	syscall
	li $v0, 33
	li $a0, 110				# pitch.
	li $a1, 1000				# duration in milisecond.
	li $a2, 24				# instrument.
	li $a3, 400				# volume.
	syscall
	# Restoration:
        lw  $a0, 0($sp)
        lw  $a1, 4($sp)
        lw  $a2, 8($sp)
        lw  $a3, 12($sp)
    	addi $sp, $sp, 16			# free stack space.
	jr  $ra     				# return back, no return value from function.

##### Correct move sound.
sound_move_ok:
	# Preservation:
	addi $sp, $sp, -16 			# allocate stack space.
        sw  $a0, 0($sp)				# will be used for sound pitch.
        sw  $a1, 4($sp)				# will be used for sound duration.	
        sw  $a2, 8($sp)				# will be used for sound instrument.	
        sw  $a3, 12($sp)			# will be used for sound volume.	
        # Sound generation:
	li $v0, 33
	li $a0, 0				# pitch.
	li $a1, 300				# duration in milisecond.
	li $a2, 0				# instrument.
	li $a3, 0				# volume.
	syscall
	li $v0, 33
	li $a0, 90				# pitch.
	li $a1, 2000				# duration in milisecond.
	li $a2, 114				# instrument.
	li $a3, 400				# volume.
	syscall
	# Restoration:
        lw  $a0, 0($sp)
        lw  $a1, 4($sp)
        lw  $a2, 8($sp)
        lw  $a3, 12($sp)
    	addi $sp, $sp, 16			# free stack space.
    	jr  $ra     				# return back, no return value from function.

    	 
    	
	
