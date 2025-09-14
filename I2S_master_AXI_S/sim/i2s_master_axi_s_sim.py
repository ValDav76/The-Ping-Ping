import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotbext.axi import AxiStreamSink, AxiStreamSource, AxiStreamFrame, AxiStreamBus
from cocotb.triggers import Timer
import random

import logging

class i2s_axis:
    def __init__(self, dut):
        self.dut = dut
        self.clk = dut.sck
        self.rst  = dut.rst
        self.lrck = dut.lrck
        self.sdata = dut.sdata 

        self.axis_sink = AxiStreamSink(AxiStreamBus.from_prefix(self.dut, "m_axi_s"), self.clk, self.rst)
    async def start(self, period_ns=10):
        cocotb.start_soon(Clock(self.clk, period_ns, units="ns").start())
        cocotb.start_soon(self.gen_lrck())

    async def gen_lrck(self):
        div = 0
        while True:
            await RisingEdge(self.lrck)
            if div == 15:
                self.lrck.value = ~self.lrck.value  # toggle
                div = 0
            else:
                div += 1

@cocotb.test(timeout_time=2, timeout_unit="ms")
async def uut(dut):
    ip = i2s_axis(dut)
    dut._log.setLevel(logging.CRITICAL) 
    await ip.start()

    await RisingEdge(ip.clk)
    ip.rst.value = 1
    await RisingEdge(ip.clk)
    ip.rst.value = 0
    await RisingEdge(ip.clk)
    await RisingEdge(ip.clk)
    await RisingEdge(ip.clk)

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
        #print(len(sample))
        inject_val = 0
        for i in sample:
            inject_val = (inject_val << 1) | i
        
        sample = []
        
        frame = await ip.axis_sink.recv()

        print(frame.tdata[1]) 
        print(frame.tdata[0])

        val = (frame.tdata[1] << 8) | frame.tdata[0]
        print(val)
    
        assert bin(val) == bin(inject_val), 'error'
    
        