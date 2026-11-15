library ieee;
use ieee.std_logic_1164.all;

entity top_clk_rst is 
    port(
        arst_n      : in std_logic; 
        clk_12m     : in std_logic;

        clk_100m    : out std_logic;
        rst_100m    : out std_logic;

        clk_12m288  : out std_logic; 
        rst_12m288  : out std_logic
    ); 
end top_clk_rst;

entity rtl of top_clk_rst is 
begin 

    i_rst_ctrl : entity CLOCK_LIB.reset_ctrl
    port map(
        reset_n     => arst_n,
        clk_100m    => s_clk_100m,
        clk_12m288  => s_clk_12m288,
        mmcm_locked => s_locked, 
        mmcm_rst    => s_mmcm_rst,
        rst_100m    => rst_100m,
        rst_12m288  => rst_12m288
    );

end rtl;
