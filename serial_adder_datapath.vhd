library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity for structural top-level
entity serial_adder_top is
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

architecture structural of serial_adder_top is

    -- Component declarations go here
    component my_full_adder
        port(
            A, B, Cin : in  std_logic;
            Sum, Cout : out std_logic
        );
    end component;

    component my_dff
        port(
            clk   : in  std_logic;
            clear : in  std_logic;
            en    : in  std_logic;
            D     : in  std_logic;
            Q     : out std_logic
        );
    end component;

    component my_shift_register
        port(
            clk         : in  std_logic;
            clear_dp    : in  std_logic;
            s1, s0      : in  std_logic;
            parallel_in : in  std_logic_vector(3 downto 0);
            serial_out  : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Signals for interconnecting components
    signal regA_out, regB_out : std_logic_vector(3 downto 0);
    signal carry_ff           : std_logic;
    signal sum_bit            : std_logic;
    signal control_out        : std_logic_vector(3 downto 0);
    signal clear_dp_sig, s1_sig, s0_sig : std_logic;

begin

    -- Instantiate components here (example)
    -- REG_A, REG_B, Full Adder, DFF, etc.

end architecture;
