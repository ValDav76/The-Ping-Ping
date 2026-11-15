import cocotb

from cocotb.clock import Clock
from cocotb.triggers import (
    RisingEdge,
    FallingEdge,
    Timer,
    with_timeout
)


# ====================================================
# Test MMCM clock generation
# ====================================================

@cocotb.test()
async def top_clk_rst_tb(dut):

    # =================================================
    # Parameters
    # =================================================

    F_CLK_IN = 12_000_000
    F_CLK_OUT = 12_288_000
    F_CLK_OUT_100MHZ = 100_000_000

    # Calcul en picosecondes (entier) pour éviter les erreurs de flottants
    T_CLK_IN_PS = int(1e12 // F_CLK_IN)  # 12 MHz -> Exactly 83333 ps

    TOLERANCE = 0.02  # 2 %

    # =================================================
    # Input clock
    # =================================================

    dut.arst_n.value = 0

    # Utilisation de T_CLK_IN_PS et unit="ps"
    cocotb.start_soon(
        Clock(
            dut.clk_12m,
            T_CLK_IN_PS,
            unit="ps"
        ).start()
    )

    # =================================================
    # Reset
    # =================================================

    await Timer(200, unit="ns")

    dut.arst_n.value = 1

    dut._log.info("MMCM reset released")

    # =================================================
    # Wait for MMCM lock (12.288MHz)
    # =================================================

    try:
        await with_timeout(
            FallingEdge(dut.rst_100m),
            100,
            "us"
        )

    except Exception:
        assert False, "RST failed"

    dut._log.info("RST")

    dut._log.info("clk rst test passed")

