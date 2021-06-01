#Project title:  LAB02 | ECE201
#Year:           2019-2020 | 3rd Semester
#Author:         Dimitrios Petrou
#A.M.:           2018030070
#Date:           14/10/2019
#Project job:    Read 2 integers and do the operation that the user specifies
#Known-bugs:     None 
#----------------------------------------------------------------------------------

#---------------------------- Use of registers policy -----------------------------
#The code uses the $v0 and $a0 registers only for communication with the OS,
#registers of the type $sX and $tX are used for storing the two numbers, the result
#and the operator. The 'j" (jump) command is used for appropriate case handling and
#label linking. We mostly prefer the call-preserved registers of $sX type. 
#----------------------------------------------------------------------------------

#Data section of the code

.data
prompt0: .asciiz "Please enter the first number: "               #Prompt message for entering the first number
prompt1: .asciiz "\nPlease enter the desired operation: "        #Prompt message for entering the operator
prompt2: .asciiz "\nPlease enter the second number: "            #Prompt message for enterign the second number
errorMes: .asciiz "\nFATAL ERROR | Unknown operator"             #Informing message about unknown operator
errorDivMes: .asciiz "\nFATAL ERROR | Never divide by 0(zero)"   #Informing message about unknown operator
resultMes: .asciiz "\nThe result of the operation equals: "      #Informing message about the result

opuser: .space 2                 #Allocated space for the user input (one byte for the operator and one for the EOS)
opadd: .asciiz "+"               #Labels for the +,-,*,/ operators. They will be loaded later in some registers
opsub: .asciiz "-"               #(in ASCII form). We wil be using those ASCII values for comparison and case handling
opmul: .asciiz "*"               #
opdiv: .asciiz "/"               #

#Text section of the code

.text
   main: #MAIN Label
 
        #----- Reading the first number ---------------------------------------------------------------
        li $v0, 4             #Telling the OS that we want to print a string
        la $a0, prompt0       #Specifing the string we want to print by specifing its address
        syscall               #Executing

        li $v0, 5             #Telling the OS that we want to read an integer
        syscall               #Executing

        move $s0, $v0         #Storing the number entered from the user to call-preserved register $s0
        #----------------------------------------------------------------------------------------------



        #----- Reading the user operator --------------------------------------------------------------
        li $v0, 4             #Telling the OS that we want to print a string
        la $a0, prompt1       #Specifing the string we want to print by specifing its address
        syscall               #Executing

        li $v0, 8             #Telling the OS that we want to read a string
        la $a0, opuser        #Specifing the label that it will be caried by
        li $a1 ,2             #Specifing the allowed space
        syscall               #Executing

        lb $s2, opuser        #Storing the operator the user added before to call-preserved register $s2 
                              #(only the least significant byte)
        #----------------------------------------------------------------------------------------------


        #----- Loading comparison standards -----------------------------------------------------------
        lb $s3, opadd         #Storing the +, -, *, / operators in call-preserved
        lb $s4, opsub         #registers $s3, $s4, $s5, $s6 (again only the least significant bytes)
        lb $s5, opmul         #
        lb $s6, opdiv         #
        syscall               #Executing
        #----------------------------------------------------------------------------------------------


        #----- Reading the second number --------------------------------------------------------------
        li $v0, 4             #Telling the OS that we want to print a string
        la $a0, prompt2       #Specifing the string we want to print by specifing its address
        syscall               #Executing

        li $v0, 5             #Telling the OS that we want to read an integer
        syscall               #Executing

        move $s1, $v0         #Storing the number entered from the user to call-preserved register $s1
        #----------------------------------------------------------------------------------------------


        #----- Case handling --------------------------------------------------------------------------

        beq $s2,$s3, PLUS      #If the user operator is + then add the two numbers by jumping to PLUS label
        beq $s2,$s4, MINUS     #If the user operator is - then subtract the two numbers by jumping to MINUS label
        beq $s2,$s5, MUL       #If the user operator is * then multiply the two numberS by jumping to MUL LABEL
        beq $s2,$s6, CHECKDIV  #If the user operator is / then proceed to check if the divider equals zero
        j ERROR                #Otherwise jump to ERROR unknown operator label and print message

        #----------------------------------------------------------------------------------------------


        #----- Labels Used ----------------------------------------------------------------------------

        CHECKDIV:                      #CHECKDIV LABEL
           beq $s1, $zero, ERRORDIV    #If the divider of the div operation is 0 then jump to ERRORDIV message
           j DIV                       #Otherwise jump to DIV LABEL

        PLUS:                 #ADD LABEL
           add $s0,$s0,$s1    #Add the values of s0 and s1 and store the result in s0
           j PRINT            #Then jump to PRINT label and print the result
           syscall            #Executing
         
        MINUS:                #SUBTRACT LABEL
           sub $s0,$s0,$s1    #Subtract the values of s0 and s1 and store the result in s0
           j PRINT            #Then jump to PRINT label and print the result
           syscall            #Executing

        MUL:                  #MULTIPLY LABEL
           mul $s0,$s0,$s1    #Multiply the values of s0 and s1 and store the result in s0
           j PRINT            #Then jump to PRINT label and print the result
           syscall            #Executing
        
        DIV:                  #DIVIDE LABEL
           div $s0,$s0,$s1    #Divide the values of s0 and s1 and store the result in s0
           j PRINT            #Then jump to PRINT label and print the result
           syscall            #Executing

        PRINT:                #PRINT LABEL
           li $v0, 4          #Telling the OS that we want to print a String
           la $a0, resultMes  #Specifing the string, in this case it is the result message
           syscall            #Executing

           li $v0, 1          #Telling the OS that we want to print an integer
           move $a0, $s0      #Bringing the integer in a0 to give it as an argument
           syscall            #Executing

           j EXIT             #Then exit the program
           syscall            #Executing jump to EXIT label

        ERRORDIV:
           li $v0, 4            #Telling the OS that we want to print a string
           la $a0, errorDivMes  #Specifing the string, in this case it is the error message
           syscall              #Executing

           j EXIT
           syscall          

        ERROR:                #ERROR LABEL
           li $v0, 4          #Telling the OS that we want to print a string
           la $a0, errorMes   #Specifing the string, in this case it is the error message
           syscall            #Executing

        #----------------------------------------------------------------------------------------------

        EXIT:                 #EXIT LABEL
           li $v0, 10         #Telling the OS that we want to stop running the MAIN Label 
           syscall            #Executing
