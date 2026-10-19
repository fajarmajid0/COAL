# COAL – Computer Organization and Assembly Language

**Name:** Fajar Fatima  
**Roll Number:** 25L-2585  
**Course:** Computer Organization and Assembly Language (COAL)

## About This Repository

This repository contains my Computer Organization and Assembly Language (COAL) assignments and practice programs written in 8088 Assembly Language using NASM.

The purpose of this repository is to practise assembly language programming and understand how the processor works with registers, memory, stack operations, and screen output. Each program is written to fulfil the requirements of its respective assignment.

## Programs
The repository includes assembly language programs covering different concepts of 8088 programming.

- **Text Viewport Manager:** Creates a windowed text viewer, displays a document, scrolls text within the window boundaries, highlights occurrences of a search keyword, and displays the total number of matches in a status bar.

## Tools Used

The following tools were used to write and run the programs:

- **NASM:** Used to assemble the 8088 assembly language source code.
- **DOSBox:** Used to run and test the programs in a DOS environment.

## How to Assemble and Run
### 1. Prepare the Files

Save the assembly language program with a `.asm` extension, for example:
Place the source file in a folder that is accessible through DOSBox.

### 2. Open DOSBox
Start DOSBox and mount the folder containing your program. For example, if your files are stored in `C:\COAL`, enter:

```text
mount c c:\COAL
c:
```

### 3. Assemble the Program
Use NASM to assemble the source file into a DOS `.COM` file:

```text
nasm viewport.asm -o viewport.com
```
Make sure NASM is installed and accessible from the DOSBox environment, or use the appropriate path to your NASM executable.

### 4. Run the Program
After assembling successfully, run the generated file:

```text
viewport.com
```
The program will execute in the DOS environment. For the Text Viewport Manager, the expected output includes a bordered text window, document lines, highlighted keyword matches, and a status bar showing the match count.

**Note:** The commands may need minor adjustments depending on where NASM and DOSBox are installed on your computer.

## Output Screenshots

### Text Viewport Manager
<img width="642" height="421" alt="25L-2585_A3" src="https://github.com/user-attachments/assets/e1294c54-93ce-4110-a24b-65c38070e4ed" />


## Conclusion

This repository represents my learning and practical work for COAL. Through these programs, I am improving my understanding of 8088 assembly language, memory addressing, registers, stack-based procedures, string instructions, and direct screen output.

I will continue updating the repository as I complete more assignments and practise new concepts throughout the course.
