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
use IEEE.numeric_std.ALL; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity REG is
    Port ( AddrA : in STD_LOGIC_VECTOR (3 downto 0); -- 
           AddrB : in STD_LOGIC_VECTOR (3 downto 0);
           AddrW : in STD_LOGIC_VECTOR (3 downto 0);
           W : in STD_LOGIC; -- 1 if writing 
           DATA : in STD_LOGIC_VECTOR (7 downto 0);
           RST : in STD_LOGIC;
           CLK : in STD_LOGIC;
           QA : out STD_LOGIC_VECTOR (7 downto 0);
           QB : out STD_LOGIC_VECTOR (7 downto 0));
end REG;

architecture Behavioral of REG is
    type reg_bank is array (0 to 15) of STD_LOGIC_VECTOR (7 downto 0); -- 16 registers of 8 bits each;
    signal reg: reg_bank;
begin
    process
        begin
        wait until CLK'event and CLK = '1';
        if (RST='1') then 
            reg <= (others => x"00");
        else
            if (W='1') then
                reg(to_integer(unsigned(AddrW))) <= DATA;
            end if;
        end if;
    end process;
    QA <= reg(to_integer(unsigned(AddrA)));
    QB <= reg(to_integer(unsigned(AddrB)));

end Behavioral;

