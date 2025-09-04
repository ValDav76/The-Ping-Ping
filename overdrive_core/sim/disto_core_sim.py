import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotbext.axi import AxiStreamSink, AxiStreamSource, AxiStreamFrame, AxiStreamBus
from cocotb.triggers import Timer
import matplotlib.pyplot as plt
import numpy as np


import logging


class disto_core:
    def __init__(self, dut):
        self.dut = dut
        self.clk = dut.clk
        self.rst = dut.rst
        
        self.axis_source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "s_axi_s"), dut.clk, dut.rst)
        self.axis_sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "m_axi_s"), dut.clk, dut.rst)

    async def start(self, period_ns=10):
        cocotb.start_soon(Clock(self.clk, period_ns, units="ns").start())
        # if self.rst is not None:
        #     self.rst.value = 0
        #     await Timer(100, units="ns")
        #     self.rst.value = 1
        #     await RisingEdge(self.clk)
def int_to_complement2(value, nb_bits):
    # Calculer la plage valide

    value = int(value)
    
    max_pos = (1 << (nb_bits - 1)) - 1      # 2^(n-1) - 1
    max_neg = -(1 << (nb_bits - 1))         # -2^(n-1)
    
    # Vérifier les limites
    if value > max_pos or value < max_neg:
        raise ValueError(f"Valeur {value} hors limites [{max_neg}, {max_pos}] pour {nb_bits} bits")
    
    # Si positif ou zéro, retourner directement
    if value >= 0:
        return value
    
    # Si négatif, calculer le complément à 2
    return (1 << nb_bits) + value

def complement2_to_int(value, nb_bits):
    """Convertit une valeur en complément à 2 sur nb_bits en entier signé."""
    # Masque pour nb_bits
    mask = (1 << nb_bits) - 1
    value &= mask  # on force dans la plage
    
    # Si le bit de signe est à 1 → négatif
    if value & (1 << (nb_bits - 1)):
        return value - (1 << nb_bits)
    else:
        return value

@cocotb.test(timeout_time=20, timeout_unit="ms")
async def uut(dut):
    ip = disto_core(dut)
    dut._log.setLevel(logging.CRITICAL) 

    await ip.start()

    await RisingEdge(ip.clk)
    await RisingEdge(ip.clk)
    await RisingEdge(ip.clk)
    await RisingEdge(ip.clk)
    await RisingEdge(ip.clk)
    tabs = []
    for i in range(-32768, 32768):
        data = int_to_complement2(i, 16)
        data_LSB = data & 0xFF
        data_MSB = (data & 0xFF00) >> 8
        await ip.axis_source.send([data_LSB, data_MSB])
        frame = await ip.axis_sink.recv()
        val_two_c = frame.tdata[1] << 8 | frame.tdata[0]
        val_int = complement2_to_int(val_two_c, 16)
        tabs.append(val_int) 
        #print(int(dut.debug.value))    

    await RisingEdge(ip.clk)
    await RisingEdge(ip.clk)

    fig, ax = plt.subplots()
    ax.plot(tabs)
    plt.savefig("plot.png", dpi=300)   # tu peux mettre .png, .jpg, .pdf...
    plt.close(fig)            # libérer la mémoire

