library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_clk is
    generic(
        G_LRCK_DIV     : integer := 4;
        G_SCLK_DIV     : integer := 256; 
        G_NB_SCLK_STABLE    : integer := 10 -- ATTENTION : 1/48MHz = ~21 us
    );
    port(
        MCLK : in std_logic;
        rst  : in std_logic;

        LRCK : out std_logic; 
        SCLK : out std_logic;

        stable : out std_logic -- Quand LRCK et SLCK sont stable, on peut commencer le reset du CS4272
    );
end i2s_clk;


architecture rtl of i2s_clk is 

    signal s_LRCK       : std_logic;
    signal s_SCLK       : std_logic; 
    signal LRCK_cnt     : integer range 0 to G_LRCK_DIV-1;
    signal SCLK_cnt     : integer range 0 to G_SCLK_DIV-1;

    signal NB_SCLK_cnt  : integer range 0 to G_NB_SCLK_STABLE-1;

begin

    LRCK <= s_LRCK;
    SCLK <= s_SCLK;

    p_LRCK_gen : process(MCLK)
    begin 
        if rising_edge(MCLK) then
            if rst = '1' then
                s_LRCK      <= '0';
                LRCK_cnt    <= 0;
            else
                if LRCK_cnt = G_LRCK_DIV/2-1 then
                    LRCK_cnt <= 0;
                    s_LRCK <= not(s_LRCK);
                else
                    LRCK_cnt <= LRCK_cnt + 1;
                end if;
            end if;
        end if;
    end process p_LRCK_gen;

    p_SLCK_gen : process(MCLK)
    begin 
        if rising_edge(MCLK) then
            if rst = '1' then
                s_SCLK      <= '0';
                SCLK_cnt    <= 0;
                stable      <= '0';
                NB_SCLK_cnt <= 0;
            else
                if SCLK_cnt = G_SCLK_DIV/2-1 then
                    SCLK_cnt <= 0;
                    s_SCLK   <= not(s_SCLK);

                    if NB_SCLK_cnt = G_NB_SCLK_STABLE-1 then
                        stable <= '1';
                    else
                        NB_SCLK_cnt <= NB_SCLK_cnt + 1;
                    end if;

                else
                    SCLK_cnt <= SCLK_cnt + 1;
                end if;
            end if;
        end if;
    end process p_SLCK_gen;

end rtl;

