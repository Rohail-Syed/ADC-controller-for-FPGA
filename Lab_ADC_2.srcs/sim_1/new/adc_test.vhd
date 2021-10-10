----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.11.2020 18:37:05
-- Design Name: 
-- Module Name: adc_test - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity adc_test is
--  Port ( );
end adc_test;

architecture Behavioral of adc_test is

    component ADC
        port ( reset: in std_logic;
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
    
    component design_1_wrapper
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

    signal clk_100mhz: std_logic;
    signal reset: std_logic := '0';
    signal start: std_logic := '1';
    signal spi_clk : std_logic;
    signal cs_n: std_logic;
    signal spi_data_in: std_logic := '0';
    signal mem_addr_in: std_logic_vector(13 downto 0);
    signal mem_data_a: std_logic_vector(11 downto 0);
    signal mem_data_b: std_logic_vector(11 downto 0);
    signal busy: std_logic;
    signal ready: std_logic;
    
begin
  

  clk_generator: process
  begin
      wait for 5 ns;
      clk_100mhz <= '0';
      wait for 5 ns;
      clk_100mhz <= '1';
  end process;
  
  spi_data_generator: process
      variable err_count : integer range 0 to 3 := 0;
      variable count : integer range 0 to 2 := 0;
      variable data_index : std_logic_vector(2 downto 0) := (others => '0');
      variable current_data : std_logic_vector(2 downto 0) := "010";
      variable spi_conv_duration : std_logic := '1';
      variable first_data: std_logic := '1';
  begin
      if (spi_conv_duration = '1') then
          if (first_data = '1') then
              wait for 1110 ns;
              first_data := '0';
          end if;
          wait for 910 ns;
          spi_conv_duration := '0';
      else
          if (data_index(1 downto 0) = "11") and (count = 2) then
              err_count := 0;
              count := 0;
              data_index := data_index + 1;
              spi_data_in <= '0';
              spi_conv_duration := '1';
          else
              if(err_count < 3) then
                  spi_data_in <= '0';
                  err_count := err_count + 1;
              else
                  if (data_index = "000") then
                    current_data := (others => '1');--"010";
                  elsif (data_index = "001") then
                    current_data := (others => '1');--"001";
                  elsif (data_index = "010") then
                    current_data := (others => '1');--"111";
                  elsif (data_index = "011") then
                    current_data := (others => '1');--"100";
                  elsif (data_index = "100") then
                    current_data := (others => '1');--"110";
                  elsif (data_index = "101") then
                    current_data := (others => '1');--"000";
                  elsif (data_index = "110") then
                    current_data := (others => '1');--"011";
                  elsif (data_index = "111") then
                    current_data := (others => '1');--"101";
                  end if;
                  spi_data_in <= current_data(count);
                  if (count = 2) then
                      count := 0;
                      data_index := data_index + 1;
                  else
                      count := count + 1;
                  end if;
              end if;
              wait for 80 ns;
          end if;
      end if;
  end process;

  uut1: ADC 
  port map ( reset          => reset,
             clk_100mhz     => clk_100mhz,
             spi_data_in    => spi_data_in,
             start          => start,
             spi_clk        => spi_clk,
             cs_n           => cs_n,
             mem_addr_in    => mem_addr_in,
             mem_data_out   => mem_data_a,
             busy           => busy,
             ready          => ready );

  uut2: design_1_wrapper
  port map( BRAM_PORTA_0_addr => mem_addr_in, 
            BRAM_PORTA_0_clk => clk_100mhz,
            BRAM_PORTA_0_din => mem_data_a,
            BRAM_PORTA_0_we => "1",
            BRAM_PORTB_0_addr => mem_addr_in,
            BRAM_PORTB_0_clk => '0', 
            BRAM_PORTB_0_dout => mem_data_b,
            BRAM_PORTB_0_en => '0');

end Behavioral;
