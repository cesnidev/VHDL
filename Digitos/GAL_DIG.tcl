
########## Tcl recorder starts at 06/28/15 10:12:13 ##########

set version "2.0"
set proj_dir "C:/Users/Andres/Desktop/GAL_09"
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
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:12:13 ###########


########## Tcl recorder starts at 06/28/15 10:12:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:12:17 ###########


########## Tcl recorder starts at 06/28/15 10:12:23 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:12:23 ###########


########## Tcl recorder starts at 06/28/15 10:12:41 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:12:41 ###########


########## Tcl recorder starts at 06/28/15 10:12:58 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:12:58 ###########


########## Tcl recorder starts at 06/28/15 10:13:05 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:13:05 ###########


########## Tcl recorder starts at 06/28/15 10:13:29 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:13:29 ###########


########## Tcl recorder starts at 06/28/15 10:13:30 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:13:30 ###########


########## Tcl recorder starts at 06/28/15 10:14:11 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:14:11 ###########


########## Tcl recorder starts at 06/28/15 10:14:48 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:14:48 ###########


########## Tcl recorder starts at 06/28/15 10:15:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:15:34 ###########


########## Tcl recorder starts at 06/28/15 10:15:41 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:15:41 ###########


########## Tcl recorder starts at 06/28/15 10:16:16 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:16:16 ###########


########## Tcl recorder starts at 06/28/15 10:16:18 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:16:18 ###########


########## Tcl recorder starts at 06/28/15 10:16:46 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:16:46 ###########


########## Tcl recorder starts at 06/28/15 10:16:51 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:16:51 ###########


########## Tcl recorder starts at 06/28/15 10:18:16 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:18:16 ###########


########## Tcl recorder starts at 06/28/15 10:18:27 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:18:27 ###########


########## Tcl recorder starts at 06/28/15 10:20:24 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:20:24 ###########


########## Tcl recorder starts at 06/28/15 10:20:26 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:20:26 ###########


########## Tcl recorder starts at 06/28/15 10:21:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:21:44 ###########


########## Tcl recorder starts at 06/28/15 10:24:09 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:24:09 ###########


########## Tcl recorder starts at 06/28/15 10:24:28 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:24:28 ###########


########## Tcl recorder starts at 06/28/15 10:24:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:24:38 ###########


########## Tcl recorder starts at 06/28/15 10:24:46 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:24:46 ###########


########## Tcl recorder starts at 06/28/15 10:24:57 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:24:57 ###########


########## Tcl recorder starts at 06/28/15 10:25:30 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:25:30 ###########


########## Tcl recorder starts at 06/28/15 10:25:47 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:25:47 ###########


########## Tcl recorder starts at 06/28/15 10:25:50 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:25:50 ###########


########## Tcl recorder starts at 06/28/15 10:26:10 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:26:10 ###########


########## Tcl recorder starts at 06/28/15 10:26:26 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:26:26 ###########


########## Tcl recorder starts at 06/28/15 10:27:24 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:27:24 ###########


########## Tcl recorder starts at 06/28/15 10:27:30 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:27:30 ###########


########## Tcl recorder starts at 06/28/15 10:27:55 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:27:55 ###########


########## Tcl recorder starts at 06/28/15 10:27:57 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:27:57 ###########


########## Tcl recorder starts at 06/28/15 10:31:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:31:08 ###########


########## Tcl recorder starts at 06/28/15 10:32:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:32:08 ###########


########## Tcl recorder starts at 06/28/15 10:32:17 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:32:17 ###########


########## Tcl recorder starts at 06/28/15 10:34:59 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:34:59 ###########


########## Tcl recorder starts at 06/28/15 10:35:01 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:35:01 ###########


########## Tcl recorder starts at 06/28/15 10:36:31 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:36:31 ###########


########## Tcl recorder starts at 06/28/15 10:36:48 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:36:48 ###########


########## Tcl recorder starts at 06/28/15 10:36:55 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:36:55 ###########


########## Tcl recorder starts at 06/28/15 10:37:19 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:37:19 ###########


########## Tcl recorder starts at 06/28/15 10:37:21 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:37:21 ###########


########## Tcl recorder starts at 06/28/15 10:39:07 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:39:07 ###########


########## Tcl recorder starts at 06/28/15 10:39:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:39:18 ###########


########## Tcl recorder starts at 06/28/15 10:39:32 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:39:32 ###########


########## Tcl recorder starts at 06/28/15 10:39:53 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:39:53 ###########


########## Tcl recorder starts at 06/28/15 10:40:01 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:40:01 ###########


########## Tcl recorder starts at 06/28/15 10:46:31 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:46:31 ###########


########## Tcl recorder starts at 06/28/15 10:46:34 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:46:34 ###########


########## Tcl recorder starts at 06/28/15 10:46:51 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:46:51 ###########


########## Tcl recorder starts at 06/28/15 10:46:54 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:46:54 ###########


########## Tcl recorder starts at 06/28/15 10:48:13 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:48:13 ###########


########## Tcl recorder starts at 06/28/15 10:48:16 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:48:16 ###########


########## Tcl recorder starts at 06/28/15 10:48:35 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:48:35 ###########


########## Tcl recorder starts at 06/28/15 10:48:42 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:48:42 ###########


########## Tcl recorder starts at 06/28/15 10:49:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:49:05 ###########


########## Tcl recorder starts at 06/28/15 10:49:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:49:49 ###########


########## Tcl recorder starts at 06/28/15 10:49:52 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:49:52 ###########


########## Tcl recorder starts at 06/28/15 10:50:12 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:50:12 ###########


########## Tcl recorder starts at 06/28/15 10:50:16 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:50:16 ###########


########## Tcl recorder starts at 06/28/15 10:52:04 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:52:04 ###########


########## Tcl recorder starts at 06/28/15 10:52:15 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:52:15 ###########


########## Tcl recorder starts at 06/28/15 10:52:20 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:52:20 ###########


########## Tcl recorder starts at 06/28/15 10:52:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:52:44 ###########


########## Tcl recorder starts at 06/28/15 10:52:46 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:52:46 ###########


########## Tcl recorder starts at 06/28/15 10:53:14 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:53:14 ###########


########## Tcl recorder starts at 06/28/15 10:53:21 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:53:21 ###########


########## Tcl recorder starts at 06/28/15 10:54:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:54:05 ###########


########## Tcl recorder starts at 06/28/15 10:54:09 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:54:09 ###########


########## Tcl recorder starts at 06/28/15 10:55:07 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:55:07 ###########


########## Tcl recorder starts at 06/28/15 10:55:20 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:55:20 ###########


########## Tcl recorder starts at 06/28/15 10:56:20 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:56:20 ###########


########## Tcl recorder starts at 06/28/15 10:56:34 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:56:34 ###########


########## Tcl recorder starts at 06/28/15 10:57:12 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:57:12 ###########


########## Tcl recorder starts at 06/28/15 10:57:15 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:57:15 ###########


########## Tcl recorder starts at 06/28/15 10:57:53 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 10:57:53 ###########


########## Tcl recorder starts at 06/28/15 11:00:09 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:00:09 ###########


########## Tcl recorder starts at 06/28/15 11:00:16 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:00:16 ###########


########## Tcl recorder starts at 06/28/15 11:01:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:01:08 ###########


########## Tcl recorder starts at 06/28/15 11:01:15 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:01:15 ###########


########## Tcl recorder starts at 06/28/15 11:04:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:04:02 ###########


########## Tcl recorder starts at 06/28/15 11:04:40 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:04:40 ###########


########## Tcl recorder starts at 06/28/15 11:06:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:06:52 ###########


########## Tcl recorder starts at 06/28/15 11:07:01 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:07:01 ###########


########## Tcl recorder starts at 06/28/15 11:08:19 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:08:19 ###########


########## Tcl recorder starts at 06/28/15 11:08:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:08:25 ###########


########## Tcl recorder starts at 06/28/15 11:08:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:08:45 ###########


########## Tcl recorder starts at 06/28/15 11:08:48 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:08:48 ###########


########## Tcl recorder starts at 06/28/15 11:09:34 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:09:34 ###########


########## Tcl recorder starts at 06/28/15 11:09:39 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:09:39 ###########


########## Tcl recorder starts at 06/28/15 11:12:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:12:42 ###########


########## Tcl recorder starts at 06/28/15 11:13:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:13:06 ###########


########## Tcl recorder starts at 06/28/15 11:13:11 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:13:11 ###########


########## Tcl recorder starts at 06/28/15 11:13:32 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:13:32 ###########


########## Tcl recorder starts at 06/28/15 11:13:34 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:13:34 ###########


########## Tcl recorder starts at 06/28/15 11:14:03 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:14:03 ###########


########## Tcl recorder starts at 06/28/15 11:14:04 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:14:04 ###########


########## Tcl recorder starts at 06/28/15 11:14:28 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:14:28 ###########


########## Tcl recorder starts at 06/28/15 11:16:55 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:16:55 ###########


########## Tcl recorder starts at 06/28/15 11:17:13 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:17:13 ###########


########## Tcl recorder starts at 06/28/15 11:17:54 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:17:55 ###########


########## Tcl recorder starts at 06/28/15 11:18:14 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:18:14 ###########


########## Tcl recorder starts at 06/28/15 11:18:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:18:34 ###########


########## Tcl recorder starts at 06/28/15 11:18:36 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:18:36 ###########


########## Tcl recorder starts at 06/28/15 11:21:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:21:25 ###########


########## Tcl recorder starts at 06/28/15 11:21:29 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:21:29 ###########


########## Tcl recorder starts at 06/28/15 11:24:07 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:24:07 ###########


########## Tcl recorder starts at 06/28/15 11:24:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:24:33 ###########


########## Tcl recorder starts at 06/28/15 11:24:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:24:40 ###########


########## Tcl recorder starts at 06/28/15 11:24:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:24:45 ###########


########## Tcl recorder starts at 06/28/15 11:24:55 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:24:55 ###########


########## Tcl recorder starts at 06/28/15 11:25:00 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:25:00 ###########


########## Tcl recorder starts at 06/28/15 11:25:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:25:18 ###########


########## Tcl recorder starts at 06/28/15 11:25:22 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:25:22 ###########


########## Tcl recorder starts at 06/28/15 11:26:01 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:26:01 ###########


########## Tcl recorder starts at 06/28/15 11:26:03 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:26:03 ###########


########## Tcl recorder starts at 06/28/15 11:26:26 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:26:26 ###########


########## Tcl recorder starts at 06/28/15 11:26:28 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:26:28 ###########


########## Tcl recorder starts at 06/28/15 11:27:07 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:27:07 ###########


########## Tcl recorder starts at 06/28/15 11:27:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:27:34 ###########


########## Tcl recorder starts at 06/28/15 11:27:57 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:27:57 ###########


########## Tcl recorder starts at 06/28/15 11:28:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:28:21 ###########


########## Tcl recorder starts at 06/28/15 11:28:24 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:28:24 ###########


########## Tcl recorder starts at 06/28/15 11:28:41 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:28:41 ###########


########## Tcl recorder starts at 06/28/15 11:28:43 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:28:43 ###########


########## Tcl recorder starts at 06/28/15 11:30:13 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:30:13 ###########


########## Tcl recorder starts at 06/28/15 11:30:30 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:30:30 ###########


########## Tcl recorder starts at 06/28/15 11:30:40 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:30:40 ###########


########## Tcl recorder starts at 06/28/15 11:31:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:31:18 ###########


########## Tcl recorder starts at 06/28/15 11:31:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:31:42 ###########


########## Tcl recorder starts at 06/28/15 11:31:45 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:31:45 ###########


########## Tcl recorder starts at 06/28/15 11:32:07 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:32:07 ###########


########## Tcl recorder starts at 06/28/15 11:32:13 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:32:13 ###########


########## Tcl recorder starts at 06/28/15 11:41:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:41:50 ###########


########## Tcl recorder starts at 06/28/15 11:42:00 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:42:00 ###########


########## Tcl recorder starts at 06/28/15 11:42:11 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:42:11 ###########


########## Tcl recorder starts at 06/28/15 11:43:07 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:43:07 ###########


########## Tcl recorder starts at 06/28/15 11:43:12 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:43:12 ###########


########## Tcl recorder starts at 06/28/15 11:43:30 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:43:30 ###########


########## Tcl recorder starts at 06/28/15 11:43:32 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:43:32 ###########


########## Tcl recorder starts at 06/28/15 11:44:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:44:43 ###########


########## Tcl recorder starts at 06/28/15 11:44:49 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:44:49 ###########


########## Tcl recorder starts at 06/28/15 11:45:07 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:45:07 ###########


########## Tcl recorder starts at 06/28/15 11:45:09 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:45:09 ###########


########## Tcl recorder starts at 06/28/15 11:46:37 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:46:37 ###########


########## Tcl recorder starts at 06/28/15 11:46:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:46:45 ###########


########## Tcl recorder starts at 06/28/15 11:47:39 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:47:39 ###########


########## Tcl recorder starts at 06/28/15 11:47:45 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:47:45 ###########


########## Tcl recorder starts at 06/28/15 11:49:10 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:49:10 ###########


########## Tcl recorder starts at 06/28/15 11:55:13 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:55:13 ###########


########## Tcl recorder starts at 06/28/15 11:55:23 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:55:23 ###########


########## Tcl recorder starts at 06/28/15 11:56:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:56:26 ###########


########## Tcl recorder starts at 06/28/15 11:56:32 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:56:32 ###########


########## Tcl recorder starts at 06/28/15 11:56:38 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:56:38 ###########


########## Tcl recorder starts at 06/28/15 11:57:20 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:57:20 ###########


########## Tcl recorder starts at 06/28/15 11:57:22 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:57:22 ###########


########## Tcl recorder starts at 06/28/15 11:58:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:58:12 ###########


########## Tcl recorder starts at 06/28/15 11:58:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:58:18 ###########


########## Tcl recorder starts at 06/28/15 11:58:27 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:58:27 ###########


########## Tcl recorder starts at 06/28/15 11:59:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 11:59:12 ###########


########## Tcl recorder starts at 06/28/15 12:01:48 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:01:48 ###########


########## Tcl recorder starts at 06/28/15 12:01:54 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:01:54 ###########


########## Tcl recorder starts at 06/28/15 12:04:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:04:45 ###########


########## Tcl recorder starts at 06/28/15 12:04:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:04:52 ###########


########## Tcl recorder starts at 06/28/15 12:04:58 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:04:58 ###########


########## Tcl recorder starts at 06/28/15 12:05:02 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:05:02 ###########


########## Tcl recorder starts at 06/28/15 12:05:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:05:56 ###########


########## Tcl recorder starts at 06/28/15 12:05:59 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:05:59 ###########


########## Tcl recorder starts at 06/28/15 12:06:51 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:06:51 ###########


########## Tcl recorder starts at 06/28/15 12:06:55 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:06:55 ###########


########## Tcl recorder starts at 06/28/15 12:07:58 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:07:58 ###########


########## Tcl recorder starts at 06/28/15 12:08:01 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:08:01 ###########


########## Tcl recorder starts at 06/28/15 12:08:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:08:50 ###########


########## Tcl recorder starts at 06/28/15 12:08:53 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:08:53 ###########


########## Tcl recorder starts at 06/28/15 12:09:58 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:09:58 ###########


########## Tcl recorder starts at 06/28/15 12:10:03 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:10:03 ###########


########## Tcl recorder starts at 06/28/15 12:12:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:12:25 ###########


########## Tcl recorder starts at 06/28/15 12:12:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:12:34 ###########


########## Tcl recorder starts at 06/28/15 12:12:50 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:12:50 ###########


########## Tcl recorder starts at 06/28/15 12:14:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:14:41 ###########


########## Tcl recorder starts at 06/28/15 12:14:50 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:14:50 ###########


########## Tcl recorder starts at 06/28/15 12:15:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:15:45 ###########


########## Tcl recorder starts at 06/28/15 12:15:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:15:49 ###########


########## Tcl recorder starts at 06/28/15 12:15:53 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:15:53 ###########


########## Tcl recorder starts at 06/28/15 12:16:13 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:16:13 ###########


########## Tcl recorder starts at 06/28/15 12:16:17 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:16:17 ###########


########## Tcl recorder starts at 06/28/15 12:17:07 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:17:07 ###########


########## Tcl recorder starts at 06/28/15 12:17:28 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:17:28 ###########


########## Tcl recorder starts at 06/28/15 12:17:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:17:52 ###########


########## Tcl recorder starts at 06/28/15 12:17:57 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:17:57 ###########


########## Tcl recorder starts at 06/28/15 12:19:10 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:19:10 ###########


########## Tcl recorder starts at 06/28/15 12:19:17 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:19:17 ###########


########## Tcl recorder starts at 06/28/15 12:19:50 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:19:50 ###########


########## Tcl recorder starts at 06/28/15 12:19:52 ##########

# Commands to make the Process: 
# Chip Report
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:19:52 ###########


########## Tcl recorder starts at 06/28/15 12:19:54 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:19:54 ###########


########## Tcl recorder starts at 06/28/15 12:21:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:21:21 ###########


########## Tcl recorder starts at 06/28/15 12:22:24 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:22:24 ###########


########## Tcl recorder starts at 06/28/15 12:24:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:24:02 ###########


########## Tcl recorder starts at 06/28/15 12:24:12 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:24:12 ###########


########## Tcl recorder starts at 06/28/15 12:24:35 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:24:35 ###########


########## Tcl recorder starts at 06/28/15 12:24:37 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:24:37 ###########


########## Tcl recorder starts at 06/28/15 12:24:56 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:24:56 ###########


########## Tcl recorder starts at 06/28/15 12:24:59 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:24:59 ###########


########## Tcl recorder starts at 06/28/15 12:28:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:28:56 ###########


########## Tcl recorder starts at 06/28/15 12:28:59 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:28:59 ###########


########## Tcl recorder starts at 06/28/15 12:29:18 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:29:18 ###########


########## Tcl recorder starts at 06/28/15 12:29:20 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:29:20 ###########


########## Tcl recorder starts at 06/28/15 12:56:46 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:56:46 ###########


########## Tcl recorder starts at 06/28/15 12:56:54 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 12:56:54 ###########


########## Tcl recorder starts at 06/28/15 13:10:03 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 13:10:03 ###########


########## Tcl recorder starts at 06/28/15 13:11:29 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 13:11:29 ###########


########## Tcl recorder starts at 06/28/15 13:11:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 13:11:50 ###########


########## Tcl recorder starts at 06/28/15 13:11:52 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 13:11:52 ###########


########## Tcl recorder starts at 06/28/15 13:12:12 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 13:12:12 ###########


########## Tcl recorder starts at 06/28/15 13:12:13 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 13:12:13 ###########


########## Tcl recorder starts at 06/28/15 13:25:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 13:25:17 ###########


########## Tcl recorder starts at 06/28/15 13:25:59 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 13:25:59 ###########


########## Tcl recorder starts at 06/28/15 13:26:16 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 13:26:16 ###########


########## Tcl recorder starts at 06/28/15 13:26:18 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 13:26:18 ###########


########## Tcl recorder starts at 06/28/15 15:32:13 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:32:13 ###########


########## Tcl recorder starts at 06/28/15 15:32:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:32:43 ###########


########## Tcl recorder starts at 06/28/15 15:32:49 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:32:49 ###########


########## Tcl recorder starts at 06/28/15 15:33:06 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:33:06 ###########


########## Tcl recorder starts at 06/28/15 15:33:08 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:33:08 ###########


########## Tcl recorder starts at 06/28/15 15:46:07 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:46:07 ###########


########## Tcl recorder starts at 06/28/15 15:46:35 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:46:35 ###########


########## Tcl recorder starts at 06/28/15 15:47:13 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:47:13 ###########


########## Tcl recorder starts at 06/28/15 15:47:15 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:47:15 ###########


########## Tcl recorder starts at 06/28/15 15:51:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:51:12 ###########


########## Tcl recorder starts at 06/28/15 15:51:23 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:51:23 ###########


########## Tcl recorder starts at 06/28/15 15:51:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:51:43 ###########


########## Tcl recorder starts at 06/28/15 15:51:46 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:51:46 ###########


########## Tcl recorder starts at 06/28/15 15:51:50 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:51:50 ###########


########## Tcl recorder starts at 06/28/15 15:52:20 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:52:20 ###########


########## Tcl recorder starts at 06/28/15 15:52:21 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:52:21 ###########


########## Tcl recorder starts at 06/28/15 15:53:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:53:12 ###########


########## Tcl recorder starts at 06/28/15 15:54:32 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:54:32 ###########


########## Tcl recorder starts at 06/28/15 15:55:09 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:55:09 ###########


########## Tcl recorder starts at 06/28/15 15:55:28 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:55:28 ###########


########## Tcl recorder starts at 06/28/15 15:55:34 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:55:34 ###########


########## Tcl recorder starts at 06/28/15 15:55:58 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:55:58 ###########


########## Tcl recorder starts at 06/28/15 15:56:00 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:56:00 ###########


########## Tcl recorder starts at 06/28/15 15:56:26 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:56:26 ###########


########## Tcl recorder starts at 06/28/15 15:56:28 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:56:28 ###########


########## Tcl recorder starts at 06/28/15 15:57:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:57:25 ###########


########## Tcl recorder starts at 06/28/15 15:57:37 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:57:37 ###########


########## Tcl recorder starts at 06/28/15 15:58:27 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:58:27 ###########


########## Tcl recorder starts at 06/28/15 15:58:47 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:58:47 ###########


########## Tcl recorder starts at 06/28/15 15:58:51 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 15:58:51 ###########


########## Tcl recorder starts at 06/28/15 17:25:07 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:25:07 ###########


########## Tcl recorder starts at 06/28/15 17:25:10 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:25:10 ###########


########## Tcl recorder starts at 06/28/15 17:25:27 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:25:27 ###########


########## Tcl recorder starts at 06/28/15 17:25:30 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:25:30 ###########


########## Tcl recorder starts at 06/28/15 17:29:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:29:43 ###########


########## Tcl recorder starts at 06/28/15 17:29:54 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:29:54 ###########


########## Tcl recorder starts at 06/28/15 17:30:46 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:30:46 ###########


########## Tcl recorder starts at 06/28/15 17:30:48 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:30:48 ###########


########## Tcl recorder starts at 06/28/15 17:33:10 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:33:10 ###########


########## Tcl recorder starts at 06/28/15 17:35:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:35:21 ###########


########## Tcl recorder starts at 06/28/15 17:35:24 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:35:24 ###########


########## Tcl recorder starts at 06/28/15 17:35:55 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:35:55 ###########


########## Tcl recorder starts at 06/28/15 17:35:56 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:35:56 ###########


########## Tcl recorder starts at 06/28/15 17:38:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:38:40 ###########


########## Tcl recorder starts at 06/28/15 17:38:43 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:38:43 ###########


########## Tcl recorder starts at 06/28/15 17:38:59 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:38:59 ###########


########## Tcl recorder starts at 06/28/15 17:39:00 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:39:00 ###########


########## Tcl recorder starts at 06/28/15 17:41:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:41:06 ###########


########## Tcl recorder starts at 06/28/15 17:41:14 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:41:14 ###########


########## Tcl recorder starts at 06/28/15 17:41:32 ##########

# Commands to make the Process: 
# Linked Equations
if [runCmd "\"$cpld_bin/blif2eqn\" \"gal_dig.bl2\" -o \"gal_dig.eq2\" -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:41:32 ###########


########## Tcl recorder starts at 06/28/15 17:41:33 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:41:33 ###########


########## Tcl recorder starts at 06/28/15 17:41:36 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:41:36 ###########


########## Tcl recorder starts at 06/28/15 17:59:24 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:59:24 ###########


########## Tcl recorder starts at 06/28/15 17:59:29 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:59:29 ###########


########## Tcl recorder starts at 06/28/15 17:59:47 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:59:47 ###########


########## Tcl recorder starts at 06/28/15 17:59:48 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 17:59:49 ###########


########## Tcl recorder starts at 06/28/15 20:48:29 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:48:29 ###########


########## Tcl recorder starts at 06/28/15 20:48:32 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:48:32 ###########


########## Tcl recorder starts at 06/28/15 20:48:49 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:48:49 ###########


########## Tcl recorder starts at 06/28/15 20:48:51 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 20:48:51 ###########


########## Tcl recorder starts at 06/28/15 23:36:09 ##########

set version "2.0"
set proj_dir "C:/Users/Andres/Desktop/Digitos"
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
if [runCmd "\"$cpld_bin/vhd2jhd\" \"main.vhd\" -o \"main.jhd\" -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:36:09 ###########


########## Tcl recorder starts at 06/28/15 23:36:12 ##########

# Commands to make the Process: 
# Link Design
if [catch {open decodificador.cmd w} rspFile] {
	puts stderr "Cannot create response file decodificador.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: gal_dig.sty
PROJECT: decodificador
WORKING_PATH: \"$proj_dir\"
MODULE: decodificador
VHDL_FILE_LIST: main.vhd
OUTPUT_FILE_NAME: decodificador
SUFFIX_NAME: edi
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e decodificador -target ispGAL -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete decodificador.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf \"decodificador.edi\" -out \"decodificador.bl0\" -err automake.err -log \"decodificador.log\" -prj gal_dig -lib \"$install_dir/ispcpld/dat/mach.edn\" -cvt YES -net_Vcc VCC -net_GND GND -nbx -dse -tlw"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"decodificador.bl0\" -red bypin choose -collapse -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"decodificador.bl1\" -o \"gal_dig.bl2\" -omod decodificador -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:36:12 ###########


########## Tcl recorder starts at 06/28/15 23:36:29 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" gal_dig.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" gal_dig.bl3 -pla -o gal_dig.tt2 -dev p22v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" gal_dig.tt2 -dev p22v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:36:29 ###########


########## Tcl recorder starts at 06/28/15 23:36:31 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" gal_dig.tt3 -dev p22v10g -o gal_dig.jed -ivec NoInput.tmv -rep gal_dig.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj gal_dig -if gal_dig.jed -j2s -log gal_dig.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/28/15 23:36:31 ###########

