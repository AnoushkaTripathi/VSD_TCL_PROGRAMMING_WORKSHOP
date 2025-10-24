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

<img width="1852" height="639" alt="image" src="https://github.com/user-attachments/assets/f5ffceb1-1ea3-4a28-8f35-10a2134ead86" />

<img width="1277" height="945" alt="image" src="https://github.com/user-attachments/assets/a12a82c0-9163-4014-b8c7-200947806707" />

<img width="1277" height="945" alt="image" src="https://github.com/user-attachments/assets/b1b0c6a8-71bd-4a01-987e-5916ac9afdc1" />

## Day 3: Mapping openMSP430_design_constraints.csv file to format[1] compatible with Yosys(open source EDA tool) for Synthesis

### Clock latency and transition constraints

Get all the parameters under "CLOCKS",get row and column number and traverse using them.

<img width="1857" height="1000" alt="image" src="https://github.com/user-attachments/assets/b1f5728b-3070-4e7b-a24a-f9a0b72b4aae" />

<img width="1857" height="1000" alt="image" src="https://github.com/user-attachments/assets/79c30bc9-e0f0-4bcb-8d6e-0442c18527ce" />

<img width="1857" height="1000" alt="image" src="https://github.com/user-attachments/assets/891a149f-a55a-48ba-8983-cdbfe755ebf2" />

<img width="1845" height="992" alt="image" src="https://github.com/user-attachments/assets/a0e28ed2-7543-4f4f-9833-b817e514bbb6" />

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/1825d128-6282-4ac1-8216-a4dc4d08ba83" />

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/cde80a2a-d14b-4146-b01b-be6167974b40" />

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/463162c3-3d38-491b-87c7-bb1f38b7af33" />

## DAY-4 : Feeding RTL Netlist and Standard Cell Library to Yosys EDA tool for Synthesis

### Checking the hierarchy
####  All the referenced modules are interlinked properly and the hierarchy is properly defined - Hierarchy PASS

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/4a506f81-4b73-4f77-9d5e-7bc461fc1ddd" />

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/b3e4f3c6-aa5e-4577-88c4-75851898346d" />

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/5118afa5-324a-4823-8ce9-a5eecc3a0e70" />

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/fbe0fb28-7f84-486a-82a7-e6090fdc3364" />

## DAY-5: Converting Yosys tool's Synthesized Gate Level Output Netlist to a Format compatible with Opentimer(Open Source EDA Tool) for Timing Analysis

