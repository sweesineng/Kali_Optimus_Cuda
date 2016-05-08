#!/bin/bash  
echo -e "\e[1;96m " 
echo "***********************************************************************"
echo "*                      Automate Installation for                      *"
echo "*         Nvidia + Cuda Toolkits + Bumblebee + PyritOptimus           *"
echo "*                          for Optimus Laptop                         *"
echo "***********************************************************************"
echo -e " \e[0m"
echo -e "\e[93mDownload virtualgl & cuda toolkit from website listed below: "
echo -e "\e[93m   virtualgl      => \e[95mhttps://sourceforge.net/projects/virtualgl/files/ "
echo -e "\e[93m                     *Grab the latest non-beta *.deb"
echo " "
echo -e "\e[93m   Cuda Toolkits  => \e[95mhttps://developer.nvidia.com/cuda-downloads"
echo -e "\e[93m                     *Grab the x64 or 14.04 *.run file"
echo " "
echo -e "\e[93mSave both file in same location"
echo -e "\e[93mDefault save location : ~/Downloads/\e[0m"

# Define default location
LOC=$(~/Downloads/)

# Check if had download both file
echo -e "\e[93mCheck if file exist:"
[ -f $LOC/virtualgl*.deb ] && echo -e "\e[93mVirtualgl ===> \e[1;92mFound\e[0m" ||echo -e "\e[93mVirtualgl ===> \e[1;91mNot found\e[0m"
[ -f $LOC/cuda*.run ] && echo -e "\e[93mCuda Toolkits ===> \e[1;92mFound\e[0m" ||echo -e "\e[93mCuda Toolkits ===> \e[1;91mNot found\e[0m"

# If one of the file not in default location
while ! [ -f $LOC/virtualgl*.deb ] || ! [ -f $LOC/cuda_*.run ]; do
        echo -e "\e[93mInput where both file location, followed by [ENTER]: \e[0m"
        # Read new location
        read LOC
        LOC=$(sed s'/\/$//' <<< $LOC)
        # Check again on new location
        if [ -f $LOC/virtualgl*.deb ] && [ -f $LOC/cuda_*.run ]; then
                echo -e "\e[93mFiles found at new location... \e[1;92m[ OK ]\e[0m"
                echo -e "\e[93mContineu with installation\e[0m"
                break
        fi
done
echo -e "\e[1;96m "
echo "***********************************************************************"
echo "*                       Unload Nouveau Driver                         *"
echo "***********************************************************************"
echo -e " \e[0m"
echo -e "\e[93mmodprobe -r nouveau \e[0m"
# Unload nouveau
modprobe -r -q nouveau
# Check if nouveau succefully remove
if [ "$?" -gt 0 ]; then
	echo -e "\e[1;91mError...Nouveau cannot be unload"
	echo -e "Reboot & set nomodeset=0 on boot menu\e[0m" 
	exit 1
fi
echo -e "\e[93mUnload Nouveau driver... \e[1;92m[ OK ]\e[0m"

echo -e "\e[1;96m "
echo "***********************************************************************"
echo "*                    Install build-essential package                  *"
echo "***********************************************************************"
echo -e " \e[0m"
echo -e "\e[93mCheck if gcc, g++ & make is installed \e[0m"
# Check gcc compiler
[ $(which gcc) ] && echo -e "\e[93mgcc... \e[1;92m$(which gcc)\e[0m" || echo -e "\e[1;91mgcc... Not Installed\e[0m" 
# Check g++ compiler
[ $(which g++) ] && echo -e "\e[93mg++... \e[1;92m$(which g++)\e[0m" || echo -e "\e[1;91mg++... Not Installed\e[0m" 
# Check make compiler
[ $(which make) ] && echo -e "\e[93mmake... \e[1;92m$(which make)\e[0m" || echo -e "\e[1;91mmake... Not Installed\e[0m" 

if [ ! $(which gcc) ] || [ ! $(which g++) ] || [ ! $(which make) ]; then
        echo -e "\e[93mInstalling build-essential\e[0m"
	apt-get -y install build-essential | grep "Setting" | sed 's/^/   /'
fi
echo -e "\e[93mInstallation build-essential... \e[1;92m[ OK ]\e[0m"

echo -e "\e[1;96m "
echo "***********************************************************************"
echo "*                         Install linux header                        *"
echo "***********************************************************************"
echo -e " \e[0m"
echo -e "\e[93mInstall latest linux-headers-$(uname -r)\e[0m"
# Install latestlinux-headers
apt-get -y install linux-headers-$(uname -r) | grep "Setting" | sed 's/^/   /'
echo -e "\e[93mlinux-headers-$(uname -r)... \e[1;92m[ OK ]\e[0m"

echo -e "\e[1;96m "
echo "***********************************************************************"
echo "*                        Install bbswitch-dksm                        *"
echo "***********************************************************************"
echo -e " \e[0m"
echo -e "\e[93mInstall bbswitch-dkms\e[0m"
# Install BBSwitch-dkms
apt-get -y install bbswitch-dkms | grep "Setting"  | sed 's/^/   /'
echo -e "\e[93mbbswitch-dkms... \e[1;92m[ OK ]\e[0m"
# Set nvidia to off
echo -e "\e[93mTurn off nvidia card by: \e[94mmodprobe bbswitch load_state=0\e[0m"
modprobe bbswitch load_state=0
echo -ne "\e[93mCurrent state:\e[0m"
cat /proc/acpi/bbswitch
if cat /proc/acpi/bbswitch | grep "ON"; then
        echo -ne "\e[91mError...need to unload and load again\e[0m"
        modprobe -r -q bbswitch
        modprobe bbswitch load_state=0
        echo -ne "\e[93mCurrent state:\e[0m"
        cat /proc/acpi/bbswitch
fi
echo -e "\e[93mTurn off Nvidia video card... \e[1;92m[ OK ]\e[0m"
echo -ne "\e[93mAppend \"\e[94mbbswitch load_state=0\e[93m\" to \e[95m/etc/modules... \e[0m"
echo "bbswitch load_state=0" >> /etc/modules
echo -e "\e[1;92m[ OK ]\e[0m"
# Create blacklist for nouveau
echo -ne "\e[93mCreate nouveau-blacklist.conf for blacklist nouveau... \e[0m"
echo "blacklist nouveau" > /etc/modprobe.d/nouveau-blacklist.conf
echo -e "\e[1;92m[ OK ]\e[0m"

echo -e "\e[1;96m "
echo "***********************************************************************"
echo "*                        Install Nvidia Driver                        *"
echo "***********************************************************************"
echo -e " \e[0m"
# Install Nvidia driver
echo -e "\e[94mapt-get install nvidia-kernel-dkms nvidia-xconfig nvidia-settings\e[0m" 
apt-get -y install nvidia-kernel-dkms nvidia-xconfig nvidia-settings | grep "Setting" | sed 's/^/   /'
echo -e "\e[93mnvidia-kernel-dkms nvidia-xconfig nvidia-settings... \e[1;92m[ OK ]\e[0m"
echo -e "\e[94mapt-get install nvidia-vdpau-driver vdpau-va-driver mesa-utils\e[0m"
apt-get -y install nvidia-vdpau-driver vdpau-va-driver mesa-utils | grep "Setting" | sed 's/^/   /'
echo -e "\e[93mnvidia-vdpau-driver vdpau-va-driver mesa-utils... \e[1;92m[ OK ]\e[0m"

echo -e "\e[1;96m "
echo "***********************************************************************"
echo "*                          Install VirtualGL                          *"
echo "***********************************************************************"
echo -e " \e[0m"
echo -e "\e[93mInstall $(basename $LOC/virtualgl_*.deb) in $LOC\e[0m"
dpkg -i $LOC/virtualgl_*.deb | grep "Setting" | sed 's/^/   /'
echo -ne "\e[93mDelete $(basename $LOC/virtualgl_*.deb) after installation... \e[0m"
rm -f /root/Downloads/virtualgl_*.deb
echo -e "\e[1;92m[ OK ]\e[0m"

echo -e "\e[1;96m "
echo "***********************************************************************"
echo "*                          Install Bumblebee                          *"
echo "***********************************************************************"
echo -e " \e[0m"
# Install Bumblebee
echo -e "\e[93mInstall bumblebee-nvidia\e[0m"
apt-get -y install bumblebee-nvidia | grep "Setting" | sed 's/^/   /'
echo -e "\e[93mbumblebee-nvidia... \e[1;92m[ OK ]\e[0m"
echo -ne "\e[94musermod -aG bumblebee $USER... \e[0m"
usermod -aG bumblebee $USER
echo -e "\e[1;92m[ OK ]\e[0m"
echo -e "\e[93mInstall devscripts\e[0m"
apt-get -y install devscripts | grep "Setting" | sed 's/^/   /'
echo -e "\e[93mInstall devscripts... \e[1;92m[ OK ]\e[0m"
echo -e "\e[93mRecompile bumblebee from source\e[0m"
echo -e "\e[94mapt-get -y build-dep bumblebee\e[0m"
apt-get -y build-dep bumblebee | grep "Setting" | sed 's/^/   /'
echo -e "\e[94mapt-get source bumblebee\e[0m"
apt-get source bumblebee | grep "Setting" | sed 's/^/   /'
echo -e "\e[94msed -i 's/"Xorg"/"\/usr\/lib\/xorg\/Xorg"/'... \e[0m"
sed -i 's/"Xorg"/"\/usr\/lib\/xorg\/Xorg"/' bumblebee-3.2.1/src/bbsecondary.h
cd bumblebee-*
echo -e "\e[94mdpkg-buildpackage -us -uc -nc\e[0m"
dpkg-buildpackage -us -uc -nc > /dev/null
echo -e "\e[94mdpkg -i ../bumblebee_*.deb\e[0m"
dpkg -i ../bumblebee_*.deb | grep "Setting" | sed 's/^/   /'
echo -e "\e[93mRecompile bumblebee... \e[1;92m[ OK ]\e[0m"
echo -ne "\e[93mRetarting Bumblebee ..."
service bumblebeed restart
echo -e "\e[1;92m[ OK ]\e[0m"
# Cleanup bumblebee source
echo -e "\e[93mCleanning up bumblebee ...\e[0m"
cd ..
rm -rf bumblebee*
echo -e "\e[1;92mDeleted ...\e[0m"

echo -e "\e[1;96m "
echo "***********************************************************************"
echo "*                      Install Cuda Toolkits                          *"
echo "***********************************************************************"
echo -e " \e[0m"
# Export CUDA Path
echo -e "\e[93mexport PATH=$PATH:/opt/VirtualGL/bin:/usr/local/cuda-7.5/bin\e[0m"
echo "export PATH=$PATH:/opt/VirtualGL/bin:/usr/local/cuda-7.5/bin" >> ~/.bashrc
echo -e "\e[93mInstall $(basename $LOC/cuda_*.run)\e[0m"
chmod +x $LOC/cuda_*.run
$LOC/cuda_*.run --override compiler --silent --toolkit
echo -e "\e[93mCuda Toolkit... \e[1;92m[ OK ]\e[0m"
echo -e "\e[93mAdd "/usr/local/cuda-7.5/lib64" to /etc/ld.so.conf\e[0m"
echo "/usr/local/cuda-7.5/lib64" >> /etc/ld.so.conf
echo -ne "\e[93mldconfig... \e[0m"
ldconfig
echo -e "\e[1;92m[ OK ]\e[0m"
# Install libcuda1
echo -e "\e[93mInstall libcuda1\e[0m"
apt-get -y install libcuda1 | grep "Setting" | sed 's/^/   /'
echo -e "\e[93mlibcuda1... \e[1;92m[ OK ]\e[0m"
# Modified host_config
echo -e "\e[93mComment out line 115 to prevent error!\e[0m"
echo -ne "\e[94msed -i '115s/^/\/\//g' /usr/local/cuda/include/host_config.h... \e[0m"
sed -i '115s/^/\/\//g' /usr/local/cuda/include/host_config.h
echo -e "\e[1;92m[ OK ]\e[0m"

echo -e "\e[1;96m "
echo "***********************************************************************"
echo "*                           Install Pyrit                             *"
echo "***********************************************************************"
echo -e " \e[0m"
# Check svn exist
if ! which svn > /dev/null; then
	echo -e "\e[91msvn is not installed\e[0m"
	echo -e "\e[93mInstall Subversion\e[0m"
	apt-get -y install subversion | grep "Setting" | sed 's/^/   /'
	echo -e "\e[93mSubversion... \e[1;92m[ OK ]\e[0m"
fi

# Download from googlecode
echo -e "\e[93mDownload Pyrit from googlecode.com\e[0m"
svn checkout http://pyrit.googlecode.com/svn/trunk/ pyrit/ | grep "Checked" | sed 's/^/   /'

# Install Pyrit dependancy
echo -e "\e[93mInstall libssl-dev libpcap0.8-dev python-dev\e[0m"
apt-get -y install libssl-dev libpcap0.8-dev python-dev | grep "Setting" | sed 's/^/   /'
echo -e "\e[93mlibssl-dev libpcap0.8-dev python-dev... \e[1;92m[ OK ]\e[0m"

# Compile pyrit source
echo -e "\e[93mCompile Pyrit\e[0m"
cd pyrit/pyrit
echo -e "\e[94mpython setup.py build\e[0m"
python setup.py build | grep "Writing" | sed 's/^/   /'
echo -e "\e[94mpython setup.py install\e[0m"
python setup.py install | grep "Writing" | sed 's/^/   /'
echo -e "\e[93mPyrit... \e[1;92m[ OK ]\e[0m"

# Compile Cuda Pyrit source
echo -e "\e[93mCompile Cuda Pyrit\e[0m"
cd ../cpyrit_cuda
echo -e "\e[94mpython setup.py build\e[0m"
python setup.py build | grep "Writing" | sed 's/^/   /'
echo -e "\e[94mpython setup.py install\e[0m"
python setup.py install | grep "Writing" | sed 's/^/   /'
echo -e "\e[93mCPyrit... \e[1;92m[ OK ]\e[0m"

# Test pyrit list core
echo -e "\e[93mTesting Cuda Pyrit\e[0m"
echo -e "\e[94moptirun pyrit list_cores\e[0m"
optirun pyrit list_cores

# Clean up Pyrit
echo -ne "\e[93mDeleting Pyrit directory\e[0m"
cd ../../
rm -rf pyrit
echo -e "\e[1;92m[ OK ]\e[0m"

echo -e "\e[1;93mAutomate Installation has Completed!!\e[0m"
