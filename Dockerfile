FROM debian:jessie
MAINTAINER Justifiably <justifiably@ymail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get upgrade && \
    apt-get install -y curl

ENV LMS_DEBFILE=http://downloads.slimdevices.com/nightly/7.9/sc/5558c96/logitechmediaserver_7.9.0~1464697159_all.deb
RUN curl -o /tmp/lms.deb $LMS_DEBFILE

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
    libio-socket-ssl-perl \
    locales \
    faad \
    faac \
    flac \
    lame \
    sox \
    wavpack

RUN echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

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

