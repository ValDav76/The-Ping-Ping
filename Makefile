# Makefile

# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += \
  $(PWD)/I2S_master_AXI_S/rtl/S_I2S_M_AXI_S.vhd \
  $(PWD)/i2s_slave/rtl/i2s_slave_axis.vhd \
  $(PWD)/overdrive_core/rtl/disto_core.vhd \
  $(PWD)/top_level.vhd
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = top_level

# MODULE is the basename of the Python test file
MODULE = testbench

SIM_ARGS=--vcd=anyname.vcd

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim