#!/bin/bash

CMD="$DEVICE"
EXTRACMD="$EXTRACMD"
EXTRABUILD="$EXTRABUILD"
A_TOP=${PWD}/workspace
CUR_DIR=`dirname $0`
DATE=$(date +%D)
MACHINE_TYPE=`uname -m`
branch="$REPO_BRANCH"
version ="$RECOVERY_VERSION"
RELEASE_TYPE="$RELEASE_TYPE"

if [ -z "$DEVICE" ]
then
  echo DEVICE not specified
  exit 1
fi


if [ -z "$REPO_BRANCH" ]
then
  echo REPO_BRANCH not specified
  exit 1
fi


# Common defines (Arch-dependent)
case `uname -s` in
    Darwin)
        txtrst='\033[0m'  # Color off
        txtred='\033[0;31m' # Red
        txtgrn='\033[0;32m' # Green
        txtylw='\033[0;33m' # Yellow
        txtblu='\033[0;34m' # Blue
        THREADS=`sysctl -an hw.logicalcpu`
        ;;
    *)
        txtrst='\e[0m'  # Color off
        txtred='\e[0;31m' # Red
        txtgrn='\e[0;32m' # Green
        txtylw='\e[0;33m' # Yellow
        txtblu='\e[0;34m' # Blue
        THREADS=`cat /proc/cpuinfo | grep processor | wc -l`
        ;;
esac

check_root() {
    if [ ! $( id -u ) -eq 0 ]; then
        echo -e "${txtred}Please run this script as root."
        echo -e "\r\n ${txtrst}"
        exit
    fi
}

check_machine_type() {
    echo "Checking machine architecture..."
    if [ ${MACHINE_TYPE} == 'x86_64' ]; then
        echo -e "${txtgrn}Detected: ${MACHINE_TYPE}. Good!"
        echo -e "\r\n ${txtrst}"
    else
        echo -e "${txtred}Detected: ${MACHINE_TYPE}. Bad!"
        echo -e "${txtred}Sorry, we do only support building on 64-bit machines."
        echo -e "${txtred}32-bit is soooo 1970, consider a upgrade. ;-)"
        echo -e "\r\n ${txtrst}"
        exit
    fi
}

install_sun_jdk()
{
    add-apt-repository "deb http://archive.canonical.com/ lucid partner"
    apt-get update
    apt-get install sun-java6-jdk
}

install_arch_packages()
{
    # x86_64
    pacman -S jdk7-openjdk jre7-openjdk jre7-openjdk-headless perl git gnupg flex bison gperf zip unzip lzop sdl wxgtk \
    squashfs-tools ncurses libpng zlib libusb libusb-compat readline schedtool \
    optipng python2 perl-switch lib32-zlib lib32-ncurses lib32-readline \
    gcc-libs-multilib gcc-multilib lib32-gcc-libs binutils-multilib libtool-multilib
}

install_ubuntu_packages()
{
    # x86_64
    apt-get install git-core gnupg flex bison gperf build-essential \
    zip curl libc6-dev libncurses5-dev:i386 x11proto-core-dev \
    libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 \
    libgl1-mesa-dev g++-multilib mingw32 openjdk-6-jdk tofrodos \
    python-markdown libxml2-utils xsltproc zlib1g-dev:i386 pngcrush
}

prepare_environment()
{
    echo "Which 64-bit distribution are you running?"
    echo "1) Ubuntu 11.04"
    echo "2) Ubuntu 11.10"
    echo "3) Ubuntu 12.04"
    echo "4) Ubuntu 12.10"
    echo "5) Arch Linux"
    echo "6) Debian"
    read -n1 distribution
    echo -e "\r\n"

    case $distribution in
    "1")
        # Ubuntu 11.04
        echo "Installing packages for Ubuntu 11.04"
        install_sun_jdk
        apt-get install git-core gnupg flex bison gperf build-essential \
        zip curl zlib1g-dev libc6-dev lib32ncurses5-dev ia32-libs \
        x11proto-core-dev libx11-dev lib32readline5-dev lib32z-dev \
        libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown \
        libxml2-utils xsltproc libx11-dev:i386
        ;;
    "2")
        # Ubuntu 11.10
        echo "Installing packages for Ubuntu 11.10"
        install_sun_jdk
        apt-get install git-core gnupg flex bison gperf build-essential \
        zip curl zlib1g-dev libc6-dev lib32ncurses5-dev ia32-libs \
        x11proto-core-dev libx11-dev lib32readline5-dev lib32z-dev \
        libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown \
        libxml2-utils xsltproc libx11-dev:i386
        ;;
    "3")
        # Ubuntu 12.04
        echo "Installing packages for Ubuntu 12.04"
        install_ubuntu_packages
        ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so
        ;;
    "4")
        # Ubuntu 12.10
        echo "Installing packages for Ubuntu 12.10"
        install_ubuntu_packages
        ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so
        ;;
    "5")
        # Arch Linux
        echo "Installing packages for Arch Linux"
        install_arch_packages
        mv /usr/bin/python /usr/bin/python.bak
        ln -s /usr/bin/python2 /usr/bin/python
        ;;
    "6")
        # Debian
        echo "Installing packages for Debian"
        apt-get update
        apt-get install git-core gnupg flex bison gperf build-essential \
        zip curl libc6-dev lib32ncurses5 libncurses5-dev x11proto-core-dev \
        libx11-dev libreadline6-dev lib32readline-gplv2-dev libgl1-mesa-glx \
        libgl1-mesa-dev g++-multilib mingw32 openjdk-6-jdk tofrodos \
        python-markdown libxml2-utils xsltproc zlib1g-dev pngcrush \
        libcurl4-gnutls-dev comerr-dev krb5-multidev libcurl4-gnutls-dev \
        libgcrypt11-dev libglib2.0-dev libgnutls-dev libgnutls-openssl27 \
        libgnutlsxx27 libgpg-error-dev libgssrpc4 libgstreamer-plugins-base0.10-dev \
        libgstreamer0.10-dev libidn11-dev libkadm5clnt-mit8 libkadm5srv-mit8 \
        libkdb5-6 libkrb5-dev libldap2-dev libp11-kit-dev librtmp-dev libtasn1-3-dev \
        libxml2-dev tofrodos python-markdown lib32z-dev ia32-libs
        ln -s /usr/lib32/libX11.so.6 /usr/lib32/libX11.so
        ln -s /usr/lib32/libGL.so.1 /usr/lib32/libGL.so
        ;;

    *)
        # No distribution
        echo -e "${txtred}No distribution set. Aborting."
        echo -e "\r\n ${txtrst}"
        exit
        ;;
    esac

echo "Target Directory ("$A_TOP"/cm-builds/"$branch"):"
read working_directory
if [ ! -n $working_directory ]; then
    working_directory=""$A_TOP"/cm-builds/"$branch""
fi

echo "Installing to $working_directory"
mkdir ~/bin
export PATH=~/bin:$PATH
curl https://dl-ssl.google.com/dl/googlesource/git-repo/repo > ~/bin/repo
chmod a+x ~/bin/repo
source ~/.profile
repo selfupdate

# Configure Git
if [ -z ${BUILD_USER_ID} ]; then
  export BUILD_USER_ID=$(whoami)
fi

git config --global user.name $BUILD_USER_ID
git config --global user.email wimpknocker@hotmail.com

mkdir -P $A_TOP
cd $A_TOP

if [ ! -d buildscripts ];
  then
    git clone git://github.com/wimpknocker/buildscripts.git
    cd buildscripts
## Get rid of possible local changes
    git reset --hard
    git pull -s resolve
fi

mkdir -p $working_directory
cd $working_directory
repo init -u git://github.com/CyanogenMod/android.git -b $branch
mkdir -p $working_directory/.repo/local_manifests
touch $working_directory/.repo/local_manifests/${CMD}-${branch}_manifest.xml
curl https://raw.github.com/wimpknocker/buildscripts/${CMD}/${branch}_manifest.xml > $working_directory/.repo/local_manifests/${CMD}-${branch}_manifest.xml
repo sync -j15
echo "Sources synced to $working_directory"

# Archive
mkdir -p ${A_TOP}/archive
export BUILD_NO=$BUILD_NUMBER
unset BUILD_NUMBER

# Make Ota Dirs
OTA_WIMPNETHER_NET_DEVICE=~/otaupdate/full_builds/$DEVICE
OTA_WIMPNETHER_NET_DELTAS=~/otaupdate/nightlies/$DEVICE
OTA_WIMPNETHER_NET_DEVICE_KERNEL=~/otaupdate/full_builds/$DEVICE/kernel
OTA_WIMPNETHER_NET_DEVICE_BLACKHAWK=~/otaupdate/full_builds/$DEVICE/blackhawk
OTA_WIMPNETHER_NET_DEVICE_RECOVERY=~/otaupdate/full_builds/$DEVICE/recovery

mkdir -p $OTA_WIMPNETHER_NET_DEVICE
mkdir -p $OTA_WIMPNETHER_NET_DELTAS
mkdir -p $OTA_WIMPNETHER_NET_DEVICE_KERNEL
mkdir -p $OTA_WIMPNETHER_NET_DEVICE_BLACKHAWK
mkdir -p $OTA_WIMPNETHER_NET_DEVICE_RECOVERY

# create kernel zip
create_kernel_zip()
{
    echo -e "${txtgrn}Creating kernel zip...${txtrst}"
    if [ -e ${ANDROID_PRODUCT_OUT}/boot.img ]; then
        echo -e "${txtgrn}Bootimage found...${txtrst}"
        if [ -e ${A_TOP}/buildscripts/${CMD}/kernel_updater-script ]; then

            echo -e "${txtylw}Package KERNELUPDATE:${txtrst} out/target/product/${CMD}/kernel-${branch}-$(date +%Y%m%d)-${CMD}-signed.zip"
            cd ${ANDROID_PRODUCT_OUT}

            rm -rf kernel_zip
            rm kernel-${branch}-*

            mkdir -p kernel_zip/META-INF/com/google/android

            echo "Copying boot.img..."
            cp boot.img kernel_zip/

            echo "Copying update-binary..."
            cp obj/EXECUTABLES/updater_intermediates/updater kernel_zip/META-INF/com/google/android/update-binary

            echo "Copying updater-script..."

                 cat ${A_TOP}/buildscripts/${CMD}/kernel_updater-script > kernel_zip/META-INF/com/google/android/updater-script

                 echo "Zipping package..."
                 cd kernel_zip
                 zip -qr ../kernel-${branch}-$(date +%Y%m%d)-${CMD}.zip ./
                 cd ${ANDROID_PRODUCT_OUT}

            echo "Signing package..."
                 java -jar ${ANDROID_HOST_OUT}/framework/signapk.jar ${A_TOP}/build/target/product/security/testkey.x509.pem ${A_TOP}/build/target/product/security/testkey.pk8 kernel-cm-${CM_VERSION}-$(date +%Y%m%d)-${CMD}.zip kernel-cm-${CM_VERSION}-$(date +%Y%m%d)-${CMD}-signed.zip
                 rm kernel-cm-${CM_VERSION}-$(date +%Y%m%d)-${CMD}.zip

                 echo -e "${txtgrn}Package complete:${txtrst} out/target/product/${CMD}/kernel-cm-${CM_VERSION}-$(date +%Y%m%d)-${CMD}-signed.zip"
                 md5sum kernel-cm-${CM_VERSION}-$(date +%Y%m%d)-${CMD}-signed.zip > kernel-cm-${CM_VERSION}-$(date +%Y%m%d)-${CMD}-signed.zip.md5sum
                 cp kernel-cm-${CM_VERSION}-$(date +%Y%m%d)-${CMD}-signed.zip $OTA_WIMPNETHER_NET_DEVICE_KERNEL
                 cp kernel-cm-${CM_VERSION}-$(date +%Y%m%d)-${CMD}-signed.zip.md5sum $OTA_WIMPNETHER_NET_DEVICE_KERNEL
                 cd ${A_TOP}
        else
            echo -e "${txtred}No instructions to create out/target/product/${CMD}/kernel-cm-${CM_VERSION}-$(date +%Y%m%d)-${CMD}-signed.zip... skipping."
            echo -e "\r\n ${txtrst}"
        fi
    else
        echo -e "${txtred}Bootimage not found... skipping."
        echo -e "\r\n ${txtrst}"
    fi
}

create_blackhawk_kernel_zip()
{
   echo -e "${txtgrn}Creating blackhawk kernel zip...${txtrst}"
    if [ -e ${ANDROID_PRODUCT_OUT}/boot.img ]; then
        echo -e "${txtgrn}Bootimage found...${txtrst}"
        if [ -e ${A_TOP}/buildscripts/${CMD}/blackhawk_kernel_updater-script ]; then

            echo -e "${txtylw}Package BLACKHAWKUPDATE:${txtrst} out/target/product/${CMD}/blackhawk-next-kernel-${version}-${CMD}-signed.zip"
            cd ${ANDROID_PRODUCT_OUT}

            rm -rf kernel_zip
            rm kernel-${branch}-*
            rm blackhawk-next-kernel*
            mkdir -p kernel_zip/META-INF/com/google/android

            echo "Unpack boot.img.."
              unpackbootimg -i boot.img  -o boot_img
              cd boot_img
              rm *ramdisk*

            echo "Building blackhawk"
              git clone https://github.com/wimpknocker/android_dualboot.git -b ${CMD} ramdisk
              cd ramdisk/ramdisk
              find . | cpio -o -H newc | gzip > ../../blackhawk-ramdisk.cpio.gz
              cd ../..
              mkbootimg --kernel *-kernel --ramdisk blackhawk-ramdisk.cpio.gz --cmdline *-cmdline --base *-base --pagesize *-pagesize -o ../kernel_zip/boot.img

            echo "Copying updater-script..."
              cat ${A_TOP}/buildscripts/${CMD}/blackhawk_kernel_updater-script > kernel_zip/META-INF/com/google/android/updater-script

            echo "Zipping package..."
              cd kernel_zip
              zip -qr ../blackhawk-next-kernel-${version}-${CMD}.zip ./
              cd ${ANDROID_PRODUCT_OUT}

            echo "Signing package..."
              java -jar ${ANDROID_HOST_OUT}/framework/signapk.jar ${A_TOP}/build/target/product/security/testkey.x509.pem ${A_TOP}/build/target/product/security/testkey.pk8 blackhawk-next-kernel-${version}-${CMD}.zip blackhawk-next-kernel-${version}-${CMD}-signed.zip
              rm blackhawk-next-kernel-${version}-${CMD}.zip

            echo -e "${txtgrn}Package complete:${txtrst} out/target/product/${CMD}/blackhawk-next-kernel-${version}-${CMD}-signed.zip"
              md5sum blackhawk-next-kernel-${version}-${CMD}-signed.zip > blackhawk-next-kernel-${version}-${CMD}-signed.zip.md5sum
              cp blackhawk-next-kernel-${version}-${CMD}-signed.zip $OTA_WIMPNETHER_NET_DEVICE_BLACKHAWK
              cp blackhawk-next-kernel-${version}-${CMD}-signed.zip.md5sum $OTA_WIMPNETHER_NET_DEVICE_BLACKHAWK
              cd ${A_TOP}
        else
            echo -e "${txtred}No instructions to create out/target/product/${CMD}/blackhawk-next-kernel-${version}-${CMD}-signed.zip... skipping."
            echo -e "\r\n ${txtrst}"
        fi
    else
        echo -e "${txtred}Bootimage not found... skipping."
        echo -e "\r\n ${txtrst}"
    fi
}

create_blackhawk_recovery_zip()
{
   echo -e "${txtgrn}Creating blackhawk recovery zip...${txtrst}"
    if [ -e ${ANDROID_PRODUCT_OUT}/blackhawk-recovery.img ]; then
        echo -e "${txtgrn}recoveryimage found...${txtrst}"
        if [ -e ${A_TOP}/buildscripts/${CMD}/blackhawk_recovery_updater-script ]; then

            echo -e "${txtylw}Package BLACKHAWKUPDATE:${txtrst} out/target/product/${CMD}/PhilZ-Touch-Recovery_${PHILZ_BUILD}-blackhawk-${CMD}.zip"
              cd ${ANDROID_PRODUCT_OUT}
              rm -rf recovery_zip
              rm PhilZ-Touch-Recovery*

            mkdir -p recovery_zip/META-INF/com/google/android

            echo "Copying recovery image..."
              cp blackhawk-recovery.img recovery_zip/blackhawk-recovery.img

            echo "Copying updater-script..."
              cat ${A_TOP}/buildscripts/${CMD}/blackhawk_recovery_updater-script > recovery_zip/META-INF/com/google/android/updater-script

            echo "Zipping package..."
              cd recovery_zip
              zip -qr ../PhilZ-Touch-Recovery_${PHILZ_BUILD}-blackhawk-${CMD}.zip ./
              cd ${ANDROID_PRODUCT_OUT}
              md5sum PhilZ-Touch-Recovery_${PHILZ_BUILD}-blackhawk-${CMD}.zip > PhilZ-Touch-Recovery_${PHILZ_BUILD}-blackhawk-${CMD}.zip.md5sum
              cp PhilZ-Touch-Recovery_${PHILZ_BUILD}-blackhawk-${CMD}.zip $OTA_WIMPNETHER_NET_DEVICE_BLACKHAWK
              cp PhilZ-Touch-Recovery_${PHILZ_BUILD}-blackhawk-${CMD}.zip.md5sum $OTA_WIMPNETHER_NET_DEVICE_BLACKHAWK

        else
            echo -e "${txtred}No instructions to create out/target/product/${CMD}/PhilZ-Touch-Recovery_${PHILZ_BUILD}-blackhawk-${CMD}.zip... skipping."
            echo -e "\r\n ${txtrst}"
        fi
    else
        echo -e "${txtred}recoveryimage not found... skipping."
        echo -e "\r\n ${txtrst}"
    fi
}

# Check for build target
if [ -z "${CMD}" ]; then
	echo -e "${txtred}No build target set."
	echo -e "${txtred}Usage: ./build.sh skomer (complete build)"
	echo -e "${txtred}       ./build.sh skomer kernel (bootimage only)"
        echo -e "${txtred}       ./build.sh skomer recovery (recovery only)"
        echo -e "${txtred}       ./build.sh skomer blackhawk-kernel (blackhawk bootimage only)"
        echo -e "${txtred}       ./build.sh skomer blackhawk-recovery (blackhawk recoveryimage only)"
	echo -e "${txtred}       ./build.sh clean (make clean)"
    echo -e "${txtred}       ./build.sh clobber (make clober, wipes entire out/ directory)"
    echo -e "${txtred}       ./build.sh prepare (prepares the build environment)"
    echo -e "\r\n ${txtrst}"
    exit
fi

# Starting Timer
START=$(date +%s)

case "$EXTRACMD" in
    eng)
		BUILD_TYPE=eng
		;;
    userdebug)
		BUILD_TYPE=userdebug
		;;
    *)
		BUILD_TYPE=userdebug
		;;
esac

# Device specific settings
case "$CMD" in
    prepare)
        check_root
        check_machine_type
        prepare_environment
        exit
        ;;
    clean)
        make clean
        rm -rf ./out/target/product
        exit
        ;;
    clobber)
        make clobber
        exit
        ;;
    *)
        lunch=cm_${CMD}-${BUILD_TYPE}
        brunch=${lunch}
        ;;
esac

# create env.sh if it doesn't exist
if [ ! -f $CUR_DIR/env.sh ]; then
    echo "export USE_CCACHE=1" > env.sh
fi

# create empty patches.txt if it doesn't exist
if [ ! -f $CUR_DIR/patches.txt ]; then
    touch patches.txt
fi

# Setting up Build Environment
echo -e "${txtgrn}Setting up Build Environment...${txtrst}"
. build/envsetup.sh
lunch ${lunch}

# Allow setting of additional flags
if [ -f $CUR_DIR/env.sh ]; then
    source $CUR_DIR/env.sh
fi

# fix module copy for archlinux
mkdir -p ${ANDROID_PRODUCT_OUT}/system/lib
mkdir -p ${ANDROID_PRODUCT_OUT}/system/usr
cd ${ANDROID_PRODUCT_OUT}/system/usr
ln -sf ../lib .
cd -

# Apply gerrit changes from patches.txt. One change-id per line!
if [ -f $CUR_DIR/patches.txt ]; then
    while read line; do
        GERRIT_CHANGES+="$line "
    done < patches.txt

    if [[ ! -z ${GERRIT_CHANGES} && ! ${GERRIT_CHANGES} == " " ]]; then
        echo -e "${txtylw}Applying patches...${txtrst}"
        python ${working_directory}/build/tools/repopick.py $GERRIT_CHANGES --ignore-missing --start-branch auto --abandon-first
        echo -e "${txtgrn}Patches applied!${txtrst}"
    fi
fi

# Modified Updater Server
echo "Modified Updater Server"
source ${A_TOP}/buildscripts/updater-server.sh

# Release type for succesfull build
case "$RELEASE_TYPE" in
    cm_nigthly)
        export cm_nigthly=true
    ;;

    cm_experimental)
       export cm_experimental=true
    ;;

    cm_release)
       export cm_release=true
    ;;

    *)
    echo -e "Release type not specified"
    exit 1
    ;;

esac

rm -f ${A_TOP}/changecount
WORKSPACE=${working_directory} LUNCH=${lunch} bash ${A_TOP}/buildscripts/changes/buildlog.sh 2>&1
if [ -f ${A_TOP}/changecount ]
then
  CHANGE_COUNT=$(cat ${A_TOP}/changecount)
  rm -f ${A_TOP}/changecount
  if [ $CHANGE_COUNT -eq "0" ]
  then
    echo "Zero changes since last build, aborting"
    exit 1
  fi
fi

# Start the Build
case "$EXTRABUILD" in
    kernel)
        echo -e "${txtgrn}Rebuilding bootimage...${txtrst}"

        rm -rf ${ANDROID_PRODUCT_OUT}/kernel_zip
        rm ${ANDROID_PRODUCT_OUT}/kernel
        rm ${ANDROID_PRODUCT_OUT}/boot.img
        rm -rf ${ANDROID_PRODUCT_OUT}/root
        rm -rf ${ANDROID_PRODUCT_OUT}/ramdisk*
        rm -rf ${ANDROID_PRODUCT_OUT}/combined*

        mka bootimage
        if [ ! -e ${ANDROID_PRODUCT_OUT}/obj/EXECUTABLES/updater_intermediates/updater ]; then
        	mka updater
        fi
        if [ ! -e ${ANDROID_HOST_OUT}/framework/signapk.jar ]; then
            mka signapk
        fi
        create_kernel_zip
        ;;

    blackhawk-kernel)
        echo -e "${txtgrn}Rebuilding bootimage with blackhawk support...${txtrst}"

        rm -rf ${ANDROID_PRODUCT_OUT}/kernel_zip
        rm ${ANDROID_PRODUCT_OUT}/kernel
        rm ${ANDROID_PRODUCT_OUT}/boot.img
        rm ${ANDROID_PRODUCT_OUT}/recovery.img
        rm -rf ${ANDROID_PRODUCT_OUT}/root
        rm -rf ${ANDROID_PRODUCT_OUT}/ramdisk*
        rm -rf ${ANDROID_PRODUCT_OUT}/combined*

        mka bootimage
        if [ ! -e ${ANDROID_HOST_OUT}/linux-x86/bin/unpackbootimg ]; then
                mka unpackbootimg
        fi
        if [ ! -e ${ANDROID_PRODUCT_OUT}/obj/EXECUTABLES/updater_intermediates/updater ]; then
                mka updater
        fi
        if [ ! -e ${ANDROID_HOST_OUT}/framework/signapk.jar ]; then
                mka signapk
        fi

        create_blackhawk_kernel_zip
        ;;

    recovery)
        echo -e "${txtgrn}Rebuilding recoveryimage...${txtrst}"

        rm -rf ${ANDROID_PRODUCT_OUT}/obj/KERNEL_OBJ
        rm ${ANDROID_PRODUCT_OUT}/kernel
        rm ${ANDROID_PRODUCT_OUT}/recovery.img
        rm ${ANDROID_PRODUCT_OUT}/recovery
        rm -rf ${ANDROID_PRODUCT_OUT}/ramdisk*

        mka ${ANDROID_PRODUCT_OUT}/recovery.img
        cp recovery.img $OTA_WIMPNETHER_NET_DEVICE_RECOVERY/recovery-CWM-${RECOVERY_VERSION}-$(date +%Y%m%d)-${CMD}.img
        ;;

    blackhawk-recovery)
        echo -e "${txtgrn}Rebuilding recoveryimage with blackhawk support...${txtrst}"

        rm -rf ${ANDROID_PRODUCT_OUT}/obj/KERNEL_OBJ
        rm ${ANDROID_PRODUCT_OUT}/kernel
        rm ${ANDROID_PRODUCT_OUT}/recovery.img
        rm ${ANDROID_PRODUCT_OUT}/recovery
        rm -rf ${ANDROID_PRODUCT_OUT}/ramdisk*

        export RECOVERY_VARIANT=philz

        mka ${ANDROID_PRODUCT_OUT}/blackhawk-recovery.img
        if [ ! -e ${ANDROID_PRODUCT_OUT}/obj/EXECUTABLES/updater_intermediates/updater ]; then
                mka updater
        fi

        create_blackhawk_recovery_zip
        ;;

    *)
        echo -e "${txtgrn}Building Android...${txtrst}"
        brunch ${brunch}
        ;;
esac

# Start sign build
echo -e "${txtgrn}Start Signing build...${txtrst}"
if [ ! -e ${ANDROID_PRODUCT_OUT}/cm-* ]; then
    echo "Unable to find target files to sign"
    exit 1
  fi

#Opendelta
echo -e "Signing zip"

BIN_JAVA=java
BIN_MINSIGNAPK=${ANDROID_HOST_OUT}/bin/minsignapk.jar
BIN_XDELTA=${ANDROID_HOST_OUT}/bin/xdelta3
BIN_ZIPADJUST=${ANDROID_HOST_OUT}/bin/zipadjust

FILE_MATCH=cm-*.zip
PATH_CURRENT=${ANDROID_PRODUCT_OUT}
PATH_LAST=$A_TOP/archive

KEY_X509=$working_directory/build/target/product/security/platform.x509.pem
KEY_PK8=$working_directory/build/target/product/security/platform.pk8

# Check and get needed files
if [ ! -e ${ANDROID_HOST_OUT}/bin/minsignapk.jar ]; then
    wget https://raw.github.com/omnirom/android_packages_apps_OpenDelta/android-5.1/server/minsignapk.jar -o ${ANDROID_HOST_OUT}/bin/minsignapk.jar
fi
if [ ! -e ${ANDROID_HOST_OUT}/bin/xdelta3 ]; then
    mkdir $A_TOP/temp
    cd $A_TOP/temp
    svn checkout https://github.com/omnirom/android_packages_apps_OpenDelta/trunk/jni install
    cd install/xdelta3-3.0.7
    ./configure
    make
    cp xdelta3 ${ANDROID_HOST_OUT}/bin/xdelta3
fi
if [ ! -e ${ANDROID_HOST_OUT}/bin/zipadjust ]; then
    cd $A_TOP/temp/install
    gcc -o zipadjust zipadjust.c zipadjust_run.c -lz
    cp zipadjust ${ANDROID_HOST_OUT}/bin/zipadjust
fi

# Remove Temp folder
rm -rf $A_TOP/temp

# ------ PROCESS ------
getFileName() {
	echo ${1##*/}
}

getFileNameNoExt() {
	echo ${1%.*}
}

getFileMD5() {
	TEMP=$(md5sum -b $1)
	for T in $TEMP; do echo $T; break; done
}

getFileSize() {
	echo $(stat --print "%s" $1)
}

FILE_CURRENT=$(getFileName $(ls -1 $PATH_CURRENT/$FILE_MATCH))
FILE_LAST=$(getFileName $(ls -1 $PATH_LAST/$FILE_MATCH))
FILE_LAST_BASE=$(getFileNameNoExt $FILE_LAST)

rm -rf work
mkdir work
rm -rf out
mkdir out

MODVERSION=$(cat ${ANDROID_PRODUCT_OUT}/system/build.prop | grep ro.cm.version | cut -d = -f 2)
SDKVERSION=$(cat ${ANDROID_PRODUCT_OUT}/system/build.prop | grep ro.build.version.sdk | cut -d = -f 2)
if [ ! -z "$MODVERSION" -a -f ${ANDROID_PRODUCT_OUT}/obj/PACKAGING/target_files_intermediates/$TARGET_PRODUCT-target_files-$BUILD_NUMBER.zip ]
  then
    misc_info_txt=${ANDROID_PRODUCT_OUT}/obj/PACKAGING/target_files_intermediates/$TARGET_PRODUCT-target_files-$BUILD_NUMBER/META/misc_info.txt
    function get_meta_val {
        echo $(cat $misc_info_txt | grep ${1} | cut -d = -f 2)
    }
    minigzip=$(get_meta_val "minigzip")
    if [ ! -z "$minigzip" ]
    then
        export MINIGZIP="$minigzip"
    fi
fi

$BIN_ZIPADJUST --decompress $PATH_CURRENT/$FILE_CURRENT work/current.zip
$BIN_ZIPADJUST --decompress $PATH_LAST/$FILE_LAST work/last.zip
$BIN_JAVA -Xmx1024m -jar $BIN_MINSIGNAPK $KEY_X509 $KEY_PK8 work/current.zip work/current_signed.zip
$BIN_JAVA -Xmx1024m -jar $BIN_MINSIGNAPK $KEY_X509 $KEY_PK8 work/last.zip work/last_signed.zip
$BIN_XDELTA -9evfS none -s work/last.zip work/current.zip out/$FILE_LAST_BASE.update
$BIN_XDELTA -9evfS none -s work/current.zip work/current_signed.zip out/$FILE_LAST_BASE.sign

MD5_CURRENT=$(getFileMD5 $PATH_CURRENT/$FILE_CURRENT)
MD5_CURRENT_STORE=$(getFileMD5 work/current.zip)
MD5_CURRENT_STORE_SIGNED=$(getFileMD5 work/current_signed.zip)
MD5_LAST=$(getFileMD5 $PATH_LAST/$FILE_LAST)
MD5_LAST_STORE=$(getFileMD5 work/last.zip)
MD5_LAST_STORE_SIGNED=$(getFileMD5 work/last_signed.zip)
MD5_UPDATE=$(getFileMD5 out/$FILE_LAST_BASE.update)
MD5_SIGN=$(getFileMD5 out/$FILE_LAST_BASE.sign)

SIZE_CURRENT=$(getFileSize $PATH_CURRENT/$FILE_CURRENT)
SIZE_CURRENT_STORE=$(getFileSize work/current.zip)
SIZE_CURRENT_STORE_SIGNED=$(getFileSize work/current_signed.zip)
SIZE_LAST=$(getFileSize $PATH_LAST/$FILE_LAST)
SIZE_LAST_STORE=$(getFileSize work/last.zip)
SIZE_LAST_STORE_SIGNED=$(getFileSize work/last_signed.zip)
SIZE_UPDATE=$(getFileSize out/$FILE_LAST_BASE.update)
SIZE_SIGN=$(getFileSize out/$FILE_LAST_BASE.sign)

DELTA=out/$FILE_LAST_BASE.delta

echo "{" > $DELTA
echo "  \"version\": 1," >> $DELTA
echo "  \"in\": {" >> $DELTA
echo "      \"name\": \"$FILE_LAST\"," >> $DELTA
echo "      \"size_store\": $SIZE_LAST_STORE," >> $DELTA
echo "      \"size_store_signed\": $SIZE_LAST_STORE_SIGNED," >> $DELTA
echo "      \"size_official\": $SIZE_LAST," >> $DELTA
echo "      \"md5_store\": \"$MD5_LAST_STORE\"," >> $DELTA
echo "      \"md5_store_signed\": \"$MD5_LAST_STORE_SIGNED\"," >> $DELTA
echo "      \"md5_official\": \"$MD5_LAST\"" >> $DELTA
echo "  }," >> $DELTA
echo "  \"update\": {" >> $DELTA
echo "      \"name\": \"$FILE_LAST_BASE.update\"," >> $DELTA
echo "      \"size\": $SIZE_UPDATE," >> $DELTA
echo "      \"size_applied\": $SIZE_CURRENT_STORE," >> $DELTA
echo "      \"md5\": \"$MD5_UPDATE\"," >> $DELTA
echo "      \"md5_applied\": \"$MD5_CURRENT_STORE\"" >> $DELTA
echo "  }," >> $DELTA
echo "  \"signature\": {" >> $DELTA
echo "      \"name\": \"$FILE_LAST_BASE.sign\"," >> $DELTA
echo "      \"size\": $SIZE_SIGN," >> $DELTA
echo "      \"size_applied\": $SIZE_CURRENT_STORE_SIGNED," >> $DELTA
echo "      \"md5\": \"$MD5_SIGN\"," >> $DELTA
echo "      \"md5_applied\": \"$MD5_CURRENT_STORE_SIGNED\"" >> $DELTA
echo "  }," >> $DELTA
echo "  \"out\": {" >> $DELTA
echo "      \"name\": \"$FILE_CURRENT\"," >> $DELTA
echo "      \"size_store\": $SIZE_CURRENT_STORE," >> $DELTA
echo "      \"size_store_signed\": $SIZE_CURRENT_STORE_SIGNED," >> $DELTA
echo "      \"size_official\": $SIZE_CURRENT," >> $DELTA
echo "      \"md5_store\": \"$MD5_CURRENT_STORE\"," >> $DELTA
echo "      \"md5_store_signed\": \"$MD5_CURRENT_STORE_SIGNED\"," >> $DELTA
echo "      \"md5_official\": \"$MD5_CURRENT\"" >> $DELTA
echo "  }" >> $DELTA
echo "}" >> $DELTA

echo -e "Signing Done!"

# file name conflict
function getFileName() {
    echo ${1##*/}
}

if [ "$RELEASE_TYPE" = "CM_RELEASE" ]
    then
      OTA_WIMPNETHER_NET_DEVICE="$OTA_WIMPNETHER_NET_DEVICE"
    else
      # Remove older nightlies and deltas
      find $OTA_WIMPNETHER_NET_DEVICE -name "cm-*" -type f -mtime +63 -delete
      find $OTA_WIMPNETHER_NET_DELTAS -name "*.delta" -type f -mtime +70 -delete
fi

# Full zips
for f in $(ls ${ANDROID_PRODUCT_OUT}/cm-*.zip*)
do
  cp $f $A_TOP/archive/cm-$MODVERSION.zip
done

CM_ZIP=
for f in $(ls $A_TOP/archive/cm-*.zip)
do
  CM_ZIP=$(basename $f)
done
if [ -f $OTA_WIMPNETHER_NET_DEVICE/$CM_ZIP ]
    then
      echo "File $CM_ZIP exists on ota.wimpnether.net"
      make clobber >/dev/null
      rm -fr $OUT
      exit 1
fi

# Copying signed ota files
cp out/* $OTA_WIMPNETHER_NET_DELTAS/.

# changelog
cp $A_TOP/archive/CHANGES.txt $OTA_WIMPNETHER_NET_DEVICE/cm-$MODVERSION.txt

# /archive
for f in $(ls $A_TOP/archive/cm-*.zip*)
do
    cp $f $OTA_WIMPNETHER_NET_DEVICE
done

rm -rf work
rm -rf out


END=$(date +%s)
ELAPSED=$((END - START))
E_MIN=$((ELAPSED / 60))
E_SEC=$((ELAPSED - E_MIN * 60))
printf "${txtgrn}Elapsed: "
[ $E_MIN != 0 ] && printf "%d min(s) " $E_MIN
printf "%d sec(s)\n ${txtrst}" $E_SEC

# Postbuild script for uploading builds
if [ -f ${A_TOP}/buildscripts/postbuild.sh ]; then
    source ${A_TOP}/buildscripts/postbuild.sh
fi

