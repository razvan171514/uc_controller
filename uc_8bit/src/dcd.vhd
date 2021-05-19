library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dcd is
    generic (N_OF_BIT: natural := 4);
    port (X:in std_logic_vector((N_OF_BIT-1) downto 0);
        Y:out std_logic_vector((2**N_OF_BIT-1) downto 0));
end dcd;

architecture arch_dcd of dcd is
begin
    DCD_PROC: process (X)
    variable temp: std_logic_vector((2**N_OF_BIT-1) downto 0);
    variable x_int: integer;
    begin
        x_int := to_integer(unsigned(X));
        temp := (others=>'0');
        temp(x_int) := '1';
        Y <= temp;
    end process DCD_PROC;
end arch_dcd;
