#----------------------------------------------------------------------------------
#Project title:  LAB05 | ECE201
#Year:           2019-2020 | 3rd Semester
#Authors:        Dimitris Petrou
#Date:           10/12/2019
#Project job:    Recursive fibonacci number calculator
#Known-bugs:     None 
#Assembler:      QtSpim MIPS
#----------------------------------------------------------------------------------

#.data Section of the program
.data
userPrompt: .asciiz "\nPlease enter a number in the range 0-24: "
mainMenu: .asciiz "--------------------- Fibo Calculator --------------------\nEnter Q to quit, or any other letter to continue: "
dashes: .asciiz "\n----------------------------------------------------------\n\n"
.align 2
fiboResult: .asciiz "\nThe Fibonacci number F   is: "
rangeException: .asciiz "The number you entered is outside the allowable range!\n"
entryException: .asciiz "\nUnknown entry! Please try again..."
.align 2
userChoice: .space 4

#.text Section of the program
.text
  main:
    
    #---- Loop for repeating the programm until the user gives Q ---------------#
    while:
       
      #---- Temporal registers | Use policy | main ---------------#
      # $t0 : contains the MSByte of the user's input
      # $t1 : contains the user's number
      #-----------------------------------------------------------#

      #---- Call of the Get_String subroutine -------------------------------------------#
      jal Get_String       #Call the subroutine      
      move $t0,$v0         #Getting the return value of the subroutine
      #----------------------------------------------------------------------------------#

      beq $t0,0x51,EXIT    #Exit if the user's input was Q

      #---- Call of the subroutine Get_Number -------------------------------------------#
      jal Get_Number
      move $s0, $v0        #Store the user's number in global reg $s0
      #----------------------------------------------------------------------------------#

      bgt $s0, 0x18, outOfRange   #If the number is greater than 24 then display error
      blt $s0, $zero, outOfRange  #If the number is less than 0 then display error

      move $s1,$sp           #Restoring the stack's starting address 

      #---- Call of the Fibo subroutine -------------------------------------------------#
      move $a0, $s0          #Giving the user's number as an argument
      jal Fibo               #Call the Fibo 
      move $s2,$v0           #Store the return type of Fibo
      #----------------------------------------------------------------------------------#

      move $sp,$s1           #Return  to stack's start

      #---- Call of the Parse_String subroutine -----------------------------------------#
      move $a0,$s0           #Give the user number as an argument 
      la $a1,fiboResult      #Give the result string address as an argument
      jal Parse_String       #Call the Parse_String
      #----------------------------------------------------------------------------------#

      #---- Print the result string -----------------------------------------------------#
      li $v0,4               #Telling the OS that we want to print a string
      la $a0,fiboResult      #Specifing the string's address
      syscall                #I/O Call
      #----------------------------------------------------------------------------------#

      #---- Print the Fibo result -------------------------------------------------------#
      li $v0,1               #Telling the OS that we want to print an integer
      move $a0,$s2           #Specifing the integer
      syscall                #I/O Call
      #----------------------------------------------------------------------------------#

      repeatwhile:
        li $v0,4            
        la $a0,dashes
        syscall

    j while

    outOfRange:
      li $v0,4                #Telling the OS that we want to read a astring
      la $a0,rangeException   #Specifing the string's address
      syscall                 #I/0 Call
      j repeatwhile           #Return to the loop
    #---------------------------------------------------------------------------#
    

    #---- Label for exiting the programm ----------#
    EXIT:
      li $v0,10
      syscall
    #----------------------------------------------#
    ########################################## MAIN ENDS HERE ###########################################

    
    #---- Subroutine for getting command from the user ------------------------------------------------------#
    Get_String:

      #---- Printing user prompt message ---------------------------------------
      li $v0,4             #Telling the OS that we want to print a string
      la $a0,mainMenu      #Specifing string's address
      syscall              #I/O Call
      #-------------------------------------------------------------------------

      #---- Reading the user's choice ------------------------------------------
      li $v0,8             #Telling the OS that we want to read a string  
      la $a0, userChoice   #Specifing the buffer's address
      li $a1,4             #Specifing the length of the string
      syscall              #I/0 Call
      #-------------------------------------------------------------------------

      lb $v0, 0($a0)       #Return the user's choice in v0
      
      jr $ra               #Return command of the subroutine
    #--------------------------------------------------------------------------------------------------------#

    
    #---- Subroutine for getting number ---------------------------------------------------------------------#
    Get_Number:

     #---- Printing user prompt message ----------------------------------------
      li $v0,4             #Telling the OS that we want to print a string
      la $a0,userPrompt    #Specifing string's address
      syscall              #I/O Call
      #-------------------------------------------------------------------------

      #---- Reading the user's choice ------------------------------------------
      li $v0,5             #Telling the OS that we want to read an integer 
      syscall              #I/0 Call
      #-------------------------------------------------------------------------
      
      jr $ra               #Return command of the subroutine
    #--------------------------------------------------------------------------------------------------------#


    #---- Subroutine for converting int to string  and storing it in the result string ----------------------#
    Parse_String:
      move $t0,$a0              #Get the int argument 
      move $t1,$a1              #Get the buffer .space address argument
      addi $t1,$t1,23           #Move to the point where we need to write the number in the result string

      blt $t0,10,parseUnder10   #If the number is less than 10 then jump to parseUnder10
      bgt $t0,10,parseOver10    #If the number is greater than 10 then jump to parseOver10
      beq $t0,10,parse10        #If the number is 10 then jump to parse10

      parseUnder10:
        li $t8,0x30             #Load the '0' in t8
        sb $t8,0($t1)           #Store '0' before the single-digit number
        addi $t0,$t0,48         #Convert $t0 number to ascii
        sb $t0,1($t1)           #Store the ascii digit in the result string
        j exitparse             #Exit

      parseOver10:
        div $t6,$t0,10          #Divide the double-digit number by and get the quotient
        mfhi $t7                #Get the remainder of the division

        addi $t6,$t6,48         #Convert quotient to ascii digit
        addi $t7,$t7,48         #Convert remainder to ascii digit
 
        sb $t6,0($t1)           #Store the first digit in the result string
        sb $t7,1($t1)           #Store the second digit in the result string

        li $t7,0x20             #Load the ' ' ascii in t7
        sb $t7,2($t1)           #Store the ' ' in the result string
        j exitparse             #Exit

      parse10:
        li $t6,0x31             #Load the '1' ascii digit in t6
        li $t7,0x30             #Load the '0' ascii digit in t7
        sb $t6,0($t1)           #Store the '1' in the ascii string
        sb $t7,1($t1)           #Store the '0' in the ascii string

      exitparse:                #Exit label
        li $v0,0                  #Return type of the subroutine
        jr $ra                    #Return command of the subroutine
    #--------------------------------------------------------------------------------------------------------#


    #---- Subroutine for calculating recursively the fibonacci sum of a number ------------------------------#
    Fibo:
    
    beq $a0,0,F0           #Return F0=0
    beq $a0,1,F1           #Return F1=1

    #---- Calculation of F(n-1) ------------------------------------------#
    addi $sp,$sp,-4        #Allocating space in stack for the ra
    sw $ra,0($sp)          #Storing the return address in stack 

    addi $a0,$a0,-1        #Creating the term n-1
    jal Fibo               #Calling recursively Fibo
    
    lw $ra,0($sp)          #Recalling the ra from the stack
    
    addi $a0,$a0,1         #Remaking the n term by adding 1 to n-1
    addi $sp,$sp,4         #Restoring the $sp one word behind

    addi $sp,$sp,-4        #Allocating one word for storing the F(n-1) 
    sw $v0,0($sp)          #Storing the F(n-1) in stack
    #---------------------------------------------------------------------#

    #---- Calculation of F(n-2) ------------------------------------------#
    addi $sp,$sp,-4        #Allocating space in stack for the ra
    sw $ra,0($sp)          #Storing the return address in stack

    addi $a0,$a0,-2        #Creating the term n-2
    jal Fibo               #Calling recursively Fibo
    
    lw $ra,0($sp)          #Recalling the ra from the stack

    addi $a0,$a0,2         #Remaking the n term by adding 2 to n-2
    addi $sp,$sp,4         #Restoring the $sp one word behind
    #---------------------------------------------------------------------#


    lw $t0,0($sp)          #Recalling the F(n-1) from the stack
    addi $sp,$sp,4         #Restoring the $sp one word behind

    add $v0,$v0,$t0        #Calculate F(t)=F(t-1)+F(t-2)

    j EXIT_FIB             #Return

    F0:
     li $v0,0
     j EXIT_FIB
    F1:
     li $v0,1
     j EXIT_FIB    

    EXIT_FIB:

    jr $ra
    #--------------------------------------------------------------------------------------------------------#