library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity decodificador is
	Port (
		diga: in std_logic_vector(2 downto 0);
		clk: in std_logic;
		digb: in std_logic_vector(3 downto 0);
		digo,digt: out std_logic;
		digout: out std_logic_vector(6 downto 0)
		);
attribute LOC : string;
attribute LOC of digout: signal is "P23 P22 P21 P20 P19 P18 P17";
attribute LOC of diga: signal is "P1 P2 P3";
attribute LOC of digb: signal is "P4 P5 P6 P7";
attribute LOC of clk: signal is "P10";
end decodificador;


architecture behavioral of decodificador is

begin
process(diga,digb,clk)
begin
digo<=not(clk);
digt<=clk;
if clk = '1' then
 case diga is
   when "000" => digout<="1111110";
   when "001" => digout<="0110000";
   when "010" => digout<="1101101";
   when "011" => digout<="1111001";
   when "100" => digout<="0110011";
   when "101" => digout<="1011011";
   when others => digout<="0000000";
 end case;
else
 case digb is
   when "0000" => digout<="1111110";
   when "0001" => digout<="0110000";
   when "0010" => digout<="1101101";
   when "0011" => digout<="1111001";
   when "0100" => digout<="0110011";
   when "0101" => digout<="1011011";
   when "0110" => digout<="1011111";
   when "0111" => digout<="1110000";
   when "1000" => digout<="1111111";
   when "1001" => digout<="1110011";
   when others => digout<="0000000";
 end case;
end if;



end process;
end behavioral;

