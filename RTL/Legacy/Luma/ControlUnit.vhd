-- Copyright 2017 Andrea Giannini.
-- Copyright and related rights are licensed under the Solderpad Hardware
-- License, Version 0.51 (the “License”); you may not use this file except in
-- compliance with the License.  You may obtain a copy of the License at
-- http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
-- or agreed to in writing, software, hardware and materials distributed under
-- this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
-- CONDITIONS OF ANY KIND, either express or implied. See the License for the
-- specific language governing permissions and limitations under the License.
----------------------------------------------------------------------------------
-- Author: Andrea Giannini 
-- 
-- Create Date(mm/aaaa):	09/2017 
-- Module Name:			ControlUnit.vhd
-- Project:			interpolation filter project for HEVC
-- Description:			Control Unit luma legacy
-- Dependencies:
--			FSM1_filter.vhd
--			FSM2_filter.vhd
--			counter_programmable_CE_NoOutput.vhd
--			my_math.vhd
--			
--
-- Revision: 
--		1.0 created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use WORK.my_math.all;

entity ControlUnit is
	port(
		clk,
		reset_n,
		terminal_count_Add,						-- input buffer address counter terminal count
		Vin,								-- input data and config sampling strobe
		horVer:IN std_logic;						-- '0'=>1D filtering, '1'=>2D filtering
		EightOrSeven_1,EightOrSeven_2:IN std_logic_vector(1 downto 0);	-- 1st stage and 2nd stage filter selection signals
		conftap_8or7_1,conftap_8or7_2:OUT std_logic_vector(1 downto 0);	-- config stage1 and stage2 routing units
		conf_vect1_stage1,conf_vect2_stage1,conf_vect1_stage2,conf_vect2_stage2:OUT std_logic_vector(8 downto 0);	-- config stage1 and stage2 half filters
		LE_rout1,LE_rout2,						-- load enable stage1 and stage2 config routing units
		LE_conf_vect1_stage1,LE_conf_vect2_stage1,LE_conf_vect1_stage2,LE_conf_vect2_stage2,	-- load enable stage1 and stage2 half filters configuration vectors
		LE_regout,							-- output register load enable
		clear_AddCounter,						-- synchronous clear address counter
		wr_n,								-- input buffer write enable (active-low)
		fir1or2,							-- '0'=>1D output, '1'=>2D output
		SE,								-- serial enable for second stage shift register
		LE_ME_MCBi: OUT std_logic					-- load enable motion compensation biprediction register
	);
end entity ControlUnit;

architecture structure of ControlUnit is
component FSM1_filter is
	port(
		clk,reset_n,
		terminal_count_1,terminal_count_2,
		Vin,
		horVer:IN std_logic;
		EightOrSeven:IN std_logic_vector(1 downto 0);
		mod_LineCounter:OUT std_logic_vector(2 downto 0);
		conftap_8or7_1:OUT std_logic_vector(1 downto 0);
		conf_vect1_stage1,conf_vect2_stage1:OUT std_logic_vector(8 downto 0);
		LE_LineCounter,
		LE_rout1,
		LE_conf_vect1_stage1,LE_conf_vect2_stage1,
		LE_regout,
		clear_AddCounter,
		clear_LineCounter,
		CE_LineCounter,
		wr_n,
		startFir2,
		SE,
		LE_ME_MCBi: OUT std_logic
  );
end component FSM1_filter;
component FSM2_filter is
	port(
		clk,reset_n,
		start,terminal_count,terminal_count_Add: IN std_logic;	-- Vin
		EightOrSeven:IN std_logic_vector(1 downto 0);
		conftap_8or7_2:OUT std_logic_vector(1 downto 0);
		conf_vect1_stage2,conf_vect2_stage2:OUT std_logic_vector(8 downto 0);
		mod_PelCounter:OUT std_logic_vector(2 downto 0);
		clear_count,
		LE_count,
		LE_rout2,
		LE_conf_vect1_stage2,LE_conf_vect2_stage2,
		LE_regout,
		fir1or2:OUT std_logic
  );
end component FSM2_filter;
component counter_programmable_CE_NoOutput is	-- programmable counter with mode register, clear, terminal count, count enable
	generic(rg:positive:=63);
	port(
		clk,reset_n,clear,LE_mod,CE:IN std_logic;
		modulus:IN std_logic_vector(log2(rg)-1 downto 0);
		terminal_count:OUT std_logic
	);
end component counter_programmable_CE_NoOutput;

	signal terminal_count_Line,
		LE_LineCounter,
		clear_LineCounter,
		CE_LineCounter,
		startFir2,
		terminal_count_Stall,
		clear_PelCounter,
		LE_regout_1,LE_regout_2,
		LE_PelCounter,
		clear_SharedCounter,
		LE_SharedCounter,
		CE_SharedCounter,
		terminal_count_SharedCounter,
		fir1or2_int:std_logic;
	signal mod_LineCounter,
		mod_PelCounter,
		mod_SharedCounter:std_logic_vector(2 downto 0);
begin
	FSM1:FSM1_filter
		port map(
			clk=>clk,
			reset_n=>reset_n,
			terminal_count_1=>terminal_count_Add,
			terminal_count_2=>terminal_count_SharedCounter,
			Vin=>Vin,
			horVer=>horVer,
			EightOrSeven=>EightOrSeven_1,
			mod_LineCounter=>mod_LineCounter,
			conftap_8or7_1=>conftap_8or7_1,
			conf_vect1_stage1=>conf_vect1_stage1,
			conf_vect2_stage1=>conf_vect2_stage1,
			LE_LineCounter=>LE_LineCounter,
			LE_rout1=>LE_rout1,
			LE_conf_vect1_stage1=>LE_conf_vect1_stage1,
			LE_conf_vect2_stage1=>LE_conf_vect2_stage1,
			LE_regout=>LE_regout_1,
			clear_AddCounter=>clear_AddCounter,
			clear_LineCounter=>clear_LineCounter,
			CE_LineCounter=>CE_LineCounter,
			wr_n=>wr_n,
			startFir2=>startFir2,
			SE=>SE,
			LE_ME_MCBi=>LE_ME_MCBi
	  );
	SHARED_CNT: counter_programmable_CE_NoOutput
		generic map(rg=>7)
		port map(
			clk=>clk,
			reset_n=>reset_n,
			clear=>clear_SharedCounter,
			LE_mod=>LE_SharedCounter,
			CE=>CE_SharedCounter,
			modulus=>mod_SharedCounter,
			terminal_count=>terminal_count_SharedCounter
		);
	FSM2:FSM2_filter 
		port map(
			clk=>clk,
			reset_n=>reset_n,
			start=>startFir2,
			terminal_count=>terminal_count_SharedCounter,
			terminal_count_Add=>terminal_count_Add,
			EightOrSeven=>EightOrSeven_2,
			conftap_8or7_2=>conftap_8or7_2,
			conf_vect1_stage2=>conf_vect1_stage2,
			conf_vect2_stage2=>conf_vect2_stage2,
			mod_PelCounter=>mod_PelCounter,
			clear_count=>clear_PelCounter,
			LE_count=>LE_PelCounter,
			LE_rout2=>LE_rout2,
			LE_conf_vect1_stage2=>LE_conf_vect1_stage2,
			LE_conf_vect2_stage2=>LE_conf_vect2_stage2,
			LE_regout=>LE_regout_2,
			fir1or2=>fir1or2_int
	  	);
-- MUX clear shared counter
clear_SharedCounter<=
	clear_LineCounter when fir1or2_int='0' else 
	clear_PelCounter;
-- MUX LE shared counter
LE_SharedCounter<=
	LE_LineCounter when fir1or2_int='0' else
	LE_PelCounter;
-- MUX Count Enable shared counter
CE_SharedCounter<=
	CE_LineCounter when fir1or2_int='0' else
	'1';
-- MUX modulus shared counter
mod_SharedCounter<=
	mod_LineCounter when fir1or2_int='0' else
	mod_PelCounter;
fir1or2<=fir1or2_int;

LE_regout<=	-- logic OR of the two FSMs output register load enable signals
	LE_regout_2 when LE_regout_1='0' else
	LE_regout_1; 

end architecture structure;
