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
async def i2s_clk_tb(dut):

    # =================================================
    # Parameters
    # =================================================

    F_CLK_IN = 12_288_000
    F_LRCK_OUT = F_CLK_IN/4
    F_SCLK_OUT = F_CLK_IN/256

    # Calcul en picosecondes (entier) pour éviter les erreurs de flottants
    T_CLK_IN_PS = int(1e12 // F_CLK_IN)
    T_LRCK_OUT_NS = 1e9 / F_LRCK_OUT
    T_SCLK_OUT_NS = 1e9 / F_SCLK_OUT

    TOLERANCE = 0.02  # 2 %

    # =================================================
    # Input clock
    # =================================================

    dut.rst.value = 1

    # Utilisation de T_CLK_IN_PS et unit="ps"
    cocotb.start_soon(
        Clock(
            dut.MCLK,
            T_CLK_IN_PS,
            unit="ps"
        ).start()
    )

    # =================================================
    # Reset
    # =================================================

    await Timer(200, unit="ns")

    dut.rst.value = 0

    dut._log.info("DUT reset released")

    # =================================================
    # Wait for stable signal
    # Peut prendre du temps en fonction du nombre de SCLK attendu
    # =================================================

    try:
        await with_timeout(
            RisingEdge(dut.stable),
            500,
            "us"
        )

    except Exception:
        assert False, "SCLK non stable"

    dut._log.info("SCLK stable")

    # =================================================
    # Check fréquence LRCK
    # =================================================

    periods = []

    for _ in range(20):

        await RisingEdge(dut.LRCK)
        t1 = cocotb.utils.get_sim_time(unit="ns")

        await RisingEdge(dut.LRCK)
        t2 = cocotb.utils.get_sim_time(unit="ns")

        period = t2 - t1

        periods.append(period)

    avg_period = sum(periods) / len(periods)

    measured_freq = 1e9 / avg_period

    dut._log.info(
        f"LRCK fréquence mesuré: "
        f"{measured_freq / 1e6:.3f} MHz"
    )

    # Correction de la casse de F_LRCK_OUT dans le log
    dut._log.info(
        f"Expected LRCK frequency: "
        f"{F_LRCK_OUT / 1e6:.3f} MHz"
    )

    assert abs(measured_freq - F_LRCK_OUT) / F_LRCK_OUT < TOLERANCE, \
        "Fréquence LRCK incorrect"

    # =================================================
    # Check fréquence SCLK
    # =================================================

    periods = []

    for _ in range(20):

        await RisingEdge(dut.SCLK)
        t1 = cocotb.utils.get_sim_time(unit="ns")

        await RisingEdge(dut.SCLK)
        t2 = cocotb.utils.get_sim_time(unit="ns")

        period = t2 - t1

        periods.append(period)

    avg_period = sum(periods) / len(periods)

    measured_freq = 1e9 / avg_period

    dut._log.info(
        f"SCLK fréquence mesuré: "
        f"{measured_freq / 1e6:.3f} MHz"
    )

    dut._log.info(
        f"Expected SCLK frequency: "
        f"{F_SCLK_OUT / 1e6:.3f} MHz"
    )

    assert abs(measured_freq - F_SCLK_OUT) / F_SCLK_OUT < TOLERANCE, \
        "Fréquence SCLK incorrect"

    dut._log.info("I2S clk test passed")
