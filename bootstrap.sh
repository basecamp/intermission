#!/usr/bin/env bash

# Update the apt sources
apt-get update

# Install dependencies
sudo apt-get -y install make ruby1.9.1 ruby1.9.1-dev git-core libpcre3-dev libxslt1-dev libgd2-xpm-dev libgeoip-dev unzip zip build-essential

# Get openresty
wget http://openresty.org/download/ngx_openresty-1.4.3.9.tar.gz

# Uncompress openresty
tar -zxvf ngx_openresty-1.4.3.9.tar.gz 

# Build & install openresty
cd ngx_openresty-1.4.3.9/
./configure --with-luajit  --with-http_dav_module --with-http_flv_module --with-http_geoip_module --with-http_gzip_static_module --with-http_image_filter_module --with-http_realip_module --with-http_stub_status_module --with-http_ssl_module --with-http_sub_module --with-http_xslt_module --with-ipv6 --with-sha1=/usr/include/openssl --with-md5=/usr/include/openssl --with-mail --with-mail_ssl_module --with-http_stub_status_module --with-http_secure_link_module --with-http_sub_module
make && make install

# Put intermission in place
ln -s /vagrant /usr/local/openresty/nginx/intermission

# Start intermission
/usr/local/openresty/nginx/sbin/nginx -c intermission/sample-nginx.conf

# Put reminder of how to start openresty in vagrant shell
cat << EOF >> /home/vagrant/.bashrc
	echo -e "\nTo Start openresty (if nginx isn't running), run:\n\tsudo /usr/local/openresty/nginx/sbin/nginx -c intermission/sample-nginx.conf\n"
EOF