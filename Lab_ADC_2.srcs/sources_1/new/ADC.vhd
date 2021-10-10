
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ADC is
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
end ADC;

architecture Behavioral of ADC is

Type state is (Idle, start_conv, sample, average, write, end_wait);
signal current_state : State := Idle; 
signal cs_counter : integer range 0 to 200 := 0; -- Counter for 500k samples per second
signal adc_clk_div : integer range 0 to 3 := 0; --12.5Mh clk for sch
signal parrallel_data : std_logic_vector (16 downto 0) := (others => '0');
signal sclk_o : std_logic;
signal data_index : integer range 0 to 14:= 14;  --its not twelve because we get some zeros in beginning
signal first_bit: std_logic;
signal was_obtained: std_logic;
signal was_written: std_logic;
signal addra_o : std_logic_vector (13 downto 0) := (others => '0');
signal dina_ram : std_logic_vector (11 downto 0) := (others => '0');

signal indice : integer range 0 to 32 := 0;
signal averaged : std_logic_vector(11 downto 0);

type r_data is array (0 to 31) of std_logic_vector(16 downto 0);
signal t_data  : r_data;
begin

process(clk_100mhz, reset, current_state)
    
begin

if(reset = '1') then
    sclk_o <= '1';
    addra_o <= (others => '0');
    parrallel_data <= (others => '0');
    first_bit <= '1';
    was_obtained <= '0';
    was_written <= '0';
    cs_n <= '1';
    current_state <= idle;
    busy <= '0';
elsif rising_edge(clk_100mhz) then 
    
    if(current_state = idle) then
        sclk_o <= '1';
        addra_o <= (others => '0');
        first_bit <= '1';
        was_obtained <= '0';
        was_written <= '0';
        cs_n <= '1';
        busy <= '0';
        if(start = '1') then 
            current_state <= start_conv;
        else
            current_state <= idle;
        end if;
        
    elsif(current_state = start_conv) then
        ready <= '0';
        adc_clk_div <= 0; 
        busy <= '1';
        if(cs_counter < 200) then  --wait here until a data is converted
            cs_n <= '0';
            current_state <= start_conv;
            cs_counter <= cs_counter + 1;
        else
            sclk_o <= '0';
            adc_clk_div <= 0;
            cs_counter <= 0;
            if(addra_o < x"3FFF") then
                cs_n <= '0';
                if (was_written = '1') then
                    addra_o <= addra_o + 1;
                    was_written <= '0';
                end if;
                parrallel_data <= (others => '0');
                current_state <= sample;
            else
                cs_n <= '1';
                ready <= '1';
                busy <= '0';
                current_state <= end_wait;
            end if;
        end if;
         
    elsif(current_state = sample) then
        cs_counter <= cs_counter + 1;
        busy <= '1';
            
        if(adc_clk_div < 3) then
            adc_clk_div <= adc_clk_div + 1;
        else
            adc_clk_div <= 0;
            sclk_o <= not(sclk_o);
            first_bit <= '0';
        end if;
        if(sclk_o = '1' and first_bit <= '0') then 
            parrallel_data(data_index) <= spi_data_in;   --loads sdata in MSB of paralleldata
            first_bit <= '1';
            if(data_index > 0) then 
                data_index <= data_index - 1;
                current_state <= sample;
            else
                data_index <= 14;    --paralleldata is fully loaded hence we dont load more
                cs_n <= '1';
                current_state <= average;    --as 12bit is fully received
            end if;
        end if;
  
    elsif(current_state = average) then
        if (indice < 32) then
            t_data(indice) <= ("00000" & parrallel_data(11 downto 0));
            indice <= indice + 1;
        else
            parrallel_data <= t_data(indice - 1) + t_data(indice - 2) + t_data(indice - 3) + t_data(indice - 4) + t_data(indice - 5) + t_data(indice - 6) + t_data(indice - 7) + t_data(indice - 8) + t_data(indice - 9) + t_data(indice - 10) + t_data(indice - 11) + t_data(indice - 12) + t_data(indice - 13) + t_data(indice - 14) + t_data(indice - 15) + t_data(indice - 16) + t_data(indice - 17) + t_data(indice - 18) + t_data(indice - 19) + t_data(indice - 20) + t_data(indice - 21) + t_data(indice - 22) + t_data(indice - 23) + t_data(indice - 24) + t_data(indice - 25) + t_data(indice - 26) + t_data(indice - 27) + t_data(indice - 28) + t_data(indice - 29) + t_data(indice - 30) + t_data(indice - 31) + t_data(indice - 32);
            indice <= 0;
			averaged <= parrallel_data(16 downto 5); --divided by 32 by taking the 12 most significant digits
			was_obtained <= '1';
        end if;
        current_state <= write;
        
    elsif(current_state = write) then 
        if (was_obtained = '1') then
            dina_ram <= averaged;
            was_obtained <= '0';
            was_written <= '1';
        end if;
        current_state <= start_conv;
        
    else
        current_state <= end_wait;
    end if;
 end if;
end process; 

mem_data_out <= dina_ram;
spi_clk <= sclk_o;
mem_addr_in <= addra_o;


end Behavioral;
