-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): xkrato61
--
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------
entity UART_FSM is
port(
   CLK      : in std_logic;
   RST      : in std_logic;
   DIN      : in std_logic;
   CNT      : in std_logic_vector(4 downto 0);
   CNT2     : in std_logic_vector(3 downto 0);
   RX_EN    : out std_logic;
   CNT_EN   : out std_logic;
   DT_VLD   : out std_logic
   );
end entity UART_FSM;

-------------------------------------------------
architecture behavioral of UART_FSM is
  type STATE_TYPE is (WAIT_START, WAIT_FIRST, RECEIVE_DATA, WAIT_STOP, DATA_VALID);
  signal states : STATE_TYPE := WAIT_START;
begin
  DT_VLD <= '1' when states = DATA_VALID else '0';
process (CLK) begin
    if rising_edge(CLK) then
        
        if RST = '1' then
          states <= WAIT_START;
          RX_EN    <= '0';
          CNT_EN   <= '0';

        else
          case states is
            when WAIT_START  => if DIN = '0' then
                                  states   <= WAIT_FIRST;
                                  RX_EN    <= '0';
                                  CNT_EN   <= '1';
                                end if; 
            
            when WAIT_FIRST  => if CNT = "10110" then
                                  states   <= RECEIVE_DATA;
                                  RX_EN    <= '1';
                                  CNT_EN   <= '0';                  
                                end if;
            
            when RECEIVE_DATA => if CNT2 = "1000" then
                                  states   <= WAIT_STOP;
                                  RX_EN    <= '1';
                                  CNT_EN   <= '1';
                                end if;
            
            when WAIT_STOP => if DIN = '1' then
                                states   <= DATA_VALID;
                                RX_EN    <= '0';
                                CNT_EN   <= '0';          
                              end if;
                          
            when DATA_VALID =>  states <= WAIT_START;
                                
            when others => null;
              
          end case;
        end if;
    end if;
  end process;
end behavioral;
