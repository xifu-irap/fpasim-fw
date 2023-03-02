# -------------------------------------------------------------------------------------------------------------
#                              Copyright (C) 2022-2030 Ken-ji de la Rosa, IRAP Toulouse.
# -------------------------------------------------------------------------------------------------------------
#                              This file is part of the ATHENA X-IFU DRE Focal Plane Assembly simulator.
#
#                              fpasim-fw is free software: you can redistribute it and/or modify
#                              it under the terms of the GNU General Public License as published by
#                              the Free Software Foundation, either version 3 of the License, or
#                              (at your option) any later version.
#
#                              This program is distributed in the hope that it will be useful,
#                              but WITHOUT ANY WARRANTY; without even the implied warranty of
#                              MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                              GNU General Public License for more details.
#
#                              You should have received a copy of the GNU General Public License
#                              along with this program.  If not, see <https://www.gnu.org/licenses/>.
# -------------------------------------------------------------------------------------------------------------
#    email                   kenji.delarosa@alten.com
#!   @file                   ads62p49_init_memory_generator.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference
# -------------------------------------------------------------------------------------------------------------
#!   @details
#
#   This scrips generates data in order to initialize the ads62p49 ADC registers.
#   The generated data will be stored in a output file in order to configure a FPGA memory
#   Note:
#      . Tested with python : 3.10.7
#
# -------------------------------------------------------------------------------------------------------------

from pathlib import Path

class Ram:
    """docstring for Ram"""
    def __init__(self):
        self.reg_list = []
        self.addr_list = []
        self.data_list = []
        self.cmt_list = []

    def add_register(self,addr_p,data_p,cmt_p=''):
        self.addr_list.append(addr_p)
        self.data_list.append(data_p)
        self.cmt_list.append(cmt_p)

    def get_cmt_list(self):
        return self.cmt_list

    def get_reg_list(self):

        res = []
        L = len(self.addr_list)
        for i in range(L):
            addr = self.addr_list[i]
            data = self.data_list[i]
            value = (addr << 8) + data
            res.append(value)

        return res



if __name__ == "__main__":
    # define the base address where to find the *.csv input files
    base_address = './'
    output_filename = 'ads62p49_init_mem.txt'
    output_filepath = str(Path(base_address,output_filename))
    
    obj = Ram()
    ################################################################
    # register0
    ################################################################
    # D7 <RESET>
    # 1: Software reset applied – resets all internal registers and self-clears to 0.
    # 0: do nothing
    rst = 1 
    # D0 <SERIAL READOUT>
    # 0: Serial readout disabled. SDOUT is forced low by the device (and not put in high impedance state).
    # 1: Serial readout enabled, Pin SDOUT functions as serial data readout.
    serial_out = 0 
    reg0 = (rst << 7) + serial_out
    obj.add_register(addr_p=0x00,data_p=reg0,cmt_p='register0')
    ################################################################
    # register1
    ################################################################
    # D2 <ENABLE LOW SPEED MODE>
    # 0: LOW SPEED mode disabled. Use for sampling frequency > 80 MSPS
    # 1: Enable LOW SPEED mode for sampling frequencies ≤ 80 MSPS.
    enable_low_speed = 0
    reg0 = (enable_low_speed << 2)
    obj.add_register(addr_p=0x20,data_p=reg0,cmt_p='register1')

    ################################################################
    # register2
    ################################################################
    # D6-D5 <REF> Internal or external reference selection
    # 00 : Internal reference enabled
    # 01:
    # 10:
    # 11: External reference enabled
    ref = int('01',2) # TODO strange value
    # D1 <STANDBY>
    # 0 Normal operation
    # 1 Both ADC channels are put in standby. Internal references, output buffers are active. This results in
    #   quick wake-up time from standby.
    standby = 0
    reg0 = (ref << 5) + (standby << 1)
    obj.add_register(addr_p=0x3F,data_p=reg0,cmt_p='register2')

    ################################################################
    # register3
    ################################################################
    # D3-D0 <POWER DOWN MODES>
    # 0000 Pins CTRL1, CTRL2, and CTRL3 determine power down modes.
    # 1000 Normal operation
    # 1001 Output buffer disabled for channel B
    # 1010 Output buffer disabled for channel A
    # 1011 Output buffer disabled for channel A and B
    # 1100 Global power down
    # 1101 Channel B standby
    # 1110 Channel A standby
    # 1111 Multiplexed mode, MUX- (only with CMOS interface)
    #      Channel A and B data is multiplexed and output on DA13 to DA0 pins. Refer to the Multiplexed
    #      Output Mode section in the APPLICATION INFORMATION for additional information.
    power_down_mode = int('1000',2)
    reg0 = power_down_mode
    obj.add_register(addr_p=0x40,data_p=reg0,cmt_p='register3')

    ################################################################
    # register4
    ################################################################
    # D7 <LVDS CMOS>
    # 0 Parallel CMOS interface
    # 1 DDR LVDS interface
    lvds_cmos = 1
    reg0 = (lvds_cmos << 7)
    obj.add_register(addr_p=0x41,data_p=reg0,cmt_p='register4')

    ################################################################
    # register5
    ################################################################
    # LVDS interface
    #    D7-D5 <CLKOUT POSN> Output clock rising edge position (2)
    #       000, 100 Default output clock position (refer to timing specification table)
    #       101 Falling edge shifted (delayed) by + (4/26)×Ts(1)
    #       110 Falling edge shifted (advanced) by – (7/26)×Ts
    #       111 Falling edge shifted (advanced) by – (4/26)×Ts
    #    D4-D2 <CLKOUT POSN> Output clock falling edge position (2)
    #       000, 100 Default output clock position (refer to timing specification table)
    #       101 Rising edge shifted (delayed) by + (4/26)×Ts
    #       110 Rising edge shifted (advanced) by – (7/26)×Ts
    #       111 Rising edge shifted (advanced) by – (4/26)×Ts
    # CMOS interface
    #    D7-D5 <CLKOUT POSN> Output clock rising edge position (2)
    #       000, 100 Default output clock position (refer to timing specification table)
    #       101 Rising edge shifted (delayed) by + (4/26)×Ts
    #       110 Rising edge shifted (advanced) by – (7/26)×Ts
    #       111 Rising edge shifted (advanced) by – (4/26)×Ts
    #    D4-D2 <CLKOUT POSN> Output clock falling edge position (2)
    #       000, 100 Default output clock position (refer to timing specification table)
    #       101 Falling edge shifted (delayed) by + (4/26)×Ts
    #       110 Falling edge shifted (advanced) by – (7/26)×Ts
    #       111 Falling edge shifted (advanced) by – (4/26)×Ts
    # Note: 
    #       (1) Ts = 1 / sampling frequency
    #       (2) Keep the same duty cycle, move both edges by the same amount (i.e., write both D<4:2> and D<7:5> to be
    #       the same value).
    clock_edge_control = int('000',2)
    reg0 = (clock_edge_control << 5) + clock_edge_control
    obj.add_register(addr_p=0x44,data_p=reg0,cmt_p='register5')

    ################################################################
    # register6
    ################################################################
    # D6 <ENABLE INDEPENDENT CHANNEL CONTROL>
    #    0 Common control – both channels use common control settings for test patterns, offset correction,
    #      fine gain, gain correction and SNR Boost functions. These settings can be specified in a single set of registers.
    #    1 Independent control – both channels can be programmed with independent control settings for test
    #      patterns, offset correction and SNR Boost functions. Separate registers are available for each channel.
    en_independant_chan_ctrl = 1
    # D2-D1  <DATA FORMAT>
    #   10 2s complement
    #   11 Offset binary
    data_format = 2
    reg0 = (en_independant_chan_ctrl << 6) + (data_format << 1)
    obj.add_register(addr_p=0x50,data_p=reg0,cmt_p='register6')

    ################################################################
    # register7
    ################################################################
    # D7-D0 <CUSTOM PATTERN LOW>
    #   8 lower bits of custom pattern available at the output instead of ADC data.
    # Note: Use this mode along with “Test Patterns” (register 0x62).
    custom_patter_low = 0
    reg0 = custom_patter_low
    obj.add_register(addr_p=0x51,data_p=reg0,cmt_p='register7')

    ################################################################
    # register8
    ################################################################
    # D5-D0 <CUSTOM PATTERN HIGH>
    #   6 upper bits of custom pattern available at the output instead of ADC data
    # Note: Use this mode along with “Test Patterns” (register 0x62).
    custom_patter_high = 0
    reg0 = custom_patter_high
    obj.add_register(addr_p=0x52,data_p=reg0,cmt_p='register8')

    ################################################################
    # register9
    ################################################################
    # D6 <ENABLE OFFSET CORRECTION – Common/Ch A>
    #      Offset correction enable control for both channels (with common control) or for channel A only (with
    #      independent control).
    #   0 Offset correction disabled
    #   1 Offset correction enabled
    en_offset_correction_cha = 1
    reg0 = (en_offset_correction_cha << 6)
    obj.add_register(addr_p=0x53,data_p=reg0,cmt_p='register9')

    ################################################################
    # register10
    ################################################################
    # D7-D4 <GAIN – Common/Ch A>
    #  Gain control for both channels (with common control) or for channel A only (with independent control).
    #    0000 0 dB gain, default after reset
    #    0001 0.5 dB gain
    #    0010 1.0 dB gain
    #    0011 1.5 dB gain
    #    0100 2.0 dB gain
    #    0101 2.5 dB gain
    #    0110 3.0 dB gain
    #    0111 3.5 dB gain
    #    1000 4.0 dB gain
    #    1001 4.5 dB gain
    #    1010 5.0 dB gain
    #    1011 5.5 dB gain
    #    1100 6.0 dB gain
    gain_cha = int('0000',2)
    # D3-D0 <OFFSET CORR TIME CONSTANT – Common/Ch A>
    #    Correction loop time constant in number of clock cycles.
    #    Applies to both channels (with common control) or for channel A only (with independent control).
    #    0000 256 k
    #    0001 512 k
    #    0010 1 M
    #    0011 2 M
    #    0100 4 M
    #    0101 8 M
    #    0110 16 M
    #    0111 32 M
    #    1000 64 M
    #    1001 128 M
    #    1010 256 M
    #    1011 512 M
    offset_corr_time_cha = int('0000',2)
    reg0 = (gain_cha << 4) + offset_corr_time_cha
    obj.add_register(addr_p=0x55,data_p=reg0,cmt_p='register10')

    ################################################################
    # register11
    ################################################################
    # D6-D0 <Fine Gain Adjust - Common/ChA>
    # Using the FINE GAIN ADJUST register bits, the channel gain can be trimmed in fine steps. The trim is only
    # additive, has 128 steps and a range of 0.134dB. The relation between the FINE GAIN ADJUST bits and the
    # trimmed channel gain is:
    #     Δ Channel gain = 20*log10[1 + (FINE GAIN ADJUST/8192)]
    # Note: that the total device gain = ADC gain + Δ Channel gain. The ADC gain is determined by register bits
    #      <GAIN PROGRAMMABILITY>
    fine_gain_adjust_cha = 0
    reg0 = (fine_gain_adjust_cha)
    obj.add_register(addr_p=0x57,data_p=reg0,cmt_p='register11')

    ################################################################
    # register12
    ################################################################
    # D2-D0 <TEST PATTERNS - Common/ChA> Test Patterns to verify data capture.
    #   Applies to both channels (with common control) or for channel A only (with independent control).
    #   000 Normal operation
    #   001 Outputs all zeros
    #   010 Outputs all ones
    #   011 Outputs toggle pattern – see Figure 14 and Figure 15 for test pattern timing diagrams for LVDS and CMOS modes.
    #       In ADS62P49/48, output data <D13:D0> alternates between 01010101010101 and 10101010101010 every clock cycle.
    #       In ADS62P29/28, output data <D11:D0> alternates between 010101010101 and 101010101010 every clock cycle.
    #   100 Outputs digital ramp
    #        In ADS62P49/48, output data increments by one LSB (14-bit) every clock cycle from code 0 to code 16383
    #        In ADS62P29/28, output data increments by one LSB (12-bit) every 4th clock cycle from code 0 to code 4095
    #   101 Outputs custom pattern (use registers 0x51, 0x52 for setting the custom pattern), see Figure 16 for an example of a custom pattern.
    #   110 Unused
    #   111 Unused
    test_pattern = int('011',2)
    reg0 = (test_pattern)
    obj.add_register(addr_p=0x62,data_p=reg0,cmt_p='register12')

    ################################################################
    # register13
    ################################################################
    # D5-D0 <OFFSET PEDESTAL – Common/Ch A>
    #       When the offset correction is enabled, the final converged value (after the offset is corrected) will
    #       be the ideal ADC mid-code value (=8192 for P49/48, = 2048 for P29/28). A pedestal can be
    #       added to the final converged value by programming these bits. So, the final converged value will
    #       be = ideal mid-code + PEDESTAL.
    #       See "Offset Correction" in application section.
    #       Applies to both channels (with common control) or for channel A only (with independent control).
    #    011111 PEDESTAL = 31 LSB
    #    011110 PEDESTAL = 30 LSB
    #    011101 PEDESTAL = 29 LSB
    #    ...
    #    000000 PEDESTAL = 0
    #    ...
    #    111111 PEDESTAL = –1 LSB
    #    111110 PEDESTAL = –2 LSB
    #    ...
    #    100000 PEDESTAL = –32 LSB
    offset_pedestal_cha = int('000000',2)
    reg0 = (offset_pedestal_cha)
    obj.add_register(addr_p=0x63,data_p=reg0,cmt_p='register13')

    ################################################################
    # register14
    ################################################################
    # D6 <ENABLE OFFSET CORRECTION – CH B>
    #     Offset correction enable control for channel B (only with independent control).
    #   0 offset correction disabled
    #   1 offset correction enabled
    offset_corr_chb = 1
    reg0 = (offset_corr_chb << 6)
    obj.add_register(addr_p=0x66,data_p=reg0,cmt_p='register14')

    ################################################################
    # register15
    ################################################################
    # D7-D4 <GAIN – CH B> Gain programmability to 0.5 dB steps.
    #       Applies to channel B (only with independent control).
    #    0000 0 dB gain, default after reset
    #    0001 0.5 dB gain
    #    0010 1.0 dB gain
    #    0011 1.5 dB gain
    #    0100 2.0 dB gain
    #    0101 2.5 dB gain
    #    0110 3.0 dB gain
    #    0111 3.5 dB gain
    #    1000 4.0 dB gain
    #    1001 4.5 dB gain
    #    1010 5.0 dB gain
    #    1011 5.5 dB gain
    #    1100 6.0 dB gain
    gain_chb = int('0000',2)
    # D3-D0 OFFSET CORR TIME CONSTANT – CH B> Time constant of correction loop in number of clock cycles.
    #       Applies to channel B (only with independent control)
    #  0000 256 k
    #  0001 512 k
    #  0010 1 M
    #  0011 2 M
    #  0100 4 M
    #  0101 8 M
    #  0110 16 M
    #  0111 32 M
    #  1000 64 M
    #  1001 128 M
    #  1010 256 M
    #  1011 512 M
    offset_corr_time_chb = int('0000',2)
    reg0 = (gain_chb << 4) + offset_corr_time_chb
    obj.add_register(addr_p=0x68,data_p=reg0,cmt_p='register15')

    ################################################################
    # register16
    ################################################################
    # D7-D0 <FINE GAIN ADJUST – CH B>
    #     Using the FINE GAIN ADJUST register bits, the channel gain can be trimmed in fine steps. The trim is only
    #     additive, has 128 steps and a range of 0.134dB. The relation between the FINE GAIN ADJUST bits and the
    #     trimmed channel gain is:
    #        Δ Channel gain = 20*log10[1 + (FINE GAIN ADJUST/8192)]
    # Note that the total device gain = ADC gain + Δ Channel gain. The ADC gain is determined by register bits
    #  <GAIN PROGRAMMABILITY>
    fine_gain_adjust_chb = 0
    reg0 = fine_gain_adjust_chb
    obj.add_register(addr_p=0x6A,data_p=reg0,cmt_p='register16')

    ################################################################
    # register17
    ################################################################
    # D2-D0 <TEST PATTERNS - CHB> Test Patterns to verify data capture.
    #       Applies to channel B (only with independent control)
    #     000 Normal operation
    #     001 Outputs all zeros
    #     010 Outputs all ones
    #     011 Outputs toggle pattern – see Figure 14 and Figure 15 for LVDS and CMOS modes.
    #        In ADS62P49/48, output data <D13:D0> alternates between 01010101010101 and 10101010101010 every clock cycle.
    #        In ADS62P29/28, output data <D11:D0> alternates between 010101010101 and 101010101010 every clock cycle.
    #     100 Outputs digital ramp
    #        In ADS62P49/48, output data increments by one LSB (14-bit) every clock cycle from code 0 to code 16383
    #        In ADS62P29/28, output data increments by one LSB (12-bit) every 4th clock cycle from code 0 to code 4095
    #     101 Outputs custom pattern (use registers 0x51, 0x52 for setting the custom pattern), see Figure 16 for an example of a custom pattern.
    #     110 Unused
    #     111 Unused
    test_pattern_chb = int('011',2)
    reg0 = test_pattern_chb
    obj.add_register(addr_p=0x75,data_p=reg0,cmt_p='register17')

    ################################################################
    # register18
    ################################################################
    # D5-D0 <OFFSET PEDESTAL – Common/CH B>
    #       When the offset correction is enabled, the final converged value (after the offset is corrected) will
    #       be the ideal ADC mid-code value (=8192 for P49/48, = 2048 for P29/28). A pedestal can be
    #       added to the final converged value by programming these bits. So, the final converged value will
    #       be = ideal mid-code + PEDESTAL. See "Offset Correction" in application section.
    #       Applies to channel B (only with independent control).
    #   011111 PEDESTAL = 31 LSB
    #   011110 PEDESTAL = 30 LSB
    #   011101 PEDESTAL = 29 LSB
    #   ...
    #   000000 PEDESTAL = 0
    #   ...
    #   111111 PEDESTAL = –1 LSB
    #   111110 PEDESTAL = –2 LSB
    #   ...
    #   100000 PEDESTAL = –32 LSB
    offset_pedestal_chb = int('000000',0)
    reg0 = offset_pedestal_chb
    obj.add_register(addr_p=0x76,data_p=reg0,cmt_p='register18')





    ################################################################
    # write the ram content in file
    ################################################################
    fid = open(output_filepath,'w')
    reg_list = obj.get_reg_list()
    cmt_list = obj.get_cmt_list()
    L = len(reg_list)
    index_max = L - 1
    for i in range(L):
        reg = reg_list[i]
        cmt = cmt_list[i]
        str_reg = '{0:016b}'.format(reg)
        fid.write(str_reg)
        fid.write(';')
        fid.write(cmt)
        if index_max != i:
            fid.write('\n')

    fid.close()
