library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg2 is
    Port ( clk : in STD_LOGIC;
           i : in STD_LOGIC_VECTOR (7 downto 0);
           o0 : out STD_LOGIC_VECTOR (7 downto 0);
           o1 : out STD_LOGIC_VECTOR (7 downto 0));
end reg2;

architecture Behavioral of reg2 is

type t_reg is array (0 to 1) of std_logic_vector(7  downto 0);
signal a : t_reg := (others=>(others=>'0'));

begin
    process(clk)
    begin
        if rising_edge (clk) then
            a(1) <= a(0);
            a(0) <= i;
            
            o0 <= a(1);
            o1 <= a(0);
        end if;            
    end process;

end Behavioral;
