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
    signal QA_reg, QB_reg, QC_reg, QD_reg : std_logic := '0';
begin

    QA <= QA_reg;
    QB <= QB_reg;
    QC <= QC_reg;
    QD <= QD_reg;

    process (Clear, Clock)
    begin
        -- Asynchronous clear
        if Clear = '0' then
            QA_reg <= '0' after 22 ns;
            QB_reg <= '0' after 22 ns;
            QC_reg <= '0' after 22 ns;
            QD_reg <= '0' after 22 ns;

        elsif rising_edge(Clock) then

            -- MODE decoding (S1 S0)
            case to_integer(unsigned(s1 & s0)) is
                when "1X" =>
                    -- hold - do nothing (retain values)
                when "11" =>
                    QA_reg <= A after 22 ns;
                    QB_reg <= B after 22 ns;
                    QC_reg <= C after 22 ns;
                    QD_reg <= D after 22 ns;

                when "10" =>
                    QA_reg <= SR     after 22 ns;
                    QB_reg <= QA_reg after 22 ns;
                    QC_reg <= QB_reg after 22 ns;
                    QD_reg <= QC_reg after 22 ns;

                when "01" =>
                    QD_reg <= SL     after 22 ns;
                    QC_reg <= QD_reg after 22 ns;
                    QB_reg <= QC_reg after 22 ns;
                    QA_reg <= QB_reg after 22 ns;

                when others =>
                    null;
            end case;
        end if;

    end process;
end behv;
