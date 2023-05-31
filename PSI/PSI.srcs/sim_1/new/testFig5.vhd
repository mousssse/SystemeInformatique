----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.05.2023 11:27:49
-- Design Name: 
-- Module Name: testFig5 - Behavioral
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

entity testFig5 is
end testFig5;

architecture Behavioral of testFig5 is

    component DATA_PATH is 
        Port (INS : in STD_LOGIC_VECTOR (7 downto 0);
              CLK : in STD_LOGIC;
              RST : in STD_LOGIC);
    end component;
    
 

-- clock & entries test
constant Clock_period : time := 10 ns;
signal INS : STD_LOGIC_VECTOR (7 downto 0) :=x"00";
signal CLK : STD_LOGIC;
signal RST : STD_LOGIC;

-- temporary signals
-- signal clk, rst : STD_LOGIC; -- TODO : both
signal ins_out : STD_LOGIC_VECTOR (31 downto 0); -- instruction memory output
signal qa, qb : STD_LOGIC_VECTOR (7 downto 0); -- register bench output
signal n,o,z,c : STD_LOGIC; -- TODO : use alu flags
signal alu_out : STD_LOGIC_VECTOR (7 downto 0); -- alu output
signal dm_out : STD_LOGIC_VECTOR (7 downto 0); -- data memory output
signal dm_addr_in : STD_LOGIC_VECTOR (7 downto 0); -- data memory in address
-- TODO : make following cleaner (LC)
signal w : STD_LOGIC; -- from op to reg_bank
signal ctrl_alu : STD_LOGIC_VECTOR (1 downto 0); --initially 2 downto 0

-- pipeline LI/DI
signal li_di_a_out : STD_LOGIC_VECTOR (7 downto 0);
signal li_di_op_out : STD_LOGIC_VECTOR (7 downto 0);
signal li_di_b_out : STD_LOGIC_VECTOR (7 downto 0);
signal li_di_c_out : STD_LOGIC_VECTOR (7 downto 0);

-- pipeline DI/EX
signal di_ex_a_out : STD_LOGIC_VECTOR (7 downto 0);
signal di_ex_op_out : STD_LOGIC_VECTOR (7 downto 0);
signal di_ex_b_out : STD_LOGIC_VECTOR (7 downto 0);
signal di_ex_c_out : STD_LOGIC_VECTOR (7 downto 0);

-- pipeline EX/Mem
signal ex_mem_a_out : STD_LOGIC_VECTOR (7 downto 0);
signal ex_mem_op_out : STD_LOGIC_VECTOR (7 downto 0);
signal ex_mem_b_out : STD_LOGIC_VECTOR (7 downto 0);

-- pipeline Mem/RE
signal mem_re_a_out : STD_LOGIC_VECTOR (7 downto 0);
signal mem_re_op_out : STD_LOGIC_VECTOR (7 downto 0);
signal mem_re_b_out : STD_LOGIC_VECTOR (7 downto 0);

-- op identifiers
constant AFC : STD_LOGIC_VECTOR := x"06";
constant COP : STD_LOGIC_VECTOR := x"05";
constant ALU_OP_MIN : STD_LOGIC_VECTOR := x"01";
constant ALU_OP_MAX : STD_LOGIC_VECTOR := x"03"; -- ADD = x"01", MUL = x"02", SUB = x"03", DIV = x"04"
constant LOAD : STD_LOGIC_VECTOR := x"07";
constant STORE : STD_LOGIC_VECTOR := x"08";

begin

DUT : DATA_PATH PORT MAP (INS => INS, CLK => CLK, RST => RST);

-- Clock process : f = 100 MHz
Clock_process : process
   begin
       CLK <= not(CLK);
       wait for Clock_period/2;
   end process;
   
-- RST process : rst once at beginning of execution
Reset_process : process
    begin
        RST <= '1';
        wait for 100 ns;
        RST <= '0';
    end process;
   
-- input process
INS_process : process
    begin
        INS <=  x"06010600"; -- AFC(x"06") R1(x"01") 6(x"06") C unused(x"00") (affect 6 to R1)
        -- R1 should be equal to 6
        wait for 10 ns;
        INS <=  x"06010900"; -- AFC(x"06") R2(x"02") 9(x"09") C unused(x"00") (affect 9 to R2)
        -- R2 should be equal to 9
        wait for 10 ns;
        INS <=  x"01000102"; -- ADD(x"01") in R0(x"00") R1(x"01") + R2(x"02") (simple addition)
        -- RO should be equal to R1 + R2 = x"0F" / 15
        wait for 10 ns;
        INS <=  x"01000001"; -- ADD(x"01") in R0(x"00") R0(x"00") + R1(x"01") (destination register used in add)
        -- RO should be equal to R0 + R1 = x"15" / 21
        wait for 10 ns;
        INS <=  x"05020100"; -- COP(x"05") in R2(x"02") R0(x"00") C unused(x"00") (copy of R0 in R2)
        -- R2 should be equal to R0 (old value of R0) = x"15" / 21
        wait for 10 ns;
        INS <=  x"010001FF"; -- COP(x"05") in R2(x"02") R0(x"00") C unused(x"FF") (C changed to make sure it doesn't impact)
        -- idem ins before R2 = R0 = x"15" / 21
        wait for 10 ns;
        INS <=  x"03000102"; -- SUB(x"03") in R0(x"00") R2(x"02") * R1(x"01") (simple substraction no carry no negative)
        -- R0 should be R2 - R1 = 21 - 6 = 15 = x"0F"
        wait for 10 ns;
        INS <=  x"02000102"; -- MUL(x"02") in R0(x"00") R1(x"01") - R2(x"02") (simple multiplication no overflow)
        -- R0 should be R1 * R2 = 21 * 6 = 126 = x"7E"
        wait for 10 ns;
    end process;
   
-- output process / assertions
process 
    begin 
        wait for 10 ns; -- let 1st pipeline propagation happen
    
    end process;

end Behavioral;
