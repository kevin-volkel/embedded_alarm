library ieee;
use ieee.std_logic_1164.all;

entity alarm_clock is
	port
	(	
		seconds_ones	:	in	std_logic_vector(3 downto 0);
		seconds_tens	:	in	std_logic_vector(3 downto 0);
		minutes_ones	:	in	std_logic_vector(3 downto 0);
		minutes_tens	:	in	std_logic_vector(3 downto 0);
		hours_ones		:	in	std_logic_vector(3 downto 0);
		hours_tens		:	in	std_logic_vector(3 downto 0);
		second_ones_segment	:	out	std_logic_vector(6 downto 0);
		second_tens_segment  :	out	std_logic_vector(6 downto 0);
		minute_ones_segment	:	out	std_logic_vector(6 downto 0);
		minute_tens_segment	:	out	std_logic_vector(6 downto 0);
		hour_ones_segment		:	out	std_logic_vector(6 downto 0);
		hour_tens_segment		:	out	std_logic_vector(6 downto 0)
	);
end entity;

architecture behavior of alarm_clock is
	component bcd_decoder is
		port
		(
			bcd_in : IN STD_LOGIC_VECTOR (3 downto 0); 
			seven_segment_out : OUT STD_LOGIC_VECTOR (6 downto 0)
		);
	end component;
	begin
			SEC_ONES: bcd_decoder port map (bcd_in => seconds_ones, seven_segment_out => second_ones_segment);
			SEC_TENS: bcd_decoder port map (bcd_in => seconds_tens, seven_segment_out => second_tens_segment);
		 
			MIN_ONES: bcd_decoder port map (bcd_in => minutes_ones, seven_segment_out => minute_ones_segment);
			MIN_TENS: bcd_decoder port map (bcd_in => minutes_tens, seven_segment_out => minute_tens_segment);
		 
			HR_ONES:  bcd_decoder port map (bcd_in => hours_ones,   seven_segment_out => hour_ones_segment);	
			HR_TENS:  bcd_decoder port map (bcd_in => hours_tens,   seven_segment_out => hour_tens_segment);
end architecture;