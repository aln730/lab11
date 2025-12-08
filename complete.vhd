library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

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
end serial_adder_complete;

architecture structural of serial_adder_complete is

    -- Control signals from FSM
    signal control_out : std_logic_vector(3 downto 0);
    signal clear_dp    : std_logic;
    signal s1, s0      : std_logic;

    -- Datapath signals
    signal regA_out, regB_out : std_logic_vector(3 downto 0);
    signal carry_ff           : std_logic;
    signal sum_bit            : std_logic;

    -- Component declarations
    component serial_adder_control
        port(
            clk            : in  std_logic;
            start          : in  std_logic;
            clear_sm       : in  std_logic;
            control_output : out std_logic_vector(3 downto 0)
        );
    end component;

    component shift_register_4bit
        port(
            clk         : in  std_logic;
            clear_dp    : in  std_logic;
            s1          : in  std_logic;
            s0          : in  std_logic;
            parallel_in : in  std_logic_vector(3 downto 0);
            serial_out  : out std_logic_vector(3 downto 0)
        );
    end component;

    component full_adder
        port(
            A, B, Cin : in  std_logic;
            Sum, Cout : out std_logic
        );
    end component;

    component dff
        port(
            clk   : in  std_logic;
            clear : in  std_logic;
            en    : in  std_logic;
            D     : in  std_logic;
            Q     : out std_logic
        );
    end component;

begin

    -- Instantiate Control Unit
    CU: serial_adder_control
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

    -- Instantiate Shift Registers
    REG_A: shift_register_4bit
        port map(
            clk         => clk,
            clear_dp    => clear_dp,
            s1          => s1,
            s0          => s0,
            parallel_in => inA,
            serial_out  => regA_out
        );

    REG_B: shift_register_4bit
        port map(
            clk         => clk,
            clear_dp    => clear_dp,
            s1          => s1,
            s0          => s0,
            parallel_in => inB,
            serial_out  => regB_out
        );

    -- 1-bit Full Adder (LSB of regA and regB)
    FA: full_adder
        port map(
            A    => regA_out(0),
            B    => regB_out(0),
            Cin  => carry_ff,
            Sum  => sum_bit,
            Cout => carry_ff
        );

    -- Feed sum bit back into regA LSB
    process(clk)
    begin
        if rising_edge(clk) then
            if clear_dp = '1' then
                regA_out(0) <= '0';
            elsif s1 = '0' and s0 = '1' then -- SHIFT/ADD states
                regA_out(0) <= sum_bit;
            end if;
        end if;
    end process;

    -- Carry flip-flop
    CARRY_FF: dff
        port map(
            clk   => clk,
            clear => clear_dp,
            en    => s1,       -- enable during addition
            D     => carry_ff,
            Q     => cout
        );

    -- Output sum
    sum <= regA_out;

end structural;
