
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

VHDL_LIB_ORDER = clk_lib

VHDL_SOURCES_clk_lib = \
    $(PWD)/../rtl/mmcm_clock.vhd

# ============================================================
# Cocotb
# ============================================================

TOPLEVEL = mmcm_clock
TOPLEVEL_LIBRARY = clk_lib
MODULE = mmcm_clock_tb

# ============================================================
# Simulation
# ============================================================

SIM_ARGS += --wave=wave.ghw

include $(shell cocotb-config --makefiles)/Makefile.sim
