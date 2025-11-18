library IEEE;
use IEEE.std_logic_1164.all;

entity inv is
    port (
        A : in std_logic;
        Y : out std_logic
    );
end inv;

architecture behavioral of inv is
begin
    Y <= not A after 2 ns;
end behavioral;
