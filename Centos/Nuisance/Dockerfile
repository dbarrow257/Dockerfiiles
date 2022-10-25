FROM dbarrow257/gibuu_21:latest as gibuu_build
FROM dbarrow257/nuwro_21.09:latest as nuwro_build
FROM dbarrow257/neut_5.5.0:latest as neut_build
FROM dbarrow257/genie_3.0.6:latest as genie_build
FROM dbarrow257/root_6.24.06:latest as root_build

FROM dbarrow257/buildbox:latest

COPY --from=gibuu_build /opt/GiBUU /opt/GiBUU
COPY --from=nuwro_build /opt/nuwro /opt/nuwro

COPY --from=neut_build /opt/neut /opt/neut
COPY --from=neut_build /opt/neut-src /opt/neut-src
COPY --from=neut_build /opt/cernlib /opt/cernlib

COPY --from=genie_build /opt/genie /opt/genie
COPY --from=genie_build /opt/Reweight-src /opt/Reweight-src
COPY --from=genie_build /opt/lhapdf /opt/lhapdf

COPY --from=root_build /opt/root /opt/root
COPY --from=root_build /opt/pythia /opt/pythia

#================================================================================================
#General

ENV PYTHIA6_VER=6.4.28
ENV PYTHIA6=/opt/pythia/${PYTHIA6_VER}
ENV LD_LIBRARY_PATH=${PYTHIA6}:${LD_LIBRARY_PATH}

ENV ROOT_VERSION=v6-24-06
ENV ROOTSYS=/opt/root/${ROOT_VERSION}/
ENV PATH=${ROOTSYS}/bin:${PATH}
ENV LD_LIBRARY_PATH=${ROOTSYS}/lib:${LD_LIBRARY_PATH}

ENV LHAPDF_VERS=5.9.1
ENV LHAPATH=/opt/lhapdf/${LHAPDF_VERS}
ENV PATH=${LHAPATH}/bin:${PATH}
ENV LD_LIBRARY_PATH=${LHAPATH}/lib:${LD_LIBRARY_PATH}
ENV LHAPDF_INC=${LHAPATH}/include
ENV LHAPDF_LIB=${LHAPATH}/lib

ENV GENIE_VERSION=3_00_06
ENV GENIE_XSEC_TUNE=G1810a0211a
ENV GENIE=/opt/genie/${GENIE_VERSION}
ENV GENIE_REWEIGHT=/opt/Reweight-src/
ENV PATH=${GENIE}/bin:${PATH}
ENV LD_LIBRARY_PATH=${GENIE}/lib:${LD_LIBRARY_PATH}
ENV ROOT_INCLUDE_PATH=${GENIE}/include/GENIE

ENV GENIE_XSEC_DIR=/opt/genie/tune/genie_xsec/v${GENIE_VERSION}/NULL/${GENIE_XSEC_TUNE}-k250-e1000/
ENV GXMLPATH=/opt/genie/tune/genie_xsec/v${GENIE_VERSION}/NULL/${GENIE_XSEC_TUNE}-k250-e1000/

ENV CERN /opt/cernlib
ENV CERN_LEVEL 2005
ENV CERN_ROOT /opt/cernlib/2005

ENV NEUT_VERSION=5.5.0
ENV NEUT_ROOT=/opt/neut/${NEUT_VERSION}
ENV PATH=${NEUT_ROOT}/bin:${PATH}
ENV LD_LIBRARY_PATH=${NEUT_ROOT}/lib:${LD_LIBRARY_PATH}
ENV NEUT_CRSPATH=${NEUT_ROOT}/share/neut/crsdat
ENV NEUT_CARDS=${NEUT_ROOT}/share/neut/Cards
ENV PKG_CONFIG_PATH=${NEUT_ROOT}:${PKG_CONFIG_PATH}

ENV NUWRO_VERSION=21.09
ENV NUWRO=/opt/nuwro/${NUWRO_VERSION}/
ENV PATH=/opt/nuwro/${NUWRO_VERSION}/bin:${PATH}
ENV ROOT_INCLUDE_PATH=/opt/nuwro/${NUWRO_VERSION}/src:${ROOT_INCLUDE_PATH}

ENV GiBUU=/opt/GiBUU/2021
ENV GiBUU_JOBCARDS=/opt/GiBUU/2021/jobCards
ENV GiBUU_BUUINPUTS=/opt/GiBUU/2021/buuinput
ENV PATH=${GiBUU}/bin:${PATH}

WORKDIR /
#================================================================================================
#Nuisance

WORKDIR /opt

RUN git clone https://github.com/NUISANCEMC/nuisance.git nuisance-src 
WORKDIR /opt/nuisance-src
#RUN sed -i 's/GIT_TAG v0.2.3/GIT_TAG main/g' /opt/nuisance-src/CMakeLists.txt 

RUN mkdir /opt/nuisance-build
WORKDIR /opt/nuisance-build
RUN cmake /opt/nuisance-src -DCMAKE_INSTALL_PREFIX=/opt/nuisance
RUN make -j6 && make install -j6

ENV NUISANCE=/opt/nuisance/
ENV PATH=${NUISANCE}/bin:${PATH}
ENV LD_LIBRARY_PATH=${NUISANCE}/lib:${LD_LIBRARY_PATH}

WORKDIR /
#================================================================================================
#Run Scripts

WORKDIR /opt

RUN git clone https://github.com/dbarrow257/GeneratorRunScripts GeneratorTools
WORKDIR /opt/GeneratorTools



