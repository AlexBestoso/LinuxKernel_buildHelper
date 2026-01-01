#!/bin/bash
COLOR_RST="\033[0m"
COLOR_RED="\033[0;31m"
COLOR_GREEN="\033[0;32m"
COLOR_YELLOW="\033[0;33m"
COLOR_BLUE="\033[0;34m"
COLOR_PURPLE="\033[0;35m"
COLOR_CYAN="\033[0;36m"
COLOR_BPURPLE="\033[1;35m"
COLOR_BCYAN="\033[1;36m"
COLOR_BYELLOW="\033[1;33m"
THIS_DIR=$(pwd)
KERNEL_REPO_INSTALL_LOC=$THIS_DIR # Directory to clone linux to
KERNEL_REPO_LOC="$KERNEL_REPO_INSTALL_LOC/linux" # the actual location of the linux repo
KERNEL_PATCHES_LOC="$THIS_DIR/patches" # A folder containing ONLY patch files for the linux repo made via the git command.
KERNEL_PATCH_ARCHIVE="$THIS_DIR/patch_archive"
KERNEL_CONFIG="$THIS_DIR/linux.config" # the location of your config file

echo -en "${COLOR_CYAN}Would you like to install the build requirements? (No/yes)\n"
read IPT
if [ "$IPT" == "yes" ]; then
	sudo apt-get install libdw-dev gawk libdwarf-dev git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc flex libelf-dev bison
	if [ "$?" != "0" ]; then
		echo "build helper failed :("
		exit;
	fi
fi

echo -en "${COLOR_PURPLE}Would you like to generate a new config file using your current kernel version? (No/yes)\n"
read IPT
if [ "$IPT" == "yes" ]; then
	cp -v /boot/config-$(uname -r) $KERNEL_CONFIG
	if [ "$?" != "0" ]; then
		echo "build helper failed :("
		exit;
	fi
fi

echo -en "${COLOR_BLUE}Would you like to download the kernel? (No/yes)\n"
read IPT
if [ "$IPT" == "yes" ]; then
	echo "removing $KERNEL_REPO_LOC"
	rm -rfv $KERNEL_REPO_LOC
	if [ "$?" != "0" ]; then
		echo "build helper failed :("
		exit;
	fi
	echo "downloading to $KERNEL_REPO_INSTALL_LOC"
	cd $KERNEL_REPO_INSTALL_LOC
	git clone https://github.com/torvalds/linux.git
	if [ "$?" != "0" ]; then
		echo "build helper failed :("
		exit;
	fi
	cd $THIS_DIR
fi

echo -en "${COLOR_YELLOW}Would you like to pull the kernel? (No/yes)\n"
read IPT
if [ "$IPT" == "yes" ]; then
	cd $KERNEL_REPO_LOC;
	git pull
	if [ "$?" != "0" ]; then
		echo "build helper failed :("
		exit;
	fi
	cd $THIS_DIR
fi

echo -en "${COLOR_RED}Any changes made to the $THIS_DIR/myKernel will be erased. Are you ready? (NO / 'nuke it')"
read IPT;
while [ "$IPT" != "nuke it" ]
do
	echo -en "${COLOR_GREEN}We've protected your precious widdle kernel changes.${COLOR_RST}\n";
	echo -en "${COLOR_RED}myKernel will be erased. Are you ready? (NO / 'nuke it') "
	read IPT;
done

echo -en "${COLOR_CYAN}Deleting old kernel (if it exists)\n"
rm -rfv "$THIS_DIR/myKernel"
if [ "$?" != "0" ]; then
	echo "build helper failed :("
	exit;
fi

echo -en "${COLOR_PURPLE}Setting up your kernel!\n"
cp -rv $KERNEL_REPO_LOC "$THIS_DIR/myKernel"
if [ "$?" != "0" ]; then
	echo "build helper failed :("
	exit;
fi

echo -en "${COLOR_BLUE}Copying config to my kernel.\n"
cp $KERNEL_CONFIG "$THIS_DIR/myKernel/.config"
if [ "$?" != "0" ]; then
	echo "build helper failed :("
	exit;
fi

echo -en "${COLOR_GREEN}Applying patches\n"
cd "$THIS_DIR/myKernel"
for p in $(ls $KERNEL_PATCHES_LOC)
do
	patch="$KERNEL_PATCHES_LOC/$p"
	echo "Applying patch $patch"
	git apply $patch
	if [ "$?" != "0" ]; then
		echo -en "${COLOR_CYAN}This patch failed, what would you like to do?\n1) archive\n2) exit\nany other key) ignore\n> "
		read IPT
		if [ "$IPT" == "exit" ] || [ "$IPT" == "2" ]; then
			echo "Good bye"
			exit;
		elif [ "$IPT" == "archive" ] || [ "$IPT" == "1" ]; then
			mkdir -p $KERNEL_PATCH_ARCHIVE
			mv -v $patch $KERNEL_PATCH_ARCHIVE;
			echo "Patch archinved."
		else
			if [ "$IPT" == "any other key" ]; then
				echo -en "[\033[5;31;42m We Gotta Smartass!\033[0m\n"
			fi
			echo "...Ignoring"
		fi
	fi
done

echo -en "${COLOR_RED}Disabling trusted keys (new ones will be generated)\n"
scripts/config --disable SYSTEM_TRUSTED_KEYS
if [ "$?" != "0" ]; then
	echo "build helper failed :("
	exit;
fi
scripts/config --disable SYSTEM_REVOCATION_KEYS
if [ "$?" != "0" ]; then
	echo "build helper failed :("
	exit;
fi

echo -en "${COLOR_YELLOW}Would you like to configure your config file? (No/yes)\n"
read IPT
if [ "$IPT" == "yes" ]; then
	make menuconfig
fi
echo -en "${COLOR_BPURPLE}Making kernel\n"
make
if [ "$?" != "0" ]; then
	echo "build helper failed :("
	exit;
fi
	
echo "Player One, are you ready?"
echo -en "${COLOR_BCYAN}install modules ? (No/yes)\n"
read IPT
if [ "$IPT" == "yes" ]; then
	sudo make modules_install
	if [ "$?" != "0" ]; then
		echo "build helper failed :("
		exit;
	fi
fi

echo -en "${COLOR_BYELLO}installing kernel? (No/yes)\n"
read IPT
if [ "$IPT" == "yes" ]; then
	sudo make install
	if [ "$?" != "0" ]; then
		echo "build helper failed :("
		exit;
	fi
fi
cd $THIS_DIR
echo -en "${COLOR_RST}Done :)\n"
