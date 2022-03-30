library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg is
    Port ( clk        : in  std_logic;
           i : in STD_LOGIC_VECTOR (7 downto 0);
           o0 : out STD_LOGIC_VECTOR (7 downto 0);
           o1 : out STD_LOGIC_VECTOR (7 downto 0);
           o2 : out STD_LOGIC_VECTOR (7 downto 0);
           o3 : out STD_LOGIC_VECTOR (7 downto 0));
end reg;

architecture Behavioral of reg is
    type t_reg is array (0 to 3) of std_logic_vector(7  downto 0);
    signal a : t_reg := (others=>(others=>'0')); -- initialised as all '0's

begin
    process(clk)
    begin
        if rising_edge (clk) then
            for i in 3 downto 1 loop
                a(i) <= a(i-1);
            end loop;
            a(0) <= i;
            
            o0 <= a(3);
            o1 <= a(2);
            o2 <= a(1);
            o3 <= a(0);
        end if;            
    end process;


end Behavioral;
