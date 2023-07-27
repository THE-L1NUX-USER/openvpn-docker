# openvpn-docker

Get your stateless VPN server up and running effortlessly with this Docker image. It launches within seconds and doesn't need persistent storage. Simply copy and paste the snippet provided below into your terminal:

```bash
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
```

### Repos

| Name | URL |
| :--: | :-----: |
| GitHub | <https://github.com/THE-L1NUX-USER/openvpn-docker> |
| Docker Hub | <https://hub.docker.com/r/vo1dbin/openvpn> |


### Environment variables

| Variable | Description | Default value |
| :------: | :---------: | :-----------: |
| NET_ADAPTER | Network adapter to use on the host machine | eth0 |
| HOST_ADDR | Host address to advertise in the client config file | localhost |
| HOST_TUN_PORT | Tunnel port to advertise in the client config file | 1194 |
| HOST_CONF_PORT | HTTP port on the host machine to download the client config file | 80 |


### Container commands

After container was run using `docker run` command, it's possible to execute additional commands using `docker exec` command. For example, `docker exec <container id> ./version.sh`. See table below to get the full list of supported commands.

| Command  | Description | Parameters | Example |
| :------: | :---------: | :--------: | :-----: |
| `./version.sh` | Outputs full container version, i.e `openvpn v1.2.0` |  | `docker exec openvpn ./version.sh` |
| `./genclient.sh` | Generates new client configuration | `z` — Optional. Puts newly generated client.ovpn file into client.zip archive.<br><br>`zp paswd` — Optional. Puts newly generated client.ovpn file into client.zip archive with password `pswd` <br><br>`o` — Optional. Prints cert to the output. <br><br>`oz` — Optional. Prints zipped cert to the output. Use with output redirection. <br><br>`ozp paswd` — Optional. Prints encrypted zipped cert to the output. Use with output redirection. | `docker exec openvpn ./genclient.sh`<br><br>`docker exec openvpn ./genclient.sh z`<br><br>`docker exec openvpn ./genclient.sh zp 123` <br><br>`docker exec openvpn ./genclient.sh o > client.ovpn`<br><br>`docker exec openvpn ./genclient.sh oz > client.zip` <br><br>`docker exec openvpn ./genclient.sh ozp paswd > client.zip`| 
 | `./rmclient.sh` | Revokes client certificate thus making him/her anable to connect to given openvpn server. | Client Id, i.e `ssdgkahsgdyasfgdhsdfjahdvhj` | `docker exec openvpn ./rmclient.sh ssdgkahsgdyasfgdhsdfjahdvhj` |


## Quick Start

### Prerequisites

1. Any hardware or server running Linux. You should have administrative rights on this machine.
2. Docker installation on your server.
3. Public ip address assigned to your server.

### 1. Run openvpn

Copy & paste the following command to run docker-openvpn:<br>

```bash
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
```
If everything went well, you should be able to see the following output in your docker logs:
```bash
docker logs -f openvpn
```
Output:
```bash
Initialization Sequence Completed
Client.ovpn file has been generated
Config server started, download your client.ovpn config at http://<your_host_public_ip>:80/
NOTE: After you download you client config, http server will be shut down!
 ```

### 2. Get client configuration

Now, when your openvpn is up and running you can go to `<your_host_public_ip>:80` on your device and download ovpn client configuration.
As soon as you have your config file downloaded, you will see the following output in the console:

```bash
Config http server has been shut down
```

Import `client.ovpn` into your favourite openvpn client. In most cases it should be enough to just doubleclick or tap on that file.

### 3. Connect to your docker-openvpn container

You should be able to see your newly added client configuration in the list of available configurations. Click on it, connection process should initiate and be established within few seconds.

## Alternative way. Run with docker compose

Sometimes it is more convenient to use [docker-compose](https://docs.docker.com/compose/).

To run dockvpn with docker-compose run:

```bash
echo -e "\nHOST_ADDR=$(curl -s https://eth0.me)" >> .env && \
docker compose up -d
```

After run this command you can find your `client.ovpn` inside `openvpn_conf` folder.

