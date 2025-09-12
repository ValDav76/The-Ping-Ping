# Makefile

# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/../rtl/S_I2S_M_AXI_S.vhd
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = s_i2s_m_axis_s

# MODULE is the basename of the Python test file
MODULE = i2s_master_axi_s_sim

SIM_ARGS=--vcd=anyname.vcd

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim