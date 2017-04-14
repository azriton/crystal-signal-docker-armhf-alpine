FROM armhf/alpine

RUN apk --no-cache upgrade \
 && apk add --no-cache curl apache2 python \
 && apk add --no-cache --virtual build-dependencies openssl rsync py2-pip gcc make python-dev musl-dev \
 && pip install --upgrade pip \
 && pip install pigpio \
 \
 && curl -sSL https://raw.githubusercontent.com/azriton/crystal-signal-armhf-alpine/master/install.sh | sh \
 \
 && apk del --purge build-dependencies \
 && rm -fr /tmp/* \
 && rm -fr /root/.cache \
;


EXPOSE 80
CMD /usr/sbin/httpd -f /etc/apache2/httpd.conf && /usr/local/bin/LEDController.py
