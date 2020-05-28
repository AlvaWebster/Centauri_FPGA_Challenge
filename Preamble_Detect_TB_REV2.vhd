library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	use ieee.std_logic_textio.all;
	use IEEE.STD_LOGIC_UNSIGNED.ALL;
	

entity Preamble_Detect_TB_REV2 is
end Preamble_Detect_TB_REV2;

Architecture behavior of Preamble_Detect_TB_REV2 is
	
	signal button  	:	std_logic	:= '0';
	signal clk_in		:	std_logic	:= '0';
	signal data_line	:	std_logic	:= '0';
	signal reset		:	std_logic	:= '0';
	
	--Led Simulation Signals
	signal led			:	std_logic;
	
	--Idle Simulation Signals
	signal tb_idleStatus	:	std_logic;
	
	--Preamble Detect Simulation Signals
	signal data_clock_out : std_logic;
	signal detectedDataPattern: std_logic_vector (16 downto 0) := (others => '0');
	signal dataLineSimCounter : integer := 0;
	signal tb_detectedDataPattern : std_logic_vector (16 downto 0) := (others => '0');
	signal tb_preambleBit : std_logic;
	signal tb_strobe : std_logic;
	signal tb_preambleCounter : integer := 0;
	signal tb_preambleStatus : std_logic;
	
	--Servo Simulation Signals
	signal servo		:	std_logic;
	signal tb_servoCounter : integer;
	signal tb_servoStatus : std_logic;
	
	signal preamblePattern : std_logic_vector (16 downto 0) := (others =>'0');
	signal testPattern : std_logic_vector (16 downto 0) := (others =>'0');
	
	--Assign a constant to clock to make it easier to change
	constant clk_period : time := 10ns;
	

--test bench code
begin
	--LOAD IN PATTERN SIMULATION
	preamblePattern <= "10100001010000001";
	testPattern <= "10100001010000001";
	
	uut: entity work.Preamble_DetecT_REV2 port map (
		button => button,
		clk_in => clk_in,
		data_line => data_line,
		reset => reset,
		
		led => led,
		servo => servo,
		tb_servoCounter => tb_servoCounter,
		data_clock_out => data_clock_out,
		
		tb_detectedDataPattern => tb_detectedDataPattern,
		tb_strobe => tb_strobe,
		tb_preambleCounter => tb_preambleCounter,
		tb_preambleStatus => tb_preambleStatus,
		tb_servoStatus => tb_servoStatus,
		tb_idleStatus => tb_idleStatus
		);

--Simulation of clock line
	clk_process :process
		begin
			clk_in <= '0';
			wait for clk_period/2;
		
			clk_in <= '1';
			wait for clk_period/2;
		end process;
	
--Simulation of Button Pressed	
	button_proc: process
		begin			
			button <= '0';
			wait for 15us;
			
			button <= '1';
			wait for 15us;
		end process;	

--Simulation of Data Line to be Read
	data_line_simulation: process
		begin			
			if(tb_strobe = '1'and tb_preambleStatus = '1') then
				data_line <= testPattern(tb_preambleCounter);

			end if;
			wait for 10ns;
		end process;

	
end;