library ieee;
use ieee.std_logic_1164.all;

entity mux_16_to_1_1bit is
	generic (N_OF_ADDRESS_LINES: natural := 4);
	port (X:in std_logic_vector(15 downto 0);
		SEL:in std_logic_vector(3 downto 0);
		Y:out std_logic);
end mux_16_to_1_1bit;

architecture arch_mux_16_to_1_1bit of mux_16_to_1_1bit is
begin
	MUX_PROC: process (X, SEL)
	begin				 		   
		case SEL is
		  when "0000" => Y <= X(0);
		  when "0001" => Y <= X(1);
		  when "0010" => Y <= X(2);
		  when "0011" => Y <= X(3);
		  when "0100" => Y <= X(4);
		  when "0101" => Y <= X(5);
		  when "0110" => Y <= X(6);
		  when "0111" => Y <= X(7);
		  when "1000" => Y <= X(8);
          when "1001" => Y <= X(9);
          when "1010" => Y <= X(10);
          when "1011" => Y <= X(11);
          when "1100" => Y <= X(12);
          when "1101" => Y <= X(13);
          when "1110" => Y <= X(14);
          when "1111" => Y <= X(15); 
		  when others => Y <= '0';
		end case;
	end process MUX_PROC;
end arch_mux_16_to_1_1bit;