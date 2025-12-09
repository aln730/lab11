library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-------------------------------------------------------------------------------
-- COMPONENTS
-------------------------------------------------------------------------------

-- 1-bit Full Adder
entity my_full_adder is
    port(
        A, B, Cin : in  std_logic;
        Sum, Cout : out std_logic
    );
end entity;

architecture behavioral of my_full_adder is
begin
    Sum  <= A xor B xor Cin after 8 ns;
    Cout <= (A and B) or (Cin and (A xor B)) after 8 ns;
end architecture;

-- D Flip-Flop
entity my_dff is
    port(
        clk   : in  std_logic;
        clear : in  std_logic;
        en    : in  std_logic;
        D     : in  std_logic;
        Q     : out std_logic
    );
end entity;

architecture behavioral of my_dff is
    signal q_i : std_logic;
begin
    process(clk, clear)
    begin
        if clear = '1' then
            q_i <= '0' after 6 ns;
        elsif rising_edge(clk) then
            if en = '1' then
                q_i <= D after 6 ns;
            end if;
        end if;
    end process;
    Q <= q_i;
end architecture;

-- 4-bit Shift Register
entity my_shift_register is
    port(
        clk         : in  std_logic;
        clear_dp    : in  std_logic;
        s1, s0      : in  std_logic;
        parallel_in : in  std_logic_vector(3 downto 0);
        serial_out  : out std_logic_vector(3 downto 0)
    );
end entity;

architecture behavioral of my_shift_register is
    signal reg : std_logic_vector(3 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if clear_dp = '1' then
                reg <= (others => '0');
            elsif s1 = '1' and s0 = '1' then
                reg <= parallel_in;
            elsif s1 = '0' and s0 = '1' then
                reg <= reg(2 downto 0) & '0'; -- shift left
            end if;
        end if;
    end process;
    serial_out <= reg;
end architecture;

-------------------------------------------------------------------------------
-- SERIAL ADDER STRUCTURAL
-------------------------------------------------------------------------------
entity serial_adder_complete is
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
end entity;

architecture structural of serial_adder_complete is

    -- Control signals
    signal control : std_logic_vector(1 downto 0);
    signal clear_dp : std_logic;

    -- Datapath signals
    signal regA_out, regB_out : std_logic_vector(3 downto 0);
    signal carry_ff           : std_logic;
    signal sum_bit            : std_logic;

begin
    -- Example simple control: 11=load, 01=shift, 00=hold
    process(clk)
    begin
        if rising_edge(clk) then
            if clear_sm = '1' then
                control <= "00";
                clear_dp <= '1';
            elsif start = '1' then
                control <= "11"; -- load first
                clear_dp <= '0';
            else
                control <= "01"; -- shift
                clear_dp <= '0';
            end if;
        end if;
    end process;

    ready <= '1' when control = "00" else '0';

    -- Shift Registers
    REG_A: my_shift_register
        port map(clk => clk, clear_dp => clear_dp, s1 => control(1), s0 => control(0),
                 parallel_in => inA, serial_out => regA_out);

    REG_B: my_shift_register
        port map(clk => clk, clear_dp => clear_dp, s1 => control(1), s0 => control(0),
                 parallel_in => inB, serial_out => regB_out);

    -- Full Adder
    FA: my_full_adder
        port map(A => regA_out(0), B => regB_out(0), Cin => carry_ff,
                 Sum => sum_bit, Cout => carry_ff);

    -- Feed sum back into regA LSB
    process(clk)
    begin
        if rising_edge(clk) then
            if control = "01" then
                regA_out(0) <= sum_bit;
            end if;
        end if;
    end process;

    -- Carry flip-flop
    CARRY_FF: my_dff
        port map(clk => clk, clear => clear_dp, en => '1', D => carry_ff, Q => cout);

    sum <= regA_out;

end architecture;

-------------------------------------------------------------------------------
-- TEST BENCH (binary vectors)
-------------------------------------------------------------------------------
entity tb_serial_adder is
end entity;

architecture tb of tb_serial_adder is
    signal clk, start, clear_sm : std_logic := '0';
    signal inA, inB             : std_logic_vector(3 downto 0);
    signal sum                  : std_logic_vector(3 downto 0);
    signal cout, ready          : std_logic;

    constant clk_period : time := 100 ns;

begin

    UUT: serial_adder_complete
        port map(clk => clk, start => start, clear_sm => clear_sm,
                 inA => inA, inB => inB, sum => sum, cout => cout, ready => ready);

    -- Clock
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus
    stim_proc: process
    begin
        -- Reset
        clear_sm <= '1';
        wait for clk_period;
        clear_sm <= '0';

        -- Test case 1: inA="0000", inB="0100" -> sum="0100"
        inA <= "0000"; inB <= "0100"; start <= '1';
        wait for clk_period;
        start <= '0';
        wait for clk_period*5; -- enough cycles for shifting
        assert sum = "0100" and cout = '0'
            report "Test case 1 failed!" severity error;

        -- Test case 2: inA="1100", inB="1110" -> sum="1010" (example)
        inA <= "1100"; inB <= "1110"; start <= '1';
        wait for clk_period;
        start <= '0';
        wait for clk_period*5;
        assert sum = "1010" -- put expected value
            report "Test case 2 failed!" severity error;

        wait;
    end process;

end architecture;
