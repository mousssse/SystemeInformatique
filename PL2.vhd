----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.05.2023 11:13:26
-- Design Name: 
-- Module Name: PL2 - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PL2 is
    Port ( OP_IN : in STD_LOGIC_VECTOR (7 downto 0);
           A_IN : in STD_LOGIC_VECTOR (7 downto 0);
           B_IN : in STD_LOGIC_VECTOR (7 downto 0);
           OP_OUT : out STD_LOGIC_VECTOR (7 downto 0);
           A_OUT : out STD_LOGIC_VECTOR (7 downto 0);
           B_OUT : out STD_LOGIC_VECTOR (7 downto 0);
           CLK : in STD_LOGIC); -- add reset ?
end PL2;

architecture Behavioral of PL2 is

begin
    process
        begin
        wait until CLK'event and CLK = '1';
            OP_OUT <= OP_IN;
            A_OUT <= A_IN;
            B_OUT <= B_IN;
    end process;

end Behavioral;
