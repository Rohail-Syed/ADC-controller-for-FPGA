library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
 
entity FSM_new is
  port (
    clk             : in std_logic;
    mem_data_in     : in  std_logic_vector(11 downto 0);
    start           : in std_logic;
    reset           : in std_logic;
    Data            : out  std_logic_vector(7 downto 0);
    mem_addr_out    : out  std_logic_vector(13 downto 0)
    );
end FSM_new;
 
 
architecture RTL of FSM_new is
 
type t_SM_Main is (s_H1, s_H2, s_H3, s_H4,
                   s_D1, s_D2, s_D3, s_D4,
                   s_S1, s_S2, s_S3, s_S4);
                     
signal r_SM_Main : t_SM_Main := s_H1;

signal r_Data : std_logic_vector(7 downto 0) := x"03";
signal r_mem_addr_out : std_logic_vector(13 downto 0) := (others => '0');
signal r_sent : std_logic;

signal count: integer:=0;
signal tmp : std_logic := '0';

begin

process(clk)
begin
    if rising_edge(clk) then
        count <= count + 1;
        if (count = 2500) then
        tmp <= not tmp;
        count <= 0;
        end if;
    end if;
end process;

process (tmp,reset,start)
begin
    if reset = '1' then
        r_mem_addr_out <= (others => '0');
        r_SM_Main <= s_H1;
        elsif rising_edge(tmp) then
            if reset = '0' and start = '1' then
                case r_SM_Main is
                    when s_H1 =>
                        r_Data <= x"55";
                        r_SM_Main <= s_H2;
                    when s_H2 =>
                        r_Data <= x"AA";
                        r_SM_Main <= s_H3;        
                    when s_H3 =>
                        r_Data <= x"CC";
                        r_SM_Main <= s_H4;
                    when s_H4 =>
                        r_Data <= x"03";
                        r_SM_Main <= s_D1;
                    when s_D1 =>
                        r_Data <= "0000"&mem_data_in(11 downto 8);
                        r_SM_Main <= s_D2;
                    when s_D2 =>
                        r_Data <= mem_data_in(7 downto 0);
                        r_mem_addr_out <= r_mem_addr_out + '1';
                        if r_mem_addr_out = "11111111111111" then
                            r_SM_Main <= s_S1;
                        else
                            r_SM_Main <= s_D1;
                        end if;
--                        r_SM_Main <= s_D3;
--                    when s_D3 =>
--                        r_Data <= mem_data_in(15 downto 8);
--                        r_SM_Main <= s_D4;
--                    when s_D4 =>
--                        r_Data <= mem_data_in(7 downto 0);
--                        r_mem_addr_out <= r_mem_addr_out + '1';
--                        if r_mem_addr_out = "00000000000111" then
--                            r_SM_Main <= s_S1;
--                        else
--                            r_SM_Main <= s_D1;
--                        end if;
                    when s_S1 =>
                        r_Data <= x"AA";
                        r_SM_Main <= s_S2;  
                    when s_S2 =>
                        r_Data <= x"55";
                        r_SM_Main <= s_S3;
                    when s_S3 =>
                        r_Data <= x"03";
                        r_SM_Main <= s_S4;
                    when s_S4 =>
                        r_Data <= x"CC";
                        r_SM_Main <= s_H1;
                    when others =>
                        r_SM_Main <= s_H1;
                end case;
            end if;
    end if;
end process;

Data <= r_Data;
mem_addr_out <= r_mem_addr_out;
end RTL;