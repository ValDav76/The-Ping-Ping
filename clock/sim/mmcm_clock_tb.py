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
async def test_mmcm_clock(dut):

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

    dut.rst.value = 1

    # Utilisation de T_CLK_IN_PS et unit="ps"
    cocotb.start_soon(
        Clock(
            dut.clk_in,
            T_CLK_IN_PS,
            unit="ps"
        ).start()
    )

    # =================================================
    # Reset
    # =================================================

    await Timer(200, unit="ns")

    dut.rst.value = 0

    dut._log.info("MMCM reset released")

    # =================================================
    # Wait for MMCM lock (12.288MHz)
    # =================================================

    try:
        await with_timeout(
            RisingEdge(dut.locked_12m288),
            100,
            "us"
        )

    except Exception:
        assert False, "MMCM 0 failed to lock"

    dut._log.info("MMCM 0 locked")

    # =================================================
    # Check output clock frequency
    # =================================================

    periods = []

    for _ in range(20):

        await RisingEdge(dut.clk_12m288)
        t1 = cocotb.utils.get_sim_time(unit="ns")

        await RisingEdge(dut.clk_12m288)
        t2 = cocotb.utils.get_sim_time(unit="ns")

        period = t2 - t1

        periods.append(period)

    avg_period = sum(periods) / len(periods)

    measured_freq = 1e9 / avg_period

    dut._log.info(
        f"Measured output frequency MMCM 0 : "
        f"{measured_freq / 1e6:.3f} MHz"
    )

    # Correction de la casse de F_CLK_OUT dans le log
    dut._log.info(
        f"Expected output frequency MMCM 0 : "
        f"{F_CLK_OUT / 1e6:.3f} MHz"
    )

    assert abs(measured_freq - F_CLK_OUT) / F_CLK_OUT < TOLERANCE, \
        "Output clock MMCM 0 frequency is incorrect"



    # =================================================
    # Wait for MMCM lock (100MHz)
    # =================================================

    if not dut.locked_100m.value:
        try:
            await with_timeout(
                RisingEdge(dut.locked_100m),
                100,
                "us"
            )
        except Exception:
            
            assert False, "MMCM failed to lock"

    dut._log.info("MMCM 1 locked")

    # =================================================
    # Check output clock frequency
    # =================================================

    periods = []

    for _ in range(20):

        await RisingEdge(dut.clk_100m)
        t1 = cocotb.utils.get_sim_time(unit="ns")

        await RisingEdge(dut.clk_100m)
        t2 = cocotb.utils.get_sim_time(unit="ns")

        period = t2 - t1

        periods.append(period)

    avg_period = sum(periods) / len(periods)

    measured_freq = 1e9 / avg_period

    dut._log.info(
        f"Measured output frequency MMCM 0 : "
        f"{measured_freq / 1e6:.3f} MHz"
    )

    # Correction de la casse de F_CLK_OUT dans le log
    dut._log.info(
        f"Expected output frequency MMCM 0 : "
        f"{F_CLK_OUT_100MHZ / 1e6:.3f} MHz"
    )

    assert abs(measured_freq - F_CLK_OUT_100MHZ) / F_CLK_OUT_100MHZ < TOLERANCE, \
        "Output clock MMCM 0 frequency is incorrect"

    dut._log.info("MMCM 0 test passed")

