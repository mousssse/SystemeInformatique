----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.05.2023 09:52:32
-- Design Name: 
-- Module Name: ALU - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( A : in STD_LOGIC_VECTOR (7 downto 0);
           B : in STD_LOGIC_VECTOR (7 downto 0);
           Ctrl_Alu : in STD_LOGIC_VECTOR (2 downto 0);
           S : out STD_LOGIC_VECTOR (7 downto 0));
           -- N : out STD_LOGIC;
           -- O : out STD_LOGIC;
           -- Z : out STD_LOGIC;
           -- C : out STD_LOGIC;
end ALU;

architecture Behavioral of ALU is
    signal aux: STD_LOGIC_VECTOR (15 downto 0);
begin
aux <=
    (x"00"&A) + (x"00"&B) when Ctrl_Alu="000" else
    (x"00"&A) - (x"00"&B) when Ctrl_Alu="001" else
    A * B when Ctrl_Alu="010" else
    x"0000";
S <= aux(7 downto 0);
-- N <= '1' when aux(15)='1';
-- O <= '1' when aux(15 down to 8) !=x"00";
-- Z <= '1' when aux=x"0000";
-- C <= aux(8);

    
end Behavioral;