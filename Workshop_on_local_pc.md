# VSD_TCL_PROGRAMMING_WORKSHOP

## DAY1  Creating a TCL command and pass .csv file from UNIX shell to tcl script

<img width="1390" height="705" alt="image" src="https://github.com/user-attachments/assets/1d80afb3-0ee1-446d-a149-0f77a66e6e62" />
<img width="1390" height="705" alt="image" src="https://github.com/user-attachments/assets/69f630fb-1a29-4c02-b101-3397f670b793" />
<img width="1134" height="570" alt="image" src="https://github.com/user-attachments/assets/7c3d91de-71c9-4aa5-9e5f-d3a256066c02" />

### Scenario 1

user doesnot provide the .csv file 
<img width="1113" height="634" alt="image" src="https://github.com/user-attachments/assets/14f47d0e-d1fe-4dde-9059-1dffe4b33f5d" />

### Scenario 2:
user provides the name of .csv file but it doesnot exist 
<img width="1173" height="610" alt="image" src="https://github.com/user-attachments/assets/f7acd089-40f0-46ed-bfb4-b1f8a50f3afc" />

### Scenario 3:
user requests for help regarding the excel sheet content and execution using --help 
<img width="1271" height="643" alt="image" src="https://github.com/user-attachments/assets/e9d8d06e-2cd6-48b6-b3a1-9abc7fc4d554" />

## Creating CSV File
<img width="1271" height="643" alt="image" src="https://github.com/user-attachments/assets/443ae576-1fa9-450f-bb47-4da1b0bfe43a" />


Source the UNIX shell to tcl script by passing the csv file
```
tclsh my_synth.tcl $argv[1]

```
<img width="1343" height="677" alt="image" src="https://github.com/user-attachments/assets/4e49fea0-b561-4cc8-96c1-99abe72130dc" />

# DAY 2 Automated Design Setup and Synthesis Flow Initialization in MonkSynth

### **Task Description:**

This phase of **MonkSynth** focuses on preparing and validating all design inputs before synthesis.

It involves:

1. **Variable Extraction:**
   Creating TCL-accessible variables by reading paths and parameters from the CSV configuration file.

2. **Input Validation:**
   Checking existence of directories and files defined in the CSV (Netlist, Libraries, Constraints).

3. **Constraint Processing:**
   Reading the constraint file entry in CSV and converting it into proper **SDC format**.

4. **Netlist Parsing:**
   Reading and listing all Verilog files from the specified netlist directory.

5. **Script Generation:**
   Dynamically generating the **main synthesis TCL script (format-2)** with correct paths and flow structure.

6. **Execution:**
   Passing the generated synthesis script to **Yosys** for running the synthesis process.



