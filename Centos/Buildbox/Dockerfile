# syntax=docker/dockerfile:1
FROM centos:7 AS buildbox

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
RUN yum -y install ed csh openmotif-devel bzip2

RUN ln -s /usr/bin/cmake3 /usr/bin/cmake