Petalinux docker environment
============================

- Florian Dupeyron <florian.dupeyron@mugcat.fr>
- April 2024, based on work from march 2021

This repo contains the necessary tools to build a simple petalinux docker image.

Dependencies
------------

This repo is based on:

- [Docker](https://www.docker.com/): Container generation and running
- [Just]( https://github.com/casey/just): Shortcuts for commands


Building the docker image
-------------------------

1. First, download the relevant petalinux installer (for instance: `petalinux-v2023.2-10121855-installer.run`), and place it in the `docker` folder.
2. Generate the image, either:
   1. Using `just`: `just image-build`
   2. **Or** using docker command directly: `docker buildx build -t petalinux:2023.2 --load docker`


Using this image to generate a sample project
---------------------------------------------

Here are sample instructions to generate a project for the ZCU102 board:

1. Download and place the corresponding BSP file (for instance `xilinx-zcu102-v2023.2-10140544.bsp`) in the `bsp` folder
2. Start a petalinux shell (using one the following commands):
    1. Using just: `just shell`
    2. **Or** using docker command directly: ` docker run --rm -it -v ./project:/project -v ./bsp:/bsp petalinux:2023.2 bash`

3. In the opened shell, create the project: `petalinux-create -t project -s /bsp/xilinx-zcu102-v2023.2-10140544.bsp`
4. Build the project: `petalinux-build`
5. Generate the output images: `petalinux-package --boot --fpga images/linux/system.bit --fsbl images/zynqmp_fsbl.elf --u-boot`

Packaging options are:

- `--boot`: We are creating a boot image
- `--fpga`: The bitstream we want to download on the PL
- `--fsbl`: First Stage BootLoader, before running u-boot
- `--u-boot`: Integrate u-boot to our image.

👉 Output images should be generated in the corresponding `images/linux` folder.

After that, copy to the root of a FAT32 formatted partition on the SD card:

- `images/linux/BOOT.BIN`: The boot image we generated, containing the first stage bootloader, u-boot, and the FPGA bitstream
- `images/linux/image.ub`: The compressed linux image
- `images/linux/boot.scr`: The booting script for u-boot


After booting the board with correct boot settings (refer to the relevant user guide), user should be `root`, and password `root`.