#! /usr/bin/env tclsh
puts "\n\n=============================================================="
puts "                    WELCOME TO MonkSynth"
puts "--------------------------------------------------------------"
puts "  An Open-Source Synthesis & STA Automation Tool"
puts "  Developed by Er. Anoushka Tripathi"
puts "  Monk9 Tech Private Limited"
puts "==============================================================\n"

#----- Checks whether MonkSynth usage is correct or not -----#
set enable_prelayout_timing 1
set working_dir [exec pwd]
set monksynth_array_length [llength [split [lindex $argv 0] .]]
set input [lindex [split [lindex $argv 0] .] $monksynth_array_length-1]

if {![regexp {^csv} $input] || $argc!=1 } {
	puts "MonkSynth Error: Incorrect usage."
	puts "Usage: ./monksynth <.csv>"
	puts "Where <.csv> contains required design configuration."
	exit
} else {

#------ Convert .csv to matrix and create initial variables ----------#
	set filename [lindex $argv 0]
	package require csv
	package require struct::matrix
	struct::matrix m
	set f [open $filename]
	csv::read2matrix $f m , auto
	close $f
	m link my_arr
	set num_of_rows [m rows]
	set i 0

	while {$i < $num_of_rows} {
		 puts "\nMonkSynth Info: Setting $my_arr(0,$i) as '$my_arr(1,$i)'"
		 if {$i == 0} {
			 set [string map {" " ""} $my_arr(0,$i)] $my_arr(1,$i)
		 } else {
			 set [string map {" " ""} $my_arr(0,$i)] [file normalize $my_arr(1,$i)]
		 }
		 set i [expr {$i+1}]
	}
}

puts "\nMonkSynth Info: Listing key variables for debug:"
puts "DesignName       = $DesignName"
puts "OutputDirectory  = $OutputDirectory"
puts "NetlistDirectory = $NetlistDirectory"
puts "EarlyLibraryPath = $EarlyLibraryPath"
puts "LateLibraryPath  = $LateLibraryPath"
puts "ConstraintsFile  = $ConstraintsFile"

#----- Verify file & directory existence -----#

if {! [file exists $EarlyLibraryPath]} {
	puts "\nMonkSynth Error: Early library not found at $EarlyLibraryPath. Exiting..."
	exit
} else {
	puts "\nMonkSynth Info: Early cell library found at $EarlyLibraryPath"
}

if {! [file exists $LateLibraryPath]} {
	puts "\nMonkSynth Error: Late library not found at $LateLibraryPath. Exiting..."
	exit
} else {
	puts "\nMonkSynth Info: Late cell library found at $LateLibraryPath"
}

if {! [file isdirectory $OutputDirectory]} {
	puts "\nMonkSynth Info: Creating output directory $OutputDirectory"
	file mkdir $OutputDirectory
} else {
	puts "\nMonkSynth Info: Output directory found at $OutputDirectory"
}

if {! [file isdirectory $NetlistDirectory]} {
	puts "\nMonkSynth Error: RTL netlist directory not found at $NetlistDirectory. Exiting..."
	exit	
} else {
	puts "\nMonkSynth Info: RTL netlist directory found at $NetlistDirectory"
}

if {! [file exists $ConstraintsFile]} {
	puts "\nMonkSynth Error: Constraints file not found at $ConstraintsFile. Exiting..."
	exit
} else {
	puts "\nMonkSynth Info: Constraints file found at $ConstraintsFile"
}

#====================================================================#
#                 Constraints File Parsing - SDC Creation
#====================================================================#
puts "\nMonkSynth Info: Dumping SDC constraints for $DesignName"
puts "\nInfo: Dumping SDC constraints for $DesignName"
::struct::matrix constraints
set chan [open $ConstraintsFile]
csv::read2matrix $chan constraints  , auto
close $chan
set number_of_rows [constraints rows]
puts "number_of_rows = $number_of_rows"
set number_of_columns [constraints columns]
puts "number_of_columns=$number_of_columns"
 

#-----check row number for "clocks" and column number for "IO delays and slew section" in constraints.csv---##
set clock_start [lindex [lindex [constraints search all CLOCKS] 0 ] 1]
set clock_start_column [lindex [lindex [constraints search all CLOCKS] 0 ] 0]
puts "clock start= $clock_start"
puts "clock start_column=$clock_start_column"

#-----check row number for "inputs" section in constraints.csv---##
set input_ports_start [lindex [lindex [constraints search all INPUTS] 0 ] 1]
puts "input_ports_start=$input_ports_start"
#-----check row number for "outputs" section in constraints.csv---##
set output_ports_start [lindex [lindex [constraints search all OUTPUTS] 0 ] 1]
puts "output_ports_start=$output_ports_start"

#-------------------clock constraints--------------------##
#-------------------clock latency constraints------------#

set clock_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  early_rise_delay] 0 ] 0]

set clock_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  early_fall_delay] 0 ] 0]

set clock_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  late_rise_delay] 0 ] 0]

set clock_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  late_fall_delay] 0 ] 0]

#-------------------clock transition constraints------------#

set clock_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  early_rise_slew] 0 ] 0]

set clock_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  early_fall_slew] 0 ] 0]

set clock_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  late_rise_slew] 0 ] 0]

set clock_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  late_fall_slew] 0 ] 0]

set sdc_file [open $OutputDirectory/$DesignName.sdc "w"]
set i [expr {$clock_start+1}]
set end_of_ports [expr {$input_ports_start-1}]
puts "\nInfo-SDC: Working on clock constraints....."
while { $i < $end_of_ports } {
        puts -nonewline $sdc_file "\ncreate_clock -name [constraints get cell 0 $i] -period [constraints get cell 1 $i] -waveform \{0 [expr {[constraints get cell 1 $i]*[constraints get cell 2 $i]/100}]\} \[get_ports [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition -rise -min [constraints get cell $clock_early_rise_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition -fall -min [constraints get cell $clock_early_fall_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_transition -rise -max [constraints get cell $clock_late_rise_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_transition -fall -max [constraints get cell $clock_late_fall_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_latency -source -early -rise [constraints get cell $clock_early_rise_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_latency -source -early -fall [constraints get cell $clock_early_fall_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_latency -source -late -rise [constraints get cell $clock_late_rise_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_latency -source -late -fall [constraints get cell $clock_late_fall_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        set i [expr {$i+1}]
}
set input_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  early_rise_delay] 0 ] 0]
set input_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  early_fall_delay] 0 ] 0]
set input_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  late_rise_delay] 0 ] 0]
set input_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  late_fall_delay] 0 ] 0]

set input_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  early_rise_slew] 0 ] 0]
set input_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  early_fall_slew] 0 ] 0]
set input_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  late_rise_slew] 0 ] 0]
set input_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  late_fall_slew] 0 ] 0]


set related_clock [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  clocks] 0 ] 0]
set i [expr {$input_ports_start+1}]
set end_of_ports [expr {$output_ports_start-1}]
puts "\nInfo-SDC: Working on IO constraints....."
puts "\nInfo-SDC: Categorizing input ports as bits and bussed"
set netlist [glob -dir $NetlistDirectory *.v]
set tmp_file [open /tmp/1 w]
foreach f $netlist {
        set fd [open $f]
	puts "reading file $f"
        while {[gets $fd line] != -1} {
		set pattern1 " [constraints get cell 0 $i];"
                if {[regexp -all -- $pattern1 $line]} {
			puts "pattern1 \"$pattern1\" found and matching line in verilog file \"$f\" is \"$line\""
			set pattern2 [lindex [split $line ";"] 0]
			puts "creating pattern2 by splitting pattern1 using semi-colon as delimiter => \"$pattern2\""
			if {[regexp -all {input} [lindex [split $pattern2 "\S+"] 0]]} {
			puts "out of all patterns, \"$pattern2\" has matching string \"input\". So preserving this line and ignoring others"
			set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
			puts "printing first 3 elements of pattern2 as \"$s1\" using space as demiliter"
			puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
			puts "replace multiple spaces in s1 by single space and reformat as \"[regsub -all {\s+} $s1 " "]\""
			}
                }
        }
close $fd
}
close $tmp_file


# Read /tmp/1 contents generated earlier
if {![file exists /tmp/1]} {
    puts "MonkSynth Warning: /tmp/1 not found — skipping port check for this input."
    set count 0
} else {
    set tmp_file [open /tmp/1 r]
    set tmp_data [read $tmp_file]
    close $tmp_file

    # Split into lines, remove empty entries, and get unique declarations
    set line_list [split $tmp_data "\n"]
    set clean_lines {}
    foreach line $line_list {
        set line_trim [string trim $line]
        if {$line_trim ne ""} {
            lappend clean_lines $line_trim
        }
    }
    set unique_lines [lsort -unique $clean_lines]
    set count [llength $unique_lines]
}

# Determine if the port is bussed or single-bit
if {$count > 2} {
    set inp_ports "[constraints get cell 0 $i]*"
    puts "MonkSynth: Port [constraints get cell 0 $i] detected as BUS (count=$count)"
} else {
    set inp_ports [constraints get cell 0 $i]
    puts "MonkSynth: Port $inp_ports detected as SINGLE-BIT (count=$count)"
}

puts "Input port name is $inp_ports (count=$count)\n"

# Write SDC commands for this port
set clkSpec "\[get_clocks [constraints get cell $related_clock $i]\]"
set portSpec "\[get_ports $inp_ports\]"

puts -nonewline $sdc_file "\nset_input_delay -clock $clkSpec -min -rise -source_latency_included [constraints get cell $input_early_rise_delay_start $i] $portSpec"
puts -nonewline $sdc_file "\nset_input_delay -clock $clkSpec -min -fall -source_latency_included [constraints get cell $input_early_fall_delay_start $i] $portSpec"
puts -nonewline $sdc_file "\nset_input_delay -clock $clkSpec -max -rise -source_latency_included [constraints get cell $input_late_rise_delay_start $i] $portSpec"
puts -nonewline $sdc_file "\nset_input_delay -clock $clkSpec -max -fall -source_latency_included [constraints get cell $input_late_fall_delay_start $i] $portSpec"

puts -nonewline $sdc_file "\nset_input_transition -clock $clkSpec -min -rise -source_latency_included [constraints get cell $input_early_rise_slew_start $i] $portSpec"
puts -nonewline $sdc_file "\nset_input_transition -clock $clkSpec -min -fall -source_latency_included [constraints get cell $input_early_fall_slew_start $i] $portSpec"
puts -nonewline $sdc_file "\nset_input_transition -clock $clkSpec -max -rise -source_latency_included [constraints get cell $input_late_rise_slew_start $i] $portSpec"
puts -nonewline $sdc_file "\nset_input_transition -clock $clkSpec -max -fall -source_latency_included [constraints get cell $input_late_fall_slew_start $i] $portSpec"

# Increment loop counter
set i [expr {$i + 1}]
# ----------------------------
# End MonkSynth Block
# ----------------------------


set output_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  early_rise_delay] 0 ] 0]
set output_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  early_fall_delay] 0 ] 0]
set output_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  late_rise_delay] 0 ] 0]
set output_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  late_fall_delay] 0 ] 0]
set output_load_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  load] 0 ] 0]
set related_clock [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  clocks] 0 ] 0]
set i [expr {$output_ports_start+1}]
set end_of_ports [expr {$number_of_rows}]
puts "\nInfo-SDC: Working on IO constraints....."
puts "\nInfo-SDC: Categorizing output ports as bits and bussed"

while { $i < $end_of_ports } {
#--------------------------optional script----differentiating input ports as bussed and bits------#
set netlist [glob -dir $NetlistDirectory *.v]
set tmp_file [open /tmp/1 w]
foreach f $netlist {
        set fd [open $f]
        while {[gets $fd line] != -1} {
                set pattern1 " [constraints get cell 0 $i];"
                if {[regexp -all -- $pattern1 $line]} {
                        set pattern2 [lindex [split $line ";"] 0]
                        if {[regexp -all {output} [lindex [split $pattern2 "\S+"] 0]]} {
                        set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
                        puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
                        }
                }
        }
close $fd
}
close $tmp_file
set tmp_file [open /tmp/1 r]
set tmp2_file [open /tmp/2 w]
puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
close $tmp_file
close $tmp2_file
set tmp2_file [open /tmp/2 r]
set count [split [llength [read $tmp2_file]] " "]
if {$count > 2} {
        set op_ports [concat [constraints get cell 0 $i]*]
} else {
        set op_ports [constraints get cell 0 $i]
}
        puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $output_early_rise_delay_start $i] \[get_ports $op_ports\]"
        puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $output_early_fall_delay_start $i] \[get_ports $op_ports\]"
        puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $output_late_rise_delay_start $i] \[get_ports $op_ports\]"
        puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $output_late_fall_delay_start $i] \[get_ports $op_ports\]"
	puts -nonewline $sdc_file "\nset_load [constraints get cell $output_load_start $i] \[get_ports $op_ports\]"
	set i [expr {$i+1}]
}
close $tmp2_file
close $sdc_file

puts "\nInfo: SDC created. Please use constraints in path  $OutputDirectory/$DesignName.sdc"


#--------------------------- Hierarchy check --------------------------------#
#--------------------------- Hierarchy check --------------------------------#


puts "\nInfo: Creating hierarchy check script to be used by Yosys"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
puts "data is \"$data\""
set filename "$DesignName.hier.ys"
puts "filename is \"$filename\""
set fileId [open $OutputDirectory/$filename "w"]
puts "open \"$OutputDirectory/$filename\" write mode"
puts -nonewline $fileId $data
set netlist [glob -dir $NetlistDirectory *.v]
puts "netlist is \"$netlist\""
foreach f $netlist {
	set data $f
	puts "data is \"$f\""
	#puts "\nread_verilog $f"
	puts -nonewline $fileId "\nread_verilog $f"
}
puts -nonewline $fileId "\nhierarchy -check"
close $fileId 

puts "\nChecking hierarchy....."
set my_err [catch {exec yosys -s $OutputDirectory/$DesignName.hier.ys >& $OutputDirectory/$DesignName.hierarchy_check.log} msg]
puts "err flag is $my_err"

if { [catch { exec yosys -s $OutputDirectory/$DesignName.hier.ys >& $OutputDirectory/$DesignName.hierarchy_check.log} msg]} {
	set filename "$OutputDirectory/$DesignName.hierarchy_check.log"
	set pattern {referenced in module}
	set count 0
	set fid [open $filename r]
	while {[gets $fid line] != -1} {
		incr count [regexp -all -- $pattern $line]
		if {[regexp -all -- $pattern $line]} {
			puts "\nError: module [lindex $line 2] is not part of design $DesignName. Please correct RTL in the path '$NetlistDirectory'" 
			puts "\nInfo: Hierarchy check FAIL"
		}
	}
	close $fid
} else {
	puts "\nInfo: Hierarchy check PASS"
}
puts "\nInfo: Please find hierarchy check details in [file normalize $OutputDirectory/$DesignName.hierarchy_check.log] for more info"

cd $working_dir 

#------------------------- Main synthesis script-----------------------------#

puts "\nInfo: Creating main synthesis script to be used by Yosys"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
puts "data is \"$data\""
set filename "$DesignName.ys"
puts "filename is \"$DesignName\""
set fileId [open $OutputDirectory/$filename "w"]
puts -nonewline $fileId $data

set netlist [glob -dir $NetlistDirectory *.v]
puts "netlist is \"$netlist\""

foreach f $netlist {
        set data $f
	puts "data is \"$f\""
	#puts "\nread_verilog $f"
        puts -nonewline $fileId "\nread_verilog $f"
}

puts -nonewline $fileId "\nhierarchy -top $DesignName"
puts -nonewline $fileId "\nsynth -top $DesignName"
puts -nonewline $fileId "\nsplitnets -ports -format ___\nproc; memory; opt; fsm; opt\ntechmap; opt\ndfflibmap -liberty ${LateLibraryPath}"
puts -nonewline $fileId "\nabc -liberty ${LateLibraryPath} "
puts -nonewline $fileId "\nflatten"
puts -nonewline $fileId "\nclean -purge\niopadmap -outpad BUFX2 A:Y -bits\nopt\nclean"
puts -nonewline $fileId "\nwrite_verilog $OutputDirectory/$DesignName.synth.v"
close $fileId
puts "\nInfo: Synthesis script created and can be accessed from path $OutputDirectory/$DesignName.ys"

puts "\nInfo: Running synthesis........"

#-------------------- Run synthesis script using yosys ----------------------#



if {[catch { exec yosys -s $OutputDirectory/$DesignName.ys >& $OutputDirectory/$DesignName.synthesis.log} msg]} {
	puts "\nError: Synthesis failed due to errors. Please refer to log $OutputDirectory/$DesignName.synthesis.log for errors"
	exit
} else {
	puts "\nInfo: Synthesis finished successfully"
}
puts "\nInfo: Please refer to log $OutputDirectory/$DesignName.synthesis.log"

set fileid [open /tmp/1 "w"]
puts -nonewline $fileid [exec grep -v -w "*" $OutputDirectory/$DesignName.synth.v]
#grep  -v -w "*" gets alll the instances with * in it so that we can remove them as they arent understood by Opentimer
close $fileid

set output [open $OutputDirectory/$DesignName.final.synth.v "w"]

set filename "/tmp/1"
set fid [open $filename r]
while {[gets $fid line] != -1} {
        puts -nonewline $output [string map {"\\" ""} $line]
        puts -nonewline $output "\n"
}

close $fid
close $output

puts "\nInfo : Please find the final synthesized netlist for $DesignName at below path. You cann use this netlist for STA or PNR"
puts "$OutputDirectory/$DesignName.final.synth.v"
#------------------------- Edit synth.v to be usable by Opentimer-----------------------------#


set fileId [open /tmp/1 "w"]
puts -nonewline $fileId [exec grep -v -w "*" $OutputDirectory/$DesignName.synth.v]
close $fileId

set output [open $OutputDirectory/$DesignName.final.synth.v "w"]

set filename "/tmp/1"
set fid [open $filename r]
        while {[gets $fid line] != -1} {
	puts -nonewline $output [string map {"\\" ""} $line]
	puts -nonewline $output "\n"
}
close $fid
close $output

puts "\nInfo: Please find the synthesized netlist for $DesignName at below path. You can use this netlist for STA or PNR"
puts "\n$OutputDirectory/$DesignName.final.synth.v"

puts "\nInfo: Timing Analysis Started...."
puts "\nInfo: Initializing number of threads, libraries, sdc, verilog netlist path..."
source procs/reopenStdout.proc
source procs/set_num_threads.proc
reopenStdout $OutputDirectory/$DesignName.conf
set_multi_cpu_usage -localCpu 4


source procs/read_lib.proc
read_lib -early /home/anoushka-tripathi/TCL_WORKSHOP/monksynth/osu018_stdcells.lib 

read_lib -late /home/anoushka-tripathi/TCL_WORKSHOP/monksynth/osu018_stdcells.lib

source procs/read_verilog.proc
read_verilog $OutputDirectory/$DesignName.final.synth.v
 

source procs/read_sdc.proc
read_sdc $OutputDirectory/$DesignName.sdc
reopenStdout /dev/tty

if {$enable_prelayout_timing == 1} {
	puts "\nInfo: enable_prelayout_timing is $enable_prelayout_timing. Enabling zero-wire load parasitics"
	set spef_file [open $OutputDirectory/$DesignName.spef w]
puts $spef_file "*SPEF \"IEEE 1481-1998\" " 
puts $spef_file "*DESIGN \"$DesignName\" " 
puts $spef_file "*DATE \"Tue Sep 25 11:51:50 2012\" " 
puts $spef_file "*VENDOR \"TAU 2015 Contest\" " 
puts $spef_file "*PROGRAM \"Benchmark Parasitic Generator\" " 
puts $spef_file "*VERSION \"0.0\" " 
puts $spef_file "*DESIGN_FLOW \"NETLIST_TYPE_VERILOG\" " 
puts $spef_file "*DIVIDER / " 
puts $spef_file "*DELIMITER : " 
puts $spef_file "*BUS_DELIMITER [ ] " 
puts $spef_file "*T_UNIT 1 PS " 
puts $spef_file "*C_UNIT 1 FF " 
puts $spef_file "*R_UNIT 1 KOHM " 
puts $spef_file "*L_UNIT 1 UH " 
}
close $spef_file

set conf_file [open $OutputDirectory/$DesignName.conf a]
puts $conf_file "set_spef_fpath $OutputDirectory/$DesignName.spef"
puts $conf_file "init_timer "
puts $conf_file "report_timer "
puts $conf_file "report_wns "
puts $conf_file "report_worst_paths -numPaths 10000 "
close $conf_file


set time_elapsed_in_us [time {exec /home/anoushka-tripathi/OpenTimer-1.0.5/bin/OpenTimer < $OutputDirectory/$DesignName.conf >& $OutputDirectory/$DesignName.results}]
set time_elapsed_in_sec "[expr {[lindex $time_elapsed_in_us 0]/100000}] sec"
puts "\nInfo: STA finished in $time_elapsed_in_sec seconds"
puts "\nInfo: Refer to $OutputDirectory/$DesignName.results for warning and errors"

puts "tcl_precision is $tcl_precision"
#return

#---------------find WNS using RAT-------------------------#
set worst_RAT_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {RAT}
puts "pattern is $pattern"
while {[gets $report_file line] != -1} {
	if {[regexp $pattern $line]} {
		set worst_RAT_slack "[expr {[lindex $line 3]/1000}]ns"
		puts "worst_RAT_slack is $worst_RAT_slack"
		break
	} else {
		continue
	}
}
close $report_file
#return

#--------------------------fine number of output violation------------#
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
                incr count [regexp -all -- $pattern $line]
}
set Number_of_output_violations $count
puts "Number of output violations $Number_of_output_violations"
close $report_file


#---------------find WNS setup violation-------------------------#
set worst_negative_setup_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {Setup}
puts "pattern is $pattern"
while {[gets $report_file line] != -1} {
        if {[regexp $pattern $line]} {
                set worst_negative_setup_slack "[expr {[lindex $line 3]/1000}]ns"
                break
        } else {
                continue
        }
}
close $report_file

#---------------find number of setup violation-------------------------#

set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
                incr count [regexp -all -- $pattern $line]
}
set Number_of_setup_violations $count
close $report_file

#---------------find WNS hold violation-------------------------#
set worst_negative_hold_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {Hold}
puts "pattern is $pattern"
while {[gets $report_file line] != -1} {
        if {[regexp $pattern $line]} {
                set worst_negative_hold_slack "[expr {[lindex $line 3]/1000}]ns"
                break
        } else {
                continue
        }
}
close $report_file

#---------------find number of hold violation-------------------------#

set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
                incr count [regexp -all -- $pattern $line]
}
set Number_of_hold_violations $count
close $report_file


#---------------find number of instance---------------------------#
set pattern {Num of gates}
puts "pattern is $pattern"
set report_file [open $OutputDirectory/$DesignName.results r]
while {[gets $report_file line] != -1} {
        if {[regexp $pattern $line]} {
                set Instance_count [lindex [join $line " "] 4 ]
                break
        } else {
                continue
        }
}
close $report_file

set Instance_count "$Instance_count PS"
set time_elapsed_in_sec "$time_elapsed_in_sec PS"
puts "DesignName is \{$DesignName\}"
puts "time_elapsed_in_sec is \{$time_elapsed_in_sec\}"
puts "Instance_count is \{$Instance_count\}"
puts "worst_negative_setup_slack is \{$worst_negative_setup_slack\}"
puts "Number_of_setup_violations is \{$Number_of_setup_violations\}"
puts "worst_negative_hold_slack is \{$worst_negative_hold_slack\}"
puts "Number_of_hold_violations is \{$Number_of_hold_violations\}"
puts "worst_RAT_slack is \{$worst_RAT_slack\}"
puts "Number_output_violations is \{$Number_of_output_violations\}"
#return
puts "\n"
puts "                                 **********PRELAYOUT TIMING RESULTS**********                                                      "
set formatStr {%15s%15s%15s%15s%15s%15s%15s%15s%15s}

puts [format $formatStr "-----------" "-------" "--------------" "-----------" "-----------" "----------" "----------" "-------" "-------"]
puts [format $formatStr "Design Name" "Runtime" "Instance Count" " WNS Setup " " FEP Setup " " WNS Hold " " FEP Hold " "WNS RAT" "FEP RAT"]
puts [format $formatStr "-----------" "-------" "--------------" "-----------" "-----------" "----------" "----------" "-------" "-------"]
foreach design_name $DesignName runtime $time_elapsed_in_sec instance_count $Instance_count wns_setup $worst_negative_setup_slack fep_setup $Number_of_setup_violations wns_hold $worst_negative_hold_slack fep_hold $Number_of_hold_violations wns_rat $worst_RAT_slack fep_rat $Number_of_output_violations {
	puts [format $formatStr $design_name $runtime $instance_count $wns_setup $fep_setup $wns_hold $fep_hold $wns_rat $fep_rat]
}

puts [format $formatStr "-----------" "-------" "--------------" "-----------" "-----------" "----------" "----------" "-------" "-------"]
puts "\n"
 
