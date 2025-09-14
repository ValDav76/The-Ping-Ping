library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_slave_axis is
    generic(
        G_WIDTH : integer := 16
    );
    port(
        clk : in std_logic;
        rst : in std_logic;

        s_axi_s_tdata : in std_logic_vector(G_WIDTH-1 downto 0);
        s_axi_s_tvalid : in std_logic;
        s_axi_s_tready : out std_logic;

        lrck_out : out std_logic;
        sdata : out std_logic
    );
end i2s_slave_axis;

architecture rtl of i2s_slave_axis is
    signal tready : std_logic;
    signal reg_tdata : std_logic_vector(G_WIDTH-1 downto 0);
    signal writing : std_logic;
    signal lrck : std_logic;
begin
    process(clk, rst)
        variable compteur : integer range 0 to G_WIDTH-1 := 0;
    begin
        if rst = '1' then
            lrck <= '0';
            sdata <= '0';
            tready <= '1';
            writing <= '0';
            reg_tdata <= (others => '0');
        else
            if rising_edge(clk) then
                if s_axi_s_tvalid = '1' and tready = '1' then
                    reg_tdata <= s_axi_s_tdata;
                    writing <= '1';
                    lrck <= not lrck;
                end if;
                if writing = '1' and compteur < G_WIDTH-1 then
                    sdata <= reg_tdata(G_WIDTH-1);
                    reg_tdata <= reg_tdata(G_WIDTH-2 downto 0) & '0';
                    compteur := compteur+1;
                else
                    sdata <= reg_tdata(G_WIDTH-1);
                    compteur := 0;
                end if;
            end if;
        end if;
    end process;

    s_axi_s_tready <= tready;
    lrck_out <= lrck;
end rtl;
