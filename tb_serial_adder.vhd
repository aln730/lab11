library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-------------------------------------------------------------------------------
-- Components
-------------------------------------------------------------------------------

-- 1-bit Full Adder
entity full_adder is
    port(
        A, B, Cin : in  std_logic;
        Sum, Cout : out std_logic
    );
end entity;

architecture behavioral of full_adder is
begin
    Sum  <= A xor B xor Cin;
    Cout <= (A and B) or (Cin and (A xor B));
end architecture;

-- D Flip-Flop
entity dff is
    port(
        clk   : in  std_logic;
        clear : in  std_logic;
        D     : in  std_logic;
        Q     : out std_logic
    );
end entity;

architecture behavioral of dff is
begin
    process(clk, clear)
    begin
        if clear = '1' then
            Q <= '0';
        elsif rising_edge(clk) then
            Q <= D;
        end if;
    end process;
end architecture;

-- 4-bit Shift Register
entity shift_register is
    port(
        clk         : in  std_logic;
        clear_dp    : in  std_logic;
        load        : in  std_logic;
        parallel_in : in  std_logic_vector(3 downto 0);
        serial_in   : in  std_logic;
        serial_out  : out std_logic_vector(3 downto 0)
    );
end entity;

architecture behavioral of shift_register is
    signal reg : std_logic_vector(3 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if clear_dp = '1' then
                reg <= (others => '0');
            elsif load = '1' then
                reg <= parallel_in;
            else
                reg <= reg(2 downto 0) & serial_in; -- shift left
            end if;
        end if;
    end process;

    serial_out <= reg;
end architecture;

-- 2-input AND gate
entity and2 is
    port(A, B : in std_logic; Y : out std_logic);
end entity;

architecture behavioral of and2 is
begin
    Y <= A and B;
end architecture;

-- Inverter
entity inv is
    port(A : in std_logic; Y : out std_logic);
end entity;

architecture behavioral of inv is
begin
    Y <= not A;
end architecture;

-------------------------------------------------------------------------------
-- Structural Serial Adder
-------------------------------------------------------------------------------
entity serial_adder is
    port(
        clk      : in  std_logic;
        clear_dp : in  std_logic;
        inA      : in  std_logic_vector(3 downto 0);
        inB      : in  std_logic_vector(3 downto 0);
        control  : in  std_logic_vector(1 downto 0); -- "11" load, "01" shift
        sum      : out std_logic_vector(3 downto 0);
        carry    : out std_logic
    );
end entity;

architecture structural of serial_adder is
    signal regA_out, regB_out : std_logic_vector(3 downto 0);
    signal sum_bit, carry_ff  : std_logic;
begin
    -- Registers
    REG_A: shift_register
        port map(clk => clk, clear_dp => clear_dp,
                 load => (control="11"),
                 parallel_in => inA, serial_in => sum_bit,
                 serial_out => regA_out);

    REG_B: shift_register
        port map(clk => clk, clear_dp => clear_dp,
                 load => (control="11"),
                 parallel_in => inB, serial_in => '0',
                 serial_out => regB_out);

    -- Full Adder
    FA: full_adder
        port map(A => regA_out(0), B => regB_out(0), Cin => carry_ff,
                 Sum => sum_bit, Cout => carry_ff);

    -- Carry Flip-Flop
    CARRY_FF: dff
        port map(clk => clk, clear => clear_dp, D => carry_ff, Q => carry);

    -- Output sum
    sum <= regA_out;

end architecture;

-------------------------------------------------------------------------------
-- Test Bench
-------------------------------------------------------------------------------
entity tb_serial_adder is
end entity;

architecture sim of tb_serial_adder is
    constant clk_period : time := 10 ns;

    -- Signals
    signal clk, clear_dp : std_logic := '0';
    signal control       : std_logic_vector(1 downto 0) := "00";
    signal inA, inB      : std_logic_vector(3 downto 0) := (others => '0');
    signal sum           : std_logic_vector(3 downto 0);
    signal carry         : std_logic;

    -- Test cases
    type test_case is record
        a, b    : std_logic_vector(3 downto 0);
        expected_sum : std_logic_vector(3 downto 0);
        expected_carry : std_logic;
    end record;

    constant tests : array(0 to 6) of test_case := (
        (a => X"0", b => X"4", expected_sum => X"4", expected_carry => '0'),
        (a => X"C", b => X"E", expected_sum => X"A", expected_carry => '1'),
        (a => X"8", b => X"A", expected_sum => X"2", expected_carry => '1'),
        (a => X"F", b => X"F", expected_sum => X"E", expected_carry => '1'),
        (a => X"F", b => X"1", expected_sum => X"0", expected_carry => '1'),
        (a => X"A", b => X"5", expected_sum => X"2", expected_carry => '0'), -- intentionally wrong
        (a => X"8", b => X"7", expected_sum => X"F", expected_carry => '0')
    );
begin
    -- Clock generator
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    -- Stimulus process
    stim_process: process
    begin
        for i in 0 to 6 loop
            -- Reset
            clear_dp <= '1';
            wait for clk_period;
            clear_dp <= '0';
            wait for clk_period;

            -- Load registers
            inA <= tests(i).a;
            inB <= tests(i).b;
            control <= "11"; -- load
            wait for clk_period;

            -- Shift 4 times
            control <= "01"; -- shift
            for j in 0 to 3 loop
                wait for clk_period;
            end loop;

            -- Hold
            control <= "00";
            wait for clk_period;

            -- Check results
            assert sum = tests(i).expected_sum and carry = tests(i).expected_carry
                report "Test " & integer'image(i) & " failed. Got sum=" &
                       std_logic_vector'image(sum) & " carry=" & std_logic'image(carry)
                severity error;
        end loop;

        report "All tests finished";
        wait;
    end process;

end architecture;
