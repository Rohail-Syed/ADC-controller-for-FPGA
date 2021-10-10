library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Lab_Debug is
    Port ( clk_100mhz : in STD_LOGIC;
           reset : in STD_LOGIC;
           start : in STD_LOGIC;
           data_in : in std_logic_vector(11 downto 0);
           addrb : out std_logic_vector(13 downto 0);
           txd : out STD_LOGIC;
           idle : out std_logic);
end Lab_Debug;

architecture Behavioral of Lab_Debug is

signal ready_wire : std_logic;
--signal mem_data_in_wire : std_logic_vector(11 downto 0);
signal Data_wire : std_logic_vector(7 downto 0);

signal active_wire  : std_logic;

--signal wea_wire : STD_LOGIC_VECTOR(0 DOWNTO 0);
signal doutb  : STD_LOGIC_VECTOR(11 DOWNTO 0);
signal addrb_wire : std_logic_vector(13 downto 0);

component FSM_new is
  port (
    clk             : in std_logic;
    mem_data_in     : in  std_logic_vector(11 downto 0);
    start           : in std_logic;
    reset           : in std_logic;
    Data            : out  std_logic_vector(7 downto 0);
    mem_addr_out    : out  std_logic_vector(13 downto 0)
    );
end component;

component UART_FSM is
  generic (
    g_CLKS_PER_BIT : integer := 500     -- Needs to be set correctly
    );
  port (
    i_Clk       : in  std_logic;
    i_TX_DV     : in  std_logic;
    i_TX_Byte   : in  std_logic_vector(7 downto 0);
    o_TX_Active : out std_logic;
    o_TX_Serial : out std_logic;
    o_TX_Done   : out std_logic
    );
end component;

begin

controller : FSM_new PORT MAP(
clk => clk_100mhz,
mem_data_in => data_in,
start => start,
reset => reset,
Data => Data_wire,
mem_addr_out => addrb);

UART : UART_FSM PORT MAP(
i_Clk => clk_100mhz,
i_TX_DV => start,
i_TX_Byte => Data_wire,
o_TX_Active => active_wire,
o_TX_Serial => txd,
o_TX_Done => ready_wire);

idle <= active_wire;
end Behavioral;
