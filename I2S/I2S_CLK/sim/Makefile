
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

VHDL_LIB_ORDER = I2S_LIB

VHDL_SOURCES_I2S_LIB = \
    $(PWD)/../rtl/i2s_clk.vhd

# ============================================================
# Cocotb
# ============================================================

TOPLEVEL = i2s_clk
TOPLEVEL_LIBRARY = I2S_LIB
MODULE = i2s_clk_tb

# ============================================================
# Simulation
# ============================================================

SIM_ARGS += --wave=wave.ghw

include $(shell cocotb-config --makefiles)/Makefile.sim
