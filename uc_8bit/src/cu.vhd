library ieee;
use ieee.std_logic_1164.all;

entity cu is
    generic (CTRLS: natural := 18; INSTR_SIZE: natural := 17; STEP_SIZE: natural := 4);
    port (CLK, PROG, RST:in std_logic;
        INSTRUCTION_IN:in std_logic_vector((INSTR_SIZE-1) downto 0);
        CONTROLS:inout std_logic_vector((CTRLS-1) downto 0);
        INPUT:out std_logic_vector(7 downto 0);
        ADDR:out std_logic_vector(3 downto 0));
end cu;

architecture arch_cu of cu is

component instr_rom is
    generic (ADDRESS_LEN: natural := 8; MEM_SIZE: natural := 14);
    port (CLK:in std_logic;
        ADDR:in std_logic_vector((ADDRESS_LEN-1) downto 0);
        CONTENT:out std_logic_vector((MEM_SIZE-1) downto 0));
end component instr_rom;

component program_memory is
    generic (ADDRESS_LENGTH: natural := 8; N_OF_BIT: natural := 16);
    port (CLK, PROG, RST:in std_logic;
         ADDR_READ:in std_logic_vector((ADDRESS_LENGTH-1) downto 0);
         DATA_IN:in std_logic_vector((N_OF_BIT-1) downto 0);
         DATA_OUT:out std_logic_vector((N_OF_BIT-1) downto 0);
         FULL_MEM:out std_logic);
end component program_memory;

component counter is
	generic (N_OF_BIT: natural := 8);
	port (CLK, EN, CLR, LD:in std_logic;
		LOAD:in std_logic_vector((N_OF_BIT-1) downto 0);
		Q:inout std_logic_vector((N_OF_BIT-1) downto 0);
		TC:out std_logic);
end component counter;

component load_register is
	generic (N_OF_BIT: natural := 8);
	port (LOAD:in std_logic_vector((N_OF_BIT-1) downto 0);
		CLK, LD, CLR:in std_logic;
		Q:out std_logic_vector((N_OF_BIT-1) downto 0));
end component load_register;

component dcd is
    generic (N_OF_BIT: natural := 4);
    port (X:in std_logic_vector((N_OF_BIT-1) downto 0);
        Y:out std_logic_vector((2**N_OF_BIT-1) downto 0));
end component dcd;

signal INVERTED_CLK: std_logic;

signal PROGRAM_COUNTER_OUT: std_logic_vector(7 downto 0);
signal MEM_ADDR_REG_OUT: std_logic_vector(7 downto 0);
signal RAM_MEM_OUT: std_logic_vector((INSTR_SIZE-1) downto 0); 
signal INSTRUCTION_REG_OUT: std_logic_vector((INSTR_SIZE-1) downto 0);
signal OP_CODE: std_logic_vector(4 downto 0);
signal STEP_COUNTER_OUT: std_logic_vector((STEP_SIZE-1) downto 0);
signal STEP_RESET_DCD: std_logic_vector(15 downto 0);
signal INSTR_STEP_ADDR: std_logic_vector(8 downto 0); 
signal JUMP_ADDR: std_logic_vector(7 downto 0);
signal STP_RES, STEP_EN: std_logic;

signal ADDR1, ADDR2: std_logic_vector(3 downto 0);

begin

    INVERTED_CLK <= not CLK; 

    PROGRAM_COUNTER: counter generic map (N_OF_BIT => 8) port map (CONTROLS(3), '1', RST, CONTROLS(0), JUMP_ADDR, PROGRAM_COUNTER_OUT);
    MEM_ADDR_REG: load_register generic map (N_OF_BIT => 8) port map (PROGRAM_COUNTER_OUT, CLK, CONTROLS(2), RST, MEM_ADDR_REG_OUT);
    RAM_MEM: program_memory generic map (N_OF_BIT => INSTR_SIZE) port map (CLK, PROG, RST, MEM_ADDR_REG_OUT, INSTRUCTION_IN, RAM_MEM_OUT);
    INSTRUCTION_REG: load_register generic map (N_OF_BIT => INSTR_SIZE) port map (RAM_MEM_OUT, CLK, CONTROLS(1), RST, INSTRUCTION_REG_OUT);

    INPUT <= INSTRUCTION_REG_OUT(7 downto 0);
    
    ADDR1 <= INSTRUCTION_REG_OUT(11 downto 8);
    ADDR2 <= INSTRUCTION_REG_OUT(7 downto 4);
    JUMP_ADDR <= INSTRUCTION_REG_OUT(11 downto 4);
    OP_CODE <= INSTRUCTION_REG_OUT(16 downto 12);
    
    EFFECTIVE_ADDRESS: process (ADDR1, ADDR2, INSTR_STEP_ADDR)
    begin
        ADDR <= ADDR1;
        if INSTR_STEP_ADDR(8 downto 4) < "01111" or INSTR_STEP_ADDR(8 downto 4) > "10101" then
            ADDR <= ADDR1;
        elsif INSTR_STEP_ADDR(3 downto 0) > "0100" and INSTR_STEP_ADDR(3 downto 0) < "1000" then
            ADDR <= ADDR2;
        end if;
    end process EFFECTIVE_ADDRESS; 
	
	STP_RES <= STEP_RESET_DCD(9) or RST;  
	STEP_EN <= not PROG;
	
    STEP_COUNTER: counter generic map (N_OF_BIT => STEP_SIZE) port map (INVERTED_CLK, STEP_EN, STP_RES, '0', (others=>'0'), STEP_COUNTER_OUT);
    STEP_RESET: dcd generic map (N_OF_BIT => 4) port map (STEP_COUNTER_OUT, STEP_RESET_DCD);
    INSTR_STEP_ADDR <= OP_CODE & STEP_COUNTER_OUT;
    ROM_MEM: instr_rom generic map (ADDRESS_LEN => 9, MEM_SIZE => CTRLS) port map (INVERTED_CLK, INSTR_STEP_ADDR, CONTROLS);

end arch_cu;
