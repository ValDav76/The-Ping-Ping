library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity system_timer is
    port(
        clk_100MHz  : in  std_logic;
        rst         : in  std_logic;
        time_now    : out unsigned(63 downto 0)
    );
end entity system_timer; 


architecture rtl of system_timer is 
    signal counter : unsigned(63 downto 0) := (others => '0');
begin
    time_now <= counter;

    process(clk_100MHz)
    begin 
        if rising_edge(clk_100MHz) then
            if rst = '1' then
                counter <= (others => '0');
            else 
                counter <= counter + 1;
            end if;
        end if;
    end process;
end architecture rtl;
