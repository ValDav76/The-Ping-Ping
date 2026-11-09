# Makefile

# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

# use VHDL_SOURCES for VHDL files
VHDL_SOURCES_ping_ping_lib += $(PWD)/../../../commun/ping_ping_pkg.vhd

VHDL_SOURCES_I2C_LIB += \
					$(PWD)/../I2C_pkg.vhd \
					$(PWD)/../i2c_core/rtl/i2c_master_bit_ctrl.vhd \
					$(PWD)/../i2c_core/rtl/i2c_master_byte_ctrl.vhd \
					$(PWD)/../i2c_core/rtl/i2c_master_top.vhd \
					$(PWD)/../i2c_seq/rtl/i2c_sequencer.vhd \
					$(PWD)/../rtl/top_i2c_seq.vhd


VHDL_SOURCES += \
    $(PWD)/wrapper_top_i2c_seq.vhd

VHDL_LIB_ORDER = ping_ping_lib I2C_LIB work


# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = tb_top_i2c_seq 

# MODULE is the basename of the Python test file
MODULE = i2c_seq_tb


# Arguments passés à la compilation et à l'élaboration (Crucial pour garder la hiérarchie)
COMPILE_ARGS += -O0

# Conserve vos arguments de simulation
SIM_ARGS += --wave=wave.ghw 

EXTRA_ARGS += --std=08
# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim