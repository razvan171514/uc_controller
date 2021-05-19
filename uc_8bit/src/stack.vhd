library ieee;
use ieee.std_logic_1164.all;

entity stack is
	generic (MEM_LEN: natural := 256; N_OF_BIT: natural := 8);
	port (CLK, CLR: in std_logic;
		DATA_IN:in std_logic_vector((N_OF_BIT-1) downto 0);
		PUSH, POP:in std_logic;
		DATA_OUT: out std_logic_vector((N_OF_BIT-1) downto 0));
end stack;

architecture arch_stack of stack is
type memory is array (0 to (MEM_LEN-1)) of std_logic_vector((N_OF_BIT-1) downto 0);
signal mem:memory := (others=>(others=>'0'));
begin
	STACK_PROC: process (CLK, CLR)
	variable data_temp: std_logic_vector((N_OF_BIT-1) downto 0);
	variable push_pop: std_logic_vector(1 downto 0);
	begin
		if CLR = '1' then
			data_temp := (others=>'0');
		elsif CLK'EVENT and CLK = '1' then																					   
			push_pop := PUSH & POP;
			case push_pop is	
				when "10" => 
					for i in (MEM_LEN-2) downto 0 loop
						mem(i+1) <= mem(i);
					end loop;
					mem(0) <= DATA_IN;
					data_temp := DATA_IN;
				when "01" =>			 
					data_temp := mem(0);
					for i in 1 to (MEM_LEN-1) loop
						mem(i-1) <= mem(i);
					end loop;
				when others => null;
			end case;
		end if;
		DATA_OUT <= data_temp;
	end process STACK_PROC;
end arch_stack;