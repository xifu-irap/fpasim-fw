ads62p49 directory: simplified model of the ads62p49 ADC. The architecture is as follows:
	1. convert float -> std_logic_vector.
	2. optional latency to simulate the ADC latency.
	3. instanciate IOs.

dac3283 directory: simplified model of the dac3283 DAC. The architecture is as follows:
	1. instanciate IOs.
	2. demux the input data stream in order to retrieve data for the DAC0.
	3. optional latency to simulate the DAC latency.
	4. convert std_logic_vector -> float.