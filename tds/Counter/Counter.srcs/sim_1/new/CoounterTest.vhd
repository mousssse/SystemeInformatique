----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.03.2023 17:15:50
-- Design Name: 
-- Module Name: CounterTest - Behavioral
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

entity CounterTest is
--  Port ( );
end CounterTest;

architecture Behavioral of CounterTest is

Component Counter8bits
Port ( CLK : in STD_LOGIC;
       RST : in STD_LOGIC;
       LOAD : in STD_LOGIC;
       SENS : in STD_LOGIC;
       EN : in STD_LOGIC;
       Din : in STD_LOGIC_VECTOR (7 downto 0);
       Dout : out STD_LOGIC_VECTOR (7 downto 0)
      );
end Component;

--input / output
signal clkTest : STD_LOGIC := '0';
signal rstTest : STD_LOGIC := '0';
signal loadTest : STD_LOGIC := '0';
signal sensTest : STD_LOGIC := '0';
signal enTest : STD_LOGIC := '0';
signal inTest : STD_LOGIC_VECTOR(7 downto 0) := x"00";
signal outTest : STD_LOGIC_VECTOR(7 downto 0);

constant Clock_period : time := 10 ns;

begin
    Label_uut: Counter8bits PORT MAP (
        CLK => clkTest,
        RST => rstTest,
        LOAD => loadTest,
        SENS => sensTest,
        EN => enTest,
        Din => inTest,
        Dout => outTest
    );
    
   Clock_process : process
   begin
       clkTest <= not(clkTest);
       wait for Clock_period/2;
   end process;

end Behavioral;
