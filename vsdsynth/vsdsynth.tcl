#! /bin/env tclsh
#----------------------------------------------------------------------------#
#------------- Check whether vsdsynth usage is correct or not ---------------#
#----------------------------------------------------------------------------#

#----------------------------------------------------------------------------------------------------------------------------------------------#
#---- Converts .csv to matrix and creates initial variables "DesignName OutputDirectory NetlistDirectory EarlyLibraryPath LateLibraryPath -----#
#----------------------------------------------------------------------------------------------------------------------------------------------#

set filename [lindex $argv 0]
package require csv
package require struct::matrix
struct::matrix m
set f [open $filename]
csv::read2matrix $f m , auto
close $f
set columns [m columns]
#m add columns $colimns
m link my_arr
set num_of_rows [m rows]
set i 0
while {$i < $num_of_rows} {
	puts "Info: Setting $my_arr(0,$i) as '$my_arr(1,$i)'\n"
	if {$i == 0} {
		set [string map {" " ""} $my_arr(0,$i)] $my_arr(1,$i)
	} else {
		set [string map {" " ""} $my_arr(0,$i)] [file normalize $my_arr(1,$i)]
	}
	set i [expr {$i+1}]
}

puts "Info: Below are the list of initial variables and their values. User can use these variables for further debug. Use 'puts <variable name>' command to query value of below variables."
puts "DesignName = $DesignName"
puts "OutputDirectory = $OutputDirectory"
puts "NetlistDirectory = $NetlistDirectory"
puts "EarlyLibraryPath = $EarlyLibraryPath"
puts "LateLibraryPath = $LateLibraryPath"
puts "ConstraintsFile = $ConstraintsFile"


#----------------------------------------------------------------------------------------------------------------------------------------------#
#--------------------------- Below script checks if directories and files mentioned in csv file, exixts or not --------------------------------#
#----------------------------------------------------------------------------------------------------------------------------------------------#

if {![file isdirectory $OutputDirectory]} {
	puts "\nInfo: Cannot find output directory $OutputDirectory. Creating $OutputDirectory"
	file mkdir $OutputDirectory
} else {
	puts "\nInfo: OutputDirectory found in path $OutputDirectory"
}

if {![file isdirectory $NetlistDirectory]} {
	puts "\nError: Cannot find RTL netlist directory in path $NetlistDirectory. Exiting.... "
	exit
} else {
	puts "\nInfo: RTL netlist directory found in path $NetlistDirectory"
}

if {![file exists $EarlyLibraryPath]} {
	puts "\nError: Cannot find early cell library in path $EarlyLibraryPath. Exiting..."
	exit
} else {
	puts "\nInfo: Early cell library found in path $EarlyLibraryPath"
}

if {![file exists $LateLibraryPath]} {
	puts "\nError: Cannot find Late cell library in path $LateLibraryPath. Exiting..."
	exit
} else {
	puts "\nInfo: Late cell Library found in path $LateLibraryPath"
}

if {![file exists $ConstraintsFile]} {
	puts "\nError: Cannot find constraints file in path $ConstraintsFile. Exiting..."
	exit
} else {
	puts "\nInfo: Constraints file found in path $ConstraintsFile"
}


#--------------------------------------------------------------------------------------------------------#
#--------------------------------------- Constraints File creation --------------------------------------#
#----------------------------------------------- SDC Format ---------------------------------------------#
#--------------------------------------------------------------------------------------------------------#

puts "\nInfo: Dumping SDC constraints for $DesignName"
::struct::matrix constraints
set chan [open $ConstraintsFile]
csv::read2matrix $chan constraints , auto
close $chan
set number_of_rows [constraints rows]
set number_of_columns [constraints columns]

#--- Check row number for "clocks" and column number for "IO delays and slew section" in constraints.csv ---#
set clock_start [lindex [lindex [constraints search all CLOCKS] 0] 1]
set clock_start_column [lindex [lindex [constraints search all CLOCKS] 0] 0]

#--- Check row number for "inputs" section in constraints.csv ----#
set input_ports_start [lindex [lindex [constraints search all INPUTS] 0] 1]

#--- Check row number for "outputs" section in constraints.csv ---#
set output_ports_start [lindex [lindex [constraints search all OUTPUTS] 0] 1]

#puts "number_of_rows = $number_of_rows\n"
#puts "number_of_columns = $number_of_columns\n"
#puts "clock_start = $clock_start\n"
#puts "clock_start_column = $clock_start_column\n"
#puts "input_ports_start = $input_ports_start\n"
#puts "output_ports_start = $output_ports_start"


#---------------------------------------------------------------------------------------------------------#
#---------------------------------------- Clock constraints ----------------------------------------------#
#---------------------------------------------------------------------------------------------------------#

#----------------------------------- Clock latency constraints -------------------------------------------#

set clock_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr ($number_of_columns-1)] [expr ($input_ports_start-1)] early_rise_delay] 0] 0]
set clock_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr ($number_of_columns-1)] [expr ($input_ports_start-1)] early_fall_delay] 0] 0]
set clock_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr ($number_of_columns-1)] [expr ($input_ports_start-1)] late_rise_delay] 0] 0]
set clock_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr ($number_of_columns-1)] [expr ($input_ports_start-1)] late_fall_delay] 0] 0]


#--------------------------------- Clock transition constraints ------------------------------------------#

set clock_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr ($number_of_columns-1)] [expr ($input_ports_start-1)] early_rise_slew] 0] 0]
set clock_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr ($number_of_columns-1)] [expr ($input_ports_start-1)] early_fall_slew] 0] 0]
set clock_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr ($number_of_columns-1)] [expr ($input_ports_start-1)] late_rise_slew] 0] 0]
set clock_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr ($number_of_columns-1)] [expr ($input_ports_start-1)] late_fall_slew] 0] 0]



set sdc_file [open $OutputDirectory/$DesignName.sdc "w"]
set i [expr {$clock_start+1}]
set end_of_ports [expr {$input_ports_start-1}]
puts "\nInfo-SDC: Working on clock constraints......"
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




#---------------------------------------------------------------------------------------------------------#
#----------------------------------------- Input Constraints ---------------------------------------------#
#---------------------------------------------------------------------------------------------------------#

#---------------------------- Create input delay and slew constraints ------------------------------------#

set input_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_rise_delay] 0] 0]
set input_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_fall_delay] 0] 0]
set input_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_rise_delay] 0] 0]
set input_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_fall_delay] 0] 0]


set input_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_rise_slew] 0] 0]
set input_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_fall_slew] 0] 0]
set input_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_rise_slew] 0] 0]
set input_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_fall_slew] 0] 0]


set related_clock [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] clocks] 0] 0]

set i [expr {$input_ports_start+1}]
set end_of_ports [expr {$output_ports_start-1}]
puts "\nINFO-SDC: Working on IO constraints...."
puts "\nINFO-SDC: Categorizing input ports as bits and bussed"


#--------------------- differentiating input ports as bussed and bits ------------------------------------#

while { $i < $end_of_ports } {
set netlist [glob -dir $NetlistDirectory *.v]
set tmp_file [open /tmp/1 w]
foreach f $netlist {
	set fd [open $f]
	#puts "reading file $f"
	while {[gets $fd line] != -1} {
		set pattern1 " [constraints get cell 0 $i];"
		if {[regexp -all -- $pattern1 $line]} {
			#puts "pattern1 \"$pattern1\" found and matching line in verilog file \"$f\" is \"$line\""
			set pattern2 [lindex [split $line ";"] 0]
			#puts "Creating pattern2 by splitting pattern1 using semi-colon as delimiter => \"$pattern2\""
			if {[regexp -all {input} [lindex [split $pattern2 "\S+"] 0]]} {
				#puts "Out of all patterns, \"$pattern2\" has matching string \"input\". So, preserving this line and ignoring others"
				set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
				#puts "printing first 3 elements of pattern2 as \"$s1\" using space delimiter"
				puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
				#puts "replace multiple spaces in s1 by single space and reformat as \"[regsub -all {\s+} $s1 " "]\""
				}
		}
	}
	close $fd
}
close $tmp_file

set tmp_file [open /tmp/1 r]

#puts "reading [read $tmp_file]"
#puts "reading /tmp/1 file as [split [read $tmp_file] \n]"
#puts "sorting /tmp/1 contents as [lsort -unique [split [read $tmp_file] \n ]]"
#puts "joining /tmp/1 as [join [lsort -unique [split [read $tmp_file] \n ]] \n]"

set tmp2_file [open /tmp/2 w]
puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n ]] \n]"
close $tmp_file
close $tmp2_file
set tmp2_file [open /tmp/2 r]

#puts "count is [llength [read $tmp2_file]]"

set count [llength [read $tmp2_file]]
#puts "Splitting content of tmp_2 using space and counting number of elements as $count"

if { $count > 2 } {
	set inp_ports [concat [constraints get cell 0 $i]*]
	#puts "\nbussed"
} else {
	set inp_ports [constraints get cell 0 $i]
	#puts "\nnot bussed"
}

#puts "\ninput port name is $inp_ports since count is $count\n"

puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_early_rise_delay_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $input_early_fall_delay_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $input_late_rise_delay_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $input_late_fall_delay_start $i] \[get_ports $inp_ports\]"

puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_early_rise_slew_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $input_early_fall_slew_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $input_late_rise_slew_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $input_late_fall_slew_start $i] \[get_ports $inp_ports\]"

set i [expr {$i+1}]
}









