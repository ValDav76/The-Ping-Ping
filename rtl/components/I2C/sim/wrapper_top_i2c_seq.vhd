library ieee;
use ieee.std_logic_1164.all;

library I2C_LIB;
use I2C_LIB.I2C_pkg.all;

entity tb_top_i2c_seq is
    port (
        -- Clock / reset
        clk : in std_logic;
        rst : in std_logic;

        -- Sequencer interface
        req      : in std_logic;
        rw       : in std_logic;
        dev_addr : in std_logic_vector(6 downto 0);
        reg_addr : in std_logic_vector(7 downto 0);
        wr_data  : in std_logic_vector(7 downto 0);

        busy    : out std_logic;
        done    : out std_logic;
        rd_data : out std_logic_vector(7 downto 0);
        err     : out std_logic;

        -- I2C slave model interface
        sda_bus      : out std_logic;
        scl_bus      : out std_logic;
        sda_slave_o  : in std_logic;
        scl_slave_o  : in std_logic
    );
end entity;

architecture sim of tb_top_i2c_seq is

    signal sda_pad_i    : std_logic;
    signal scl_pad_i    : std_logic;

    signal sda_pad_o    : std_logic;
    signal scl_pad_o    : std_logic;

    signal sda_padoen_o : std_logic;
    signal scl_padoen_o : std_logic;

begin

    -- Open-drain bus resolution

    sda_pad_i <= '0' when
        (sda_padoen_o = '0' or sda_slave_o = '0')
        else '1';

    scl_pad_i <= '0' when
        (scl_padoen_o = '0' or scl_slave_o = '0')
        else '1';

    sda_bus <= sda_pad_i;
    scl_bus <= scl_pad_i;

    -- DUT

    dut : entity I2C_LIB.top_i2c_seq
    port map (
        clk => clk,
        rst => rst,

        req      => req,
        rw       => rw,
        dev_addr => dev_addr,
        reg_addr => reg_addr,
        wr_data  => wr_data,

        busy    => busy,
        done    => done,
        rd_data => rd_data,
        err     => err,

        scl_pad_i    => scl_pad_i,
        scl_pad_o    => scl_pad_o,
        scl_padoen_o => scl_padoen_o,

        sda_pad_i    => sda_pad_i,
        sda_pad_o    => sda_pad_o,
        sda_padoen_o => sda_padoen_o
    );

end architecture;