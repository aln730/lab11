library IEEE;
use IEEE.std_logic_1164.all;

entity DM74LS194A is
    port (
        Clear : in  std_logic;
        S1, S0 : in std_logic;
        Clock  : in std_logic;
        SL, SR : in std_logic;        -- Serial inputs
        A, B, C, D : in std_logic;    -- Parallel inputs
        QA, QB, QC, QD : out std_logic
    );
end DM74LS194A;

architecture behavioral of DM74LS194A is
    signal q : std_logic_vector(3 downto 0);
begin

    process (Clock, Clear)
    begin
        -- asynchronous clear
        if Clear = '0' then
            q <= (others => '0') after 22 ns;

        -- rising-edge functionality
        elsif rising_edge(Clock) then

            case (S1 & S0) is

                when "11" =>              -- Parallel load
                    q <= A & B & C & D after 22 ns;

                when "01" =>              -- Shift right
                    q <= SR & q(3 downto 1) after 22 ns;

                when "10" =>              -- Shift left
                    q <= q(2 downto 0) & SL after 22 ns;

                when others =>            -- Hold
                    q <= q after 22 ns;

            end case;
        end if;
    end process;

    -- Outputs
    QA <= q(3);
    QB <= q(2);
    QC <= q(1);
    QD <= q(0);

end behavioral;