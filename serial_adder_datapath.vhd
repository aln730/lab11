library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-------------------------------------------------------------------------------
-- Components (reuse your previously defined entities)
-------------------------------------------------------------------------------

-- 1-bit full adder
component my_full_adder is
    port(
        A, B, Cin : in std_logic;
        Sum, Cout : out std_logic
    );
end component;

-- D flip-flop (for carry)
component my_dff is
    port(
        clk   : in  std_logic;
        clear : in  std_logic;
        en    : in  std_logic;
        D     : in  std_logic;
        Q     : out std_logic
    );
end component;

-- 4-bit shift register
component my_shift_register is
    port(
        clk         : in  std_logic;
        clear_dp    : in  std_logic;
        s1, s0      : in  std_logic;
        parallel_in : in  std_logic_vector(3 downto 0);
        serial_out  : out std_logic_vector(3 downto 0)
    );
end component;

-------------------------------------------------------------------------------
-- Serial adder data path
-------------------------------------------------------------------------------

entity serial_adder_datapath is
    port(
        clk      : in  std_logic;
        clear_dp : in  std_logic;
        control  : in  std_logic_vector(1 downto 0); -- 11=load, 01=shift
        inA      : in  std_logic_vector(3 downto 0);
        inB      : in  std_logic_vector(3 downto 0);
        sum      : out std_logic_vector(3 downto 0);
        carry    : out std_logic
    );
end entity;

architecture structural of serial_adder_datapath is

    -- Control signals
    signal s1, s0 : std_logic;

    -- Datapath signals
    signal regA_out, regB_out : std_logic_vector(3 downto 0);
    signal sum_bit             : std_logic;
    signal carry_ff            : std_logic;

    -- Internal signals for AND and inverter (if needed for specific logic)
    signal temp_and : std_logic;
    signal temp_not : std_logic;

begin

    -- Decode control signals
    s1 <= control(1);
    s0 <= control(0);

    ---------------------------------------------------------------------------
    -- Shift registers
    ---------------------------------------------------------------------------
    REG_A: my_shift_register
        port map(
            clk => clk,
            clear_dp => clear_dp,
            s1 => s1,
            s0 => s0,
            parallel_in => inA,
            serial_out => regA_out
        );

    REG_B: my_shift_register
        port map(
            clk => clk,
            clear_dp => clear_dp,
            s1 => s1,
            s0 => s0,
            parallel_in => inB,
            serial_out => regB_out
        );

    ---------------------------------------------------------------------------
    -- 1-bit full adder
    ---------------------------------------------------------------------------
    FA: my_full_adder
        port map(
            A   => regA_out(0),
            B   => regB_out(0),
            Cin => carry_ff,
            Sum => sum_bit,
            Cout => carry_ff
        );

    ---------------------------------------------------------------------------
    -- Carry flip-flop
    ---------------------------------------------------------------------------
    CARRY_FF: my_dff
        port map(
            clk   => clk,
            clear => clear_dp,
            en    => s1, -- enable during load/shift
            D     => carry_ff,
            Q     => carry
        );

    ---------------------------------------------------------------------------
    -- Feed sum back into regA LSB (serial addition)
    ---------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if (s1='0' and s0='1') then  -- shift mode
                regA_out(0) <= sum_bit;
            end if;
        end if;
    end process;

    ---------------------------------------------------------------------------
    -- Output sum (final result in regA)
    ---------------------------------------------------------------------------
    sum <= regA_out;

end architecture;
