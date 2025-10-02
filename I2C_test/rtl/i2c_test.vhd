library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_test is
    port(
        -- whisbone master signals
        wb_clk_i : in std_logic;
        wb_rst_i : in std_logic := '0'; -- synchronous active high reset !
        arst_i : in std_logic := '0';
        wb_adr_o : out std_logic_vector(2 downto 0);
        wb_dat_i : in std_logic_vector(7 downto 0);
        wb_dat_o : out std_logic_vector(7 downto 0);
        wb_we_o : out std_logic;
        wb_stb_o : out std_logic;
        wb_cyc_o : out std_logic;
        wb_ack_i : in std_logic;
        wb_inta_o : in std_logic;
        send_test : in std_logic;

        debug : out natural
    );

end i2c_test;

architecture rtl of i2c_test is
    type state is (RESET, IDLE, SEND, INIT);
    signal fsm : state;
    constant slave_addr : std_logic_vector(6 downto 0) := "1100111";
    constant txr_addr : std_logic_vector(2 downto 0) := "011";
    type init_array is array (natural range <>) of std_logic_vector(7 downto 0);
    signal wb_stb : std_logic;

    constant init_data_list : init_array := (
        x"02",  -- PRER 
        x"C0"   -- CTR
    );

    constant init_addr_list : init_array :=(
        x"00", -- PRER 
        x"02"  -- CTR
    );

    type send_data is array (natural range <>) of std_logic_vector(7 downto 0);

    constant test_data : send_data := (
        slave_addr & '0', -- potentiel problème au niveau du bit d'écriture, à tester !
        X"90",
        X"C4",
        X"50"
    );

    constant test_addr : send_data := (
        X"03",
        X"04",
        X"03",
        X"04"
    );
    
    begin
    
    process(wb_clk_i, arst_i)
        variable i : natural range 0 to 15 := 0;
    begin
        if arst_i = '1' then
            fsm <= RESET;
        else
            if rising_edge(wb_clk_i) then
                case fsm is
                    when RESET =>
                        wb_adr_o <= (others => '0');
                        wb_dat_o <= (others => '0'); 
                        wb_cyc_o <= '0';
                        wb_stb <= '0';
                        wb_we_o <= '0';

                        fsm <= INIT;
                        i := 0;

                    when INIT =>

                        wb_we_o <= '1'; 
                        wb_cyc_o <= '1';

                        if i = 0 then 
                            wb_stb <= '1';
                        end if; 

                        if wb_stb = '1' then
                            wb_stb <= '0';
                            --wb_cyc_o <= '0';
                        end if;

                        if wb_ack_i = '1' then
                            i := i+1;
                            wb_stb <= '1';
                        end if;

                        if i = 2 then
                            fsm <= IDLE;
                            wb_adr_o <= (others => '0');
                            wb_dat_o <= (others => '0');
                            wb_we_o <= '0';
                            wb_cyc_o <= '0';
                            wb_stb <= '0';
                            i := 0;
                        else
                            wb_adr_o <= init_addr_list(i)(2 downto 0);
                            wb_dat_o <= init_data_list(i);
                        end if;

                    when IDLE =>
                        if send_test = '1' then
                            fsm <= SEND;
                        end if; 
                    
                    when SEND =>
                        wb_we_o <= '1';
                        wb_cyc_o <= '1';
                        
                        if i=0 then
                            wb_stb <= '1';
                        end if;

                        if wb_stb = '1' then
                            wb_stb <= '0';
                            --wb_cyc_o <= '0';
                        end if;

                        if wb_ack_i = '1' then
                            i := i+1;
                            wb_stb <= '1';
                        end if;
                        
                        if i = 4 then
                            fsm <= IDLE;
                            wb_adr_o <= (others => '0');
                            wb_dat_o <= (others => '0');
                            wb_we_o <= '0';
                            wb_cyc_o <= '0';
                            wb_stb <= '0';
                            i := 0;
                        else
                            wb_adr_o <= test_addr(i)(2 downto 0);
                            wb_dat_o <= test_data(i);
                        end if;
                        
                end case;
                if wb_rst_i = '1' then
                    fsm <= RESET;
                end if;
                debug <= i;
             end if;
        end if;
    end process;
    wb_stb_o <= wb_stb; 
end rtl;