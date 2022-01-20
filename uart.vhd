-- uart.vhd: UART controller - receiving part
-- Author(s): xkrato61
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------
entity UART_RX is
port(	
     CLK      :  in std_logic;
	   RST      :  in std_logic;
	   DIN      :  in std_logic;
	   DOUT     :  out std_logic_vector(7 downto 0);
	   DOUT_VLD :	 out std_logic
);
end UART_RX;  

-------------------------------------------------
architecture behavioral of UART_RX is
  signal cnt      : std_logic_vector(4 downto 0);
  signal cnt2     : std_logic_vector(3 downto 0);
  signal rx_en    : std_logic;
  signal cnt_en   : std_logic;
  signal dt_vld   : std_logic;
begin
  UART : entity work.UART_FSM(behavioral)
    port map (
        CLK 	    => CLK,
        RST 	    => rst,
        DIN 	    => DIN,
        CNT	     => cnt,
        CNT2    	=> cnt2,
        RX_EN    => rx_en,
        CNT_EN   => cnt_en,
        DT_VLD   => dt_vld
        
  );
  process (CLK) begin
    if CLK'event and CLK= '1' then
      
      if DT_VLD = '1' then
        DOUT_VLD <= '0';
      end if;  
        
      -- WAIT START
      if CNT_EN = '0' and RX_EN = '0' then
        if dt_vld = '1' then
          DOUT_VLD <= '1';
        else
          DOUT_VLD <= '0';
        end if;
        
        cnt  <= "00000";
        cnt2 <= "0000";
      end if;
      
      -- WAIT FIRST
      if CNT_EN = '1' and RX_EN = '0' then
          DOUT <= "00000000";
          cnt <= cnt + 1;
          cnt2 <= "0000";        
      end if;
      
      -- RECEIVE DATA
      if  CNT_EN = '0' and RX_EN = '1' then
          --if cnt2 = "1000" then
         --   DOUT_VLD <= '0';
         -- end if;          
          if cnt = "10111" then
            cnt <= "00001";
          else
            cnt <= cnt + 1; 
          end if;
          
        
        if cnt = "00000" or cnt = "10111" then
          case cnt2 is
           when "0000" => DOUT(0) <= DIN;
           when "0001" => DOUT(1) <= DIN;
           when "0010" => DOUT(2) <= DIN;
           when "0011" => DOUT(3) <= DIN;
           when "0100" => DOUT(4) <= DIN;
           when "0101" => DOUT(5) <= DIN;
           when "0110" => DOUT(6) <= DIN;
           when "0111" => DOUT(7) <= DIN;
           when others => null;
          end case;
          cnt2 <= cnt2 + 1;
       end if;
       
       if cnt = "01111" then
          cnt <= "00000";
       end if;
       
        
      end if;
     
      
   end if; 
  end process;
end behavioral;