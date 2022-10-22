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
#NuWro

ENV NUWRO_VERSION=21.09

WORKDIR /

WORKDIR /opt/
RUN git clone https://github.com/NuWro/nuwro.git nuwro-src
WORKDIR /opt/nuwro-src
RUN git checkout nuwro_${NUWRO_VERSION}
RUN sed -i "s:-lPythia6:-L${PYTHIA6} -lPythia6:g" Makefile
RUN make -j6

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