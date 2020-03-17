# TouchCORE Auto Dev Setup

## About

[TouchCORE](http://touchcore.cs.mcgill.ca/) is a multi-touch enabled software modeling tool, developed at McGill University.
A working dev-environment for TouchCORE is subject to many implicit version constraints, such as the right Eclipse version, plugins, JDK and also IDE settings.  
This repository hosts a [bash script](touchcore-init.sh) for an automated and reliable workstation setup.

## Features

The auto-installer performs the identical steps as a [manual workstation setup](https://bitbucket.org/mcgillram/touchram/wiki/getting-started).

 * Install compatible Java version
 * Download [TouchCore sources](https://bitbucket.org/mcgillram/touchram/src/master/) into dedicated folder
 * Install compatible Eclipse-Modeling IDE
 * Install compatible Acceleo Eclipse-Plugin
 * Install compatible OCL Eclipse-Plugin
 * Install compatible Xtext Eclipse-Plugin
 * Install compatible Eclipse Checkstyle plugin
 * Auto configure eclipse / plugin settings
 * Import TouchCORE projects into workspace 

Furthermore, depending on your system and the required actions it may download additional tools, such as [brew](https://brew.sh/), [eclipse-CDT](https://www.eclipse.org/cdt/) and [wget](https://www.gnu.org/software/wget/).

*Note:* The installer modifies configuration files within the eclipse installation. This leads to a signature mismatch of the app. Depending on your system settings you may be asked for your password to override the MacOS integrity protection.

## Usage

**Warning:** This tool may overwrite existing eclipse installations and configurations. It is highly recommended to make a full system backup before usage.

 * ```./touchcore-init.sh -p``` *Run a full installation in pretend mode, only showing what would be done to the system.*
 * ```./touchcore-init.sh``` *Run a full installation, but request a backup before actually modifying the system.*
 * ```./touchcore-init.sh -iknowwhatiamdoing``` *Run a full installation, brutally replacing any installation/configuration that may exist.*

*Note:* The script was developed specifically for MacOS and will not work on other UNIX-like systems.

## Known Bugs

 * brew currently lags slighlty behind the official Eclipse Modeling release
   * Most recent without brew: 4.14.0
   * Most recent with brew: 4.13.0  
Some aird files complain about a sirius conflict, if not opened with the most recent eclipse version. So far a workaraound is to open the aird as xml and manually downgrade the sirius version number.

## Author

Maximilian Schiedermeier  
first.last@mcgill.ca
