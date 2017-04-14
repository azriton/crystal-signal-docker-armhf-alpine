FROM armhf/alpine

RUN set -ex \
 && apk add --no-cache apache2 curl python \
 && apk add --no-cache --virtual build-dependencies gcc make musl-dev openssl py2-pip python-dev rsync \
 && pip install --upgrade pip \
 && pip install pigpio \
 \
 && curl -sSL 'https://raw.githubusercontent.com/azriton/crystal-signal-armhf-alpine/master/install.sh' | sh \
 \
 && apk del --purge build-dependencies \
 && rm -fr /tmp/* \
 && rm -fr /root/.cache \
;


EXPOSE 80
CMD /usr/sbin/httpd -f /etc/apache2/httpd.conf && /usr/local/bin/LEDController.py
