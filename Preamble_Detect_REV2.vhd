library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	use ieee.std_logic_textio.all;
	use IEEE.STD_LOGIC_UNSIGNED.ALL;
	

entity Preamble_Detect_REV2 is

--define system input and outputs for use in program
port(
		--system inputs
		Clk_in		: in std_logic := '0';
		button		: in std_logic := '0';
		data_line	: in std_logic := '0';
		reset			: in std_logic;--I think it is good practice to define
		
		--system outputs
		led			: out std_logic;
		servo			: out std_logic;
		
		--test bench outputs for debuggins
		data_clock_out	: out std_logic;
		
		tb_detectedDataPattern : out std_logic_vector (16 downto 0);
		tb_servoCounter : out integer;
		tb_preambleBit	: out std_logic;
		tb_strobe : out std_logic;
		tb_preambleCounter : out integer;
		tb_dataDetected : out std_logic;
		
		tb_preambleStatus : out std_logic;
		tb_servoStatus : out std_logic;
		tb_idleStatus : out std_logic
);

end entity;

architecture rtl of Preamble_Detect_REV2 is

type preamble_sm is (IDLE, PREAMBLE_DETECT,  ROTATE_SERVO); --enumeration, define state machine types for use

--asynchronous button detection signals
signal buttonUnstable	: std_logic;
signal buttonStable	: std_logic;

--state name
signal preamble_present : preamble_sm; -- present state
signal preamble_next : preamble_sm; --next state

--clock divider signals
signal clk_counter : integer:= 1;
signal data_clock_en : std_logic := '0';

--state status signals
signal idleStatus : std_logic;
signal preambleStatus : std_logic;
signal servoStatus : std_logic;

--preamble detect signals
signal preambleCounter : integer := 0;
signal detectedDataPattern : std_logic_vector (16 downto 0) := (others => '0');
signal preamblePattern : std_logic_vector (16 downto 0) := "10100001010000001";

--servo signals
signal servoCounter :  integer := 0;
signal servoPWMTimer : integer := 0;

--strobe signal creation
signal strobe : std_logic := '0';
signal clock0 : std_logic := '0';
signal clock1 : std_logic := '0';
signal clock2 : std_logic := '0';

begin
--test bench signals assignment
tb_strobe <= strobe;
tb_detectedDataPattern <= detectedDataPattern;
tb_preambleCounter <= preambleCounter;

tb_preambleStatus <= preambleStatus;
tb_servoStatus <= servoStatus;
tb_idleStatus <= idleStatus;

tb_servoCounter <= servoCounter;

--create clock divider for data line reading
	clk_divider: process(clk_in, reset)
	begin
		if(rising_edge(clk_in)) then
			clk_counter <= clk_counter + 1;		
			
			if(clk_counter < 25) then --50 is how many ticks are in a 100Mhz compared to 2Mhz
				data_clock_en <= '0';
			else
				data_clock_en <= '1';
			end if;
			
			if (clk_counter = 49) then
				clk_counter <= 0;
			end if;

			data_clock_out <= data_clock_en;
			
			--strobe generation for data_clock
			clock0 <= data_clock_en;
			clock1 <= clock0;
			clock2 <= clock1;
			
			if(clock0 = '1' and clock1 = '0') then
				strobe <= '1';
			else
				strobe <= '0';
			end if;
				
		end if;		
	end process;

--clocked process for driving the present state
	preamble_machine_state : process(clk_in) 
	begin		
		if(rising_edge(clk_in)) then
			preamble_present <= preamble_next; --assign the next state to compare for the current state	
		else
			preamble_present <= preamble_next;
		end if;
			
	end process preamble_machine_state ;
	
--combinational logic for driving the next state
	preamble_machine_comb : process (preamble_present, button, clk_in, data_clock_en)
	begin
		if(rising_edge(clk_in)) then
			case preamble_present is
			
				--idle state logic
				when IDLE =>
					--status signals for state detection
					idleStatus <= '1';
					preambleStatus <= '0';
					servoStatus <= '0';
					
					if(button = '1') then --synchronous button detection to clock
						preamble_next <= PREAMBLE_DETECT;
					else
						preamble_next <= IDLE;
					end if;
				
				--preamble detect state logic
				when PREAMBLE_DETECT =>
					--status signals for state detection
					idleStatus <= '0';
					preambleStatus <= '1';
					servoStatus <= '0';
					
					--determines next state, if preamble has been detected move to rotate servo
					if(detectedDataPattern = preamblePattern) then
						detectedDataPattern <= "00000000000000000";

						preamble_next <= ROTATE_sERVO;
					else
						if(strobe = '1') then
							detectedDataPattern(preambleCounter) <= data_line;
							if(preambleCounter = 16) then
								preambleCounter <= 0;
							else
								preambleCounter <= preambleCounter + 1;
							end if;
						end if;
							
						preamble_next <= PREAMBLE_DETECT;
					end if;
				
				--rotate servo state logic
				when ROTATE_sERVO =>		
					--status signals for state detection
					idleStatus <= '0';
					preambleStatus <= '0';
					servoStatus <= '1';
					
					if(servoCounter	= 10000) then -- wait for 10000 clock ins, or 100us
						preamble_next <= IDLE;
						servoCounter <= 0;
					else
						servoCounter <= servoCounter + 1;
						preamble_next <= ROTATE_sERVO;
					end if;
					
			end case;
		end if;
	end process preamble_machine_comb;
	
--output state machine
	preamble_machine_out : process(clk_in)
	begin
		case preamble_present is
			when IDLE =>
				led <= '0';
				servo <= '0';
				
			when PREAMBLE_DETECT =>
				led <= '1';
				servo <= '0';
				
			when ROTATE_SERVO =>
				led  <= '1';
				
				if(servoPWMTimer < 15) then--50 pulses in actual 10 second scaling, so 2 useconds is the pwm timer length
					servo <= '1';
				else
					servo <= '0';
				end if;
				
				if(servoPWMTimer <= 200) then
					servoPWMTimer <= servoPWMTimer + 1;
				else
					servoPWMTimer <= 0;
				end if;
		end case;
	end process preamble_machine_out;

end rtl;