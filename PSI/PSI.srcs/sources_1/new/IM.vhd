----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.05.2023 10:05:37
-- Design Name: 
-- Module Name: MB - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IM is
    Port ( CLK : in STD_LOGIC; 
           ADDR_INS : in STD_LOGIC_VECTOR (7 downto 0);
           OUT_INS : out STD_LOGIC_VECTOR (31 downto 0));
end IM;

architecture Behavioral of IM is
    type data_bank is array (0 to 255) of STD_LOGIC_VECTOR (7 downto 0); -- address on 8 bits = 256 possibilities on 8 bits each;
    signal data: data_bank;
begin
    process
        begin
            wait until CLK'event and CLK='1';
            OUT_INS <= data(to_integer(unsigned(ADDR_INS)));    
    end process;
end Behavioral;