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
-- Create Date(mm/aaaa):	10/2017 
-- Module Name:			ProcessingElement_chroma_approximate.vhd
-- Project:			interpolation filter project for HEVC
-- Description:			Top level entity chroma approximate
-- Dependencies:
--			ControlUnit_chroma_approximate.vhd
--			DataPath_chroma_approximate.vhd
--			
--
-- Revision: 
--		1.0 created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity ProcessingElement_chroma_approximate is
	port(
		clk,
		reset_n,
		Vin,								-- input data and config sampling strobe
		horVer,								-- '0'=>1D filtering, '1'=>2D filtering
		ME_MCBi:IN std_logic;						-- motion compensation biprediction output selection signal
		---------- Additional signals required for approximate version
		filterSel_1,filterSel_2:IN std_logic_vector(3 downto 0);	-- 1st stage and 2nd stage filter selector signals
		----------
		InData:IN std_logic_vector(7 downto 0);				-- input pixel
		modAddr_IN:IN std_logic_vector(5 downto 0);			-- counter modulus address input
		Vout:OUT std_logic;						-- sampling strobe output signal
		o:OUT std_logic_vector(15 downto 0)				-- output data port
	);
end entity ProcessingElement_chroma_approximate;

architecture structural of ProcessingElement_chroma_approximate is
component ControlUnit_chroma_approximate is
	port(
		clk,
		reset_n,
		terminal_count_Add,
		Vin,
		horVer:IN std_logic;
		---------- Additional signals required for approximate version
		filterSel_1,filterSel_2:IN std_logic_vector(3 downto 0);
		conf2_stage1,conf2_stage2,
		conf_2tap_stage1,conf_2tap_stage2:OUT std_logic_vector(1 downto 0);
		dpSelect:OUT std_logic;
		----------
		conftap_1,conftap_2:OUT std_logic_vector(1 downto 0);
		conf_vect_stage1,conf_vect_stage2:OUT std_logic_vector(12 downto 0);
		LE_rout1,LE_rout2,
		LE_conf_vect_stage1,LE_conf_vect_stage2,
		LE_regout,
		clear_AddCounter,
		wr_n,
		fir1or2,
		SE,
		LE_ME_MCBi,
		---------- Additional signals required for approximate version
		LE_rout1_2tap,LE_rout2_2tap,
		LE_conf_2tap_stage1,LE_conf_2tap_stage2,
		LE_dpSelect:OUT std_logic
		----------
	);
end component ControlUnit_chroma_approximate;
component DataPath_chroma_approximate is
	port(
		clk,reset_n,
		wr_n,
		SE,
		LE_dataIn,LE_dataOut,
		fir1or2,
		LE_conf_vect_stage1,LE_conf_vect_stage2,
		LE_rout1,LE_rout2,
		LE_modAdd,
		clear_AddCounter,
		ME_MCBi,
		LE_ME_MCBi,
		---------- Additional signals required for approximate version
		LE_rout1_2tap,LE_rout2_2tap,
		LE_conf_2tap_stage1,LE_conf_2tap_stage2,
		LE_dpSelect,
		dpSelect:IN std_logic;
		----------
		modAddr_IN:IN std_logic_vector(5 downto 0);
		InData:IN std_logic_vector(7 downto 0);
		conftap_1,conftap_2,
		---------- Additional signals required for approximate version
		conf2_stage1,conf2_stage2,						-- routing unit conf
		conf_2tap_stage1,conf_2tap_stage2:IN std_logic_vector(1 downto 0);	-- filter conf
		----------
		conf_vect_stage1,conf_vect_stage2:IN std_logic_vector(12 downto 0);
		terminal_count_Add:OUT std_logic;
		Vout:OUT std_logic;
		o:OUT std_logic_vector(15 downto 0)
	);
end component DataPath_chroma_approximate;
	signal terminal_count_Add,
		LE_rout1,LE_rout2,
		LE_conf_vect_stage1,LE_conf_vect_stage2,
		LE_regout,
		clear_AddCounter,
		wr_n,
		fir1or2,
		SE,
		LE_ME_MCBi,
		LE_rout1_2tap,LE_rout2_2tap,
		LE_conf_2tap_stage1,LE_conf_2tap_stage2,
		LE_dpSelect,
		dpSelect:std_logic;
	signal conftap_1,conftap_2,
		conf2_stage1,conf2_stage2,
		conf_2tap_stage1,conf_2tap_stage2:std_logic_vector(1 downto 0);
	signal conf_vect_stage1,conf_vect_stage2:std_logic_vector(12 downto 0);

begin
	CU:ControlUnit_chroma_approximate
		port map(
		clk=>clk,
		reset_n=>reset_n,
		terminal_count_Add=>terminal_count_Add,
		Vin=>Vin,
		horVer=>horVer,
		---------- Additional signals required for approximate version
		filterSel_1=>filterSel_1,
		filterSel_2=>filterSel_2,
		conf2_stage1=>conf2_stage1,
		conf2_stage2=>conf2_stage2,
		conf_2tap_stage1=>conf_2tap_stage1,
		conf_2tap_stage2=>conf_2tap_stage2,
		dpSelect=>dpSelect,
		----------
		conftap_1=>conftap_1,
		conftap_2=>conftap_2,
		conf_vect_stage1=>conf_vect_stage1,
		conf_vect_stage2=>conf_vect_stage2,
		LE_rout1=>LE_rout1,
		LE_rout2=>LE_rout2,
		LE_conf_vect_stage1=>LE_conf_vect_stage1,
		LE_conf_vect_stage2=>LE_conf_vect_stage2,
		LE_regout=>LE_regout,
		clear_AddCounter=>clear_AddCounter,
		wr_n=>wr_n,
		fir1or2=>fir1or2,
		SE=>SE,
		LE_ME_MCBi=>LE_ME_MCBi,
		---------- Additional signals required for approximate version
		LE_rout1_2tap=>LE_rout1_2tap,
		LE_rout2_2tap=>LE_rout2_2tap,
		LE_conf_2tap_stage1=>LE_conf_2tap_stage1,
		LE_conf_2tap_stage2=>LE_conf_2tap_stage2,
		LE_dpSelect=>LE_dpSelect
		----------
	);
	DP:DataPath_chroma_approximate
	port map(
		clk=>clk,
		reset_n=>reset_n,
		wr_n=>wr_n,
		SE=>SE,
		LE_dataIn=>Vin,
		LE_dataOut=>LE_regout,
		fir1or2=>fir1or2,
		LE_conf_vect_stage1=>LE_conf_vect_stage1,
		LE_conf_vect_stage2=>LE_conf_vect_stage2,
		LE_rout1=>LE_rout1,
		LE_rout2=>LE_rout2,
		LE_modAdd=>Vin,
		clear_AddCounter=>clear_AddCounter,
		ME_MCBi=>ME_MCBi,
		LE_ME_MCBi=>LE_ME_MCBi,
		---------- Additional signals required for approximate version
		LE_rout1_2tap=>LE_rout1_2tap,
		LE_rout2_2tap=>LE_rout2_2tap,
		LE_conf_2tap_stage1=>LE_conf_2tap_stage1,
		LE_conf_2tap_stage2=>LE_conf_2tap_stage2,
		LE_dpSelect=>LE_dpSelect,
		dpSelect=>dpSelect,
		----------
		modAddr_IN=>modAddr_IN,
		InData=>InData,
		conftap_1=>conftap_1,
		conftap_2=>conftap_2,
		---------- Additional signals required for approximate version
		conf2_stage1=>conf2_stage1,
		conf2_stage2=>conf2_stage2,
		conf_2tap_stage1=>conf_2tap_stage1,
		conf_2tap_stage2=>conf_2tap_stage2,
		----------
		conf_vect_stage1=>conf_vect_stage1,
		conf_vect_stage2=>conf_vect_stage2,
		terminal_count_Add=>terminal_count_Add,
		Vout=>Vout,
		o=>o
	);

end architecture structural;
