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
-- Module Name:			filter_reconfigurable_stage2.vhd
-- Project:			interpolation filter project for HEVC
-- Description:			8/7-tap reconfigurable multiplier-less 16-bit inputs half filter, with configuration input vector
-- Dependencies:		None
--
-- Revision: 
--		1.0 created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity filter_reconfigurable_stage2 is
	port(
		s0,s1,s2,s3:IN std_logic_vector(15 downto 0);	-- half filter inputs
		conf_vect:IN std_logic_vector(8 downto 0);	-- half filter input configuration vector, see FSM2_filter.vhd for the different config settings
		o:OUT std_logic_vector(21 downto 0)
	);
end entity filter_reconfigurable_stage2;

architecture behavioural of filter_reconfigurable_stage2 is
	signal inA_op1,inB_op1,o_op1,inA_op2,inB_op2,o_op2,inA_op6,inB_op6,o_op6: std_logic_vector(21 downto 0);
	signal inA_op5,inB_op5,inA_op4,inB_op4,o_op4,o_op5,inA_op3,inB_op3:std_logic_vector(18 downto 0);
	signal o_op3:std_logic_vector(19 downto 0);
begin
-- ADD op1
inA_op1<=
	s1(15)&s1(15)&s1(15)&s1(15)&s1&"00" when conf_vect(8)='0' else	-- s1<<2
	s0(15)&s0(15)&s0(15)&s0(15)&s0(15)&s0(15)&s0;			-- s0
inB_op1<=
	s3(15)&s3&"00000" when conf_vect(7 downto 6)="00" else				-- s3<<5
	s3&"000000" when conf_vect(7 downto 6)="01" else				-- s3<<6
	s3(15)&s3(15)&s3(15)&s3(15)&s3(15)&s3&'0' when conf_vect(7 downto 6)="10" else	-- s3<<1
	s2(15)&s2(15)&s2(15)&s2(15)&s2(15)&s2(15)&s2;					-- s2
o_op1<=std_logic_vector(signed(inA_op1)+signed(inB_op1));	-- discard carry out

-- ADD op2
inA_op2<=o_op1;
inB_op2<=
	s3(15)&s3(15)&s3(15)&s3&"000" when conf_vect(5 downto 4)="00" else		-- s3<<3
	s3(15)&s3(15)&s3(15)&s3(15)&s3(15)&s3&'0' when conf_vect(5 downto 4)="01" else	-- s3<<1
	s2(15)&s2(15)&s2&"0000";							-- s2<<4
o_op2<=std_logic_vector(signed(inA_op2)+signed(inB_op2));	-- discard carry out

-- ADD op4
inA_op4<=
	s0(15)&s0(15)&s0(15)&s0 when conf_vect(3)='0' else	-- s0
	s1(15)&s1(15)&s1(15)&s1;				-- s1
inB_op4<=
	s2&"000" when conf_vect(2)='0' else	-- s2<<3
	s1(15)&s1&"00";			-- s1<<2
o_op4<=std_logic_vector(signed(inA_op4)+signed(inB_op4));	-- discard carry out

-- ADD op5
inA_op5<=
	s2(15)&s2(15)&s2&'0' when conf_vect(1)='0' else	-- s2<<1
	std_logic_vector(to_unsigned(0,19));		-- 0
inB_op5<=
	s2(15)&s2(15)&s2(15)&s2 when conf_vect(0)<='0' else	-- s2
	s3&"000";				-- s3<<3
o_op5<=std_logic_vector(signed(inA_op5)+signed(inB_op5));

-- ADD op3
inA_op3<=o_op4;
inB_op3<=o_op5;
o_op3<=std_logic_vector(signed(inA_op3(18)&inA_op3)+signed(inB_op3(18)&inB_op3));

-- SUB op6
inA_op6<=o_op2;
inB_op6<=o_op3(19)&o_op3(19)&o_op3;
o_op6<=std_logic_vector(signed(inA_op6)-signed(inB_op6));

o<=o_op6;

end architecture behavioural;
