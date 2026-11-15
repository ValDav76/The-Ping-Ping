library ieee;
use ieee.std_logic_1164.all;

library CLK_LIB;

entity top_clk_rst is 
    generic(
        G_SIM : boolean := true
    );
    port(
        arst_n      : in std_logic; 
        clk_12m     : in std_logic;

        clk_100m    : out std_logic;
        rst_100m    : out std_logic;

        clk_12m288  : out std_logic; 
        rst_12m288  : out std_logic
    ); 
end top_clk_rst;

architecture rtl of top_clk_rst is 

    signal s_clk_100m   : std_logic;
    signal s_clk_12m288 : std_logic; 
    signal s_locked     : std_logic;
    signal s_mmcm_rst   : std_logic; 
begin 

    clk_100m    <= s_clk_100m;
    clk_12m288  <= s_clk_12m288;
    
    -- rtl_mmcm : if G_SIM = false generate
    --     i_mmcm_clk : entity CLK_LIB.mmcm_clock
    --     port map(
    --         clk_in      => clk_12m, 
    --         rst         => s_mmcm_rst,

    --         clk_12m288  => s_clk_12m288,
    --         clk_100m    => s_clk_100m,
    --         locked      => s_locked
    --     );
    -- end generate rtl_mmcm; 

    sim_mmcm : if G_SIM generate
        i_mmcm_clk : entity CLK_LIB.mmcm_clock_sim
        port map(
            clk_in      => clk_12m, 
            rst         => s_mmcm_rst,

            clk_12m288  => s_clk_12m288,
            clk_100m    => s_clk_100m,
            locked      => s_locked
        );
    end generate sim_mmcm; 
    
    i_rst_ctrl : entity CLK_LIB.reset_ctrl
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
