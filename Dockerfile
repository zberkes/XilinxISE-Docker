FROM centos:6

MAINTAINER Zoltán Berkes <zoltan.berkes.1@gmail.com>

RUN yum -y install \
    compat-libstdc++-33 \
    libX11 \
    firefox \
    openmotif22 \
    patch \
    file \
&& yum clean all

RUN curl -o /usr/local/bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(arch | sed s/x86_64/amd64/ --)" \
&& chmod +x /usr/local/bin/gosu

COPY content README.md /

VOLUME [ "/opt/Xilinx", "/home/workspace"  ]

WORKDIR /home/workspace
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "--shell" ]
