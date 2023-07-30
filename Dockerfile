FROM alpine:latest

LABEL maintainer="vo1d.bin"

# System settings. User normally shouldn't change these parameters
ENV APP_NAME openvpn
ENV APP_INSTALL_PATH /opt/${APP_NAME}
ENV APP_PERSIST_DIR /opt/${APP_NAME}_data

# Configuration settings with default values
ENV NET_ADAPTER eth0
ENV HOST_ADDR localhost
ENV HOST_TUN_PORT 1194
ENV HOST_CONF_PORT 80

WORKDIR ${APP_INSTALL_PATH}

COPY scripts .
COPY config ./config
COPY VERSION ./config

RUN apk add --no-cache openvpn easy-rsa bash netcat-openbsd zip dumb-init && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/bin/easyrsa && chmod +x *.sh && \
    mkdir -p ${APP_PERSIST_DIR} && \
    # Copy FROM ./scripts/server/conf TO /etc/openvpn/server.conf in DockerFile
    cd ${APP_INSTALL_PATH} && \
    cp config/server.conf /etc/openvpn/server.conf

EXPOSE 1194/udp
EXPOSE 8080/tcp

VOLUME [ "/opt/openvpn_data" ]

ENTRYPOINT [ "dumb-init", "./start.sh" ]
#ENTRYPOINT [ "bash", "./start.sh" ]
CMD [ "" ]
