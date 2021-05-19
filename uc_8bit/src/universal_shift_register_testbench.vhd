library ieee;
use ieee.std_logic_1164.all;

entity universal_shift_register_testbench is
end universal_shift_register_testbench;

architecture arch_universal_shift_register_testbench of universal_shift_register_testbench is

component universal_shift_register is
	generic (N_OF_BIT: natural := 8);
	port (CLK, EN, CLR:in std_logic;
		LOAD:in std_logic_vector((N_OF_BIT-1) downto 0);
		OP_SEL:in std_logic_vector(1 downto 0);
		SI:in std_logic;
		Q:out std_logic_vector((N_OF_BIT-1) downto 0));
end component universal_shift_register;

shared variable END_TEST: boolean := false;

signal CLK, EN, SI:std_logic;
signal LOAD, Q:std_logic_vector(7 downto 0); 
signal OP_SEL:std_logic_vector(1 downto 0);

constant CLK_PERIOD: time := 100 ns;

begin  
	UUT: universal_shift_register port map (CLK, EN, '0', LOAD, OP_SEL, SI, Q); 
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
		LOAD <= "00000110";
		EN <= '0';
		OP_SEL <= "11";	
		SI <= '0';
		wait for CLK_PERIOD;
		EN <= '1';
		wait for CLK_PERIOD;
		OP_SEL <= "00";
		wait for CLK_PERIOD;
		OP_SEL <= "01";
		SI <= '1';
		wait for CLK_PERIOD;
		OP_SEL <= "01";
		SI <= '0';
		wait for CLK_PERIOD;
		OP_SEL <= "10";
		SI <= '0';
		wait for CLK_PERIOD;
		OP_SEL <= "10";
		SI <= '1';
		wait for CLK_PERIOD;
		END_TEST := true;
		wait;
	end process STIMULI_GENERATOR;
	
end arch_universal_shift_register_testbench;