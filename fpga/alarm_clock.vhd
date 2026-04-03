library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alarm_clock is
    port (
        clk                 : in  std_logic;
        clock_mode          : in  std_logic_vector(1 downto 0);
        switches            : in  std_logic_vector(2 downto 0);
        edit_increment      : in  std_logic;
        edit_decrement      : in  std_logic;
        time_bcd            : in  std_logic_vector(23 downto 0);
		  alarm_reset			 : in	 std_logic;
        second_ones_segment : out std_logic_vector(6 downto 0);
        second_tens_segment : out std_logic_vector(6 downto 0);
        minute_ones_segment : out std_logic_vector(6 downto 0);
        minute_tens_segment : out std_logic_vector(6 downto 0);
        hour_ones_segment   : out std_logic_vector(6 downto 0);
        hour_tens_segment   : out std_logic_vector(6 downto 0);
		  alarm_activated		 : out std_logic
    );
end entity;

architecture behavior of alarm_clock is

    component bcd_decoder is
        port (
            bcd_in            : in  std_logic_vector(3 downto 0);
            seven_segment_out : out std_logic_vector(6 downto 0)
        );
    end component;

    function digit_to_slv(value : integer) return std_logic_vector is
    begin
        return std_logic_vector(to_unsigned(value, 4));
    end function;

    function edit_time(t : integer; inc : std_logic; dec : std_logic;
                       sw : std_logic_vector(2 downto 0)) return integer is
        variable h : integer range 0 to 23;
		  variable m : integer range 0 to 59;
		  variable s : integer range 0 to 59;
		  variable result : integer range 0 to 86399;
    begin
        h := t / 3600;
        m := (t mod 3600) / 60;
        s := t mod 60;
		  
        if inc = '1' then
            if sw(2) = '1' then h := (h + 1)  mod 24; end if;
            if sw(1) = '1' then m := (m + 1)  mod 60; end if;
            if sw(0) = '1' then s := (s + 1)  mod 60; end if;
        elsif dec = '1' then
            if sw(2) = '1' then h := (h + 23) mod 24; end if;
            if sw(1) = '1' then m := (m + 59) mod 60; end if;
            if sw(0) = '1' then s := (s + 59) mod 60; end if;
        end if;
        result := h * 3600 + m * 60 + s;
		  return result;
    end function;

    signal current_time    : integer range 0 to 86399 := 0;
    signal alarm_time      : integer range 0 to 86399 := 86399;
    signal one_sec_counter : unsigned(25 downto 0)    := (others => '0');
    signal time_loaded     : std_logic                := '0';

	 signal alarm_active : std_logic := '0';
	 
    signal disp_sec_ones, disp_sec_tens : std_logic_vector(3 downto 0) := (others => '0');
    signal disp_min_ones, disp_min_tens : std_logic_vector(3 downto 0) := (others => '0');
    signal disp_hr_ones,  disp_hr_tens  : std_logic_vector(3 downto 0) := (others => '0');
	 
	 signal raw_sec_ones, raw_sec_tens : std_logic_vector(6 downto 0);
	 signal raw_min_ones, raw_min_tens : std_logic_vector(6 downto 0);
	 signal raw_hr_ones,  raw_hr_tens  : std_logic_vector(6 downto 0);
	 
	 signal blink_counter : unsigned(24 downto 0) := (others => '0');
	 signal blink_on      : std_logic := '1';

begin

	alarm_activated <= alarm_active;

    process(clk)
        variable shown   : integer range 0 to 86399;
        variable h, m, s : integer;
    begin
        if rising_edge(clk) then
            if time_loaded = '0' then
                h := to_integer(unsigned(time_bcd(23 downto 20))) * 10
                   + to_integer(unsigned(time_bcd(19 downto 16)));
                m := to_integer(unsigned(time_bcd(15 downto 12))) * 10
                   + to_integer(unsigned(time_bcd(11 downto 8)));
                s := to_integer(unsigned(time_bcd(7  downto 4)))  * 10
                   + to_integer(unsigned(time_bcd(3  downto 0)));
                current_time    <= h * 3600 + m * 60 + s;
                alarm_time      <= 86399;
                one_sec_counter <= (others => '0');
                time_loaded     <= '1';
            else
					  if one_sec_counter = 49999999 then
							one_sec_counter <= (others => '0');
							if clock_mode /= "10" then
								current_time <= (current_time + 1) mod 86400;
								if (current_time + 1) mod 86400 = alarm_time then
									alarm_active <= '1';
								end if;
							end if;
					  else
							one_sec_counter <= one_sec_counter + 1;
					  end if;
					  
					  -- Blink counter (~2Hz)
						if blink_counter = 24999999 then
							blink_counter <= (others => '0');
							blink_on <= not blink_on;
						else
							blink_counter <= blink_counter + 1;
						end if;
					  
						if alarm_reset = '1' then
							alarm_active <= '0';
						end if;

                if clock_mode = "10" then
                    current_time <= edit_time(current_time, edit_increment,
                                              edit_decrement, switches);
                elsif clock_mode = "11" then
                    alarm_time   <= edit_time(alarm_time, edit_increment,
                                              edit_decrement, switches);
                end if;
            end if;

            if clock_mode = "01" or clock_mode = "11" then
                shown := alarm_time;
            else
                shown := current_time;
            end if;

            h := shown / 3600;
            m := (shown mod 3600) / 60;
            s := shown mod 60;

            disp_hr_tens  <= digit_to_slv(h / 10);
				disp_hr_ones  <= digit_to_slv(h mod 10);
				disp_min_tens <= digit_to_slv(m / 10);
				disp_min_ones <= digit_to_slv(m mod 10);
				disp_sec_tens <= digit_to_slv(s / 10);
				disp_sec_ones <= digit_to_slv(s mod 10);
        end if;
    end process;

		SEC_ONES_DEC : bcd_decoder port map (bcd_in => disp_sec_ones, seven_segment_out => raw_sec_ones);
		SEC_TENS_DEC : bcd_decoder port map (bcd_in => disp_sec_tens, seven_segment_out => raw_sec_tens);
		MIN_ONES_DEC : bcd_decoder port map (bcd_in => disp_min_ones, seven_segment_out => raw_min_ones);
		MIN_TENS_DEC : bcd_decoder port map (bcd_in => disp_min_tens, seven_segment_out => raw_min_tens);
		HR_ONES_DEC  : bcd_decoder port map (bcd_in => disp_hr_ones,  seven_segment_out => raw_hr_ones);
		HR_TENS_DEC  : bcd_decoder port map (bcd_in => disp_hr_tens,  seven_segment_out => raw_hr_tens);

		-- Apply blinking
		second_ones_segment <= "1111111" when (clock_mode = "10" or clock_mode = "11") and switches(0) = '1' and blink_on = '0' else raw_sec_ones;
		second_tens_segment <= "1111111" when (clock_mode = "10" or clock_mode = "11") and switches(0) = '1' and blink_on = '0' else raw_sec_tens;
		minute_ones_segment <= "1111111" when (clock_mode = "10" or clock_mode = "11") and switches(1) = '1' and blink_on = '0' else raw_min_ones;
		minute_tens_segment <= "1111111" when (clock_mode = "10" or clock_mode = "11") and switches(1) = '1' and blink_on = '0' else raw_min_tens;
		hour_ones_segment   <= "1111111" when (clock_mode = "10" or clock_mode = "11") and switches(2) = '1' and blink_on = '0' else raw_hr_ones;
		hour_tens_segment   <= "1111111" when (clock_mode = "10" or clock_mode = "11") and switches(2) = '1' and blink_on = '0' else raw_hr_tens;

end architecture;