library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_register is
	generic (ADDR_LEN: natural := 4; N_OF_BIT: natural := 8);	
	port (CLK, WE, CLR:in std_logic;
		ADDR:in std_logic_vector((ADDR_LEN-1) downto 0);
		DATA_IN:in std_logic_vector((N_OF_BIT-1) downto 0);
		DATA_OUT:out std_logic_vector((N_OF_BIT-1) downto 0);
		PORT_ID:out std_logic_vector((ADDR_LEN-1) downto 0));
end cpu_register;

architecture arch_cpu_register of cpu_register is 
type memory is array (0 to (2**ADDR_LEN - 1)) of std_logic_vector((N_OF_BIT-1) downto 0);
begin
	CPU_REG_PROC: process (CLK, CLR)
	variable mem: memory := (others=>(others=>'0'));
	variable addr_int: integer := 0;
	variable temp: std_logic_vector((N_OF_BIT-1) downto 0);
	variable acc_port: std_logic_vector((ADDR_LEN-1) downto 0);
	begin						   
		if CLR = '1' then
			for i in 0 to (2**ADDR_LEN - 1) loop 
				mem(i) := (others=>'0');
			end loop;	  
			temp := (others=>'0');
			acc_port := (others=>'0');
		elsif CLK'EVENT and CLK = '1' then
			addr_int := to_integer(unsigned(ADDR));
			if WE = '1' then
				mem(addr_int) := DATA_IN;
			end if;
			temp := mem(addr_int);
			acc_port := ADDR;
		end if;
		DATA_OUT <= temp;
		PORT_ID <= acc_port;
	end process CPU_REG_PROC;
end arch_cpu_register;