LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY bcd_decoder IS
    PORT
	 (
		bcd_in : IN STD_LOGIC_VECTOR (3 downto 0); 
		seven_segment_out : OUT STD_LOGIC_VECTOR (6 downto 0)
	 );
END bcd_decoder ;

architecture Behavioral of bcd_decoder is
begin
    process(bcd_in)
        variable A : STD_LOGIC := bcd_in(3) ;
        variable B : STD_LOGIC := bcd_in(2) ;
        variable C : STD_LOGIC := bcd_in(1) ;
        variable D : STD_LOGIC := bcd_in(0) ;
    begin
        seven_segment_out(0) <= NOT ((NOT B AND NOT D) OR C OR (B AND D) OR A) ;
        seven_segment_out(1) <= NOT (NOT B OR (NOT C AND NOT D) OR (C AND D)) ;
        seven_segment_out(2) <= NOT (NOT C OR D OR B) ;
        seven_segment_out(3) <= NOT ((NOT B AND NOT D) OR (NOT B AND C) OR (B AND NOT C AND D) OR (C AND NOT D) OR A) ;
        seven_segment_out(4) <= NOT ((NOT B AND NOT D) OR (C AND NOT D)) ;
        seven_segment_out(5) <= NOT ((NOT C AND NOT D) OR (B AND NOT C) OR (B AND NOT D) OR A) ;
        seven_segment_out(6) <= NOT ((NOT B AND C) OR (B AND NOT C) OR A OR (B AND NOT D)) ;
    end process;
end Behavioral;