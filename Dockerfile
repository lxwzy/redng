FROM ubuntu

ENV OS_VERSION=openssl-1.1.1
ENV os_url=https://www.openssl.org/source/openssl-1.1.1.tar.gz

ENV NPS_VERSION=1.13.35.2-stable
ENV psol_url=https://dl.google.com/dl/page-speed/psol/1.13.35.2-x64.tar.gz

ENV NG_VERSION=nginx-1.15.3
ENV ng_url=https://nginx.org/download/nginx-1.15.3.tar.gz

COPY 404.html /usr/share/errpg/
COPY 500.html /usr/share/errpg/

RUN apt update \
	&&apt install -y build-essential libpcre3 libpcre3-dev zlib1g-dev unzip git wget uuid-dev \
	&&wget -O openssl.tar.gz -c ${os_url} && tar zxf openssl.tar.gz && mv ${OS_VERSION}/ openssl \
	&&git clone --recursive https://github.com/google/ngx_brotli.git \
	&&wget -O nginx.tar.gz -c  ${ng_url}&&tar zxf nginx.tar.gz&&cd ${NG_VERSION} \
	&&sed -i 's/\"nginx\/\" NGINX_VERSION/\"RedHome\"/g' src/core/nginx.h \
	&&sed -i 's/\"NGINX\"/\"RedHome\"/g' src/core/nginx.h \
	&&sed -i 's/\"Server: nginx\"/\"Server: RedHome\"/g' src/http/ngx_http_header_filter_module.c \
	&&sed -i 's/\"Server: \" NGINX_VER_BUILD/\"Server: RedHome\"/g' src/http/ngx_http_header_filter_module.c \
	&&sed -i 's/\"Server: \" NGINX_VER/\"Server: RedHome\"/g' src/http/ngx_http_header_filter_module.c \
	&&/usr/sbin/groupadd -f nginx \
	&&/usr/sbin/useradd -g nginx nginx \
	&&./configure --add-module=../ngx_brotli --with-openssl=../openssl --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie' \
	&&make \
	&&make install \
	&& apt purge -y  build-essential libpcre3-dev zlib1g-dev uuid-dev git wget unzip \
        && apt autoremove -y \
	&& cd / \
	&& rm -rf ${NG_VERSION} &&rm nginx.tar.gz \
	&& rm -rf openssl &&rm openssl.tar.gz \
	&& rm -rf ngx_brotli \
	&& rm -rf /var/lib/apt/lists/* \
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/access.log \
	&& mkdir /var/cache/nginx/ && chmod 777 /var/cache/nginx/

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
