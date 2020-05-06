--*****************************************************************************
--Title		:8LEDs Train Collision project
--School	:Daan_Elevtronics(4113)
--Author	:Jacky Lin
--CPLD		:Altera MAXII EPM1270T144C5
--Date		:109-04-01
--Utiliy	:00000000
--           10000001
--			 11000011
--			 11100111
--			 11111111
--*****************************************************************************
--1.Libraries Declarations & Packages usage
library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--*****************************************************************************
--2.Entity Declarations
entity Coillision_LEDs is
generic(fmax : integer := 5E7);
port(
	--input pins
	Clk_50M		:in std_logic;						--Pin = 18 , 50MHz
	dip_sw		:in std_logic_vector(2 downto 0);	--Pin = 15, 16, 20, 21
	dp			:in std_logic;
	--output pins
	rgb_led : out std_logic_vector(2 downto 0);		--Pin = 32, 38, 37
	led_act : out std_logic_vector(7 downto 0)		--Pin = 22 ~ 31
	);
end Coillision_LEDs;
--*****************************************************************************
--3.Architectures(Body)
architecture beh of Coillision_LEDs is
--Global Singal's Declaration
signal pulsed_wave	: std_logic_vector(2 downto 0);	--10, 5, now_used
signal flag			: integer range 0 to 15;
signal scan			: integer range 0 to 7;
signal temp			: std_logic_vector(7 downto 0);
-------------------------------------------------------------------------------
begin
	---------------------------------------------------------------------------
	--1. 2 to 1 MUX
	pulsed_wave(0) <= pulsed_wave(2) when(dp = '1')else
					  pulsed_wave(1);
	---------------------------------------------------------------------------
	--Pulsed Wave
	process(Clk_50M) --Sensitivity List
		variable cnt_pulsed_01 : std_logic_vector(25 downto 0);
		variable cnt_pulsed_02 : std_logic_vector(25 downto 0);
	begin
		if(Clk_50M'event and Clk_50M = '1') then--Positive-Edge Trigger
			--10Hz
			if(cnt_pulsed_01 < fmax/10 - 1) then -- Denominator = Output Frequency
				pulsed_wave(2) <= '0';
				cnt_pulsed_01 := cnt_pulsed_01 + 1;
			else
				pulsed_wave(2) <= '1';
				cnt_pulsed_01 :=(others => '0'); --clear
			end if;
			--5Hz
			if(cnt_pulsed_02 < fmax/5 - 1) then -- Denominator = Output Frequency
				pulsed_wave(1) <= '0';
				cnt_pulsed_02 := cnt_pulsed_02 + 1;
			else
				pulsed_wave(1) <= '1';
				cnt_pulsed_02 :=(others => '0'); --clear
			end if;
		end if;
	end process;
	---------------------------------------------------------------------------
	--1.Pili LED Scan
	process(Clk_50M) --Sensitivity List
	begin
		if(Clk_50M'event and Clk_50M = '1')then	--Positive-Edge Trigger
			if(pulsed_wave(0) = '1')then
				if (flag >= 4)then				
					scan <= scan - 1;
				elsif(flag < 4)then
					scan <= scan + 1;
				end if;
				if(flag > 7)then
					flag <= 0;
					scan <= 0;
				else
					flag <= flag + 1;
				end if;
			end if;
		end if;
	end process;
	---------------------------------------------------------------------------
	--2.Pili LED decoder and O/P
	with scan select
	temp <= "00000000" when 0,
			"10000001" when 1,
			"11000011" when 2,
			"11100111" when 3,
			"11111111" when 4,
			"00000000" when others;
	---------------------------------------------------------------------------
	led_act <= not temp;
	rgb_led <= "011" when(dip_sw = "000")else
			   "101" when(dip_sw = "001")else
			   "110" when(dip_sw = "010")else
			   "001" when(dip_sw = "011")else
			   "010" when(dip_sw = "100")else
			   "100" when(dip_sw = "101")else
			   "000" when(dip_sw = "110")else
			   "000" ;
--*****************************************************************************
end beh;
