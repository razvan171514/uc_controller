library ieee;
use ieee.std_logic_1164.all;

-- SEL: operation select
-- 01000 -> SL0
-- 01001 -> SL1
-- 01010 -> SLX
-- 01011 -> SLA
-- 01100 -> RL
-----------------
-- 10000 -> SR0
-- 10001 -> SR1
-- 10010 -> SRX
-- 10011 -> SRA
-- 10100 -> RR

entity slu is
	generic (N_OF_BIT: natural := 8);
	port (CLK, EN, CLR:in std_logic;
		LOAD:in std_logic_vector((N_OF_BIT-1) downto 0);
		OP_SEL:in std_logic_vector(4 downto 0);
		Q:inout std_logic_vector((N_OF_BIT-1) downto 0);
		C_F, Z_F:out std_logic);
end slu;

architecture arch_slu of slu is	

component mux_16_to_1_1bit is
	generic (N_OF_ADDRESS_LINES: natural := 4);
	port (X:in std_logic_vector(15 downto 0);
		SEL:in std_logic_vector(3 downto 0);
		Y:out std_logic);
end component mux_16_to_1_1bit;

component universal_shift_register_with_cry is
	generic (N_OF_BIT: natural := 8);
	port (CLK, EN, CLR:in std_logic;
		LOAD:in std_logic_vector((N_OF_BIT-1) downto 0);
		OP_SEL:in std_logic_vector(1 downto 0);
		SI:in std_logic;
		Q:out std_logic_vector((N_OF_BIT-1) downto 0);
		C_F:out std_logic);
end component universal_shift_register_with_cry;

signal X_INP: std_logic_vector(15 downto 0);
signal SI_PART: std_logic;
signal MUX_SEL: std_logic_vector(3 downto 0);

begin
    MUX_SEL <= OP_SEL(4) & OP_SEL(2 downto 0);
	X_INP <= "000" & Q(1) & Q(0) & Q(N_OF_BIT-1) & "10000" & Q(N_OF_BIT-2) & Q(N_OF_BIT-1) & Q(0) & "10"; 
	
	MUX: mux_16_to_1_1bit port map (X_INP, MUX_SEL, SI_PART);
	U_SH_R: universal_shift_register_with_cry generic map (N_OF_BIT) port map (CLK, EN, CLR, LOAD, OP_SEL(4 downto 3), SI_PART, Q, C_F);
	
	Z_F_PROC: process (Q)
	constant zero: std_logic_vector((N_OF_BIT-1) downto 0) := (others=>'0');
	begin
		Z_F <= '0';
		if Q = zero then
			Z_F <= '1';
		end if;
	end process Z_F_PROC;
end arch_slu;