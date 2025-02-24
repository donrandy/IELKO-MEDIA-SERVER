#!/bin/bash
sudo add-apt-repository ppa:mc3man/trusty-media -y
sudo apt-get update -y
sudo apt-get install livestreamer build-essential libpcre3 libpcre3-dev libssl-dev  libpcre3 git  software-properties-common php7.0-cli php7.0-curl php7.0-dev php7.0-fpm php7.0-gd php7.0-mysql php7.0-mcrypt php7.0-opcache php-mbstring php7.0-mbstring php7.0-sybase libsybdb5 php-gettext -y
sudo apt-get install ffmpeg  -y
mkdir ~/working
mkdir ~/working/IELKO
mkdir ~/working/nginx-rtmp-module
mkdir ~/working/ngx_devel_kit
mkdir ~/working/set-misc-nginx-module
mkdir ~/working/nginx
git clone https://github.com/donrandy/IELKO-MEDIA-SERVER.git ~/working/IELKO
git clone https://github.com/sergey-dryabzhinsky/nginx-rtmp-module.git ~/working/nginx-rtmp-module
git clone https://github.com/openresty/set-misc-nginx-module.git ~/working/set-misc-nginx-module
git clone https://github.com/simpl/ngx_devel_kit.git ~/working/ngx_devel_kit
git clone https://github.com/nginx-modules/nginx-hmac-secure-link.git ~/working/nginx-hmac-secure-link
wget http://nginx.org/download/nginx-1.14.1.tar.gz -P ~/working
tar -xf ~/working/nginx-1.14.1.tar.gz -C ~/working/nginx --strip-components=1
rm ~/working/nginx-1.14.1.tar.gz
cd ~/working/nginx
./configure --with-http_ssl_module --add-module=../nginx-rtmp-module --with-http_secure_link_module --add-module=../ngx_devel_kit --add-module=../set-misc-nginx-module
make -j 2
sudo make install
cp ~/working/IELKO/conf/nginx.conf /usr/local/nginx/conf/nginx.conf
cp ~/working/IELKO/conf/nginx.service /etc/init.d/nginx
sudo chmod +x /etc/init.d/nginx
sudo /usr/sbin/update-rc.d -f nginx defaults
ufw allow 8080
ufw allow 80
ufw allow 1935
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp --dport 1935 -j ACCEPT
iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
rm /usr/local/nginx/html/*
cp ~/working/IELKO/www/index.php /usr/local/nginx/html/index.php
cp ~/working/IELKO/www/ielko-media-server.css /usr/local/nginx/html/ielko-media-server.css
cp ~/working/IELKO/www/stream.xml /usr/local/nginx/html/stream.xml
cp ~/working/IELKO/www/stat.xsl /usr/local/nginx/html/stat.xsl
cp ~/working/IELKO/www/testing.png /usr/local/nginx/html/testing.png
cp ~/working/IELKO/www/favicon.ico /usr/local/nginx/html/favicon.ico
git clone https://github.com/donrandy/ielko-video-player /usr/local/nginx/html/player
ip=$(curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//' )
sed -i -- 's/replaceip/'"$ip"'/g' /usr/local/nginx/html/stream.xml
sed -i -- 's/replaceip/'"$ip"'/g' /usr/local/nginx/html/index.php
#
ln -s /usr/local/nginx/sbin/nginx nginx
sudo service nginx start
sudo rm -rf ~/working
shutdown -r now
