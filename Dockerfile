ARG FRM='pihole/pihole:latest'
ARG TAG='latest'

FROM ${FRM}
ARG FRM
ARG TAG
ARG TARGETPLATFORM

RUN apt-get update && \
    apt-get install -Vy sudo bash nano curl wget php-cli php-sqlite3 php-intl php-curl stubby git

ADD stuff /temp

RUN /bin/bash /temp/install.sh \
    && rm -f /temp/install.sh

RUN wget -O - https://raw.githubusercontent.com/jacklul/pihole-updatelists/master/install.sh | bash /dev/stdin docker

RUN echo "$(date "+%d.%m.%Y %T") Built from ${FRM} with tag ${TAG}" >> /build_date.info
