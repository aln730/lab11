library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- Testbench for DM74LS194A Shift Register
-------------------------------------------------------------------------------

entity tb_DM74LS194A is
end tb_DM74LS194A;

architecture behav of tb_DM74LS194A is

    -- Component declaration
    component DM74LS194A is
        port (
            a, b, c, d : in std_logic;
            clk, clear : in std_logic;
            s0, s1     : in std_logic;
            sL, sR     : in std_logic;
            qa, qb, qc, qd : out std_logic
        );
    end component;

    -- Helper function to print std_logic_vectors
    function vec2str(vec: std_logic_vector) return string is
        variable stmp: string(vec'high+1 downto 1);
        variable counter : integer := 1;
    begin
        for i in vec'reverse_range loop
            stmp(counter) := std_logic'image(vec(i))(2);
            counter := counter + 1;
        end loop;
        return stmp;
    end vec2str;

    -- Clock period
    constant clk_period : time := 100 ns;

    -- Inputs
    signal i_data : std_logic_vector(3 downto 0) := (others => '0');
    signal clk    : std_logic := '0';
    signal clear  : std_logic := '0';
    signal mode   : std_logic_vector(1 downto 0) := (others => '0');
    signal sL     : std_logic := '0';
    signal sR     : std_logic := '0';

    -- Outputs
    signal o_data : std_logic_vector(3 downto 0);
    signal qa, qb, qc, qd : std_logic;

begin

    -- Instantiate the shift register
    UUT: DM74LS194A
        port map (
            a => i_data(3),
            b => i_data(2),
            c => i_data(1),
            d => i_data(0),
            clk => clk,
            clear => clear,
            s0 => mode(0),
            s1 => mode(1),
            sL => sL,
            sR => sR,
            qa => qa,
            qb => qb,
            qc => qc,
            qd => qd
        );

    -- Combine outputs
    o_data <= qa & qb & qc & qd;

    -- Clock generation
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process clk_process;

    -- Reset process
    rst_process: process
    begin
        clear <= '0';
        wait for clk_period/4;
        clear <= '1';
        wait;
    end process rst_process;

    -- Stimulus process
    stim_process: process
    begin
        wait until clear = '1'; -- Wait for reset to finish

        -- Load B = 1011
        i_data <= "1011";
        mode <= "11"; -- Load mode
        wait for clk_period;
        assert o_data = "1011"
            report "Shift register failed to load at: " & time'image(now) &
                   ". Expected: 1011, Got: " & vec2str(o_data)
            severity error;

        -- Shift left
        sL <= '1';
        mode <= "10";
        wait for clk_period;
        assert o_data = "0111"
            report "Shift register failed to shift left at: " & time'image(now) &
                   ". Expected: 0111, Got: " & vec2str(o_data)
            severity error;

        sL <= '0';
        wait for clk_period;
        assert o_data = "1110"
            report "Shift register failed to shift left at: " & time'image(now) &
                   ". Expected: 1110, Got: " & vec2str(o_data)
            severity error;

        -- Shift right
        sR <= '1';
        mode <= "01";
        wait for clk_period;
        assert o_data = "1111"
            report "Shift register failed to shift right at: " & time'image(now) &
                   ". Expected: 1111, Got: " & vec2str(o_data)
            severity error;

        sR <= '0';
        wait for clk_period;
        assert o_data = "0111"
            report "Shift register failed to shift right at: " & time'image(now) &
                   ". Expected: 0111, Got: " & vec2str(o_data)
            severity error;

        -- Hold
        mode <= "00";
        wait for clk_period*3;
        assert o_data = "0111"
            report "Shift register hold failed at: " & time'image(now) &
                   ". Expected: 0111, Got: " & vec2str(o_data)
            severity error;

        -- Finish simulation
        assert false
            report "Simulation finished"
            severity failure;
    end process stim_process;

end behav;
