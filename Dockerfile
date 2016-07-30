FROM debian:jessie
MAINTAINER Justifiably <justifiably@ymail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl

# Dependencies first
RUN echo "deb http://www.deb-multimedia.org jessie main non-free" | tee -a /etc/apt/sources.list && \
    curl -s -o /tmp/key.deb https://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2016.3.7_all.deb && \
    dpkg -i /tmp/key.deb && \
    rm -f /tmp/key.deb

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --force-yes \
    supervisor \
    perl5 \
    locales \
    faad \
    faac \
    flac \
    lame \
    sox \
    wavpack \
    ffmpeg

# Dependencies for shairport (https://github.com/disaster123/shairport2_plugin/)
RUN apt-get install -y --force-yes \
    libcrypt-openssl-rsa-perl \
    libio-socket-inet6-perl \
    libwww-perl avahi-utils \
    libio-socket-ssl-perl && \
    curl -o /tmp/netsdp.deb http://www.inf.udec.cl/~diegocaro/rpi/libnet-sdp-perl_0.07-1_all.deb && \
    dpkg -i /tmp/netsdp.deb && \
    rm -f /tmp/netsdp.deb

RUN echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

COPY lms.deb /tmp/lms.deb

# Fix UID for squeezeboxserver user to help with host volumes
RUN useradd --system --uid 819 -M -s /bin/false -d /usr/share/squeezeboxserver -G nogroup -c "Logitech Media Server user" squeezeboxserver && \
    dpkg -i /tmp/lms.deb && \
    rm -f  /tmp/lms.deb

# Cleanup
RUN apt-get -y remove curl && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
        
# Move config dir to allow editing convert.conf
RUN mkdir -p /mnt/state/etc && \
    mv /etc/squeezeboxserver /etc/squeezeboxserver.orig && \
    cp -pr /etc/squeezeboxserver.orig/* /mnt/state/etc && \
    ln -s /mnt/state/etc /etc/squeezeboxserver && \
    chown -R squeezeboxserver.nogroup /mnt/state

RUN mkdir -p /var/log/supervisor
COPY ./supervisord.conf /etc/
COPY ./start-lms.sh /usr/local/bin

VOLUME ["/mnt/state","/mnt/music","/mnt/playlists"]
EXPOSE 3483 3483/udp 9000 9090 9010

CMD ["/usr/local/bin/start-lms.sh"]

