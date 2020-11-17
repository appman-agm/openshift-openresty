FROM bcit/alpine:3.11

LABEL maintainer="jesse@weisner.ca"
LABEL alpine_version="3.11"
LABEL build_id="1605575475"

ENV RUNUSER nginx
ENV HOME /var/cache/nginx
ENV RESTY_SESSION_SECRET "00000000000000000000000000000000"

RUN wget 'http://openresty.org/package/admin@openresty.com-5ea678a6.rsa.pub' \
        -O '/etc/apk/keys/admin@openresty.com-5ea678a6.rsa.pub' \
 && echo "http://openresty.org/package/alpine/v3.11/main" \
        >> /etc/apk/repositories

RUN apk add --no-cache \
    openresty \
    openresty-opm \
    openresty-resty

RUN mkdir -p \
        /application \
        /config \
        /usr/local/openresty/nginx/conf.d \
 && chown -R 0:0 \
        /application \
        /config \
        /usr/local/openresty/nginx/conf \
        /usr/local/openresty/nginx/conf.d \
        /usr/local/openresty/nginx/logs \
        /usr/local/openresty/nginx \
        /var/run \
 && chmod 775 \
        /application \
        /config \
        /usr/local/openresty/nginx/conf \
        /usr/local/openresty/nginx/conf.d \
        /usr/local/openresty/nginx/logs \
        /usr/local/openresty/nginx \
        /var/run \
 && ln -sf /usr/local/openresty/nginx/html/index.html /application/index.html \
 && touch /usr/local/openresty/nginx/html/ping \
 && adduser --home /var/cache/nginx --gecos "Nginx Web Server" --system --disabled-password --no-create-home --ingroup root nginx

COPY 50-copy-config.sh /docker-entrypoint.d/
COPY 60-set-resty-env.sh /docker-entrypoint.d/
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY default.conf /usr/local/openresty/nginx/conf.d/default.conf
COPY 00-openresty.conf /usr/local/openresty/nginx/conf.d/00-openresty.conf
COPY resty-00-set.conf /usr/local/openresty/nginx/conf/resty-00-set.conf

USER nginx
WORKDIR /application

EXPOSE 8080

CMD ["/usr/local/openresty/nginx/sbin/nginx", "-g", "daemon off;"]
