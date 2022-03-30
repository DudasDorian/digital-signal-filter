library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity top_level is
    generic(
BAUD_CLK_TICKS: integer := 12500000); -- 100 000 000 / {12 500 000} = 8 Hz

    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           dp : out STD_LOGIC;
           tx : out STD_LOGIC;
           rx : in STD_LOGIC);
end top_level;

architecture Behavioral of top_level is
    component UART
        port(
            clk            : in  std_logic;
            reset          : in  std_logic;
            tx_start       : in  std_logic;

            data_in        : in  std_logic_vector (7 downto 0);
            data_out       : out std_logic_vector (7 downto 0);

            rx             : in  std_logic;
            tx             : out std_logic
            );
    end component;
    
    component SSD is
        Port ( digit : in STD_LOGIC_VECTOR (15 downto 0);
               clk : in STD_LOGIC;
               an : out STD_LOGIC_VECTOR (3 downto 0);
               seg : out STD_LOGIC_VECTOR (6 downto 0));
    end component;
    
    component fir_filter is
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               a1 : in STD_LOGIC_VECTOR (7 downto 0);
               a2 : in STD_LOGIC_VECTOR (7 downto 0);
               a3 : in STD_LOGIC_VECTOR (7 downto 0);
               a4 : in STD_LOGIC_VECTOR (7 downto 0);
               i_data : in STD_LOGIC_VECTOR (7 downto 0);
               o_data : out STD_LOGIC_VECTOR (7 downto 0));
    end component;
    
    component simple_filter1 is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_data : out STD_LOGIC_VECTOR (7 downto 0));
    end component;
    
    component simple_filter2 is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           a : in STD_LOGIC_VECTOR (7 downto 0);
           b : in STD_LOGIC_VECTOR (7 downto 0);
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_data : out STD_LOGIC_VECTOR (7 downto 0));
    end component;
    
    -- RX/TX :
    signal rxtx_data_in, rxtx_data_out : std_logic_vector(7 downto 0);
    
    -- Synchronization :
    signal baud_rate_clk : std_logic := '0';
    
    -- filters :
    signal o_data0, o_data1, o_data2, o_data3 : std_logic_vector(7 downto 0);

begin

    dp <= '1';
    SSD1: SSD port map (digit => (others => '1'), clk => clk, an => an, seg => seg);

    UART_transceiver: UART
    port map(
            clk            => clk,
            reset          => btn(0),
            tx_start       => baud_rate_clk,
            data_in        => rxtx_data_in,
            data_out       => rxtx_data_out,
            rx             => rx,
            tx             => tx
            );

    generate_tx_start : process(clk)
    variable baud_count: integer range 0 to (BAUD_CLK_TICKS - 1) := (BAUD_CLK_TICKS - 1);
    begin
        if rising_edge(clk) then
            if (btn(0) = '1') then
                baud_rate_clk <= '0';
                baud_count := (BAUD_CLK_TICKS - 1);
            else
                if (baud_count = 0) then
                    baud_rate_clk <= '1';
                    baud_count := (BAUD_CLK_TICKS - 1);
                else
                    baud_rate_clk <= '0';
                    baud_count := baud_count - 1;
                end if;
            end if;
        end if;
    end process generate_tx_start;
    
    -- filter0::i_data <= rxtx_data_out, {a1, a2, a3, a4} preset
    
    -- butterworth coefficients multiplied by 10
    filter0: fir_filter Port map
               ( clk => baud_rate_clk,
               rst => btn(0),
               a1 => x"01",
               a2 => x"14",
               a3 => x"14",
               a4 => x"01",
               i_data => rxtx_data_out,
               o_data => o_data0);
               
    filter1: simple_filter1 Port map -- looks good doesn't work
                   ( clk => baud_rate_clk,
                   rst => btn(0),
                   i_data => rxtx_data_out,
                   o_data => o_data1);
    
    filter2: simple_filter2 Port map 
           ( clk => baud_rate_clk,
           rst => btn(0),
           a => x"01",
           b => x"7f",
           i_data => rxtx_data_out,
           o_data => o_data2);
    
    filter3: fir_filter Port map
               ( clk => baud_rate_clk,
               rst => btn(0),
               a1 => x"7f",
               a2 => x"1f",
               a3 => x"07",
               a4 => x"03",
               i_data => rxtx_data_out,
               o_data => o_data3);
    
    pick_filter : process(sw)
    begin
        -- selects filter
        filter_select : if (sw(0) = '1') then
            -- rxtx_data_in <= filter0::o_data; 
            rxtx_data_in <= o_data0;
        elsif (sw(1) = '1') then -- copy paste this    
            rxtx_data_in <= o_data2;        
        elsif (sw(2) = '1') then -- copy paste this
            rxtx_data_in <= o_data3;
        else
            rxtx_data_in <= rxtx_data_out;
        end if filter_select;
    end process pick_filter;

end Behavioral;
