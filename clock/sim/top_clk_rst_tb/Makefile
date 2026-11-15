
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
UNISIMDIR = /home/val/repos/Xilinx_lib/vhdl/xilinx-vivado/unisim/v08

COMPILE_ARGS += -P$(UNISIMDIR)

# ============================================================
# Libraries
# ============================================================

VHDL_LIB_ORDER = clk_lib

VHDL_SOURCES_clk_lib = \
    $(PWD)/../../rtl/mmcm_clock_sim.vhd \
    $(PWD)/../../rtl/reset_ctrl.vhd \
    $(PWD)/../../rtl/top_clk_rst.vhd

# ============================================================
# Cocotb
# ============================================================

TOPLEVEL = top_clk_rst
TOPLEVEL_LIBRARY = clk_lib
MODULE = top_clk_rst_tb

# ============================================================
# Simulation
# ============================================================

SIM_ARGS += --wave=sim.vcd

include $(shell cocotb-config --makefiles)/Makefile.sim 