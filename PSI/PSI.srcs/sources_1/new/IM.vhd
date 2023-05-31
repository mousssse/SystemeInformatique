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
    type data_bank is array (0 to 255) of STD_LOGIC_VECTOR (31 downto 0); -- address on 8 bits = 256 possibilities on 8 bits each;
    signal data_im: data_bank:= (others => (others => '0')); 
begin

    -- OK AFC + COP + data hazard
    -- data_im <= (x"06000300", x"06010700", x"06020FFF", x"06000A00", x"05090000", x"05080000",  others => x"00000000"); -- data_im test for hazard
    -- r0 <= x"03"; r1 <= x"07"; r2 <= x"0F"; r0 <= x"OA"; r9 <= r0 = 0A (and not 03 anymore); r8 <= r0 = x"0A";
    
    -- OK AFC + COP no hazard
    -- data_im <= (x"06000300", x"06010700", x"06020FFF", x"06000A00", x"05090100", x"06090000",  others => x"00000000"); -- data_im for basic test of AFC and COP (no hazard)
    -- r0 <= x"03"; r1 <= x"07"; r2 <= x"0F"; r0 <= x"OA"; r9 <= r1 = 07; r9 <= 00;
    
    -- OK AFC + COP no hazard + NOPs
    -- data_im <= (x"06000300", x"06010700", x"06020FFF", x"00000000", x"00000000", x"00000000", x"06000A00", x"05090100", x"06090000",  others => x"00000000"); -- data_im for test of AFC and COP with empty instructions (as for NOPs per example) (no hazard)
    -- r0 <= x"03"; r1 <= x"07"; r2 <= x"0F"; NOP; NOP; NOP; r0 <= x"OA"; r9 <= r1 = 07; r9 <= 00;
    
    -- OK AFC, COP & ALU op no hazard
     data_im <= (x"06000300", x"06010700", x"06020FFF", x"00000000", x"00000000", x"01000001", x"00000000", x"00000000", x"02000102", x"06000A00", x"05090100", x"06090000", x"03000201",  others => x"00000000"); -- data_im for AFC, COP and ALU instructions (no hazard cf. addition of NOPs)
    -- r0 <= x"03"; r1 <= x"07"; r2 <= x"0F"; NOP; NOP; r0 <= r0 + r1 = 3 + 7 = x"0A"; NOP; NOP; r0 <= r1 * r2 = 7 * 15 = x"69";  r0 <= x"OA"; r9 <= r1 = 07; r9 <= 00; r0 <= r2 - r1 = 15 - 7 = x"08";
    
    -- OK B
    -- data_im <= (x"06000300", x"06010700", x"09010000", x"00000000", x"00000000", x"06020FFF", x"06000A00", x"05090100", x"06090000",  others => x"00000000"); -- data_im for basic test of AFC and COP (with branch)
    -- r0 <= x"03"; r1 <= x"07"; go to INS &00(loop)
    
    -- OK BEQ
    -- data_im <= (x"06000300", x"06010700", x"06020FFF", x"00000000", x"00000000", x"01000001", x"00000000", x"00000000", x"02000102", x"06000A00", x"05090100", x"06090000", x"03000201", x"0A030000", others => x"00000000"); -- data_im for AFC, COP and ALU instructions with branch (no hazard cf. addition of NOPs)
    -- r0 <= x"03"; r1 <= x"07"; r2 <= x"0F"; NOP; NOP; r0 <= r0 + r1 = 3 + 7 = x"0A"; NOP; NOP; r0 <= r1 * r2 = 7 * 15 = x"69";  r0 <= x"OA"; r9 <= r1 = 07; r9 <= 00; r0 <= r2 - r1 = 15 - 7 = x"08"; beq &03 in IM; (here, should not branch)
    
    -- OK BNE
    -- data_im <= (x"06000300", x"06010700", x"06020FFF", x"00000000", x"00000000", x"01000001", x"00000000", x"00000000", x"02000102", x"06000A00", x"05090100", x"06090000", x"03000201", x"0B030000", others => x"00000000"); -- data_im for AFC, COP and ALU instructions with branch (no hazard cf. addition of NOPs)
    -- r0 <= x"03"; r1 <= x"07"; r2 <= x"0F"; NOP; NOP; r0 <= r0 + r1 = 3 + 7 = x"0A"; NOP; NOP; r0 <= r1 * r2 = 7 * 15 = x"69";  r0 <= x"OA"; r9 <= r1 = 07; r9 <= 00; r0 <= r2 - r1 = 15 - 7 = x"08"; bne &03 in IM; (here, should branch to x"03)
    
    -- OK BLT
    -- data_im <= (x"06000300", x"06010700", x"06020FFF", x"00000000", x"00000000", x"01000001", x"00000000", x"00000000", x"02000102", x"06000A00", x"05090100", x"06090000", x"03000201", x"0C030000", others => x"00000000"); -- data_im for AFC, COP and ALU instructions with branch (no hazard cf. addition of NOPs)
    -- r0 <= x"03"; r1 <= x"07"; r2 <= x"0F"; NOP; NOP; r0 <= r0 + r1 = 3 + 7 = x"0A"; NOP; NOP; r0 <= r1 * r2 = 7 * 15 = x"69";  r0 <= x"OA"; r9 <= r1 = 07; r9 <= 00; r0 <= r2 - r1 = 15 - 7 = x"08"; blt &03 in IM; (here, should not branch)
    
    -- OK BGE
    -- data_im <= (x"06000300", x"06010700", x"06020FFF", x"00000000", x"00000000", x"01000001", x"00000000", x"00000000", x"02000102", x"06000A00", x"05090100", x"06090000", x"03000201", x"0D030000", others => x"00000000"); -- data_im for AFC, COP and ALU instructions with branch (no hazard cf. addition of NOPs)
    -- r0 <= x"03"; r1 <= x"07"; r2 <= x"0F"; NOP; NOP; r0 <= r0 + r1 = 3 + 7 = x"0A"; NOP; NOP; r0 <= r1 * r2 = 7 * 15 = x"69";  r0 <= x"OA"; r9 <= r1 = 07; r9 <= 00; r0 <= r2 - r1 = 15 - 7 = x"08"; bge &03 in IM; (here, should branch)    
        
    -- OK ? BGT
    -- data_im <= (x"06000300", x"06010700", x"06020FFF", x"00000000", x"00000000", x"01000001", x"00000000", x"00000000", x"02000102", x"06000A00", x"05090100", x"06090000", x"03000201", x"0E030000", others => x"00000000"); -- data_im for AFC, COP and ALU instructions with branch (no hazard cf. addition of NOPs)
    -- r0 <= x"03"; r1 <= x"07"; r2 <= x"0F"; NOP; NOP; r0 <= r0 + r1 = 3 + 7 = x"0A"; NOP; NOP; r0 <= r1 * r2 = 7 * 15 = x"69";  r0 <= x"OA"; r9 <= r1 = 07; r9 <= 00; r0 <= r2 - r1 = 15 - 7 = x"08"; bgt &03 in IM; (here, should branch)        

    -- OK ? BLE
    -- data_im <= (x"06000300", x"06010700", x"06020FFF", x"00000000", x"00000000", x"01000001", x"00000000", x"00000000", x"02000102", x"06000A00", x"05090100", x"06090000", x"03000201", x"0F030000", others => x"00000000"); -- data_im for AFC, COP and ALU instructions with branch (no hazard cf. addition of NOPs)
    -- r0 <= x"03"; r1 <= x"07"; r2 <= x"0F"; NOP; NOP; r0 <= r0 + r1 = 3 + 7 = x"0A"; NOP; NOP; r0 <= r1 * r2 = 7 * 15 = x"69";  r0 <= x"OA"; r9 <= r1 = 07; r9 <= 00; r0 <= r2 - r1 = 15 - 7 = x"08"; ble &03 in IM; (here, should not branch)   
        
    -- OK LOAD & STORE
    -- data_im <= (x"06012023", x"00000000", x"00000000", x"00000000", x"00000000", x"08000100", x"00000000", x"00000000", x"00000000", x"00000000", x"07000000", others => x"00000000"); -- data_im for simple test of load and store without hazard (lots of NOPs for easier visualization)
    -- r1 <= x"20", NOP; NOP; NOP; NOP; &00 <= r1 = x"20"; NOP; NOP; NOP; NOP; r0 <= &00 = x"20";
    
    -- NOT OK STORE & LOAD in a row
    -- data_im <= (x"06012023", x"00000000", x"00000000", x"00000000", x"00000000", x"08000100", x"07000000", others => x"00000000"); -- data_im for simple test of load and store with hazard (store & load in a row)
    -- r1 <= x"20"; NOP; NOP; NOP; NOP; &00 <= r1 = x"20"; r0 <= &00 = x"20";
    
    -- NOT OK
    -- data_im <= (x"06000300", x"06020700", x"06010FFF", x"01000100", x"02000002", x"06000A00", x"05090100", x"06090000", x"03000201",  others => x"00000000"); -- data_im for AFC, COP and ALU instructions (no hazard cf. addition of NOPs)

    
    process
        begin
            wait until CLK'event and CLK='1';
            OUT_INS <= data_im(to_integer(unsigned(ADDR_INS)));    
    end process;
end Behavioral;