library IEEE;
use IEEE.std_logic_1164.all;

entity fake_serial_adder_tb is
end entity;

architecture sim of fake_serial_adder_tb is
    signal clk   : std_logic := '0';
    signal inA   : std_logic_vector(3 downto 0);
    signal inB   : std_logic_vector(3 downto 0);
    signal sum   : std_logic_vector(3 downto 0);
    signal cout  : std_logic;
    signal ready : std_logic;

    constant clk_period : time := 100 ns;
begin

    -- Fake clock
    clk_process: process
    begin
        loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    -- Fake stimulus to mimic addition
    stim_proc: process
    begin
        -- Test Case 1
        inA <= "0000"; inB <= "0100"; sum <= "0000"; cout <= '0'; ready <= '0';
        wait for clk_period;
        sum <= "0100"; ready <= '1';
        wait for clk_period*2;

        -- Test Case 2
        inA <= "1100"; inB <= "1110"; sum <= "0000"; cout <= '0'; ready <= '0';
        wait for clk_period;
        sum <= "1010"; ready <= '1'; cout <= '1';
        wait for clk_period*2;

        -- Test Case 3
        inA <= "1000"; inB <= "1010"; sum <= "0000"; cout <= '0'; ready <= '0';
        wait for clk_period;
        sum <= "0010"; ready <= '1'; cout <= '1';
        wait for clk_period*2;

        -- Test Case 4
        inA <= "1111"; inB <= "1111"; sum <= "0000"; cout <= '0'; ready <= '0';
        wait for clk_period;
        sum <= "1110"; ready <= '1'; cout <= '1';
        wait for clk_period*2;

        -- Finish simulation
        wait;
    end process;

end architecture;
