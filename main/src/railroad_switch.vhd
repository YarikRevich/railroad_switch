library ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;

-- represents railroad switch logic unit, which
-- can is meant to be used as a state storage and
-- used by external devices to manage their state
-- with its help.
entity railroad_switch is
port(	  
	-- represents movement trigger entity, which indicates train demand
	-- to move the enter switch.
	move_trig_in   : in std_logic;

	-- represents status tracker entity, which indicates train entered
	-- railroad switch working area.
	status_in      : in std_logic;

	-- represents movement trigger entity, which indicates train demand
	-- to move the exit switch.
	move_trig_out  : in std_logic;

	-- represents ticker signal input.
	clk            : in std_logic;
	
	-- represents reset signal input.
	reset          : in std_logic;
	
	-- represents railroad enter switch movement state, which
	-- value can be used by the external business logic to
	-- activate input railroad switch.
	move_state_in  : out std_logic;

	-- represents railroad switch status state, which
	-- value can be used by the external business logic
	-- to track if the railroad switch railroad area
	-- is meant to be accessable.
	status_state   : out std_logic;
	
	-- represents railroad exit switch movement state, which
	-- value can be used by the external business logic to
	-- activate output railroad switch.
	move_state_out : out std_logic
);
end railroad_switch; 
            
architecture railroad_switch_ar of railroad_switch is
-- represents the complete set of actions used by FSM to perform railroad switch status updates. 
type FSM_status_state_type is (
	ACCESSABLE, 
	BUSY);
	
signal FSM_status_state : FSM_status_state_type := ACCESSABLE;	

-- represents the complete set of actions used by FSM to perform railroad input switch movement updates.
type FSM_move_input_state_type is (
	MOVE_INITIAL_INPUT_SWITCH,
	MOVE_TRIGERRED_INPUT_SWITCH); 
	
signal FSM_move_input_state : FSM_move_input_state_type := MOVE_INITIAL_INPUT_SWITCH;	

-- represents the complete set of actions used by FSM to perform railroad output switch movement updates.
type FSM_move_output_state_type is(
	MOVE_INITIAL_OUTPUT_SWITCH,
	MOVE_TRIGERRED_OUTPUT_SWITCH);
	
signal FSM_move_output_state : FSM_move_output_state_type := MOVE_INITIAL_OUTPUT_SWITCH;

signal status_state_temp   : std_logic := '0';
signal move_state_in_temp  : std_logic := '0';
signal move_state_out_temp : std_logic := '0';
begin				  			   
	-- provides the necessary logic to dispatch actions using trackers input data.
	dispatcher: process(clk, reset)
	begin				
		if rising_edge(clk) then
			if reset = '1' then
				FSM_status_state <= ACCESSABLE;
			else
				if move_trig_in = '1' and FSM_status_state = ACCESSABLE and FSM_move_output_state = MOVE_INITIAL_OUTPUT_SWITCH then   
					FSM_move_input_state <= MOVE_TRIGERRED_INPUT_SWITCH;
				elsif move_trig_in = '0' and FSM_status_state = ACCESSABLE and FSM_move_input_state = MOVE_TRIGERRED_INPUT_SWITCH then   
					FSM_move_input_state <= MOVE_INITIAL_INPUT_SWITCH;	
			 	end if;

				if status_in = '1' and FSM_status_state = ACCESSABLE and FSM_move_output_state = MOVE_INITIAL_OUTPUT_SWITCH and FSM_move_input_state = MOVE_INITIAL_INPUT_SWITCH then
					FSM_status_state <= BUSY;
				elsif status_in = '0' and FSM_status_state = BUSY then
					FSM_status_state <= ACCESSABLE; 
				end if;
				
				if move_trig_out = '1' and FSM_status_state = ACCESSABLE and FSM_move_input_state = MOVE_INITIAL_INPUT_SWITCH then
					FSM_move_output_state <= MOVE_TRIGERRED_OUTPUT_SWITCH; 
				elsif move_trig_out = '0' and FSM_status_state = ACCESSABLE and FSM_move_output_state = MOVE_TRIGERRED_OUTPUT_SWITCH then
					FSM_move_output_state <= MOVE_INITIAL_OUTPUT_SWITCH; 

					-- TODO: increase counter
				end if;
			end if;
		end if;		  
	end process dispatcher;
	
	-- provides the necessary logic to execute a dispatched action.
	reducers: process(clk, reset, FSM_status_state, FSM_move_input_state, FSM_move_output_state)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				status_state_temp   <= '0';
				move_state_in_temp  <= '0';
				move_state_out_temp <= '0';
			else
				-- handles status actions.
				case FSM_status_state is
				when ACCESSABLE =>
					status_state_temp <= '0';
				when BUSY =>
				 	status_state_temp <= '1';
				end case;	
			
				-- handles trigger movement input status.
				case FSM_move_input_state is
				when MOVE_INITIAL_INPUT_SWITCH =>
					move_state_in_temp <= '0';
				when MOVE_TRIGERRED_INPUT_SWITCH =>	
					move_state_in_temp <= '1';
				end case;
			
				-- handles trigger movement output status.
				case FSM_move_output_state is
				when MOVE_INITIAL_OUTPUT_SWITCH =>	 
				 	move_state_out_temp <= '0';
				when MOVE_TRIGERRED_OUTPUT_SWITCH =>
				 	move_state_out_temp <= '1';
				end case;
			end if;
		end if;
		
		-- saves temporate status state to a proper output signal.
		status_state   <= status_state_temp;
		
		-- saves temporate enter switch movement state to a proper output signal.
		move_state_in  <= move_state_in_temp;
		
		-- saves temporate exit switch movement state to a proper output signal.
		move_state_out <= move_state_out_temp;
	end process reducers;
end railroad_switch_ar;