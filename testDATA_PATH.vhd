----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.05.2023 09:32:30
-- Design Name: 
-- Module Name: testDATA_PATH - Behavioral
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

entity testDATA_PATH is
end testDATA_PATH;

architecture Behavioral of testDATA_PATH is

component DATA_PATH is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC);
end component;

signal CLK : STD_LOGIC := '0';
signal RST : STD_LOGIC := '0';

-- Clock period definitions
-- Si 100 MHz
constant Clock_period : time := 10 ns;

begin
UUT : DATA_PATH port map (CLK => CLK, RST => RST);

Clock_process : process
    begin
        CLK <= not(CLK);
        wait for Clock_period/2;
end process;

end Behavioral;
