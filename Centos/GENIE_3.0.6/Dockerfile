FROM dbarrow257/root_6.24.06:latest as root-build

FROM dbarrow257/buildbox:latest

#================================================================================================
#General

ENV PYTHIA6_VER=6.4.28
ENV ROOT_VERSION=v6-24-06

ENV PYTHIA6=/opt/pythia/${PYTHIA6_VER}
ENV LD_LIBRARY_PATH=${PYTHIA6}:${LD_LIBRARY_PATH}
ENV ROOTSYS=/opt/root/${ROOT_VERSION}/
ENV PATH=${ROOTSYS}/bin:${PATH}
ENV LD_LIBRARY_PATH=${ROOTSYS}/lib:${LD_LIBRARY_PATH}

COPY --from=root-build /opt/root /opt/root
COPY --from=root-build /opt/pythia /opt/pythia

WORKDIR /
#================================================================================================
#LHAPDF

ENV LHAPDF_VERS=5.9.1

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
    && make install -j4

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

ENV GENIE_VERSION=3_00_06
ENV GENIE_INSTALL=/opt/genie/${GENIE_VERSION}
ENV GENIE_SRC="/opt/Generator-src"
ENV GENIE=${GENIE_SRC}

RUN mkdir -p ${GENIE_INSTALL}
WORKDIR ${GENIE_SRC}
RUN ./configure --prefix=${GENIE_INSTALL} --enable-rwght 
RUN make -j6
RUN make install

ENV GENIE_REWEIGHT=/opt/Reweight-src/
WORKDIR /opt/Reweight-src
RUN make -j6 && make install

RUN cp /opt/Generator-src/data/evgen/pdfs/GRV98lo_patched.LHgrid \
    ${LHAPATH}/GRV98lo_patched.LHgrid

ENV GENIE=${GENIE_INSTALL}

RUN cp /opt/Generator-src/VERSION ${GENIE}/
RUN cp -r /opt/Generator-src/config ${GENIE}/
RUN mkdir -p ${GENIE}/data/
RUN cp -r /opt/Generator-src/data/evgen ${GENIE}/data/

RUN mkdir -p ${GENIE}/src/make/
RUN cp /opt/Generator-src/src/make/Make.config_no_paths \
                      ${GENIE}/src/make/

ENV PATH=${GENIE_INSTALL}/bin:${PATH}
ENV LD_LIBRARY_PATH=${GENIE_INSTALL}/lib:${LD_LIBRARY_PATH}
ENV ROOT_INCLUDE_PATH=${GENIE_INSTALL}/include/GENIE

#================================================================================================
#GENIE Tune

RUN mkdir /opt/genie/tune/
WORKDIR /opt/genie/tune

ENV GENIE_XSEC_TUNE=G1810a0211a

RUN wget https://scisoft.fnal.gov/scisoft/packages/genie_xsec/v3_00_06/genie_xsec-3.00.06-noarch-${GENIE_XSEC_TUNE}-k250-e1000.tar.bz2 \
          -O genie_xsec-3.00.06-noarch-${GENIE_XSEC_TUNE}-k250-e5000-resfixfix.tar.bz2
RUN tar xvf genie_xsec-3.00.06-noarch-${GENIE_XSEC_TUNE}-k250-e5000-resfixfix.tar.bz2

ENV GENIE_XSEC_DIR=/opt/genie/tune/genie_xsec/v${GENIE_VERSION}/NULL/${GENIE_XSEC_TUNE}-k250-e1000/
ENV GXMLPATH=/opt/genie/tune/genie_xsec/v${GENIE_VERSION}/NULL/${GENIE_XSEC_TUNE}-k250-e1000/

WORKDIR /
