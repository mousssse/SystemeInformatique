----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.05.2023 15:28:08
-- Design Name: 
-- Module Name: testDM - Behavioral
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

entity testDM is
end testDM;

architecture Behavioral of testDM is

component DM is
    Port ( IN_DATA : in STD_LOGIC_VECTOR (7 downto 0);
           RW : in STD_LOGIC; -- 1 if write
           RST : in STD_LOGIC; -- 1 if reset
           CLK : in STD_LOGIC;
           OUT_DATA : out STD_LOGIC_VECTOR (7 downto 0);
           ADDR_DATA : in STD_LOGIC_VECTOR (7 downto 0));
end component;

signal IN_DATA : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
signal RW : STD_LOGIC := '0'; -- 1 if write
signal RST : STD_LOGIC := '0'; -- 1 if reset
signal CLK : STD_LOGIC := '0';
signal OUT_DATA : STD_LOGIC_VECTOR (7 downto 0);
signal ADDR_DATA : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');

-- Clock period definitions
-- Si 100 MHz
constant Clock_period : time := 10 ns;

begin

UUT : DM port map (IN_DATA => IN_DATA, RW => RW, RST => RST, CLK => CLK, OUT_DATA => OUT_DATA, ADDR_DATA => ADDR_DATA);

-- Clock process
Clock_process : process
    begin
        CLK <= not(CLK);
        wait for Clock_period/2;
end process;

-- test for different inputs
inputTest : process
    begin
        -- Test 0 : Reset all addresses to x"00";
        RST <= '1';
        wait for 10 ns;
        RST <= '0';
        
        -- Test 1 : Read any address, here @ 0 (x"00"), OUT_DATA = 0
        RW <= '0';
        ADDR_DATA <= x"00"; -- @ 0
        wait for 10 ns;
        
        -- Test 2 : Write 7(x"07") at @ 127(x"7F")
        RW <= '1';
        IN_DATA <= x"07";
        ADDR_DATA <= x"7F"; -- @ 127
        wait for 10 ns;
        
        -- Test 3 : Read at @ 127, OUT_DATA = x"07"
        RW <= '0';
        ADDR_DATA <= x"7F"; -- @ 127
        wait for 10 ns;
        
        -- Test 4 : idem but change IN_DATA (result should be unchanged, OUT_DATA = x"07")
        RW <= '0';
        ADDR_DATA <= x"7F"; -- @ 127
        IN_DATA <= x"70"; -- 112
        wait for 10 ns;
        
        -- Test 5 : reset and try to write, then read (should not write, so OUT_DATA = x"00")
        RST <= '1';
        RW <= '1';
        ADDR_DATA <= x"0B"; -- @ 11
        wait for 10 ns; -- give time for propagation
        RST <= '0';
        RW <= '0';
        wait for 10 ns;
end process;


end Behavioral;
