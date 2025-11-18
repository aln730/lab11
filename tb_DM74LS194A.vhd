library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- In order for this test bench to work, you will need to update the component
-- name to match what is in your shift register vhd file. If you have chosen
-- to parallelize the inputs, be sure to update the component below
-- appropriately. Finally, there are assert statements that must be filled in.
-------------------------------------------------------------------------------

entity tb_DM74LS194A is
end tb_DM74LS194A;

architecture behav of tb_DM74LS194A is

component DM74LS194A is
  port (a, b, c, d : in std_logic;
        clk, clear : in std_logic;
		s0, s1     : in std_logic;
		sL, sR     : in std_logic;
		qa, qb, qc, qd : out std_logic);
end component;
-- Possible parallel component. Signal names will likely need updating!
-- component DM74LS194A is
-- port (parallel_load  : in  std_logic_vector(3 downto 0);
--       clk, clear     : in  std_logic;
--		 control        : in  std_logic_vector(1 downto 0);
--		 sL, sR         : in  std_logic;
--		 outputs        : out std_logic_vector(3 downto 0));
-- end component;

    -- Helper function to print std_logic_vectors more easily
    function vec2str(vec: std_logic_vector) return string is
        variable stmp: string(vec'high+1 downto 1);
        variable counter : integer := 1;
    begin
        for i in vec'reverse_range loop
            stmp(counter) := std_logic'image(vec(i))(2); -- image returns '1' (with quotes)
            counter := counter + 1;
        end loop;
        return stmp;
    end vec2str;

	constant clk_period : time := 100 ns;
    -- Inputs
	signal i_data : std_logic_vector(3 downto 0) := (others => '0');
	signal clk : std_logic := '0';
	signal clear : std_logic := '0';
	signal mode : std_logic_vector(1 downto 0) := (others => '0');
	signal sL : std_logic := '0';
	signal sR : std_logic := '0';
    -- Outputs
	signal o_data : std_logic_vector(3 downto 0);
    signal qa, qb, qc, qd : std_logic;

	begin
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

-- Possible parallel component. Signal names will likely need updating!
-- UUT: DM74LS194A
-- port map (
--     parallel_load => i_data,
--     clk => clk,
--     clear => clear,
--     control => mode,
--     sL => sL,
--     sR => sR,
--     outputs => o_data
-- );

    o_data<= (qa,qb,qc,qd);

	clk_process: process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process clk_process;

	rst_process: process
	begin
		clear <= '0';
		wait for clk_period/4;
		clear <= '1';
		wait;
	end process rst_process;

	stim_process: process
    begin
        wait until clear = '1'; -- Wait for reset to finish
        i_data <= ____; -- TODO: Fill this value in
        mode <= "11"; -- load into the shift register
        wait for clk_period;
        assert o_data = X"B"
            report "Shift register failed to load at: " & time'image(now) &
                   ". Expected: " & vec2str(____) & -- TODO: This should match the value in the assert
                   ". Got: " & vec2str(o_data)
            severity error; -- The report statement tells the user what time the
                            -- failure occured at, and what was expected
        sL <= '1';
        mode <= ____; -- TODO: shift to the left
        wait for clk_period;
        assert o_data = X"7"
            report "Shift register failed to shift left at: " & time'image(now) &
                   ". Expected: " & vec2str(X"7") &
                   ". Got: " & vec2str(o_data)
            severity error;

        sL <= ____; -- TODO: Fill this value in to create 0xE
        wait for clk_period;
        assert o_data = X"E"
            report "Shift register failed to shift left at: " & time'image(now) &
                   ". Expected: " & vec2str(X"E") &
                   ". Got: " & vec2str(o_data)
            severity error;

        sR <= '1';
        mode <= "01"; --shift to the right
        wait for clk_period;
        assert o_data = ____ -- TODO: Fill this value in
            report "Shift register failed to shift right at: " & time'image(now) &
                   ". Expected: " & vec2str(____) & -- TODO: This should match the value in the assert
                   ". Got: " & vec2str(o_data)
            severity error;

        sR <= '0';
        wait for clk_period;
        assert o_data = ____ -- TODO: Fill this value in
            report "Shift register failed to shift right at: " & time'image(now) &
                   ". Expected: " & vec2str(____) & -- TODO: This should match the value in the assert
                   ". Got: " & vec2str(o_data)
            severity error;

        mode <= ____; -- TODO: Hold
        wait for clk_period*3; -- hold for multiple cycles
        assert o_data = X"7"
            report "Shift register failed to shift right at: " & time'image(now) &
                   ". Expected: " & vec2str(X"7") &
                   ". Got: " & vec2str(o_data)
            severity error;

		assert false
			report "Simulation finished"
			severity failure;
	end process stim_process;

end behav;
