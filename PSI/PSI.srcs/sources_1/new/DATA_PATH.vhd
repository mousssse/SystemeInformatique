----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.05.2023 09:48:23
-- Design Name: 
-- Module Name: DATA_PATH - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use work.IM;
use work.REG;
use work.DM;
use work.ALU;

entity DATA_PATH is
    Port (INS: in STD_LOGIC_VECTOR(7 downto 0));
end DATA_PATH;

architecture struct of DATA_PATH is
    component ins_mem
        port( CLK : in STD_LOGIC;
              ADDR_INS :in STD_LOGIC_VECTOR(7 downto 0);
              OUT_INS : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    component reg_bank
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
    component alu
            port( A : in STD_LOGIC_VECTOR (7 downto 0);
                  B : in STD_LOGIC_VECTOR (7 downto 0);
                  Ctrl_Alu : in STD_LOGIC_VECTOR (2 downto 0);
                  S : out STD_LOGIC_VECTOR (7 downto 0);
                  N : out STD_LOGIC;
                  O : out STD_LOGIC;
                  Z : out STD_LOGIC;
                  C : out STD_LOGIC);
    end component;
    component data_memory
            port( IN_DATA : in STD_LOGIC_VECTOR (7 downto 0);
                  RW : in STD_LOGIC; -- 0 if write, 1 if read
                  RST : in STD_LOGIC;
                  CLK : in STD_LOGIC;
                  OUT_DATA : out STD_LOGIC_VECTOR (7 downto 0);
                  ADDR_DATA : in STD_LOGIC_VECTOR (7 downto 0));
    end component;

-- link components to their effective design
for all : ins_mem use entity work.IM(Behavioral);
for all : reg_bank use entity work.REG(Behavioral);
for all : alu use entity work.ALU(Behavioral);
for all : data_memory use entity work.DM(Behavioral);

--tmp, gérer la clock
signal clk, rst : STD_LOGIC;
signal out_ins : STD_LOGIC_VECTOR (31 downto 0);
signal qa, qb : STD_LOGIC_VECTOR (7 downto 0);

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




begin
    U1: ins_mem port map(CLK,INS,out_ins);
    U2: reg_bank port map(li_di_b_out(3 downto 0),li_di_c_out(3 downto 0),mem_re_a_out(3 downto 0),'0',mem_re_b_out, RST, CLK, qa, qb); --change RST and CLK
    -- U3: alu port map();
    -- U4: data_memory port map();
    process
        begin
            wait until CLK'event and CLK='1'; --change CLK (use counter ?)
            
            --instruction pipeline (1st floor)
            li_di_a_out <= out_ins (15 downto 8);
            li_di_op_out <= out_ins (7 downto 0);
            li_di_b_out <= out_ins (23 downto 16);
            li_di_c_out <= out_ins (31 downto 24);
            
            -- if (li_di_op_out = x"06") then --if AFC or COP, move later (just a reminder)
            -- register bank pipeline propagation (2nd floor)
            di_ex_a_out <= li_di_a_out;
            di_ex_op_out <= li_di_a_out;
            di_ex_b_out <= li_di_b_out;
            
            -- ALU pipeline propagation (3rd floor)
            ex_mem_a_out <= di_ex_a_out;
            ex_mem_op_out <= di_ex_op_out;
            ex_mem_b_out <= di_ex_b_out;
            
            -- data memory pipeline propagation (4th floor)
            mem_re_a_out <= ex_mem_a_out;
            mem_re_op_out <= ex_mem_op_out;
            mem_re_b_out <= ex_mem_b_out;
            --end if;
    end process;
end struct; 