#----------------------------------------------------------------------------------
#Project title:  LAB03 | ECE201
#Year:           2019-2020 | 3rd Semester
#Authors:        Dimitris Petrou - Alexandros Avraam
#Date:           8/11/2019
#Project job:    String processor, space limiter and capital to low-case converter
#Known-bugs:     None 
#Assembler:      QtSpim MIPS
#----------------------------------------------------------------------------------

#Data section of the code

.data 
offset: .word 0                                  #TESTING VARIABLE-NOT A PART OF THE CODE
prompt: .asciiz "Please enter your string:  "    #Prompt message for the user
result: .asciiz "\nThe processed string is:  "   #Message printed followed by the converted string
.align 2
userInput: .space 100                            #Pre-allocated space for the user input
.align 2
wordOutput: .space 100                           #Pre-allocated space for the converted string


#Text section of the code

.text 
   main:                   #MAIN Label
     jal Get_Input         #Calling the subroutine for input reading
     jal Process           #Calling the subroutine for string processing 
     jal Print_Output      #Calling the subroutine for output printing

     li $v0,10             #Tellin the OS that we want to terminate the program
     syscall               #I/O Call

   #Subroutine for prompt and input reading
   Get_Input:
     #---- Printing prompt message ------------------------------------------------------
     li $v0, 4               #Telling the OS that we want to print a string
     la $a0, prompt          #Specifing the string that we want to print by its address
     syscall                 #I/O call
     #-----------------------------------------------------------------------------------

     #---- Reading the string that the user entered -------------------------------------
     li $v0, 8               #Telling the OS that we want to read a string
     la $a0, userInput       #Specifing the address in which it will be stored
     li $a1, 100             #Specifing its length
     syscall                 #I/O call

     jr $ra                  #Subroutine return command
                             #The subroutine ends here
     #-----------------------------------------------------------------------------------
  

   #Subroutine for the string 
   # $t0: contains the 4byte-word of the string which is currently processed
   # $t1: contains the byte which is currently processed
   # $t2: contains the memory address pointer for the userInput
   # $t3: contains the memory address pointer for the wordOutput
   # $t4: used with a true/false convention, so we can know when we are in a word (FFFFFFFF=true/12345678=false)
   # $t6: used with a true/false convention, so we can know when a space between has been written (FFFFFFFF=true/11111111=false)
   #------------------------------------------------------------------------------------------------------------------------
   Process:
     la $t2, userInput     #Memory pointer for word input
     la $t3, wordOutput    #Memory pointer for word output


    while:
     beq $t1,0x0a,exit     #If '\n' is found then exit, because it defines the end of the string

     lw $t0, 0($t2)        #Load the upper bytes of the word in process
     addi $t2,$t2, 4       #Move the pointer to the next 4 bytes
 
     li $t1, 1             #Initializing $t1 register, which keeps the byte that is processed 

     loop:
      beq $t4, 0xFFFFFFFF, initialize       #If we are in a word then we reset the space_has_been written register
      
      return:                      #Return label after the initialization of t6

      andi $t1, $t0, 0x000000ff    #Masking the current word and keeping only the first byte (Little Endian) in $t1
      beq $t1, 0x00, while         #If the current byte is 0 then move to the next word. That happens because every time 
                                   #a set of 4 bytes is successfully processed the $t1 is being left at 0
      beq $t1, 0x0a, while         #If the current byte is LF, then jump to while

      #Symbols check
      beq $t1,0x20, spacewrite  #Check for space ' ' 
      beq $t1,0x24, spacewrite  #Check for symbol '$'
      beq $t1,0x25, spacewrite  #Check for symbol '%'
      beq $t1,0x26, spacewrite  #Check for symbol '&'
      beq $t1,0x28, spacewrite  #Check for symbol '('
      beq $t1,0x29, spacewrite  #Check for symbol ')'
      beq $t1,0x2a, spacewrite  #Check for symbol '*'
      beq $t1,0x5e, spacewrite  #Check for symbol '^'

      blt $t1,0x61, convertcapital    #If the current byte is a character less than 61 in ascii code 
                                      #then its possibly an upper case letter and we need to convert it
      j store                         #Store an alphanumerical character
 
      storespace:               #Seperate label for storing spaces because we dont want to
        sb $t1,0($t3)           #reset the $t4 register when writing a space
        j afterstorespace       #Then continue to the next bytes via the known process

      store:   
        li $t4, 0xffffffff            #Updating the $t4 register that we are in a word
        sb $t1,0($t3)                 #Storing the current byte from $t1 to the memory address contained in $t3
                                      #by zero offset

      afterstorespace:                #Bypass label for when storing spaces
        addi $t3, $t3, 1              #Moving the pointer of the output space 100, by 1 byte

      continue: 
        srlv $t0, $t0, 8              #Brings the bits to the right by 1 HEX position

     j loop

    spacewrite:      
       li $t4, 0x12345678              #Updating the $t4 that we are not in word, because a symbol or space was read
       beq $t6,0xFFFFFFFF, continue    #If a space, is already written then don't store it, simply move to the next byte
       li $t6, 0xFFFFFFFF              #When the first space needs to be written, update the $t6 to a conventional true value
       li $t1, 0x20                    #Load the space ascii code in $t1
       j storespace                    #Store the space and continue
    
    convertcapital:  
       blt $t1 ,0x41, store            #Check if the character is not a letter, if it isn't then simply store it
       addi $t1,$t1,0x20               #Otherwise, taking advantage of the ascii code, we add 20 to the current 
                                       #content of the register $t1. The lower and the upper forms of a letter in 
                                       #the ascii code have a distance of 20.
       j store                         #After converting the letter to lower case, store it

    initialize: 
       li $t6, 0x11111111               #We use the $t6 register as a true/false value so can know when a space between
                                        #two words has been written or not.
       j return                         

    exit:
       li $t1,0x0a                     #Every word ends with a LF. Load the ascii LF in $t1
       sb $t1,0($t3)                   #Store it at the end of the wordOutput

    jr $ra                             #Return command of the subroutine
                                       #The subroutine ends here
    #------------------------------------------------------------------------------------------------------------------------                            

     

   #Subroutine for printing the processed string
   Print_Output:
     #---- Printing output message ------------------------------------------------------
     li $v0, 4               #Telling the OS that we want to print a string
     la $a0, result          #Specifing the string that we want to print by its address
     syscall                 #I/O Call
     #-----------------------------------------------------------------------------------

     #---- Printing the processed string ------------------------------------------------
     li $v0, 4               #Telling the OS that we want to print a string
     la $a0, wordOutput      #Specifing the string that we want to print by its address
     syscall                 #I/O Call 
     
     jr $ra                  #Subroutine return command
                             #The subroutine ends here
     #-----------------------------------------------------------------------------------




