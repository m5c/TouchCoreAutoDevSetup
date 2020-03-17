#!/bin/bash

# Touch/Ram/Core setup script.
# @author max.schiedermeier@mcgill.ca
# 
# steps (installations are skiped if required software already found on system)
#
# print disclaimer
# OS check
# brew installation
# jdk8 installation (v 1.8.232)
# eclipse installation
# code checkout
# eclipse plugin installation
# eclipse checkstyle installation
# eclipse workspace creation and default setup
# eclipse settings configuration (compiler version / JRE)

# java: 1.8.0.232

# Software Version variables

# Cask ruby file for homebrew / java8
JAVARUBY=https://raw.githubusercontent.com/AdoptOpenJDK/homebrew-openjdk/19d716f1c9ebc325ed23c5df580e0d2b027285a1/Casks/adoptopenjdk8.rb
# Cask ruby file for homebrew / eclipse modeling 2019-09
ECLIPSEVERSION=2019-09
ECLIPSERUBY=eclipse-modeling
#ECLIPSERUBY=https://raw.githubusercontent.com/Homebrew/homebrew-cask/31c955e9d598aea8b43f832090ed98c3edcfdf3f/Casks/eclipse-modeling.rb
# Eclipse plugin version numbers
ACCELEOVERSION=3.7.8.201902261618
# OCL requires splitup, because the files created in the installation do not respect the full verison convention. So to detect preinstalled versions, we need two strings.
OCLVERSIONPREFIX="6.9.0."
OCLVERSION=v20190910-0937
# Alike OCL, XTEXT files do not strictly follow the version convention. We need to strings to lookup existing installations
XTEXTVERSION=2.19.0.v20190902
XTEXTVERSIONSUFFIX="-1322"
CDTVERSIONPREFIX="9.9.0."
CDTVERSION=201909091956

function disclaimer()
{
	echo "Welcome to the TouchCore setup script."
	echo "Running this script will alter your system. MAKE A BACKUP NOW!"
	echo "To only display changes that would be made, use the \"-p\" parameter."
        echo "You may have to enter your password, to authorize system-wide configurations."
	echo "--------------------------------------------------------------------"
	echo "I have a backup and want my system to be modified [y/N]"
	read CORRECT
}

function maccheck
{
	# check if the kernel info variable contains the word "Darwin"
	MACKERNEL=$(uname -a | grep Darwin)
	if [ -z "$MACKERNEL" ]; then
		echo "This script only works for MacOS."
		exit -1
	fi
}

# manipulation of installed apps requires spctl to be disbaled. This is required to manipulate default settings in the eclipse application, after ihas been installed.
function spctlcheck
{
   INTEGRITYCHECKS=$(sudo spctl --status)
   if [ "$INTEGRITYCHECKS" = "assessments enabled" ]; then 
	echo " *** WARNING: Your system is currenlty integrity protected, but eclipse auto-configuration modifies the app-signature. You may be asked for your password, to accept the modification. ***"
	sudo spctl --master-disable
  fi
}

function brewinstall
{
	BREWPATH=$(command -v brew)
	if [ -z "$BREWPATH" ];then
		echo " * Installing brew"
		if [ -z "$PRETEND" ] ; then
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
		fi
	else
		echo " * Skipping installation of brew"
	fi
}

function javainstall
{
	# check if required version is java 8 present	
	if [ ! -d /Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/ ]; then
		echo " * Installing Java 1.8.232"
		if [ -z "$PRETEND" ] ; then
			brew cask install $JAVARUBY
		fi
	else
		# check if the preinstalled java version is the right one
		INSTALLED_VERSION=$(cat /Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Info.plist | grep "AdoptOpenJDK 1.8" | cut -c 23-31)
		if [ ! "$INSTALLED_VERSION" = "1.8.0_232" ]; then
			echo " * Replacing existing java 8 installation with compatible version 1.8.232"
			if [ -z "$PRETEND" ] ; then
			    brew cask uninstall adoptopenjdk8
			    brew cask install $JAVARUBY
			fi
		else
			echo " * Skipping installation/update of Java 1.8.232"
		fi
	fi
}

# makes sure the core/ram code is where it is supposed to be
function checkoutcode
{
	# Ensure existence of Code basedir
	if [ ! -d ~/Code/ ]; then
		echo " * Creating dedicated Code folder"
		if [ -z "$PRETEND" ] ; then
		  mkdir ~/Code
		fi
	else
		echo " * Skipping creation of ~/Code folder"
	fi
        if [ -z "$PRETEND" ] ; then
       	  cd ~/Code
	fi

	# Ensure the repositories are present
	if [ ! -d ~/Code/touchram ]; then
		echo " * Cloning touchram sources into Code folder"
		if [ -z "$PRETEND" ] ; then
		  git clone https://bitbucket.org/mcgillram/touchram.git
		fi
	else
		echo " * Skipping checkout of core sources"
	fi
	if [ ! -d ~/Code/core ]; then
		echo " * Cloning core sources into Code folder"
		if [ -z "$PRETEND" ] ; then
		  git clone https://bitbucket.org/mcgillram/core.git
		fi
	else
		echo " * Skipping checkout of touchram sources"
	fi
}

# makes sure that version 4.13.0 of the eclipse mdoeling version is installed
function eclipseinstall
{
	# TODO: Check version.
	# check if the modeling verison of eclipse is installed
	if [ ! -d /Applications/Eclipse\ Modeling.app/ ]; then
		echo " * Installing Eclipse Modeling version to /Applications/Eclipse Modeling.app/"
		if [ -z "$PRETEND" ] ; then
		    # check if existing version was installed by brew
		    brew cask info eclipse-modeling > /dev/null
		    BREWINSTALLED=$?
		    if [ $BREWINSTALLED -eq 0 ] ; then
    		      brew cask uninstall eclipse-modeling
		    else
 		      rm -rf /Applications/Eclipse-Modeling.app/
                    fi
		    brew cask install $ECLIPSERUBY
		fi
	else
		
		# check if the installed version is the right one
		INSTALLEDECLIPSE=$(cat /Applications/Eclipse\ Modeling.app/Contents/Info.plist | grep -A2 CFBundleVersion | grep string | cut -c 11-31)
		if [ ! "$INSTALLEDECLIPSE" = "4.13.0.I20190916-1045" ]; then
		  echo " * Replacing installed eclipse by v4.12.0 / 2019-09R"
		  if [ -z "$PRETEND" ] ; then
		    # check if existing version was installed by brew
		    brew cask info eclipse-modeling > /dev/null
		    BREWINSTALLED=$?
		    if [ $BREWINSTALLED -eq 0 ] ; then
    		      brew cask reinstall $ECLIPSERUBY
		    else
 		      rm -rf /Applications/Eclipse-Modeling.app/
		      brew cask install $ECLIPSERUBY
                    fi
		  fi
		else
		  echo " * Skipping installation/update of Eclipse-Modeling"
		fi
	fi
}

# TODO: make sure the _right versions_ of the plugins are installed
# Uninstall with: -uninstallIU
function eclipseplugins()
{
    # acceleo
    if ls /Applications/Eclipse\ Modeling.app/Contents/Eclipse/plugins/org.eclipse.acceleo.common_$ACCELEOVERSION.jar 1> /dev/null 2>&1; then
	echo " * Skipping installation of Acceleo Eclipse-Plugin"
    else
	    echo " * Installing Acceleo Eclipse-Plugin"
	    if [ -z "$PRETEND" ] ; then
	      /Applications/Eclipse\ Modeling.app/Contents/MacOS/eclipse -nosplash -application org.eclipse.equinox.p2.director -repository http://download.eclipse.org/releases/$ECLIPSEVERSION -installIU org.eclipse.acceleo.feature.group/$ACCELEOVERSION
	    fi
    fi

    # OCL
    if ls /Applications/Eclipse\ Modeling.app/Contents/Eclipse/plugins/org.eclipse.ocl.examples_*$OCLVERSION*.jar 1> /dev/null 2>&1; then
	echo " * Skipping installation of OCL Eclipse-Plugin"
    else
	    echo " * Installing OCL Eclipse-Plugin"
	    if [ -z "$PRETEND" ] ; then
	      /Applications/Eclipse\ Modeling.app/Contents/MacOS/eclipse -nosplash -application org.eclipse.equinox.p2.director -repository http://download.eclipse.org/releases/$ECLIPSEVERSION -installIU org.eclipse.ocl.examples.feature.group/$OCLVERSIONPREFIX$OCLVERSION
	    fi
    fi

    # xtext
    if ls /Applications/Eclipse\ Modeling.app/Contents/Eclipse/plugins/org.eclipse.xtext.doc_$XTEXTVERSION*.jar 1> /dev/null 2>&1; then
	echo " * Skipping installation of Xtext Eclipse-Plugin"
    else
	    echo " * Installing Xtext Eclipse-Plugin"
	    if [ -z "$PRETEND" ] ; then
      /Applications/Eclipse\ Modeling.app/Contents/MacOS/eclipse -nosplash -application org.eclipse.equinox.p2.director -repository http://download.eclipse.org/releases/$ECLIPSEVERSION -installIU org.eclipse.xtext.sdk.feature.group/$XTEXTVERSION$XTEXTVERSIONSUFFIX
	    fi
    fi

    # CDT -> c/c++ development tools (non sdk)
    if ls /Applications/Eclipse\ Modeling.app/Contents/Eclipse/plugins/org.eclipse.cdt_$CDTVERSIONPREFIX*.jar 1> /dev/null 2>&1; then
	echo " * Skipping installation of CDT Eclipse-Plugin"
    else
	    echo " * Installing CDT Eclipse-Plugin"
	    if [ -z "$PRETEND" ] ; then
	      /Applications/Eclipse\ Modeling.app/Contents/MacOS/eclipse -nosplash -application org.eclipse.equinox.p2.director -repository http://download.eclipse.org/releases/$ECLIPSEVERSION -installIU org.eclipse.cdt.feature.group/$CDTVERSIONPREFIX$CDTVERSION
	    fi
    fi

}

function eclipseconfig()
{
    # disable mac-os integrity / signature checks, so we can still launch the app after we configured it.
    if [ -z "$PRETEND" ] ; then
      spctlcheck
    fi

    # make sure the right eclipse workspace exists
    if [ ! -d ~/touchcore-workspace/ ]; then
      echo " * Creating dedicated workspace"
      if [ -z "$PRETEND" ] ; then
        mkdir ~/touchcore-workspace
      fi
    else
      echo " * Skipping creation of dedicated workspace"
    fi

    # make sure dedicated workspace is selected by default
    if [ ! -f /Applications/Eclipse\ Modeling.app/Contents/Eclipse/configuration/.settings/org.eclipse.ui.ide.prefs ] ; then
      echo " * Setting correct default workspace"
      if [ -z "$PRETEND" ] ; then
        mkdir -p /Applications/Eclipse\ Modeling.app/Contents/Eclipse/configuration/.settings
	echo "MAX_RECENT_WORKSPACES=10
RECENT_WORKSPACES=/Users/$(whoami)/touchcore-workspace
RECENT_WORKSPACES_PROTOCOL=3
SHOW_RECENT_WORKSPACES=false
SHOW_WORKSPACE_SELECTION_DIALOG=false
eclipse.preferences.version=1" > /Applications/Eclipse\ Modeling.app/Contents/Eclipse/configuration/.settings/org.eclipse.ui.ide.prefs
      fi
    else
      echo " * Skipping setting dedicated workspace as default"
    fi

    # make sure the correct JRE path is set
    echo " * Configuring Eclipse to use JRE 1.8 as default"
    if [ -z "$PRETEND" ] ; then
      mkdir -p ~/touchcore-workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/
      echo 'eclipse.preferences.version=1
org.eclipse.jdt.launching.PREF_VM_XML=<?xml version\="1.0" encoding\="UTF-8" standalone\="no"?>\n<vmSettings defaultVM\="52,org.eclipse.jdt.internal.launching.macosx.MacOSXType22,net.adoptopenjdk.8.jre">\n    <vmType id\="org.eclipse.jdt.internal.launching.macosx.MacOSXType">\n        <vm id\="net.adoptopenjdk.13.jdk" name\="AdoptOpenJDK 13 [13.0.2]" path\="/Library/Java/JavaVirtualMachines/adoptopenjdk-13.jdk/Contents/Home"/>\n        <vm id\="net.adoptopenjdk.8.jdk" name\="AdoptOpenJDK 8 [1.8.0_232]" path\="/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home"/>\n        <vm id\="net.adoptopenjdk.8.jre" name\="AdoptOpenJDK (JRE) 8 [1.8.0_232]" path\="/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jre/Contents/Home"/>\n    </vmType>\n</vmSettings>\n' > ~/touchcore-workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.jdt.launching.prefs
    fi

    # make sure the correct compiler compliance is set
    echo " * Configuring Eclipse compiler compliance JDK 1.8"
    if [ -z "$PRETEND" ] ; then
      echo "org.eclipse.jdt.core.compiler.compliance=1.8" >> ~/touchcore-workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.jdt.core.prefs
      echo "org.eclipse.jdt.core.compiler.source=1.8" >> ~/touchcore-workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.jdt.core.prefs
      echo "org.eclipse.jdt.core.compiler.codegen.targetPlatform=1.8" >> ~/touchcore-workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.jdt.core.prefs
    fi
}

# checkstyle is a marketplace app and as such not directly isntallable via the eclipse installer. But ther is a plugin for that
# https://github.com/budhash/install-eclipse
function eclipsecs()
{	
	# TODO: Uninstall different versions.
	if [ ! -f /Applications/Eclipse\ Modeling.app/Contents/Eclipse/plugins/net.sf.eclipsecs.checkstyle_8.29.0.202001290016.jar ]; then
		echo " * Installing Checkstyle plugin"
		
		if [ -z "$PRETEND" ] ; then
			# not from official repo. Bash installer therefore rejects the plugin. But we can transplant the content manually into the eclipse installation.
			# install wget if not yet installed
			WGETPATH=$(command -v brew)
			if [ -z "WGETPATH" ];then
				if [ -z "$PRETEND" ] ; then
					brew install wget
				fi
			fi
			
			# get the checkstyle plugin, v 8.29.0.202001290016
			wget -q --show-progress --progress=bar:force -O /tmp/checkstyle.zip https://bintray.com/eclipse-cs/eclipse-cs/download_file?file_path=update-site-archive%2Fnet.sf.eclipsecs-updatesite_8.29.0.202001290016.zip 2>&1
			unzip -qq -o /tmp/checkstyle.zip -d /tmp

			# transplant plugin files into Eclipse installation
			cp /tmp/features/* /Applications/Eclipse\ Modeling.app/Contents/Eclipse/features/
			cp /tmp/plugins/* /Applications/Eclipse\ Modeling.app/Contents/Eclipse/plugins/
		fi
	else
		echo " * Skipping installation of checkstyle plugin"
	fi
}

# forces the right checstyle configuration file to be used, without any clicking
function configurecs()
{
	if [ ! -f ~/touchcore-workspace/.metadata/.plugins/net.sf.eclipsecs.core/checkstyle-config.xml ]; then
		echo " * Auto configuring checkstyle plugin"
		if [ -z "$PRETEND" ] ; then
			mkdir -p ~/touchcore-workspace/.metadata/.plugins/net.sf.eclipsecs.core/
			echo '<?xml version="1.0" encoding="UTF-8"?>

		<checkstyle-configurations file-format-version="5.0.0" default-check-configuration="TouchRAM Checks">
		  <check-configuration name="TouchRAM Checks" location="/ca.mcgill.sel.commons/touchram_checkstyle.xml" type="project" description="">
		    <additional-data name="protect-config-file" value="false"/>
		  </check-configuration>
		</checkstyle-configurations>' > ~/touchcore-workspace/.metadata/.plugins/net.sf.eclipsecs.core/checkstyle-config.xml
		fi
	else
		echo " * Skipping configuration of checkstyle plugin."
	fi
}

# Requires eclipse CDT sdk plugin to work
function projectimport()
{
	# run check if already imported.
	if [ ! -f ~/touchcore-workspace/.metadata/.plugins/org.eclipse.core.resources/.projects/ca.mcgill.sel.ram.gui/.location ]; then
		echo " * Importing projects into workspace"
		if [ -z "$PRETEND" ] ; then
			for i in ~/Code/core/ca.mcgill*
			  do 
			  # skip the gui project - it is a phantom
			  if [[ "$i" == *"$ca.mcgill.sel.core.gui"* ]]; then
				continue;
			  fi
			  # TODO: skip import if already imported
			  /Applications/Eclipse\ Modeling.app/Contents/MacOS/eclipse -nosplash -data ~/touchcore-workspace/ -application org.eclipse.cdt.managedbuilder.core.headlessbuild -import $i &>/dev/null
			  echo -n "."
			done
			for i in ~/Code/touchram/ca.mcgill*
			  do 
			  # skip the ucm projects (currently not building)
			  if [[ "$i" == *"$ca.mcgill.sel.ucm"* ]]; then
				continue;
			  fi
			  # skip the ram editor project - it is a phantom
			  if [[ "$i" == *"$ca.mcgill.sel.ram.editor"* ]]; then
				continue;
			  fi
			  /Applications/Eclipse\ Modeling.app/Contents/MacOS/eclipse -nosplash -data ~/touchcore-workspace/ -application org.eclipse.cdt.managedbuilder.core.headlessbuild -import $i &>/dev/null
			  echo -n "."
			done
			echo ""
		fi
	else
		echo " * Skipping import of projects into workspace"
	fi
}

function autoinstaller()
{
	brewinstall
	javainstall
	checkoutcode
	eclipseinstall
	eclipseplugins
	eclipsecs
	eclipseconfig
	configurecs
	projectimport
}

# MAIN FUNCTION
# PRINT WELCOME MESSAGE, AWAIT BACKUP CONFIRMATION
maccheck
if [ "$1" = "-iknowwhatiamdoing" ]; then
	CORRECT="y"
elif [ "$1" = "-p" ]; then
	echo "You are in pretend mode. All checks are run, but no modifications are made to your system."
	PRETEND="y"
else
	disclaimer
fi
if [ "$CORRECT" = "y" ] || [ "$PRETEND" = "y" ] ; then
	autoinstaller
else
	echo "No changes made. Exiting."	
	exit 1
fi

exit -1
