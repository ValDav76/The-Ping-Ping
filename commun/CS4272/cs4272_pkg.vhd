library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package cs4272_pkg is

    constant C_MAIN_FREQ    : integer := 50_000_000;
    constant C_SCL_FREQ     : integer := 100_000;

    constant C_PRESCALE_WIDTH   : integer : 16;
    constant C_WB_ADDR_WIDTH    : integer := 3;
    constant C_WB_DATA_WIDTH    : integer := 8;
    
    subtype t_wb_addr is std_logic_vector(C_WB_ADDR_WIDTH-1 downto 0);

    -- OpenCores I2C register map
    constant C_I2C_PRER_LO_ADDR : t_wb_addr := "000";
    constant C_I2C_PRER_HI_ADDR : t_wb_addr := "001";
    constant C_I2C_CTR_ADDR     : t_wb_addr := "010";
    constant C_I2C_TXR_RXR_ADDR : t_wb_addr := "011";
    constant C_I2C_CR_SR_ADDR   : t_wb_addr := "100";

    function i2c_core_get_prescale return std_logic_vector(C_PRESCALE_WIDTH-1 downto 0);
end package cs4272_pkg;

package body cs4272_pkg is 

    function i2c_core_get_prescale return std_logic_vector(C_PRESCALE_WIDTH-1 downto 0) is
    begin
        return std_logic_vector(to_unsigned((C_MAIN_FREQ / (5 * C_SCL_FREQ)) - 1, 16));
    end function

    constant C_PRESCALE     : std_logic_vector(C_PRESCALE_WIDTH-1 downto 0) := i2c_core_get_prescale;

end package body cs4272_pkg;
