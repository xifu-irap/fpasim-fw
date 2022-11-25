----------------------------------------------------------------------------------
-- Company       : CNRS - INSU - IRAP
-- Engineer      : Laurent Ravera, Antoine Clenet
-- 
-- Create Date   : 07/07/2015 
-- Design Name   : DRE XIFU FPGA_BOARD
-- Module Name   : dds_generic - Behavioral 
-- Project Name  : Athena XIfu DRE
-- Target Devices: Virtex 6 LX 240
-- Tool versions : ISE-14.7
-- Description   : Sine wave generator
--
-- Dependencies	 : 
--
-- Revision: 
-- Revision 0.1 - File Created
-- Revision 0.2 - All DDS parameters (all signals) are function of ROM_Depth, Size_ROM_Sine and Size_ROM_delta defined in the athena_package
-- Additional Comments: 
--
---------------------------------------oOOOo(o_o)oOOOo-----------------------------

library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.athena_package.all;


entity DDS is
port		(
--RESET
			Reset       	: in  std_logic;
--CLOCKs
			CLK_100MHz     	: in  std_logic;
		
			counter         : in  unsigned(C_size_counter - 1 downto 0);
			dds_signal	  	: out signed(C_Size_DDS-1 downto 0)
    );
end entity;
---------------------------------------------------------------------------------

--! @brief-- BLock diagrams schematics -- 
--! @detail file:work.dds_generic.Behavioral.svg
architecture Behavioral of DDS is

signal counter_previous			: unsigned(C_size_counter - 1 downto 0);
signal counter_previous_2 		: unsigned(C_size_counter - 1 downto 0);
signal counter_backward			: unsigned(C_size_counter-C_Size_quarter - 1 downto 0);
signal interpolation_previous	: unsigned(C_Size_ROM_delta+C_Size_intrp-1 downto 0);
signal interpol_x				: unsigned(C_Size_intrp-1 downto 0);
signal interpol_x_previous		: unsigned(C_Size_intrp-1 downto 0);

constant C_first_cross_zero		: unsigned(C_size_counter - 1 downto C_size_counter - C_REF_SINE_Depth - C_Size_intrp) := "01" & to_unsigned(0,C_REF_SINE_Depth + C_Size_intrp - 2);
constant C_second_cross_zero	: unsigned(C_size_counter - 1 downto C_size_counter - C_REF_SINE_Depth - C_Size_intrp) := "11" & to_unsigned(0,C_REF_SINE_Depth + C_Size_intrp - 2);
constant C_Quarter_of_counter		: unsigned(C_size_counter-C_Size_quarter-1 downto 0) := (others => '0'); 

-- where we are in the sine period from the 2 MSB of the counter:
constant C_quarter1 				: unsigned(C_Size_quarter-1 downto 0) := "00";
--constant C_quarter2 				: unsigned(Size_quarter-1 downto 0) := "01";
constant C_quarter3 				: unsigned(C_Size_quarter-1 downto 0) := "10";
constant C_quarter4 				: unsigned(C_Size_quarter-1 downto 0) := "11";

signal quarter          		: unsigned(C_Size_quarter-1 downto 0);
signal quarter_previous			: unsigned(C_Size_quarter-1 downto 0);


signal    address_rom  	: unsigned((C_REF_SINE_Depth-2)-1 downto 0);	-- ROM_Depth-2 because only 1/4 of sine period is stored into the LUT
signal    sine			: unsigned(C_Size_ROM_Sine-1 downto 0);
signal 	  sine_previous	: unsigned(C_Size_ROM_Sine-1 downto 0);
signal    delta			: unsigned(C_Size_ROM_delta-1 downto 0);
type rom_dds is array ((2**(C_REF_SINE_Depth-2))-1 downto 0) of unsigned(C_Size_ROM_Sine+C_Size_ROM_delta-1 downto 0);
constant cts_rom_data : rom_dds := (
-------------------------------------------------------------------
-- In this version of the ROM:
--   - a quarter of a period only is stored
--   - the absolute value of the Delta is stored (-1 * Delta)
--   - the sine values are stored on Size_ROM_sine bits
--   - the Delta values are stored on Size_ROM_delta bits
-------------------------------------------------------------------
0	=>	 "1111111111111111110000000001",
1	=>	 "1111111111111111100000000100",
2	=>	 "1111111111111110100000000110",
3	=>	 "1111111111111101000000001001",
4	=>	 "1111111111111010110000001011",
5	=>	 "1111111111111000000000001101",
6	=>	 "1111111111110100110000010000",
7	=>	 "1111111111110000110000010011",
8	=>	 "1111111111101100000000010101",
9	=>	 "1111111111100110110000010111",
10	=>	 "1111111111100001000000011010",
11	=>	 "1111111111011010100000011101",
12	=>	 "1111111111010011010000011110",
13	=>	 "1111111111001011110000100010",
14	=>	 "1111111111000011010000100100",
15	=>	 "1111111110111010010000100110",
16	=>	 "1111111110110000110000101000",
17	=>	 "1111111110100110110000101100",
18	=>	 "1111111110011011110000101101",
19	=>	 "1111111110010000100000110000",
20	=>	 "1111111110000100100000110011",
21	=>	 "1111111101110111110000110101",
22	=>	 "1111111101101010100000110111",
23	=>	 "1111111101011100110000111010",
24	=>	 "1111111101001110010000111101",
25	=>	 "1111111100111111000000111111",
26	=>	 "1111111100101111010001000001",
27	=>	 "1111111100011111000001000100",
28	=>	 "1111111100001110000001000110",
29	=>	 "1111111011111100100001001001",
30	=>	 "1111111011101010010001001011",
31	=>	 "1111111011010111100001001101",
32	=>	 "1111111011000100010001010000",
33	=>	 "1111111010110000010001010011",
34	=>	 "1111111010011011100001010101",
35	=>	 "1111111010000110010001010111",
36	=>	 "1111111001110000100001011010",
37	=>	 "1111111001011010000001011100",
38	=>	 "1111111001000011000001011111",
39	=>	 "1111111000101011010001100001",
40	=>	 "1111111000010011000001100100",
41	=>	 "1111110111111010000001100110",
42	=>	 "1111110111100000100001101001",
43	=>	 "1111110111000110010001101011",
44	=>	 "1111110110101011100001101101",
45	=>	 "1111110110010000010001110000",
46	=>	 "1111110101110100010001110011",
47	=>	 "1111110101010111100001110100",
48	=>	 "1111110100111010100001111000",
49	=>	 "1111110100011100100001111001",
50	=>	 "1111110011111110010001111100",
51	=>	 "1111110011011111010001111111",
52	=>	 "1111110010111111100010000001",
53	=>	 "1111110010011111010010000011",
54	=>	 "1111110001111110100010000110",
55	=>	 "1111110001011101000010001000",
56	=>	 "1111110000111011000010001011",
57	=>	 "1111110000011000010010001101",
58	=>	 "1111101111110101000010010000",
59	=>	 "1111101111010001000010010010",
60	=>	 "1111101110101100100010010100",
61	=>	 "1111101110000111100010010111",
62	=>	 "1111101101100001110010011001",
63	=>	 "1111101100111011100010011100",
64	=>	 "1111101100010100100010011110",
65	=>	 "1111101011101101000010100001",
66	=>	 "1111101011000100110010100011",
67	=>	 "1111101010011100000010100101",
68	=>	 "1111101001110010110010101000",
69	=>	 "1111101001001000110010101010",
70	=>	 "1111101000011110010010101101",
71	=>	 "1111100111110011000010101111",
72	=>	 "1111100111000111010010110001",
73	=>	 "1111100110011011000010110100",
74	=>	 "1111100101101110000010110110",
75	=>	 "1111100101000000100010111001",
76	=>	 "1111100100010010010010111011",
77	=>	 "1111100011100011100010111101",
78	=>	 "1111100010110100010011000000",
79	=>	 "1111100010000100010011000010",
80	=>	 "1111100001010011110011000101",
81	=>	 "1111100000100010100011000111",
82	=>	 "1111011111110000110011001001",
83	=>	 "1111011110111110100011001100",
84	=>	 "1111011110001011100011001110",
85	=>	 "1111011101011000000011010001",
86	=>	 "1111011100100011110011010011",
87	=>	 "1111011011101111000011010101",
88	=>	 "1111011010111001110011011000",
89	=>	 "1111011010000011110011011010",
90	=>	 "1111011001001101010011011100",
91	=>	 "1111011000010110010011011111",
92	=>	 "1111010111011110100011100001",
93	=>	 "1111010110100110010011100100",
94	=>	 "1111010101101101010011100110",
95	=>	 "1111010100110011110011101000",
96	=>	 "1111010011111001110011101010",
97	=>	 "1111010010111111010011101101",
98	=>	 "1111010010000100000011110000",
99	=>	 "1111010001001000000011110001",
100	=>	 "1111010000001011110011110101",
101	=>	 "1111001111001110100011110110",
102	=>	 "1111001110010001000011111001",
103	=>	 "1111001101010010110011111011",
104	=>	 "1111001100010100000011111101",
105	=>	 "1111001011010100110100000000",
106	=>	 "1111001010010100110100000010",
107	=>	 "1111001001010100010100000101",
108	=>	 "1111001000010011000100000110",
109	=>	 "1111000111010001100100001010",
110	=>	 "1111000110001111000100001011",
111	=>	 "1111000101001100010100001110",
112	=>	 "1111000100001000110100010000",
113	=>	 "1111000011000100110100010010",
114	=>	 "1111000010000000010100010101",
115	=>	 "1111000000111011000100010111",
116	=>	 "1110111111110101010100011010",
117	=>	 "1110111110101110110100011011",
118	=>	 "1110111101101000000100011110",
119	=>	 "1110111100100000100100100000",
120	=>	 "1110111011011000100100100011",
121	=>	 "1110111010001111110100100101",
122	=>	 "1110111001000110100100100111",
123	=>	 "1110110111111100110100101010",
124	=>	 "1110110110110010010100101011",
125	=>	 "1110110101100111100100101110",
126	=>	 "1110110100011100000100110001",
127	=>	 "1110110011001111110100110010",
128	=>	 "1110110010000011010100110101",
129	=>	 "1110110000110110000100111000",
130	=>	 "1110101111101000000100111001",
131	=>	 "1110101110011001110100111100",
132	=>	 "1110101101001010110100111110",
133	=>	 "1110101011111011010101000000",
134	=>	 "1110101010101011010101000011",
135	=>	 "1110101001011010100101000100",
136	=>	 "1110101000001001100101000111",
137	=>	 "1110100110110111110101001010",
138	=>	 "1110100101100101010101001011",
139	=>	 "1110100100010010100101001110",
140	=>	 "1110100010111111000101010000",
141	=>	 "1110100001101011000101010010",
142	=>	 "1110100000010110100101010101",
143	=>	 "1110011111000001010101010111",
144	=>	 "1110011101101011100101011001",
145	=>	 "1110011100010101010101011011",
146	=>	 "1110011010111110100101011101",
147	=>	 "1110011001100111010101100000",
148	=>	 "1110011000001111010101100010",
149	=>	 "1110010110110110110101100100",
150	=>	 "1110010101011101110101100110",
151	=>	 "1110010100000100010101101001",
152	=>	 "1110010010101010000101101010",
153	=>	 "1110010001001111100101101101",
154	=>	 "1110001111110100010101101111",
155	=>	 "1110001110011000100101110001",
156	=>	 "1110001100111100010101110100",
157	=>	 "1110001011011111010101110110",
158	=>	 "1110001010000001110101110111",
159	=>	 "1110001000100100000101111011",
160	=>	 "1110000111000101010101111100",
161	=>	 "1110000101100110010101111110",
162	=>	 "1110000100000110110110000001",
163	=>	 "1110000010100110100110000010",
164	=>	 "1110000001000110000110000101",
165	=>	 "1101111111100100110110000111",
166	=>	 "1101111110000011000110001001",
167	=>	 "1101111100100000110110001100",
168	=>	 "1101111010111101110110001101",
169	=>	 "1101111001011010100110010000",
170	=>	 "1101110111110110100110010010",
171	=>	 "1101110110010010000110010100",
172	=>	 "1101110100101101000110010110",
173	=>	 "1101110011000111100110011000",
174	=>	 "1101110001100001100110011010",
175	=>	 "1101101111111011000110011100",
176	=>	 "1101101110010100000110011111",
177	=>	 "1101101100101100010110100001",
178	=>	 "1101101011000100000110100010",
179	=>	 "1101101001011011100110100101",
180	=>	 "1101100111110010010110100111",
181	=>	 "1101100110001000100110101001",
182	=>	 "1101100100011110010110101011",
183	=>	 "1101100010110011100110101110",
184	=>	 "1101100001001000000110101111",
185	=>	 "1101011111011100010110110001",
186	=>	 "1101011101110000000110110100",
187	=>	 "1101011100000011000110110101",
188	=>	 "1101011010010101110110111000",
189	=>	 "1101011000100111110110111010",
190	=>	 "1101010110111001010110111011",
191	=>	 "1101010101001010100110111110",
192	=>	 "1101010011011011000111000000",
193	=>	 "1101010001101011000111000010",
194	=>	 "1101001111111010100111000100",
195	=>	 "1101001110001001100111000110",
196	=>	 "1101001100011000000111001000",
197	=>	 "1101001010100110000111001010",
198	=>	 "1101001000110011100111001100",
199	=>	 "1101000111000000100111001110",
200	=>	 "1101000101001101000111010000",
201	=>	 "1101000011011001000111010010",
202	=>	 "1101000001100100100111010100",
203	=>	 "1100111111101111100111010110",
204	=>	 "1100111101111010000111011000",
205	=>	 "1100111100000100000111011011",
206	=>	 "1100111010001101010111011100",
207	=>	 "1100111000010110010111011110",
208	=>	 "1100110110011110110111100000",
209	=>	 "1100110100100110110111100010",
210	=>	 "1100110010101110010111100100",
211	=>	 "1100110000110101010111100110",
212	=>	 "1100101110111011110111101000",
213	=>	 "1100101101000001110111101010",
214	=>	 "1100101011000111010111101100",
215	=>	 "1100101001001100010111101110",
216	=>	 "1100100111010000110111101111",
217	=>	 "1100100101010101000111110010",
218	=>	 "1100100011011000100111110100",
219	=>	 "1100100001011011100111110101",
220	=>	 "1100011111011110010111111000",
221	=>	 "1100011101100000010111111001",
222	=>	 "1100011011100010000111111011",
223	=>	 "1100011001100011010111111110",
224	=>	 "1100010111100011110111111111",
225	=>	 "1100010101100100001000000001",
226	=>	 "1100010011100011111000000011",
227	=>	 "1100010001100011001000000101",
228	=>	 "1100001111100001111000000110",
229	=>	 "1100001101100000011000001001",
230	=>	 "1100001011011110001000001011",
231	=>	 "1100001001011011011000001100",
232	=>	 "1100000111011000011000001110",
233	=>	 "1100000101010100111000010000",
234	=>	 "1100000011010000111000010010",
235	=>	 "1100000001001100011000010100",
236	=>	 "1011111111000111011000010110",
237	=>	 "1011111101000001111000010111",
238	=>	 "1011111010111100001000011010",
239	=>	 "1011111000110101101000011011",
240	=>	 "1011110110101110111000011101",
241	=>	 "1011110100100111101000011111",
242	=>	 "1011110010011111111000100000",
243	=>	 "1011110000010111111000100011",
244	=>	 "1011101110001111001000100100",
245	=>	 "1011101100000110001000100110",
246	=>	 "1011101001111100101000101000",
247	=>	 "1011100111110010101000101010",
248	=>	 "1011100101101000001000101011",
249	=>	 "1011100011011101011000101101",
250	=>	 "1011100001010010001000101111",
251	=>	 "1011011111000110011000110001",
252	=>	 "1011011100111010001000110011",
253	=>	 "1011011010101101011000110100",
254	=>	 "1011011000100000011000110110",
255	=>	 "1011010110010010111000111000",
256	=>	 "1011010100000100111000111001",
257	=>	 "1011010001110110101000111100",
258	=>	 "1011001111100111101000111101",
259	=>	 "1011001101011000011000111111",
260	=>	 "1011001011001000101001000000",
261	=>	 "1011001000111000101001000010",
262	=>	 "1011000110101000001001000100",
263	=>	 "1011000100010111001001000110",
264	=>	 "1011000010000101101001000111",
265	=>	 "1010111111110011111001001001",
266	=>	 "1010111101100001101001001011",
267	=>	 "1010111011001110111001001100",
268	=>	 "1010111000111011111001001110",
269	=>	 "1010110110101000011001010000",
270	=>	 "1010110100010100011001010001",
271	=>	 "1010110010000000001001010100",
272	=>	 "1010101111101011001001010100",
273	=>	 "1010101101010110001001010111",
274	=>	 "1010101011000000011001011000",
275	=>	 "1010101000101010011001011001",
276	=>	 "1010100110010100001001011100",
277	=>	 "1010100011111101001001011101",
278	=>	 "1010100001100101111001011110",
279	=>	 "1010011111001110011001100000",
280	=>	 "1010011100110110011001100010",
281	=>	 "1010011010011101111001100011",
282	=>	 "1010011000000101001001100101",
283	=>	 "1010010101101011111001100111",
284	=>	 "1010010011010010001001101000",
285	=>	 "1010010000111000001001101010",
286	=>	 "1010001110011101101001101011",
287	=>	 "1010001100000010111001101101",
288	=>	 "1010001001100111101001101111",
289	=>	 "1010000111001011111001110000",
290	=>	 "1010000100101111111001110001",
291	=>	 "1010000010010011101001110011",
292	=>	 "1001111111110110111001110101",
293	=>	 "1001111101011001101001110110",
294	=>	 "1001111010111100001001111000",
295	=>	 "1001111000011110001001111001",
296	=>	 "1001110101111111111001111011",
297	=>	 "1001110011100001001001111100",
298	=>	 "1001110001000010001001111110",
299	=>	 "1001101110100010101010000000",
300	=>	 "1001101100000010101010000000",
301	=>	 "1001101001100010101010000011",
302	=>	 "1001100111000001111010000011",
303	=>	 "1001100100100001001010000110",
304	=>	 "1001100001111111101010000110",
305	=>	 "1001011111011110001010001000",
306	=>	 "1001011100111100001010001010",
307	=>	 "1001011010011001101010001011",
308	=>	 "1001010111110110111010001101",
309	=>	 "1001010101010011101010001110",
310	=>	 "1001010010110000001010001111",
311	=>	 "1001010000001100011010010001",
312	=>	 "1001001101101000001010010010",
313	=>	 "1001001011000011101010010100",
314	=>	 "1001001000011110101010010101",
315	=>	 "1001000101111001011010010110",
316	=>	 "1001000011010011111010011000",
317	=>	 "1001000000101101111010011001",
318	=>	 "1000111110000111101010011011",
319	=>	 "1000111011100000111010011100",
320	=>	 "1000111000111001111010011110",
321	=>	 "1000110110010010011010011110",
322	=>	 "1000110011101010111010100000",
323	=>	 "1000110001000010111010100010",
324	=>	 "1000101110011010011010100011",
325	=>	 "1000101011110001101010100100",
326	=>	 "1000101001001000101010100101",
327	=>	 "1000100110011111011010100111",
328	=>	 "1000100011110101101010101000",
329	=>	 "1000100001001011101010101010",
330	=>	 "1000011110100001001010101010",
331	=>	 "1000011011110110101010101100",
332	=>	 "1000011001001011101010101110",
333	=>	 "1000010110100000001010101110",
334	=>	 "1000010011110100101010110000",
335	=>	 "1000010001001000101010110010",
336	=>	 "1000001110011100001010110010",
337	=>	 "1000001011101111101010110100",
338	=>	 "1000001001000010101010110101",
339	=>	 "1000000110010101011010110110",
340	=>	 "1000000011100111111010110111",
341	=>	 "1000000000111010001010111001",
342	=>	 "0111111110001011111010111010",
343	=>	 "0111111011011101011010111011",
344	=>	 "0111111000101110101010111101",
345	=>	 "0111110101111111011010111101",
346	=>	 "0111110011010000001010111111",
347	=>	 "0111110000100000011011000000",
348	=>	 "0111101101110000011011000001",
349	=>	 "0111101011000000001011000010",
350	=>	 "0111101000001111101011000100",
351	=>	 "0111100101011110101011000101",
352	=>	 "0111100010101101011011000110",
353	=>	 "0111011111111011111011000111",
354	=>	 "0111011101001010001011001000",
355	=>	 "0111011010011000001011001001",
356	=>	 "0111010111100101111011001010",
357	=>	 "0111010100110011011011001100",
358	=>	 "0111010010000000011011001101",
359	=>	 "0111001111001101001011001110",
360	=>	 "0111001100011001101011001110",
361	=>	 "0111001001100110001011010000",
362	=>	 "0111000110110010001011010010",
363	=>	 "0111000011111101101011010010",
364	=>	 "0111000001001001001011010011",
365	=>	 "0110111110010100011011010100",
366	=>	 "0110111011011111011011010110",
367	=>	 "0110111000101001111011010110",
368	=>	 "0110110101110100011011011000",
369	=>	 "0110110010111110011011011001",
370	=>	 "0110110000001000001011011001",
371	=>	 "0110101101010001111011011011",
372	=>	 "0110101010011011001011011100",
373	=>	 "0110100111100100001011011100",
374	=>	 "0110100100101101001011011110",
375	=>	 "0110100001110101101011011111",
376	=>	 "0110011110111101111011100000",
377	=>	 "0110011100000101111011100000",
378	=>	 "0110011001001101111011100010",
379	=>	 "0110010110010101011011100011",
380	=>	 "0110010011011100101011100011",
381	=>	 "0110010000100011111011100101",
382	=>	 "0110001101101010101011100110",
383	=>	 "0110001010110001001011100110",
384	=>	 "0110000111110111101011101000",
385	=>	 "0110000100111101101011101000",
386	=>	 "0110000010000011101011101010",
387	=>	 "0101111111001001001011101010",
388	=>	 "0101111100001110101011101011",
389	=>	 "0101111001010011111011101100",
390	=>	 "0101110110011000111011101101",
391	=>	 "0101110011011101101011101110",
392	=>	 "0101110000100010001011101111",
393	=>	 "0101101101100110011011110000",
394	=>	 "0101101010101010011011110000",
395	=>	 "0101100111101110011011110001",
396	=>	 "0101100100110010001011110011",
397	=>	 "0101100001110101011011110011",
398	=>	 "0101011110111000101011110100",
399	=>	 "0101011011111011101011110101",
400	=>	 "0101011000111110011011110101",
401	=>	 "0101010110000001001011110111",
402	=>	 "0101010011000011011011110111",
403	=>	 "0101010000000101101011111000",
404	=>	 "0101001101000111101011111001",
405	=>	 "0101001010001001011011111010",
406	=>	 "0101000111001010111011111010",
407	=>	 "0101000100001100011011111100",
408	=>	 "0101000001001101011011111100",
409	=>	 "0100111110001110011011111100",
410	=>	 "0100111011001111011011111110",
411	=>	 "0100111000001111111011111110",
412	=>	 "0100110101010000011011111111",
413	=>	 "0100110010010000101100000000",
414	=>	 "0100101111010000101100000001",
415	=>	 "0100101100010000011100000001",
416	=>	 "0100101001010000001100000010",
417	=>	 "0100100110001111101100000011",
418	=>	 "0100100011001110111100000011",
419	=>	 "0100100000001110001100000100",
420	=>	 "0100011101001101001100000101",
421	=>	 "0100011010001011111100000101",
422	=>	 "0100010111001010101100000110",
423	=>	 "0100010100001001001100000111",
424	=>	 "0100010001000111011100001000",
425	=>	 "0100001110000101011100001000",
426	=>	 "0100001011000011011100001000",
427	=>	 "0100001000000001011100001010",
428	=>	 "0100000100111110111100001010",
429	=>	 "0100000001111100011100001010",
430	=>	 "0011111110111001111100001100",
431	=>	 "0011111011110110111100001011",
432	=>	 "0011111000110100001100001101",
433	=>	 "0011110101110000111100001101",
434	=>	 "0011110010101101101100001110",
435	=>	 "0011101111101010001100001110",
436	=>	 "0011101100100110101100001110",
437	=>	 "0011101001100011001100010000",
438	=>	 "0011100110011111001100010000",
439	=>	 "0011100011011011001100010000",
440	=>	 "0011100000010111001100010001",
441	=>	 "0011011101010010111100010010",
442	=>	 "0011011010001110011100010010",
443	=>	 "0011010111001001111100010010",
444	=>	 "0011010100000101011100010011",
445	=>	 "0011010001000000101100010100",
446	=>	 "0011001101111011101100010100",
447	=>	 "0011001010110110101100010100",
448	=>	 "0011000111110001101100010101",
449	=>	 "0011000100101100011100010110",
450	=>	 "0011000001100110111100010110",
451	=>	 "0010111110100001011100010110",
452	=>	 "0010111011011011111100010111",
453	=>	 "0010111000010110001100011000",
454	=>	 "0010110101010000001100010111",
455	=>	 "0010110010001010011100011001",
456	=>	 "0010101111000100001100011000",
457	=>	 "0010101011111110001100011001",
458	=>	 "0010101000110111111100011010",
459	=>	 "0010100101110001011100011001",
460	=>	 "0010100010101011001100011011",
461	=>	 "0010011111100100011100011010",
462	=>	 "0010011100011101111100011011",
463	=>	 "0010011001010111001100011100",
464	=>	 "0010010110010000001100011011",
465	=>	 "0010010011001001011100011100",
466	=>	 "0010010000000010011100011101",
467	=>	 "0010001100111011001100011101",
468	=>	 "0010001001110011111100011101",
469	=>	 "0010000110101100101100011101",
470	=>	 "0010000011100101011100011110",
471	=>	 "0010000000011101111100011110",
472	=>	 "0001111101010110011100011110",
473	=>	 "0001111010001110111100011111",
474	=>	 "0001110111000111001100011111",
475	=>	 "0001110011111111011100011111",
476	=>	 "0001110000110111101100011111",
477	=>	 "0001101101101111111100100000",
478	=>	 "0001101010100111111100100000",
479	=>	 "0001100111011111111100100000",
480	=>	 "0001100100010111111100100001",
481	=>	 "0001100001001111101100100001",
482	=>	 "0001011110000111011100100001",
483	=>	 "0001011010111111001100100001",
484	=>	 "0001010111110110111100100001",
485	=>	 "0001010100101110101100100010",
486	=>	 "0001010001100110001100100010",
487	=>	 "0001001110011101101100100010",
488	=>	 "0001001011010101001100100010",
489	=>	 "0001001000001100101100100010",
490	=>	 "0001000101000100001100100011",
491	=>	 "0001000001111011011100100010",
492	=>	 "0000111110110010111100100011",
493	=>	 "0000111011101010001100100011",
494	=>	 "0000111000100001011100100011",
495	=>	 "0000110101011000101100100011",
496	=>	 "0000110010001111111100100100",
497	=>	 "0000101111000110111100100011",
498	=>	 "0000101011111110001100100100",
499	=>	 "0000101000110101001100100011",
500	=>	 "0000100101101100011100100100",
501	=>	 "0000100010100011011100100100",
502	=>	 "0000011111011010011100100100",
503	=>	 "0000011100010001011100100100",
504	=>	 "0000011001001000011100100100",
505	=>	 "0000010101111111011100100100",
506	=>	 "0000010010110110011100100100",
507	=>	 "0000001111101101011100100100",
508	=>	 "0000001100100100011100100100",
509	=>	 "0000001001011011011100100101",
510	=>	 "0000000110010010001100100100",
511	=>	 "0000000011001001001100100100"

);

signal rdata : unsigned(C_Size_ROM_Sine+C_Size_ROM_delta-1 downto 0);

begin

P_readout: process (CLK_100MHz)
begin
	if (rising_edge(CLK_100MHz)) then
		if (Reset = '1') then
			rdata 	<= (others=>'0');
		else
				rdata <= cts_rom_data(to_integer(address_rom));
		end if;
	end if;
end process P_readout;
        		sine 	<= rdata(C_Size_ROM_Sine+C_Size_ROM_delta-1 downto C_Size_ROM_delta);
        		delta 	<= rdata(C_Size_ROM_delta-1 downto 0);

counter_backward 		<= C_Quarter_of_counter - counter(C_size_counter-C_Size_quarter-1 downto 0);
quarter 				<= counter(C_size_counter - 1 downto C_size_counter - C_Size_quarter);

-----------------------
-- Computation of ROM address (from the counter value) 
mux_quarter_address: 
    address_rom <= counter(C_size_counter - C_Size_quarter - 1 downto C_Size_intrp) when (quarter = C_quarter1 or quarter = C_quarter3)
                   else counter_backward(C_size_counter - C_Size_quarter - 1 downto C_Size_intrp);

-----------------------
-- Computation of X factor for the interpolation (from the counter value) 
mux_quarter_interpol: 
   interpol_x <= counter(C_Size_intrp-1 downto 0) when (quarter = C_quarter1 or quarter = C_quarter3)
                 else counter_backward(C_Size_intrp-1 downto 0);

-----------------------
-----------------------
P_sync_interpol: process(CLK_100MHz) -- @suppress "All references must have the same capitalization as their declaration: Expected "CLK_4X" but was "Clk_4X""
-- Delay of the "interpol_x" and "quarter" signals to be in-phase with the ROM output
begin
	if rising_edge(CLK_100MHz) then	
		if Reset = '1' then
			interpol_x_previous 	<= (others => '0');
			counter_previous 		<= (others => '0');
			counter_previous_2 		<= (others => '0');
			interpolation_previous 	<= (others => '0');
			sine_previous 			<= (others => '0');
			dds_signal 				<= (others => '0');
 		else
			interpol_x_previous <= interpol_x; 
			counter_previous 	<= counter;
			counter_previous_2 	<= counter_previous;
-----------------------
-- Interpolation : Multiplication of the counter's LSB by the slope of the sine function
			interpolation_previous 	<= delta * interpol_x_previous;
			sine_previous 			<= sine;
-----------------------
-- Addition of the "Sine" value and the "interpolation" value
			if (counter_previous_2(C_size_counter - 1 downto C_size_counter - C_REF_SINE_Depth - C_Size_intrp) = C_first_cross_zero or counter_previous_2(C_size_counter - 1 downto C_size_counter - C_REF_SINE_Depth - C_Size_intrp) = C_second_cross_zero) then 
				dds_signal <= (others => '0');
			elsif (quarter_previous = C_quarter1 or quarter_previous = C_quarter4) then
				dds_signal <=  signed('0' & resize(sine_previous - resize(interpolation_previous(C_Size_ROM_delta+C_Size_intrp - 1 downto C_Size_ROM_delta+C_Size_intrp-C_Size_ROM_delta),C_Size_ROM_Sine),C_Size_DDS-1));
				else
				dds_signal <=  -( signed('0' & resize(sine_previous - resize(interpolation_previous(C_Size_ROM_delta+C_Size_intrp - 1 downto C_Size_ROM_delta+C_Size_intrp-C_Size_ROM_delta),C_Size_ROM_Sine),C_Size_DDS-1)));
			end if;
		end if;
	end if;
end process;
quarter_previous <= counter_previous_2(C_size_counter - 1 downto C_size_counter - C_Size_quarter);

end Behavioral;
