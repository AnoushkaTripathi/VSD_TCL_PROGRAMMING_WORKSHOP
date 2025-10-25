
#  *Complete Theory and Flow Description*

> **Objective:**
> Understand how TCL scripting automates ASIC synthesis and timing analysis using Yosys & OpenTimer, with CSV/Excel inputs acting as front-end design descriptors.

---

## DAY 1 — Introduction to TCL and the VSDSYNTH Toolbox

### 1.1  Background – Why TCL?

TCL (Tool Command Language) has become the *de facto* control language for almost all EDA tools (Synopsys, Cadence, Siemens, OpenROAD, etc.) because it is:

* **Event-driven** – easily integrates with shell environments and GUIs.
* **Interpreted** – no compilation step, instant command execution.
* **Embeddable** – tools expose internal APIs as TCL commands.
* **Extensible** – engineers can prototype flows quickly.

Thus, TCL acts as the *glue logic* between diverse design stages — synthesis, place-and-route, STA, and DRC.

---

### 1.2  Problem Statement

A designer typically maintains multiple design files, liberty libraries, and constraint files.
Manually invoking each tool is error-prone.
We want a **unified automation layer** that:

1. Reads design meta-data (from Excel/CSV).
2. Generates proper tool commands automatically.
3. Executes Yosys → OpenTimer → Report sequence.

This unified flow is implemented in **VSDSYNTH** – a TCL “Tool-Box” that behaves like a command-line EDA environment.

---

### 1.3  Conceptual Analogy

| Real-World Analogy | EDA Analogy                            |
| ------------------ | -------------------------------------- |
| Excel Sheet        | Input order sheet specifying materials |
| VSDSYNTH (TCL Box) | Factory processor                      |
| Yosys + OpenTimer  | Manufacturing machines                 |
| Output Reports     | Final product specifications           |

---

### 1.4  Top-Down Automation Flow

```
User CSV  →  TCL Parser  →  Yosys (Synthesis)
                          →  OpenTimer (Timing)
                          →  Reports (.v + .sdc + .rpt)
```

**CSV acts as Input**, **TCL Box as Processor**, and **Reports as Output**.

---

### 1.5  Key Components of CSV

| Field              | Description                     |
| ------------------ | ------------------------------- |
| DesignName         | Top-level RTL module name       |
| OutputDir          | Folder for generated files      |
| NetlistDir         | RTL behavioral files            |
| EarlyLib / LateLib | Liberty timing models           |
| ConstraintsFile    | Clock & IO timing specification |

Each field is later converted into TCL variables and validated.

---

### 1.6  Why Yosys + OpenTimer?

* **Yosys** performs logic synthesis, mapping RTL into gates.
* **OpenTimer** performs static timing analysis, computing path slacks using liberty models.
  Together they replicate the “compile + analyze” loop found in commercial EDA suites.

---

### 1.7  Error Handling Philosophy

The toolbox must be robust:

* Missing input file → user message + graceful exit.
* Wrong directory → auto-create or prompt user.
* `-help` switch → prints usage guide.

This mimics professional EDA tool behavior (user-friendly yet strict).

---

---

## DAY 2 — Variable Creation & Constraint Processing

### 2.1  Purpose

To translate a CSV’s human-readable data into **machine-readable variables** and to convert design constraints into **SDC (Synopsys Design Constraint)** format, the industry standard used by synthesis and timing tools.

---

### 2.2  Theory of Variable Creation

TCL stores data in associative arrays and lists.
When CSV is imported, each header (column name) becomes a **TCL variable**, enabling parameterized flow generation.

For example:

| CSV Header | TCL Variable  |
| ---------- | ------------- |
| DesignName | `$DesignName` |
| OutputDir  | `$OutputDir`  |
| EarlyLib   | `$EarlyLib`   |

This dynamic creation allows the script to be **design-independent**.

---

### 2.3  Why Matrix Representation?

A CSV is two-dimensional.
The `struct::matrix` object in TCL represents it perfectly.
It allows indexed access such as:

```tcl
set value [struct::matrix get M $row $col]
```

This is important for later pattern searches (e.g., locating “CLOCKS” row).

---

### 2.4  Design Data Validation

**Purpose:** ensure tool commands don’t fail due to missing inputs.

Checks include:

```tcl
file isdirectory  → verifies directories  
file exists        → verifies library files
```

Error → exit, preventing cascade failures.
This resembles the “pre-compile” phase in commercial EDA systems.

---

### 2.5  SDC: Synopsys Design Constraint Format

An SDC file defines **timing intent**:

* Clock periods
* Input/Output delays
* Slew (transition)
* Load (capacitance)
* Path exceptions (multicycle, false paths)

It standardizes constraints across all tools, ensuring **consistent timing closure**.

---

### 2.6  Conversion Pipeline

```
design_details.csv → Matrix → Variables → Constraint Parser → constraints.sdc
```

Each constraint line (e.g., `CLOCK,clk,10,50%`) becomes:

```tcl
create_clock -name clk -period 10 [get_ports clk]
```

---

### 2.7  Practical Theory – Why Auto-Variables?

Instead of hard-coding filenames, dynamic variables allow:

* **Scalability:** multiple designs can reuse one TCL script.
* **Portability:** easy integration into CI/CD flows.
* **Reusability:** same script supports multiple netlists.

---

---

## DAY 3 — Clock & Input Constraint Processing

### 3.1  Static Timing Background

Static Timing Analysis (STA) computes timing paths without simulation.
Every signal path between sequential elements is analyzed for setup/hold margins.

**Three types of constraints:**

1. **Clock Constraints** – define time reference.
2. **Input Constraints** – specify arrival times and transitions.
3. **Output Constraints** – specify required times and loads.

---

### 3.2  Clock Processing Algorithm

1. Identify “CLOCKS” section in constraint CSV.
2. Extract `period`, `duty_cycle`, `latency`.
3. Compute waveform:

   * Rise = `0 ns`
   * Fall = `period * duty_cycle / 100`
4. Generate SDC:

```tcl
create_clock -name $clk -period $period -waveform {0 $fall} [get_ports $clk]
```

5. Add derived attributes:

```tcl
set_clock_latency -early $early_lat -late $late_lat [get_clocks $clk]
set_clock_transition $slew [get_clocks $clk]
```

These ensure both early and late scenarios are modeled.

---

### 3.3  Processing IO Constraints

IO delays relate external world to chip boundary:

```tcl
set_input_delay  -clock $clk $delay [get_ports $input]
set_output_delay -clock $clk $delay [get_ports $output]
```

---

### 3.4  Bus vs. Bit Differentiation

Hardware designs often declare buses:

```verilog
input [7:0] data;
```

OpenTimer and Yosys sometimes require individual bits (`data[0] … data[7]`).
Hence the script performs **bit-blasting**:

* Parse range `[7:0]`.
* Generate individual port names.
* Write repeated SDC lines.

This ensures constraint coverage for each signal bit.

---

### 3.5  Regular Expression Theory

`regexp` and `regsub` let TCL treat Verilog text as a searchable database.

* `regexp {input\s+\[([0-9]+):([0-9]+)\]\s+(\S+);}`
  → Captures bus width and port name.
* `regsub -all "\s+"`
  → Collapses multiple spaces.

This pattern-matching layer is what makes TCL the scripting backbone for EDA.

---

### 3.6  Importance of Temp-File Processing

Temporary files act as intermediate buffers between string manipulations.
They allow:

* Stepwise debugging.
* Data sanitization (sorting, uniqueness).
* Modular testing of parser stages.

---


##  DAY 4 — Complete SDC & Yosys Synthesis

### 4.1  Output Constraints Theory

Outputs connect to external loads (e.g., board capacitance).
To model this:

```tcl
set_load 0.02 [get_ports data_out]
```

represents a 20 fF load.

Only output paths include *set_load*; inputs define transition/slew.


### 4.2  Integration with Yosys

**Yosys** performs gate-level synthesis via steps:

1. **Read RTL:** `read_verilog`.
2. **Read Libraries:** `read_liberty -lib`.
3. **Elaboration:** building design hierarchy.
4. **Optimization:** logic minimization.
5. **Technology mapping:** map to cells from liberty.
6. **Write netlist:** `write_verilog`.

Its flexible command-line interface mirrors proprietary tools (Design Compiler, Genus).


### 4.3  Why Generate Yosys Script via TCL?

Each design may have different paths, libs, or top names.
Automating Yosys script creation ensures:

* Correct filenames every run.
* Version traceability.
* Repeatability.

Generated `synth.ys` (example):

```yosys
read_verilog $NetlistDir/*.v
read_liberty -lib $LateLib
synth -top $DesignName
write_verilog $OutputDir/synthesized.v
```

### 4.4  Hierarchy & Error Handling Theory

Synthesis flows often fail due to:

* Missing submodules.
* Mismatched port lists.

The toolbox pre-checks the design tree:

```tcl
if {![regexp {module\s+$DesignName} $verilog_data]} {
    puts "Error: Top module not found."
    exit 1
}
```

This proactive validation saves runtime and ensures deterministic flow.


### 4.5  Intermediate Knowledge – Behavioral vs. Structural Netlist

* *Behavioral* RTL uses `always`, `if`, `case` constructs.
* *Structural* (synthesized) netlist expresses gates and flip-flops.
  Timing and power tools require **structural** data.

Hence, Day 4 transitions the design from behavior → structure.



##  DAY 5 — Flow Orchestration, OpenTimer, and QoR Metrics

### 5.1  The End-to-End Automation Concept

At this stage, TCL is orchestrating an entire mini-EDA toolchain:

```
CSV → Variable Creation → SDC Generation → Yosys Synthesis → OpenTimer STA → QoR Extraction
```

All within one script environment — a self-contained **digital-flow engine**.


### 5.2  OpenTimer – Theory of Static Timing

OpenTimer computes path delays using:

* **Liberty models:** specify cell delay & transition arcs.
* **Verilog netlist:** connectivity information.
* **SDC constraints:** timing intent.

It builds a timing graph and solves timing equations for:

```
Slack = Required_Time - Arrival_Time
```

The most negative slack represents the *Worst Negative Slack (WNS)*.


### 5.3  Configuration File (`design.conf`)

A `.conf` file formalizes OpenTimer input:

```
set_liberty early.lib
set_liberty late.lib
read_verilog synthesized.v
read_sdc constraints.sdc
report_timing > timing_report.txt
```



### 5.4  Multi-CPU Usage and Procs

In professional environments, STA runs are parallelized.
The workshop introduces TCL **procs** (procedures) that emulate options:

```tcl
proc set_multi_cpu_usage {args} {
    array set opts { -help "" -cpu 4 }
    # parse args ...
}
```


### 5.5  QoR (Quality of Results) Metrics – Theory

**QoR** measures the design’s timing quality after synthesis.

| Metric                         | Meaning                            |
| ------------------------------ | ---------------------------------- |
| **WNS (Worst Negative Slack)** | Most critical path delay violation |
| **TNS (Total Negative Slack)** | Sum of all violating slacks        |
| **Setup/Hold Violations**      | Number of failing paths            |
| **Instance Count**             | Gate count, indicates design size  |
| **Runtime**                    | Indicates computational efficiency |

The toolbox extracts these metrics automatically from OpenTimer reports.


### 5.6  Algorithm for WNS Extraction

1. Read each line of `timing.results`.
2. Identify lines containing `Slack:` using `regexp`.
3. Track the minimum slack value.
4. Print WNS in nanoseconds.

```tcl
set worst 0
while {[gets $f l] >= 0} {
    if {[regexp {Slack:\s*(-?[0-9.]+)} $l -> val]} {
        if {$val < $worst} { set worst $val }
    }
}
puts "WNS = $worst ns"
```


### 5.7  Report Formatting Principles

* Human-readable alignment uses `format` specifiers:

```tcl
puts [format "%-20s %-10s %-10s" "Design" "WNS(ns)" "Violations"]
```

* Column width ensures professional output.
* Summaries stored as `.csv` or `.txt` for regression comparison.



### 5.8  Bit-Blasting for OpenTimer (Theory)

OpenTimer requires per-bit pin data.
The toolbox expands buses using range parsing:

```
bus[7:0] → bus[0] bus[1] … bus[7]
```

This is called **bit-blasting** — essential for STA accuracy.



### 5.9  Why Automation Matters

Manual editing of dozens of constraints for multi-bit ports or multiple clocks is impractical.
A scripted system ensures:

* Consistency across runs
* Rapid iteration for what-if analysis
* Reusability in other flows (e.g., OpenROAD)



### 5.10  Quality of Results Summary Table

| Metric         | Description              | Extraction Method           |
| -------------- | ------------------------ | --------------------------- |
| WNS            | Worst slack              | `regexp` search of “Slack:” |
| FEP            | Failing Endpoints        | Count of violation keywords |
| Instance Count | # of synthesized gates   | Parse Yosys report          |
| Runtime        | Execution time           | `time {command}`            |
| Setup/Hold     | Path type classification | regex filters               |



### 5.11  Inter-Tool Data Continuity

Each stage’s output becomes the next stage’s input:

```
SDC (Yosys) → OpenTimer .SDC  
Netlist (Yosys) → OpenTimer Verilog  
Libs (CSV) → OpenTimer Liberty
```

This data continuity ensures **deterministic QoR correlation** between synthesis and STA.



### 5.12  Closing the Loop

Once timing reports are generated, engineers can:

1. Modify RTL or constraints.
2. Re-run the same flow (only CSV changes).
3. Compare new QoR with old via generated tables.

Thus, VSDSYNTH acts as a **feedback-driven automation framework**.


## Summary of the Entire Flow

| Stage          | Tool      | Key Files            | Concept                             |
| -------------- | --------- | -------------------- | ----------------------------------- |
| Input          | CSV       | `design_details.csv` | Design metadata                     |
| TCL Parsing    | TCL       | `.tcl` scripts       | Data extraction + variable creation |
| SDC Generation | TCL       | `constraints.sdc`    | Standard constraint format          |
| Synthesis      | Yosys     | `synthesized.v`      | Behavioral → Gate-level             |
| STA            | OpenTimer | `.conf`, `.rpt`      | Timing verification                 |
| Reporting      | TCL       | `.results`, `.csv`   | QoR computation                     |



## Pedagogical Outcomes

By the end of Day 5, the learner understands:

| Concept               | Learning Outcome                    |
| --------------------- | ----------------------------------- |
| TCL Fundamentals      | Flow control, lists, arrays, procs  |
| Data Parsing          | CSV → matrix → variable creation    |
| EDA Integration       | Synthesis + STA orchestration       |
| Constraint Theory     | Clocks, IO delays, slews, loads     |
| Tool APIs             | Yosys & OpenTimer command structure |
| QoR Metrics           | Slack interpretation & reporting    |
| Automation Philosophy | Designing reusable flows            |


