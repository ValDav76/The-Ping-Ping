library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
    generic(
        G_WIDTH : integer := 16
    );
    port(
        clk : in std_logic;
        rst : in std_logic;

        lrck_in : in std_logic;
        lrck_out : out std_logic;

        sdata_in : in std_logic;
        sdata_out : out std_logic
    );
end top_level;

architecture rtl of top_level is
    signal m_axi_s_tvalid_i2s_slave : std_logic;
    signal m_axi_s_tready_i2s_slave : std_logic;
    signal m_axi_s_tdata_i2s_slave : std_logic_vector(G_WIDTH-1 downto 0);

    signal tdata_core : std_logic_vector(G_WIDTH-1 downto 0);
    signal tready_core : std_logic;
    signal tvalid_core : std_logic;
begin
    i2s_in : entity work.s_i2s_m_axis_s(rtl)
        port map(
            sck => clk,
            lrck => lrck_in,
            sdata => sdata_in,
            rst => rst,

            m_axi_s_tdata => m_axi_s_tdata_i2s_slave,
            m_axi_s_tvalid => m_axi_s_tvalid_i2s_slave,
            m_axi_s_tready => m_axi_s_tready_i2s_slave
        );
    
    core : entity work.disto_core(rtl)
        port map(
            s_axi_s_tdata  => m_axi_s_tdata_i2s_slave,
            s_axi_s_tvalid  => m_axi_s_tvalid_i2s_slave, 
            s_axi_s_tready => m_axi_s_tready_i2s_slave,

            m_axi_s_tdata => tdata_core, 
            m_axi_s_tvalid => tvalid_core,
            m_axi_s_tready => tready_core,

            clk => clk,
            rst => rst
        );
    
    i2s_out : entity work.i2s_slave_axis(rtl)
        port map(
            clk => clk,
            rst => rst,

            s_axi_s_tdata => tdata_core,
            s_axi_s_tvalid => tvalid_core,
            s_axi_s_tready => tready_core,

            lrck_out => lrck_out,
            sdata => sdata_out
        );
    
end rtl;

