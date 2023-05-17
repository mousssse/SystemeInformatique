----------------------------------------------------------------------------------
-- Company: INSA Toulouse
-- Engineer: Sarah Mousset & Valentin Guittard
-- 
-- Create Date: 16.05.2023 09:48:23
-- Design Name: 
-- Module Name: DATA_PATH - Behavioral
-- Project Name: PSI
-- Target Devices: FPGA Basys 3
-- Tool Versions: 
-- Description: This source gives the code needed to link all 4 components (alu, data & instruction memory, register bank) together.
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
use work.IM;
use work.REG;
use work.DM;
use work.ALU;

entity DATA_PATH is
    Port (INS: in STD_LOGIC_VECTOR(7 downto 0));
end DATA_PATH;

architecture struct of DATA_PATH is
    component ins_mem -- instruction memory
        port( CLK : in STD_LOGIC;
              ADDR_INS :in STD_LOGIC_VECTOR(7 downto 0);
              OUT_INS : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    component reg_ben -- register bench
            port( AddrA : in STD_LOGIC_VECTOR (3 downto 0); 
                  AddrB : in STD_LOGIC_VECTOR (3 downto 0);
                  AddrW : in STD_LOGIC_VECTOR (3 downto 0);
                  W : in STD_LOGIC; -- 1 if writing 
                  DATA : in STD_LOGIC_VECTOR (7 downto 0);
                  RST : in STD_LOGIC;
                  CLK : in STD_LOGIC;
                  QA : out STD_LOGIC_VECTOR (7 downto 0);
                  QB : out STD_LOGIC_VECTOR (7 downto 0));
    end component;
    component alu -- arithmetics logic unit
            port( A : in STD_LOGIC_VECTOR (7 downto 0);
                  B : in STD_LOGIC_VECTOR (7 downto 0);
                  Ctrl_Alu : in STD_LOGIC_VECTOR (2 downto 0);
                  S : out STD_LOGIC_VECTOR (7 downto 0);
                  N : out STD_LOGIC;
                  O : out STD_LOGIC;
                  Z : out STD_LOGIC;
                  C : out STD_LOGIC);
    end component;
    component data_memory -- data memory
            port( IN_DATA : in STD_LOGIC_VECTOR (7 downto 0);
                  RW : in STD_LOGIC; -- 0 if write, 1 if read
                  RST : in STD_LOGIC;
                  CLK : in STD_LOGIC;
                  OUT_DATA : out STD_LOGIC_VECTOR (7 downto 0);
                  ADDR_DATA : in STD_LOGIC_VECTOR (7 downto 0));
    end component;

-- link components to their effective design
for all : ins_mem use entity work.IM(Behavioral);
for all : reg_ben use entity work.REG(Behavioral);
for all : alu use entity work.ALU(Behavioral);
for all : data_memory use entity work.DM(Behavioral);

-- temporary signals 
signal clk, rst : STD_LOGIC; -- TODO : both
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
-- TODO ? DIV
constant AFC : STD_LOGIC_VECTOR := x"06";
constant COP : STD_LOGIC_VECTOR := x"05";
constant ALU_OP_MIN : STD_LOGIC_VECTOR := x"01";
constant ALU_OP_MAX : STD_LOGIC_VECTOR := x"03"; -- ADD = x"01", MUL = x"02", SUB = x"03", DIV = x"04"
constant LOAD : STD_LOGIC_VECTOR := x"07";
constant STORE : STD_LOGIC_VECTOR := x"08";

begin
    -- port map : link inputs and outputs to changeable signals
    U1: ins_mem port map(CLK => CLK, ADDR_INS => INS, OUT_INS => ins_out);
    U2: reg_ben port map(AddrA => li_di_b_out(3 downto 0), AddrB => li_di_c_out(3 downto 0), AddrW => mem_re_a_out(3 downto 0), W => w, DATA => mem_re_b_out, RST => RST, CLK => CLK, QA => qa, QB => qb);
    U3: alu port map(A => di_ex_b_out, B => di_ex_c_out, Ctrl_Alu => ctrl_alu, S => alu_out, N => n, O => o, Z => z, C => c);
    U4: data_memory port map(IN_DATA => dm_addr_in,RW => w,RST => RST, CLK => CLK, OUT_DATA => dm_out, ADDR_DATA => ex_mem_b_out);
    
    process --(CLK,RST,INS) --TODO : decide sensitivity list with 3 or wait until CLK'event with CLK only
        begin --TODO : gestion des aléas (R following W)
            wait until CLK'event and CLK='1'; --TODO : change CLK (use counter ?)
            
            --instruction pipeline (1st floor)
            li_di_a_out <= ins_out (15 downto 8);
            li_di_op_out <= ins_out (7 downto 0);
            li_di_b_out <= ins_out (23 downto 16);
            li_di_c_out <= ins_out (31 downto 24);
            
            -- register bench pipeline propagation (2nd floor)
            di_ex_a_out <= li_di_a_out;
            di_ex_op_out <= li_di_op_out;
            if (li_di_op_out = AFC) then -- 2nd figure : AFC & COP
                w <= '1'; -- write
                di_ex_b_out <= li_di_b_out;
            elsif (li_di_op_out = COP) then
                w <= '0'; -- read
                di_ex_b_out <= qa;
            end if;    
            di_ex_c_out <= qb;
            
            -- ALU pipeline propagation (3rd floor)
            ex_mem_a_out <= di_ex_a_out;
            ex_mem_op_out <= di_ex_op_out;
            if ((ALU_OP_MIN <= di_ex_op_out) and (di_ex_op_out <= ALU_OP_MAX)) then -- 3rd figure
                w <= '1'; -- write
                ctrl_alu <= di_ex_op_out(1 downto 0);
                ex_mem_b_out <= alu_out;
            else
                ex_mem_b_out <= di_ex_b_out;
            end if;
            
            -- data memory pipeline propagation (4th floor)
            if (ex_mem_op_out = STORE) then
                dm_addr_in <= ex_mem_a_out;
                w <= '1'; -- write
            elsif (ex_mem_op_out = LOAD) then
                w <= '0'; -- read
                dm_addr_in <= ex_mem_b_out;
            end if;
            mem_re_a_out <= ex_mem_a_out;
            mem_re_op_out <= ex_mem_op_out; 
            if ((ex_mem_op_out = LOAD) or (ex_mem_op_out = STORE)) then -- 4th and 5th fig : LOAD & STORE
                mem_re_b_out <= dm_out;
            else    
                mem_re_b_out <= ex_mem_b_out;
            end if;
    end process;
end struct; 