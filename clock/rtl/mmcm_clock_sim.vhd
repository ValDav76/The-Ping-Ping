library ieee;
use ieee.std_logic_1164.all;

entity mmcm_clock_sim is
    port (
        clk_in       : in  std_logic;
        rst          : in  std_logic;

        clk_12m288   : out std_logic;
        clk_100m     : out std_logic;

        locked       : out std_logic
    );
end entity mmcm_clock_sim;

architecture sim of mmcm_clock_sim is 
begin 

    p_gen_locked : process
    begin 
        wait until rst = '1';
        locked <= '0';
        wait for 10 us;
        locked <= '1';
        wait; 
    end process; 

    p_gen_12m288 : process
    begin 
        clk_12m288 <= '0';
        wait for 81.38 ns; 
        clk_12m288 <= '1';
        wait for 81.38 ns;  
    end process; 

    p_gen_100m : process
    begin 
        clk_100m <= '0';
        wait for 10 ns; 
        clk_100m <= '1';
        wait for 10 ns;  
    end process; 

end sim; 