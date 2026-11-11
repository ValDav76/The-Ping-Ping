
# ============================================================
# Simulation configuration
# ============================================================

SIM ?= ghdl
TOPLEVEL_LANG = vhdl

# ============================================================
# GHDL configuration
# ============================================================

COMPILE_ARGS += --std=93
COMPILE_ARGS += -fsynopsys
COMPILE_ARGS += -frelaxed-rules
COMPILE_ARGS += -fexplicit

# Precompiled Xilinx libraries
UNISIMDIR = /home/val/.xilinx-vivado/unisim/v93

COMPILE_ARGS += -P$(UNISIMDIR)

# ============================================================
# Libraries
# ============================================================

VHDL_LIB_ORDER = SYSTEM_TIMER_LIB

VHDL_SOURCES_SYSTEM_TIMER_LIB = \
    $(PWD)/../rtl/system_timer.vhd

# ============================================================
# Cocotb
# ============================================================

TOPLEVEL = system_timer
TOPLEVEL_LIBRARY = SYSTEM_TIMER_LIB
MODULE = system_timer_tb

# ============================================================
# Simulation
# ============================================================

SIM_ARGS += --wave=wave.ghw

include $(shell cocotb-config --makefiles)/Makefile.sim
