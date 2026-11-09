
import cocotb

from cocotb.clock import Clock
from cocotb.triggers import (
    RisingEdge,
    ClockCycles,
    with_timeout
)

from cocotbext.i2c import I2cMemory


@cocotb.test()
async def test_i2c_write(dut):

    # ================================================
    # Clock
    # ================================================

    cocotb.start_soon(
        Clock(dut.clk, 10, unit="ns").start()
    )

    # ================================================
    # I2C slave model
    # ================================================

    slave = I2cMemory(
        dut.sda_bus,
        dut.sda_slave_o,
        dut.scl_bus,
        dut.scl_slave_o,
        addr=0x10,
        size=256
    )

    # ================================================
    # Initialize inputs
    # ================================================

    dut.rst.value = 1

    dut.req.value = 0
    dut.rw.value = 1

    dut.dev_addr.value = 0x10
    dut.reg_addr.value = 0x02
    dut.wr_data.value = 0x03

    dut.sda_slave_o.value = 1
    dut.scl_slave_o.value = 1

    # ================================================
    # Reset
    # ================================================

    await ClockCycles(dut.clk, 5)

    dut.rst.value = 0

    await ClockCycles(dut.clk, 15)

    # ================================================
    # Test parameters
    # ================================================

    dev_addr = 0x10
    reg_addr = 0x02
    wr_data = 0x03

    dut.dev_addr.value = dev_addr
    dut.reg_addr.value = reg_addr
    dut.wr_data.value = wr_data

    # ================================================
    # Launch transaction
    # ================================================

    dut._log.info("Starting I2C write transaction")

    dut.req.value = 1

    await RisingEdge(dut.clk)

    dut.req.value = 0

    # ================================================
    # Wait for completion
    # ================================================

    await with_timeout(
        RisingEdge(dut.done),
        10,
        "ms"
    )
    
    await ClockCycles(dut.clk, 5)
    # ================================================
    # Check result
    # ================================================

    dut._log.info("I2C transaction completed")

    assert int(dut.err.value) == 0, \
        "I2C transaction returned an error"

    assert int(dut.busy.value) == 0, \
        "Sequencer is still busy after completion"

    received_data = slave.read_mem(reg_addr, 1)

    dut._log.info(
        f"Register 0x{reg_addr:02X} = {received_data.hex()}"
    )

    assert received_data == bytes([wr_data]), \
        f"Expected 0x{wr_data:02X}, got {received_data.hex()}"

    dut._log.info("I2C WRITE TEST PASSED")

    # ================================================
    # READ test
    # ================================================

    slave.write_mem(reg_addr, bytes([0xAB]))

    await RisingEdge(dut.clk) 

    dut.rw.value = 0
    dut.req.value = 1 
    
    dut._log.info("Debut test I2C lecture")

    await RisingEdge(dut.clk)

    dut.req.value = 0

    await with_timeout(
        RisingEdge(dut.done),
        10,
        "ms"
    )

    data_read = int(dut.rd_data.value)

    await ClockCycles(dut.clk, 2)

    # ================================================
    # Check result
    # ================================================

    dut._log.info("I2C transaction completed")

    assert int(dut.err.value) == 0, \
        "I2C transaction returned an error"

    assert int(dut.busy.value) == 0, \
        "Sequencer is still busy after completion"

    assert data_read == 0xAB, \
        f"Expected 0xAB, got 0x{data_read:02X}"

    dut._log.info("I2C READ TEST PASSED")