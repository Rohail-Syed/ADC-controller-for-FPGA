library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ADC_top_module is
    Port (  clk : in std_logic;
            reset: in std_logic;
            start: in std_logic;
            reset_1 : in std_logic;
            start_1 : in std_logic;
            sclk: out std_logic;
            txd: out std_logic;
            cs: out std_logic;
            s_data_in: in std_logic;
            busy: out std_logic;
            finish: out std_logic);
end ADC_top_module;

architecture Behavioral of ADC_top_module is

signal ram_data_a: std_logic_vector(11 downto 0);
signal ram_addr_a: std_logic_vector(13 downto 0);
signal ram_data_b: std_logic_vector(11 downto 0);
signal ram_addr_b: std_logic_vector(13 downto 0);
signal port_b_en: std_logic := '1';
signal port_a_we: std_logic_vector(0 downto 0) := "1";
signal send: std_logic := '0';
signal data_uart: std_logic_vector(7 downto 0);
signal fin: std_logic := '0';
signal t_busy: std_logic := '1';

component ADC is
    Port ( reset: in std_logic;
           clk_100mhz: in std_logic;
           spi_data_in: in std_logic;
           start: in std_logic;
           spi_clk: out std_logic;
           cs_n: out std_logic;
           mem_addr_in : out std_logic_vector(13 downto 0);
           mem_data_out: out std_logic_vector(11 downto 0);
           busy: out std_logic;
           ready: out std_logic);
end component;

component design_1_wrapper is
    port (
        BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 13 downto 0 );
        BRAM_PORTA_0_clk : in STD_LOGIC;
        BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 11 downto 0 );
        BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 );
        BRAM_PORTB_0_addr : in STD_LOGIC_VECTOR ( 13 downto 0 );
        BRAM_PORTB_0_clk : in STD_LOGIC;
        BRAM_PORTB_0_dout : out STD_LOGIC_VECTOR ( 11 downto 0 );
        BRAM_PORTB_0_en : in STD_LOGIC);  
end component;

component Lab_Debug is
    Port ( clk_100mhz : in STD_LOGIC;
           reset : in STD_LOGIC;
           start : in STD_LOGIC;
           data_in : in std_logic_vector(11 downto 0);
           addrb : out std_logic_vector(13 downto 0);
           txd : out STD_LOGIC;
           idle : out std_logic);
end component;

begin

C1: ADC port map(reset => reset, clk_100mhz => clk, spi_data_in => s_data_in, start => start, 
                 spi_clk => sclk, cs_n => cs, mem_addr_in => ram_addr_a, mem_data_out => ram_data_a, busy => t_busy, ready => finish);
                 
C2: design_1_wrapper port map(BRAM_PORTA_0_addr => ram_addr_a, BRAM_PORTA_0_clk => clk, BRAM_PORTA_0_din => ram_data_a,
                              BRAM_PORTA_0_we => port_a_we, BRAM_PORTB_0_addr => ram_addr_b, BRAM_PORTB_0_clk => clk, BRAM_PORTB_0_dout => ram_data_b, BRAM_PORTB_0_en => port_b_en);

UART : Lab_Debug PORT MAP(
clk_100mhz => clk,
start => start_1,
reset => reset_1,
data_in => ram_data_b,
addrb => ram_addr_b,
txd => txd,
idle => busy);
                    
end Behavioral;


