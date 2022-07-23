# Encryption-and-Decryption
## Micaela Landauro
### UTD CS 2340 Spring 2022
This project was one of my final projects in my Computer Architecture Course
I made this program and run it on the MARS MIPS simulator

### DESCRIPTION
  The main focus of this project was to encrypt or decrypt a given file with a given key
  
### HOW IT WORKS
  Given an input file, the user can select wether to encrypt or decrypt the file by entering
  the proper key. The algorithm works as such, a block of 1024 bytes is read from the text file
  into a buffer. For each byte, the corresponding byte of the key is either added (for encryption)
  or subtracted (for decryption) to it using unsigned addition. The new value is then stored back 
  into the buffer. The process is then repeated until zero characters are read and the file is 
  either encrypted or decrypted. Then, the proper output file is created (with proper file 
  extension, .enc for encrypted and .txt for decrypted)
  
### PROGRAM INPUT
  The program will first to choose an option, encrypt, decrypt, or exit. For a decryption
  example, use T1.enc and the key "Computer Science", then the proper output should appear
  in T1.txt. For an encryption example, use OhCaptainMyCaptain.txt and whatever key you would
  like to use, and the encrypted file should appear in "OhCaptainMyCaptain.enc"
  
