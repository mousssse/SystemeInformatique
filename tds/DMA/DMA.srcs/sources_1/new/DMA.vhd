----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.03.2023 16:01:44
-- Design Name: 
-- Module Name: DMA - Behavioral
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

entity DMA is
    Port ( CS : in STD_LOGIC;
           RS1 : in STD_LOGIC;
           RS2 : in STD_LOGIC;
           BG : in STD_LOGIC;
           RST : in STD_LOGIC;
           CLK : in STD_LOGIC;
           RD : out STD_LOGIC;
           WR : out STD_LOGIC;
           BR : out STD_LOGIC);
end DMA;

architecture Behavioral of DMA is
    signal addr: STD_LOGIC_VECTOR(15 downto 0);
    signal ctrl: STD_LOGIC_VECTOR(2 downto 0); --valeurs : ??1 si transform; ?1? pour read write; 1?? configuré mais attende du bus
    signal cpt: STD_LOGIC_VECTOR(15 downto 0);
    
begin
    
    process
    begin
        wait until CLK'event and CLK = '1';
        if (ctrl(0) = '1') then
            if (cpt = x"0000") then
                ctrl <= "000";
                br <= '0';
            else 
                WR <= ctrl(1);
                bus_addr <= addr;
                addr <= addr + 4;
                cpt <= cpt - 4;
            end if;
        else 
            -- jsp on l'a pas fait en td
        end if;
    end process;
    
end Behavioral;
