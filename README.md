# fpasim-fw
Focal Plan Assembly simulator firmware

## definition
  we'll call @project_root the path to the project.  

## Vivado
To compile Xilinx IP into the **fpasim** library.
Project Manager -> Settings -> General -> Default Library : fpasim

## Directories and files description
In the following section,the path to the project root directory will be defined as @project_root (**example**:C:/fpasim-fw )

Directories inside the @project_root directory:
- **(dir.) .git**: internal git files (don't edit)
- **(dir.) constraints**: Synthesis tool constraints
- **(dir.) ip**: Synthesize source files linked to the FPGA technology
- **(dir.) simu**: Simulation files
    - **(dir.) conf**: Unitary test configuration files
    - **(dir.) script**: Unitary test python scripts files called by the associated run python script files for the testbench data and command generation
    - **(dir.) tb**: Test bench and model component files for simulation
    - **(dir.) vunit**: Unitary test run python scripts files
    - **(dir.) wave**: Unitary test modelsim waveform files
    - **(dir.) lib**: Library files for the simulation
- **(dir.) src**: vhdl Synthesize source files independent to FPGA technology
- **(dir.) project**: project files linked to the FPGA technology
  - **(dir.) vivado00**: vivado project files

## Python installation
TODO

## [Vunit installation](https://vunit.github.io/installing.html)
To install the Vunit library (**see the VUnit Developers section**), we need to follow the following step:
> git clone https://github.com/VUnit/vunit.git
> cd vunit
> pip install -e .







