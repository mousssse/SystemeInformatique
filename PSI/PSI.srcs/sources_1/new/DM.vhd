----------------------------------------------------------------------------------
-- Company: INSA Toulouse
-- Engineer: Sarah Mousset & Valentin Guittard
-- 
-- Create Date: 16.05.2023 09:48:23
-- Design Name: 
-- Module Name: DM - Behavioral
-- Project Name: PSI
-- Target Devices: FPGA Basys 3
-- Tool Versions: 
-- Description: This source gives the code corresponding to the design of a data memory.
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

entity DM is
    Port ( IN_DATA : in STD_LOGIC_VECTOR (7 downto 0);
           RW : in STD_LOGIC; -- 1 if write
           RST : in STD_LOGIC;
           CLK : in STD_LOGIC;
           OUT_DATA : out STD_LOGIC_VECTOR (7 downto 0);
           ADDR_DATA : in STD_LOGIC_VECTOR (7 downto 0));
end DM;

architecture Behavioral of DM is
    type data_bank is array (0 to 255) of STD_LOGIC_VECTOR (7 downto 0); -- address on 8 bits = 256 possibilities on 8 bits each;
    signal data: data_bank;
begin
    process
        begin
            wait until CLK'event and CLK='1';
            if (RST='1') then
                data <= (others =>x"00");
            elsif (RW='1') then
                data(to_integer(unsigned(ADDR_DATA))) <= IN_DATA;                 
            end if;
            OUT_DATA <= data(to_integer(unsigned(ADDR_DATA)));
    end process;
end Behavioral;