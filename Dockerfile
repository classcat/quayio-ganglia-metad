FROM ubuntu:trusty
MAINTAINER ClassCat Co.,Ltd. <support@classcat.com>

########################################################################
# ClassCat/Ganglia-Gmetad Dockerfile
#   Maintained by ClassCat Co.,Ltd ( http://www.classcat.com/ )
########################################################################

#--- HISTORY -----------------------------------------------------------
# 02-jun-15 : created.
#-----------------------------------------------------------------------

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y upgrade \
  && apt-get install -y language-pack-en language-pack-en-base \
  && apt-get install -y language-pack-ja language-pack-ja-base \
  && update-locale LANG="en_US.UTF-8" \
  && apt-get install -y openssh-server supervisor rsyslog mysql-client \
  && apt-get install -y rrdtool gmetad ganglia-webfrontend \
  && apt-get clean \
  && mkdir -p /var/run/sshd \
  && sed -ri "s/^PermitRootLogin\s+.*/PermitRootLogin yes/" /etc/ssh/sshd_config \
  && cp -p /etc/ganglia-webfrontend/apache.conf /etc/apache2/sites-enabled/ganglia.conf
# RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

COPY assets/supervisord.conf /etc/supervisor/supervisord.conf

WORKDIR /opt
ADD assets/cc-init.sh /opt/cc-init.sh

EXPOSE 22

CMD /opt/cc-init.sh; service gmetad restart; /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
