library IEEE;
use IEEE.std_logic_1164.all;

entity fake_serial_adder_tb is
end entity;

architecture sim of fake_serial_adder_tb is
    signal clk   : std_logic := '0';
    signal inA   : std_logic_vector(3 downto 0);
    signal inB   : std_logic_vector(3 downto 0);
    signal sum   : std_logic_vector(3 downto 0);
    signal carry : std_logic;
    signal ready : std_logic;

    constant clk_period : time := 100 ns;
begin

    ------------------------------------------------------------------------
    -- Clock generation
    ------------------------------------------------------------------------
    clk_process: process
    begin
        loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    ------------------------------------------------------------------------
    -- Stimulus process
    ------------------------------------------------------------------------
    stim_proc: process
    begin
        -- Reset state
        inA   <= "0000"; inB <= "0000"; sum <= "0000"; carry <= '0'; ready <= '0';
        wait for clk_period;

        -- Test Case 1: 0 + 4 = 4
        inA   <= "0000"; inB <= "0100"; sum <= "0000"; carry <= '0'; ready <= '0';
        wait for clk_period;
        sum   <= "0100"; carry <= '0'; ready <= '1';
        wait for clk_period*2;

        -- Test Case 2: 1100 + 1110 = 1010 with carry
        inA   <= "1100"; inB <= "1110"; sum <= "0000"; carry <= '0'; ready <= '0';
        wait for clk_period;
        sum   <= "1010"; carry <= '1'; ready <= '1';
        wait for clk_period*2;

        -- Test Case 3: 1000 + 1010 = 0010 with carry
        inA   <= "1000"; inB <= "1010"; sum <= "0000"; carry <= '0'; ready <= '0';
        wait for clk_period;
        sum   <= "0010"; carry <= '1'; ready <= '1';
        wait for clk_period*2;

        -- Test Case 4: 1111 + 1111 = 1110 with carry
        inA   <= "1111"; inB <= "1111"; sum <= "0000"; carry <= '0'; ready <= '0';
        wait for clk_period;
        sum   <= "1110"; carry <= '1'; ready <= '1';
        wait for clk_period*2;

        -- Test Case 5: 1111 + 0001 = 0000 with carry
        inA   <= "1111"; inB <= "0001"; sum <= "0000"; carry <= '0'; ready <= '0';
        wait for clk_period;
        sum   <= "0000"; carry <= '1'; ready <= '1';
        wait for clk_period*2;

        -- Test Case 6: 1010 + 0101 = 0010 (intentionally wrong)
        inA   <= "1010"; inB <= "0101"; sum <= "0000"; carry <= '0'; ready <= '0';
        wait for clk_period;
        sum   <= "0010"; carry <= '0'; ready <= '1';
        wait for clk_period*2;

        -- Test Case 7: 1000 + 0111 = 1111
        inA   <= "1000"; inB <= "0111"; sum <= "0000"; carry <= '0'; ready <= '0';
        wait for clk_period;
        sum   <= "1111"; carry <= '0'; ready <= '1';
        wait for clk_period*2;

        -- End simulation
        wait;
    end process;

end architecture;
