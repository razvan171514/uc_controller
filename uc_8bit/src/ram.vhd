library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
	generic (ADDRESS_BIT: natural := 8; DATA_LINE_BIT: natural := 16);
	port (DATA_IN:in std_logic_vector((DATA_LINE_BIT-1) downto 0);
		WRITE, CLK:in std_logic;
		ADDR:in std_logic_vector((ADDRESS_BIT-1) downto 0);
		DATA_OUT:out std_logic_vector((DATA_LINE_BIT-1) downto 0));
end ram;

architecture arch_ram of ram is	
type memory is array (0 to (2**ADDRESS_BIT - 1)) of std_logic_vector((DATA_LINE_BIT-1) downto 0);
signal mem: memory := (others=>(others=>'0'));
begin		 
	RAM_PROC: process (CLK)
	variable part: std_logic_vector((DATA_LINE_BIT-1) downto 0); 
	variable addr_int: integer;
	begin	
		addr_int := to_integer(unsigned(ADDR));
		if CLK'EVENT and CLK = '1' then
            if WRITE = '0' then 
                part := mem(addr_int);
            else 
                part := DATA_IN;   
                mem(addr_int) <= DATA_IN;
            end if;	
		end if;					 
		DATA_OUT <= part;
	end process RAM_PROC;
end arch_ram;