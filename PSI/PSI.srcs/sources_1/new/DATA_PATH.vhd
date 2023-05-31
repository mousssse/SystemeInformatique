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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.IM;
use work.REG;
use work.DM;
use work.ALU;

entity DATA_PATH is
    Port (CLK : in STD_LOGIC;
          RST : in STD_LOGIC);
end DATA_PATH;

architecture struct of DATA_PATH is
    component IM -- instruction memory
        port( CLK : in STD_LOGIC;
              ADDR_INS :in STD_LOGIC_VECTOR(7 downto 0);
              OUT_INS : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    component REG -- register bench
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
    component ALU -- arithmetics logic unit
            port( A : in STD_LOGIC_VECTOR (7 downto 0);
                  B : in STD_LOGIC_VECTOR (7 downto 0);
                  Ctrl_Alu : in STD_LOGIC_VECTOR (1 downto 0);
                  S : out STD_LOGIC_VECTOR (7 downto 0);
                  N : out STD_LOGIC;
                  O : out STD_LOGIC;
                  Z : out STD_LOGIC;
                  C : out STD_LOGIC);
    end component;
    component DM -- data memory
            port( IN_DATA : in STD_LOGIC_VECTOR (7 downto 0);
                  RW : in STD_LOGIC; -- 0 if write, 1 if read
                  RST : in STD_LOGIC;
                  CLK : in STD_LOGIC;
                  OUT_DATA : out STD_LOGIC_VECTOR (7 downto 0);
                  ADDR_DATA : in STD_LOGIC_VECTOR (7 downto 0));
    end component;

-- link components to their effective design
for all : IM use entity work.IM(Behavioral);
for all : REG use entity work.REG(Behavioral);
for all : ALU use entity work.ALU(Behavioral);
for all : DM use entity work.DM(Behavioral);

-- temporary signals
signal INS : STD_LOGIC_VECTOR (7 downto 0) := x"00";
signal ins_out : STD_LOGIC_VECTOR (31 downto 0); -- instruction memory output
signal qa, qb : STD_LOGIC_VECTOR (7 downto 0); -- register bench output
signal n,o,z,c : STD_LOGIC; -- TODO : use alu flags
signal alu_out : STD_LOGIC_VECTOR (7 downto 0); -- alu output
signal dm_out : STD_LOGIC_VECTOR (7 downto 0); -- data memory output
signal dm_addr_in : STD_LOGIC_VECTOR (7 downto 0); -- data memory in address
-- TODO : make following cleaner (LC)
signal w_reg, w_dm : STD_LOGIC; -- from op to reg_bank
-- signal ctrl_alu : STD_LOGIC_VECTOR (1 downto 0); 

-- pipeline LI/DI
signal li_di_a_out : STD_LOGIC_VECTOR (7 downto 0);
signal li_di_op_out : STD_LOGIC_VECTOR (7 downto 0);
signal li_di_b_out : STD_LOGIC_VECTOR (7 downto 0);
signal li_di_c_out : STD_LOGIC_VECTOR (7 downto 0); -- only used for @B input of Register Bench

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
-- decIns 0A and incIns OB
begin
    -- port map : link inputs and outputs to changeable signals
    U1: IM port map(CLK => CLK, ADDR_INS => INS, OUT_INS => ins_out);
    U2: REG port map(AddrA => li_di_b_out(3 downto 0), AddrB => li_di_c_out(3 downto 0), AddrW => mem_re_a_out(3 downto 0), W => w_reg, DATA => mem_re_b_out, RST => RST, CLK => CLK, QA => qa, QB => qb);
    U3: ALU port map(A => di_ex_b_out, B => di_ex_c_out, Ctrl_Alu => di_ex_op_out(1 downto 0), S => alu_out, N => n, O => o, Z => z, C => c);
    U4: DM port map(IN_DATA => ex_mem_b_out,RW => w_dm,RST => RST, CLK => CLK, OUT_DATA => dm_out, ADDR_DATA => dm_addr_in);         
    process --(CLK,RST,INS) --TODO : decide sensitivity list with 3 or wait until CLK'event with CLK only
            variable incINS : integer := 1;
            begin --TODO : gestion des aléas (R following W)
                wait until CLK'event and CLK='1';
                --instruction pipeline (1st floor)
                li_di_b_out <= ins_out (15 downto 8);
                li_di_c_out <= ins_out (7 downto 0);
                li_di_a_out <= ins_out (23 downto 16);
                li_di_op_out <= ins_out (31 downto 24);
                
                -- register bench pipeline propagation (2nd floor)
                if di_ex_op_out = AFC and li_di_op_out = COP and di_ex_a_out = li_di_b_out then
                    -- alea => insert NOP
                    di_ex_b_out <= x"00";
                    di_ex_c_out <= x"00";
                    di_ex_a_out <= x"00";
                    di_ex_op_out <= x"00";
                    incINS := -1;
                else
                    incINS := 1;
                    di_ex_a_out <= li_di_a_out;
                    di_ex_op_out <= li_di_op_out;
                    if (li_di_op_out = AFC) then -- 2nd figure : AFC & COP
                        di_ex_b_out <= li_di_b_out;
                    elsif (li_di_op_out > x"00" and li_di_op_out <= COP) or li_di_op_out = STORE then -- not dynamic
                        di_ex_b_out <= qa;
                    end if;    
                    di_ex_c_out <= qb;
                    if ex_mem_op_out > x"00" and ex_mem_op_out <= LOAD then -- not dynamic, but works here bc every op code <= 0x07 means writing in a register
                        w_reg <= '1';
                    else 
                        w_reg <= '0';
                    end if;
                end if;
                
                -- ALU pipeline propagation (3rd floor)
                ex_mem_a_out <= di_ex_a_out;
                ex_mem_op_out <= di_ex_op_out;
                if ((ALU_OP_MIN <= di_ex_op_out) and (di_ex_op_out <= ALU_OP_MAX)) then -- 3rd figure
                    ex_mem_b_out <= alu_out;
                else
                    ex_mem_b_out <= di_ex_b_out; 
                end if;
                
                if (di_ex_op_out = STORE) then -- prepare DM entries
                    dm_addr_in <= ex_mem_a_out;
                    w_dm <= '1';
                elsif (di_ex_op_out = LOAD) then
                    dm_addr_in <= ex_mem_b_out;
                    w_dm <= '0';
                end if;
                
                -- data memory pipeline propagation (4th floor)
                mem_re_a_out <= ex_mem_a_out;
                mem_re_op_out <= ex_mem_op_out; 
                if ((ex_mem_op_out = LOAD) or (ex_mem_op_out = STORE)) then -- 4th and 5th fig : LOAD & STORE
                    mem_re_b_out <= dm_out;
                else    
                    mem_re_b_out <= ex_mem_b_out;
                end if;
                INS <= INS + incINS;
        end process;
end struct; 