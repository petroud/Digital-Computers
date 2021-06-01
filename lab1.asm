# Hello World with user interaction

.data
helloString: .asciiz "\nHello, "
worldString: .asciiz " World!"
welcomeString: .asciiz "Welcome!\n"
userWord: .asciiz "Please provide me a word: "
userInput: .space 20

.text

main:
  li $v0 , 4                #Tells the system we want to print something
  la $a0 , welcomeString    #Prints welcome message
  syscall

  li $v0 , 4                #Tells the system we want to print something
  la $a0 , userWord         #Tells the user what we need
  syscall

  li $v0 , 8                #Tells the system we want to read something from the keyboard
  la $a0 , userInput        #Stores the input from the keyboard to a variable
  li $a1 , 20               #Tells the system the maximum length of the input
  syscall

  #Prints hello
  li $v0 , 4 
  la $a0 , helloString
  syscall

  #Prints user message
  li $v0 , 4
  la $a0 , userInput
  syscall

  #Prints world
  li $v0 , 4
  la $a0 , worldString
  syscall

  li $v0, 10                #Tells the system this is the end of main
  syscall
  
