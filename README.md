# VSD_TCL_PROGRAMMING_WORKSHOP

## DAY 1:  Creating a TCL command and pass .csv file from UNIX shell to tcl script

## Objective

The goal of this day is to **understand how a TCL-based automation flow can process design data from an Excel/CSV input**, synthesize it using **Yosys**, and perform **timing analysis with OpenTimer** — all wrapped inside the **VSDSYNTH Toolbox**.

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

The goal is to process timing constraints directly from the CSV input file, interpret clock specifications, identify input signals (both single-bit and buses), and generate corresponding Synopsys Design Constraint (SDC) entries.

You will learn to:

- Parse and categorize data from the constraints.csv file.

- Create clock definitions with accurate period, duty cycle, and latency.

- Extract bus information from Verilog netlists using regular expressions.

- Differentiate between bit-level and bus-level constraints.

- Generate set_input_delay and set_clock_latency commands automatically.

## Conceptual Background

Clocks and IO timing form the backbone of any STA environment.
The accuracy of clock period, latency, and input arrival times directly affects the synthesized design’s performance.
This lab builds the automation logic that allows VSDSYNTH to:

Read CSV → create structured matrices → locate “CLOCKS” → compute waveform equations.

Translate design intent into tool-readable SDC commands.

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

###  **Lab Objective**

Day 4 extends the Day 3 flow to cover **output constraints** and **integration with the Yosys synthesis tool**.
Here, we will finalize SDC generation and use it to synthesize an RTL design into a gate-level netlist.

You will:

* Add `set_output_delay` and `set_load` commands to the SDC file.
* Understand how the SDC is consumed by synthesis tools.
* Create an automated Yosys script (`synth.ys`) using TCL variables.
* Execute synthesis and verify successful gate-level netlist generation.
* Implement hierarchy checks and error-handling in TCL.

---

### 🧠 **Conceptual Background**

Synthesis is the process of converting behavioral RTL code into a structural gate-level representation using liberty models.
By feeding the generated SDC into Yosys, you ensure that synthesis honors timing constraints.
Day 4 bridges the gap between **functional design intent (RTL)** and **implementation design intent (timing)**.

### Checking the hierarchy
####  All the referenced modules are interlinked properly and the hierarchy is properly defined - Hierarchy PASS

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/4a506f81-4b73-4f77-9d5e-7bc461fc1ddd" />

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/b3e4f3c6-aa5e-4577-88c4-75851898346d" />

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/5118afa5-324a-4823-8ce9-a5eecc3a0e70" />

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/fbe0fb28-7f84-486a-82a7-e6090fdc3364" />

## DAY-5: Converting Yosys tool's Synthesized Gate Level Output Netlist to a Format compatible with Opentimer(Open Source EDA Tool) for Timing Analysis

### 🎯 **Lab Objective**

Day 5 is where all components come together.
You’ll automate the **entire design flow**:
CSV → SDC → Yosys → OpenTimer → QoR Report.

The focus is on:

* Creating OpenTimer configuration files (`.conf`).
* Running static timing analysis automatically.
* Parsing OpenTimer timing reports to extract QoR metrics:

  * WNS (Worst Negative Slack)
  * TNS (Total Negative Slack)
  * Setup/Hold violations
  * Instance count & runtime
* Formatting these metrics into readable tables and logs.

---


Here, the TCL script becomes a *flow controller*, capable of:

* Launching synthesis and analysis tools.
* Managing data dependencies between stages.
* Evaluating timing performance quantitatively.

**OpenTimer** performs the timing graph analysis using liberty, Verilog, and SDC inputs, applying standard STA principles:

```
Slack = Required_Time – Arrival_Time
```

A negative slack indicates a timing violation.


<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/886d0c4f-2fe5-4b09-8093-c9708187e602" />

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/d9b845cc-4633-439a-865b-491d1372bc12" />

### Traking no of * & //// in openMSP430.synth.v

<img width="806" height="289" alt="image" src="https://github.com/user-attachments/assets/b8ce99b2-1651-41b8-bd96-75265f7ece0a" />

<img width="1847" height="354" alt="image" src="https://github.com/user-attachments/assets/61ddb4c5-60ad-4ed0-b014-085718945c8b" />

<img width="1917" height="1069" alt="image" src="https://github.com/user-attachments/assets/3e14da56-475d-46cb-ba9c-bca16b362225" />

<img width="1917" height="1069" alt="image" src="https://github.com/user-attachments/assets/649db072-9868-41b7-957b-f475beeeb5e7" />
<img width="1917" height="1069" alt="image" src="https://github.com/user-attachments/assets/dcf0f34a-cfad-4cd1-9cde-7ef340771fed" />
<img width="1917" height="1069" alt="image" src="https://github.com/user-attachments/assets/48bd4217-5e04-4e53-955b-d5cad4328896" />

<img width="1917" height="1069" alt="image" src="https://github.com/user-attachments/assets/a33fb569-a992-4f02-8912-3d408a2c5754" />



# Final result

<img width="1917" height="1069" alt="image" src="https://github.com/user-attachments/assets/8765e7ee-aa23-4821-b165-5fd243d190e9" />
