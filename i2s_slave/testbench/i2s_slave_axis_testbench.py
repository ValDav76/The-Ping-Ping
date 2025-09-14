import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotbext.axi import AxiStreamSink, AxiStreamSource, AxiStreamFrame, AxiStreamBus
from cocotb.triggers import Timer

import logging
import random

class i2s_slave_axis():
    def __init__(self, dut):
        self.dut = dut
        self.clk = dut.clk
        self.rst = dut.rst
        self.lrck = dut.lrck_out
        self.sdata = dut.sdata
        self.axis_source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "s_axi_s"), dut.clk, dut.rst)

    async def start(self, period_ns=10):
        cocotb.start_soon(Clock(self.clk, period_ns, units="ns").start())
        if self.rst is not None:
            self.rst.value = 1
            await Timer(100, units="ns")
            self.rst.value = 0
            await RisingEdge(self.clk)

@cocotb.test(timeout_time=20, timeout_unit="ms")
async def uut(dut):
    ip = i2s_slave_axis(dut)
    dut._log.setLevel(logging.CRITICAL) 

    await ip.start()

    await RisingEdge(ip.clk)
    await RisingEdge(ip.clk)

    data = []

    for i in range(10):
        data.append(random.randint(0, (2**8)-1))

        data_LSB = data[i] & 0xFF
        data_MSB = (data[i] & 0xFF00) >> 8 
        await ip.axis_source.send([data_LSB, data_MSB])

        for i in range(16):
            await RisingEdge(ip.clk)