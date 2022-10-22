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
ENV PATH=${GiBUU}/bin:${PATH}