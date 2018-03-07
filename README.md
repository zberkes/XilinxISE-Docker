Docker image and starter script for Xilinx ISE.
===============================================

Xilinx has released _the last_ version of Xilinx ISE in 2013 -- namely version 14.7 -- and the product is now mature and discontinued.
If you want to use it under GNU/Linux, you may find difficulties to install and run it on a recent GNU/Linux distro, because support
of old libraries used by Xilinx ISE start disappearing in modern distros. With
[this Docker image](https://hub.docker.com/r/zberkes/xilinx-ise-centos6/) you can run Xilinx ISE in a Docker container on top of CentOS 6
while your workspace mounted ino the container.


Installation
------------

For copyright and size reasons this image only contains a preconfigured CentOS 6 with a start-up script (docker-entrypoint.sh). To get
a working Xilinx ISE development environment, first you have to deploy that in this image:

0. pull docker image: `docker pull zberkes/xilinx-ise-centos6`

1. [Download Xilinx ISE Design Suite](http://www.xilinx.com/products/design-tools/ise-design-suite.html) version
    [14.7](http://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/design-tools/v2012_4---14_7.html)

2. Acquire a free licence key [here](http://www.xilinx.com/support/licensing_solution_center.htm). You must register if you don't have
    a Xilinx account already. The licence key will be sent to your email address. Keep it, you will need it in a later step.

3. Download the [startup script file](https://github.com/zberkes/XilinxISE-Docker/blob/master/xilinx) and
    [configuration file](https://github.com/zberkes/XilinxISE-Docker/blob/master/config) into a folder and add it to PATH, or make a symlink
    to `xilinx` from your bin folder. Certainly, you can checkout the ful source code from
    [GitHub](https://github.com/zberkes/XilinxISE-Docker)

    Optionally you can put it directly in your bin folder and the config file to `$HOME/.config/Docker` or
    `/etc/XilinxISE-docker.config, $HOME/.config/XilinxISE-docker.config`.

4. In the configuration file set paths to your Xilinx ISE installer, installation target (installed Xilinx ISE), and your workspace.
   The workspace will be your home folder in the container.

5. Start the installation with the following command:

    `xilinx --install xsetup`

    If everything is okay, Xilinx ISE's installer window appears. Accept licences and all default setup configs.

    _Don't install cable drivers!_

6. Run post install patches

    This are patches to fix issues. You can run them with the following command:

    `xilinx --install --root --shell apply-xilinx-patch PATCHNAME`

    Currently the following post install patches exist:

    - glibstdc++ version upgrade, Firefox needs it: upgrade-glibstdc++
    - Xilinx Virtual Cable in ISE Project Navigator: ise-navigator-xvc

    You can run all of them with the following command:

    `xilinx --root --install --shell apply-xilinx-patches --all`

7. Initiate workspace:

    - Create your workspace folder, which was configured in step 3. This folder will be your home folder in the container and must be
      writable by you.
    - Run `xilinx --init-workspace` This step creates default GNU/Linux config files in your workspace folder.
    - Copy your Xilinx ISE licence key to the .Xilinx folder under your workspace folder.

9. Start Xilinx ISE: `xilinx ise`

    Xilinx ISE project manager should appear.

10. If you want to configure and debug your Xilinx devices directly from Xilinx ISE (iMPACT, ChipSCOPE), than I suggest using Xilinx
   Virtual Cable. You find details later in this document.

11. If you want to apply additional changes on the Linux system inside this Docker image, please read the "How this Docker image works"
    section below.


Known issues
------------

  * *Xilinx FGPA Editor* starts slowly.

    Cause: It is waiting to register an RPC service.


Startup script reference
========================

Usage: **xilinx** *[startup options]* *[in-docker startup options]* *[command]*


startup options
---------------

These options are interpreted by the *xilinx* startup script. They must be the first command line options.

  * `--shell` or `-s`

    Run in shell. Startup script starts the Docker with interactive shell
    connection.
    
  * `--config conf` or `-c conf`

    Use configuration file `conf`.

  * `--install` or `-i`

    Run in install mode. In this mode, install folder (*INSTALLER* config otion) is mounted into */media/install* in read only mode,
    while the installed Xilinx ISE application folder (*XILINX_ISE* config option) is made writable. In this mode Xilinx ISE's
    initialization scripts are not applied.

    
in-docker startup options
-------------------------

These options are interpreted by the in-docker starter script (*/docker-entrypoint.sh*):

  * `--init-workspace`

    Initialize workspace (user home fodler template files are copied into the workspace).

  * `--root`

    Run as root user.

Actually there are more in-docker startup options, however, they are for internal use by *xilinx* startup script.


command
-------

The command can be any valid linux command and its arguments. The startup script calls Xilinx ISE's initialization scripts, so you can
use all Xilinx XILINX_ISE commands.

If no command is given then an interactive BASH shell is started.



How this Docker image works
===========================

I wanted a Docker image that works out-of-box without using any desktop share solution like VNC. Therefore I looked for a solution to use
X11 directly, and I've found [this X11 socket sharing solution](http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/).
With this solution GUI runs natively on your desktop without any performance lost. However, due to X11's security mechanism, this solution
needs that you run the Xilinx ISE under the same user as you runs your X11 desktop (or more precisely X11 client). To achieve this, *linux*
startup script passes actual user's id, name and group to the Docker image where *docker-entrypoint.sh* creates the same user and switches
to it.

Startup script runs a new Docker session everytime. This has an important effect: everytime you starts it with *xilinx* startup script,
a new, clean environment is created, therefore everything you have modified on the system as root is lost. To install additional linux
packages or apply changes on the system, you have to create a new Docker image (on this one) with your modifications. If this solution
is not appropriate for you, feel free to modify the startup script.



How to use Xilinx Virtual Cable in Xilinx ISE 14.7
==================================================

Even though it is not officially supported, you can use the Xilix Virtual Cable driver in Xilinx ISE 14.7.


About the Xilinx Virtual Cable
------------------------------

Xilinx Virtual Cable is a simple protocol to communicate with a JTAG interface over IP network. So, the Xilinx
development environment and the device under configuration or debug can be somewhere else on the network, even
it can be thousand miles away somewhere on the internet. You can find more details and a sample implementation
at [Xilinx's web page](http://www.xilinx.com/products/intellectual-property/xvc.html).


Limitations in Xilinx ISE 14.7
------------------------------

- It is not officially supported, it looks like an undocumented and/or maybe unfinished Cable Driver plugin.
- Only the `shift` command is implemented in the driver.
- You may have to modify some script files in Xilinx ISE.


Using it from iMPACT and ChipSCOPE
----------------------------------

1. Start your Xilinx Virtual Cable Server. This is the software that receives XVC commands and performs that
   on the JTAG cable. Some implementations:

    - [Xilinx's example design](https://github.com/Xilinx/XilinxVirtualCable)
    - [xvcd with GPIO](https://github.com/tmbinc/xvcd)
    - [xvcd with libFTDI](https://github.com/tmbinc/xvcd/tree/ftdi)

        You can easily implement a USB JTAG cable with an
        [FT2232H Mini-Module](http://www.ftdichip.com/Products/Modules/DevelopmentModules.htm#FT2232H_Mini). It can be connected directly
        to a 3.3V device. For 2.5V devices put 68 ohm or larger resistors in series on TCK, TDI and TMS pins.

2. In _iMPACT_ and _ChipSCOPE_ select **Open Cable Plug-in** and type the following command in the textfield:

    `xilinx_xvc host=my_xvc_host:2542 disableversioncheck=true`

    where **my_xvc_host** must be the host name or ip address where your Xilinx Virtual Cable Server runs.


Using from ISE project navigator
--------------------------------

When you want to configure your device from the Project Navigator, it tries to autodetect cable, because it
doesn't know Xilinx Virtual Cable protocol. Fortunately, you only have to modify two TCL script files by the
patch mentioned in the sixth step of intallation:

1. add XVC support to ISE Project Navigator with the following command:

  `xilinx --install --root --shell apply-xilinx-patch PATCHNAME`

2. Select Xilinx Virtual Cable in your project:

    - Right click on **Configure Target Device** node in Project Navigator, then select **Process Properties...**
    - Change **Property display level** to **Advanced**
    - Set **Port to be used** to **Xilinx Virtual Cable**

3. Double click on **Configure Target Device** in the processes window. If your design works and your Xilinx
   Virtual Cable Server runs, it must connect and configure your device.


Useful links:
-------------

- http://www.xilinx.com/products/intellectual-property/xvc.html
- https://github.com/Xilinx/XilinxVirtualCable
- http://debugmo.de/2012/02/xvcd-the-xilinx-virtual-cable-daemon/
- https://github.com/tmbinc/xvcd
- https://github.com/tmbinc/xvcd/tree/ftdi
