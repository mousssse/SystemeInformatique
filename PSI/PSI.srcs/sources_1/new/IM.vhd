----------------------------------------------------------------------------------
-- Company: INSA Toulouse
-- Engineer: Sarah Mousset & Valentin Guittard
-- 
-- Create Date: 16.05.2023 09:48:23
-- Design Name: 
-- Module Name: IM - Behavioral
-- Project Name: PSI
-- Target Devices: FPGA Basys 3
-- Tool Versions: 
-- Description: This source gives the code corresponding to the design of an instruction memory.
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

entity IM is
    Port ( CLK : in STD_LOGIC; 
           ADDR_INS : in STD_LOGIC_VECTOR (7 downto 0);
           OUT_INS : out STD_LOGIC_VECTOR (31 downto 0));
end IM;

architecture Behavioral of IM is
    type data_bank is array (0 to 255) of STD_LOGIC_VECTOR (7 downto 0); -- address on 8 bits = 256 possibilities on 8 bits each;
    signal data: data_bank;
begin
    process
        begin
            wait until CLK'event and CLK='1';
            OUT_INS <= data(to_integer(unsigned(ADDR_INS)));    
    end process;
end Behavioral;