----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.05.2023 19:18:38
-- Design Name: 
-- Module Name: testIM - Behavioral
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

entity testIM is
--  Port ( );
end testIM;

architecture Behavioral of testIM is

component IM is
    Port ( CLK : in STD_LOGIC; 
           ADDR_INS : in STD_LOGIC_VECTOR (7 downto 0);
           OUT_INS : out STD_LOGIC_VECTOR (31 downto 0));
end component;

signal CLK : STD_LOGIC := '0'; 
signal ADDR_INS : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
signal OUT_INS : STD_LOGIC_VECTOR (31 downto 0);

-- Clock period definitions
-- Si 100 MHz
constant Clock_period : time := 10 ns;

begin

UUT : IM port map (CLK => CLK, ADDR_INS => ADDR_INS, OUT_INS => OUT_INS);

-- Clock process
Clock_process : process
    begin
        CLK <= not(CLK);
        wait for Clock_period/2;
end process;

process
    begin
        ADDR_INS <= x"00";
        wait for 10 ns;
        ADDR_INS <= x"01";
        wait for 10 ns;
        ADDR_INS <= x"02";
        wait for 10 ns;        
        ADDR_INS <= x"03";
        wait for 10 ns;  
        ADDR_INS <= x"04";
        wait for 10 ns;  
        ADDR_INS <= x"05";
        wait for 10 ns;  
end process;

end Behavioral;
