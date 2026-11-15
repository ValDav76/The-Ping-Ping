
library ieee;
use ieee.std_logic_1164.all;

entity reset_ctrl is
    port (
        -- External reset (active low)
        reset_n     : in  std_logic;

        -- MMCM clocks
        clk_100m    : in  std_logic;
        clk_12m288     : in  std_logic;
        mmcm_locked : in  std_logic;

        -- MMCM reset (active high)
        mmcm_rst    : out std_logic;

        -- Domain resets (active high)
        rst_100m    : out std_logic;
        rst_12m288  : out std_logic
    );
end entity;

architecture rtl of reset_ctrl is

    signal arst_global : std_logic;

    signal sync_100m : std_logic_vector(1 downto 0) := "11";
    signal sync_12m  : std_logic_vector(1 downto 0) := "11";

    attribute ASYNC_REG : string;
    attribute ASYNC_REG of sync_100m : signal is "TRUE";
    attribute ASYNC_REG of sync_12m  : signal is "TRUE";

begin

    -- MMCM reset
    mmcm_rst <= not reset_n;

    -- Global asynchronous reset
    arst_global <= (not reset_n) or (not mmcm_locked);

    -- 100 MHz reset synchronizer
    process(clk_100m, arst_global)
    begin
        if arst_global = '1' then
            sync_100m <= "11";

        elsif rising_edge(clk_100m) then
            sync_100m <= sync_100m(0) & '0';
        end if;
    end process;

    -- 12.288 MHz reset synchronizer
    process(clk_12m288, arst_global)
    begin
        if arst_global = '1' then
            sync_12m <= "11";

        elsif rising_edge(clk_12m288) then
            sync_12m <= sync_12m(0) & '0';
        end if;
    end process;

    rst_100m <= sync_100m(1);
    rst_12m288  <= sync_12m(1);

end architecture;
