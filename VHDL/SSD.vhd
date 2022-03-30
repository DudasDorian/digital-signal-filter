library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity SSD is
    Port ( digit : in STD_LOGIC_VECTOR (15 downto 0);
           clk : in STD_LOGIC;
           an : out STD_LOGIC_VECTOR (3 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0));
end SSD;

architecture Behavioral of SSD is

signal  cnt : std_logic_vector (15 downto 0);
signal output : std_logic_vector (3 downto 0);

begin
    process (clk)
    begin
        if rising_edge (clk) then
             if cnt = x"FFFF" then
                cnt <= x"0000";
            else
                cnt <= cnt + 1;
            end if;
        end if;
    end process;

    process (cnt, digit) -- the double MUX
    begin
        case cnt(15 downto 14) is
            when "00" => output <= digit(3 downto 0); an <= "1110";
            when "01" => output <= digit(7 downto 4); an <= "1101";
            when "10" => output <= digit(11 downto 8); an <= "1011";
            when others => output <= digit(15 downto 12); an <= "0111";
        end case;
    end process;
    
    process (output) -- the HEX to 7SD DCD
    begin
        case output is
--            when "0000" => seg <= "1000000";
--            when "0001" => seg <= "1111001";
--            when "0010" => seg <= "0100100";
--            when "0011" => seg <= "0110000";
--            when "0100" => seg <= "0011001";
--            when "0101" => seg <= "0010010";
--            when "0110" => seg <= "0000010";
--            when "0111" => seg <= "1111000";
--            when "1000" => seg <= "0000000";
--            when "1001" => seg <= "0010000";
--            when "1010" => seg <= "0001000";
--            when "1011" => seg <= "0000011";
--            when "1100" => seg <= "1000110";
--            when "1101" => seg <= "0100001";
--            when "1110" => seg <= "0000110";
--            when "1111" => seg <= "0001110";
            when others => seg <= "1111111";
        end  case;        
    end process;
end Behavioral;
