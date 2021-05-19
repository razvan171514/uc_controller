library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;	

-- OP_SEL: operation select
-- 000 -> AND
-- 001 -> OR
-- 010 -> XOR
-- 011 -> ADD
-- 100 -> ADDCY
-- 101 -> SUB
-- 110 -> SUBCY

entity alu is
	generic (N_OF_BIT: natural := 8);
	port (A, B:in unsigned((N_OF_BIT-1) downto 0);
		OP_SEL:in std_logic_vector(2 downto 0);	 
		CY:in std_logic;
		Y:inout unsigned((N_OF_BIT-1) downto 0);
		C_F, O_F, P_F, Z_F:out std_logic);
end alu;											  

architecture arch_alu of alu is
begin	
	
	ALU_PROC: process (A, B, CY, OP_SEL)
	variable carry: unsigned((N_OF_BIT-1) downto 0) := (others => '0');
	variable temp: unsigned((N_OF_BIT) downto 0) := (others => '0');
	variable cry_f, ovf_f: std_logic := '0';
	begin
	    carry := (others=>'0');  
	    cry_f := '0'; ovf_f := '0';
		case OP_SEL is
			when "000" => 
				temp := '0' & (A and B);
				cry_f := '0'; ovf_f := '0';
			when "001" => 
				temp := '0' & (A or B);
				cry_f := '0'; ovf_f := '0';
			when "010" => 
				temp := '0' & (A xor B); 
				cry_f := '0'; ovf_f := '0';
			when "011" => 
				temp := '0' & A + B;
				cry_f := temp(N_OF_BIT); ovf_f := '0';
			when "100" => 		
				carry := carry((N_OF_BIT-1) downto 1) & CY;
				temp := '0' & A + B + carry; 
				cry_f := temp(N_OF_BIT); ovf_f := '0';
			when "101" =>
				temp := ('0' & A) - ('0' & B);
				ovf_f := temp(N_OF_BIT); cry_f := '0';
			when "110" =>  
				carry := carry((N_OF_BIT-1) downto 1) & CY;
				temp := ('0' & A) - ('0' & B) - carry;
				ovf_f := temp(N_OF_BIT); cry_f := '0';
			when others => temp := (others => '0');
		end case;  
		Y <= temp((N_OF_BIT-1) downto 0); 
		C_F <= cry_f;  
		O_F <= ovf_f;
	end process ALU_PROC;	
	
	PARITY_PROC: process (Y)
	variable count: natural := 0;
	variable prt: std_logic := '0';
	begin						 
		count := 0;
		for i in (N_OF_BIT-1) downto 0 loop	
			if Y(i) = '1' then
				count := count+1;
			end if;
		end loop;  
		if (count mod 2) = 0 then
			prt := '1';
		else prt := '0';
		end if;
		P_F <= prt;
	end process PARITY_PROC;	   
	
	ZERO_PROC: process (Y)
	constant zero: unsigned((N_OF_BIT-1) downto 0) := (others => '0');
	begin	
	    Z_F <= '0';			 
		if Y = zero then
		    Z_F <= '1';
		else Z_F <= '0'; 
		end if;
	end process ZERO_PROC;
end arch_alu;