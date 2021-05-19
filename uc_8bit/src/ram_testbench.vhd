library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_testbench is
end ram_testbench;

architecture arch_ram_testbench of ram_testbench is	  

component ram is
	generic (ADDRESS_BIT: natural := 8; DATA_LINE_BIT: natural := 16);
	port (DATA_IN:in std_logic_vector((DATA_LINE_BIT-1) downto 0);
		WRITE, CLK:in std_logic;
		ADDR:in std_logic_vector((ADDRESS_BIT-1) downto 0);
		DATA_OUT:out std_logic_vector((DATA_LINE_BIT-1) downto 0));
end component ram;

shared variable END_TEST: boolean := false;	 

signal CLK, WRITE:std_logic;
signal DATA_IN, DATA_OUT:std_logic_vector(15 downto 0);
signal ADDR:std_logic_vector(7 downto 0);

constant CLK_PERIOD: time := 100 ns;

begin
	UUT: ram port map (DATA_IN, WRITE, CLK, ADDR, DATA_OUT);
	CLK_GENERATOR: process
	begin
		if not END_TEST then
			CLK <= '1';
			wait for CLK_PERIOD / 2;
			CLK <= '0';
			wait for CLK_PERIOD / 2;
		else wait;
		end if;		 
	end process CLK_GENERATOR; 
	
	STIMULI_GENERATOR: process					
	variable data: integer := 12;  
	variable addr_int: integer := 0;
	begin	
		
		WRITE <= '1';
		ADDR <= std_logic_vector(to_unsigned(addr_int, ADDR'LENGTH));
		DATA_IN <= std_logic_vector(to_unsigned(data, DATA_IN'LENGTH));
		wait for CLK_PERIOD;										   
		data := data+1;
		addr_int := addr_int+1;
		ADDR <= std_logic_vector(to_unsigned(addr_int, ADDR'LENGTH));
		DATA_IN <= std_logic_vector(to_unsigned(data, DATA_IN'LENGTH));
		wait for CLK_PERIOD;										   
		data := data+1;
		addr_int := addr_int+1;									   
		ADDR <= std_logic_vector(to_unsigned(addr_int, ADDR'LENGTH));
		DATA_IN <= std_logic_vector(to_unsigned(data, DATA_IN'LENGTH));
		wait for CLK_PERIOD;
		data := data+1;
		addr_int := addr_int+1;									   
		ADDR <= std_logic_vector(to_unsigned(addr_int, ADDR'LENGTH));
		DATA_IN <= std_logic_vector(to_unsigned(data, DATA_IN'LENGTH));
		wait for CLK_PERIOD;
		data := data+1;
		addr_int := addr_int+1;									   
		ADDR <= std_logic_vector(to_unsigned(addr_int, ADDR'LENGTH));
		DATA_IN <= std_logic_vector(to_unsigned(data, DATA_IN'LENGTH));
		wait for CLK_PERIOD;
		data := data+1;
		addr_int := addr_int+1;									   
		ADDR <= std_logic_vector(to_unsigned(addr_int, ADDR'LENGTH));
		DATA_IN <= std_logic_vector(to_unsigned(data, DATA_IN'LENGTH));
		wait for CLK_PERIOD;
		
		WRITE <= '0';
		ADDR <= std_logic_vector(to_unsigned(addr_int, ADDR'LENGTH));
		wait for CLK_PERIOD;										 
		addr_int := addr_int-1;
		ADDR <= std_logic_vector(to_unsigned(addr_int, ADDR'LENGTH));
		wait for CLK_PERIOD;										 
		addr_int := addr_int-1;
		ADDR <= std_logic_vector(to_unsigned(addr_int, ADDR'LENGTH));
		wait for CLK_PERIOD;										 
		addr_int := addr_int-1;
		ADDR <= std_logic_vector(to_unsigned(addr_int, ADDR'LENGTH));
		wait for CLK_PERIOD;										 
		addr_int := addr_int-1;
		ADDR <= std_logic_vector(to_unsigned(addr_int, ADDR'LENGTH));
		wait for CLK_PERIOD;										 
		addr_int := addr_int-1;
		ADDR <= std_logic_vector(to_unsigned(addr_int, ADDR'LENGTH));
		wait for CLK_PERIOD;
		
		END_TEST := true;
		wait;
	end process STIMULI_GENERATOR;	 
	
end arch_ram_testbench;