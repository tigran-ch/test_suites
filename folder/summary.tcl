#!/usr/bin/tclsh

# *******************************************************************
# Created              : 05-01-2018
# Revision             : 1.0.0
# Developer            : Tigran Chakhmakhchyan
# Email                : tigranchakhmakhchyan@gmail.com
# Comments             : This script provided to summarize staff list
# *******************************************************************

set total 0
set line_number 0
set format_x -15
set format_y -15

### Usage
proc usage {} {
	puts "							"
	puts "Usage: [info script] <staff_list> <summary>	"
	puts "							"
	puts "Where:						"
	puts "\tInput : <staff_list> is staff list file		"
	puts "\tOutput:  <summary>   is summary file		"
	puts "							"
}

### Printing "usage" if user need help.
set arg_list $argv
if {[lsearch -regexp $arg_list ^--h$|^-h$|^--help$|^-help$] != -1} {
	usage
	exit 0
}

### Printing "usage" when user violate the usage.
set arg_count $argc
if {$arg_count != 2} {
	puts "Incorrect count of arguments"
	puts "Follow the usage:"
	usage
	exit 1
}

### Checking existence of input file
set input_file  [lindex $argv 0]
if {![file isfile $input_file]} {
	puts "Error: Input file \"$input_file\" does not exist."
	exit 1
}

### Checking existence of output file
set output_file [lindex $argv 1]
if {[file exists $output_file]} {
	puts "Error: Output file \"$output_file\" exists. Please specify not existing file name."
	exit 1
}

### Reading input file and collecting data into array
set INPUT_FILE  [open $input_file]
# Ignoring the first line
gets $INPUT_FILE
incr line_number
while {![eof $INPUT_FILE]} {
	set line [gets $INPUT_FILE]
	incr line_number
	if {$line == ""} { continue }
	if {[regexp {^\s*\S+\s*[,;]\s*(\S+)\s*[,;]\s*(\d+(\.\d)?\d*)\s*$} $line match sub1 sub2]} {
		set key $sub1
		set value $sub2
	} else {
		puts "Error: Input file \"$input_file\" contains line with incorrect format(line $line_number):"
		puts "Expected >>Name, Group, Value(real digit)"
		puts "Got      >>$line"
		exit 1
	}
	if {[info exists group_arr($key)]} {
		set group_arr($key) [expr {$group_arr($key) + $value}]
	} else {
		set group_arr($key) $value
	}
}
close $INPUT_FILE

### Generating output file
set OUTPUT_FILE [open $output_file w]
puts $OUTPUT_FILE [format "%${format_x}s %${format_y}s " "Groups " "Sum"]
set group_arr_list [array get group_arr]
# Sorting array by values
set group_arr_list [lsort -stride 2 -index 1 -decreasing -real $group_arr_list]
foreach {group sum} $group_arr_list {
	puts $OUTPUT_FILE [format "%${format_x}s %${format_y}s " "$group:" "$sum"]
	set total [expr {$total + $sum}]
}
puts $OUTPUT_FILE [format "%${format_x}s %${format_y}s " "Total:" "$total"]
close $OUTPUT_FILE

puts "Summary file \"$output_file\" have written successfully." 
