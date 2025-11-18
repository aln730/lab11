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

architecture behv of DM74LS194A is
    signal q : std_logic_vector(3 downto 0);
begin

    process(Clear)
    begin
        if Clear = '0' then
            q <= (others => '0') after 22 ns;
        end if;
    end process;

    process(Clock)
        variable mode : std_logic_vector(1 downto 0);
    begin
        if rising_edge(Clock) then

            mode := S1 & S0;

            case mode is

                when "11" =>        -- Parallel Load
                    q <= A & B & C & D after 22 ns;

                when "01" =>        -- Shift Right
                    q <= SR & q(3 downto 1) after 22 ns;

                when "10" =>        -- Shift Left
                    q <= q(2 downto 0) & SL after 22 ns;

                when others =>      -- Hold
                    q <= q after 22 ns;

            end case;

        end if;
    end process;

    QA <= q(3);
    QB <= q(2);
    QC <= q(1);
    QD <= q(0);

end architecture behv;
