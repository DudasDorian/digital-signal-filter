-- if X(k) is in interval (a, b) then (others => '1') else (others => '0')
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity simple_filter2 is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           a : in STD_LOGIC_VECTOR (7 downto 0);
           b : in STD_LOGIC_VECTOR (7 downto 0);
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_data : out STD_LOGIC_VECTOR (7 downto 0));
end simple_filter2;

architecture Behavioral of simple_filter2 is

begin
    process (rst, clk)
    begin
      if(rst='1') then
        o_data <= (others => '0');
      elsif(rising_edge(clk)) then
        if (i_data > a and i_data < b) then
            o_data <= x"7f";
        else
            o_data <= (others => '0');
        end if;
      end if;
    end process;

end Behavioral;
