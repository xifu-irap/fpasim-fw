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
#!   @file                   dac3283_init_memory_generator.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference
# -------------------------------------------------------------------------------------------------------------
#!   @details
#
#   This scrips generates data in order to initialize the dac3283 registers.
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

    def set_config0(self,fifo_ena_p=1,fifo_reset_ena_p=1,multi_sync_ena_p=1,alarm_out_ena_p=0,alarm_pol_p=0,mixer_func_p=0):

        cmt = 'config0'
        reserved = 0
        value1 = (reserved << 7 ) + (fifo_ena_p << 6) + (fifo_reset_ena_p << 5) + (multi_sync_ena_p << 4)
        value0 = (alarm_out_ena_p << 3) + (alarm_pol_p << 2) + mixer_func_p
        value = value1 + value0

        self.add_register(addr_p=0x00,data_p=value,cmt_p=cmt)

    def set_config1(self,qmc_offset_ena_p=0,qmc_correct_ena_p=0,fir0_ena_p=0,fir1_ena_p=1,iotest_ena_p=0,twos_p=1):

        cmt = 'config1'
        value1 = (qmc_offset_ena_p << 7) + (qmc_correct_ena_p << 6) + (fir0_ena_p << 5) + (fir1_ena_p << 4)
        value0 = (iotest_ena_p << 2) + twos_p
        value = value1 + value0

        self.add_register(addr_p=0x01,data_p=value,cmt_p=cmt)

    def set_config2(self,sif_sync_p,sif_sync_ena_p,output_delay_p):

        cmt = 'config2'
        value1 = (sif_sync_p << 5) 
        value0 = (sif_sync_ena_p << 4) + output_delay_p
        value = value1 + value0

        self.add_register(addr_p=0x02,data_p=value,cmt_p=cmt)

    def set_config3(self,cnt64_ena_p=0,fifo_offset_p=int('100',2),alarm_2away_ena_p=0,alarm_1away_ena_p=0):

        cmt = 'config3'
        value1 = (cnt64_ena_p << 7)
        value0 = (fifo_offset_p << 2) + (alarm_2away_ena_p << 1) + alarm_1away_ena_p
        value = value1 + value0

        self.add_register(addr_p=0x03,data_p=value,cmt_p=cmt)

    def set_config4(self,coarse_daca_p=int('111',2),coarse_dacb_p=int('111',2)):

        cmt = 'config4'
        value1 = (coarse_daca_p << 4)
        value0 = (coarse_dacb_p << 0)
        value = value1 + value0

        self.add_register(addr_p=0x04,data_p=value,cmt_p=cmt)

    def set_config5(self,tempdata_p):

        cmt = 'config5'
        value = tempdata_p

        self.add_register(addr_p=0x05,data_p=value,cmt_p=cmt)

    def set_config6(self,alarm_mask_p=0):

        cmt = 'config6'
        value = alarm_mask_p

        self.add_register(addr_p=0x06,data_p=value,cmt_p=cmt)

    def set_config7(self,alarm_from_zerochk_p=0,alarm_fifo_collision_p=0,alarm_from_iotest_p=0,alarm_fifo_2away_p=0,alarm_fifo1away_p=0):

        cmt = 'config7'
        value1 = (alarm_from_zerochk_p << 6) + (alarm_fifo_collision_p << 5)
        value0 = (alarm_from_iotest_p << 3) + (alarm_fifo_2away_p << 1) + alarm_fifo1away_p
        value = value1 + value0

        self.add_register(addr_p=0x07,data_p=value,cmt_p=cmt)

    def set_config8(self,iotest_results_p=0):

        cmt = 'config8'
        value = iotest_results_p

        self.add_register(addr_p=0x08,data_p=value,cmt_p=cmt)

    def set_config9(self,iotest_pattern0_p=0x7A):

        cmt = 'config9'
        value = iotest_pattern0_p

        self.add_register(addr_p=0x09,data_p=value,cmt_p=cmt)

    def set_config10(self,iotest_pattern1_p=0xB6):

        cmt = 'config10'
        value = iotest_pattern1_p

        self.add_register(addr_p=0x0A,data_p=value,cmt_p=cmt)

    def set_config11(self,iotest_pattern2_p=0xB6):

        cmt = 'config11'
        value = iotest_pattern2_p

        self.add_register(addr_p=0x0B,data_p=value,cmt_p=cmt)

    def set_config12(self,iotest_pattern3_p=0x45):

        cmt = 'config12'
        value = iotest_pattern3_p

        self.add_register(addr_p=0x0C,data_p=value,cmt_p=cmt)

    def set_config13(self,iotest_pattern4_p=0x1A):

        cmt = 'config13'
        value = iotest_pattern4_p

        self.add_register(addr_p=0x0D,data_p=value,cmt_p=cmt)

    def set_config14(self,iotest_pattern5_p=0x16):

        cmt = 'config14'
        value = iotest_pattern5_p

        self.add_register(addr_p=0x0E,data_p=value,cmt_p=cmt)

    def set_config15(self,iotest_pattern6_p=0xAA):

        cmt = 'config15'
        value = iotest_pattern6_p

        self.add_register(addr_p=0x0F,data_p=value,cmt_p=cmt)

    def set_config16(self,iotest_pattern7_p=0xC6):

        cmt = 'config16'
        value = iotest_pattern7_p

        self.add_register(addr_p=0x10,data_p=value,cmt_p=cmt)

    def set_config17(self,clk_alarm_mask_p=0,tx_off_mask_p=0,clk_alarm_ena_p=0,tx_off_ena_p=0):

        cmt = 'config17'
        reserved = 1
        value1 = (reserved << 5 ) + (clk_alarm_mask_p << 4)
        value0 = (tx_off_mask_p << 3) + (reserved << 2) + (clk_alarm_ena_p << 1) + tx_off_ena_p
        value = value1 + value0

        self.add_register(addr_p=0x11,data_p=value,cmt_p=cmt)

    def set_config18(self,daca_complement_p=0,dacb_complement_p=0,clkdiv_sync_ena_p=1):

        cmt = 'config18'
        value1 = 0
        value0 = (daca_complement_p << 3) + (dacb_complement_p << 2) + (clkdiv_sync_ena_p << 1)
        value = value1 + value0

        self.add_register(addr_p=0x12,data_p=value,cmt_p=cmt)

    def set_config19(self,bequalsa_p=0,aequalsb_p=0,multi_sync_sel_p=0,rev_p=0):

        cmt = 'config19'
        value1 = (bequalsa_p << 7) + (aequalsb_p << 6)
        value0 = (multi_sync_sel_p << 1) + rev_p
        value = value1 + value0

        self.add_register(addr_p=0x13,data_p=value,cmt_p=cmt)

    def set_config20(self,qmc_offseta_p=0):

        cmt = 'config20'
        value = (qmc_offseta_p & 0x00FF)

        self.add_register(addr_p=0x14,data_p=value,cmt_p=cmt)

    def set_config21(self,qmc_offsetb_p=0):

        cmt = 'config21'
        value = (qmc_offsetb_p & 0x00FF)

        self.add_register(addr_p=0x15,data_p=value,cmt_p=cmt)

    def set_config22(self,qmc_offseta_p=0):

        cmt = 'config22'
        qmc_offseta = ((qmc_offseta_p & 0x1F00) >> 8)
        value1 = (qmc_offseta << 4)
        value0 = 0
        value = value1 + value0

        self.add_register(addr_p=0x16,data_p=value,cmt_p=cmt)

    def set_config23(self,qmc_offsetb_p=0,sif4_ena_p=0,clkpath_sleep_a_p=0,clkpath_sleep_b_p=0):

        cmt = 'config23'
        qmc_offsetb = ((qmc_offsetb_p & 0x1F00) >> 8)
        value1 = (qmc_offsetb << 4)
        value0 = (sif4_ena_p << 2) + (clkpath_sleep_a_p << 1) + clkpath_sleep_b_p
        value = value1 + value0

        self.add_register(addr_p=0x17,data_p=value,cmt_p=cmt)

    def set_config24(self,tsense_ena_p=1,clkrecv_sleep_p=0,sleepb_p=0,sleepa_p=0):

        cmt = 'config24'
        reserved = 0x1
        value1 = (tsense_ena_p << 7) + (clkrecv_sleep_p << 6)
        value0 = (sleepb_p << 3) + (sleepa_p << 2) + (reserved << 1) + reserved
        value = value1 + value0

        self.add_register(addr_p=0x18,data_p=value,cmt_p=cmt)

    def set_config25(self,extref_ena_p=0):

        cmt = 'config25'
        value1 = 0
        value0 = (extref_ena_p << 2)
        value = value1 + value0

        self.add_register(addr_p=0x19,data_p=value,cmt_p=cmt)

    def set_config26(self):

        cmt = 'config26'
        value1 = 0
        value0 = 0
        value = value1 + value0

        self.add_register(addr_p=0x1A,data_p=value,cmt_p=cmt)

    def set_config27(self,qmc_gaina_p=0):

        cmt = 'config27'
        value1 = (qmc_gaina_p & 0x00FF)
        value0 = 0
        value = value1 + value0

        self.add_register(addr_p=0x1B,data_p=value,cmt_p=cmt)

    def set_config28(self,qmc_gainb_p=0):

        cmt = 'config28'
        value1 = (qmc_gainb_p & 0x00FF)
        value0 = 0
        value = value1 + value0

        self.add_register(addr_p=0x1C,data_p=value,cmt_p=cmt)

    def set_config29(self,qmc_phase_p=0):

        cmt = 'config29'
        value1 = (qmc_phase_p & 0x00FF)
        value0 = 0
        value = value1 + value0

        self.add_register(addr_p=0x1D,data_p=value,cmt_p=cmt)

    def set_config30(self,qmc_phase_p=0,qmc_gaina_p=int('100_0000_0000',2),qmc_gainb_p=int('100_0000_0000',2)):

        cmt = 'config30'
        qmc_phase = ((qmc_phase_p & 0x3F00) >> 8)
        qmc_gaina = ((qmc_gaina_p & 0x5F00) >> 8)
        qmc_gainb = ((qmc_gainb_p & 0x5F00) >> 8)

        value1 = (qmc_phase << 6)
        value0 = (qmc_gaina << 3) + (qmc_gainb)
        value = value1 + value0

        self.add_register(addr_p=0x1E,data_p=value,cmt_p=cmt)

    def set_config31(self,clk_alarm_p=0,tx_off_p=0,version_p=int('010010',2)):

        cmt = 'config31'
        value1 = (clk_alarm_p << 7) + (tx_off << 6)
        value0 = version_p
        value = value1 + value0

        self.add_register(addr_p=0x1F,data_p=value,cmt_p=cmt)


    def get_cmt_list(self):
        return self.cmt_list

    def get_reg_list(self):

        res = []
        # mode
        #  wr : 0
        #  rd : 1
        mode = 0
        # Number of Transferred Bytes Within One Communication Frame
        #  '00' : 1 byte
        #  '01' : 2 bytes
        #  '10' : 3 bytes
        #  '11' : 4 bytes
        nb_bytes = int('00',2)

        # convert to binary
        str_mode = '{0:01b}'.format(mode)
        str_nb_bytes = '{0:02b}'.format(nb_bytes)

        L = len(self.addr_list)
        for i in range(L):
            str_addr = '{0:04b}'.format(self.addr_list[i])
            # build the byte0 (string)
            str0 = str_mode + str_nb_bytes + str_addr 
            byte1 = int(str0,2)
            byte0 = self.data_list[i]

            value = (byte1 << 8) + byte0
            res.append(value)

        return res



if __name__ == "__main__":
    # define the base address where to find the *.csv input files
    base_address = './'
    output_filename = 'dac3283_init_mem.txt'
    output_filepath = str(Path(base_address,output_filename))
    
    obj = Ram()
    ################################################################
    # config0
    ################################################################
    # When asserted the FIFO is enabled. When the FIFO is bypassed
    #   DACCCLKP/N and DATACLKP/N must be aligned to within t_align.
    #   [6]: R/W: fifo_ena[0]
    #
    # Allows the FRAME input to reset the FIFO write pointer when asserted
    # [5]: R/W: fifo_reset_ena[0]
    #
    # Allows the FRAME or OSTR signal to reset the FIFO read pointer when
    # asserted. This selection is determined by multi_sync_sel in register CONFIG19.
    # [4]: R/W: multi_sync_ena[0]
    #
    # When asserted the ALARM_SDO pin becomes an output. The functionality of
    # this pin is controlled by the CONFIG6 alarm_mask setting.
    # [3]: R/W: alarm_out_ena[0]
    #
    # This bit changes the polarity of the ALARM signal. (0=negative logic, 1=positive logic)
    # [2]: R/W: alarm_pol[0]
    #
    # Controls the function of the mixer block.
    #     Normal : 00
    #     high pass (Fs/2) : 01
    #     Fs/4 : 10
    #     -Fs/4 : 11
    # [1:0]: R/W: mixer_func[1:0]

    fifo_ena = 1
    fifo_reset_ena = 1
    multi_sync_ena = 1
    alarm_out_ena = 0
    alarm_pol = 0
    mixer_func = 0

    obj.set_config0(fifo_ena_p=fifo_ena,fifo_reset_ena_p=fifo_reset_ena,multi_sync_ena_p=multi_sync_ena,alarm_out_ena_p=alarm_out_ena,alarm_pol_p=alarm_pol,mixer_func_p=mixer_func)
    ################################################################
    # config1
    ################################################################
    # When asserted the QMC offset correction circuitry is enabled.
    # [7]: R/W: qmc_offset_ena[0]
    #
    # When asserted the QMC phase and gain correction circuitry is enabled.
    # [6]: R/W: qmc_correct_ena[0]
    #
    # When asserted FIR0 is activated enabling 2x interpolation.
    # [5]: R/W: fir0_ena[0]
    #
    # When asserted FIR1 is activated enabling 4x interpolation. fir0_ena must be set to '1' for 4x interpolation.
    # [4]: R/W: fir1_ena[0]
    #
    # When asserted enables the data pattern checker operation.
    # [2]: R/W: iotest_ena[0]
    #
    # When asserted the inputs are expected to be in 2's complement format. When
    # de-asserted the input format is expected to be offset-binary.
    # [0]: R/W: twos[0]
    qmc_offset_ena = 0
    qmc_correct_ena = 0
    fir0_ena = 1
    fir1_ena = 1
    iotest_ena = 0
    twos = 1
    obj.set_config1(qmc_offset_ena_p=qmc_offset_ena,qmc_correct_ena_p=qmc_correct_ena,fir0_ena_p=fir0_ena,fir1_ena_p=fir1_ena,iotest_ena_p=iotest_ena,twos_p=twos)

    ################################################################
    # config2
    ################################################################
    # Serial interface created sync signal. Set to '1' to cause a sync and then clear to '0' to remove it.
    # [5]: R/W: sif_sync[0]
    #
    # When asserted this bit allows the SIF sync to be used. Normal FRAME signals are ignored.
    # [4]: R/W: sif_sync_ena[0]
    #
    # Delays the output to the DACs from 0 to 3 DAC clock cycles.
    # [1:0]: R/W: output_delay[1:0]
    sif_sync = 0
    sif_sync_ena = 0
    output_delay = 0
    obj.set_config2(sif_sync_p= sif_sync,sif_sync_ena_p=sif_sync_ena,output_delay_p = output_delay)

    ################################################################
    # config3
    ################################################################
    # This enables resetting the alarms after 64 good samples with the
    # goal of removing unnecessary errors. For instance, when checking
    # setup/hold through the pattern checker test, there may initially be
    # errors. Setting this bit removes the need for a SIF write to clear the
    # alarm register.
    # [7]: R/W: cnt64_ena[0]
    #
    # This is the default FIFO read pointer position after the FIFO read
    # pointer has been synced. With this value the initial difference
    # between write and read pointers can be controlled. This may be
    # helpful in controlling the delay through the device.
    # [4:2]: R/W: fifo_offset[2:0]
    #
    # When asserted alarms from the FIFO that represent the write and
    # read pointers being 2 away are enabled.
    # [1]: R/W: alarm_2away_ena[0]
    #
    # When asserted alarms from the FIFO that represent the write and
    # read pointers being 1 away are enabled.
    # [0]: R/W: alarm_1away_ena[0]
    cnt64_ena = 0
    fifo_offset = 4
    alarm_2away_ena = 0
    alarm_1away_ena = 0
    obj.set_config3(cnt64_ena_p=cnt64_ena,fifo_offset_p=fifo_offset,alarm_2away_ena_p=alarm_2away_ena,alarm_1away_ena_p=alarm_1away_ena)

    ################################################################
    # config4
    ################################################################
    # Scales the DACA output current in 16 equal steps.
    # (VEXTIO/Rbias)*(coarse_daca/b + 1)
    # [7:4]: R/W: coarse_daca[3:0]
    #
    # Scales the DACB output current in 16 equal steps.
    # [3:0]: R/W: coarse_dacb[3:0]
    coarse_daca = 15
    coarse_dacb = 15
    obj.set_config4(coarse_daca_p = coarse_daca,coarse_dacb_p=coarse_dacb)

    ################################################################
    # config5
    ################################################################
    # This is the output from the chip temperature sensor. The value
    # of this register in two’s complement format represents the
    # temperature in degrees Celsius. This register must be read
    # with a minimum SCLK period of 1μs. (Read Only)
    # [7:0]: R: tempdata[7:0]
    tempdata = 0
    obj.set_config5(tempdata_p=tempdata)

    ################################################################
    # config6
    ################################################################
    # These bits control the masking of the alarm outputs. This
    # means that the ALARM_SDO pin will not be asserted if the
    # appropriate bit is set. The alarm will still show up in the
    # CONFIG7 bits. (0=not masked, 1= masked).
    # alarm_mask                  Masked Alarm
    #       6                     alarm_from_zerochk
    #       5                     alarm_fifo_collision
    #       4                     reserved
    #       3                     alarm_from_iotest
    #       2                     not used (expansion)
    #       1                     alarm_fifo_2away
    #       0                     alarm_fifo_1away
    # [6:0]: R/W: alarm_mask[6:0] 
    alarm_mask = 0
    obj.set_config6(alarm_mask_p=alarm_mask)

    ################################################################
    # config7
    ################################################################
    # This alarm indicates the 8-bit FIFO write pointer address has an all
    # zeros patterns. Due to pointer address being a shift register, this is
    # not a valid address and will cause the write pointer to be stuck until
    # the next sync. This error is typically caused by timing error or
    # improper power start-up sequence. If this alarm is asserted,
    # resynchronization of FIFO is necessary. Refer to the Power-Up
    # Sequence section for more detail.
    # [6]: W: alarm_from_zerochk[0]
    #
    # Alarm occurs when the FIFO pointers over/under run each other.
    # [5]: W: alarm_fifo_collision[0]
    #
    # This is asserted when the input data pattern does not match the
    # pattern in the iotest_pattern registers.
    # [3]: W: alarm_from_iotest[0]
    #
    # Alarm occurs with the read and write pointers of the FIFO are within 2 addresses of each other.
    # [1]: W: alarm_fifo_2away[0]
    #
    # Alarm occurs with the read and write pointers of the FIFO are within 1 address of each other.
    # [0]: W: alarm_fifo1away[0]
    alarm_from_zerochk = 0
    alarm_fifo_collision = 0
    alarm_from_iotest = 0
    alarm_fifo_2away = 0
    alarm_fifo1away = 0
    obj.set_config7(alarm_from_zerochk_p=alarm_from_zerochk,alarm_fifo_collision_p=alarm_fifo_collision,alarm_from_iotest_p=alarm_from_iotest,alarm_fifo_2away_p=alarm_fifo_2away,alarm_fifo1away_p=alarm_fifo1away)



    ################################################################
    # config8
    ################################################################
    # The values of these bits tell which bit in the byte-wide LVDS bus
    # failed during the pattern checker test.
    # [7:0]: R/W: iotest_results[7:0]
    iotest_results = int('0',2)
    obj.set_config8(iotest_results_p=iotest_results)

    ################################################################
    # config9
    ################################################################
    # This is dataword0 in the IO test pattern. It is used with the seven
    # other words to test the input data.
    # [7:0]: R/W: iotest_pattern0[7:0]
    iotest_pattern0 = int('01010101',2)
    obj.set_config9(iotest_pattern0_p=iotest_pattern0)

    ################################################################
    # config10
    ################################################################
    # This is dataword1 in the IO test pattern. It is used with the seven
    # other words to test the input data.
    # [7:0]: R/W: iotest_pattern1[7:0]
    iotest_pattern1 = int('10101010',2)
    obj.set_config10(iotest_pattern1_p=iotest_pattern1)

    ################################################################
    # config11
    ################################################################
    # This is dataword2 in the IO test pattern. It is used with the seven
    # other words to test the input data.
    # [7:0]: R/W: iotest_pattern2[7:0]
    iotest_pattern2 = int('01010101',2)
    obj.set_config11(iotest_pattern2_p=iotest_pattern2)

    ################################################################
    # config12
    ################################################################
    # This is dataword3 in the IO test pattern. It is used with the seven
    # other words to test the input data.
    # [7:0]: R/W: iotest_pattern3[7:0]
    iotest_pattern3 = int('10101010',2)
    obj.set_config12(iotest_pattern3_p=iotest_pattern3)

    ################################################################
    # config13
    ################################################################
    # This is dataword4 in the IO test pattern. It is used with the seven
    # other words to test the input data.
    # [7:0]: R/W: iotest_pattern4[7:0]
    iotest_pattern4 = int('01010101',2)
    obj.set_config13(iotest_pattern4_p=iotest_pattern4)

    ################################################################
    # config14
    ################################################################
    # This is dataword5 in the IO test pattern. It is used with the seven
    # other words to test the input data.
    # [7:0]: R/W: iotest_pattern5[7:0]
    iotest_pattern5 = int('10101010',2)
    obj.set_config14(iotest_pattern5_p=iotest_pattern5)

    ################################################################
    # config15
    ################################################################
    # This is dataword6 in the IO test pattern. It is used with the seven
    # other words to test the input data.
    # [7:0]: R/W: iotest_pattern6[7:0]
    iotest_pattern6 = int('01010101',2)
    obj.set_config15(iotest_pattern6_p=iotest_pattern6)

    ################################################################
    # config16
    ################################################################
    # This is dataword7 in the IO test pattern. It is used with the seven
    # other words to test the input data.
    # [7:0]: R/W: iotest_pattern7[7:0]
    iotest_pattern7 = int('10101010',2)
    obj.set_config16(iotest_pattern7_p=iotest_pattern7)

    ################################################################
    # config17
    ################################################################
    # This bit controls the masking of the clock monitor alarm. This
    # means that the ALARM_SDO pin will not be asserted. The alarm
    # will still show up in the clk_alarm bit. (0=not masked, 1= masked).
    # [4]: R/W: clk_alarm_mask[0]
    #
    # This bit control the masking of the transmit enable alarm. This
    # means that the ALARM_SDO pin will not be asserted. The alarm
    # will still show up in the tx_off bit. (0=not masked, 1= masked).
    # [3]: R/W: tx_off_mask[0]
    #
    # When asserted the DATACLK monitor alarm is enabled.
    # [1]: R/W: clk_alarm_ena[0]
    #
    # When asserted a clk_alarm event will automatically disable the
    # AC outputs by setting them to midscale.
    # [0]: R/W: tx_off_ena[0]
    clk_alarm_mask = 0
    tx_off_mask = 0
    clk_alarm_ena = 0
    tx_off_ena = 0
    obj.set_config17(clk_alarm_mask_p=clk_alarm_mask,tx_off_mask_p=tx_off_mask,clk_alarm_ena_p=clk_alarm_ena,tx_off_ena_p=tx_off_ena)

    ################################################################
    # config18
    ################################################################
    # When asserted the output to the DACA is complemented. This
    # allows to effectively change the + and – designations of the LVDS data lines.
    # [3]: R/W: daca_complement[0]
    #
    # When asserted the output to the DACB is complemented. This
    # allows to effectively change the + and – designations of the LVDS data lines.
    # [2]: R/W: dacb_complement[0]
    #
    # Enables the syncing of the clock divider using the OSTR signal
    # or the FRAME signal passed through the FIFO. This selection is
    # determined by multi_sync_sel in register CONFIG19. The
    # internal divided-down clocks will be phase aligned after syncing.
    # See Power-Up Sequence section for more detail.
    # [1]: R/W: clkdiv_sync_ena[0]
    daca_complement = 0
    dacb_complement = 0
    clkdiv_sync_ena = 1
    obj.set_config18(daca_complement_p=daca_complement,dacb_complement_p=dacb_complement,clkdiv_sync_ena_p=clkdiv_sync_ena)

    ################################################################
    # config19
    ################################################################
    # When asserted the DACA data is driven onto DACB.
    # [7]: R/W: bequalsa[0]
    #
    # When asserted the DACB data is driven onto DACA.
    # [6]: R/W: aequalsb[0]
    #
    # Selects the signal source for multiple device and clock divider synchronization.
    #    multi_sync_sel                    sync_source
    #          0                            OSTR
    #          1                            Frame through FIFO handoff
    # [1]: R/W: multi_sync_sel[0]
    #
    # Reverse the input bits for the data word. MSB becomes LSB.
    # [0]: R/W: rev[0]
    bequalsa = 1
    aequalsb = 1
    multi_sync_sel = 1
    rev = 0
    obj.set_config19(bequalsa_p=bequalsa,aequalsb_p=aequalsb,multi_sync_sel_p=multi_sync_sel,rev_p=rev)

    ################################################################
    # config20 - 23
    ################################################################
    # Lower 8 bits of the DAC A offset correction. The offset is
    # measured in DAC LSBs. Writing this register causes an
    # autosync to be generated. This loads the values of all four
    # qmc_offset registers (CONFIG20-CONFIG23) into the offset
    # block at the same time. When updating the offset values
    # CONFIG20 should be written last. Programming any of the
    # other three registers will not affect the offset setting.
    # [12:0]: R/W: qmc_offseta
    #
    # Lower 8 bits of the DAC B offset correction. The offset is measured in DAC LSBs.
    # [12:0]: R/W: qmc_offsetb
    #
    # When asserted the SIF interface becomes a 4 pin interface. The
    # ALARM pin is turned into a dedicated output for the reading of data.
    # [2]: R/W: sif4_ena[0]
    #
    # When asserted puts the clock path through DAC A to sleep. This
    # is useful for sleeping individual DACs. Even if the DAC is asleep
    # the clock needs to pass through it for the logic to work.
    # However, if the chip is being put into a power down mode, then
    # all parts of the DAC can be turned off.
    # [1]: R/W: clkpath_sleep_a[0]
    #
    # When asserted puts the clock path through DAC B to sleep.
    # [0]: R/W: clkpath_sleep_b[0]
    qmc_offseta = 0
    qmc_offsetb = 0
    sif4_ena = 1
    clkpath_sleep_a = 0
    clkpath_sleep_b = 0

    obj.set_config20(qmc_offseta_p=qmc_offseta)
    obj.set_config21(qmc_offsetb_p = qmc_offsetb)
    obj.set_config22(qmc_offseta_p = qmc_offseta)
    obj.set_config23(qmc_offsetb_p = qmc_offsetb,sif4_ena_p=sif4_ena,clkpath_sleep_a_p=clkpath_sleep_a,clkpath_sleep_b_p=clkpath_sleep_b)


    ################################################################
    # config24
    ################################################################
    # Turns on the temperature sensor when asserted.
    # [7]: R/W: tsense_ena[0]
    #
    # When asserted the clock input receiver gets put into sleep mode.
    # This also affects the OSTR receiver.
    # [6]: R/W: clkrecv_sleep[0]
    #
    # When asserted DACB is put into sleep mode.
    # [3]: R/W: sleepb[0]
    #
    # When asserted DACA is put into sleep mode.
    # [2]: R/W: sleepa[0]
    tsense_ena = 1
    clkrecv_sleep = 0
    sleepb = 0
    sleepa = 0

    obj.set_config24(tsense_ena_p=tsense_ena,clkrecv_sleep_p=clkrecv_sleep,sleepb_p=sleepb,sleepa_p=sleepa)

    ################################################################
    # config25
    ################################################################
    # Allows the device to use an external reference or the internal reference.
    #  (0=internal, 1=external)
    # [2]: R/W: extref_ena[0]
    extref_ena = 0
    obj.set_config25(extref_ena_p=extref_ena)

    ################################################################
    # config26
    ################################################################
    # [0]: R/W
    obj.set_config26()


    ################################################################
    # config27 - 30
    ################################################################
    # Lower 8 bits of the 11-bit DAC A QMC gain word. The upper 3
    # bits are located in the CONFIG30 register. The full 11-bit
    # qmc_gaina(10:0) value is formatted as UNSIGNED with a range
    # of 0 to 1.9990 and a default gain of 1. The implied decimal point
    # for the multiplication is between bits 9 and 10. Writing this
    # register causes an autosync to be generated. This loads the
    # values of all four qmc_phase/gain registers (CONFIG27-
    # CONFIG30) into the QMC block at the same time. When
    # updating the QMC phase and/or gain values CONFIG27
    # should be written last. Programming any of the other three
    # registers will not affect the QMC settings.
    # [10:0]: R/W: qmc_gaina
    #
    # Lower 8 bits of the 11-bit DAC B QMC gain word. The upper 3
    # bits are located in the CONFIG30 register. Refer to CONFIG27
    # for formatting.
    # [10:0]: R/W: qmc_gainb
    #
    # Lower 8-bits of the 10-bit QMC phase word. The upper 2 bits are
    # in the CONFIG30 register. The full 10-bit qmc_phase(9:0) word
    # is formatted as two's complement and scaled to occupy a range
    # of –0.125 to 0.12475 (note this value does not correspond to
    # degrees) and a default phase correction of 0. To accomplish
    # QMC phase correction, this value is multiplied by the current 'Q'
    # sample, then summed into the ‘I’ sample.
    # [9:0]: R/W: qmc_phase
    qmc_gaina = int('100_0000_0000',2)
    qmc_gainb = int('100_0000_0000',2)
    qmc_phase = int('0_0000_0000',2)

    obj.set_config27(qmc_gaina_p=qmc_gaina)
    obj.set_config28(qmc_gainb_p=qmc_gainb)
    obj.set_config29(qmc_phase_p=qmc_phase)
    obj.set_config30(qmc_phase_p=qmc_phase,qmc_gaina_p=qmc_gaina,qmc_gainb_p=qmc_gainb)

    ################################################################
    # config31
    ################################################################
    # This bit is set to '1' when DATACLK is stopped for 4 clock
    # cycles. Once set, the bit needs to be cleared by writing a '0'.
    # [7]: R: clk_alarm[0]
    #
    # This bit is set to '1' when the clk_alarm is triggered. When set
    # the DAC outputs are forced to mid-level. Once set, the bit needs
    # to be cleared by writing a '0'.
    # [6]: R: tx_off[0]
    # 
    # A hardwired register that contains the version of the chip. (Read Only)
    # [5:0]: R: version[5:0]
    clk_alarm = 0
    tx_off = 1
    version = int('10010',2)
    obj.set_config31(clk_alarm_p=clk_alarm,tx_off_p=tx_off,version_p=version)

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
