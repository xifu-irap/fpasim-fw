set_clock_groups -name async_usb_clk_adc_ckl -asynchronous -group [get_clocks -include_generated_clocks okUH0] -group [get_clocks -include_generated_clocks i_adc_clk_p]

create_generated_clock -name gen_dac_clk_out -multiply_by 1 -source [get_pins **/inst_io_dac/inst_ODDR_clk/C] [get_ports o_dac_clk_p]
create_generated_clock -name gen_sync_clk_out -multiply_by 1 -source [get_pins **/inst_io_sync/inst_ODDR_clk/C] [get_ports o_ref_clk]

set_property IOB true [get_ports i_da*_p]
set_property IOB true [get_ports i_db*_p]
set_property IOB true [get_ports o_sync]
set_property IOB true [get_ports o_dac_frame_p]
set_property IOB true [get_ports o_dac*_p]


# Center-Aligned Double Data Rate Source Synchronous Inputs 
#
# For a center-aligned Source Synchronous interface, the clock
# transition is aligned with the center of the data valid window.
# The same clock edge is used for launching and capturing the
# data. The constraints below rely on the default timing
# analysis (setup = 1/2 cycle, hold = 0 cycle).
#
# input                  ____________________
# clock    _____________|                    |_____________
#                       |                    |                 
#                dv_bre | dv_are      dv_bfe | dv_afe
#               <------>|<------>    <------>|<------>
#          _    ________|________    ________|________    _
# data     _XXXX____Rise_Data____XXXX____Fall_Data____XXXX_
#

set input_clock         i_adc_clk_p;      # Name of input clock
set input_clock_period  4;    # Period of input clock (full-period) <=> 250 MHz
set dv_bre              0.900;             # Data valid before the rising clock edge
set dv_are              0.950;             # Data valid after the rising clock edge
set dv_bfe              0.900;             # Data valid before the falling clock edge
set dv_afe              0.9500;             # Data valid after the falling clock edge
set input_ports         {i_da*_p i_db*_p};     # List of input ports

# Input Delay Constraint
set_input_delay -clock $input_clock -max [expr $input_clock_period/2 - $dv_bfe] [get_ports $input_ports];
set_input_delay -clock $input_clock -min $dv_are                                [get_ports $input_ports];
set_input_delay -clock $input_clock -max [expr $input_clock_period/2 - $dv_bre] [get_ports $input_ports] -clock_fall -add_delay;
set_input_delay -clock $input_clock -min $dv_afe                                [get_ports $input_ports] -clock_fall -add_delay;



#  Falling Edge Source Synchronous Outputs 
#
#  Source synchronous output interfaces can be constrained either by the max data skew
#  relative to the generated clock or by the destination device setup/hold requirements.
#
#  Setup/Hold Case:
#  Setup and hold requirements for the destination device and board trace delays are known.
#  
# forwarded                 _________________                    _______ 
# clock                ____|                 |__________________|
#                                            |
#                                     tsu    |    thd
#                                <---------->|<--------->
#                                ____________|___________
# data @ destination    XXXXXXXXX________________________XXXXX
#
# Example of creating generated clock at clock output port
# create_generated_clock -name <gen_clock_name> -multiply_by 1 -source [get_pins <source_pin>] [get_ports <output_clock_port>]
# gen_clock_name is the name of forwarded clock here. It should be used below for defining "fwclk".	


set fwclk        gen_dac_clk_out;     # forwarded clock name (generated using create_generated_clock at output clock port)        
set tsu          0.250;            # destination device setup time requirement
set thd          0.375;            # destination device hold time requirement
set trce_dly_max 0.010;            # maximum board trace delay
set trce_dly_min 0.000;            # minimum board trace delay
set output_ports o_dac_frame_p;   # list of output ports

# Output Delay Constraints
set_output_delay -clock $fwclk -max [expr $trce_dly_max + $tsu] [get_ports $output_ports] -clock_fall;
set_output_delay -clock $fwclk -min [expr $trce_dly_min - $thd] [get_ports $output_ports] -clock_fall;


#  Double Data Rate Source Synchronous Outputs 
#
#  Source synchronous output interfaces can be constrained either by the max data skew
#  relative to the generated clock or by the destination device setup/hold requirements.
#
#  Setup/Hold Case:
#  Setup and hold requirements for the destination device and board trace delays are known.
#
# forwarded                        _________________________________
# clock                 __________|                                 |______________
#                                 |                                 |
#                           tsu_r |  thd_r                    tsu_f | thd_f
#                         <------>|<------->                <------>|<----->
#                         ________|_________                ________|_______
# data @ destination   XXX__________________XXXXXXXXXXXXXXXX________________XXXXX
#
# Example of creating generated clock at clock output port
# create_generated_clock -name <gen_clock_name> -multiply_by 1 -source [get_pins <source_pin>] [get_ports <output_clock_port>]
# gen_clock_name is the name of forwarded clock here. It should be used below for defining "fwclk".	

set fwclk        gen_dac_clk_out;     # forwarded clock name (generated using create_generated_clock at output clock port)        
set tsu_r        0.250;            # destination device setup time requirement for rising edge
set thd_r        0.375;            # destination device hold time requirement for rising edge
set tsu_f        0.250;            # destination device setup time requirement for falling edge
set thd_f        0.375;            # destination device hold time requirement for falling edge
set trce_dly_max 0.010;            # maximum board trace delay
set trce_dly_min 0.000;            # minimum board trace delay
set output_ports {o_dac*_p o_dac_clk_p};   # list of output ports

# Output Delay Constraints
set_output_delay -clock $fwclk -max [expr $trce_dly_max + $tsu_r] [get_ports $output_ports];
set_output_delay -clock $fwclk -min [expr $trce_dly_min - $thd_r] [get_ports $output_ports];
set_output_delay -clock $fwclk -max [expr $trce_dly_max + $tsu_f] [get_ports $output_ports] -clock_fall -add_delay;
set_output_delay -clock $fwclk -min [expr $trce_dly_min - $thd_f] [get_ports $output_ports] -clock_fall -add_delay;


#  Rising Edge Source Synchronous Outputs 
#
#  Source synchronous output interfaces can be constrained either by the max data skew
#  relative to the generated clock or by the destination device setup/hold requirements.
#
#  Setup/Hold Case:
#  Setup and hold requirements for the destination device and board trace delays are known.
#  
# forwarded         ____                      ___________________ 
# clock                 |____________________|                   |____________ 
#                                            |
#                                     tsu    |    thd
#                                <---------->|<--------->
#                                ____________|___________
# data @ destination    XXXXXXXXX________________________XXXXX
#
# Example of creating generated clock at clock output port
# create_generated_clock -name <gen_clock_name> -multiply_by 1 -source [get_pins <source_pin>] [get_ports <output_clock_port>]
# gen_clock_name is the name of forwarded clock here. It should be used below for defining "fwclk".	

set fwclk        gen_sync_clk_out;     # forwarded clock name (generated using create_generated_clock at output clock port)        
set tsu          0.250;            # destination device setup time requirement
set thd          0.375;            # destination device hold time requirement
set trce_dly_max 0.010;            # maximum board trace delay
set trce_dly_min 0.000;            # minimum board trace delay
set output_ports {o_sync o_ref_clk};   # list of output ports

# Output Delay Constraints
set_output_delay -clock $fwclk -max [expr $trce_dly_max + $tsu] [get_ports $output_ports];
set_output_delay -clock $fwclk -min [expr $trce_dly_min - $thd] [get_ports $output_ports];

