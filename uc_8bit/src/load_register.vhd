library ieee;
use ieee.std_logic_1164.all;

entity load_register is
	generic (N_OF_BIT: natural := 8);
	port (LOAD:in std_logic_vector((N_OF_BIT-1) downto 0);
		CLK, LD, CLR:in std_logic;
		Q:out std_logic_vector((N_OF_BIT-1) downto 0));
end load_register;

architecture arch_load_register of load_register is
begin
	LOAD_REG_PROC: process (CLK, CLR)
	variable temp: std_logic_vector((N_OF_BIT-1) downto 0) := (others=>'X');
	begin	  									
		if CLR = '1' then
			temp := (others=>'0');
		elsif CLK'EVENT and CLK = '1' then
			if LD = '1' then
				temp := LOAD;
			else temp := temp;
			end if;
		end if;
		Q <= temp;
	end process LOAD_REG_PROC;								  
end arch_load_register;