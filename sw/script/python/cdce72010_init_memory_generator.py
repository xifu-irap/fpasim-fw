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
#!   @file                   cdce72010_init_memory_generator.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference
# -------------------------------------------------------------------------------------------------------------
#!   @details
#
#   This scrips generates data in order to initialize the cdce72010 registers.
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

    def set_config0(self,
                    outbufsel0yx_p,cmosmode0nyx_p,
                    cmosmode0pyx_p,pecl0hiswing_p,irefres_p,
                    icp_p,cp_pre_p, cp_opa_p,
                    cp_snk_p,cp_src_p,cp_dir_p,
                    delay_pfd_p,refselcntrl_p,vcxosel_p,
                    secsel_p,prisel_p,inbufselyx_p
             
                    ):

        cmt = 'config0'
        reserved = 0
        value5 = (outbufsel0yx_p << 26 ) + (cmosmode0nyx_p << 24) 
        value4 = (cmosmode0pyx_p << 22) + (pecl0hiswing_p << 21) + (irefres_p<<20)
        value3 = (icp_p << 14) + (cp_pre_p << 13) + (cp_opa_p << 12)
        value2 = (cp_snk_p << 11) + (cp_src_p << 10) + (cp_dir_p << 9) 
        value1 = (delay_pfd_p << 6) + (refselcntrl_p << 5) + (vcxosel_p << 4)
        value0 = (secsel_p << 3) + (prisel_p << 2) + (inbufselyx_p << 0)

        value =  value5 + value4 + value3 + value2 + value1 + value0

        self.add_register(addr_p=0x00,data_p=value,cmt_p=cmt)

    def set_config1(self,
                    outbufsel1yx_p,cmosmode1nyx_p,
                    cmosmode1pyx_p,pecl1hiswing_p,en01div_p, 
                    out1divrsel_p, ph1adjc_p,
                    failsafe_p,secinvbb_p,
                    priinvbb_p,termsel_p,hysten_p,acdcsel_p
                    ):

        cmt = 'config1'
        reserved = 0
        value4 = (outbufsel1yx_p << 26 ) + (cmosmode1nyx_p << 24)
        value3 = (cmosmode1pyx_p << 22) + (pecl1hiswing_p << 21) + (en01div_p << 20) 
        value2 = (out1divrsel_p << 13) + (ph1adjc_p << 6)
        value1 = (failsafe_p << 5) + (secinvbb_p << 4)
        value0 = (priinvbb_p << 3) + (termsel_p << 2) + (hysten_p << 1) + (acdcsel_p << 0)

        value = value4 + value3 + value2 + value1 + value0

        self.add_register(addr_p=0x01,data_p=value,cmt_p=cmt)


    def set_config2(self,
                    outbufsel2yx_p,cmosmode2nyx_p,
                    cmosmode2pyx_p,pecl2hiswing_p,en2div_p, 
                    out2divrsel_p, ph2adjc_p,
                    dlyn_p,dlym_p
                    ):

        cmt = 'config2'
        reserved = 0
        value3 = (outbufsel2yx_p << 26 ) + (cmosmode2nyx_p << 24)
        value2 = (cmosmode2pyx_p << 22) + (pecl2hiswing_p << 21) + (en2div_p << 20) 
        value1 = (out2divrsel_p << 13) + (ph2adjc_p << 6)
        value0 = (dlyn_p << 3) + (dlym_p << 0)

        value = value3 + value2 + value1 + value0

        self.add_register(addr_p=0x02,data_p=value,cmt_p=cmt)


    def set_config3(self,
                    outbufsel3yx_p,cmosmode3nyx_p,
                    cmosmode3pyx_p,pecl3hiswing_p,en3div_p, 
                    out3divrsel_p, ph3adjc_p,
                    bias_div23_p,
                    bias_div01_p, dis_fdet_fb_p,dis_fdet_ref_p
                    ):

        cmt = 'config3'
        reserved = 0
        value4 = (outbufsel3yx_p << 26 ) + (cmosmode3nyx_p << 24)
        value3 = (cmosmode3pyx_p << 22) + (pecl3hiswing_p << 21) + (en3div_p << 20) 
        value2 = (out3divrsel_p << 13) + (ph3adjc_p << 6)
        value1 = (bias_div23_p << 4) 
        value0 = (bias_div01_p << 2) + (dis_fdet_fb_p << 1) + (dis_fdet_ref_p << 0)

        value = value4 + value3 + value2 + value1 + value0

        self.add_register(addr_p=0x03,data_p=value,cmt_p=cmt)


    def set_config4(self,
                    outbufsel4yx_p,cmosmode4nyx_p,
                    cmosmode4pyx_p,pecl4hiswing_p,en4div_p, 
                    out4divrsel_p, ph4adjc_p,
                    holdonlor_p
                    ):

        cmt = 'config4'
        reserved = 0
        value3 = (outbufsel4yx_p << 26 ) + (cmosmode4nyx_p << 24)
        value2 = (cmosmode4pyx_p << 22) + (pecl4hiswing_p << 21) + (en4div_p << 20) 
        value1 = (out4divrsel_p << 13) + (ph4adjc_p << 6)
        value0 = (holdonlor_p << 4) 

        value =  value3 + value2 + value1 + value0

        self.add_register(addr_p=0x04,data_p=value,cmt_p=cmt)


    def set_config5(self,
                    outbufsel5yx_p,cmosmode5nyx_p,
                    cmosmode5pyx_p,pecl5hiswing_p,en5div_p, 
                    out5divrsel_p, ph5adjc_p,
                    bias_div67_p,bias_div45_p
                    ):

        cmt = 'config5'
        reserved = 0
        value3 = (outbufsel5yx_p << 26 ) + (cmosmode5nyx_p << 24)
        value2 = (cmosmode5pyx_p << 22) + (pecl5hiswing_p << 21) + (en5div_p << 20) 
        value1 = (out5divrsel_p << 13) + (ph5adjc_p << 6)
        value0 = (bias_div67_p << 2) + (bias_div45_p << 0) 

        value =  value3 + value2 + value1 + value0

        self.add_register(addr_p=0x05,data_p=value,cmt_p=cmt)


    def set_config6(self,
                    outbufsel6yx_p,cmosmode6nyx_p,
                    cmosmode6pyx_p,pecl6hiswing_p,en6div_p, 
                    out6divrsel_p, ph6adjc_p,
                    det_start_bypass_p,fb_start_bypass_p,
                    fbdeterm_div2_dis_p,fbdeterm_div_sel_p,fb_fd_desel_p
                    ):

        cmt = 'config6'
        reserved = 0
        value4 = (outbufsel6yx_p << 26 ) + (cmosmode6nyx_p << 24)
        value3 = (cmosmode6pyx_p << 22) + (pecl6hiswing_p << 21) + (en6div_p << 20) 
        value2 = (out6divrsel_p << 13) + (ph6adjc_p << 6)
        value1 = (det_start_bypass_p << 5) + (fb_start_bypass_p << 4) 
        value0 = (fbdeterm_div2_dis_p << 3) + (fbdeterm_div_sel_p << 2) + (fb_fd_desel_p << 0 )

        value = value4 + value3 + value2 + value1 + value0

        self.add_register(addr_p=0x06,data_p=value,cmt_p=cmt)

    def set_config7(self,
                    outbufsel7yx_p,cmosmode7nyx_p,
                    cmosmode7pyx_p,pecl7hiswing_p,en7div_p, 
                    out7divrsel_p, ph7adjc_p,
                    adlock_p,lockc_p, lockw_p
                    ):

        cmt = 'config7'
        reserved = 0
        value3 = (outbufsel7yx_p << 26 ) + (cmosmode7nyx_p << 24)
        value2 = (cmosmode7pyx_p << 22) + (pecl7hiswing_p << 21) + (en7div_p << 20) 
        value1 = (out7divrsel_p << 13) + (ph7adjc_p << 6)
        value0 = (adlock_p << 5) + (lockc_p << 3) + lockw_p

        value = value3 + value2 + value1 + value0

        self.add_register(addr_p=0x07,data_p=value,cmt_p=cmt)

    def set_config8(self,
                    outbufsel8yx_p,cmosmode8nyx_p,
                    cmosmode8pyx_p,pecl8hiswing_p,en89div_p, 
                    out8divrsel_p, ph8adjc_p,
                    vcxoinvbb_p,vcxotermsel_p,
                    vcxohysten_p,vcxoacdcsel_p,vcxobufselyx_p
                    ):

        cmt = 'config8'
        reserved = 0
        value4 = (outbufsel8yx_p << 26 ) + (cmosmode8nyx_p << 24)
        value3 = (cmosmode8pyx_p << 22) + (pecl8hiswing_p << 21) + (en89div_p << 20) 
        value2 = (out8divrsel_p << 13) + (ph8adjc_p << 6)
        value1 = (vcxoinvbb_p << 5) + (vcxotermsel_p << 4)
        value0 = (vcxohysten_p << 3) + (vcxoacdcsel_p << 2) + (vcxobufselyx_p << 0)

        value = value4 + value3 + value2 + value1 + value0

        self.add_register(addr_p=0x08,data_p=value,cmt_p=cmt)

    def set_config9(self,
                    outbufsel9yx_p,cmosmode9nyx_p,
                    cmosmode9pyx_p,pecl9hiswing_p,dis_aux_y9_p, 
                    auxinvbb_p, bias_div89_p,bias_div_fb_p,
                    npreset_mdiv_p,low_fd_fb_en_p,pll_lock_bp_p,
                    indet_bp_p,start_bypass_p,divsync_dis_p,noinv_reshol_int_p,
                    lockw32_p,hold_cnt_p,
                    holdtr_p,hold_n_p,holdf_p
                    ):

        cmt = 'config9'
        reserved = 0
        value6 = (outbufsel9yx_p << 26 ) + (cmosmode9nyx_p << 24)
        value5 = (cmosmode9pyx_p << 22) + (pecl9hiswing_p << 21) + (dis_aux_y9_p << 20) 
        value4 = (auxinvbb_p << 19) + (bias_div89_p << 17) + (bias_div_fb_p << 15)
        value3 = (npreset_mdiv_p << 14) + (low_fd_fb_en_p << 13) + (pll_lock_bp_p << 12)
        value2 = (indet_bp_p << 11) + (start_bypass_p << 10) + (divsync_dis_p << 9) + (noinv_reshol_int_p<<8)
        value1 = (lockw32_p << 6) + (hold_cnt_p << 4) 
        value0 = (holdtr_p << 3) + (hold_n_p << 2) + holdf_p
        value = value6 + value5 + value4 + value3 + value2 + value1 + value0

        self.add_register(addr_p=0x09,data_p=value,cmt_p=cmt)


    def set_config10(self,
                    div_n_p,div_m_p
                     ):

        cmt = 'config10'
        reserved = 0
        value1 = (div_n_p << 14)
        value0 = (div_m_p << 0)
        value = value1 + value0

        self.add_register(addr_p=0x0A,data_p=value,cmt_p=cmt)


    def set_config11(self,
                    eplock_p,reset_hold_mode_p,sel_del1_p,
                    nreshape1_p, fb_sel_p, out_mux_sel_p, fb_mux_sel_p,
                    pd_pll_p,fb_phase_p,fb_count32_p,fb_inclk_inv_p,
                    fb_cml_sel_p,fb_dis_p,sec_div2_p,pri_div2_p
                     ):

        cmt = 'config11'
        reserved = 0
        value3 = (eplock_p << 26) + (reset_hold_mode_p << 25) + (sel_del1_p << 24)
        value2 = (nreshape1_p << 23) + (fb_sel_p << 22) + (out_mux_sel_p << 21) + (fb_mux_sel_p << 20)
        value1 = (pd_pll_p << 19) + (fb_phase_p << 12) + (fb_count32_p << 5) + (fb_inclk_inv_p << 4)
        value0 = (fb_cml_sel_p << 3) + (fb_dis_p << 2) + (sec_div2_p << 1) + (pri_div2_p << 0)
        value = value3 + value2 + value1 + value0

        self.add_register(addr_p=0x0B,data_p=value,cmt_p=cmt)


    def set_config12(self,
                    secactivity_p,priactivity_p,titstcfg_p,
                    status_p,
                    shold_p,sxoiref_p,pd_io_p,
                    revision_p,gtme_p, reset_hold_n_p,
                    sleep_n_p,pll_lock_p,indet_vcxo_p,indet_aux_p
                     ):

        cmt = 'config12'
        reserved = 0
        value4 = (secactivity_p << 26) + (priactivity_p << 25) + (titstcfg_p << 21)
        value3 = (status_p << 17) 
        value2 = (shold_p << 15) + (sxoiref_p << 14) + (pd_io_p << 13) 
        value1 = (revision_p << 10) + (gtme_p << 9) + (reset_hold_n_p << 8)
        value0 = (sleep_n_p << 7) + (pll_lock_p << 6) + (indet_vcxo_p << 5) + (indet_aux_p << 4)
        value = value4 + value3 + value2 + value1 + value0

        self.add_register(addr_p=0x0C,data_p=value,cmt_p=cmt)


    

    

    
   


    def get_cmt_list(self):
        return self.cmt_list

    def get_reg_list(self):

        res = []

        L = len(self.addr_list)
        for i in range(L):
            # build the byte0 (string)
            byte0 = self.addr_list[i]
            byte1 = self.data_list[i]

            value = (byte1 << 4) + byte0
            res.append(value)

        return res



if __name__ == "__main__":
    # define the base address where to find the *.csv input files
    base_address = './'
    output_filename = 'cdce72010_init_mem.txt'
    output_filepath = str(Path(base_address,output_filename))
    
    obj = Ram()
    ################################################################
    # config0
    ################################################################
    # [27:26]: R/W: outbufsel0yx[1:0]
    # [25:24]: R/W: cmosmode0nyx[1:0]
    # [23:22]: R/W: cmosmode0pyx[1:0]
    # [21]: R/W: pecl0hiswing[0]
    # [20]: R/W: irefres[0]
    # [17:14]: R/W: icp[3:0]
    # [13]: R/W: cp_pre[0]
    # [12]: R/W: cp_opa[0]
    # [11]: R/W: cp_snk[0]
    # [10]: R/W: cp_src[0]
    # [9]: R/W: cp_dir[0]
    # [7:6]: R/W: delay_pfd[1:0]
    # [5]: R/W: refselcntrl[0]
    # [4]: R/W: vcxosel[0]
    # [3]: R/W: secsel[0]
    # [2]: R/W: prisel[0]
    # [1:0]: R/W: inbufselyx[1:0]

    outbufsel0yx = int('01',2)
    cmosmode0nyx = int('10',2)
    cmosmode0pyx = int('10',2)
    pecl0hiswing = int('00',2)
    irefres = 0
    icp = int('1111',2)
    cp_pre = 0
    cp_opa = 0
    cp_snk = 0
    cp_src = 0
    cp_dir = 0
    delay_pfd = int('00',2)
    refselcntrl = 1
    vcxosel = 1
    secsel = 0
    prisel = 1
    inbufselyx = int('01',2)

    obj.set_config0(
                    outbufsel0yx_p=outbufsel0yx,cmosmode0nyx_p = cmosmode0nyx,
                    cmosmode0pyx_p = cmosmode0pyx,pecl0hiswing_p = pecl0hiswing,irefres_p=irefres,
                    icp_p=icp,cp_pre_p=cp_pre, cp_opa_p=cp_opa,
                    cp_snk_p=cp_snk,cp_src_p=cp_src,cp_dir_p=cp_dir,
                    delay_pfd_p=delay_pfd,refselcntrl_p=refselcntrl,vcxosel_p=vcxosel,
                    secsel_p=secsel,prisel_p=prisel,inbufselyx_p=inbufselyx
              )

    ################################################################
    # config1
    ################################################################
    # [27:26]: R/W: outbufsel1yx[1:0]
    # [25:24]: R/W: cmosmode1nyx[1:0]
    # [23:22]: R/W: cmosmode1pyx[1:0]
    # [21]: R/W: pecl1hiswing[0]
    # [20]: R/W: en01div[0]
    # [19:13]: R/W: out1divrsel[6:0]
    # [12:6]: R/W: ph1adjc[6:0]
    # [5]: R/W: failsafe[0]
    # [4]: R/W: secinvbb[0]
    # [3]: R/W: priinvbb[0]
    # [2]: R/W: termsel[0]
    # [1]: R/W: hysten[0]
    # [0]: R/W: acdcsel[0]

    outbufsel1yx = int('01',2)
    cmosmode1nyx = int('10',2)
    cmosmode1pyx = int('10',2)
    pecl1hiswing = 0
    en01div = 0
    out1divrsel = int('000_0000',2)
    ph1adjc = int('000_0000',2)
    failsafe = 0
    secinvbb = 0
    priinvbb = 0
    termsel = 0
    hysten = 1
    acdcsel = 0

    obj.set_config1(
                    outbufsel1yx_p=outbufsel1yx,cmosmode1nyx_p=cmosmode1nyx,
                    cmosmode1pyx_p=cmosmode1pyx,pecl1hiswing_p=pecl1hiswing,en01div_p=en01div, 
                    out1divrsel_p=out1divrsel, ph1adjc_p=ph1adjc,
                    failsafe_p=failsafe,secinvbb_p=secinvbb,
                    priinvbb_p=priinvbb,termsel_p=termsel,hysten_p=hysten,acdcsel_p=acdcsel
                    )

    ################################################################
    # config2
    ################################################################
    # [27:26]: R/W: outbufsel2yx[1:0]
    # [25:24]: R/W: cmosmode2nyx[1:0]
    # [23:22]: R/W: cmosmode2pyx[1:0]
    # [21]: R/W: pecl2hiswing[0]
    # [20]: R/W: en2div[0]
    # [19:13]: R/W: out2divrsel[6:0]
    # [12:6]: R/W: ph2adjc[6:0]
    # [5:3]: R/W: dlyn[2:0]
    # [2:0]: R/W: dlym[2:0]
    outbufsel2yx = int('10',2)
    cmosmode2nyx = int('00',2)
    cmosmode2pyx = int('00',2)
    pecl2hiswing = 1
    en2div = 1
    out2divrsel = int('100_0000',2)
    ph2adjc = int('000_0000',2)
    dlyn = int('00',2)
    dlym = int('00',2)

    obj.set_config2(
                    outbufsel2yx_p=outbufsel2yx,cmosmode2nyx_p=cmosmode2nyx,
                    cmosmode2pyx_p=cmosmode2pyx,pecl2hiswing_p=pecl2hiswing,en2div_p=en2div, 
                    out2divrsel_p=out2divrsel, ph2adjc_p=ph2adjc,
                    dlyn_p=dlyn,dlym_p=dlym
                    )

    ################################################################
    # config3
    ################################################################
    # [27:26]: R/W: outbufsel3yx[1:0]
    # [25:24]: R/W: cmosmode3nyx[1:0]
    # [23:22]: R/W: cmosmode3pyx[1:0]
    # [21]: R/W: pecl3hiswing[0]
    # [20]: R/W: en3div[0]
    # [19:13]: R/W: out3divrsel[6:0]
    # [12:6]: R/W: ph3adjc[6:0]
    # [5:4]: R/W: bias_div23[1:0]
    # [3:2]: R/W: bias_div01[1:0]
    # [1]: R/W: dis_fdet_fb[0]
    # [0]: R/W: dis_fdet_ref[0]

    outbufsel3yx = int('01',2)
    cmosmode3nyx = int('10',2)
    cmosmode3pyx = int('10',2)
    pecl3hiswing = 0
    en3div = 0
    out3divrsel = int('000_0000',2)
    ph3adjc = int('000_0000',2)
    bias_div23 = int('00',2)
    bias_div01 = int('00',2)
    dis_fdet_fb = 0
    dis_fdet_ref = 0

    obj.set_config3(
                    outbufsel3yx_p=outbufsel3yx,cmosmode3nyx_p=cmosmode3nyx,
                    cmosmode3pyx_p=cmosmode3pyx,pecl3hiswing_p=pecl3hiswing,en3div_p=en3div, 
                    out3divrsel_p=out3divrsel, ph3adjc_p=ph3adjc,
                    bias_div23_p=bias_div23,
                    bias_div01_p=bias_div01, dis_fdet_fb_p=dis_fdet_fb,dis_fdet_ref_p=dis_fdet_ref
                    )

    ################################################################
    # config4
    ################################################################
    # [27:26]: R/W: outbufsel4yx[1:0]
    # [25:24]: R/W: cmosmode4nyx[1:0]
    # [23:22]: R/W: cmosmode4pyx[1:0]
    # [21]: R/W: pecl4hiswing[0]
    # [20]: R/W: en4div[0]
    # [19:13]: R/W: out4divrsel[6:0]
    # [12:6]: R/W: ph4adjc[6:0]
    # [4]: R/W: holdonlor[0]

    outbufsel4yx = int('11',2)
    cmosmode4nyx = int('10',2)
    cmosmode4pyx = int('10',2)
    pecl4hiswing = 0
    en4div = 1
    out4divrsel = int('100_0000',2)
    ph4adjc = int('000_0000',2)
    holdonlor = 0

    obj.set_config4(
                    outbufsel4yx_p=outbufsel4yx,cmosmode4nyx_p=cmosmode4nyx,
                    cmosmode4pyx_p=cmosmode4pyx,pecl4hiswing_p=pecl4hiswing,en4div_p=en4div, 
                    out4divrsel_p=out4divrsel, ph4adjc_p=ph4adjc,
                    holdonlor_p=holdonlor
                    )

    ################################################################
    # config5
    ################################################################
    # [27:26]: R/W: outbufsel5yx[1:0]
    # [25:24]: R/W: cmosmode5nyx[1:0]
    # [23:22]: R/W: cmosmode5pyx[1:0]
    # [21]: R/W: pecl5hiswing[0]
    # [20]: R/W: en5div[0]
    # [19:13]: R/W: out5divrsel[6:0]
    # [12:6]: R/W: ph5adjc[6:0]
    # [3:2]: R/W: bias_div67[1:0]
    # [1:0]: R/W: bias_div45[1:0]
    outbufsel5yx = int('01',2)
    cmosmode5nyx = int('10',2)
    cmosmode5pyx = int('10',2)
    pecl5hiswing = 0
    en5div = 0
    out5divrsel = int('000_0000',2)
    ph5adjc = int('000_0000',2)
    bias_div67 = int('00',2)
    bias_div45 = int('00',2)


    obj.set_config5(
                    outbufsel5yx_p=outbufsel5yx,cmosmode5nyx_p=cmosmode5nyx,
                    cmosmode5pyx_p=cmosmode5pyx,pecl5hiswing_p=pecl5hiswing,en5div_p=en5div, 
                    out5divrsel_p=out5divrsel, ph5adjc_p=ph5adjc,
                    bias_div67_p=bias_div67,bias_div45_p=bias_div45
                    )

    ################################################################
    # config6
    ################################################################
    # [27:26]: R/W: outbufsel6yx[1:0]
    # [25:24]: R/W: cmosmode6nyx[1:0]
    # [23:22]: R/W: cmosmode6pyx[1:0]
    # [21]: R/W: pecl6hiswing[0]
    # [20]: R/W: en6div[0]
    # [19:13]: R/W: out6divrsel[6:0]
    # [12:6]: R/W: ph6adjc[6:0]
    # [5]: R/W: det_start_bypass[0]
    # [4]: R/W: fb_start_bypass[0]
    # [3]: R/W: fbdeterm_div2_dis[0]
    # [2]: R/W: fbdeterm_div_sel[0]
    # [0]: R/W: fb_fd_desel[0]
    outbufsel6yx = int('01',2)
    cmosmode6nyx = int('10',2)
    cmosmode6pyx = int('10',2)
    pecl6hiswing = 0
    en6div = 0
    out6divrsel = int('000_0000',2)
    ph6adjc = int('000_0000',2)
    det_start_bypass = 0
    fb_start_bypass = 0
    fbdeterm_div2_dis = 0
    fbdeterm_div_sel = 0
    fb_fd_desel = 0

    obj.set_config6(
                    outbufsel6yx_p=outbufsel6yx,cmosmode6nyx_p=cmosmode6nyx,
                    cmosmode6pyx_p=cmosmode6pyx,pecl6hiswing_p=pecl6hiswing,en6div_p=en6div, 
                    out6divrsel_p=out6divrsel, ph6adjc_p=ph6adjc,
                    det_start_bypass_p=det_start_bypass,fb_start_bypass_p=fb_start_bypass,
                    fbdeterm_div2_dis_p=fbdeterm_div2_dis,fbdeterm_div_sel_p=fbdeterm_div_sel,fb_fd_desel_p=fb_fd_desel
                    )

    ################################################################
    # config7
    ################################################################
    # [27:26]: R/W: outbufsel7yx[1:0]
    # [25:24]: R/W: cmosmode7nyx[1:0]
    # [23:22]: R/W: cmosmode7pyx[1:0]
    # [21]: R/W: pecl7hiswing[0]
    # [20]: R/W: en7div[0]
    # [19:13]: R/W: out7divrsel[6:0]
    # [12:6]: R/W: ph7adjc[6:0]
    # [5]: R/W: adlock[0]
    # [4:3]: R/W: lockc[1:0]
    # [1:0]: R/W: lockw[1:0]
    outbufsel7yx = int('10',2)
    cmosmode7nyx = int('00',2)
    cmosmode7pyx = int('00',2)
    pecl7hiswing = 1
    en7div = 1
    out7divrsel = int('100_0000',2)
    ph7adjc = int('000_0000',2)
    adlock = 0
    lockc = int('00',2)
    lockw = int('01',2)

    obj.set_config7(
                    outbufsel7yx_p=outbufsel7yx,cmosmode7nyx_p=cmosmode7nyx,
                    cmosmode7pyx_p=cmosmode7pyx,pecl7hiswing_p=pecl7hiswing,en7div_p=en7div, 
                    out7divrsel_p=out7divrsel, ph7adjc_p=ph7adjc,
                    adlock_p=adlock,lockc_p=lockc, lockw_p=lockw
                    )

    ################################################################
    # config8
    ################################################################
    # [27:26]: R/W: outbufsel8yx[1:0]
    # [25:24]: R/W: cmosmode8nyx[1:0]
    # [23:22]: R/W: cmosmode8pyx[1:0]
    # [21]: R/W: pecl8hiswing[0]
    # [20]: R/W: en8div[0]
    # [19:13]: R/W: out8divrsel[6:0]
    # [12:6]: R/W: ph8adjc[6:0]
    # [5]: R/W: vcxoinvbb[0]
    # [4]: R/W: vcxotermsel[0]
    # [3]: R/W: vcxohysten[0]
    # [2]: R/W: vcxoacdcsel[0]
    # [1:0]: R/W: vcxobufselyx[1:0]
    outbufsel8yx = int('01',2)
    cmosmode8nyx = int('10',2)
    cmosmode8pyx = int('10',2)
    pecl8hiswing = 0
    en89div = 0
    out8divrsel = int('000_0000',2)
    ph8adjc = int('000_0000',2)
    vcxoinvbb = 0
    vcxotermsel = 0
    vcxohysten = 1
    vcxoacdcsel = 0
    vcxobufselyx = int('01',2)

    obj.set_config8(
                    outbufsel8yx_p=outbufsel8yx,cmosmode8nyx_p=cmosmode8nyx,
                    cmosmode8pyx_p=cmosmode8pyx,pecl8hiswing_p=pecl8hiswing,en89div_p=en89div, 
                    out8divrsel_p=out8divrsel, ph8adjc_p=ph8adjc,
                    vcxoinvbb_p=vcxoinvbb,vcxotermsel_p=vcxotermsel,
                    vcxohysten_p=vcxohysten,vcxoacdcsel_p=vcxoacdcsel,vcxobufselyx_p=vcxobufselyx
                    )

    ################################################################
    # config9
    ################################################################
    # [27:26]: R/W: outbufsel9yx[1:0]
    # [25:24]: R/W: cmosmode9nyx[1:0]
    # [23:22]: R/W: cmosmode9pyx[1:0]
    # [21]: R/W: pecl9hiswing[0]
    # [20]: R/W: dis_aux_y9[0]
    # [19]: R/W: auxinvbb[0]
    # [18:17]: R/W: bias_div89[1:0]
    # [16:15]: R/W: bias_div_fb[1:0]
    # [14]: R/W: npreset_mdiv[0]
    # [13]: R/W: low_fd_fb_en[0]
    # [12]: R/W: pll_lock_bp[0]
    # [11]: R/W: indet_bp[0]
    # [10]: R/W: start_bypass[0]
    # [9]: R/W: divsync_dis[0]
    # [8]: R/W: noinv_reshol_int[0]
    # [7:6]: R/W: lockw32[1:0]
    # [5:4]: R/W: hold_cnt[1:0]
    # [3]: R/W: holdtr[0]
    # [2]: R/W: hold_n[0]
    # [0]: R/W: holdf[0]
    outbufsel9yx = int('01',2)
    cmosmode9nyx = int('10',2)
    cmosmode9pyx = int('10',2)
    pecl9hiswing = 0
    dis_aux_y9 = 0
    auxinvbb = 0
    bias_div89 = int('00',2)
    bias_div_fb = int('00',2)
    npreset_mdiv = 1
    low_fd_fb_en = 0
    pll_lock_bp = 1
    indet_bp = 0
    start_bypass = 0
    divsync_dis = 0
    noinv_reshol_int = 0
    lockw32 = int('11',2)
    hold_cnt = int('00',2)
    holdtr = 1
    hold_n = 1
    holdf = 0

    obj.set_config9(
                    outbufsel9yx_p=outbufsel9yx,cmosmode9nyx_p=cmosmode9nyx,
                    cmosmode9pyx_p=cmosmode9pyx,pecl9hiswing_p=pecl9hiswing,dis_aux_y9_p=dis_aux_y9, 
                    auxinvbb_p=auxinvbb, bias_div89_p=bias_div89,bias_div_fb_p=bias_div_fb,
                    npreset_mdiv_p=npreset_mdiv,low_fd_fb_en_p=low_fd_fb_en,pll_lock_bp_p=pll_lock_bp,
                    indet_bp_p=indet_bp,start_bypass_p=start_bypass,divsync_dis_p=divsync_dis,noinv_reshol_int_p=noinv_reshol_int,
                    lockw32_p=lockw32,hold_cnt_p=hold_cnt,
                    holdtr_p=holdtr,hold_n_p=hold_n,holdf_p=holdf
                    )

    ################################################################
    # config10
    ################################################################
    # [27:14]: R/W: div_m[13:0]
    # [13:0]: R/W: div_n[13:0]
    div_n = int('00_0001_0111_1111',2)
    div_m = int('00_0010_0111_0000',2)
    obj.set_config10(
                    div_n_p= div_n,div_m_p = div_m
                     )


    ################################################################
    # config11
    ################################################################
    # [26]: R/W: eplock[0]
    # [25]: R/W: reset_hold_mode[0]
    # [24]: R/W: sel_del1[0]
    # [23]: R/W: nreshape1[0]
    # [22]: R/W: fb_sel[0]
    # [21]: R/W: out_mux_sel[0]
    # [20]: R/W: fb_mux_sel[0]
    # [19]: R/W: pd_pll[0]
    # [18:12]: R/W: fb_phase[6:0]
    # [11:5]: R/W: fb_count32[6:0]
    # [4]: R/W: fb_inclk_inv[0]
    # [3]: R/W: fb_cml_sel[0]
    # [2]: R/W: fb_dis[0]
    # [1]: R/W: sec_div2[0]
    # [0]: R/W: pri_div2[0]
    eplock = 0
    reset_hold_mode = 0
    sel_del1 = 0
    nreshape1 = 0
    fb_sel = 0
    out_mux_sel = 0
    fb_mux_sel = 0
    pd_pll = 0
    fb_phase = int('000_0000',2)
    fb_count32 = int('000_0010',2)
    fb_inclk_inv= 0
    fb_cml_sel= 0
    fb_dis= 0
    sec_div2= 0
    pri_div2= 0

    obj.set_config11(
                    eplock_p=eplock,reset_hold_mode_p=reset_hold_mode,sel_del1_p=sel_del1,
                    nreshape1_p=nreshape1, fb_sel_p=fb_sel, out_mux_sel_p=out_mux_sel, fb_mux_sel_p=fb_mux_sel,
                    pd_pll_p=pd_pll,fb_phase_p=fb_phase,fb_count32_p=fb_count32,fb_inclk_inv_p=fb_inclk_inv,
                    fb_cml_sel_p=fb_cml_sel,fb_dis_p=fb_dis,sec_div2_p=sec_div2,pri_div2_p=pri_div2
                     )
    
    ################################################################
    # config12
    ################################################################
    # [26]: R/W: secactivity[0]
    # [25]: R/W: priactivity[0]
    # [24:21]: R/W: titstcfg[3:0]
    # [20:17]: R/W: status[3:0]
    # [15]: R/W: shold[0]
    # [14]: R/W: sxoiref[0]
    # [13]: R/W: pd_io[0]
    # [12:10]: R/W: revision[2:0]
    # [9]: R/W: gtme[0]
    # [8]: R/W: reset_hold_n[0]
    # [7]: R/W: sleep[0]
    # [6]: R: pll_lock[0]
    # [5]: R: indet_vcxo[0]
    # [4]: R: indet_aux[0]
    secactivity= 0
    priactivity = 0
    titstcfg = int('0000',2)
    status = int('0000',2)
    shold = 0
    sxoiref = 0
    pd_io = 0
    revision = int('000',2)
    gtme = 0
    reset_hold_n = 1
    sleep_n = 1
    pll_lock = 0
    indet_vcxo = 0
    indet_aux = 0

    obj.set_config12(
                    secactivity_p = secactivity,priactivity_p=priactivity,titstcfg_p=titstcfg,
                    status_p=status,
                    shold_p=shold,sxoiref_p=sxoiref,pd_io_p=pd_io,
                    revision_p=revision,gtme_p=gtme, reset_hold_n_p=reset_hold_n,
                    sleep_n_p=sleep_n,pll_lock_p=pll_lock,indet_vcxo_p=indet_vcxo,indet_aux_p=indet_aux
                     )
    

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
