----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.05.2023 09:50:13
-- Design Name: 
-- Module Name: testALU - Behavioral
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

entity testALU is
--  Port ( );
end testALU;

architecture Behavioral of testALU is

component ALU is
    Port ( A : in STD_LOGIC_VECTOR (7 downto 0);
           B : in STD_LOGIC_VECTOR (7 downto 0);
           Ctrl_Alu : in STD_LOGIC_VECTOR (1 downto 0);
           S : out STD_LOGIC_VECTOR (7 downto 0);
           N : out STD_LOGIC;
           O : out STD_LOGIC;
           Z : out STD_LOGIC;
           C : out STD_LOGIC);
end component;


signal A : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
signal B : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
signal Ctrl_Alu : STD_LOGIC_VECTOR (1 downto 0) := (others => '0'); 
signal S : STD_LOGIC_VECTOR (7 downto 0);
signal N : STD_LOGIC;
signal O : STD_LOGIC;
signal Z : STD_LOGIC;
signal C : STD_LOGIC;


begin

UUT : ALU port map ( A => A, B => B, Ctrl_Alu => Ctrl_Alu, S => S, N => N, O => O, Z => Z, C => C);

-- test for different inputs
inputTest : process
    begin
        -- Test 1 : A + B = 0 + 1 = 1 = S
        A <= x"00";
        B <= x"01";
        Ctrl_Alu <= "01";
        wait for 10 ns;
        -- Test 2 : A + B = 0 + 0 = 0 = S => Z = '1'
        A <= x"00";
        B <= x"00";
        Ctrl_Alu <= "01";
        wait for 10 ns;
        -- Test 3 : A - B = 2 - 1 = 1 = S
        A <= x"02";
        B <= x"01";
        Ctrl_Alu <= "11";
        wait for 10 ns;
        -- Test 4 : A - B = 2 - 4 = 2 = S => N = '1'
        A <= x"02";
        B <= x"04";
        Ctrl_Alu <= "11";
        wait for 10 ns;
        -- Test 5 : A * B = 2 * 4 = 8 = S
        A <= x"02";
        B <= x"04";
        Ctrl_Alu <= "10";
        wait for 10 ns;
        -- Test 6 : A * B = 255 * 10 = 2550 = 9F6 = S(x"F6") => O = '1'
        A <= x"FF";
        B <= x"0A";
        Ctrl_Alu <= "10";
        wait for 10 ns;
        -- Test 7 : A * B = 255 * 0 = 0 = S => Z = '1'
        A <= x"FF";
        B <= x"00";
        Ctrl_Alu <= "10";
        wait for 10 ns;
        -- Test 8 : A + B = 255 + 2 = 257 = x"0101" = S(x"01") => C = '1'
        A <= x"FF";
        B <= x"02";
        Ctrl_Alu <= "01";
        wait for 10 ns;
    end process;
end Behavioral;
