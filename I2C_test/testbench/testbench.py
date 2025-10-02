import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotbext.wishbone.monitor import WishboneSlave
from cocotb.triggers import Timer

import random
import logging

class i2c_test:
    def __init__(self, dut):
        self.dut = dut
        self.clk = dut.wb_clk_i
        self.rst = dut.arst_i
        self.send_test = dut.send_test
        self.wb_slave = WishboneSlave(dut, "wb", self.clk,
                        width=8,   # size of data bus
                        signals_dict={"cyc":  "cyc_o",
                                    "stb":  "stb_o",
                                    "we":   "we_o",
                                    "adr":  "adr_o",
                                    "datwr":"dat_o",
                                    "datrd":"dat_i",
                                    "ack":  "ack_i" })
        
    async def start(self, period_ns=166.7):
        cocotb.start_soon(Clock(self.clk, period_ns, units="ns").start())
        if self.rst is not None:
            self.rst.value = 1
            await Timer(1000, units="ns")
            self.rst.value = 0
            await RisingEdge(self.clk)

@cocotb.test(timeout_time=20, timeout_unit="ms")
async def uut(dut):
    ip = i2c_test(dut)
    dut._log.setLevel(logging.INFO)

    await ip.start() 

    await RisingEdge(ip.clk)
    await RisingEdge(ip.clk) 

    for i in range(20):
        await RisingEdge(ip.clk)
    
    ip.send_test.value = 0

    for i in range(20):
        await RisingEdge(ip.clk)

    ip.send_test.value = 1

    for i in range(100):
        await RisingEdge(ip.clk)

    for transaction in ip.wb_slave._recvQ:
        ip.wb_slave.log.info(f"{[f'@{hex(v.adr)}r{hex(v.datrd)}w{hex(0 if v.datwr is None else v.datwr)}' for v in transaction]}")