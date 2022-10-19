FROM centos:7 

#================================================================================================
#General

ENV NCORES=4

ENV PYTHIA6_VER=6.4.28
ENV ROOT_VERSION=v6-24-06
ENV LHAPDF_VERS=5.9.1
ENV NEUT_VERSION=5.5.0
ENV NUWRO_VERSION=21.09
ENV GENIE_TUNE=G1810a0211a

#================================================================================================
#Buildbox

WORKDIR /

RUN sed -i "s/alias/#alias/g" /root/.bashrc
RUN sed -i "s/alias/#alias/g" /root/.cshrc
RUN sed -i "s/alias/#alias/g" /root/.tcshrc

RUN yum -y update && yum -y install epel-release && yum repolist
RUN yum -y install gcc gcc-c++ gcc-gfortran cmake3 make imake autoconf automake
RUN yum -y install pkgconfig libtool m4
RUN yum -y install git wget openssh-clients openssl-devel xorg-x11-utils
RUN yum -y install libXt-devel libXpm-devel libXft-devel libXext-devel
RUN yum -y install libxml2-devel gmp-devel gsl-devel log4cpp-devel bzip2-devel
RUN yum -y install pcre-devel xz-devel zlib-devel freetype-devel fftw-devel blas-devel
RUN yum -y install lapack-devel lz4-devel xz-devel
RUN yum -y install emacs python-devel svn which
RUN yum -y install ed csh openmotif-devel

RUN ln -s /usr/bin/cmake3 /usr/bin/cmake

#================================================================================================
#Pythia6

ENV PYTHIA6=/opt/pythia/${PYTHIA6_VER}

RUN mkdir -p /opt/pythia-src /opt/pythia/${PYTHIA6_VER}
WORKDIR  /opt/pythia-src
RUN wget http://root.cern.ch/download/pythia6.tar.gz \
	&& wget https://pythia.org/download/pythia6/pythia6428.f \
	&& tar xfvz pythia6.tar.gz && mv pythia6428.f pythia6/pythia6428.f \
	&& rm pythia6/pythia6416.f
WORKDIR /opt/pythia-src/pythia6
RUN sed -i "s/int /extern int /g" pythia6_common_address.c \
	&& sed -i "s/char /extern char /g" pythia6_common_address.c \
	&& sed -i "s/extern int pyuppr/int pyuppr/g" pythia6_common_address.c \
	&& sed -i "s/m64/march=native/g" makePythia6.linuxx8664 \
	&& ./makePythia6.linuxx8664 \
	&& mv libPythia6.so /opt/pythia/${PYTHIA6_VER}/libPythia6.so

ENV LD_LIBRARY_PATH=${PYTHIA6}:${LD_LIBRARY_PATH}

WORKDIR /
#================================================================================================
#ROOT

RUN mkdir -p /opt /opt/root/build /opt/root/${ROOT_VERSION}/

RUN git clone https://github.com/root-project/root.git /opt/root-src
WORKDIR /opt/root-src
RUN git checkout ${ROOT_VERSION}
WORKDIR /opt/root/build
RUN cmake /opt/root-src \
    -Dminuit2=ON \
    -Dmathmore=ON \
    -Dpythia6=ON -DPYTHIA6_LIBRARY=/opt/pythia/${PYTHIA6_VER}/libPythia6.so \
    -DCMAKE_INSTALL_PREFIX=/opt/root/${ROOT_VERSION}/
RUN make -j${NCORES}
RUN make install -j${NCORES}

ENV ROOTSYS=/opt/root/${ROOT_VERSION}/
ENV PATH=${ROOTSYS}/bin:${PATH}
ENV LD_LIBRARY_PATH=${ROOTSYS}/lib:${LD_LIBRARY_PATH}

WORKDIR /
#================================================================================================
#LHAPDF

RUN mkdir -p /opt/lhapdf-src
WORKDIR /opt/lhapdf-src

RUN wget https://lhapdf.hepforge.org/downloads/?f=old/lhapdf-${LHAPDF_VERS}.tar.gz \
         -O lhapdf-${LHAPDF_VERS}.tar.gz \
    && tar -zxvf lhapdf-${LHAPDF_VERS}.tar.gz

WORKDIR /opt/lhapdf-src/lhapdf-${LHAPDF_VERS}/config/
RUN  wget -O config.guess 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD' \
 && wget -O config.sub 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD'

RUN mkdir -p /opt/lhapdf-build /opt/lhapdf/${LHAPDF_VERS}
WORKDIR /opt/lhapdf-build

ENV FCFLAGS="-std=legacy"
RUN /opt/lhapdf-src/lhapdf-${LHAPDF_VERS}/configure \
    --prefix=/opt/lhapdf/${LHAPDF_VERS} \
    --disable-old-ccwrap \
    --disable-pyext \
    && make install -j${NCORES}

ENV LHAPATH=/opt/lhapdf/${LHAPDF_VERS}
ENV PATH=${LHAPATH}/bin:${PATH}
ENV LD_LIBRARY_PATH=${LHAPATH}/lib:${LD_LIBRARY_PATH}
ENV LHAPDF_INC=${LHAPATH}/include
ENV LHAPDF_LIB=${LHAPATH}/lib

WORKDIR /
#================================================================================================
#GENIE

WORKDIR /opt/
RUN git clone https://github.com/luketpickering/Generator.git Generator-src
WORKDIR /opt/Generator-src
RUN git checkout R-3_00_06_patched
WORKDIR /opt/
RUN git clone https://github.com/GENIE-MC/Reweight.git Reweight-src
WORKDIR /opt/Reweight-src
RUN git checkout R-1_00_06

ENV GENIE="/opt/Generator-src"
ENV GENIE_VERSION=3_00_06

WORKDIR /opt/Generator-src
RUN mkdir -p /opt/genie/${GENIE_VERSION} 
RUN ./configure --prefix=/opt/genie/${GENIE_VERSION} --enable-rwght 
RUN make -j${NCORES} 
RUN make install

ENV GENIE_REWEIGHT=/opt/Reweight-src/
WORKDIR /opt/Reweight-src
RUN make -j${NCORES} && make install -j${NCORES}

RUN cp /opt/Generator-src/data/evgen/pdfs/GRV98lo_patched.LHgrid \
    ${LHAPATH}/GRV98lo_patched.LHgrid

ENV PATH=${GENIE}/bin:${PATH}
ENV LD_LIBRARY_PATH=${GENIE}/lib:${LD_LIBRARY_PATH}
ENV LD_LIBRARY_PATH=/opt/genie/${GENIE_VERSION}/lib:${LD_LIBRARY_PATH}
ENV ROOT_INCLUDE_PATH=${GENIE}/include/GENIE

WORKDIR /
#================================================================================================
#GIBUU

RUN mkdir -p /opt/GiBUU-src
WORKDIR /opt/GiBUU-src

RUN wget --content-disposition https://gibuu.hepforge.org/downloads?f=release2021.tar.gz
RUN wget --content-disposition https://gibuu.hepforge.org/downloads?f=buuinput2021.tar.gz
RUN wget --content-disposition https://gibuu.hepforge.org/downloads?f=libraries2021_RootTuple.tar.gz

RUN tar -xzvf buuinput2021.tar.gz
RUN tar -xzvf release2021.tar.gz
RUN tar -xzvf libraries2021_RootTuple.tar.gz

WORKDIR /opt/GiBUU-src/release2021

RUN make withFORT=gfortran buildRootTuple
RUN make withFORT=gfortran withROOT=1

RUN mkdir -p /opt/GiBUU/2021/{bin,buuinput}
RUN cp /opt/GiBUU-src/release2021/objects/GiBUU.x /opt/GiBUU/2021/bin/
RUN cp -a /opt/GiBUU-src/release2021/testRun/jobCards /opt/GiBUU/2021/jobCards/
RUN cp -a /opt/GiBUU-src/buuinput2021 /opt/GiBUU/2021/buuinput

ENV GiBUU=/opt/GiBUU/2021
ENV GiBUU_JOBCARDS=/opt/GiBUU/2021/jobCards
ENV GiBUU_BUUINPUTS=/opt/GiBUU/2021/buuinput
ENV PATH=${GiBUU}/bin:${PATH}OB

WORKDIR /
#================================================================================================
#NuWro

WORKDIR /

WORKDIR /opt/
RUN git clone https://github.com/NuWro/nuwro.git nuwro-src
WORKDIR /opt/nuwro-src
RUN git checkout nuwro_${NUWRO_VERSION}
RUN sed -i "s:-lPythia6:-L${PYTHIA6} -lPythia6:g" Makefile
RUN make -j${NCORES}

RUN mkdir -p /opt/nuwro/${NUWRO_VERSION}/src/dis
RUN mkdir -p /opt/nuwro/${NUWRO_VERSION}/src/espp
RUN mkdir -p /opt/nuwro/${NUWRO_VERSION}/src/sf
RUN mkdir -p /opt/nuwro/${NUWRO_VERSION}/src/rpa
RUN mkdir -p /opt/nuwro/${NUWRO_VERSION}/src/rew
RUN cp -a /opt/nuwro-src/data /opt/nuwro/${NUWRO_VERSION}/data
RUN cp -a /opt/nuwro-src/bin /opt/nuwro/${NUWRO_VERSION}/bin
RUN cp -a /opt/nuwro-src/src/*.h /opt/nuwro/${NUWRO_VERSION}/src/
RUN cp -a /opt/nuwro-src/src/dis/*.h /opt/nuwro/${NUWRO_VERSION}/src/dis/
RUN cp -a /opt/nuwro-src/src/espp/*.h /opt/nuwro/${NUWRO_VERSION}/src/espp/
RUN cp -a /opt/nuwro-src/src/sf/*.h /opt/nuwro/${NUWRO_VERSION}/src/sf/
RUN cp -a /opt/nuwro-src/src/rpa/*.h /opt/nuwro/${NUWRO_VERSION}/src/rpa/
RUN cp -a /opt/nuwro-src/src/rew/*.h /opt/nuwro/${NUWRO_VERSION}/src/rew/

ENV NUWRO=/opt/nuwro/${NUWRO_VERSION}/
ENV PATH=/opt/nuwro/${NUWRO_VERSION}/bin:${PATH}
ENV ROOT_INCLUDE_PATH=/opt/nuwro/${NUWRO_VERSION}/src:${ROOT_INCLUDE_PATH}

WORKDIR /
#================================================================================================
#CERNLIB

WORKDIR /opt/

RUN mkdir -p /opt/cernlib-src /opt/cernlib/2005
WORKDIR /opt/cernlib-src
RUN test -e /usr/bin/gmake || ln -s /usr/bin/make /usr/bin/gmake
RUN git clone https://github.com/luketpickering/cernlibgcc5-.git
WORKDIR /opt/cernlib-src/cernlibgcc5-
RUN ./build_cernlib.sh
RUN cp -r /opt/cernlib-src/cernlibgcc5-/cernlib_build/2005/bin \
		/opt/cernlib-src/cernlibgcc5-/cernlib_build/2005/lib \
		/opt/cernlib-src/cernlibgcc5-/cernlib_build/2005/include \
     /opt/cernlib/2005

ENV CERN /opt/cernlib
ENV CERN_LEVEL 2005
ENV CERN_ROOT /opt/cernlib/2005

WORKDIR /
#================================================================================================
#NEUT

RUN mkdir -p /opt/neut-build
RUN mkdir -p ~/.ssh/
RUN ssh-keyscan github.com > ~/.ssh/known_hosts

WORKDIR /opt
RUN --mount=type=ssh git clone git@github.com:neut-devel/neut.git 
WORKDIR /opt/neut
RUN git checkout ${NEUT_VERSION}
WORKDIR /opt/neut/src
RUN autoreconf -if

WORKDIR /opt/neut-build
RUN /opt/neut/src/configure --prefix=/opt/neut/${NEUT_VERSION}
RUN make install -j${NCORES}

ENV NEUT_ROOT=/opt/neut/${NEUT_VERSION}
ENV PATH=${NEUT_ROOT}/bin:${PATH}
ENV LD_LIBRARY_PATH=${NEUT_ROOT}/lib:${LD_LIBRARY_PATH}
ENV NEUT_CRSPATH=${NEUT_ROOT}/share/neut/crsdat
ENV NEUT_CARDS=${NEUT_ROOT}/share/neut/Cards

RUN ln -s ${NEUT_ROOT}/include /opt/neut/src/neutclass
ENV ROOT_INCLUDE_PATH=/:${ROOT_INCLUDE_PATH}
RUN source /opt/neut/${NEUT_VERSION}/setup.sh

ENV PKG_CONFIG_PATH=${NEUT_ROOT}:${PKG_CONFIG_PATH}

WORKDIR /
#================================================================================================
#Prob3++

WORKDIR /opt

RUN git clone https://github.com/rogerwendell/Prob3plusplus.git Prob3pp-src
WORKDIR /opt/Prob3pp-src

RUN make all

ENV Prob3plusplus_DIR=/opt/Prob3pp-src/

WORKDIR /
#================================================================================================
#Nuisance

WORKDIR /opt

RUN git clone https://github.com/NUISANCEMC/nuisance.git nuisance-src 
WORKDIR /opt/nuisance-src
RUN sed -i 's/GIT_TAG v0.2.3/GIT_TAG main/g' /opt/nuisance-src/CMakeLists.txt 

RUN mkdir /opt/nuisance-build
WORKDIR /opt/nuisance-build
RUN cmake /opt/nuisance-src -DCMAKE_INSTALL_PREFIX=/opt/nuisance
RUN make -j${NCORES} && make install -j${NCORES}

ENV NUISANCE=/opt/nuisance/
ENV PATH=${NUISANCE}/bin:${PATH}
ENV LD_LIBRARY_PATH=${NUISANCE}/lib:${LD_LIBRARY_PATH}

WORKDIR /
#================================================================================================
#GENIE Tunes

RUN mkdir /opt/genie/tune
WORKDIR /opt/genie/Tune

RUN wget https://scisoft.fnal.gov/scisoft/packages/genie_xsec/v3_00_06/genie_xsec-3.00.06-noarch-${GENIETUNE}-k250-e1000.tar.bz2
RUN tar -xvf genie_xsec-3.00.06-noarch-${GENIETUNE}-k250-e1000.tar.bz2 -C ${GENIETUNE}