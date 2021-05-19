library ieee;
use ieee.std_logic_1164.all;

entity counter_testbench is
end counter_testbench;

architecture arch_counter_testbench of counter_testbench is

component counter is
	generic (N_OF_BIT: natural := 8);
	port (CLK, EN, CLR, LD:in std_logic;
		LOAD:in std_logic_vector((N_OF_BIT-1) downto 0);
		Q:inout std_logic_vector((N_OF_BIT-1) downto 0);
		TC:out std_logic);
end component counter;	

shared variable END_TEST: boolean := false;

signal CLK, EN, CLR, LD, TC:std_logic;
signal LOAD, Q:std_logic_vector(7 downto 0);

constant CLK_PERIOD: time := 100 ns;

begin		  
	UUT: counter port map (CLK, EN, CLR, LD, LOAD, Q, TC);
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
		EN <= '0';
		CLR <= '0';
		LD <= '0';
		wait for CLK_PERIOD;
		EN <= '1';
		wait for CLK_PERIOD;
		CLR <= '1';
		wait for CLK_PERIOD;
		CLR <= '0';
		wait for CLK_PERIOD;
		
		for i in 0 to 210 loop	
			wait for CLK_PERIOD;	
		end loop;
		
		LD <= '1';
		wait for CLK_PERIOD;
		LD <= '0';
		wait for CLK_PERIOD;
		wait for CLK_PERIOD;
		wait for CLK_PERIOD;
		
		for i in 0 to 255 loop	
			wait for CLK_PERIOD;	
		end loop;
		
		wait for CLK_PERIOD;
		END_TEST := true;
		wait;
	end process STIMULI_GENERATOR;
	
end arch_counter_testbench;