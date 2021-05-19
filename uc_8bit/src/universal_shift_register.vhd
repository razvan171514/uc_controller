library ieee;
use ieee.std_logic_1164.all;

-- OP_SEL: operation select
-- 00 -> HOLD
-- 01 -> SHIFT LEFT
-- 10 -> SHIFT RIGHT 
-- 11 -> LOAD

entity universal_shift_register is
	generic (N_OF_BIT: natural := 8);
	port (CLK, EN, CLR:in std_logic;
		LOAD:in std_logic_vector((N_OF_BIT-1) downto 0);
		OP_SEL:in std_logic_vector(1 downto 0);
		SI:in std_logic;
		Q:out std_logic_vector((N_OF_BIT-1) downto 0));
end universal_shift_register;

architecture arch_universal_shift_register of universal_shift_register is
begin
	UNIVERSAL_SH_REG_PROC: process (CLK, EN, CLR)
	variable memory: std_logic_vector((N_OF_BIT-1) downto 0) := (others=>'X');
	begin
	    if CLR = '1' then
	       memory := (others=>'0');	   
		elsif EN = '1' then
            if CLK'EVENT and CLK = '1' then
                case OP_SEL is
                    when "00" => null;		 
                    when "01" => memory := memory((N_OF_BIT-2) downto 0) & SI;
                    when "10" => memory := SI & memory((N_OF_BIT-1) downto 1);
                    when "11" => memory := LOAD;
                    when others => memory := (others=>'0');
                end case;
            end if;
		end if;	
		Q <= memory;
	end process UNIVERSAL_SH_REG_PROC; 
end arch_universal_shift_register;