## 

TB_MAIN = tb_main.sv

# ( 1 - use DPI from UVM sources, 0 - use ModelSim built-in DPI )
USE_SIDE_DPI=0

#---------------------------------------------------------------
# Define Variables
#---------------------------------------------------------------

LIBDIR  = $(UVM_HOME)/lib
GCC     = gcc
TEST    = /usr/bin/test
BITS    ?= 32
LIBNAME = uvm_dpi
DPI_SRC = $(UVM_HOME)/src/dpi/uvm_dpi.cc


GCCCMD =  $(GCC) \
        -m$(BITS) \
        -fPIC \
        -DQUESTA \
        -g \
        -W \
        -shared \
        -x c \
        -I$(MTI_HOME)/include \
        $(DPI_SRC) \
        -o $(LIBDIR)/$(LIBNAME).so

VLIB =  vlib work

VLOG =  vlog \
        -timescale "1ns/1ns" \
        $(DPILIB_VLOG_OPT) \
        $(VLOG_OPT) \
        $(OPT_C) \
        -mfcu \
        -suppress 2181 \
        +acc=rmb \
        -writetoplevels questa.tops \
        +incdir+$(UVM_HOME)/src \
        $(UVM_HOME)/src/uvm.sv


VSIM =  vsim \
        $(DPILIB_VSIM_OPT) \
        $(VSIM_OPT) \
        $(OPT_R) \
        -c \
        -do "run -all; q" \
        -l questa.log \
        -f questa.tops

N_ERRS = 0
N_FATALS = 0

CHECK = \
	@$(TEST) \( `grep -c 'UVM_ERROR : $(N_ERRS)'   questa.log` -eq 1 \) -a \
      		 \( `grep -c 'UVM_FATAL : $(N_FATALS)' questa.log` -eq 1 \)

#---------------------------------------------------------------
# If USE_SIDE_DPI is set, enables compilation and loading of DPI
# libraries. Enabling DPI adds +acc on command line, which
# may adversely affect simulator performance.
#---------------------------------------------------------------

ifeq ($(USE_SIDE_DPI),1)
  DPILIB_VLOG_OPT = 
  DPILIB_VSIM_OPT = -sv_lib $(LIBDIR)/uvm_dpi 
  DPILIB_TARGET = dpi_lib$(BITS)
else
  DPILIB_VLOG_OPT =
  DPILIB_VSIM_OPT = 
  DPILIB_TARGET =
endif
  

#---------------------------------------------------------------
# Define Targets
#
# vlog and vsim targets defined in individual examples
#---------------------------------------------------------------

help: 
	@echo "Usage:  make -f Makefile [target(s)]"
	@echo ""
	@echo "Typical: make -f Makefile all"
	@echo ""
	@echo "where target is any of"
	@echo ""
	@echo "  dpi_lib     - compile DPI lib (use BITS=XX, def=32)"
	@echo "  dpi_lib32   - compile DPI lib for 32-bit Linux (BITS=32)"
	@echo "  dpi_lib64   - compile DPI lib for 64-bit Linux (BITS=64)"
	@echo ""
	@echo "  clean       - removes all derived files"
	@echo "  vlib        - creates work library"
	@echo "  prepare     - invokes clean, vlib, and dpi_lib targets"
	@echo ""
	@echo "When this makefile is included by a Makefile from an example"
	@echo "sub-directory, additional targets should be available:"
	@echo ""
	@echo "  all       - invokes targets prepare, vlog, and vsim"
	@echo "  vlog      - invokes the vlog compiler"
	@echo "  vsim      - invokes the vsim simulator"
	@echo ""
	@echo "Variables: specify any of the following on the make command line"
	@echo ""
	@echo "  UVM_HOME  - root directory of the UVM library (default:..)"
	@echo "  UVM_VERBOSITY - verbosity level for vsim (default:UVM_MEDIUM)"
	@echo "  BITS      - the bus architecture: 32 or 64 (default:32)"
	@echo "  LIBNAME   - the root name of the dpi library (default:uvm_dpi)"
	@echo "  LIBDIR    - the location to put the dpi lib (default:UVM_HOME/lib)"
	@echo ""

prepare: clean vlib $(DPILIB_TARGET)


dpi_lib:
	mkdir -p $(LIBDIR)
	$(GCCCMD)

dpi_lib32:
	make -f Makefile BITS=32 dpi_lib

dpi_lib64:
	make -f Makefile BITS=64 dpi_lib

vlib: $(DPILIB_TARGET)
	vlib work

clean:
	rm -rf *~ work vsim.wlf* *.log questa.tops transcript *.vstf

###

all: run

comp: vlib
	$(VLOG) +incdir+. $(TB_MAIN) 

run: comp
	$(VSIM)
	$(CHECK)
