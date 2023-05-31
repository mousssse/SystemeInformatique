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
    component PL -- pipeline with 4
            port( OP_IN : in STD_LOGIC_VECTOR (7 downto 0);
                  A_IN : in STD_LOGIC_VECTOR (7 downto 0);
                  B_IN : in STD_LOGIC_VECTOR (7 downto 0);
                  C_IN : in STD_LOGIC_VECTOR (7 downto 0);
                  OP_OUT : out STD_LOGIC_VECTOR (7 downto 0);
                  A_OUT : out STD_LOGIC_VECTOR (7 downto 0);
                  B_OUT : out STD_LOGIC_VECTOR (7 downto 0);
                  C_OUT : out STD_LOGIC_VECTOR (7 downto 0);
                  CLK : in STD_LOGIC);
    end component;
    component PL2 -- pipeline with 3 
                port( OP_IN : in STD_LOGIC_VECTOR (7 downto 0);
                      A_IN : in STD_LOGIC_VECTOR (7 downto 0);
                      B_IN : in STD_LOGIC_VECTOR (7 downto 0);
                      OP_OUT : out STD_LOGIC_VECTOR (7 downto 0);
                      A_OUT : out STD_LOGIC_VECTOR (7 downto 0);
                      B_OUT : out STD_LOGIC_VECTOR (7 downto 0);
                      CLK : in STD_LOGIC);
    end component;

-- link components to their effective design
for all : IM use entity work.IM(Behavioral);
for all : REG use entity work.REG(Behavioral);
for all : ALU use entity work.ALU(Behavioral);
for all : DM use entity work.DM(Behavioral);
for all : PL use entity work.PL(Behavioral);
for all : PL2 use entity work.PL2(Behavioral);

-- temporary signals
signal INS : STD_LOGIC_VECTOR (7 downto 0) := x"00";
signal ins_out : STD_LOGIC_VECTOR (31 downto 0); -- instruction memory output
signal qa, qb : STD_LOGIC_VECTOR (7 downto 0); -- register bench output
signal n,o,z,c : STD_LOGIC; -- TODO : use alu flags ? for branching
signal alu_out : STD_LOGIC_VECTOR (7 downto 0); -- alu output
signal dm_out : STD_LOGIC_VECTOR (7 downto 0); -- data memory output

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
constant AFC : STD_LOGIC_VECTOR := x"06";
constant COP : STD_LOGIC_VECTOR := x"05";
constant ALU_OP_MIN : STD_LOGIC_VECTOR := x"01";
constant ALU_OP_MAX : STD_LOGIC_VECTOR := x"03"; -- ADD = x"01", MUL = x"02", SUB = x"03", DIV = x"04"
constant LOAD : STD_LOGIC_VECTOR := x"07";
constant STORE : STD_LOGIC_VECTOR := x"08";
-- branch
constant BRANCH : STD_LOGIC_VECTOR := x"09"; 
constant BEQ : STD_LOGIC_VECTOR := x"0A";
constant BNE : STD_LOGIC_VECTOR := x"0B";
constant BLT : STD_LOGIC_VECTOR := x"0C";
constant BGE : STD_LOGIC_VECTOR := x"0D";
constant BGT : STD_LOGIC_VECTOR := x"0E";
constant BLE : STD_LOGIC_VECTOR := x"0F";

-- mux outputs
-- signal mux_di_ex_op : STD_LOGIC_VECTOR (7 downto 0);
signal mux_di_ex_b : STD_LOGIC_VECTOR (7 downto 0);
signal mux_di_ex_c : STD_LOGIC_VECTOR (7 downto 0);
signal mux_ex_mem_b : STD_LOGIC_VECTOR (7 downto 0);
signal mux_dm_addr_in : STD_LOGIC_VECTOR (7 downto 0);                                                                                                                                                                                                                                                                             
signal mux_dm_data_in : STD_LOGIC_VECTOR (7 downto 0);
signal mux_mem_re_b : STD_LOGIC_VECTOR (7 downto 0);
signal mux_jump_addr : STD_LOGIC_VECTOR (7 downto 0);

-- lc
signal lc_ctrl_alu : STD_LOGIC_VECTOR (1 downto 0);
signal lc_rw_dm, lc_rw_reg : STD_LOGIC;
signal lc_b : STD_LOGIC;

-- hazard detector - injection of NOPs
-- signal hazard_1 : STD_LOGIC;

begin
   -- port map : link inputs and outputs to changeable signals
   -- components (FLOORS)
   U_IM: IM port map(CLK => CLK, ADDR_INS => INS, OUT_INS => ins_out);
   U_REG: REG port map(AddrA => li_di_b_out(3 downto 0), AddrB => li_di_c_out(3 downto 0), AddrW => mem_re_a_out(3 downto 0), W => lc_rw_reg, DATA => mem_re_b_out, RST => RST, CLK => CLK, QA => qa, QB => qb);
   U_ALU: ALU port map(A => di_ex_b_out, B => di_ex_c_out, Ctrl_Alu => lc_ctrl_alu, S => alu_out, N => n, O => o, Z => z, C => c);
   U_DM: DM port map(IN_DATA => ex_mem_b_out, RW => lc_rw_dm,RST => RST, CLK => CLK, OUT_DATA => dm_out, ADDR_DATA => mux_dm_addr_in);         
   -- pipelines
   U_PL_IM: PL port map(OP_IN => ins_out(31 downto 24), A_IN => ins_out(23 downto 16), B_IN => ins_out(15 downto 8), C_IN => ins_out(7 downto 0), OP_OUT => li_di_op_out, A_OUT => li_di_a_out, B_OUT => li_di_b_out, C_OUT => li_di_c_out, CLK => CLK);
   U_PL_REG: PL port map(OP_IN => li_di_op_out, A_IN => li_di_a_out, B_IN => mux_di_ex_b, C_IN => mux_di_ex_c, OP_OUT => di_ex_op_out, A_OUT => di_ex_a_out, B_OUT => di_ex_b_out, C_OUT => di_ex_c_out, CLK => CLK);
   U_PL_ALU: PL2 port map(OP_IN => di_ex_op_out, A_IN => di_ex_a_out, B_IN => mux_ex_mem_b, OP_OUT => ex_mem_op_out, A_OUT => ex_mem_a_out, B_OUT => ex_mem_b_out, CLK => CLK);
   U_PL_DM: PL2 port map(OP_IN => ex_mem_op_out, A_IN => ex_mem_a_out, B_IN => mux_mem_re_b, OP_OUT => mem_re_op_out, A_OUT => mem_re_a_out, B_OUT => mem_re_b_out, CLK => CLK);
   
         
   -- LC
   -- branch (next instruction)
   lc_b <=
           '1' when li_di_op_out = BRANCH 
                   or (li_di_op_out = BEQ and z = '1') 
                   or (li_di_op_out = BNE and z = '0') 
                   or (li_di_op_out = BLT and n = '1') 
                   or (li_di_op_out = BGE and n = '0')
                   or (li_di_op_out = BGT and c = '1')
                   or (li_di_op_out = BLE and c = '0') else
           '0';
   -- operation for alu (sub, add, mul)
   lc_ctrl_alu <=
        di_ex_op_out(1 downto 0) when (ALU_OP_MIN <= di_ex_op_out and di_ex_op_out <= ALU_OP_MAX) else
        "XX";
    
   -- rw for data memory (LOAD and STORE)
   lc_rw_dm <=
        '1' when ex_mem_op_out = STORE else
        '0';
        
   -- rw for register bench (AFC, COP, etc)
   lc_rw_reg <=
        '1' when (x"00" < mem_re_op_out and mem_re_op_out < LOAD) else -- not dynamic, works with our op codes only
        '0';
 
   
   -- MULTIPLEXERS
   -- mux for di_ex_op when branching (annihilate)
   --mux_di_ex_op <=
   --     x"00" when li_di_op_out = BRANCH 
   --               or (li_di_op_out = BEQ and z = '1') 
   --               or (li_di_op_out = BNE and z = '0') 
   --               or (li_di_op_out = BLT and n = '1') 
   --               or (li_di_op_out = BGE and n = '0')
   --               or (li_di_op_out = BGT and c = '1')
   --               or (li_di_op_out = BLE and c = '0') else
   --     li_di_op_out;
   -- mux for di_ex_b (register or value)
   mux_di_ex_b <=
        -- data hazard ALU
        mux_ex_mem_b when di_ex_b_out = li_di_b_out and li_di_op_out < STORE and (di_ex_op_out >= ALU_OP_MIN and di_ex_op_out <= ALU_OP_MAX) else
        -- data hazard AFC & COP
        mux_ex_mem_b when di_ex_a_out = li_di_b_out and di_ex_op_out = AFC and li_di_op_out = COP else
        mux_mem_re_b when ex_mem_a_out = li_di_b_out and ex_mem_op_out = AFC and li_di_op_out = COP else
        li_di_b_out when li_di_op_out = AFC else -- alea AFC puis COP
        qa;
    
    -- mux for di_ex_c (for ALU hazard) 
    mux_di_ex_c <=
        li_di_c_out when di_ex_b_out = li_di_b_out and li_di_op_out < STORE and (di_ex_op_out >= ALU_OP_MIN and di_ex_op_out <= ALU_OP_MAX) else
        qb;
    
    -- mux for ex_mem_b (di_ex_b or alu output)
    mux_ex_mem_b <=
        di_ex_b_out when (di_ex_op_out > ALU_OP_MAX) else
        alu_out;
    
    -- mux for addr of data memory (ex_mem_a_out or ex_mem_b_out)
    mux_dm_addr_in <=
        ex_mem_a_out when ex_mem_op_out = STORE else
        ex_mem_b_out;
        
    -- mux for mem_re_b (ex_mem_b_out or output of data memory)
    mux_mem_re_b <=
        dm_out when ex_mem_op_out = LOAD and mem_re_op_out /= STORE else
        ex_mem_b_out;
        
    -- mux for jump_address
    mux_jump_addr <= 
        li_di_a_out when li_di_op_out = BRANCH
                       or (li_di_op_out = BEQ and z = '1') 
                       or (li_di_op_out = BNE and z = '0') 
                       or (li_di_op_out = BLT and n = '1') 
                       or (li_di_op_out = BGE and n = '0')
                       or (li_di_op_out = BGT and c = '1')
                       or (li_di_op_out = BLE and c = '0') else
        INS; -- could be anything
       
   process
        begin
            wait until CLK'event and CLK='1';
            if lc_b='0' then INS <= INS + 1; else INS <= mux_jump_addr;  end if;
   end process;
end struct; 