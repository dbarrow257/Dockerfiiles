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

ENV NEUT_VERSION=5.5.0

RUN mkdir -p /opt/neut/${NEUT_VERSION}
RUN mkdir -p /opt/neut-build/${NEUT_VERSION}
RUN mkdir -p /opt/neut-src/${NEUT_VERSION}

RUN mkdir -p ~/.ssh/
RUN ssh-keyscan github.com > ~/.ssh/known_hosts

WORKDIR /opt/neut-src/${NEUT_VERSION}
RUN --mount=type=ssh git clone git@github.com:neut-devel/neut.git 
WORKDIR /opt/neut-src/${NEUT_VERSION}/neut/
RUN git checkout ${NEUT_VERSION}
WORKDIR /opt/neut-src/${NEUT_VERSION}/neut/src
RUN autoreconf -if

WORKDIR /opt/neut-build/${NEUT_VERSION}
RUN /opt/neut-src/${NEUT_VERSION}/neut/src/configure --prefix=/opt/neut/${NEUT_VERSION}
RUN make install -j6

ENV NEUT_ROOT=/opt/neut/${NEUT_VERSION}
ENV PATH=${NEUT_ROOT}/bin:${PATH}
ENV LD_LIBRARY_PATH=${NEUT_ROOT}/lib:${LD_LIBRARY_PATH}
ENV NEUT_CRSPATH=${NEUT_ROOT}/share/neut/crsdat
ENV NEUT_CARDS=${NEUT_ROOT}/share/neut/Cards

ENV PKG_CONFIG_PATH=${NEUT_ROOT}:${PKG_CONFIG_PATH}

WORKDIR /
