library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_serial_adder is
end entity;

architecture behavioral of tb_serial_adder is

    -- Signals to connect to the UUT
    signal clk      : std_logic := '0';
    signal start    : std_logic := '0';
    signal clear_sm : std_logic := '0';
    signal inA      : std_logic_vector(3 downto 0);
    signal inB      : std_logic_vector(3 downto 0);
    signal sum      : std_logic_vector(3 downto 0);
    signal cout     : std_logic;
    signal ready    : std_logic;

    constant clk_period : time := 100 ns;

begin

    -- Instantiate the serial adder
    UUT: entity work.serial_adder_complete
        port map(
            clk      => clk,
            start    => start,
            clear_sm => clear_sm,
            inA      => inA,
            inB      => inB,
            sum      => sum,
            cout     => cout,
            ready    => ready
        );

    -- Clock generation
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset the design
        clear_sm <= '1';
        wait for clk_period;
        clear_sm <= '0';
        wait for clk_period;

        -- Test Case 1: 0000 + 0100 = 0100
        inA <= "0000"; inB <= "0100"; start <= '1';
        wait for clk_period;
        start <= '0';
        wait for clk_period*6; -- enough cycles for shifting
        assert sum = "0100" and cout = '0'
            report "Test Case 1 failed!" severity error;

        -- Test Case 2: 1100 + 1110 = 1010 (LSB-first addition)
        inA <= "1100"; inB <= "1110"; start <= '1';
        wait for clk_period;
        start <= '0';
        wait for clk_period*6;
        assert sum = "1010"
            report "Test Case 2 failed!" severity error;

        -- Test Case 3: 1000 + 1010 = 0010, carry=1
        inA <= "1000"; inB <= "1010"; start <= '1';
        wait for clk_period;
        start <= '0';
        wait for clk_period*6;
        assert sum = "0010" and cout = '1'
            report "Test Case 3 failed!" severity error;

        -- Test Case 4: 1111 + 1111 = 1110, carry=1
        inA <= "1111"; inB <= "1111"; start <= '1';
        wait for clk_period;
        start <= '0';
        wait for clk_period*6;
        assert sum = "1110" and cout = '1'
            report "Test Case 4 failed!" severity error;

        -- Test Case 5: 1111 + 0001 = 0000, carry=1
        inA <= "1111"; inB <= "0001"; start <= '1';
        wait for clk_period;
        start <= '0';
        wait for clk_period*6;
        assert sum = "0000" and cout = '1'
            report "Test Case 5 failed!" severity error;

        -- Test Case 6: 1010 + 0101 = 1111, carry=0
        inA <= "1010"; inB <= "0101"; start <= '1';
        wait for clk_period;
        start <= '0';
        wait for clk_period*6;
        assert sum = "1111" and cout = '0'
            report "Test Case 6 failed!" severity error;

        -- Test Case 7: 1000 + 0111 = 1111, carry=0
        inA <= "1000"; inB <= "0111"; start <= '1';
        wait for clk_period;
        start <= '0';
        wait for clk_period*6;
        assert sum = "1111" and cout = '0'
            report "Test Case 7 failed!" severity error;

        report "All test cases completed successfully!" severity note;
        wait;
    end process;

end architecture;
