library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ping_ping_lib;
use ping_ping_lib.ping_ping_pkg.all; 

library I2C_LIB;
use I2C_LIB.I2C_pkg.all;

entity top_i2c_seq is 
    generic(
        G_WB_ADDR_WIDTH : integer := C_WB_ADDR_WIDTH;
        G_WB_DATA_WIDTH : integer := C_WB_DATA_WIDTH
    );
    port(
        clk : in std_logic; 
        rst : in std_logic;

        req      : in std_logic;
        rw       : in std_logic; -- 0 = READ | 1 = WRITE
        dev_addr : in std_logic_vector(6 downto 0);
        reg_addr : in std_logic_vector(7 downto 0);
        wr_data  : in std_logic_vector(7 downto 0);

        busy     : out std_logic;
        done     : out std_logic;
        rd_data  : out std_logic_vector(7 downto 0);
        err      : out std_logic;

        -- i2c lines
        scl_pad_i     : in  std_logic;                    -- i2c clock line input
        scl_pad_o     : out std_logic;                    -- i2c clock line output
        scl_padoen_o  : out std_logic;                    -- i2c clock line output enable, active low
        sda_pad_i     : in  std_logic;                    -- i2c data line input
        sda_pad_o     : out std_logic;                    -- i2c data line output
        sda_padoen_o  : out std_logic
    );
end entity;

architecture rtl of top_i2c_seq is

    signal wb_adr    : std_logic_vector(G_WB_ADDR_WIDTH-1 downto 0);
    signal wb_dat_io : std_logic_vector(G_WB_DATA_WIDTH-1 downto 0); 
    signal wb_dat_oi : std_logic_vector(G_WB_DATA_WIDTH-1 downto 0); 
    signal wb_we     : std_logic;
    signal wb_stb    : std_logic;
    signal wb_cyc    : std_logic;
    signal wb_ack    : std_logic;
    signal wb_inta   : std_logic;

begin 

    i2c_core_i : entity I2C_LIB.i2c_master_top
    port map(
        -- wishbone signals
        wb_clk_i        => clk,
        wb_rst_i        => rst,
        arst_i          => '1',
        wb_adr_i        => wb_adr, 
        wb_dat_i        => wb_dat_io, 
        wb_dat_o        => wb_dat_oi, 
        wb_we_i         => wb_we,  
        wb_stb_i        => wb_stb, 
        wb_cyc_i        => wb_cyc, 
        wb_ack_o        => wb_ack, 
        wb_inta_o       => wb_inta, 

        -- i2c lines
        scl_pad_i       => scl_pad_i,
        scl_pad_o       => scl_pad_o,
        scl_padoen_o    => scl_padoen_o,
        sda_pad_i       => sda_pad_i,
        sda_pad_o       => sda_pad_o,
        sda_padoen_o    => sda_padoen_o
    );

    i2c_seq_i : entity I2C_LIB.i2c_sequencer
    port map(
        clk => clk,
        rst => rst,

        -- interface WISHBONE Master

        wb_adr_o    => wb_adr,
        wb_dat_o    => wb_dat_io, 
        wb_dat_i    => wb_dat_oi,
        wb_we_o     => wb_we,
        wb_stb_o    => wb_stb,
        wb_cyc_o    => wb_cyc,
        wb_ack_i    => wb_ack,
        wb_inta_i   => wb_inta,

        -- interface vers CS4272 init

        req         => req,
        rw          => rw, 
        dev_addr    => dev_addr, 
        reg_addr    => reg_addr, 
        wr_data     => wr_data, 

        busy        => busy,
        done        => done, 
        rd_data     => rd_data, 
        err         => err
    );

end rtl;