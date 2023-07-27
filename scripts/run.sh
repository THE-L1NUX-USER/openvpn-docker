#!/bin/bash

docker run -it -d --cap-add=NET_ADMIN \
-v ./openvpn_conf:/opt/openvpn_data/clients \
--name openvpn \
-p 1194:1194/udp -p 80:8080/tcp \
-e HOST_ADDR=$(curl -s https://eth0.me) \
-e HOST_TUN_PORT="1194" \
-e HOST_CON_PORT="80" \
-e NET_ADAPTER="eth0" \
--restart always \
vo1dbin/openvpn:latest 