library ieee;
use ieee.std_logic_1164.all;

entity program_memory is
    generic (ADDRESS_LENGTH: natural := 8; N_OF_BIT: natural := 16);
    port (CLK, PROG, RST:in std_logic;
         ADDR_READ:in std_logic_vector((ADDRESS_LENGTH-1) downto 0);
         DATA_IN:in std_logic_vector((N_OF_BIT-1) downto 0);
         DATA_OUT:out std_logic_vector((N_OF_BIT-1) downto 0);
         FULL_MEM:out std_logic);
end program_memory;

architecture arch_program_memory of program_memory is

component ram is
	generic (ADDRESS_BIT: natural := 8; DATA_LINE_BIT: natural := 16);
	port (DATA_IN:in std_logic_vector((DATA_LINE_BIT-1) downto 0);
		WRITE, CLK:in std_logic;
		ADDR:in std_logic_vector((ADDRESS_BIT-1) downto 0);
		DATA_OUT:out std_logic_vector((DATA_LINE_BIT-1) downto 0));
end component ram;

component counter is
	generic (N_OF_BIT: natural := 8);
	port (CLK, EN, CLR, LD:in std_logic;
		LOAD:in std_logic_vector((N_OF_BIT-1) downto 0);
		Q:inout std_logic_vector((N_OF_BIT-1) downto 0);
		TC:out std_logic);
end component counter;

signal MEM_ADDR: std_logic_vector((ADDRESS_LENGTH-1) downto 0);
signal COUNTER_ADDR: std_logic_vector((ADDRESS_LENGTH-1) downto 0) := (others=>'0');

begin
    MEM_ADDR_PROC: process (PROG, ADDR_READ, COUNTER_ADDR)
    begin
        if PROG = '0' then
            MEM_ADDR <= ADDR_READ;
        else MEM_ADDR <= COUNTER_ADDR;
        end if;
    end process MEM_ADDR_PROC;
    
    RAM_MEM: ram generic map (ADDRESS_BIT => ADDRESS_LENGTH, DATA_LINE_BIT => N_OF_BIT) port map (DATA_IN, PROG, CLK, MEM_ADDR, DATA_OUT);
    COUNTER_MEM: counter generic map (N_OF_BIT => ADDRESS_LENGTH) port map (CLK, PROG, RST, '0', (others=>'0'), COUNTER_ADDR, FULL_MEM);
    
end arch_program_memory;
