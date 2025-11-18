library IEEE;
use IEEE.std_logic_1164.all;

entity full_adder is
    port (
        A, B, Cin : in std_logic;
        Sum, Cout : out std_logic
    );
end full_adder;

architecture behavioral of full_adder is
begin
    Sum  <= A xor B xor Cin after 8 ns;
    Cout <= (A and B) or (Cin and (A xor B)) after 8 ns;
end behavioral;
