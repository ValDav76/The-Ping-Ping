library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ping_ping_lib;
use ping_ping_lib.ping_ping_pkg.all; 

entity top_cs4272 is
    generic(
        G_DATA_WIDTH : integer := C_DATA_WIDTH
    ); 
    port(
        clk : in std_logic;
        rst : in std_logic;

        time_now : in std_logic_vector(63 downto 0);

        -- interface axi stream
        m_axis_tdata    : in std_logic_vector(G_DATA_WIDTH-1 downto 0);
        m_axis_tready   : in std_logic;
        m_axis_tvalid   : out std_logic;
        m_axis_tlast    : out std_logic; 
        m_axis_tuser    : out std_logic; -- L ou R

        -- interface axi stream
        s_axis_tdata    : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
        s_axis_tready   : out std_logic;
        s_axis_tvalid   : in  std_logic;
        s_axis_tlast    : in  std_logic; 
        s_axis_tuser    : in  std_logic; -- L ou R
        

        -- interface I2C
        scl_i       : in std_logic;
        scl_o       : out std_logic;
        scl_oe      : out std_logic;

        sda_i       : in std_logic;
        sda_o       : out std_logic; 
        sda_oe      : out std_logic;

        -- I2S CS4272 interface
        CS_RSTN     : out std_logic;
        MCLK        : in std_logic; -- Master clock
        LRCK        : out std_logic; -- Left Right clock
        SCLK        : out std_logic; -- serial data clock
        CS_SDIN     : out std_logic; 
        CS_SDOUT    : in std_logic

    );
end entity; 


architecture rtl of top_cs4272 is 
begin
    
end architecture rtl;