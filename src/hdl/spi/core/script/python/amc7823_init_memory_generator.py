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
#!   @file                   amc7823_init_memory_generator.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference
# -------------------------------------------------------------------------------------------------------------
#!   @details
#
#   This scrips generates data in order to initialize the amc7823 registers.
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
        self.page_list = []

    def add_register(self,addr_p,data_p,page_p,cmt_p=''):
        self.addr_list.append(addr_p)
        self.data_list.append(data_p)
        self.cmt_list.append(cmt_p)
        self.page_list.append(page_p)



    
      ###############################################################
      # set the set_gpio register
      ###############################################################
      # [11:08]: R/W: iomod_p[3:0]
      # [05:00]: R/W: iost_p[5:0]
    def set_gpio(self,
                    iomod_p,
                    iost_p
                    ):

        cmt = 'set_gpio'
        value1 = (int('1111',2) << 12) + (int('11',2) << 6)
        value0 = (iomod_p << 8) + iost_p

        value = value1 +  value0;
        page = 0

        self.add_register(addr_p=0x0A,data_p=value,page_p=page,cmt_p=cmt)

    ###############################################################
    # set the dac(s) register
    ###############################################################
    # [11:0]: R/W: dac[11:0]
    # dac_id_p: (0 to 7)
    def set_dac(self,
                    dac_p,dac_id_p
                    ):

        cmt = 'set_dac'+str(dac_id_p)
        value0 = dac_p

        value = value0
        page = 1

        if dac_id_p == 0:
            addr = 0x00;
        elif dac_id_p == 1:
            addr = 0x01;
        elif dac_id_p == 2:
            addr = 0x02;
        elif dac_id_p == 3:
            addr = 0x03;
        elif dac_id_p == 4:
            addr = 0x04;
        elif dac_id_p == 5:
            addr = 0x05;
        elif dac_id_p == 6:
            addr = 0x06;
        else: # dac_id_p == 6
            addr = 0x07;

        self.add_register(addr_p=addr,data_p=value,page_p=page,cmt_p=cmt)


    
    ###############################################################
    # set the dac_load register
    ###############################################################
    # RW
    def set_dac_load(self):

        cmt = 'set_dac_load'
        value0 = 0xBB00;

        value = value0;
        page = 1
        addr = 0x08;

        self.add_register(addr_p=addr,data_p=value,page_p=page,cmt_p=cmt)


    ###############################################################
    # set the dac_conf(s) register
    ###############################################################
    # [15:8]: R/W: slda_p[7:0]
    # [7:0]: R/W: gdac_p[7:0]
    def set_dac_conf(self,
                    slda_p,gdac_p
                    ):

        cmt = 'set_dac_conf'
        value0 = (slda_p << 8) + gdac_p

        value = value0
        page = 1
        addr = 0x09;

        self.add_register(addr_p=addr,data_p=value,page_p=page,cmt_p=cmt)

    ###############################################################
    # set the set_amc_status_conf register
    ###############################################################
    # [14]: R/W: rstc_p[0]
    # [13]: R/W: davf_p[0]
    # [7]: R/W: sref_p[0]
    # [6]: R/W: gref_p[0]
    # [5]: R/W: ecnvt_p[0]
    def set_amc_status_conf(self,
                    rstc_p,davf_p,sref_p,gref_p,ecnvt_p
                    ):

        cmt = 'set_amc_status_conf'
        value1 = (rstc_p << 14) + (davf_p << 13)
        value0 = (sref_p << 7) + (gref_p << 6) + (ecnvt_p << 5) 

        value = value1 + value0
        page = 1
        addr = 0x0A;

        self.add_register(addr_p=addr,data_p=value,page_p=page,cmt_p=cmt)


    ###############################################################
    # set the adc_ctrl register
    ###############################################################
    # [15]: R/W: cmode_p[0]
    # [11:8]: R/W: sa_p[3:0]
    # [7:4]: R/W: ea_p[3:0]
    def set_adc_ctrl(self,
                    cmode_p,sa_p,ea_p
                    ):

        cmt = 'set_adc_ctrl'
        value1 = (cmode_p << 15) + (sa_p << 8)
        value0 = (ea_p << 4)

        value = value1 + value0
        page = 1
        addr = 0x0B;

        self.add_register(addr_p=addr,data_p=value,page_p=page,cmt_p=cmt)


    ###############################################################
    # set the set_reset register
    ###############################################################
    def set_reset(self):

        cmt = 'set_reset'
        value0 = 0xBB30

        value = value0
        page = 1
        addr = 0x0C;

        self.add_register(addr_p=addr,data_p=value,page_p=page,cmt_p=cmt)

    ###############################################################
    # set the set_power_down register
    ###############################################################
    # [15]: R/W: padc_p[0]
    # [14:7]: R/W: pdac_p[7:0]
    # [6]: R/W: pts_p[0]
    # [5]: R/W: prefb_p[0]
    def set_power_down(self, padc_p, pdac_p, pts_p, prefb_p):

        cmt = 'set_power_down'
        value1 = (padc_p << 15) + (pdac_p << 7)
        value0 = (pts_p << 6) + (prefb_p << 5)

        value = value1 + value0
        page = 1
        addr = 0x0D;

        self.add_register(addr_p=addr,data_p=value,page_p=page,cmt_p=cmt)


    ###############################################################
    # set the set_threshold_hi register
    ###############################################################
    # [11:0]: R/W: threshold_p[11:0]
    # threshold_id_p (0 to 3)
    def set_threshold_hi(self,threshold_p,threshold_id_p):

        cmt = 'set_threshold_hi'
        value0 = threshold_p

        value =  value0
        page = 1
        if threshold_id_p == 0:
            addr = 0x0E;
        elif threshold_id_p == 1:
            addr = 0x10;
        elif threshold_id_p == 2:
            addr = 0x12;
        else: # threshold_id = 3
            addr = 0x14;

        self.add_register(addr_p=addr,data_p=value,page_p=page,cmt_p=cmt)

    ###############################################################
    # set the set_threshold_hi register
    ###############################################################
    # [11:0]: R/W: threshold_p[11:0]
    # threshold_id_p (0 to 3)
    def set_threshold_lo(self,threshold_p,threshold_id_p):

        cmt = 'set_threshold_lo'
        value0 = threshold_p

        value =  value0
        page = 1
        if threshold_id_p == 0:
            addr = 0x0F;
        elif threshold_id_p == 1:
            addr = 0x11;
        elif threshold_id_p == 2:
            addr = 0x13;
        else: # threshold_id = 3
            addr = 0x15;

        self.add_register(addr_p=addr,data_p=value,page_p=page,cmt_p=cmt)


    def get_cmt_list(self):
        return self.cmt_list

    def get_reg_list(self):

        res = []

        L = len(self.addr_list)
        for i in range(L):
            # build the byte0 (string)
            page  = self.page_list[i]
            addr = self.addr_list[i]
            data = self.data_list[i]

            value = (page << 24) + (addr << 16) + data
            res.append(value)

        return res



if __name__ == "__main__":
    # define the base address where to find the *.csv input files
    base_address = './'
    output_filename = 'amc7823_init_mem.txt'
    output_filepath = str(Path(base_address,output_filename))
    
    obj = Ram()

    ###############################################################
      # set the set_gpio register
      ###############################################################
      # [11:08]: R/W: iomod_p[3:0]
      # [05:00]: R/W: iost_p[5:0]
    iomod = int('1111',2);
    iost = int('111111',2);
    obj.set_gpio(iomod_p=iomod,iost_p=iost);

    ###############################################################
    # set the set_amc_status_conf register
    ###############################################################
    # [14]: R/W: rstc_p[0]
    # [13]: R/W: davf_p[0]
    # [7]: R/W: sref_p[0]
    # [6]: R/W: gref_p[0]
    # [5]: R/W: ecnvt_p[0]
    rstc = 0;
    davf = 0;
    sref = 0;
    gref = 0;
    ecnvt = 0;
    obj.set_amc_status_conf(rstc_p = rstc,davf_p = davf,sref_p=sref,gref_p=gref,ecnvt_p=ecnvt);

    ###############################################################
    # set the adc_ctrl register
    ###############################################################
    # [15]: R/W: cmode_p[0]
    # [11:8]: R/W: sa_p[3:0]
    # [7:4]: R/W: ea_p[3:0]
    cmode = 1;
    sa = int('0000',2);
    ea = int('1000',2);
    obj.set_adc_ctrl(cmode_p = cmode,sa_p=sa,ea_p = ea);

    ###############################################################
    # set the set_power_down register
    ###############################################################
    # [15]: R/W: padc_p[0]
    # [14:7]: R/W: pdac_p[7:0]
    # [6]: R/W: pts_p[0]
    # [5]: R/W: prefb_p[0]
    padc = 1;
    pdac = int('0000_0000',2);
    pts = 0;
    prefb = 0;
    obj.set_power_down(padc_p=padc, pdac_p=pdac, pts_p=pts, prefb_p=prefb);

    ###############################################################
    # set the set_threshold_hi register
    ###############################################################
    # [11:0]: R/W: threshold_p[11:0]
    # threshold_id_p (0 to 3)
    threshold = 0x0B16;
    threshold_id = 0;
    obj.set_threshold_hi(threshold_p=threshold,threshold_id_p=threshold_id);

    ###############################################################
    # set the set_threshold_lo register
    ###############################################################
    # [11:0]: R/W: threshold_p[11:0]
    # threshold_id_p (0 to 3)
    threshold = 0x0A08;
    threshold_id = 0;
    obj.set_threshold_lo(threshold_p=threshold,threshold_id_p=threshold_id);

    ###############################################################
    # set the set_threshold_hi register
    ###############################################################
    # [11:0]: R/W: threshold_p[11:0]
    # threshold_id_p (0 to 3)
    threshold = 0x0B16;
    threshold_id = 1;
    obj.set_threshold_hi(threshold_p=threshold,threshold_id_p=threshold_id);

    ###############################################################
    # set the set_threshold_lo register
    ###############################################################
    # [11:0]: R/W: threshold_p[11:0]
    # threshold_id_p (0 to 3)
    threshold = 0x0A08;
    threshold_id = 1;
    obj.set_threshold_lo(threshold_p=threshold,threshold_id_p=threshold_id);

    ###############################################################
    # set the set_threshold_hi register
    ###############################################################
    # [11:0]: R/W: threshold_p[11:0]
    # threshold_id_p (0 to 3)
    threshold = 0x0C18;
    threshold_id = 2;
    obj.set_threshold_hi(threshold_p=threshold,threshold_id_p=threshold_id);

    ###############################################################
    # set the set_threshold_lo register
    ###############################################################
    # [11:0]: R/W: threshold_p[11:0]
    # threshold_id_p (0 to 3)
    threshold = 0x0AF1;
    threshold_id = 2;
    obj.set_threshold_lo(threshold_p=threshold,threshold_id_p=threshold_id);

    ###############################################################
    # set the set_threshold_hi register
    ###############################################################
    # [11:0]: R/W: threshold_p[11:0]
    # threshold_id_p (0 to 3)
    threshold = 0x0C18;
    threshold_id = 3;
    obj.set_threshold_hi(threshold_p=threshold,threshold_id_p=threshold_id);

    ###############################################################
    # set the set_threshold_lo register
    ###############################################################
    # [11:0]: R/W: threshold_p[11:0]
    # threshold_id_p (0 to 3)
    threshold = 0x0AF1;
    threshold_id = 3;
    obj.set_threshold_lo(threshold_p=threshold,threshold_id_p=threshold_id);


    ###############################################################
    # set the dac_load register
    ###############################################################
    # RW
    # obj.set_dac_load();

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
        str_reg = '{0:08x}'.format(reg).upper()
        fid.write(str_reg)
        fid.write(';')
        fid.write(cmt)
        if index_max != i:
            fid.write('\n')

    fid.close()
