-- Component declarations for structural modeling
component my_full_adder is
    port(
        A, B, Cin : in  std_logic;
        Sum, Cout : out std_logic
    );
end component;

component my_dff is
    port(
        clk   : in  std_logic;
        clear : in  std_logic;
        en    : in  std_logic;
        D     : in  std_logic;
        Q     : out std_logic
    );
end component;

component my_shift_register is
    port(
        clk         : in  std_logic;
        clear_dp    : in  std_logic;
        s1, s0      : in  std_logic;
        parallel_in : in  std_logic_vector(3 downto 0);
        serial_out  : out std_logic_vector(3 downto 0)
    );
end component;

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
