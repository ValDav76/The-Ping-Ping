
library ieee;
use ieee.std_logic_1164.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity mmcm_clock is
    port (
        clk_in       : in  std_logic;
        rst          : in  std_logic;

        clk_12m288   : out std_logic;
        clk_100m     : out std_logic;

        locked_12m288   : out std_logic;
        locked_100m     : out std_logic
    );
end entity mmcm_clock;

architecture rtl of mmcm_clock is

    signal clk_in_buf : std_logic;

    -- MMCM 1 : 12.288 MHz
    signal clk_fb_1     : std_logic;
    signal clk_fb_buf_1 : std_logic;
    signal clk_mmcm_1   : std_logic;

    -- MMCM 2 : 100 MHz
    signal clk_fb_2     : std_logic;
    signal clk_fb_buf_2 : std_logic;
    signal clk_mmcm_2   : std_logic;

begin

    ------------------------------------------------
    -- Input clock buffer
    ------------------------------------------------

    input_buf : IBUF
    port map (
        I => clk_in,
        O => clk_in_buf
    );

    ------------------------------------------------
    -- MMCM 1 : 12 MHz -> 12.288 MHz
    ------------------------------------------------

    mmcm_1 : MMCME2_BASE
    generic map (
        BANDWIDTH          => "OPTIMIZED",
        CLKIN1_PERIOD      => 83.333,

        CLKFBOUT_MULT_F    => 64.0,
        DIVCLK_DIVIDE      => 1,

        CLKOUT0_DIVIDE_F   => 62.5,
        CLKOUT0_DUTY_CYCLE => 0.5,
        CLKOUT0_PHASE      => 0.0
    )
    port map (
        CLKIN1    => clk_in_buf,

        CLKFBIN   => clk_fb_buf_1,
        CLKFBOUT  => clk_fb_1,

        CLKOUT0   => clk_mmcm_1,
        CLKOUT1   => open,
        CLKOUT2   => open,
        CLKOUT3   => open,
        CLKOUT4   => open,
        CLKOUT5   => open,
        CLKOUT6   => open,

        CLKOUT0B  => open,
        CLKOUT1B  => open,
        CLKOUT2B  => open,
        CLKOUT3B  => open,
        CLKFBOUTB => open,

        LOCKED    => locked_12m288,
        PWRDWN    => '0',
        RST       => rst
    );

    feedback_buf_1 : BUFG
    port map (
        I => clk_fb_1,
        O => clk_fb_buf_1
    );

    output_buf_1 : BUFG
    port map (
        I => clk_mmcm_1,
        O => clk_12m288
    );

    ------------------------------------------------
    -- MMCM 2 : 12 MHz -> 100 MHz
    ------------------------------------------------

    mmcm_2 : MMCME2_BASE
    generic map (
        BANDWIDTH          => "OPTIMIZED",
        CLKIN1_PERIOD      => 83.333,

        CLKFBOUT_MULT_F    => 62.5,
        DIVCLK_DIVIDE      => 1,

        CLKOUT0_DIVIDE_F   => 7.5,
        CLKOUT0_DUTY_CYCLE => 0.5,
        CLKOUT0_PHASE      => 0.0
    )
    port map (
        CLKIN1    => clk_in_buf,

        CLKFBIN   => clk_fb_buf_2,
        CLKFBOUT  => clk_fb_2,

        CLKOUT0   => clk_mmcm_2,
        CLKOUT1   => open,
        CLKOUT2   => open,
        CLKOUT3   => open,
        CLKOUT4   => open,
        CLKOUT5   => open,
        CLKOUT6   => open,

        CLKOUT0B  => open,
        CLKOUT1B  => open,
        CLKOUT2B  => open,
        CLKOUT3B  => open,
        CLKFBOUTB => open,

        LOCKED    => locked_100m,
        PWRDWN    => '0',
        RST       => rst
    );

    feedback_buf_2 : BUFG
    port map (
        I => clk_fb_2,
        O => clk_fb_buf_2
    );

    output_buf_2 : BUFG
    port map (
        I => clk_mmcm_2,
        O => clk_100m
    );

end architecture rtl;
