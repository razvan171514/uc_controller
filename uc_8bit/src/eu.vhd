library ieee;
use ieee.std_logic_1164.all;

entity eu is
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
end eu;

architecture arch_eu of eu is

component cpu_register is
	generic (ADDR_LEN: natural := 4; N_OF_BIT: natural := 8);	
	port (CLK, WE, CLR:in std_logic;
		ADDR:in std_logic_vector((ADDR_LEN-1) downto 0);
		DATA_IN:in std_logic_vector((N_OF_BIT-1) downto 0);
		DATA_OUT:out std_logic_vector((N_OF_BIT-1) downto 0);
		PORT_ID:out std_logic_vector((ADDR_LEN-1) downto 0));
end component cpu_register;

component sync_alu is
    generic (N_OF_BIT: natural := 8);
    port (CLK, RST, LOAD_A, LOAD_RES, LOAD_EN, CRY:in std_logic;
        OPERAND:in std_logic_vector((N_OF_BIT-1) downto 0);
        OP_SEL:in std_logic_vector(2 downto 0);
        RESULT:out std_logic_vector((N_OF_BIT-1) downto 0);
        C_F, O_F, P_F, Z_F:out std_logic);
end component sync_alu;

component slu is
	generic (N_OF_BIT: natural := 8);
	port (CLK, EN, CLR:in std_logic;
		LOAD:in std_logic_vector((N_OF_BIT-1) downto 0);
		OP_SEL:in std_logic_vector(4 downto 0);
		Q:inout std_logic_vector((N_OF_BIT-1) downto 0);
		C_F, Z_F:out std_logic);
end component slu;

component stack is
	generic (MEM_LEN: natural := 256; N_OF_BIT: natural := 8);
	port (CLK, CLR: in std_logic;
		DATA_IN:in std_logic_vector((N_OF_BIT-1) downto 0);
		PUSH, POP:in std_logic;
		DATA_OUT: out std_logic_vector((N_OF_BIT-1) downto 0));
end component stack;

component load_register is
	generic (N_OF_BIT: natural := 8);
	port (LOAD:in std_logic_vector((N_OF_BIT-1) downto 0);
		CLK, LD, CLR:in std_logic;
		Q:out std_logic_vector((N_OF_BIT-1) downto 0));
end component load_register;

component bcd_7sd is
	port (x:in std_logic_vector(3 downto 0); 
	   y:out std_logic_vector(6 downto 0));
end component bcd_7sd;

signal ALU_DATA_OUT, SLU_DATA_OUT, STACK_DATA_OUT:std_logic_vector((N_OF_BIT-1) downto 0);
signal CPU_DATA_IN, CPU_DATA_OUT:std_logic_vector((N_OF_BIT-1) downto 0);
signal ALU_C_F, ALU_Z_F, SLU_C_F, SLU_Z_F: std_logic;
signal STACK_PUSH, STACK_POP: std_logic;
signal FLAGS, FLAGS_OUT: std_logic_vector(3 downto 0);
signal OUT_C_F, OUT_Z_F, OUT_P_F, OUT_O_F: std_logic;
signal DISPLAY: std_logic_vector((N_OF_BIT-1) downto 0);
signal CA_SEG_DISP, CC_SEG_DISP: std_logic_vector((7*(N_OF_BIT/4)-1) downto 0);

begin

    CPU_REG_DATA_SEL: process (INPUT, ALU_DATA_OUT, SLU_DATA_OUT, STACK_DATA_OUT, OP_SEL(6 downto 5))
    begin
        case OP_SEL(6 downto 5) is
            when "00" => CPU_DATA_IN <= INPUT;
            when "01" => CPU_DATA_IN <= ALU_DATA_OUT;
            when "10" => CPU_DATA_IN <= SLU_DATA_OUT;
            when "11" => CPU_DATA_IN <= STACK_DATA_OUT;
            when others => CPU_DATA_IN <= (others=>'0');
        end case; 
    end process CPU_REG_DATA_SEL;

    ST_PUSH_POP_PROC: process (OP_SEL(6 downto 5), OP_SEL(1 downto 0))
    begin
        if OP_SEL(6 downto 5) = "11" then
            STACK_PUSH <= OP_SEL(1);
            STACK_POP <= OP_SEL(0);
        else
            STACK_PUSH <= '0';
            STACK_POP <= '0';
        end if;
    end process ST_PUSH_POP_PROC;

    CPU_REG: cpu_register generic map(ADDR_LEN => ADDR_LEN, N_OF_BIT => N_OF_BIT) port map (CLK, WE, RST, ADDR, CPU_DATA_IN, CPU_DATA_OUT, PORT_ID);
    SLU_COMP: slu generic map (N_OF_BIT => N_OF_BIT) port map (CLK, '1', RST, CPU_DATA_OUT, OP_SEL(4 downto 0), SLU_DATA_OUT, SLU_C_F, SLU_Z_F);
    ALU_COMP: sync_alu generic map (N_OF_BIT => N_OF_BIT) port map (CLK, RST, LOAD_A, LOAD_RES, LOAD_EN, C_F, CPU_DATA_OUT, OP_SEL(2 downto 0), ALU_DATA_OUT, ALU_C_F, OUT_O_F, OUT_P_F, ALU_Z_F);
    STACK_COMP: stack generic map (MEM_LEN => STACK_LENGTH, N_OF_BIT => N_OF_BIT) port map (CLK, RST, CPU_DATA_OUT, STACK_PUSH, STACK_POP, STACK_DATA_OUT);
    
    FLAGS <= OUT_C_F & OUT_O_F & OUT_P_F & OUT_Z_F;
    FLAG_REG: load_register generic map (N_OF_BIT => 4) port map (FLAGS, CLK, LOAD_F, RST, FLAGS_OUT);
    
    C_F <= FLAGS_OUT(0);
    O_F <= FLAGS_OUT(1);
    P_F <= FLAGS_OUT(2);
    Z_F <= FLAGS_OUT(3);
    
    DISPLAY_REG: load_register generic map (N_OF_BIT => N_OF_BIT) port map (CPU_DATA_OUT, CLK, LOAD_DISP, RST, DISPLAY);
    
    BCD_OUT <= DISPLAY;
    
    BCD_GEN: for i in 1 to (N_OF_BIT/4) generate
        BCD_COMP: bcd_7sd port map (DISPLAY((4*i)-1 downto 4*(i-1)), CA_SEG_DISP((7*i)-1 downto 7*(i-1)));
    end generate BCD_GEN; 
    
    CC_SEG_DISP <= not CA_SEG_DISP;
    
    SEG_DISP_SEL: process (CA, CA_SEG_DISP, CC_SEG_DISP)
    begin
        SEG_DISP <= (others=>'0');
        if CA = '1' then 
            SEG_DISP <= CA_SEG_DISP;
        else SEG_DISP <= CC_SEG_DISP;
        end if;
    end process SEG_DISP_SEL;
    
    Z_F_SEL: process (ALU_Z_F, SLU_Z_F, OP_SEL(6 downto 5))
    begin
        case OP_SEL(6 downto 5) is
            when "01" => OUT_Z_F <= ALU_Z_F;
            when "10" => OUT_Z_F <= SLU_Z_F;
            when others => OUT_Z_F <= '0';
        end case;
    end process Z_F_SEL;
    
    C_F_SEL: process (ALU_C_F, SLU_C_F, OP_SEL(6 downto 5))
    begin
        case OP_SEL(6 downto 5) is
            when "01" => OUT_C_F <= ALU_C_F;
            when "10" => OUT_C_F <= SLU_C_F;
            when others => OUT_C_F <= '0';
        end case;
    end process C_F_SEL;
        
end arch_eu;
