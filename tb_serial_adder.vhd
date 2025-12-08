library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_serial_adder is
end tb_serial_adder;

architecture behav of tb_serial_adder is

    -- Component under test
    component serial_adder_datapath is
        port(
            clk      : in  std_logic;
            clear_dp : in  std_logic;
            control  : in  std_logic_vector(1 downto 0);
            inA      : in  std_logic_vector(3 downto 0);
            inB      : in  std_logic_vector(3 downto 0);
            sum      : out std_logic_vector(3 downto 0);
            carry    : out std_logic
        );
    end component;

    -- Testbench signals
    signal clk      : std_logic := '0';
    signal clear_dp : std_logic := '0';
    signal control  : std_logic_vector(1 downto 0);
    signal inA      : std_logic_vector(3 downto 0);
    signal inB      : std_logic_vector(3 downto 0);
    signal sum      : std_logic_vector(3 downto 0);
    signal carry    : std_logic;

    -- Clock period
    constant clk_period : time := 100 ns;

    -- Test vector type
    type test_vector is record
        a, b  : std_logic_vector(3 downto 0);
        sum_e : std_logic_vector(3 downto 0);
        carry_e : std_logic;
    end record;

    -- Array of test vectors
    type test_array is array (natural range <>) of test_vector;
    constant tests : test_array := (
        (a => X"0", b => X"4", sum_e => X"4", carry_e => '0'),
        (a => X"C", b => X"E", sum_e => X"A", carry_e => '1'),
        (a => X"8", b => X"A", sum_e => X"2", carry_e => '1'),
        (a => X"F", b => X"F", sum_e => X"E", carry_e => '1'),
        (a => X"F", b => X"1", sum_e => X"0", carry_e => '1'),
        (a => X"A", b => X"5", sum_e => X"2", carry_e => '0'), -- intentionally wrong for testing
        (a => X"8", b => X"7", sum_e => X"F", carry_e => '0')
    );

begin

    -- Instantiate DUT
    DUT: serial_adder_datapath
        port map(
            clk      => clk,
            clear_dp => clear_dp,
            control  => control,
            inA      => inA,
            inB      => inB,
            sum      => sum,
            carry    => carry
        );

    -- Clock generation
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    -- Stimulus
    stim_proc: process
    begin
        -- Loop over all test vectors
        for i in tests'range loop
            -- Apply reset
            clear_dp <= '1';
            control <= "00";
            wait for clk_period;
            clear_dp <= '0';
            wait for clk_period;

            -- Load inputs
            inA <= tests(i).a;
            inB <= tests(i).b;
            control <= "11";  -- load mode
            wait for clk_period;

            -- Shift and add for 4 cycles
            control <= "01";  -- shift mode
            for j in 0 to 3 loop
                wait for clk_period;
            end loop;

            -- Check results
            assert sum = tests(i).sum_e and carry = tests(i).carry_e
                report "Test failed for inA=" & integer'image(to_integer(unsigned(tests(i).a))) &
                       ", inB=" & integer'image(to_integer(unsigned(tests(i).b))) &
                       ". Expected sum=" & integer'image(to_integer(unsigned(tests(i).sum_e))) &
                       ", carry=" & std_logic'image(tests(i).carry_e) &
                       ". Got sum=" & integer'image(to_integer(unsigned(sum))) &
                       ", carry=" & std_logic'image(carry)
                severity error;

            wait for clk_period; -- small delay between tests
        end loop;

        report "All test vectors applied." severity note;
        wait;
    end process;

end behav;
