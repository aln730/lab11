library IEEE;
use IEEE.std_logic_1164.all;

entity dff is
    port (
        clk, clear, en : in std_logic;
        D : in std_logic;
        Q : out std_logic
    );
end dff;

architecture behavioral of dff is
    signal q_i : std_logic;
begin
    process(clk, clear)
    begin
        if clear = '0' then
            q_i <= '0' after 6 ns;

        elsif rising_edge(clk) then
            if en = '1' then
                q_i <= D after 6 ns;
            end if;
        end if;
    end process;
    Q <= q_i;
end behavioral;
