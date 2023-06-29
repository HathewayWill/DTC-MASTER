#!/bin/bash

start=`date`
START=$(date +"%s")


############################### System Architecture Type #################
# 32 or 64 bit
##########################################################################


export SYS_ARCH=$(uname -m)


if [ "$SYS_ARCH" = "x86_64" ]; then
  export SYSTEMBIT="64"
else
  export SYSTEMBIT="32"
fi


############################# System OS Version #############################
# Macos or linux
# Make note that this script only works for Debian Linux kernals
#############################################################################
export SYS_OS=$(uname -s)

if [ "$SYS_OS" = "Darwin" ]; then
  export SYSTEMOS="MacOS"
elif [ "$SYS_OS" = "Linux" ]; then
  export SYSTEMOS="Linux"
fi


############################### Intel or GNU Compiler Option #############



if [ "$SYSTEMBIT" = "32" ] && [ "$SYSTEMOS" = "MacOS" ]; then
  echo "Your system is not compatibile with this script."
  exit ;
fi

if [ "$SYSTEMBIT" = "64" ] && [ "$SYSTEMOS" = "MacOS" ]; then
  echo "Your system is a 64bit version of MacOS"
  echo " "
  echo "Intel compilers are not compatibile with this script"
  echo " "
  echo "Setting compiler to GNU"
  export macos_64bit_GNU=1
  echo " "
  echo "Xcode Command Line Tools & Homebrew are required for this script."
  echo " "
  echo "Installing Homebrew and Xcode Command Line Tools now"
  echo " "
  echo "Please enter password when prompted"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

 (echo; echo 'eval "$(/usr/local/bin/brew shellenv)"') >> ~/.profile
 eval "$(/usr/local/bin/brew shellenv)"

 chsh -s /bin/bash

fi

if [ "$SYSTEMBIT" = "64" ] && [ "$SYSTEMOS" = "Linux" ];
  then
    echo "Your system is 64bit version of Debian Linux Kernal"
    echo " "
  while read -r -p "Which compiler do you want to use?
  -Intel
   --Please note that Hurricane WRF (HWRF) is only compatibile with Intel Compilers.

  -GNU

  Please answer Intel or GNU and press enter (case sensative).
  " yn; do

    case $yn in
    Intel)
      echo "-------------------------------------------------- "
      echo " "
      echo "Intel is selected for installation"
      export Ubuntu_64bit_Intel=1
      break
      ;;
    GNU)
      echo "-------------------------------------------------- "
      echo " "
      echo "GNU is selected for installation"
      export Ubuntu_64bit_GNU=1
      break
      ;;
      * )
     echo " "
     echo "Please answer Intel or GNU (case sensative).";;

  esac
  done
fi

if [ "$SYSTEMBIT" = "32" ] && [ "$SYSTEMOS" = "Linux" ]; then
  echo "Your system is not compatibile with this script."
  exit ;
fi


############################# Enter sudo users information #############################
echo "-------------------------------------------------- "
while true; do
  echo " "
  read -r -s -p "
  Password is only save locally and will not be seen when typing.
  Please enter your sudo password:

  " yn
  export PASSWD=$yn
  echo "-------------------------------------------------- "
  break
done

echo " "
echo "Beginning Installation"
echo " "

############################ DTC's MET & METPLUS ##################################################

###################################################################################################

if [ "$Ubuntu_64bit_Intel" = "1" ]; then



  echo $PASSWD | sudo -S apt -y update
  echo $PASSWD | sudo -S apt -y upgrade

  # download the key to system keyring; this and the following echo command are
  # needed in order to install the Intel compilers
  wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
  | gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null


  # add signed entry to apt sources and configure the APT client to use Intel repository:
  echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list

  # this update should get the Intel package info from the Intel repository
  echo $PASSWD | sudo -S apt -y update
  echo $PASSWD | sudo -S apt -y upgrade
  echo $PASSWD | sudo -S apt -y install python3 python3-dev emacs flex bison libpixman-1-dev libjpeg-dev pkg-config libpng-dev unzip python2 python2-dev python3-pip pipenv gcc gfortran g++ libtool automake autoconf make m4 default-jre default-jdk csh ksh git libncurses5 libncurses6 mlocate pkg-config build-essential curl libcurl4-openssl-dev

  # install the Intel compilers
  echo $PASSWD | sudo -S apt -y install intel-basekit
  echo $PASSWD | sudo -S apt -y install intel-hpckit
  echo $PASSWD | sudo -S apt -y install intel-oneapi-python
  echo $PASSWD | sudo -S apt -y install intel-iotkit

  echo $PASSWD | sudo -S apt -y update


  # make sure some critical packages have been installed
  which cmake pkg-config make gcc g++

  # add the Intel compiler file paths to various environment variables
  source /opt/intel/oneapi/setvars.sh

  # some of the libraries we install below need one or more of these variables
  export CC=icc
  export CXX=icpc
  export FC=ifort
  export F77=ifort
  export F90=ifort
  export MPIFC=mpiifort
  export MPIF77=mpiifort
  export MPIF90=mpiifort
  export MPICC=mpiicc
  export MPICXX=mpiicpc
  export CFLAGS="-fPIC -fPIE -O3 -diag-disable=10441"
  export FFLAGS="-m64"
  export FCFLAGS="-m64"
  #########################

  #Downloading latest dateutil due to python3.8 running old version.
  pip3 install python-dateutil==2.8
  pip3 install python-dateutil

  #Directory Listings


  mkdir $HOME/DTC
  export DTC_FOLDER=$HOME/DTC
  mkdir $DTC_FOLDER/MET-11.0.2
  mkdir $DTC_FOLDER/MET-11.0.2/Downloads
  mkdir $DTC_FOLDER/METplus-5.0.1
  mkdir $DTC_FOLDER/METplus-5.0.1/Downloads



  #Downloading MET and untarring files
  #Note weblinks change often update as needed.
  cd $DTC_FOLDER/MET-11.0.2/Downloads
  wget -c -4 https://raw.githubusercontent.com/dtcenter/MET/main_v11.0/internal/scripts/installation/compile_MET_all.sh

  wget -c -4 https://dtcenter.ucar.edu/dfiles/code/METplus/MET/installation/tar_files.tgz

  wget -c -4 https://github.com/dtcenter/MET/archive/refs/tags/v11.0.2.tar.gz


  cp compile_MET_all.sh $DTC_FOLDER/MET-11.0.2
  tar -xvzf tar_files.tgz -C $DTC_FOLDER/MET-11.0.2
  cp v11.0.2.tar.gz $DTC_FOLDER/MET-11.0.2/tar_files
  cd $DTC_FOLDER/MET-11.0.2



  cd $DTC_FOLDER/MET-11.0.2





  export PYTHON_VERSION=$(/opt/intel/oneapi/intelpython/latest/bin/python3 -V 2>&1|awk '{print $2}')
  export PYTHON_VERSION_MAJOR_VERSION=$(echo $PYTHON_VERSION | awk -F. '{print $1}')
  export PYTHON_VERSION_MINOR_VERSION=$(echo $PYTHON_VERSION | awk -F. '{print $2}')
  export PYTHON_VERSION_COMBINED=$PYTHON_VERSION_MAJOR_VERSION.$PYTHON_VERSION_MINOR_VERSION

  export CC=icc
  export CXX=icpc
  export FC=ifort
  export F77=ifort
  export F90=ifort
  export gcc_version=$(icc -dumpversion -diag-disable=10441)
  export TEST_BASE=$DTC_FOLDER/MET-11.0.2
  export COMPILER=intel_$gcc_version
  export MET_SUBDIR=${TEST_BASE}
  export MET_TARBALL=v11.0.2.tar.gz
  export USE_MODULES=FALSE
  export MET_PYTHON=/opt/intel/oneapi/intelpython/python${PYTHON_VERSION_COMBINED}
  export MET_PYTHON_CC=-I${MET_PYTHON}/include/python${PYTHON_VERSION_COMBINED}
  export MET_PYTHON_LD=-L${MET_PYTHON}/lib/python${PYTHON_VERSION_COMBINED}/config-${PYTHON_VERSION_COMBINED}-x86_64-linux-gnu\ -L${MET_PYTHON}/lib\ -lpython${PYTHON_VERSION_COMBINED}\ -lcrypt\ -lpthread -r\ -ldl\ -lm\ -lm  #investigate -lutil
  export SET_D64BIT=FALSE


  chmod 775 compile_MET_all.sh


  ./compile_MET_all.sh

  export PATH=$DTC_FOLDER/MET-11.0.2/bin:$PATH            #Add MET executables to path


#Basic Package Management for Model Evaluation Tools (METplus)

  echo $PASSWD | sudo -S apt -y update
  echo $PASSWD | sudo -S apt -y upgrade



#Directory Listings for Model Evaluation Tools (METplus

  mkdir $DTC_FOLDER/METplus-5.0.1
  mkdir $DTC_FOLDER/METplus-5.0.1/Sample_Data
  mkdir $DTC_FOLDER/METplus-5.0.1/Output
  mkdir $DTC_FOLDER/METplus-5.0.1/Downloads




#Downloading METplus and untarring files

  cd $DTC_FOLDER/METplus-5.0.1/Downloads
  wget -c -4 https://github.com/dtcenter/METplus/archive/refs/tags/v5.0.2.tar.gz
  tar -xvzf v5.0.2.tar.gz -C $DTC_FOLDER



# Insatlllation of Model Evaluation Tools Plus
  cd $DTC_FOLDER/METplus-5.0.1/parm/metplus_config

  sed -i "s|MET_INSTALL_DIR = /path/to|MET_INSTALL_DIR = $DTC_FOLDER/MET-11.0.2|" defaults.conf
  sed -i "s|INPUT_BASE = /path/to|INPUT_BASE = $DTC_FOLDER/METplus-5.0.1/Sample_Data|" defaults.conf
  sed -i "s|OUTPUT_BASE = /path/to|OUTPUT_BASE = $DTC_FOLDER/METplus-5.0.1/Output|" defaults.conf


# Downloading Sample Data

  cd $DTC_FOLDER/METplus-5.0.1/Downloads
  wget -c -4 https://dtcenter.ucar.edu/dfiles/code/METplus/METplus_Data/v5.0/sample_data-met_tool_wrapper-5.0.tgz
  tar -xvzf sample_data-met_tool_wrapper-5.0.tgz -C $DTC_FOLDER/METplus-5.0.1/Sample_Data


# Testing if installation of MET & METPlus was sucessfull
# If you see in terminal "METplus has successfully finished running."
# Then MET & METPLUS is sucessfully installed

  echo 'Testing MET & METPLUS Installation.'
  $DTC_FOLDER/METplus-5.0.1/ush/run_metplus.py -c $DTC_FOLDER/METplus-5.0.1/parm/use_cases/met_tool_wrapper/GridStat/GridStat.conf
  export PATH=$DTC_FOLDER/METplus-5.0.1/ush:$PATH
  echo " "
  read -r -t 5 -p "MET and METPLUS sucessfully installed with intel compilers"

fi

if [ "$Ubuntu_64bit_GNU" = "1" ]; then

  export HOME=`cd;pwd`
  #Basic Package Management for Model Evaluation Tools (MET)


  #############################basic package managment############################
  echo $PASSWD | sudo -S apt -y update
  echo $PASSWD | sudo -S apt -y upgrade
  echo $PASSWD | sudo -S apt -y install python3 python3-dev emacs flex bison libpixman-1-dev libjpeg-dev pkg-config libpng-dev unzip python2 python2-dev python3-pip pipenv gcc gfortran g++ libtool automake autoconf make m4 default-jre default-jdk csh ksh git libncurses5 libncurses6 mlocate pkg-config build-essential curl libcurl4-openssl-dev

  #Downloading latest dateutil due to python3.8 running old version.
  pip3 install python-dateutil

  #Directory Listings



  mkdir $HOME/DTC
  export DTC_FOLDER=$HOME/DTC
  mkdir $DTC_FOLDER/MET-11.0.2
  mkdir $DTC_FOLDER/MET-11.0.2/Downloads
  mkdir $DTC_FOLDER/METplus-5.0.1
  mkdir $DTC_FOLDER/METplus-5.0.1/Downloads



  #Downloading MET and untarring files
  #Note weblinks change often update as needed.
  cd $DTC_FOLDER/MET-11.0.2/Downloads

  wget -c -4 https://raw.githubusercontent.com/dtcenter/MET/main_v11.0/internal/scripts/installation/compile_MET_all.sh

  wget -c -4 https://dtcenter.ucar.edu/dfiles/code/METplus/MET/installation/tar_files.tgz

  wget -c -4 https://github.com/dtcenter/MET/archive/refs/tags/v11.0.2.tar.gz



  cp compile_MET_all.sh $DTC_FOLDER/MET-11.0.2
  tar -xvzf tar_files.tgz -C $DTC_FOLDER/MET-11.0.2
  cp v11.0.2.tar.gz $DTC_FOLDER/MET-11.0.2/tar_files
  cd $DTC_FOLDER/MET-11.0.2



  # Installation of Model Evaluation Tools


  cd $DTC_FOLDER/MET-11.0.2
  export GCC_VERSION=$(/usr/bin/gcc -dumpfullversion | awk '{print$1}')
  export GFORTRAN_VERSION=$(/usr/bin/gfortran -dumpfullversion | awk '{print$1}')
  export GPLUSPLUS_VERSION=$(/usr/bin/g++ -dumpfullversion | awk '{print$1}')

  export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
  export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
  export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')

  export version_10="10"

  if [ $GCC_VERSION_MAJOR_VERSION -lt $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -lt $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -lt $version_10 ]
  then
    sed -i 's/-fno-second-underscore -fallow-argument-mismatch/-fno-second-underscore -Wno-argument-mismatch/g' compile_MET_all.sh
  fi


  export PYTHON_VERSION=$(/usr/bin/python3 -V 2>&1|awk '{print $2}')
  export PYTHON_VERSION_MAJOR_VERSION=$(echo $PYTHON_VERSION | awk -F. '{print $1}')
  export PYTHON_VERSION_MINOR_VERSION=$(echo $PYTHON_VERSION | awk -F. '{print $2}')
  export PYTHON_VERSION_COMBINED=$PYTHON_VERSION_MAJOR_VERSION.$PYTHON_VERSION_MINOR_VERSION

  export CC=/usr/bin/gcc
  export CXX=/usr/bin/g++
  export CFLAGS="-fPIC -fPIE -O3"
  export FC=/usr/bin/gfortran
  export F77=/usr/bin/gfortran
  export F90=/usr/bin/gfortran
  export gcc_version=$(gcc -dumpfullversion)
  export TEST_BASE=$DTC_FOLDER/MET-11.0.2
  export COMPILER=gnu_$gcc_version
  export MET_SUBDIR=${TEST_BASE}
  export MET_TARBALL=v11.0.2.tar.gz
  export USE_MODULES=FALSE
  export MET_PYTHON=/usr
  export MET_PYTHON_CC=-I${MET_PYTHON}/include/python${PYTHON_VERSION_COMBINED}
  export MET_PYTHON_LD="$(python3-config --ldflags --embed) -L${MET_PYTHON}/lib -lpython${PYTHON_VERSION_COMBINED}"
  export SET_D64BIT=FALSE


  chmod 775 compile_MET_all.sh

  ./compile_MET_all.sh | tee compile_MET_all.log

  export PATH=$DTC_FOLDER/MET-11.0.2/bin:$PATH

  #basic Package Management for Model Evaluation Tools (METplus)

  echo $PASSWD | sudo -S apt -y update
  echo $PASSWD | sudo -S apt -y upgrade



#Directory Listings for Model Evaluation Tools (METplus

  mkdir $DTC_FOLDER/METplus-5.0.1
  mkdir $DTC_FOLDER/METplus-5.0.1/Sample_Data
  mkdir $DTC_FOLDER/METplus-5.0.1/Output
  mkdir $DTC_FOLDER/METplus-5.0.1/Downloads



#Downloading METplus and untarring files

  cd $DTC_FOLDER/METplus-5.0.1/Downloads
  wget -c -4 https://github.com/dtcenter/METplus/archive/refs/tags/v5.0.2.tar.gz
  tar -xvzf v5.0.2.tar.gz -C $DTC_FOLDER



# Insatlllation of Model Evaluation Tools Plus
  cd $DTC_FOLDER/METplus-5.0.1/parm/metplus_config

  sed -i "s|MET_INSTALL_DIR = /path/to|MET_INSTALL_DIR = $DTC_FOLDER/MET-11.0.2|" defaults.conf
  sed -i "s|INPUT_BASE = /path/to|INPUT_BASE = $DTC_FOLDER/METplus-5.0.1/Sample_Data|" defaults.conf
  sed -i "s|OUTPUT_BASE = /path/to|OUTPUT_BASE = $DTC_FOLDER/METplus-5.0.1/Output|" defaults.conf


# Downloading Sample Data

  cd $DTC_FOLDER/METplus-5.0.1/Downloads
  wget -c -4 https://dtcenter.ucar.edu/dfiles/code/METplus/METplus_Data/v5.0/sample_data-met_tool_wrapper-5.0.tgz
  tar -xvzf sample_data-met_tool_wrapper-5.0.tgz -C $DTC_FOLDER/METplus-5.0.1/Sample_Data


# Testing if installation of MET & METPlus was sucessfull
# If you see in terminal "METplus has successfully finished running."
# Then MET & METPLUS is sucessfully installed

  echo 'Testing MET & METPLUS Installation.'
  $DTC_FOLDER/METplus-5.0.1/ush/run_metplus.py -c $DTC_FOLDER/METplus-5.0.1/parm/use_cases/met_tool_wrapper/GridStat/GridStat.conf

  export PATH=$DTC_FOLDER/METplus-5.0.1/ush:$PATH

  read -r -t 5 -p "MET and METPLUS sucessfully installed with GNU compilers."

fi

if [ "$macos_64bit_GNU" = "1" ]; then

  echo "MET INSTALLING"
  brew install wget
  brew install git
  brew install gcc@13
  brew install libtool
  brew install automake
  brew install autoconf
  brew install make
  brew install m4
  brew install java
  brew install ksh
  brew install mpich
  brew install grads
  brew install ksh
  brew install tcsh
  brew install snap
  brew install python@3.10
  brew install cmake
  brew install xorgproto
  brew install xorgrgb
  brew install xauth
  brew install curl
  brew install flex
  brew install byacc
  brew install bison
  brew install gnu-sed


   echo $PASSWD | sudo -S pip3 install python-dateutil


    #Directory Listings
    mkdir $HOME/DTC
    export WRF_FOLDER=$HOME/DTC

    if [ "$WRFCHEM_PICK" = "1" ]; then
      mkdir $HOME/WRFCHEM
      export WRF_FOLDER=$HOME/WRFCHEM
    fi

    if [ "$WRFHYDRO_COUPLED_PICK" = "1" ]; then
      mkdir $HOME/WRFHYDRO_COUPLED
      export WRF_FOLDER=$HOME/WRFHYDRO_COUPLED
    fi

    if [ "$WRFHYDRO_STANDALONE_PICK" = "1" ]; then
      mkdir $HOME/WRFHYDRO_STANDALONE
      export WRF_FOLDER=$HOME/WRFHYDRO_STANDALONE
    fi


    if [ "$WRF_PICK" = "1" ]; then
      mkdir $HOME/WRF
      export WRF_FOLDER=$HOME/WRF
    fi

    if [ "$HWRF_PICK" = "1" ]; then
      mkdir $HOME/HWRF
      export WRF_FOLDER=$HOME/HWRF
    fi



    mkdir $WRF_FOLDER/MET-11.0.2
    mkdir $WRF_FOLDER/MET-11.0.2/Downloads
    mkdir $WRF_FOLDER/METplus-5.0.1
    mkdir $WRF_FOLDER/METplus-5.0.1/Downloads




      #Symlink to avoid clang conflicts with compilers
      #default gcc path /usr/bin/gcc
      #default homebrew path /usr/local/bin

      echo "Please enter password for linking GNU libraries"

      echo $PASSWD | sudo -S ln -sf /usr/local/bin/gcc-13 /usr/local/bin/gcc
      echo $PASSWD | sudo -S ln -sf /usr/local/bin/g++-13 /usr/local/bin/g++
      echo $PASSWD | sudo -S ln -sf /usr/local/bin/gfortran-13 /usr/local/bin/gfortran
      echo $PASSWD | sudo -S ln -sf /usr/local/bin/python3.10 /usr/local/bin/python3



    cd $WRF_FOLDER/MET-11.0.2/Downloads

   wget -c -4 https://raw.githubusercontent.com/dtcenter/MET/main_v11.0/internal/scripts/installation/compile_MET_all.sh

    wget -c -4 https://dtcenter.ucar.edu/dfiles/code/METplus/MET/installation/tar_files.tgz

    wget -c -4 https://github.com/dtcenter/MET/archive/refs/tags/v11.0.2.tar.gz

    cp compile_MET_all.sh $WRF_FOLDER/MET-11.0.2
    tar -xvzf tar_files.tgz -C $WRF_FOLDER/MET-11.0.2
    cp v11.0.2.tar.gz $WRF_FOLDER/MET-11.0.2/tar_files
    cd $WRF_FOLDER/MET-11.0.2



    cd $WRF_FOLDER/MET-11.0.2



    export PYTHON_VERSION=$(python3 -V 2>1|awk '{print $2}')
    export PYTHON_VERSION_MAJOR_VERSION=$(echo $PYTHON_VERSION | awk -F. '{print $1}')
    export PYTHON_VERSION_MINOR_VERSION=$(echo $PYTHON_VERSION | awk -F. '{print $2}')
    export PYTHON_VERSION_COMBINED=$PYTHON_VERSION_MAJOR_VERSION.$PYTHON_VERSION_MINOR_VERSION

    export CC=/usr/local/bin/gcc
    export CXX=/usr/local/bin/g++
    export CFLAGS="-fPIC -fPIE -O3 -Wno-implicit-function-declaration"
    export FC=/usr/local/bin/gfortran
    export F77=/usr/local/bin/gfortran
    export F90=/usr/local/bin/gfortran
    export gcc_version=$(gcc -dumpfullversion)
    export TEST_BASE=$WRF_FOLDER/MET-11.0.2
    export COMPILER=gnu_$gcc_version
    export MET_SUBDIR=${TEST_BASE}
    export MET_TARBALL=v11.0.2.tar.gz
    export USE_MODULES=FALSE
    export MET_PYTHON=/usr/local

    export MET_PYTHON_CC="-I$MET_PYTHON/opt/python@$PYTHON_VERSION_COMBINED//Frameworks/Python.framework/Versions/$PYTHON_VERSION_COMBINED/include/python$PYTHON_VERSION_COMBINED"
    export MET_PYTHON_LD="-L$MET_PYTHON//opt/python@$PYTHON_VERSION_COMBINED/Frameworks/Python.framework/Versions/$PYTHON_VERSION_COMBINED/lib/python$PYTHON_VERSION_COMBINED/config-$PYTHON_VERSION_COMBINED-darwin -lpython$PYTHON_VERSION_COMBINED -ldl -framework CoreFoundation"


    export SET_D64BIT=FALSE


    chmod 775 compile_MET_all.sh

    sed -i'' -e "831s/export/#export/g" compile_MET_all.sh
    time ./compile_MET_all.sh | tee compile_MET_all.log

    export PATH=$WRF_FOLDER/MET-11.0.2/bin:$PATH

    mkdir $WRF_FOLDER/METplus-5.0.1
    mkdir $WRF_FOLDER/METplus-5.0.1/Sample_Data
    mkdir $WRF_FOLDER/METplus-5.0.1/Output
    mkdir $WRF_FOLDER/METplus-5.0.1/Downloads



  #Downloading METplus and untarring files

    cd $WRF_FOLDER/METplus-5.0.1/Downloads
    wget -c -4 https://github.com/dtcenter/METplus/archive/refs/tags/v5.0.2.tar.gz
    tar -xvzf v5.0.2.tar.gz -C $WRF_FOLDER



  # Insatlllation of Model Evaluation Tools Plus
    cd $WRF_FOLDER/METplus-5.0.1/parm/metplus_config

    sed -i'' -e "s|MET_INSTALL_DIR = /path/to|MET_INSTALL_DIR = $WRF_FOLDER/MET-11.0.2|" defaults.conf
    sed -i'' -e "s|INPUT_BASE = /path/to|INPUT_BASE = $WRF_FOLDER/METplus-5.0.1/Sample_Data|" defaults.conf
    sed -i'' -e "s|OUTPUT_BASE = /path/to|OUTPUT_BASE = $WRF_FOLDER/METplus-5.0.1/Output|" defaults.conf


  # Downloading Sample Data

    cd $WRF_FOLDER/METplus-5.0.1/Downloads
    wget -c -4 https://dtcenter.ucar.edu/dfiles/code/METplus/METplus_Data/v5.0/sample_data-met_tool_wrapper-5.0.tgz
    tar -xvzf sample_data-met_tool_wrapper-5.0.tgz -C $WRF_FOLDER/METplus-5.0.1/Sample_Data


  # Testing if installation of MET & METPlus was sucessfull
  # If you see in terminal "METplus has successfully finished running."
  # Then MET & METPLUS is sucessfully installed

    echo 'Testing MET & METPLUS Installation.'
    $WRF_FOLDER/METplus-5.0.1/ush/run_metplus.py -c $WRF_FOLDER/METplus-5.0.1/parm/use_cases/met_tool_wrapper/GridStat/GridStat.conf

    export PATH=$WRF_FOLDER/METplus-5.0.1/ush:$PATH
     read -r -t 5 -p "MET and METPLUS sucessfully installed with GNU compilers."
fi



#####################################BASH Script Finished##############################



end=`date`
END=$(date +"%s")
DIFF=$(($END-$START))
echo "Install Start Time: ${start}"
echo "Install End Time: ${end}"
echo "Install Duration: $(($DIFF / 3600 )) hours $((($DIFF % 3600) / 60)) minutes $(($DIFF % 60)) seconds"
