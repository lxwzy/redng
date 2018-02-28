FROM ubuntu
ENV openssl_url=https://www.openssl.org/source/openssl-1.0.2n.tar.gz
ENV NPS_VERSION=1.13.35.2-stable
ENV ng_url=https://nginx.org/download/nginx-1.13.8.tar.gz
RUN apt update
RUN apt install -y build-essential libpcre3 libpcre3-dev zlib1g-dev unzip git wget
RUN wget -O openssl.tar.gz -c ${openssl_url}
RUN tar zxf openssl.tar.gz
RUN mv openssl-1.0.2n/ openssl
RUN git clone --recursive https://github.com/google/ngx_brotli.git
# cd ngx_brotli

# modepagespeed
#[check the release notes for the latest version]
RUN wget https://github.com/apache/incubator-pagespeed-ngx/archive/v${NPS_VERSION}.zip
RUN unzip v${NPS_VERSION}.zip
RUN nps_dir=$(find . -name "*pagespeed-ngx-${NPS_VERSION}" -type d)
RUN cd "$nps_dir"
# NPS_RELEASE_NUMBER=${NPS_VERSION/beta/}
RUN NPS_RELEASE_NUMBER=${NPS_VERSION/stable/}
RUN psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_RELEASE_NUMBER}.tar.gz
RUN [ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL)
RUN wget ${psol_url}
RUN tar -xzvf $(basename ${psol_url})
RUN cd ..


# Nginx
RUN wget -O nginx.tar.gz -c  ${ng_url}
RUN tar zxf nginx.tar.gz
RUN ./configure --add-module=../incubator-pagespeed-ngx-1.13.35.2-stable --add-module=../ngx_brotli --with-openssl=../openssl --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module
