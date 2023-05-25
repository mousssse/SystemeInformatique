----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.05.2023 09:03:27
-- Design Name: 
-- Module Name: ALU_Test - Behavioral
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

entity ALU_Test is
--  Port ( );
end ALU_Test;

architecture Behavioral of ALU_Test is
    component ALU_Test
    Port(
       A : in STD_LOGIC_VECTOR (7 downto 0);
       B : in STD_LOGIC_VECTOR (7 downto 0);
       Ctrl_Alu : in STD_LOGIC_VECTOR (2 downto 0);
       S : out STD_LOGIC_VECTOR (7 downto 0);
       N : out STD_LOGIC;
       O : out STD_LOGIC;
       Z : out STD_LOGIC;
       C : out STD_LOGIC);
   end component;
   
   --inputs
   signal A : STD_LOGIC_VECTOR (7 downto 0) :=(others => '0');
   signal B : STD_LOGIC_VECTOR (7 downto 0) :=(others => '0');
   signal Ctrl_Alu : STD_LOGIC_VECTOR (2 downto 0) :=(others => '0');
   signal clkTest : STD_LOGIC := '0';
   
   --outputs
   signal S : STD_LOGIC_VECTOR (7 downto 0);
   signal N : STD_LOGIC;
   signal O : STD_LOGIC;
   signal Z : STD_LOGIC;
   signal C : STD_LOGIC;
    
   signal ite : integer;
   
begin

testALU: ALU_Test PORT MAP (
          A => A,
          B => B,
          Ctrl_Alu => Ctrl_Alu,
          S => S,
          N => N,
          O => O,
          Z => Z,
          C => C
);

A <= x"10";
B <= x"01";
Ctrl_Alu <= x"000" after 0 ns, x"001" after 20 ns, x"010" after 40 ns;
    

end Behavioral;
