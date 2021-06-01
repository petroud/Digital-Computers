#----------------------------------------------------------------------------------
#Project title:  LAB04 | ECE201
#Year:           2019-2020 | 3rd Semester
#Authors:        Dimitris Petrou
#Date:           25/11/2019
#Project job:    Phone Book Managing Software
#Known-bugs:     None 
#Assembler:      QtSpim MIPS
#----------------------------------------------------------------------------------


#.data Section of the program
.data
userPrompt: .asciiz "\nPlease determine operation, entry (E), inquiry (I) or quit (Q):  "
lastNamePrompt: .asciiz "Please enter last name: "
firstNamePrompt: .asciiz "Please enter first name: " 
phonePrompt: .asciiz "Please enter phone number: "
printEntryPrompt: .asciiz "\nPlease enter the entry number you wish to retrieve: "
printEntry: .asciiz "The entry you asked for is: \n"
fullStack: .asciiz "The phone book is full!\n"
errorEntry: .asciiz "The entry you asked does not exist!\n"
newEntry: .asciiz "\nThank you, the new entry is the following: \n"
errorChoice: .asciiz "This is not an option! Please try again...\n\n"
entryChoice: .space 3
userChoice: .space 10
.align 2
currentEntry: .space 20
.align 2
bufferSpace: .space 60
.align 2
stackBook: .space 600

#---- Global Registers | Use policy --------------------------------#
# $s0 : Used as a pointer to the buffer .space 60
# $s2 : Used for counting how many entries we currently have
# $s3 : Used as a stack pointer for the stack of entries
# $s4 : Used as an iteration stack pointer for the entries stack
#-------------------------------------------------------------------#

#.text Section of the program
.text
  main:
    
    li $s2,1

    #---- Self made stack, pointers declaration ---------------------------------#
    la $s3,stackBook           #Stack pointer for phone book stack
    move $s4, $s3              #Pointer for iteration through the stack
    #----------------------------------------------------------------------------#

    while:        
      #---- Call for Prompt_User Subroutine -------------------------------------#
      jal Prompt_User          #Calling the subroutine
      move $t0, $v0            #Storing the returned value in $t0
      #--------------------------------------------------------------------------#
      
      #---- User choice case handling -------------------------------------------#
      beq $t0, 0x51,EXIT       #If user's choice is 'Q' then exit
      beq $t0, 0x45,GET        #If user's choice is 'E' then jump to GET_ENTRY
      beq $t0, 0x49,PRINT      #If user's choice is 'I' then jump to PRINT_ENTRY
      j ERROR                  #If none of the above is true then display error
      #--------------------------------------------------------------------------#


      #---- 'Call of the the Get_Entry subroutine' label ------------------------#
      GET:
        bgt $s2,10,FULLBOOK
        jal Get_Entry 
        j while                #When the program returns it begins again until 'Q'
      #--------------------------------------------------------------------------#

      #---- 'Call of the the Get_Entry subroutine' label ------------------------#
      PRINT:
        jal Print_Entry 
        j while                #When the program returns it begins again until 'Q'
      #--------------------------------------------------------------------------#


      #---- Printing an error message when the user choice is not valid ---------#
      ERROR:                 
        li $v0, 4              #Telling the OS that we want to print a string
        la $a0, errorChoice    #Specifing the string's address
        syscall                #I/O Call
      #--------------------------------------------------------------------------#
   j while
      
      #---- Printing an error message when the phone book is full ---------------#
      FULLBOOK:
        li $v0, 4              #Telling the OS that we want to print a string
        la $a0, fullStack      #Specifing the string's address
        syscall                #I/O Call
        j while
      #--------------------------------------------------------------------------#

      EXIT:
        li $v0,10
        syscall


  #---- Subroutine for prompting the user to select an operation and after that for storing the choice ---#
  Prompt_User:   

    #---- Printing prompt message ----------------------------------------------------------
    li $v0, 4              #Letting the OS know that we want to print a string
    la $a0, userPrompt     #Giving the string's address as an argument 
    syscall                #I/O Call
    #---------------------------------------------------------------------------------------

    #---- Reading the user choice ----------------------------------------------------------
    li $v0, 8              #Letting the OS know that we want to read a string
    la $a0, userChoice     #Giving the userChoice address as an argument
    li $a1, 10             #Specifing the length of the string that we want to read
    syscall                #I/O 
                           
    lb $v0, 0($a0)         #Storing the first byte of the user choice in v0 for return
                           #There is no need to give an argument for the byte-storing 
                           #because we already did in the reading part (la $a0, userChoice)
    #---------------------------------------------------------------------------------------

    jr $ra                 #Return command of the subroutine
                           #Subroutine ends here
  #-------------------------------------------------------------------------------------------------------#



  #### Subroutine for getting the user's input for a new catalog entry ####################################################################
  Get_Entry: 
    la $s0, bufferSpace

    #---- Loop for cleaning the buffer .space 60 (repeated 60 times) ------------------------------------------------#
    la $t8, bufferSpace        #Loading the address of the bufferSpace in $t8 register
    la $t9,0                   #Loading 0 in $t9 as a start value for our loop counter

    empty:
      beq $t9,60, continue     #If the loop has been repeated for 60 times then go on with the get_entry subroutine
      sb $zero,0($t8)          #Storing a null value at the current byte of the buffer .space 60
      addi $t8,$t8,1           #Moving the address pointer to the next byte
      addi $t9,$t9,1           #Adding 1 to our loop counter
    j empty
    #----------------------------------------------------------------------------------------------------------------#

    continue:
    li $t8,0                   #Cleaning the $t8 register after the clearance of the buffer .space 60 
    li $t9,0                   #Cleaning the $t8 register after the clearance of the buffer .space 60 

    #---- Store the 'X. ' before the registration. X is the unique number of each registration ----------------------#
    beq $s2,0xA,store2digit
    addi $t7,$s2,48            # $s2 contains the counter of entries in int type we convert it to ascii
    sb $t7,0($s0)              #Storing the number of entry in bufferSpace via its pointer
    addi $s0,$s0,1             #Moving the pointer of the bufferspace by 1 byte
    j storedot

    store2digit:
    li $t7, 0x3031
    sw $t7,0($s0)
    addi $s0,$s0,2             #Moving the pointer of the bufferspace by 1 byte

    storedot:
    li $t7,0x2e                #Loading the '.' ascii character in $t7
    sb $t7,0($s0)              #Storing the '.'

    li $t7,0x20                #Loading the ' ' ascii character in $t7
    addi $s0,$s0,1             #Moving the pointer of the bufferspace by 1 byte
    sb $t7,0($s0)              #Storing the ' ' 

    addi $s0,$s0,1             #Moving the pointer of the bufferspace by 1 byte, so it shows to a clean position
    li $t7,0                   #Cleaning $t7 register
    #----------------------------------------------------------------------------------------------------------------#
    
    addi $sp,$sp,-8            #Move the stack pointer to the position where the return address will be stored
    sw $ra,0($sp)              #Storing the return address
    addi $sp,$sp,8             #Restoring the stack pointer to its native position
    
    la $a2, currentEntry
    jal Get_LName              #Call the Get_LName subroutine for getting the last name of the entry
    la $a2, currentEntry
    jal Get_FName              #Call the Get_FName subroutine for getting the first name of the entry
    la $a2, currentEntry
    jal Get_Phone              #Call the Get_Phone subroutine for getting the phone of the entry
    
    li $t9,0                   #Cleaning the $t9 register
    la $s0, bufferSpace        #Loading the starting address of the bufferspace

    storeloop:
      beq $t9,0xF,exitloop     #When 15 cycles have been made then exit the loop

      lw $t0,0($s0)            #Load the 4 bytes from where $s0 shows in the bufferspace
      sw $t0,0($s4)            #Store the word in the stack using the iteration pointer
      
      addi $s0,$s0,4           #Move the pointer in the bufferspace by 4
      addi $s4,$s4,4           #Move the iteration pointer of the stack by 4

      addi $t9,$t9,1           #Add 1 to the loop counter
    j storeloop

    exitloop:                  #Exit label for the storeloop

    li $t3, 0                  #Cleaning $t3 register
    li $t6, 0                  #Cleaning $t6 register
    li $t9, 0                  #Cleaning $t9 register

                               #Informing the User about the new entry
    li $v0,4                   #Telling the OS that we want to print a string
    la $a0,newEntry            #Specifing the string's address
    syscall                    #I/O Call 
    la $a0,bufferSpace         #Specifing another string's address
    syscall                    #I/O Call

    addi $s2,$s2,1             #Update the $s2 register that any further entry will get n+1 as a unique number

    addi $sp,$sp,-8            #Move the stack pointer to the position where the return address is stored
    lw $ra,0($sp)              #Recall the return address of the Get_Entry subroutine
    addi $sp,$sp,8             #Restoring the stack pointer to its native position

    li $v0,0                   #Return value of the subroutine
    jr $ra                     #Exiting subroutine

    #---- Subroutine for getting the last name -------------------------------------------------------------------------------------------------
    Get_LName:
        li $v0, 4                   #Telling the OS that we want to print a string
        la $a0, lastNamePrompt      #Specifing the string's address
        syscall                     #I/O Call

        li $v0, 8                   #Telling the OS that we want to read a a string
        la $a0, currentEntry        #Specifing the address in which it will be stored
        li $a1, 20                  #Specifing the length of the string that we are going to read
        syscall                     #I/O Call
 
        move $t0, $a2               #Recalling the argument we later gave to the subroutine, its a pointer to the buffer for reading the string
        
        loop0:                      #Loop for storing byte by byte the last name in the bufferSpace
          beq $t3,0x0A, exit1       #When 'LF' is found, stop storing
          li $t6,0                  #Initializing a counter in order to count 4 bytes at a time
          lw $t2,0($t0)             #Loading the upper bits of the last name
          addi $t0,$t0,4            #Moving the pointer to the next 4 bytes

          loop1:                          #Loop for storing the bytes
            andi $t3, $t2, 0x000000ff     #Masking the word to keep only the last byte
            beq $t3, 0x0A, loop0          #If the byte is 'LF' then jump to loop0
            beq $t6, 0x04, loop0          #If 4 bytes have been processed then jump to loop0 to bring the next 4

            sb $t3,0($s0)                 #Store the current byte in the bufferSpace

            srlv $t2,$t2,8                #Shift the word right so we can mask the next byte

            addi $s0,$s0,1                #Move the pointer of the bufferSpace by one position
            addi $t6,$t6,1                #Increase the counter for bytes by 1
            j loop1                       #Continue process for the next byte
           
       exit1:                      #Exit label for the loops
        li $t3, 0x20               #Load in the $t3 register the ' '
        sb $t3, 0($s0)             #Store the ' ' 
        addi $s0,$s0,1             #Move the pointer of the bufferSpace to a clean position
        
        li $v0,0                   #Return value of the subourtine
        jr $ra                     #Return command
   #-------------------------------------------------------------------------------------------------------------------------------------------

   #---- Subroutine for getting the first name ------------------------------------------------------------------------------------------------
    Get_FName:
        li $t0, 0                  #Cleaning $t0 register
        li $t3, 0                  #Cleaning $t3 register

        li $v0, 4                  #Telling the OS that we want to print a string
        la $a0, firstNamePrompt    #Specifing the string's address
        syscall                    #I/O Call

        li $v0, 8                  #Telling the OS that we want to read a a string
        la $a0, currentEntry       #Specifing the address in which it will be stored
        li $a1, 20                 #Specifing the length of the string that we are going to read
        syscall                    #I/O Call
 
        move $t0, $a2              #Recalling the argument we later gave to the subroutine, its a pointer to the buffer for reading string

        loop2:                     #Loop for storing byte by byte the first name in the bufferSpace
           beq $t3,0x0A, exit2     #When 'LF' is found, stop storing
           li $t6,0                #Initializing a counter in order to count 4 bytes at a time
           lw $t2,0($t0)           #Loading the upper bits of the last name           
           addi $t0,$t0,4          #Moving the pointer to the next 4 bytes

           loop3:                        #Loop for storing the bytes
            andi $t3, $t2, 0x000000ff    #Masking the word to keep only the last byte
            beq $t3, 0x0A, loop2         #If the byte is 'LF' then jump to loop2
            beq $t6, 0x04, loop2         #If 4 bytes have been processed then jump to loop2 to bring the next 4

            sb $t3,0($s0)                #Store the current byte in the bufferSpace

            srlv $t2,$t2,8               #Shift the word right so we can mask the next byte

            addi $s0,$s0,1               #Move the pointer of the bufferSpace by one position
            addi $t6,$t6,1               #Increase the counter for bytes by 1
            j loop3                      #Continue process for the next byte
           
       exit2:                     #Exit label for the loops
          li $t3, 0x20            #Load in the $t3 register the ' '
          sb $t3, 0($s0)          #Store the ' '
          addi $s0,$s0,1          #Move the pointer of the bufferSpace to a clean position
          
          li $v0,0                #Return value of the subroutine
          jr $ra                  #Return command
   #-------------------------------------------------------------------------------------------------------------------------------------------

   #---- Subroutine for getting the phone -----------------------------------------------------------------------------------------------------
    Get_Phone:
        li $t0, 0                 #Cleaning $t0 register
        li $t3, 0                 #Cleaning $t3 register


        li $v0, 4                 #Telling the OS that we want to print a string
        la $a0, phonePrompt       #Specifing the string's address
        syscall                   #I/O Call

        li $v0, 8                 #Telling the OS that we want to read a a string
        la $a0, currentEntry      #Specifing the address in which it will be stored
        li $a1, 20                #Specifing the length of the string that we are going to read
        syscall                   #I/O Call

        move $t0,$a2              #Recalling the argument we later gave to the subroutine, its a pointer to the buffer for reading string

        loop4:                    #Loop for storing byte by byte the first name in the bufferSpace
           beq $t3,0x0A, exit3    #When 'LF' is found, stop storing
           li $t6,0               #Initializing a counter in order to count 4 bytes at a time
           lw $t2,0($t0)          #Loading the upper bits of the last name
           addi $t0,$t0,4         #Moving the pointer to the next 4 bytes

           loop5:                        #Loop for storing the bytes
            andi $t3, $t2, 0x000000ff    #Masking the word to keep only the last byte
            beq $t3, 0x0A, loop4         #If the byte is 'LF' then jump to loop4
            beq $t6, 0x04, loop4         #If 4 bytes have been processed then jump to loop4 to bring the next 4

            sb $t3,0($s0)                #Store the current byte in the bufferSpace
            
            srlv $t2,$t2,8               #Shift the word right so we can mask the next byte
            
            addi $s0,$s0,1               #Move the pointer of the bufferSpace by one position
            addi $t6,$t6,1               #Increase the counter for bytes by 1
            j loop5                      #Continue process for the next byte
           
       exit3:                    #Exit label for the loops
            li $t3, 0x0a         #Load in the $t3 register the '\n'
            sb $t3, 0($s0)       #Store the '\n'
            addi $s0,$s0,1       #Move the pointer of the bufferSpace to a clean position
            
            li $v0,0             #Return value of the subroutine
            jr $ra               #Return command
  #-------------------------------------------------------------------------------------------------------------------------------------------

  #########################################################################################################################################


  #### Subroutine for recalling an entry from the stack and printing it ###################################################################      
  Print_Entry:
  
    #---- Printing prompt message ----------------------------------------------------------
    li $v0, 4                 #Letting the OS know that we want to print a string
    la $a0, printEntryPrompt  #Giving the string's address as an argument 
    syscall                   #I/O Call
    #---------------------------------------------------------------------------------------

    #---- Reading the user choice ----------------------------------------------------------
    li $v0, 5                 #Letting the OS know that we want to read an integer
    syscall                   #I/O  Call
    move $t0,$v0              #Copying the value that user entered in $t0
    #---------------------------------------------------------------------------------------
    

    bge $t0,$s2, ERROREXIT    #If the user gave a number that is greater that the number of entries we already have then display error

    li $t2,60                 #Load 60 as a standard for multiplication used for calculating the offset of each entry in the stack
    addi $t0,$t0,-1           #We subtract 1 from the user selection because the first entry is stored at 0 offset from stack beginning
    mul $t0,$t0,$t2           #Multiply the user's selection by 60 so we get the appropriate offset for the stack pointer
    move $t8,$s3              #Getting the stack's beginning address
    add $t8,$t8,$t0           #Offsetting the stack pointer by the amount calculated earlier

    li $v0,4                  #Telling the OS that we want to print a string
    la $a0, printEntry        #Specifing the string's address
    syscall                   #I/O Call

    move $a0,$t8              #Speciging another string's address
    syscall                   #I/O Call

    li $t8,0                  #Cleaning $t8 register
    li $t0,0                  #Cleaning $t0 register
    j SUCCESSEXIT             #Exit subroutine

    ERROREXIT:               
    li $v0,4                  #Telling the OS that we want to print a string
    la $a0, errorEntry        #Specifing the string's address
    syscall                   #I/O Call

    SUCCESSEXIT:

    li $v0,0                  #Return value of the subroutine
    jr $ra                    #Return command
 #########################################################################################################################################

         
          
            

       







