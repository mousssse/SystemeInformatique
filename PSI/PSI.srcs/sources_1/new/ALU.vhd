----------------------------------------------------------------------------------
-- Company: INSA Toulouse
-- Engineer: Sarah Mousset & Valentin Guittard
-- 
-- Create Date: 16.05.2023 09:48:23
-- Design Name: 
-- Module Name: ALU - Behavioral
-- Project Name: PSI
-- Target Devices: FPGA Basys 3
-- Tool Versions: 
-- Description: This source gives the code corresponding to the design of an arithmetics logic unit.
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

entity ALU is
    Port ( A : in STD_LOGIC_VECTOR (7 downto 0);
           B : in STD_LOGIC_VECTOR (7 downto 0);
           Ctrl_Alu : in STD_LOGIC_VECTOR (1 downto 0); --initially 2 downto 0
           S : out STD_LOGIC_VECTOR (7 downto 0);
           N : out STD_LOGIC;
           O : out STD_LOGIC;
           Z : out STD_LOGIC;
           C : out STD_LOGIC);
end ALU;

architecture Behavioral of ALU is
    signal aux: STD_LOGIC_VECTOR (15 downto 0);
begin
    aux <=
        (x"00"&A) + (x"00"&B) when Ctrl_Alu="01" else
        (x"00"&A) - (x"00"&B) when Ctrl_Alu="11" else
        A * B when Ctrl_Alu="10";
    S <= aux(7 downto 0);
    N <= '1' when aux(15)='1' else '0';
    O <= '1' when aux(15 downto 8) /= x"00" else '0';
    Z <= '1' when aux=x"0000" else '0';
    C <= aux(8);
end Behavioral;