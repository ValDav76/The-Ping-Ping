import cocotb

from cocotb.clock import Clock
from cocotb.triggers import (
    RisingEdge,
    FallingEdge,
    Timer,
    with_timeout
)


@cocotb.test()
async def system_timer_tb(dut):

    # =================================================
    # Parameters
    # =================================================

    F_CLK_IN = 100_000_000
    T_CLK_IN_PS = int(1e12 // F_CLK_IN)

    # =================================================
    # Input clock
    # =================================================

    dut.rst.value = 1

    # Utilisation de T_CLK_IN_PS et unit="ps"
    cocotb.start_soon(
        Clock(
            dut.clk_100mhz,
            T_CLK_IN_PS,
            unit="ps"
        ).start()
    )

    # =================================================
    # Reset
    # =================================================

    await Timer(200, unit="ns")

    dut.rst.value = 0

    dut._log.info("Reset released")

    t1 = cocotb.utils.get_sim_time(unit="us")

    await Timer(100, unit="us")
    
    t2 = cocotb.utils.get_sim_time(unit="us")

    # Vérification timer us 

    dut._log.info(f"Valeur du compteur us : {int(dut.time_now_us.value)}")

    assert t2-t1 == int(dut.time_now_us.value), f"Valeur du compteur us : {int(dut.time_now_us.value)}"
