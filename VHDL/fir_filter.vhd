library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.all;
use IEEE.numeric_std.all;

entity fir_filter is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           a1 : in STD_LOGIC_VECTOR (7 downto 0);
           a2 : in STD_LOGIC_VECTOR (7 downto 0);
           a3 : in STD_LOGIC_VECTOR (7 downto 0);
           a4 : in STD_LOGIC_VECTOR (7 downto 0);
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_data : out STD_LOGIC_VECTOR (7 downto 0));
end fir_filter;

architecture Behavioral of fir_filter is

component reg is
    Port ( clk        : in  std_logic;
           i : in STD_LOGIC_VECTOR (7 downto 0);
           o0 : out STD_LOGIC_VECTOR (7 downto 0);
           o1 : out STD_LOGIC_VECTOR (7 downto 0);
           o2 : out STD_LOGIC_VECTOR (7 downto 0);
           o3 : out STD_LOGIC_VECTOR (7 downto 0));
end component;

type t_data is array (0 to 3) of signed(7 downto 0);
type t_data_aux is array (0 to 3) of std_logic_vector (7 downto 0);
type t_coeff is array (0 to 3) of signed(7 downto 0);

type t_mult is array (0 to 3) of signed(15 downto 0);
type t_add_st0 is array (0 to 1) of signed(15+1 downto 0);

signal r_coeff : t_coeff ;
signal p_data : t_data;
signal p_data_aux : t_data_aux;
signal r_mult : t_mult;
signal r_add_st0 : t_add_st0;
signal r_add_st1 : signed(15+2  downto 0);

begin

    REG1: reg port map (clk => clk, i => i_data, o0 => p_data_aux(0), o1 => p_data_aux(1), o2 => p_data_aux(2), o3 => p_data_aux(3));
    
    p_input : process (rst, clk)
    begin
      if(rst='1') then
        p_data <= (others=>(others=>'0'));
        r_coeff <= (others=>(others=>'0'));
      elsif(rising_edge(clk)) then
        p_data(0) <= signed(p_data_aux(0));
        p_data(1) <= signed(p_data_aux(1));
        p_data(2) <= signed(p_data_aux(2));
        p_data(3) <= signed(p_data_aux(3));
        r_coeff(0) <= signed(a1);
        r_coeff(1) <= signed(a2);
        r_coeff(2) <= signed(a3);
        r_coeff(3) <= signed(a4);
      end if;
    end process p_input;
    
    p_mult : process (rst, clk)
    begin
      if(rst='1') then
        r_mult <= (others=>(others=>'0'));
      elsif(rising_edge(clk)) then
        for k in 0 to 3 loop
          r_mult(k) <= p_data(k) * r_coeff(k);
        end loop;
      end if;
    end process p_mult;
    
    p_add_st0 : process (rst, clk)
    begin
      if(rst='1') then
        r_add_st0 <= (others=>(others=>'0'));
      elsif(rising_edge(clk)) then
        for k in 0 to 1 loop
          r_add_st0(k) <= resize(r_mult(2*k),17)  + resize(r_mult(2*k+1),17);
        end loop;
      end if;
    end process p_add_st0;
    
    p_add_st1 : process (rst, clk)
    begin
      if(rst='1') then
        r_add_st1 <= (others=>'0');
      elsif(rising_edge(clk)) then
        r_add_st1 <= resize(r_add_st0(0),18)  + resize(r_add_st0(1),18);
      end if;
    end process p_add_st1;
    
    p_output : process (rst,clk)
    begin
      if(rst='1') then
        o_data <= (others=>'0');
      elsif(rising_edge(clk)) then
        o_data <= std_logic_vector(r_add_st1(17 downto 10));
      end if;
    end process p_output;

end Behavioral;
