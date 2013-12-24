
set tb_path         [pwd]
set project_path    [pwd]/../
set quartus_sim_lib $::env(HOME)/software/quartus13.1/quartus/eda/sim_lib
set uvm_lib         $::env(HOME)/workspace/uvm-1.1d/src
set inc_dir         "$project_path $tb_path $uvm_lib"

# verilog global defines. examples:
# RFC_EN=1 equal to `define RFC_EN 1
#set VERILOG_GLOBAL_DEFINES {RFC_EN=1};
set VERILOG_GLOBAL_DEFINES {}

# src files list
#set FILE_LIST "[exec grep -v // files]"
set FILE_LIST "tb_main.sv"

# paths where files are
set SEARCH_PATH "$project_path $tb_path $uvm_lib $quartus_sim_lib"

# tag timestamp
set last_compile_time 0; puts ""


echo "# NOTE: Creating library..."
if [file exists work] {
  vdel -all
}
vlib work
# vmap altera_mf work


if [file exists vlog.opt] {
  rm vlog.opt
}

echo "# NOTE: Processing global defines..."
foreach j $VERILOG_GLOBAL_DEFINES {
  if { [catch { exec grep -x +define+$j vlog.opt } ] } {
    exec echo +define+$j >> vlog.opt
  }
}

echo "# NOTE: Processing include dirs..."
foreach j $inc_dir {
  if { [catch { exec grep -x +incdir+$j vlog.opt } ] } {
    exec echo +incdir+$j >> vlog.opt
  }
}


proc compile_src {} {
  global FILE_LIST
  global SEARCH_PATH

  global last_compile_time

  foreach file $FILE_LIST {
    foreach path $SEARCH_PATH {
      set file_path     [exec find $path -name $file]
      set file_path_num [exec echo $file_path | wc -l]
      set file_dir      [string trimright $file_path $file]
      
      # File found or not?
      if { [llength $file_path] > 0 } {

        # There is only one file name?
        if { $file_path_num == "1" } {

          # Watch dependency
          if {$last_compile_time < [file mtime $file_path]} {
            #puts "last_compile_time = $last_compile_time"
            #puts "file_time = [file mtime $file_path]"
            # Verilog or VHDL
            if [regexp {.vhdl?} $file] {
              #puts "vcom -work work $file_path"
              vcom -work work $file_path
            } else {
              #puts "vlog -sv -work work +incdir+$file_dir $file_path"
              vlog -sv -incr -work work +incdir+$file_dir $file_path
            }
          }
        } else {
          echo ########################################################
          echo !!!! Error: files with the same names !!!!
          echo file_path     = "$file_path"
          echo file_dir      = "$file_dir"
          echo file_path_num = "$file_path_num"
          echo ########################################################
          quit
        }
      }
    }
  }
  set last_compile_time [clock seconds]; puts "" 
}

proc all {} {
  global last_compile_time
  set last_compile_time 0; puts ""
  compile_src
}

proc nwf {} { 
  quit -sim
  compile_src
  vlog -work work -refresh
  echo "# NOTE: Starting simulation..."
  vsim -novopt +UVM_TESTNAME=my_test tb_main
  run -all
}

proc awf {} { 
  quit -sim
  compile_src
  vlog -work work -refresh 
  echo "# NOTE: Starting simulation..."
  vsim -novopt +UVM_TESTNAME=my_test tb_main
  add wave -r -hex sim:/tb_main/*
  #delete wave *some_pattern*
  #add wave -hex sim:/tb_main/submodule/signal
  run -all
}

proc qs {} {
  quit -sim
}

proc q {} {
  quit
}

proc show_help {} {
  echo "show_help  - show this message"
  echo "all        - compile all"
  echo "nwf        - run test with no  waveforms"
  echo "awf        - run test with all waveforms"
  echo "qs         - quit from simulation"
  echo "q          - quit"
}

echo "# NOTE: Compiling design..."
do verilog-library-setup.tcl
compile_src
show_help

