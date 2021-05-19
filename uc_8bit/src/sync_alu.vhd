library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync_alu is
    generic (N_OF_BIT: natural := 8);
    port (CLK, RST, LOAD_A, LOAD_RES, LOAD_EN, CRY:in std_logic;
        OPERAND:in std_logic_vector((N_OF_BIT-1) downto 0);
        OP_SEL:in std_logic_vector(2 downto 0);
        RESULT:out std_logic_vector((N_OF_BIT-1) downto 0);
        C_F, O_F, P_F, Z_F:out std_logic);
end sync_alu;

architecture arch_sync_alu of sync_alu is

component alu is
	generic (N_OF_BIT: natural := 8);
	port (A, B:in unsigned((N_OF_BIT-1) downto 0);
		OP_SEL:in std_logic_vector(2 downto 0);	 
		CY:in std_logic;
		Y:inout unsigned((N_OF_BIT-1) downto 0);
		C_F, O_F, P_F, Z_F:out std_logic);
end component alu;

component load_register is
	generic (N_OF_BIT: natural := 8);
	port (LOAD:in std_logic_vector((N_OF_BIT-1) downto 0);
		CLK, LD, CLR:in std_logic;
		Q:out std_logic_vector((N_OF_BIT-1) downto 0));
end component load_register;

signal A, B, RES:std_logic_vector((N_OF_BIT-1) downto 0);
signal A_OUT, B_OUT:std_logic_vector((N_OF_BIT-1) downto 0);
signal LOAD_B, LOAD_A_ACT:std_logic;

begin

    LOAD_B <= LOAD_EN and (not LOAD_A);
    LOAD_A_ACT <= LOAD_EN and LOAD_A;

    REG_A: load_register generic map (N_OF_BIT => N_OF_BIT) port map (OPERAND, CLK, LOAD_A_ACT, RST, A_OUT);
    REG_B: load_register generic map (N_OF_BIT => N_OF_BIT) port map (OPERAND, CLK, LOAD_B, RST, B_OUT);
    ALU_COMP: alu generic map (N_OF_BIT => N_OF_BIT) port map (unsigned(A_OUT), unsigned(B_OUT), OP_SEL, CRY, unsigned(RES), C_F, O_F, P_F, Z_F);
    REG_RES: load_register generic map (N_OF_BIT => N_OF_BIT) port map (RES, CLK, LOAD_RES, RST, RESULT);
end arch_sync_alu;
