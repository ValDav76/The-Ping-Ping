import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import Timer

import logging
import random

class top_level():
    def __init__(self, dut):
        self.dut = dut
        self.clk = dut.clk
        self.rst = dut.rst

        self.lrck = dut.lrck_in
        self.lrck_out = dut.lrck_out 

        self.sdata = dut.sdata_in
        self.sdata_out = dut.sdata_out

    async def start(self, period_ns=10):
        cocotb.start_soon(Clock(self.clk, period_ns, units="ns").start())
        if self.rst is not None:
            self.rst.value = 1
            await Timer(100, units="ns")
            self.rst.value = 0
            await RisingEdge(self.clk)



@cocotb.test(timeout_time=20, timeout_unit="ms")
async def uut(dut):
    ip = top_level(dut)
    dut._log.setLevel(logging.CRITICAL)

    await ip.start()
    sample = []
    ip.lrck.value = 0
    ip.sdata.value = random.randint(0, 1)
    await RisingEdge(ip.clk)

    for i in range(6):
        for j in range(16):
            sample.append(random.randint(0, 1))
            ip.sdata.value = sample[-1]
            await RisingEdge(ip.clk)

        ip.lrck.value = int(ip.lrck.value) ^ 1
        inject_val = 0
        for i in sample:
            inject_val = (inject_val << 1) | i
    