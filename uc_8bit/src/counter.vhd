library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity counter is
	generic (N_OF_BIT: natural := 8);
	port (CLK, EN, CLR, LD:in std_logic;
		LOAD:in std_logic_vector((N_OF_BIT-1) downto 0);
		Q:inout std_logic_vector((N_OF_BIT-1) downto 0);
		TC:out std_logic);
end counter;			  

architecture arch_counter of counter is
begin			 
	COUNTER_PROC: process (CLK, CLR, EN, LD)
	variable count: std_logic_vector((N_OF_BIT-1) downto 0) := (others=>'X');	
	begin	
	    				 
		if CLR = '1' then		
			count := (others=>'0');
		elsif LD = '1' then
		    count := LOAD;
		elsif EN = '1' then
            if CLK'EVENT and CLK = '1' then
                count := count+1;
            end if;	
		end if;
		Q <= count;
	end process COUNTER_PROC;
	
	TC_PROC: process (Q)
	variable terminal_count: std_logic;
	constant control: std_logic_vector((N_OF_BIT-1) downto 0) := (others=>'1');
	begin
	   terminal_count := '0';
	   if Q = control then
            terminal_count := '1';
       else terminal_count := '0';
       end if;
       TC <= terminal_count;
    end process TC_PROC;
    
end arch_counter;