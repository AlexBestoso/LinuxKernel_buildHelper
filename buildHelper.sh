#!/bin/bash
THIS_DIR=$(pwd)
KERNEL_REPO_INSTALL_LOC=$THIS_DIR # Directory to clone linux to
KERNEL_REPO_LOC="$KERNEL_KERNEL_REPO_INSTALL_LOC/linux" # the actual location of the linux repo
KERNEL_PATCHES_LOC="$THIS_DIR/patches" # A folder containing ONLY patch files for the linux repo made via the git command.
KERNEL_CONFIG="$THIS_DIR/linux.config" # the location of your config file

echo "Would you like to install the build requirements? (No/yes)"
read IPT
if [ "$IPT" == "yes" ]; then
	sudo apt-get install git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc flex libelf-dev bison
fi

echo "Would you like to generate a new config file using your current kernel version? (No/yes)"
read IPT
if [ "$IPT" == "yes" ]; then
	cp -v /boot/config-$(uname -r) $KERNEL_CONFIG
fi

echo "Would you like to download the kernel? (No/yes)"
read IPT
if [ "$IPT" == "yes" ]; then
	echo "removing $KERNEL_REPO_LOC"
	rm -rfv $KERNEL_REPO_LOC
	echo "downloading to $KERNEL_REPO_INSTALL_LOC"
	cd $KERNEL_REPO_INSTALL_LOC
	git clone https://github.com/torvalds/linux.git
	cd $THIS_DIR
fi

echo "Would you like to pull the kernel? (No/yes)"
read IPT
if [ "$IPT" == "yes" ]; then
	cd $KERNEL_REPO_LOC;
	git pull
	cd $THIS_DIR
fi

echo "Deleting old kernel (if it exists)"
rm -rfv "$THIS_DIR/myKernel"

echo "Setting up your kernel!"
cp -rv $KERNEL_REPO_LOC "$THIS_DIR/myKernel"

echo "Copying config to my kernel."
cp $KERNEL_CONFIG "$THIS_DIR/myKernel/.config"

echo "Applying patches"
cd "$THIS_DIR/myKernel"
for p in $(ls $KERNEL_PATCHES_LOC)
do
	patch="$KERNEL_PATCHES_LOC/$p"
	echo "Applying patch $patch"
	git apply $patch
done

echo "Disabling trusted keys (new ones will be generated)"
scripts/config --disable SYSTEM_TRUSTED_KEYS
scripts/config --disable SYSTEM_REVOCATION_KEYS

echo "Would you like to configure your config file? (No/yes)"
if [ "$IPT" == "yes" ]; then
	make menuconfig
fi
echo "Making kernel"
make

echo "install modules ? (No/yes)"
read IPT
if [ "$IPT" == "yes" ]; then
	sudo make modules_install
fi

echo "installing kernel? (No/yes)"
read IPT
if [ "$IPT" == "yes" ]; then
	sudo make install
fi
cd $THIS_DIR
echo "Done :)"
