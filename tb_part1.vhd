library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_serial_adder_complete is
end entity;

architecture behav of tb_serial_adder_complete is

    -- Component declaration
    component serial_adder_complete
        port(
            clk      : in  std_logic;
            start    : in  std_logic;
            clear_sm : in  std_logic;
            inA      : in  std_logic_vector(3 downto 0);
            inB      : in  std_logic_vector(3 downto 0);
            sum      : out std_logic_vector(3 downto 0);
            cout     : out std_logic;
            ready    : out std_logic
        );
    end component;

    -- Clock period
    constant clk_period : time := 50 ns;

    -- Signals
    signal clk      : std_logic := '0';
    signal start    : std_logic := '0';
    signal clear_sm : std_logic := '0';
    signal inA      : std_logic_vector(3 downto 0) := (others => '0');
    signal inB      : std_logic_vector(3 downto 0) := (others => '0');
    signal sum      : std_logic_vector(3 downto 0);
    signal cout     : std_logic;
    signal ready    : std_logic;

    -- Test vector type
    type test_vector is record
        A : std_logic_vector(3 downto 0);
        B : std_logic_vector(3 downto 0);
        expected_sum : std_logic_vector(3 downto 0);
        expected_cout : std_logic;
    end record;

    -- Test vector array
    type test_array is array (natural range <>) of test_vector;

    constant tests : test_array := (
        (A => x"0", B => x"4", expected_sum => x"4", expected_cout => '0'),
        (A => x"C", B => x"E", expected_sum => x"A", expected_cout => '1'),
        (A => x"8", B => x"A", expected_sum => x"2", expected_cout => '1'),
        (A => x"F", B => x"F", expected_sum => x"E", expected_cout => '1'),
        (A => x"F", B => x"1", expected_sum => x"0", expected_cout => '1'),
        (A => x"A", B => x"5", expected_sum => x"2", expected_cout => '1'), -- intentionally wrong
        (A => x"8", B => x"7", expected_sum => x"F", expected_cout => '0')
    );

begin

    -- Instantiate the DUT
    DUT: serial_adder_complete
        port map(
            clk => clk,
            start => start,
            clear_sm => clear_sm,
            inA => inA,
            inB => inB,
            sum => sum,
            cout => cout,
            ready => ready
        );

    -- Clock process
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    -- Stimulus process
    stim_process : process
    begin
        -- Apply reset
        clear_sm <= '1';
        wait for clk_period;
        clear_sm <= '0';

        -- Loop through test vectors
        for i in 0 to tests'high loop
            -- Apply inputs
            inA <= tests(i).A;
            inB <= tests(i).B;
            start <= '1';
            wait for clk_period;
            start <= '0';

            -- Wait for 'ready' signal
            wait until ready = '1';
            wait for clk_period; -- wait one more clock for outputs to settle

            -- Check sum
            assert sum = tests(i).expected_sum
                report "Test " & integer'image(i) & " failed. Expected SUM=" &
                       integer'image(to_integer(unsigned(tests(i).expected_sum))) &
                       ", Got SUM=" &
                       integer'image(to_integer(unsigned(sum)))
                severity error;

            -- Check cout
            assert cout = tests(i).expected_cout
                report "Test " & integer'image(i) & " failed. Expected COUT=" &
                       std_logic'image(tests(i).expected_cout) &
                       ", Got COUT=" &
                       std_logic'image(cout)
                severity error;

            wait for clk_period;
        end loop;

        -- Finish simulation
        assert false
            report "All tests completed."
            severity failure;
    end process;

end architecture;
