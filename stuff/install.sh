#!/bin/bash

### Unbound code below

mkdir -p /etc/services.d/unbound

cp -n /temp/lighttpd-external.conf /etc/lighttpd/external.conf 
cp -n /temp/unbound-pihole.conf /etc/unbound/unbound.conf.d/pi-hole.conf
cp -n /temp/99-edns.conf /etc/dnsmasq.d/99-edns.conf
cp -n /temp/unbound-run /etc/services.d/unbound/run

# Make bash script executable
chmod -v +x /etc/services.d/unbound/run


### Lancache cache domains code below
mkdir -p /etc/s6-overlay/s6-rc.d/_cachedomainsonboot
mkdir -p /etc/s6-overlay/s6-rc.d/_cachedomainsonboot/dependencies.d
echo "" > /etc/s6-overlay/s6-rc.d/_cachedomainsonboot/dependencies.d/pihole-FTL
echo "oneshot" > /etc/s6-overlay/s6-rc.d/_cachedomainsonboot/type
echo "#!/command/execlineb
background { bash -e /usr/local/bin/_cachedomainsonboot.sh }" > /etc/s6-overlay/s6-rc.d/_cachedomainsonboot/up

echo "#!/bin/bash
# Grabbing the repo
cd ~
git clone https://github.com/uklans/cache-domains.git

# Making copies of the files
mkdir -p /etc/cache-domains/ && cp \`find ~/cache-domains -name *.txt -o -name cache_domains.json\` /etc/cache-domains
mkdir -p /etc/cache-domains/scripts/ && cp ~/cache-domains/scripts/create-unbound.sh /etc/cache-domains/scripts/


# Setting up our config.json file
mkdir -p /etc/cache-domains/config
sudo cp -n /temp/config.json /etc/cache-domains/config/
if [ -f \"/etc/cache-domains/scripts/config.json\" ]; then
	sudo rm /etc/cache-domains/scripts/config.json
fi

sudo chown -v root:root /etc/cache-domains/config/*
sudo chmod -v 644 /etc/cache-domains/*

sudo ln -s /etc/cache-domains/config/config.json /etc/cache-domains/scripts/config.json 

# Make bash scripts executable
sudo chmod -v +x /etc/cache-domains/scripts/create-unbound.sh

# Manually generating our dnsmasq files
cd /etc/cache-domains/scripts
./create-unbound.sh

# Copying our files for Pi-hole to use 
sudo cp -r /etc/cache-domains/scripts/output/dnsmasq/*.conf /etc/unbound/unbound.conf.d/


# Automating the process
sudo cp -n /temp/lancache-dns-updates.sh /usr/local/bin/
sudo chmod -v +x /usr/local/bin/lancache-dns-updates.sh
" >  /usr/local/bin/_cachedomainsonboot.sh
sudo chmod -v +x /usr/local/bin/_cachedomainsonboot.sh

echo "Installed cache-domain files!"

if [ ! -d "/etc/s6-overlay/s6-rc.d/_postFTL" ]; then
    echo "Missing /etc/s6-overlay/s6-rc.d/_postFTL directory"
    exit 1
fi

mkdir -pv /etc/s6-overlay/s6-rc.d/_postFTL/dependencies.d
echo "" > /etc/s6-overlay/s6-rc.d/_postFTL/dependencies.d/_cachedomainsonboot
echo "Added dependency to _postFTL service (/etc/s6-overlay/s6-rc.d/_postFTL/dependencies.d/_cachedomainsonboot)!"

if [ ! -f "/etc/cron.d/cache-domains" ]; then
		echo "# cache-domains Updater by mwatz1234
# https://github.com/mwatz1234/pihole-dot-doh-updatelists-lancache-cache-domains

#30 4 * * *   root   /usr/local/bin/lancache-dns-updates.sh
" > /etc/cron.d/cache-domains
		sed "s/#30 /$((1 + RANDOM % 58)) /" -i /etc/cron.d/cache-domains
		echo "Created crontab (/etc/cron.d/cache-domains)"
	fi        

echo "Created crontab line for cache-domains"
    
