library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity s_i2s_m_axis_s is
    generic(
        G_WITDH : integer := 16
    );
    port(
        sck : in std_logic;
        lrck : in std_logic;
        sdata : in std_logic;
        rst : in std_logic; 

        m_axi_s_tdata : out std_logic_vector(G_WITDH-1 downto 0);
        m_axi_s_tvalid : out std_logic; 
        m_axi_s_tready : in std_logic
    );

end entity;

architecture rtl of s_i2s_m_axis_s is
    type state is (RESET, RIGHT, LEFT, IDLE);
    signal FSM : state;
    signal tdata : std_logic_vector(G_WITDH-1 downto 0);
    signal tvalid : std_logic;
    signal data : std_logic_vector(G_WITDH-1 downto 0);
    signal lrck_store : std_logic;
begin 
    process(sck, rst)
    begin
        if rst='1' then
            FSM <= RESET;
        else
            if rising_edge(sck) then
                if m_axi_s_tready = '1' then
                    tvalid <= '1';
                end if;

                case FSM is
                    when RESET =>
                        tvalid <= '0';
                        tdata <= (others => '0');
                        lrck_store <= lrck;
                        data <= (others => '0');
                        FSM <= IDLE;
                    
                    when IDLE =>
                        lrck_store <= lrck;
                        if lrck /= lrck_store then
                            if lrck = '1' then 
                                FSM <= RIGHT;
                            else
                                FSM <= LEFT;
                            end if; 
                        end if;
                    
                    when LEFT =>
                        lrck_store <= lrck;

                        data <= data(data'high-1 downto 0) & sdata;
                        
                        if lrck_store /= lrck then
                            tdata <= data;
                            tvalid <= '1';
                            FSM <= RIGHT;
                        end if;
                    
                    when RIGHT =>
                        lrck_store <= lrck;

                        data <= data(data'high-1 downto 0) & sdata;
                        
                        if lrck_store /= lrck then
                            tdata <= data;
                            tvalid <= '1';
                            FSM <= LEFT; 
                        end if; 
                        
                        
                end case;
            end if; 
        end if; 
    end process;

    m_axi_s_tvalid <= tvalid;
    m_axi_s_tdata <= tdata;

end rtl;