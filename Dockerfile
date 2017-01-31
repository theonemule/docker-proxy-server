FROM ubuntu
MAINTAINER blaize.net

ENV BLACKLIST adult,virusinfected,warez
ENV IP_OR_HOSTNAME 192.168.99.101

RUN apt-get update && \
	apt-get install -y squid squidguard lighttpd

ADD squid.conf /etc/squid/squid.conf
ADD blacklists /opt/blacklists
ADD build-squidguard-conf.sh /build-squidguard-conf.sh
ADD block.html /var/www/html/block.html
ADD start.sh /start.sh
RUN /bin/bash /build-squidguard-conf.sh


CMD /bin/bash /start.sh