library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_serial_adder is
end tb_serial_adder;

architecture behav of tb_serial_adder is

    -- Component declaration
    component serial_adder_complete is
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

    -- Signals
    signal clk      : std_logic := '0';
    signal start    : std_logic := '0';
    signal clear_sm : std_logic := '1';
    signal inA      : std_logic_vector(3 downto 0);
    signal inB      : std_logic_vector(3 downto 0);
    signal sum      : std_logic_vector(3 downto 0);
    signal cout     : std_logic;
    signal ready    : std_logic;

    constant clk_period : time := 20 ns;

    -- Test vector type
    type test_case is record
        A, B : std_logic_vector(3 downto 0);
        SUM  : std_logic_vector(3 downto 0);
        COUT : std_logic;
    end record;

    type test_array is array (0 to 6) of test_case;

    constant tests : test_array := (
        (A => X"0", B => X"4", SUM => X"4", COUT => '0'),
        (A => X"C", B => X"E", SUM => X"A", COUT => '1'),
        (A => X"8", B => X"A", SUM => X"2", COUT => '1'),
        (A => X"F", B => X"F", SUM => X"E", COUT => '1'),
        (A => X"F", B => X"1", SUM => X"0", COUT => '1'),
        (A => X"A", B => X"5", SUM => X"2", COUT => '0'), -- intentional wrong result
        (A => X"8", B => X"7", SUM => X"F", COUT => '0')
    );

begin
    -- Instantiate the serial adder
    UUT: serial_adder_complete
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

    -- Clock generation
    clk_process: process
    begin
        while true loop
            clk <= '0'; wait for clk_period/2;
            clk <= '1'; wait for clk_period/2;
        end loop;
    end process;

    -- Test procedure
    stim_proc: process
    begin
        -- Reset
        clear_sm <= '1';
        wait for clk_period*2;
        clear_sm <= '0';
        wait for clk_period;

        -- Loop through test vectors
        for i in tests'range loop
            inA    <= tests(i).A;
            inB    <= tests(i).B;
            start  <= '1';
            wait for clk_period;
            start  <= '0';

            -- Wait until ready goes high
            wait until ready = '1';

            -- Check sum
            assert sum = tests(i).SUM and cout = tests(i).COUT
            report "Test failed for A=" & integer'image(to_integer(unsigned(tests(i).A))) &
                   " B=" & integer'image(to_integer(unsigned(tests(i).B))) &
                   " Expected SUM=" & integer'image(to_integer(unsigned(tests(i).SUM))) &
                   " COUT=" & std_logic'image(tests(i).COUT) &
                   " Got SUM=" & integer'image(to_integer(unsigned(sum))) &
                   " COUT=" & std_logic'image(cout)
            severity error;

            wait for clk_period*2;
        end loop;

        report "All tests completed" severity note;
        wait;
    end process;

end architecture;
