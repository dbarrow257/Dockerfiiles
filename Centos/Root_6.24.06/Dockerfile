FROM dbarrow257/buildbox:latest

#================================================================================================
#Pythia6

ENV PYTHIA6_VER=6.4.28
ENV ROOT_VERSION=v6-24-06

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
RUN make -j4
RUN make install -j4

ENV ROOTSYS=/opt/root/${ROOT_VERSION}/
ENV PATH=${ROOTSYS}/bin:${PATH}
ENV LD_LIBRARY_PATH=${ROOTSYS}/lib:${LD_LIBRARY_PATH}

WORKDIR /
