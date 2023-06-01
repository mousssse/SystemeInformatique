----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.05.2023 12:04:15
-- Design Name: 
-- Module Name: testREG - Behavioral
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

entity testREG is
--  Port ( );
end testREG;

architecture Behavioral of testREG is

component REG is
    Port ( AddrA : in STD_LOGIC_VECTOR (3 downto 0); -- 
           AddrB : in STD_LOGIC_VECTOR (3 downto 0);
           AddrW : in STD_LOGIC_VECTOR (3 downto 0);
           W : in STD_LOGIC; -- 1 if writing 
           DATA : in STD_LOGIC_VECTOR (7 downto 0);
           RST : in STD_LOGIC;
           CLK : in STD_LOGIC;
           QA : out STD_LOGIC_VECTOR (7 downto 0);
           QB : out STD_LOGIC_VECTOR (7 downto 0));
end component;

signal AddrA : STD_LOGIC_VECTOR (3 downto 0) := (others => '0'); 
signal AddrB : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
signal AddrW : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
signal W : STD_LOGIC := '0'; -- 1 if writing 
signal DATA : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
signal RST : STD_LOGIC := '0'; -- 1 for RST
signal CLK : STD_LOGIC := '0';
signal QA : STD_LOGIC_VECTOR (7 downto 0);
signal QB : STD_LOGIC_VECTOR (7 downto 0);

-- Clock period definitions
-- Si 100 MHz
constant Clock_period : time := 10 ns;

begin

UUT : REG port map (AddrA => AddrA, AddrB => AddrB, AddrW => AddrW, W => W, DATA => DATA, RST => RST, CLK => CLK, QA => QA, QB => QB);
 
-- Clock process
Clock_process : process
    begin
        CLK <= not(CLK);
        wait for Clock_period/2;
end process;

-- test for different inputs
inputTest : process
    begin
        -- Test 0 : Reset register array
        RST <= '1';
        wait for 10 ns;
        RST <= '0';
        
        -- Test 1 : Read any register (after RST => should be QA=QB=x"00")
        AddrA <= x"0"; -- Register 0
        AddrB <= x"E"; --Register 14
        W <='0';
        wait for 10 ns;
    
        -- Test 2 : Write 10 in R0
        AddrW <= x"0";  -- Register 0
        W <= '1';
        DATA <= x"0A";
        wait for 10 ns;
    
        -- Test 3 : Read R0 and R5 and Write 1 in R16 (should be R0 = 10 = QA, R5 = 0 = QB, R16 = 1) 
        AddrA <= x"0"; -- Register 0
        AddrB <= x"5"; -- Register 5
        AddrW <= x"F";  -- Register 16
        W <= '1';
        DATA <= x"01";
        wait for 10 ns;
        
        -- Test 4 : Read and Write in the same register R7 (should be R7 = QA = 7)
        AddrA <= x"7"; -- Register 7
        AddrW <= x"7"; -- Register 7
        W <= '1';
        DATA <= x"07";
        wait for 10 ns;
        
        -- Test 5 : Give an AddrW with DATA but W = '0' (should not change R7 => QA = x"07")
        AddrA <= x"7"; -- Register 7
        AddrW <= x"7"; -- Register 7
        W <= '0';
        DATA <= x"FF";
        wait for 10 ns;
        
        -- Test 6 : RST and write and read (RST has prio, should not write and QA = QB = x"00")
        AddrA <= x"0"; -- Register 0
        AddrB <= x"C"; -- Register 12
        AddrW <= x"C"; -- Register 12
        W <= '1';
        RST <= '1';
        DATA <= x"F0"; -- 256
        wait for 10 ns;
        RST <= '0';
end process;

end Behavioral;
