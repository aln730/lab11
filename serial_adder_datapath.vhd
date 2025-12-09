library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-------------------------------------------------------------------------------
-- 1-bit full adder
-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
-- D flip-flop
-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
-- 4-bit shift register
-------------------------------------------------------------------------------
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
            elsif s1 = '1' and s0 = '1' then  -- load
                reg <= parallel_in;
            elsif s1 = '0' and s0 = '1' then  -- shift left with 0
                reg <= reg(2 downto 0) & '0';
            end if;
        end if;
    end process;

    serial_out <= reg;
end architecture;

-------------------------------------------------------------------------------
-- Simple control unit for serial adder
-------------------------------------------------------------------------------
entity my_serial_adder_control is
    port(
        clk            : in  std_logic;
        start          : in  std_logic;
        clear_sm       : in  std_logic;
        control_output : out std_logic_vector(3 downto 0) -- ready, clear_dp, s1, s0
    );
end entity;

architecture behavioral of my_serial_adder_control is
    type state_type is (IDLE, RESET, LOAD, S1, S2, S3, S4, HOLD);
    signal state, next_state : state_type;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if clear_sm = '1' then
                state <= IDLE;
            else
                state <= next_state;
            end if;
        end if;
    end process;

    process(state, start)
    begin
        case state is
            when IDLE  => if start='1' then next_state<=RESET; else next_state<=IDLE; end if;
            when RESET => next_state <= LOAD;
            when LOAD  => next_state <= S1;
            when S1    => next_state <= S2;
            when S2    => next_state <= S3;
            when S3    => next_state <= S4;
            when S4    => next_state <= HOLD;
            when HOLD  => next_state <= IDLE;
            when others => next_state <= IDLE;
        end case;
    end process;

    process(state)
    begin
        case state is
            when IDLE    => control_output <= "1000" after 10 ns; -- ready=1
            when RESET   => control_output <= "0000" after 10 ns;
            when LOAD    => control_output <= "0111" after 10 ns; -- clear_dp=1, s1=1, s0=1
            when S1|S2|S3|S4 => control_output <= "0101" after 10 ns; -- shift mode s1=0,s0=1
            when HOLD    => control_output <= "0100" after 10 ns;
            when others  => control_output <= "0000" after 10 ns;
        end case;
    end process;
end architecture;

-------------------------------------------------------------------------------
-- Complete serial adder structural model
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
    signal control_out : std_logic_vector(3 downto 0);
    signal clear_dp    : std_logic;
    signal s1, s0      : std_logic;

    -- Datapath signals
    signal regA_out, regB_out : std_logic_vector(3 downto 0);
    signal carry_ff           : std_logic;
    signal sum_bit            : std_logic;

begin
    -- Control Unit
    CU: my_serial_adder_control
        port map(
            clk => clk,
            start => start,
            clear_sm => clear_sm,
            control_output => control_out
        );

    -- Decode control signals
    ready    <= control_out(3);
    clear_dp <= control_out(2);
    s1       <= control_out(1);
    s0       <= control_out(0);

    -- Shift Registers
    REG_A: my_shift_register
        port map(clk => clk, clear_dp => clear_dp, s1 => s1, s0 => s0,
                 parallel_in => inA, serial_out => regA_out);

    REG_B: my_shift_register
        port map(clk => clk, clear_dp => clear_dp, s1 => s1, s0 => s0,
                 parallel_in => inB, serial_out => regB_out);

    -- Full Adder
    FA: my_full_adder
        port map(A => regA_out(0), B => regB_out(0), Cin => carry_ff,
                 Sum => sum_bit, Cout => carry_ff);

    -- Shift sum_bit back into regA LSB (LSB-first addition)
    process(clk)
    begin
        if rising_edge(clk) then
            if clear_dp='1' then
                regA_out <= (others => '0');
            elsif s1='0' and s0='1' then
                regA_out <= sum_bit & regA_out(3 downto 1);
            end if;
        end if;
    end process;

    -- Carry flip-flop
    CARRY_FF: my_dff
        port map(clk => clk, clear => clear_dp, en => s1, D => carry_ff, Q => cout);

    -- Output sum
    sum <= regA_out;

end architecture;
