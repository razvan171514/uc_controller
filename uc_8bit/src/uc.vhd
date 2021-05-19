library ieee;
use ieee.std_logic_1164.all;

entity uc is
    port (CLK, PROG, RST, CA:in std_logic;
        INSTRUCTION_IN:in std_logic_vector(16 downto 0);
        PORT_ID:out std_logic_vector(3 downto 0);
        O_F, P_F, Z_F:out std_logic;
        C_F:inout std_logic;
        SEG_OUT:out std_logic_vector(13 downto 0);
        BCD_OUT:out std_logic_vector(7 downto 0));
end uc;

architecture arch_uc of uc is

component cu is
    generic (CTRLS: natural := 18; INSTR_SIZE: natural := 17; STEP_SIZE: natural := 4);
    port (CLK, PROG, RST:in std_logic;
        INSTRUCTION_IN:in std_logic_vector((INSTR_SIZE-1) downto 0);
        CONTROLS:inout std_logic_vector((CTRLS-1) downto 0);
        INPUT:out std_logic_vector(7 downto 0);
        ADDR:out std_logic_vector(3 downto 0));
end component cu;

component eu is
    generic (N_OF_BIT: natural := 8; ADDR_LEN: natural := 4; STACK_LENGTH: natural := 256);
    port (CLK, RST:in std_logic;
        WE:in std_logic;
        INPUT:in std_logic_vector((N_OF_BIT-1) downto 0);
        ADDR:in std_logic_vector((ADDR_LEN-1) downto 0);
        PORT_ID:out std_logic_vector((ADDR_LEN-1) downto 0);
        LOAD_A, LOAD_RES, LOAD_EN:in std_logic;
        O_F, P_F, Z_F:out std_logic;
        OP_SEL:in std_logic_vector(6 downto 0);
        C_F:inout std_logic;
        LOAD_F, LOAD_DISP:in std_logic;
        SEG_DISP:out std_logic_vector((7*(N_OF_BIT/4)-1) downto 0);
        BCD_OUT:out std_logic_vector((N_OF_BIT-1) downto 0);
        CA:in std_logic);
end component eu;

signal CONTROLS: std_logic_vector(17 downto 0);
signal DATA_INPUT: std_logic_vector(7 downto 0);
signal ADDRESS: std_logic_vector(3 downto 0);

begin

    COMMAND_UNIT: cu port map (CLK, PROG, RST, INSTRUCTION_IN, CONTROLS, DATA_INPUT, ADDRESS);
    EXECUTION_UNIT: eu port map (CLK, CONTROLS(17), CONTROLS(16), DATA_INPUT, ADDRESS, PORT_ID, 
        CONTROLS(15), CONTROLS(13), CONTROLS(14), O_F, P_F, Z_F, CONTROLS(10 downto 4), C_F, CONTROLS(12), CONTROLS(11), SEG_OUT, BCD_OUT, CA);

end arch_uc;
