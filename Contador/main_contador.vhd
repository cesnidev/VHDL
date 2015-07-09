library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity contador is port(
clk, reset,arriba,start:in std_logic;
conta_1:buffer std_logic;
conta_9:buffer std_logic_vector(3 downto 0)
);
attribute LOC : string;
attribute LOC of clk: signal is "P1";
attribute LOC of reset: signal is "P2";
attribute LOC of arriba: signal is "P3";
attribute LOC of start: signal is "P4";
attribute LOC of conta_1: signal is "P23";
attribute LOC of conta_9: signal is "P20 P19 P18 P17";
end contador;	
 	 
architecture archicontador of contador is
begin
process (clk,reset)
begin

  if reset = '1' then
   conta_9 <= "0000";conta_1<='0';
  elsif (start='1'and(clk'event and clk= '1')) then
	   if (arriba = '1' and conta_9="1001") then
		conta_9 <= "0000";
	   elsif (arriba = '1' ) then  
		conta_9<=conta_9+1;
	   elsif (arriba = '0' and conta_9="0000") then
		 conta_9 <= "1001";
	   else	
		conta_9<=conta_9-1 ;
	   end if;


	   if reset = '1' then
	      conta_9 <= "0000";conta_1<='0';
	   elsif (start='1'and(clk'event and clk= '1')) then
	      if (arriba = '1' and conta_9="1001") then
		 conta_1 <= conta_1+1;
	      elsif (arriba = '0' and conta_9="0000") then
		 conta_1 <=conta_1-1;
	      end if;
	   end if;

if(conta_1='1') then
conta_1<='0';
elsif (conta_1='0') then
conta_1<='1';
end if;

  end if;
end process;
end archicontador;

