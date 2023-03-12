# Pihole with unbound, updatelists, and cache domains for lancache
Official pihole docker with Unbound, jacklul/pihole-updatelists, and uklans/cache-domains configured to check and update daily if needed. 

Multi-arch image built for both Raspberry Pi (arm64, arm32/v7, arm32/v6) and amd64.

## Usage:
For docker parameters, refer to [official pihole docker readme](https://github.com/pi-hole/pi-hole). Below is an docker compose example.

```
version: '3.0'

services:
  pihole:
    container_name: pihole
    image: mwatz/pihole-unbound-updatelists-lancache-cache-domains:latest
    hostname: pihole
    domainname: pihole.local
    ports:
      - "443:443/tcp"
      - "53:53/tcp"
      - "53:53/udp"
      #- "67:67/udp"
      - "80:80/tcp"
    environment:
      - FTLCONF_LOCAL_IPV4=<IP address of device running the docker>
      - TZ=America/Los_Angeles
      - WEBPASSWORD=<Password to access pihole>
      - WEBTHEME=lcars
      - REV_SERVER=true
      - REV_SERVER_TARGET=<ip address of your router>
      - REV_SERVER_DOMAIN=localdomain
      - REV_SERVER_CIDR=<may be 192.168.1.0/24 if your router is 192.168.1.1>
      - PIHOLE_DNS_=127.0.0.1#5335
      - DNSSEC="true"
    volumes:
      - './etc/pihole:/etc/pihole/:rw'
      - './etc/dnsmask:/etc/dnsmasq.d/:rw'
      - './etc/updatelists:/etc/pihole-updatelists/:rw'
      - './etc/lancache/config.json:/etc/cache-domains/config/config.json'
    restart: unless-stopped
```
### Notes:
* Create the lancache folder and config file (https://github.com/mwatz1234/pihole-dot-doh-updatelists-lancache-cache-domains/blob/master/stuff/config.json) for the docker volume before you start the docker
      * This container will simply point pihole to your already configured and running lancache server (https://lancache.net/docs/containers/monolithic/) for the configured CDN's based on teh config file mentioned above (config.json).
* Credits:
  * Pihole base image is the official [pihole/pihole:latest](https://hub.docker.com/r/pihole/pihole/tags?page=1&name=latest)
  * unbound method was based from https://github.com/chriscrowe/docker-pihole-unbound
  * pihole-update lists is from https://github.com/jacklul/pihole-updatelists
  * cache-domains is from https://github.com/uklans/cache-domains
       * Thanks oct8l (https://oct8l.gitlab.io/posts/2021/297/scripting-lancache-dns-updates-with-pi-hole/) for having a guide for updating cache-domains.  I took that knowledge and modified it for docker.
