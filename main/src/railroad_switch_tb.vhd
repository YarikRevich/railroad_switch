library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity railroad_switch_tb is
end railroad_switch_tb;	  

architecture railroad_switch_ar_tb of railroad_switch_tb is
signal status_in      : std_logic := '0';
signal status_out     : std_logic := '0';
signal move_trig_in   : std_logic := '0';
signal move_trig_out  : std_logic := '0';
signal clk            : std_logic := '0';
signal reset          : std_logic := '0';
signal status_state   : std_logic := '0';
signal move_state_in  : std_logic := '0';
signal move_state_out : std_logic := '0';
begin			  
	uut: entity work.railroad_switch port map(
		status_in => status_in,
		status_out => status_out,
		move_trig_in => move_trig_in,
		move_trig_out => move_trig_out,
		clk => clk,	 
		reset => reset,				   
		status_state => status_state,
		move_state_in => move_state_in,
		move_state_out => move_state_out
	);
	
	clk <= not clk after 5ns;
	
	reset <= not reset after 1000ns;
	
	process
	begin	
		wait for 20ns;
		-- immitates the signal of an external device, which
		-- triggerres, when the train comes close and indicates
		-- that enter switch should be activated.
		move_trig_in <= '1';
		
		wait for 30ns;
		-- resets the state of an external device, which triggerres,
		-- when	the train comes close and indicates the further movement
		-- of the train.
		move_trig_in <= '0';
		
		wait for 40ns;
		-- immitates the signal of an external device, which
		-- triggerres, when the train comes close and indicates
		-- that the train entered the one way area.
		status_in <= not status_in;
		
		wait for 50ns;
		-- resets the state of an external device, which triggerres,
		-- when	the train comes close and indicates that the train
		-- entered the one way area.
		status_in <= not status_in;
		
		wait for 60ns;
		-- immitates the signal of an external device, which
		-- triggerres, when the train leaves the one way area.
		status_out <= not status_out;  
		
		wait for 70ns;
		-- resets the state of an external device, which triggerres,
		-- when	the train comes close and indicates that the train
		-- exited the one way area.
		status_out <= not status_out;
		
		wait for 80ns;
		-- immitates the signal of an external device, which
		-- triggerres, when the train comes close and indicates
		-- that exit switch should be activates.
		move_trig_out <= '1';
		
		wait for 90ns;
		-- resets the state of an external device, which triggrerres
		-- when the train comes close and indicates the further movement
		-- of the train.
		move_trig_out <= '0';
	end process; 
end railroad_switch_ar_tb;