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

*Note:* The script was developed specifically for MacOS and will not work on other UNIX-like systems.

## Future features

 * Profile/debug option, to only print the exact plugin/tool versions found on the current system, in a nice grid view. Possibly also indicating where it differs from the suggested setup.
 * Cleaner option to wipe specific parts of the installation
 * Parameters to only perform individual stages of the installation procedure.

## Author

Maximilian Schiedermeier  
first.last@mcgill.ca
