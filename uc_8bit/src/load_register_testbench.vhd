library ieee;
use ieee.std_logic_1164.all;

entity load_register_testbench is
end load_register_testbench;

architecture arch_load_register_testbench of load_register_testbench is	

component load_register is
	generic (N_OF_BIT: natural := 8);
	port (LOAD:in std_logic_vector((N_OF_BIT-1) downto 0);
		CLK, LD, CLR:in std_logic;
		Q:out std_logic_vector((N_OF_BIT-1) downto 0));
end component load_register;

shared variable END_TEST: boolean := false;

signal CLK, LD, CLR:std_logic;
signal LOAD, Q:	std_logic_vector(7 downto 0);

constant CLK_PERIOD: time := 100 ns;

begin 
	UUT: load_register port map (LOAD, CLK, LD, CLR, Q);
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
	begin			
		LOAD <= "00000010";
		CLR <= '0';
		LD <= '0';
		wait for CLK_PERIOD;
		CLR <= '1';
		wait for CLK_PERIOD;
		CLR <= '0';
		LD <= '1';
		wait for CLK_PERIOD;
		LD <= '0';
		wait for CLK_PERIOD;
		LOAD <= "00000110";
		wait for CLK_PERIOD;
		LD <= '1';
		wait for CLK_PERIOD;
		END_TEST := true;
		wait;
	end process STIMULI_GENERATOR; 
	
end arch_load_register_testbench;