FROM centos:6

MAINTAINER Zoltán Berkes <zoltan.berkes.1@gmail.com>

RUN yum -y install \
    compat-libstdc++-33 \
    libX11 \
    firefox \
    openmotif22 \
    patch \
&& yum clean all

RUN curl -o /usr/local/bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(arch | sed s/x86_64/amd64/ --)" \
&& chmod +x /usr/local/bin/gosu

COPY content README.md /

VOLUME [ "/opt/Xilinx", "/home/workspace"  ]

WORKDIR /home/workspace
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "--shell" ]


RUN yum -y install mc

RUN yum -y install epel-release \
 && yum -y install xorg-x11-resutils-7.1

#RUN yum -y groupinstall "Legacy X Window System compatibility"
#RUN yum -y groupinstall "Fonts"
#RUN yum -y groupinstall "X Window System"
#RUN yum -y groupinstall "General Purpose Desktop"
#RUN yum -y groupinstall "Desktop"
#RUN yum -y groupinstall "Compatibility libraries"
#RUN yum -y groupinstall "Legacy UNIX compatibility"

#RUN yum -y groupinstall "Base"
#RUN yum -y groupinstall "Desktop Debugging and Performance Tools"
#RUN yum -y groupinstall "Desktop Platform"
