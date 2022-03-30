-- if X(k) > X(x-1) then (others => '1') else (others => '0') 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.all;
use IEEE.numeric_std.all;

entity simple_filter1 is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_data : out STD_LOGIC_VECTOR (7 downto 0));
end simple_filter1;

architecture Behavioral of simple_filter1 is

component reg2 is
    Port ( clk        : in  std_logic;
           i : in STD_LOGIC_VECTOR (7 downto 0);
           o0 : out STD_LOGIC_VECTOR (7 downto 0);
           o1 : out STD_LOGIC_VECTOR (7 downto 0));
end component;

type t_data is array (0 to 1) of std_logic_vector(7 downto 0);

signal p_data, p_data_aux : t_data;

begin
    REG1: reg2 port map (clk => clk, i => i_data, o0 => p_data_aux(0), o1 => p_data_aux(1));
    
    p_input : process (rst, clk)
    begin
      if(rst='0') then
        p_data <= (others=>(others=>'0'));
      elsif(rising_edge(clk)) then
        p_data <= p_data_aux;
      end if;
    end process p_input;
    
    compare : process (rst, clk)
    begin
      if(rst='1') then
        o_data <= (others => '0');
      elsif(rising_edge(clk)) then
        if (to_integer(signed(p_data(1))) < to_integer(signed(p_data(0)))) then
            o_data <= x"7f";
        else
            o_data <= (others => '0');
        end if;
      end if;
    end process compare;

end Behavioral;
