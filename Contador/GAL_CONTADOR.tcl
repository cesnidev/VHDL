
########## Tcl recorder starts at 06/28/15 16:16:59 ##########

set version "2.0"
set proj_dir "C:/Users/Andres/Desktop/GAL_05"
cd $proj_dir

# Get directory paths
set pver $version
regsub -all {\.} $pver {_} pver
set lscfile "lsc_"
append lscfile $pver ".ini"
set lsvini_dir [lindex [array get env LSC_INI_PATH] 1]
set lsvini_path [file join $lsvini_dir $lscfile]
if {[catch {set fid [open $lsvini_path]} msg]} {
	 puts "File Open Error: $lsvini_path"
	 return false
} else {set data [read $fid]; close $fid }
foreach line [split $data '\n'] { 
	set lline [string tolower $line]
	set lline [string trim $lline]
	if {[string compare $lline "\[paths\]"] == 0} { set path 1; continue}
	if {$path && [regexp {^\[} $lline]} {set path 0; break}
	if {$path && [regexp {^bin} $lline]} {set cpld_bin $line; continue}
	if {$path && [regexp {^fpgapath} $lline]} {set fpga_dir $line; continue}
	if {$path && [regexp {^fpgabinpath} $lline]} {set fpga_bin $line}}

set cpld_bin [string range $cpld_bin [expr [string first "=" $cpld_bin]+1] end]
regsub -all "\"" $cpld_bin "" cpld_bin
set cpld_bin [file join $cpld_bin]
set install_dir [string range $cpld_bin 0 [expr [string first "ispcpld" $cpld_bin]-2]]
regsub -all "\"" $install_dir "" install_dir
set install_dir [file join $install_dir]
set fpga_dir [string range $fpga_dir [expr [string first "=" $fpga_dir]+1] end]
regsub -all "\"" $fpga_dir "" fpga_dir
set fpga_dir [file join $fpga_dir]
set fpga_bin [string range $fpga_bin [expr [string first "=" $fpga_bin]+1] end]
regsub -all "\"" $fpga_bin "" fpga_bin
set fpga_bin [file join $fpga_bin]

if {[string match "*$fpga_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$fpga_bin;$env(PATH)" }

if {[string match "*$cpld_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$cpld_bin;$env(PATH)" }

lappend auto_path [file join $install_dir "ispcpld" "tcltk" "lib" "ispwidget" "runproc"]
package require runcmd

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:16:59 ###########


########## Tcl recorder starts at 06/28/15 16:19:43 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:19:43 ###########


########## Tcl recorder starts at 06/28/15 16:19:59 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:19:59 ###########


########## Tcl recorder starts at 06/28/15 16:20:01 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:20:01 ###########


########## Tcl recorder starts at 06/28/15 16:25:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:25:21 ###########


########## Tcl recorder starts at 06/28/15 16:25:28 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:25:28 ###########


########## Tcl recorder starts at 06/28/15 16:25:45 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:25:45 ###########


########## Tcl recorder starts at 06/28/15 16:28:16 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:28:16 ###########


########## Tcl recorder starts at 06/28/15 16:28:27 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:28:27 ###########


########## Tcl recorder starts at 06/28/15 16:28:43 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:28:43 ###########


########## Tcl recorder starts at 06/28/15 16:28:45 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:28:45 ###########


########## Tcl recorder starts at 06/28/15 16:50:32 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:50:32 ###########


########## Tcl recorder starts at 06/28/15 16:50:42 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:50:42 ###########


########## Tcl recorder starts at 06/28/15 16:50:58 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:50:58 ###########


########## Tcl recorder starts at 06/28/15 16:51:00 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:51:00 ###########


########## Tcl recorder starts at 06/28/15 16:52:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:52:44 ###########


########## Tcl recorder starts at 06/28/15 16:52:48 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:52:48 ###########


########## Tcl recorder starts at 06/28/15 16:53:13 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:53:13 ###########


########## Tcl recorder starts at 06/28/15 16:53:14 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:53:14 ###########


########## Tcl recorder starts at 06/28/15 16:54:53 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:54:53 ###########


########## Tcl recorder starts at 06/28/15 16:54:57 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:54:57 ###########


########## Tcl recorder starts at 06/28/15 16:55:13 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:55:13 ###########


########## Tcl recorder starts at 06/28/15 16:55:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:55:44 ###########


########## Tcl recorder starts at 06/28/15 16:55:47 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:55:47 ###########


########## Tcl recorder starts at 06/28/15 16:56:03 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:56:03 ###########


########## Tcl recorder starts at 06/28/15 16:56:05 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:56:05 ###########


########## Tcl recorder starts at 06/28/15 16:58:58 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:58:58 ###########


########## Tcl recorder starts at 06/28/15 16:59:02 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:59:02 ###########


########## Tcl recorder starts at 06/28/15 16:59:18 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 16:59:18 ###########


########## Tcl recorder starts at 06/28/15 17:00:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:00:18 ###########


########## Tcl recorder starts at 06/28/15 17:00:26 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:00:26 ###########


########## Tcl recorder starts at 06/28/15 17:00:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:00:56 ###########


########## Tcl recorder starts at 06/28/15 17:01:01 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:01:01 ###########


########## Tcl recorder starts at 06/28/15 17:02:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:02:52 ###########


########## Tcl recorder starts at 06/28/15 17:02:56 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:02:56 ###########


########## Tcl recorder starts at 06/28/15 17:03:13 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:03:13 ###########


########## Tcl recorder starts at 06/28/15 17:03:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:03:36 ###########


########## Tcl recorder starts at 06/28/15 17:03:38 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:03:38 ###########


########## Tcl recorder starts at 06/28/15 17:03:55 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:03:55 ###########


########## Tcl recorder starts at 06/28/15 17:09:10 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:09:10 ###########


########## Tcl recorder starts at 06/28/15 17:09:12 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:09:12 ###########


########## Tcl recorder starts at 06/28/15 17:09:28 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:09:28 ###########


########## Tcl recorder starts at 06/28/15 17:09:30 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:09:30 ###########


########## Tcl recorder starts at 06/28/15 17:10:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:10:50 ###########


########## Tcl recorder starts at 06/28/15 17:10:54 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:10:54 ###########


########## Tcl recorder starts at 06/28/15 17:11:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:11:17 ###########


########## Tcl recorder starts at 06/28/15 17:11:20 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:11:20 ###########


########## Tcl recorder starts at 06/28/15 17:11:42 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:11:42 ###########


########## Tcl recorder starts at 06/28/15 17:11:58 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:11:58 ###########


########## Tcl recorder starts at 06/28/15 17:13:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:13:08 ###########


########## Tcl recorder starts at 06/28/15 17:13:11 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:13:11 ###########


########## Tcl recorder starts at 06/28/15 17:13:29 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:13:29 ###########


########## Tcl recorder starts at 06/28/15 17:13:31 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:13:31 ###########


########## Tcl recorder starts at 06/28/15 17:14:19 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:14:19 ###########


########## Tcl recorder starts at 06/28/15 17:14:24 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:14:25 ###########


########## Tcl recorder starts at 06/28/15 17:14:42 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:14:42 ###########


########## Tcl recorder starts at 06/28/15 17:14:44 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:14:44 ###########


########## Tcl recorder starts at 06/28/15 17:15:31 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:15:31 ###########


########## Tcl recorder starts at 06/28/15 17:15:34 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:15:34 ###########


########## Tcl recorder starts at 06/28/15 17:15:53 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:15:53 ###########


########## Tcl recorder starts at 06/28/15 17:15:54 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:15:54 ###########


########## Tcl recorder starts at 06/28/15 17:16:59 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:16:59 ###########


########## Tcl recorder starts at 06/28/15 17:17:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:17:02 ###########


########## Tcl recorder starts at 06/28/15 17:17:06 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:17:06 ###########


########## Tcl recorder starts at 06/28/15 17:17:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:17:27 ###########


########## Tcl recorder starts at 06/28/15 17:17:29 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:17:29 ###########


########## Tcl recorder starts at 06/28/15 17:17:58 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:17:58 ###########


########## Tcl recorder starts at 06/28/15 17:18:00 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:18:00 ###########


########## Tcl recorder starts at 06/28/15 17:19:30 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:19:30 ###########


########## Tcl recorder starts at 06/28/15 17:19:33 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:19:33 ###########


########## Tcl recorder starts at 06/28/15 17:20:45 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:20:45 ###########


########## Tcl recorder starts at 06/28/15 17:20:46 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:20:46 ###########


########## Tcl recorder starts at 06/28/15 17:26:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:26:27 ###########


########## Tcl recorder starts at 06/28/15 17:26:31 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:26:31 ###########


########## Tcl recorder starts at 06/28/15 17:26:51 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:26:51 ###########


########## Tcl recorder starts at 06/28/15 17:26:52 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:26:52 ###########


########## Tcl recorder starts at 06/28/15 17:31:47 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:31:48 ###########


########## Tcl recorder starts at 06/28/15 17:31:51 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:31:51 ###########


########## Tcl recorder starts at 06/28/15 17:32:07 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:32:07 ###########


########## Tcl recorder starts at 06/28/15 17:32:09 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:32:09 ###########


########## Tcl recorder starts at 06/28/15 17:36:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:36:42 ###########


########## Tcl recorder starts at 06/28/15 17:36:46 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:36:46 ###########


########## Tcl recorder starts at 06/28/15 17:37:02 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:37:02 ###########


########## Tcl recorder starts at 06/28/15 17:37:04 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:37:04 ###########


########## Tcl recorder starts at 06/28/15 17:41:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:41:49 ###########


########## Tcl recorder starts at 06/28/15 17:41:53 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:41:53 ###########


########## Tcl recorder starts at 06/28/15 17:42:11 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:42:11 ###########


########## Tcl recorder starts at 06/28/15 17:42:13 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:42:13 ###########


########## Tcl recorder starts at 06/28/15 17:51:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:51:45 ###########


########## Tcl recorder starts at 06/28/15 17:51:57 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:51:57 ###########


########## Tcl recorder starts at 06/28/15 17:52:15 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:52:15 ###########


########## Tcl recorder starts at 06/28/15 17:52:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:52:33 ###########


########## Tcl recorder starts at 06/28/15 17:52:35 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:52:35 ###########


########## Tcl recorder starts at 06/28/15 17:52:52 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:52:52 ###########


########## Tcl recorder starts at 06/28/15 17:52:54 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:52:54 ###########


########## Tcl recorder starts at 06/28/15 17:54:32 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:54:32 ###########


########## Tcl recorder starts at 06/28/15 17:54:48 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:54:48 ###########


########## Tcl recorder starts at 06/28/15 17:55:51 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:55:51 ###########


########## Tcl recorder starts at 06/28/15 17:55:55 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:55:56 ###########


########## Tcl recorder starts at 06/28/15 17:56:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:56:17 ###########


########## Tcl recorder starts at 06/28/15 17:56:21 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:56:21 ###########


########## Tcl recorder starts at 06/28/15 17:56:43 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:56:43 ###########


########## Tcl recorder starts at 06/28/15 17:56:44 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:56:44 ###########


########## Tcl recorder starts at 06/28/15 17:57:16 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:57:17 ###########


########## Tcl recorder starts at 06/28/15 17:57:20 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:57:20 ###########


########## Tcl recorder starts at 06/28/15 17:57:42 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:57:42 ###########


########## Tcl recorder starts at 06/28/15 17:57:44 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:57:44 ###########


########## Tcl recorder starts at 06/28/15 18:00:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:00:56 ###########


########## Tcl recorder starts at 06/28/15 18:01:02 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:01:02 ###########


########## Tcl recorder starts at 06/28/15 18:01:20 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:01:20 ###########


########## Tcl recorder starts at 06/28/15 18:01:21 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:01:21 ###########


########## Tcl recorder starts at 06/28/15 18:02:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:02:05 ###########


########## Tcl recorder starts at 06/28/15 18:02:10 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:02:10 ###########


########## Tcl recorder starts at 06/28/15 18:05:00 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:05:00 ###########


########## Tcl recorder starts at 06/28/15 18:05:03 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:05:03 ###########


########## Tcl recorder starts at 06/28/15 18:05:28 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:05:28 ###########


########## Tcl recorder starts at 06/28/15 18:05:30 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:05:30 ###########


########## Tcl recorder starts at 06/28/15 18:06:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:06:05 ###########


########## Tcl recorder starts at 06/28/15 18:06:08 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:06:08 ###########


########## Tcl recorder starts at 06/28/15 18:06:24 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:06:24 ###########


########## Tcl recorder starts at 06/28/15 18:06:25 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:06:25 ###########


########## Tcl recorder starts at 06/28/15 18:07:54 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:07:54 ###########


########## Tcl recorder starts at 06/28/15 18:07:58 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:07:58 ###########


########## Tcl recorder starts at 06/28/15 18:09:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:09:17 ###########


########## Tcl recorder starts at 06/28/15 18:09:19 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:09:20 ###########


########## Tcl recorder starts at 06/28/15 18:09:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:09:56 ###########


########## Tcl recorder starts at 06/28/15 18:09:58 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:09:58 ###########


########## Tcl recorder starts at 06/28/15 18:10:37 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:10:37 ###########


########## Tcl recorder starts at 06/28/15 18:10:41 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:10:41 ###########


########## Tcl recorder starts at 06/28/15 18:10:57 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:10:57 ###########


########## Tcl recorder starts at 06/28/15 18:10:59 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:10:59 ###########


########## Tcl recorder starts at 06/28/15 18:12:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:12:08 ###########


########## Tcl recorder starts at 06/28/15 18:12:11 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:12:11 ###########


########## Tcl recorder starts at 06/28/15 18:12:44 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:12:44 ###########


########## Tcl recorder starts at 06/28/15 18:12:45 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:12:45 ###########


########## Tcl recorder starts at 06/28/15 18:14:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:14:25 ###########


########## Tcl recorder starts at 06/28/15 18:15:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:15:42 ###########


########## Tcl recorder starts at 06/28/15 18:15:45 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:15:45 ###########


########## Tcl recorder starts at 06/28/15 18:16:01 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:16:01 ###########


########## Tcl recorder starts at 06/28/15 18:16:03 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:16:03 ###########


########## Tcl recorder starts at 06/28/15 18:17:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:17:42 ###########


########## Tcl recorder starts at 06/28/15 18:18:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:18:40 ###########


########## Tcl recorder starts at 06/28/15 18:19:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:19:40 ###########


########## Tcl recorder starts at 06/28/15 18:20:13 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:20:13 ###########


########## Tcl recorder starts at 06/28/15 18:20:16 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:20:16 ###########


########## Tcl recorder starts at 06/28/15 18:20:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:20:52 ###########


########## Tcl recorder starts at 06/28/15 18:20:54 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:20:54 ###########


########## Tcl recorder starts at 06/28/15 18:21:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:21:27 ###########


########## Tcl recorder starts at 06/28/15 18:21:30 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:21:30 ###########


########## Tcl recorder starts at 06/28/15 18:21:47 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:21:47 ###########


########## Tcl recorder starts at 06/28/15 18:21:49 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:21:49 ###########


########## Tcl recorder starts at 06/28/15 18:23:03 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:23:03 ###########


########## Tcl recorder starts at 06/28/15 18:23:06 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:23:06 ###########


########## Tcl recorder starts at 06/28/15 18:23:27 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:23:27 ###########


########## Tcl recorder starts at 06/28/15 18:23:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:23:43 ###########


########## Tcl recorder starts at 06/28/15 18:23:46 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:23:46 ###########


########## Tcl recorder starts at 06/28/15 18:24:15 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:24:15 ###########


########## Tcl recorder starts at 06/28/15 18:24:17 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:24:17 ###########


########## Tcl recorder starts at 06/28/15 18:25:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:25:26 ###########


########## Tcl recorder starts at 06/28/15 18:25:29 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:25:29 ###########


########## Tcl recorder starts at 06/28/15 18:25:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:25:49 ###########


########## Tcl recorder starts at 06/28/15 18:25:51 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:25:51 ###########


########## Tcl recorder starts at 06/28/15 18:26:08 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:26:08 ###########


########## Tcl recorder starts at 06/28/15 18:26:10 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:26:10 ###########


########## Tcl recorder starts at 06/28/15 18:27:46 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:27:46 ###########


########## Tcl recorder starts at 06/28/15 18:27:48 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:27:48 ###########


########## Tcl recorder starts at 06/28/15 18:28:06 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:28:06 ###########


########## Tcl recorder starts at 06/28/15 18:28:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:28:25 ###########


########## Tcl recorder starts at 06/28/15 18:28:32 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:28:32 ###########


########## Tcl recorder starts at 06/28/15 18:28:58 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:28:58 ###########


########## Tcl recorder starts at 06/28/15 18:29:35 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:29:35 ###########


########## Tcl recorder starts at 06/28/15 18:31:46 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:31:46 ###########


########## Tcl recorder starts at 06/28/15 18:31:48 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:31:48 ###########


########## Tcl recorder starts at 06/28/15 18:32:05 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:32:05 ###########


########## Tcl recorder starts at 06/28/15 18:32:20 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:32:20 ###########


########## Tcl recorder starts at 06/28/15 18:32:37 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:32:37 ###########


########## Tcl recorder starts at 06/28/15 18:32:55 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:32:55 ###########


########## Tcl recorder starts at 06/28/15 18:33:16 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:33:16 ###########


########## Tcl recorder starts at 06/28/15 18:33:22 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:33:22 ###########


########## Tcl recorder starts at 06/28/15 18:33:23 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:33:23 ###########


########## Tcl recorder starts at 06/28/15 18:33:44 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:33:44 ###########


########## Tcl recorder starts at 06/28/15 18:33:45 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:33:45 ###########


########## Tcl recorder starts at 06/28/15 18:35:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:35:49 ###########


########## Tcl recorder starts at 06/28/15 18:36:00 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:36:00 ###########


########## Tcl recorder starts at 06/28/15 18:36:27 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:36:27 ###########


########## Tcl recorder starts at 06/28/15 18:36:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:36:40 ###########


########## Tcl recorder starts at 06/28/15 18:36:43 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:36:43 ###########


########## Tcl recorder starts at 06/28/15 18:36:59 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:36:59 ###########


########## Tcl recorder starts at 06/28/15 18:37:11 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:37:11 ###########


########## Tcl recorder starts at 06/28/15 18:37:14 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:37:14 ###########


########## Tcl recorder starts at 06/28/15 18:37:32 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:37:32 ###########


########## Tcl recorder starts at 06/28/15 18:37:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:37:45 ###########


########## Tcl recorder starts at 06/28/15 18:37:51 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:37:51 ###########


########## Tcl recorder starts at 06/28/15 18:38:10 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:38:10 ###########


########## Tcl recorder starts at 06/28/15 18:38:12 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:38:12 ###########


########## Tcl recorder starts at 06/28/15 18:39:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:39:08 ###########


########## Tcl recorder starts at 06/28/15 18:39:11 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:39:11 ###########


########## Tcl recorder starts at 06/28/15 18:39:34 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:39:34 ###########


########## Tcl recorder starts at 06/28/15 18:40:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:40:05 ###########


########## Tcl recorder starts at 06/28/15 18:40:37 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:40:37 ###########


########## Tcl recorder starts at 06/28/15 18:40:40 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:40:40 ###########


########## Tcl recorder starts at 06/28/15 18:40:56 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:40:56 ###########


########## Tcl recorder starts at 06/28/15 18:40:58 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:40:58 ###########


########## Tcl recorder starts at 06/28/15 18:41:37 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:41:37 ###########


########## Tcl recorder starts at 06/28/15 18:41:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:41:40 ###########


########## Tcl recorder starts at 06/28/15 18:41:47 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:41:47 ###########


########## Tcl recorder starts at 06/28/15 18:42:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:42:17 ###########


########## Tcl recorder starts at 06/28/15 18:42:19 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:42:19 ###########


########## Tcl recorder starts at 06/28/15 18:42:36 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:42:36 ###########


########## Tcl recorder starts at 06/28/15 18:42:37 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:42:37 ###########


########## Tcl recorder starts at 06/28/15 18:45:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:45:49 ###########


########## Tcl recorder starts at 06/28/15 18:45:52 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:45:52 ###########


########## Tcl recorder starts at 06/28/15 18:46:10 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:46:10 ###########


########## Tcl recorder starts at 06/28/15 18:47:29 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:47:29 ###########


########## Tcl recorder starts at 06/28/15 18:47:41 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:47:41 ###########


########## Tcl recorder starts at 06/28/15 18:47:59 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:47:59 ###########


########## Tcl recorder starts at 06/28/15 18:48:01 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:48:01 ###########


########## Tcl recorder starts at 06/28/15 18:50:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:50:12 ###########


########## Tcl recorder starts at 06/28/15 18:50:15 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:50:15 ###########


########## Tcl recorder starts at 06/28/15 18:50:32 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:50:32 ###########


########## Tcl recorder starts at 06/28/15 18:51:07 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:51:07 ###########


########## Tcl recorder starts at 06/28/15 18:51:14 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:51:14 ###########


########## Tcl recorder starts at 06/28/15 18:51:32 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:51:32 ###########


########## Tcl recorder starts at 06/28/15 18:51:47 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:51:47 ###########


########## Tcl recorder starts at 06/28/15 18:51:53 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:51:53 ###########


########## Tcl recorder starts at 06/28/15 18:52:02 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:52:02 ###########


########## Tcl recorder starts at 06/28/15 18:52:18 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:52:18 ###########


########## Tcl recorder starts at 06/28/15 18:52:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:52:26 ###########


########## Tcl recorder starts at 06/28/15 18:52:31 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:52:31 ###########


########## Tcl recorder starts at 06/28/15 18:52:48 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:52:48 ###########


########## Tcl recorder starts at 06/28/15 18:52:50 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:52:50 ###########


########## Tcl recorder starts at 06/28/15 18:53:48 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:53:48 ###########


########## Tcl recorder starts at 06/28/15 18:53:50 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:53:50 ###########


########## Tcl recorder starts at 06/28/15 18:54:08 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:54:08 ###########


########## Tcl recorder starts at 06/28/15 18:54:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:54:21 ###########


########## Tcl recorder starts at 06/28/15 18:54:24 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:54:24 ###########


########## Tcl recorder starts at 06/28/15 18:54:42 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:54:42 ###########


########## Tcl recorder starts at 06/28/15 18:54:44 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:54:44 ###########


########## Tcl recorder starts at 06/28/15 18:55:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:55:34 ###########


########## Tcl recorder starts at 06/28/15 18:55:37 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:55:37 ###########


########## Tcl recorder starts at 06/28/15 18:55:54 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:55:54 ###########


########## Tcl recorder starts at 06/28/15 18:56:39 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:56:40 ###########


########## Tcl recorder starts at 06/28/15 18:56:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:56:43 ###########


########## Tcl recorder starts at 06/28/15 18:56:47 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:56:47 ###########


########## Tcl recorder starts at 06/28/15 18:57:05 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:57:05 ###########


########## Tcl recorder starts at 06/28/15 18:57:07 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:57:07 ###########


########## Tcl recorder starts at 06/28/15 18:57:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:57:41 ###########


########## Tcl recorder starts at 06/28/15 18:57:44 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:57:44 ###########


########## Tcl recorder starts at 06/28/15 18:58:01 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:58:01 ###########


########## Tcl recorder starts at 06/28/15 18:58:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:58:18 ###########


########## Tcl recorder starts at 06/28/15 18:58:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:58:38 ###########


########## Tcl recorder starts at 06/28/15 18:58:48 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:58:48 ###########


########## Tcl recorder starts at 06/28/15 18:58:57 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:58:57 ###########


########## Tcl recorder starts at 06/28/15 18:59:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:59:12 ###########


########## Tcl recorder starts at 06/28/15 18:59:16 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:59:16 ###########


########## Tcl recorder starts at 06/28/15 18:59:34 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:59:34 ###########


########## Tcl recorder starts at 06/28/15 18:59:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:59:45 ###########


########## Tcl recorder starts at 06/28/15 18:59:48 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 18:59:48 ###########


########## Tcl recorder starts at 06/28/15 19:00:04 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:00:04 ###########


########## Tcl recorder starts at 06/28/15 19:00:06 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:00:06 ###########


########## Tcl recorder starts at 06/28/15 19:01:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:01:36 ###########


########## Tcl recorder starts at 06/28/15 19:01:53 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:01:53 ###########


########## Tcl recorder starts at 06/28/15 19:02:11 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:02:11 ###########


########## Tcl recorder starts at 06/28/15 19:02:33 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:02:33 ###########


########## Tcl recorder starts at 06/28/15 19:02:35 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:02:35 ###########


########## Tcl recorder starts at 06/28/15 19:03:13 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:03:13 ###########


########## Tcl recorder starts at 06/28/15 19:03:17 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:03:17 ###########


########## Tcl recorder starts at 06/28/15 19:03:34 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:03:34 ###########


########## Tcl recorder starts at 06/28/15 19:03:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:03:56 ###########


########## Tcl recorder starts at 06/28/15 19:03:58 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:03:58 ###########


########## Tcl recorder starts at 06/28/15 19:04:15 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:04:15 ###########


########## Tcl recorder starts at 06/28/15 19:04:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:04:27 ###########


########## Tcl recorder starts at 06/28/15 19:04:30 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:04:30 ###########


########## Tcl recorder starts at 06/28/15 19:04:48 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:04:48 ###########


########## Tcl recorder starts at 06/28/15 19:04:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:04:56 ###########


########## Tcl recorder starts at 06/28/15 19:05:01 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:05:01 ###########


########## Tcl recorder starts at 06/28/15 19:05:04 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:05:04 ###########


########## Tcl recorder starts at 06/28/15 19:05:21 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:05:21 ###########


########## Tcl recorder starts at 06/28/15 19:05:22 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:05:22 ###########


########## Tcl recorder starts at 06/28/15 19:06:07 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:06:07 ###########


########## Tcl recorder starts at 06/28/15 19:06:18 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:06:18 ###########


########## Tcl recorder starts at 06/28/15 19:06:36 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:06:36 ###########


########## Tcl recorder starts at 06/28/15 19:06:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:06:49 ###########


########## Tcl recorder starts at 06/28/15 19:07:10 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:07:10 ###########


########## Tcl recorder starts at 06/28/15 19:07:12 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:07:12 ###########


########## Tcl recorder starts at 06/28/15 19:07:28 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:07:29 ###########


########## Tcl recorder starts at 06/28/15 19:07:30 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:07:30 ###########


########## Tcl recorder starts at 06/28/15 19:09:16 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:09:16 ###########


########## Tcl recorder starts at 06/28/15 19:09:20 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:09:20 ###########


########## Tcl recorder starts at 06/28/15 19:09:46 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:09:46 ###########


########## Tcl recorder starts at 06/28/15 19:09:49 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:09:49 ###########


########## Tcl recorder starts at 06/28/15 19:10:13 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:10:13 ###########


########## Tcl recorder starts at 06/28/15 19:10:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:10:34 ###########


########## Tcl recorder starts at 06/28/15 19:10:39 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:10:39 ###########


########## Tcl recorder starts at 06/28/15 19:10:56 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:10:56 ###########


########## Tcl recorder starts at 06/28/15 19:10:57 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:10:57 ###########


########## Tcl recorder starts at 06/28/15 19:12:23 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:12:23 ###########


########## Tcl recorder starts at 06/28/15 19:12:37 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:12:37 ###########


########## Tcl recorder starts at 06/28/15 19:12:40 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:12:40 ###########


########## Tcl recorder starts at 06/28/15 19:12:57 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:12:57 ###########


########## Tcl recorder starts at 06/28/15 19:13:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:13:38 ###########


########## Tcl recorder starts at 06/28/15 19:13:58 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:13:58 ###########


########## Tcl recorder starts at 06/28/15 19:14:01 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:14:01 ###########


########## Tcl recorder starts at 06/28/15 19:14:17 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:14:17 ###########


########## Tcl recorder starts at 06/28/15 19:14:30 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:14:30 ###########


########## Tcl recorder starts at 06/28/15 19:15:03 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:15:03 ###########


########## Tcl recorder starts at 06/28/15 19:15:08 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:15:08 ###########


########## Tcl recorder starts at 06/28/15 19:15:59 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:15:59 ###########


########## Tcl recorder starts at 06/28/15 19:16:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:16:17 ###########


########## Tcl recorder starts at 06/28/15 19:16:21 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:16:21 ###########


########## Tcl recorder starts at 06/28/15 19:16:44 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:16:44 ###########


########## Tcl recorder starts at 06/28/15 19:16:53 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:16:53 ###########


########## Tcl recorder starts at 06/28/15 19:17:04 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:17:04 ###########


########## Tcl recorder starts at 06/28/15 19:17:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:17:18 ###########


########## Tcl recorder starts at 06/28/15 19:17:22 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:17:22 ###########


########## Tcl recorder starts at 06/28/15 19:17:38 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:17:38 ###########


########## Tcl recorder starts at 06/28/15 19:17:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:17:49 ###########


########## Tcl recorder starts at 06/28/15 19:18:46 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:18:46 ###########


########## Tcl recorder starts at 06/28/15 19:18:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:18:52 ###########


########## Tcl recorder starts at 06/28/15 19:18:58 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:18:58 ###########


########## Tcl recorder starts at 06/28/15 19:19:01 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:19:01 ###########


########## Tcl recorder starts at 06/28/15 19:19:21 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:19:21 ###########


########## Tcl recorder starts at 06/28/15 19:19:26 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:19:26 ###########


########## Tcl recorder starts at 06/28/15 19:20:32 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:20:32 ###########


########## Tcl recorder starts at 06/28/15 19:20:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:20:42 ###########


########## Tcl recorder starts at 06/28/15 19:21:03 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:21:03 ###########


########## Tcl recorder starts at 06/28/15 19:21:20 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:21:20 ###########


########## Tcl recorder starts at 06/28/15 19:22:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:22:02 ###########


########## Tcl recorder starts at 06/28/15 19:22:05 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:22:05 ###########


########## Tcl recorder starts at 06/28/15 19:22:23 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:22:23 ###########


########## Tcl recorder starts at 06/28/15 19:22:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:22:45 ###########


########## Tcl recorder starts at 06/28/15 19:23:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:23:50 ###########


########## Tcl recorder starts at 06/28/15 19:23:53 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:23:53 ###########


########## Tcl recorder starts at 06/28/15 19:24:16 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:24:16 ###########


########## Tcl recorder starts at 06/28/15 19:24:19 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:24:19 ###########


########## Tcl recorder starts at 06/28/15 19:24:38 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:24:38 ###########


########## Tcl recorder starts at 06/28/15 19:25:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:25:02 ###########


########## Tcl recorder starts at 06/28/15 19:25:04 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:25:04 ###########


########## Tcl recorder starts at 06/28/15 19:25:24 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:25:24 ###########


########## Tcl recorder starts at 06/28/15 19:25:32 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:25:32 ###########


########## Tcl recorder starts at 06/28/15 19:25:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:25:34 ###########


########## Tcl recorder starts at 06/28/15 19:25:38 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:25:38 ###########


########## Tcl recorder starts at 06/28/15 19:26:29 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:26:29 ###########


########## Tcl recorder starts at 06/28/15 19:26:30 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:26:30 ###########


########## Tcl recorder starts at 06/28/15 19:27:31 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:27:31 ###########


########## Tcl recorder starts at 06/28/15 19:27:33 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:27:33 ###########


########## Tcl recorder starts at 06/28/15 19:28:01 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:28:01 ###########


########## Tcl recorder starts at 06/28/15 19:28:04 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:28:04 ###########


########## Tcl recorder starts at 06/28/15 19:28:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:28:49 ###########


########## Tcl recorder starts at 06/28/15 19:29:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:29:33 ###########


########## Tcl recorder starts at 06/28/15 19:29:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:29:43 ###########


########## Tcl recorder starts at 06/28/15 19:29:53 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:29:53 ###########


########## Tcl recorder starts at 06/28/15 19:29:57 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:29:57 ###########


########## Tcl recorder starts at 06/28/15 19:30:15 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:30:15 ###########


########## Tcl recorder starts at 06/28/15 19:30:17 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:30:17 ###########


########## Tcl recorder starts at 06/28/15 19:32:29 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:32:29 ###########


########## Tcl recorder starts at 06/28/15 19:32:32 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:32:32 ###########


########## Tcl recorder starts at 06/28/15 19:32:50 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:32:50 ###########


########## Tcl recorder starts at 06/28/15 19:33:03 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:33:03 ###########


########## Tcl recorder starts at 06/28/15 19:33:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:33:38 ###########


########## Tcl recorder starts at 06/28/15 19:33:41 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:33:41 ###########


########## Tcl recorder starts at 06/28/15 19:34:04 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:34:04 ###########


########## Tcl recorder starts at 06/28/15 19:34:07 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:34:07 ###########


########## Tcl recorder starts at 06/28/15 19:36:03 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:36:03 ###########


########## Tcl recorder starts at 06/28/15 19:36:10 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:36:10 ###########


########## Tcl recorder starts at 06/28/15 19:36:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:36:18 ###########


########## Tcl recorder starts at 06/28/15 19:36:46 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:36:46 ###########


########## Tcl recorder starts at 06/28/15 19:36:48 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:36:48 ###########


########## Tcl recorder starts at 06/28/15 19:37:15 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:37:15 ###########


########## Tcl recorder starts at 06/28/15 19:37:17 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:37:17 ###########


########## Tcl recorder starts at 06/28/15 19:37:39 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:37:39 ###########


########## Tcl recorder starts at 06/28/15 19:37:54 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:37:54 ###########


########## Tcl recorder starts at 06/28/15 19:38:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:38:06 ###########


########## Tcl recorder starts at 06/28/15 19:38:09 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:38:09 ###########


########## Tcl recorder starts at 06/28/15 19:38:52 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:38:52 ###########


########## Tcl recorder starts at 06/28/15 19:38:54 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:38:54 ###########


########## Tcl recorder starts at 06/28/15 19:40:30 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:40:30 ###########


########## Tcl recorder starts at 06/28/15 19:40:32 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:40:32 ###########


########## Tcl recorder starts at 06/28/15 19:40:49 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:40:49 ###########


########## Tcl recorder starts at 06/28/15 19:40:51 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:40:51 ###########


########## Tcl recorder starts at 06/28/15 19:42:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:42:42 ###########


########## Tcl recorder starts at 06/28/15 19:42:48 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:42:48 ###########


########## Tcl recorder starts at 06/28/15 19:43:05 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:43:05 ###########


########## Tcl recorder starts at 06/28/15 19:43:06 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:43:06 ###########


########## Tcl recorder starts at 06/28/15 19:43:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:43:56 ###########


########## Tcl recorder starts at 06/28/15 19:43:58 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:43:58 ###########


########## Tcl recorder starts at 06/28/15 19:44:24 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:44:24 ###########


########## Tcl recorder starts at 06/28/15 19:44:26 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:44:26 ###########


########## Tcl recorder starts at 06/28/15 19:47:10 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:47:10 ###########


########## Tcl recorder starts at 06/28/15 19:47:15 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:47:15 ###########


########## Tcl recorder starts at 06/28/15 19:47:33 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:47:33 ###########


########## Tcl recorder starts at 06/28/15 19:47:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:47:52 ###########


########## Tcl recorder starts at 06/28/15 19:47:59 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:47:59 ###########


########## Tcl recorder starts at 06/28/15 19:49:11 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:49:11 ###########


########## Tcl recorder starts at 06/28/15 19:49:16 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:49:16 ###########


########## Tcl recorder starts at 06/28/15 19:49:57 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:49:57 ###########


########## Tcl recorder starts at 06/28/15 19:50:24 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:50:24 ###########


########## Tcl recorder starts at 06/28/15 19:50:27 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:50:27 ###########


########## Tcl recorder starts at 06/28/15 19:50:44 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:50:44 ###########


########## Tcl recorder starts at 06/28/15 19:50:54 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:50:54 ###########


########## Tcl recorder starts at 06/28/15 19:50:57 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:50:57 ###########


########## Tcl recorder starts at 06/28/15 19:51:20 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:51:20 ###########


########## Tcl recorder starts at 06/28/15 19:51:22 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:51:22 ###########


########## Tcl recorder starts at 06/28/15 19:53:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:53:27 ###########


########## Tcl recorder starts at 06/28/15 19:53:30 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:53:30 ###########


########## Tcl recorder starts at 06/28/15 19:54:28 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:54:28 ###########


########## Tcl recorder starts at 06/28/15 19:54:31 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:54:31 ###########


########## Tcl recorder starts at 06/28/15 19:54:55 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:54:55 ###########


########## Tcl recorder starts at 06/28/15 19:54:56 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:54:56 ###########


########## Tcl recorder starts at 06/28/15 19:57:10 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:57:10 ###########


########## Tcl recorder starts at 06/28/15 19:57:12 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:57:12 ###########


########## Tcl recorder starts at 06/28/15 19:57:30 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:57:30 ###########


########## Tcl recorder starts at 06/28/15 19:57:31 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:57:31 ###########


########## Tcl recorder starts at 06/28/15 19:59:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:59:40 ###########


########## Tcl recorder starts at 06/28/15 19:59:43 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 19:59:43 ###########


########## Tcl recorder starts at 06/28/15 20:00:01 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:00:01 ###########


########## Tcl recorder starts at 06/28/15 20:00:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:00:12 ###########


########## Tcl recorder starts at 06/28/15 20:00:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:00:50 ###########


########## Tcl recorder starts at 06/28/15 20:00:54 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:00:54 ###########


########## Tcl recorder starts at 06/28/15 20:14:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:14:40 ###########


########## Tcl recorder starts at 06/28/15 20:14:43 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:14:43 ###########


########## Tcl recorder starts at 06/28/15 20:15:01 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:15:01 ###########


########## Tcl recorder starts at 06/28/15 20:15:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:15:17 ###########


########## Tcl recorder starts at 06/28/15 20:15:19 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:15:19 ###########


########## Tcl recorder starts at 06/28/15 20:15:55 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:15:55 ###########


########## Tcl recorder starts at 06/28/15 20:15:58 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:15:58 ###########


########## Tcl recorder starts at 06/28/15 20:16:18 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:16:18 ###########


########## Tcl recorder starts at 06/28/15 20:16:20 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:16:20 ###########


########## Tcl recorder starts at 06/28/15 20:18:29 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:18:29 ###########


########## Tcl recorder starts at 06/28/15 20:18:31 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:18:31 ###########


########## Tcl recorder starts at 06/28/15 20:18:49 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:18:49 ###########


########## Tcl recorder starts at 06/28/15 20:19:30 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:19:30 ###########


########## Tcl recorder starts at 06/28/15 20:19:32 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:19:32 ###########


########## Tcl recorder starts at 06/28/15 20:19:50 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:19:50 ###########


########## Tcl recorder starts at 06/28/15 20:20:28 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:20:28 ###########


########## Tcl recorder starts at 06/28/15 20:20:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:20:36 ###########


########## Tcl recorder starts at 06/28/15 20:20:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:20:39 ###########


########## Tcl recorder starts at 06/28/15 20:20:48 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:20:49 ###########


########## Tcl recorder starts at 06/28/15 20:20:51 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:20:51 ###########


########## Tcl recorder starts at 06/28/15 20:20:54 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:20:54 ###########


########## Tcl recorder starts at 06/28/15 20:21:12 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:21:12 ###########


########## Tcl recorder starts at 06/28/15 20:21:17 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:21:17 ###########


########## Tcl recorder starts at 06/28/15 20:22:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:22:42 ###########


########## Tcl recorder starts at 06/28/15 20:22:45 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:22:45 ###########


########## Tcl recorder starts at 06/28/15 20:23:02 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:23:02 ###########


########## Tcl recorder starts at 06/28/15 20:23:08 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:23:08 ###########


########## Tcl recorder starts at 06/28/15 20:23:30 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:23:30 ###########


########## Tcl recorder starts at 06/28/15 20:23:33 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:23:33 ###########


########## Tcl recorder starts at 06/28/15 20:23:59 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:23:59 ###########


########## Tcl recorder starts at 06/28/15 20:24:03 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:24:03 ###########


########## Tcl recorder starts at 06/28/15 20:24:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:24:44 ###########


########## Tcl recorder starts at 06/28/15 20:24:47 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:24:47 ###########


########## Tcl recorder starts at 06/28/15 20:25:20 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:25:20 ###########


########## Tcl recorder starts at 06/28/15 20:25:22 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:25:22 ###########


########## Tcl recorder starts at 06/28/15 20:25:42 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:25:42 ###########


########## Tcl recorder starts at 06/28/15 20:25:44 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:25:44 ###########


########## Tcl recorder starts at 06/28/15 20:26:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:26:49 ###########


########## Tcl recorder starts at 06/28/15 20:26:53 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:26:53 ###########


########## Tcl recorder starts at 06/28/15 20:27:11 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:27:11 ###########


########## Tcl recorder starts at 06/28/15 20:27:13 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:27:13 ###########


########## Tcl recorder starts at 06/28/15 20:29:14 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:29:14 ###########


########## Tcl recorder starts at 06/28/15 20:29:18 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:29:18 ###########


########## Tcl recorder starts at 06/28/15 20:38:19 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:38:19 ###########


########## Tcl recorder starts at 06/28/15 20:38:21 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:38:21 ###########


########## Tcl recorder starts at 06/28/15 20:39:14 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:39:14 ###########


########## Tcl recorder starts at 06/28/15 20:39:37 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:39:37 ###########


########## Tcl recorder starts at 06/28/15 20:39:41 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:39:41 ###########


########## Tcl recorder starts at 06/28/15 20:39:59 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:39:59 ###########


########## Tcl recorder starts at 06/28/15 20:40:01 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:40:01 ###########


########## Tcl recorder starts at 06/28/15 20:44:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:44:25 ###########


########## Tcl recorder starts at 06/28/15 20:44:29 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:44:29 ###########


########## Tcl recorder starts at 06/28/15 20:44:46 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:44:46 ###########


########## Tcl recorder starts at 06/28/15 20:44:48 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:44:48 ###########


########## Tcl recorder starts at 06/28/15 20:45:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:45:38 ###########


########## Tcl recorder starts at 06/28/15 20:46:03 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:46:03 ###########


########## Tcl recorder starts at 06/28/15 20:46:31 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:46:31 ###########


########## Tcl recorder starts at 06/28/15 20:46:34 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:46:34 ###########


########## Tcl recorder starts at 06/28/15 20:47:00 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:47:00 ###########


########## Tcl recorder starts at 06/28/15 20:47:10 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:47:10 ###########


########## Tcl recorder starts at 06/28/15 20:47:12 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:47:12 ###########


########## Tcl recorder starts at 06/28/15 20:47:28 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:47:28 ###########


########## Tcl recorder starts at 06/28/15 20:47:30 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:47:30 ###########


########## Tcl recorder starts at 06/28/15 23:18:15 ##########

set version "2.0"
set proj_dir "C:/Users/Andres/Desktop/Contador"
cd $proj_dir

# Get directory paths
set pver $version
regsub -all {\.} $pver {_} pver
set lscfile "lsc_"
append lscfile $pver ".ini"
set lsvini_dir [lindex [array get env LSC_INI_PATH] 1]
set lsvini_path [file join $lsvini_dir $lscfile]
if {[catch {set fid [open $lsvini_path]} msg]} {
	 puts "File Open Error: $lsvini_path"
	 return false
} else {set data [read $fid]; close $fid }
foreach line [split $data '\n'] { 
	set lline [string tolower $line]
	set lline [string trim $lline]
	if {[string compare $lline "\[paths\]"] == 0} { set path 1; continue}
	if {$path && [regexp {^\[} $lline]} {set path 0; break}
	if {$path && [regexp {^bin} $lline]} {set cpld_bin $line; continue}
	if {$path && [regexp {^fpgapath} $lline]} {set fpga_dir $line; continue}
	if {$path && [regexp {^fpgabinpath} $lline]} {set fpga_bin $line}}

set cpld_bin [string range $cpld_bin [expr [string first "=" $cpld_bin]+1] end]
regsub -all "\"" $cpld_bin "" cpld_bin
set cpld_bin [file join $cpld_bin]
set install_dir [string range $cpld_bin 0 [expr [string first "ispcpld" $cpld_bin]-2]]
regsub -all "\"" $install_dir "" install_dir
set install_dir [file join $install_dir]
set fpga_dir [string range $fpga_dir [expr [string first "=" $fpga_dir]+1] end]
regsub -all "\"" $fpga_dir "" fpga_dir
set fpga_dir [file join $fpga_dir]
set fpga_bin [string range $fpga_bin [expr [string first "=" $fpga_bin]+1] end]
regsub -all "\"" $fpga_bin "" fpga_bin
set fpga_bin [file join $fpga_bin]

if {[string match "*$fpga_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$fpga_bin;$env(PATH)" }

if {[string match "*$cpld_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$cpld_bin;$env(PATH)" }

lappend auto_path [file join $install_dir "ispcpld" "tcltk" "lib" "ispwidget" "runproc"]
package require runcmd

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:18:15 ###########


########## Tcl recorder starts at 06/28/15 23:18:18 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:18:18 ###########


########## Tcl recorder starts at 06/28/15 23:18:35 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:18:35 ###########


########## Tcl recorder starts at 06/28/15 23:18:51 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:18:51 ###########


########## Tcl recorder starts at 06/28/15 23:18:54 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:18:54 ###########


########## Tcl recorder starts at 06/28/15 23:19:20 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:19:20 ###########


########## Tcl recorder starts at 06/28/15 23:19:22 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:19:22 ###########


########## Tcl recorder starts at 06/28/15 23:19:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:19:43 ###########


########## Tcl recorder starts at 06/28/15 23:20:01 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:20:01 ###########


########## Tcl recorder starts at 06/28/15 23:20:04 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:20:04 ###########


########## Tcl recorder starts at 06/28/15 23:20:21 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:20:21 ###########


########## Tcl recorder starts at 06/28/15 23:20:32 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:20:32 ###########


########## Tcl recorder starts at 06/28/15 23:20:39 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:20:39 ###########


########## Tcl recorder starts at 06/28/15 23:20:46 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:20:46 ###########


########## Tcl recorder starts at 06/28/15 23:21:25 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:21:25 ###########


########## Tcl recorder starts at 06/28/15 23:22:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:22:06 ###########


########## Tcl recorder starts at 06/28/15 23:22:09 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:22:10 ###########


########## Tcl recorder starts at 06/28/15 23:22:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:22:52 ###########


########## Tcl recorder starts at 06/28/15 23:22:57 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:22:57 ###########


########## Tcl recorder starts at 06/28/15 23:23:45 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:23:45 ###########


########## Tcl recorder starts at 06/28/15 23:24:03 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:24:03 ###########


########## Tcl recorder starts at 06/28/15 23:24:06 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:24:06 ###########


########## Tcl recorder starts at 06/28/15 23:24:23 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:24:23 ###########


########## Tcl recorder starts at 06/28/15 23:24:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:24:41 ###########


########## Tcl recorder starts at 06/28/15 23:24:43 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:24:43 ###########


########## Tcl recorder starts at 06/28/15 23:25:00 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:25:00 ###########


########## Tcl recorder starts at 06/28/15 23:25:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:25:41 ###########


########## Tcl recorder starts at 06/28/15 23:25:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:25:56 ###########


########## Tcl recorder starts at 06/28/15 23:26:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:26:06 ###########


########## Tcl recorder starts at 06/28/15 23:26:09 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:26:09 ###########


########## Tcl recorder starts at 06/28/15 23:26:26 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:26:26 ###########


########## Tcl recorder starts at 06/28/15 23:26:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:26:44 ###########


########## Tcl recorder starts at 06/28/15 23:26:47 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:26:47 ###########


########## Tcl recorder starts at 06/28/15 23:27:04 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:27:04 ###########


########## Tcl recorder starts at 06/28/15 23:27:16 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:27:16 ###########


########## Tcl recorder starts at 06/28/15 23:27:18 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:27:18 ###########


########## Tcl recorder starts at 06/28/15 23:27:35 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:27:35 ###########


########## Tcl recorder starts at 06/28/15 23:27:37 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:27:37 ###########


########## Tcl recorder starts at 06/28/15 23:28:22 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:28:22 ###########


########## Tcl recorder starts at 06/28/15 23:28:26 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:28:26 ###########


########## Tcl recorder starts at 06/28/15 23:28:44 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:28:44 ###########


########## Tcl recorder starts at 06/28/15 23:29:07 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:29:07 ###########


########## Tcl recorder starts at 06/28/15 23:29:10 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:29:10 ###########


########## Tcl recorder starts at 06/28/15 23:29:37 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:29:37 ###########


########## Tcl recorder starts at 06/28/15 23:29:41 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:29:41 ###########


########## Tcl recorder starts at 06/28/15 23:29:57 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:29:58 ###########


########## Tcl recorder starts at 06/28/15 23:29:59 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:29:59 ###########


########## Tcl recorder starts at 06/28/15 23:31:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:31:05 ###########


########## Tcl recorder starts at 06/28/15 23:31:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:31:26 ###########


########## Tcl recorder starts at 06/28/15 23:31:30 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:31:30 ###########


########## Tcl recorder starts at 06/28/15 23:31:47 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:31:47 ###########


########## Tcl recorder starts at 06/28/15 23:32:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:32:02 ###########


########## Tcl recorder starts at 06/28/15 23:32:04 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:32:04 ###########


########## Tcl recorder starts at 06/28/15 23:32:21 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:32:21 ###########


########## Tcl recorder starts at 06/28/15 23:32:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:32:38 ###########


########## Tcl recorder starts at 06/28/15 23:32:41 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:32:41 ###########


########## Tcl recorder starts at 06/28/15 23:33:01 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:33:01 ###########


########## Tcl recorder starts at 06/28/15 23:33:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:33:21 ###########


########## Tcl recorder starts at 06/28/15 23:33:24 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:33:24 ###########


########## Tcl recorder starts at 06/28/15 23:33:41 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:33:41 ###########


########## Tcl recorder starts at 06/28/15 23:34:01 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:34:01 ###########


########## Tcl recorder starts at 06/28/15 23:34:03 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:34:03 ###########


########## Tcl recorder starts at 06/28/15 23:34:19 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:34:19 ###########


########## Tcl recorder starts at 06/28/15 23:34:35 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:34:35 ###########


########## Tcl recorder starts at 06/28/15 23:34:42 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:34:42 ###########


########## Tcl recorder starts at 06/28/15 23:34:58 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:34:58 ###########


########## Tcl recorder starts at 06/28/15 23:34:59 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:35:00 ###########


########## Tcl recorder starts at 07/08/15 20:16:43 ##########

set version "2.0"
set proj_dir "C:/Users/Andres/Documents/respaldo/proyecto/Contador"
cd $proj_dir

# Get directory paths
set pver $version
regsub -all {\.} $pver {_} pver
set lscfile "lsc_"
append lscfile $pver ".ini"
set lsvini_dir [lindex [array get env LSC_INI_PATH] 1]
set lsvini_path [file join $lsvini_dir $lscfile]
if {[catch {set fid [open $lsvini_path]} msg]} {
	 puts "File Open Error: $lsvini_path"
	 return false
} else {set data [read $fid]; close $fid }
foreach line [split $data '\n'] { 
	set lline [string tolower $line]
	set lline [string trim $lline]
	if {[string compare $lline "\[paths\]"] == 0} { set path 1; continue}
	if {$path && [regexp {^\[} $lline]} {set path 0; break}
	if {$path && [regexp {^bin} $lline]} {set cpld_bin $line; continue}
	if {$path && [regexp {^fpgapath} $lline]} {set fpga_dir $line; continue}
	if {$path && [regexp {^fpgabinpath} $lline]} {set fpga_bin $line}}

set cpld_bin [string range $cpld_bin [expr [string first "=" $cpld_bin]+1] end]
regsub -all "\"" $cpld_bin "" cpld_bin
set cpld_bin [file join $cpld_bin]
set install_dir [string range $cpld_bin 0 [expr [string first "ispcpld" $cpld_bin]-2]]
regsub -all "\"" $install_dir "" install_dir
set install_dir [file join $install_dir]
set fpga_dir [string range $fpga_dir [expr [string first "=" $fpga_dir]+1] end]
regsub -all "\"" $fpga_dir "" fpga_dir
set fpga_dir [file join $fpga_dir]
set fpga_bin [string range $fpga_bin [expr [string first "=" $fpga_bin]+1] end]
regsub -all "\"" $fpga_bin "" fpga_bin
set fpga_bin [file join $fpga_bin]

if {[string match "*$fpga_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$fpga_bin;$env(PATH)" }

if {[string match "*$cpld_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$cpld_bin;$env(PATH)" }

lappend auto_path [file join $install_dir "ispcpld" "tcltk" "lib" "ispwidget" "runproc"]
package require runcmd

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/08/15 20:16:43 ###########


########## Tcl recorder starts at 07/08/15 20:16:46 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/08/15 20:16:46 ###########


########## Tcl recorder starts at 07/08/15 20:17:11 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_contador.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_contador.bl3 -pla -o gal_contador.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_contador.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/08/15 20:17:11 ###########


########## Tcl recorder starts at 07/08/15 20:17:13 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_contador.tt3 -dev p22v10g -o gal_contador.jed -ivec NoInput.tmv -rep gal_contador.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_contador -if gal_contador.jed -j2s -log gal_contador.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/08/15 20:17:13 ###########


########## Tcl recorder starts at 07/08/15 20:17:48 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/08/15 20:17:48 ###########


########## Tcl recorder starts at 07/08/15 20:18:04 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/08/15 20:18:04 ###########


########## Tcl recorder starts at 07/08/15 20:22:23 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/08/15 20:22:23 ###########


########## Tcl recorder starts at 07/08/15 20:23:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/08/15 20:23:52 ###########


########## Tcl recorder starts at 07/08/15 20:23:56 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/08/15 20:23:57 ###########


########## Tcl recorder starts at 07/08/15 20:24:37 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/08/15 20:24:37 ###########


########## Tcl recorder starts at 07/08/15 20:24:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main_contador.vhd\" -o \"main_contador.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/08/15 20:24:42 ###########


########## Tcl recorder starts at 07/08/15 20:24:45 ##########

# Commands to make the Process: 
# Link Design
if [catch {open contador.cmd w} rspFile] {
	puts stderr "Cannot create response file contador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_contador.sty
PROJECT: contador
WORKING_PATH: \"$proj_dir\"
MODULE: contador
VHDL_FILE_LIST: main_contador.vhd
OUTPUT_FILE_NAME: contador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e contador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete contador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"contador.edi\" -out \"contador.bl0\" -err automake.err -log \"contador.log\" -prj gal_contador -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"contador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"contador.bl1\" -o \"gal_contador.bl2\" -omod contador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/08/15 20:24:45 ###########

