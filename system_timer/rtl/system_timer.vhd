library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity system_timer is
    generic(
        G_TIME_US_DIV   : integer := 100
    );
    port(
        clk_100MHz      : in  std_logic;
        rst             : in  std_logic;
        time_now_raw    : out unsigned(63 downto 0);
        time_now_us     : out unsigned(63 downto 0)
    );
end entity system_timer; 


architecture rtl of system_timer is 
    signal counter_raw  : unsigned(63 downto 0);
    signal counter_us   : unsigned(63 downto 0);
    signal cnt_div_us   : integer range 0 to G_TIME_US_DIV-1;
begin
    time_now_raw <= counter_raw;
    time_now_us  <= counter_us;

    p_time_raw : process(clk_100MHz)
    begin 
        if rising_edge(clk_100MHz) then
            if rst = '1' then
                counter_raw <= (others => '0');
            else 
                counter_raw <= counter_raw + 1;
            end if;
        end if;
    end process p_time_raw;

    p_time_us : process(clk_100MHz)
    begin
        if rising_edge(clk_100MHz) then
            if rst = '1' then
                counter_us <= (others => '0');
                cnt_div_us <= 0;
            else
                if cnt_div_us = G_TIME_US_DIV-1 then
                    counter_us <= counter_us + 1;
                    cnt_div_us <= 0;
                else
                    cnt_div_us <= cnt_div_us + 1;
                end if;
            end if;
        end if;
    end process p_time_us;
end architecture rtl;
