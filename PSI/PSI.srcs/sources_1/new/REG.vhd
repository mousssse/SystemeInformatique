----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.05.2023 11:08:27
-- Design Name: 
-- Module Name: REG - Behavioral
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

entity REG is
    Port ( accessA : in STD_LOGIC_VECTOR (3 downto 0); -- 
           accessB : in STD_LOGIC_VECTOR (3 downto 0);
           accessW : in STD_LOGIC_VECTOR (3 downto 0);
           W : in STD_LOGIC; -- 1 if writing 
           DATA : in STD_LOGIC_VECTOR (7 downto 0);
           RST : in STD_LOGIC;
           CLK : in STD_LOGIC;
           QA : out STD_LOGIC_VECTOR (7 downto 0);
           QB : out STD_LOGIC_VECTOR (7 downto 0));
end REG;

architecture Behavioral of REG is

begin
    process
        begin
        wait until CLK'event and CLK = '1';
        if (RST='1') then 
            QA;
        else 
            -- QA <= accessA;
            -- QB <= accessB;
            if (W='1') then
            
            end if;
    end process;


end Behavioral;