library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ping_ping_lib;
use ping_ping_lib.ping_ping_pkg.all; 

library I2C_LIB;
use I2C_LIB.I2C_pkg.all;

entity i2c_sequencer is 
    generic(
        G_PRESCALE_WIDTH    : integer := C_PRESCALE_WIDTH;
        G_WB_ADDR_WIDTH     : integer := C_WB_ADDR_WIDTH;
        G_WB_DATA_WIDTH     : integer := C_WB_DATA_WIDTH;
        G_PRESCALE_I2C_CORE : t_prescale := C_PRESCALE
    );
    port(
        clk : in std_logic; 
        rst : in std_logic; 

        -- interface WISHBONE Master

        wb_adr_o    : out std_logic_vector(G_WB_ADDR_WIDTH-1 downto 0);
        wb_dat_o    : out std_logic_vector(G_WB_DATA_WIDTH-1 downto 0); 
        wb_dat_i    : in std_logic_vector(G_WB_DATA_WIDTH-1 downto 0);
        wb_we_o     : out std_logic;
        wb_stb_o    : out std_logic;
        wb_cyc_o    : out std_logic;
        wb_ack_i    : in std_logic;
        wb_inta_i   : in std_logic;

        -- interface vers CS4272 init

        req      : in std_logic;
        rw       : in std_logic; -- 0 = READ | 1 = WRITE
        dev_addr : in std_logic_vector(6 downto 0);
        reg_addr : in std_logic_vector(7 downto 0);
        wr_data  : in std_logic_vector(7 downto 0);

        busy     : out std_logic;
        done     : out std_logic;
        rd_data  : out std_logic_vector(7 downto 0);
        err      : out std_logic
    );
end entity;

architecture rtl of i2c_sequencer is

    type t_state is ( 
        RESET,
        SET_CTRL_REG, 
        SET_PRERlo, 
        SET_PRERhi, 
        WAIT_ISR_INIT,
        CLEAN_ISR_INIT,
        WAITING,
        SET_TRS_REG, 
        SET_CMD_REG,
        WAIT_ISR, 
        CLEAN_ISR,
        READ_ACK, 
        WR_DONE,
        ERROR_ACK, 
        SET_NACK,
        RD_WAIT_ISR,
        RD_CLEAN_ISR,
        RD_RX_REG,
        RD_DONE,
        ERROR_STATE
    );

    signal state      : t_state; 
    signal next_state : t_state;

    signal rw_reg       : std_logic;
    signal dev_addr_reg : std_logic_vector(6 downto 0);
    signal reg_addr_reg : std_logic_vector(7 downto 0);
    signal wr_data_reg  : std_logic_vector(7 downto 0);

    signal cnt_cmd      : integer range 0 to 2;
begin

    p_state_reg : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= RESET;
            else 
                state <= next_state;
            end if; 
        end if;
    end process p_state_reg;

    p_next_state : process(all) 
    begin
        -- state en mode ressort
        next_state <= state;

        case state is   
            when RESET => 
                next_state <= SET_PRERlo;

            when SET_PRERlo => 
                if wb_ack_i = '1' then 
                    next_state <= SET_PRERhi;
                end if;

            when SET_PRERhi => 
                if wb_ack_i = '1' then 
                    next_state <= SET_CTRL_REG;
                end if;
            
            when SET_CTRL_REG => 
                if wb_ack_i = '1' then 
                    next_state <= WAIT_ISR_INIT;
                end if;
            
            when WAIT_ISR_INIT => 
                if wb_inta_i = '1' then
                    next_state <= CLEAN_ISR_INIT;
                end if;
            
            when CLEAN_ISR_INIT =>
                if wb_ack_i = '1' then
                    next_state <= WAITING;
                end if; 
            
            when WAITING => 
                if req = '1' then 
                    next_state <= SET_TRS_REG;
                end if;

            when SET_TRS_REG => 
                if wb_ack_i = '1' then 
                    next_state <= SET_CMD_REG;
                end if;

            when SET_CMD_REG => 
                if wb_ack_i = '1' then 
                    next_state <= WAIT_ISR;
                end if;

            when WAIT_ISR => 
                if wb_inta_i = '1' then 
                    next_state <= CLEAN_ISR;
                end if;

            when CLEAN_ISR => 
                if wb_ack_i = '1' then 
                    next_state <= READ_ACK;
                end if;

            when READ_ACK => 
                if wb_ack_i = '1' then 
                    if wb_dat_i(7) = '0' then
                        if cnt_cmd < 2 then
                            next_state <= SET_TRS_REG;
                        elsif cnt_cmd = 2 then
                            if rw_reg = '0' then
                                next_state <= SET_NACK;
                            else
                                next_state <= WR_DONE;
                            end if;
                        else
                            next_state <= ERROR_STATE;
                        end if;
                    else
                        next_state <= ERROR_ACK;
                    end if;
                end if;

            when WR_DONE =>
                next_state <= WAITING;
            
            when ERROR_ACK =>
                next_state <= WAITING;
            
            when SET_NACK => 
                if wb_ack_i = '1' then 
                    next_state <= RD_WAIT_ISR;
                end if;

            when RD_WAIT_ISR => 
                if wb_inta_i = '1' then
                    next_state <= RD_CLEAN_ISR;
                end if;

            when RD_CLEAN_ISR => 
                if wb_ack_i = '1' then
                    next_state <= RD_RX_REG;
                end if; 

            when RD_RX_REG => 
                if wb_ack_i = '1' then
                    next_state <= RD_DONE;
                end if;
            
            when RD_DONE =>
                next_state <= WAITING;
                
            when others => 
                null;
        end case;
    end process p_next_state;

    p_outputs : process(all)
    begin
        -- valeur ressort 
        wb_adr_o <= (others => '0');
        wb_dat_o <= (others => '0');
        wb_cyc_o <= '0';
        wb_stb_o <= '0';
        wb_we_o  <= '0';

        busy     <= '1';
        done     <= '0';
        rd_data  <= (others => '0');
        err      <= '0';

        case state is 

        when RESET => 
            null;

        when SET_PRERlo => 
            wb_adr_o <= C_I2C_PRER_LO_ADDR;
            wb_dat_o <= G_PRESCALE_I2C_CORE(G_PRESCALE_WIDTH/2-1 downto 0);
            wb_cyc_o <= '1';
            wb_stb_o <= '1';
            wb_we_o  <= '1';

        when SET_PRERhi => 
            wb_adr_o <= C_I2C_PRER_HI_ADDR;
            wb_dat_o <= G_PRESCALE_I2C_CORE(G_PRESCALE_WIDTH-1 downto G_PRESCALE_WIDTH/2);
            wb_cyc_o <= '1';
            wb_stb_o <= '1';
            wb_we_o  <= '1';
        
        when SET_CTRL_REG => 
            wb_adr_o <= C_I2C_CTR_ADDR;
            wb_dat_o <= "11" & (5 downto 0 => '0');
            wb_cyc_o <= '1';
            wb_stb_o <= '1';
            wb_we_o  <= '1';

            
        when WAIT_ISR_INIT => 
            null;
        
        when CLEAN_ISR_INIT =>
            wb_adr_o <= C_I2C_CR_SR_ADDR;
            wb_cyc_o <= '1';
            wb_stb_o <= '1';
            wb_we_o  <= '1';    
            wb_dat_o <= (7 downto 1 => '0') & '1';
        
        when WAITING => 
            busy <= '0';            
        
        when SET_TRS_REG => 
            wb_adr_o <= C_I2C_TXR_RXR_ADDR;
            wb_cyc_o <= '1';
            wb_stb_o <= '1';
            wb_we_o  <= '1';

            case cnt_cmd is 
                when 0 => 
                    wb_dat_o <= dev_addr_reg & '0';
                
                when 1 => 
                    wb_dat_o <= reg_addr_reg;
                
                when 2 => 
                    if rw_reg = '0' then
                        wb_dat_o <= dev_addr_reg & '1';
                    else
                        wb_dat_o <= wr_data_reg;
                    end if;
                    
                when others => 
                    --next_state <= ERROR_STATE; 
                    null;
            end case;
        
        when SET_CMD_REG => 
            wb_adr_o <= C_I2C_CR_SR_ADDR;
            wb_cyc_o <= '1';
            wb_stb_o <= '1';
            wb_we_o  <= '1';            

            case cnt_cmd is 
                when 0 => 
                    wb_dat_o <= '1' & "00" & '1' & "0000";
                
                when 1 => 
                    wb_dat_o <= '0' & "00" & '1' & "0000";
                
                when 2 => 
                    if rw_reg = '0' then
                        wb_dat_o <= '1' & "00" & '1' & "0000";
                    else
                        wb_dat_o <= '0' & "10" & '1' & "0000";
                    end if;
                    
                when others => 
                    --next_state <= ERROR_STATE; 
                    null;
            end case;

        when WAIT_ISR => 
            null;

        when CLEAN_ISR => 
            wb_adr_o <= C_I2C_CR_SR_ADDR;
            wb_cyc_o <= '1';
            wb_stb_o <= '1';
            wb_we_o  <= '1';    
            wb_dat_o <= (7 downto 1 => '0') & '1';
        
        when READ_ACK =>
            wb_adr_o <= C_I2C_CR_SR_ADDR;
            wb_cyc_o <= '1';
            wb_stb_o <= '1';
            wb_we_o  <= '0'; -- Lecture

        when WR_DONE =>
            done <= '1';

        when ERROR_ACK => 
            null;
        
        when SET_NACK => 
            wb_adr_o <= C_I2C_CR_SR_ADDR;
            wb_cyc_o <= '1';
            wb_stb_o <= '1';
            wb_we_o  <= '1';  
            wb_dat_o <= '0' & '1' & '1' & '0' & '1' & "000";

        when RD_WAIT_ISR => 
            null;
            
        when RD_CLEAN_ISR => 
            wb_adr_o <= C_I2C_CR_SR_ADDR;
            wb_cyc_o <= '1';
            wb_stb_o <= '1';
            wb_we_o  <= '1';    
            wb_dat_o <= (7 downto 1 => '0') & '1';

        when RD_RX_REG => 
            wb_adr_o <= C_I2C_TXR_RXR_ADDR;
            wb_cyc_o <= '1';
            wb_stb_o <= '1';
            wb_we_o  <= '0';    

        when RD_DONE => 
            done <= '1'; 
            rd_data <= wb_dat_i;
        
        when others =>
            null;             
        end case;
    end process p_outputs;

    p_save_input : process(clk)
    begin
        if rising_edge(clk) then
            if req = '1' then 
                rw_reg       <= rw;
                dev_addr_reg <= dev_addr;
                reg_addr_reg <= reg_addr;
                wr_data_reg  <= wr_data;
            end if;
        end if;
    end process p_save_input;

    p_cnt_cmd : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                cnt_cmd <= 0;

            elsif state = READ_ACK and wb_ack_i = '1' then
                if wb_dat_o(7) = '0' then
                    if cnt_cmd < 2 then
                        cnt_cmd <= cnt_cmd + 1;
                    else
                        cnt_cmd <= 0;
                    end if;
                end if;

            elsif state = WAITING and req = '1' then
                cnt_cmd <= 0;
            end if;
        end if;
    end process;
end rtl;