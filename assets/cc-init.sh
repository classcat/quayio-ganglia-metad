#!/bin/bash

########################################################################
# ClassCat/Ganglia-Gmetad Asset files
# Copyright (C) 2015 ClassCat Co.,Ltd. All rights reserved.
########################################################################

#--- HISTORY -----------------------------------------------------------
# 02-jun-15 : ganglia-monitor required.
# 02-jun-15 : created.
#-----------------------------------------------------------------------


######################
### INITIALIZATION ###
######################

function init () {
  echo "ClassCat Info >> initialization code for ClassCat/Ganglia-Gmetad"
  echo "Copyright (C) 2015 ClassCat Co.,Ltd. All rights reserved."
  echo ""
}


############
### SSHD ###
############

function change_root_password() {
  if [ -z "${ROOT_PASSWORD}" ]; then
    echo "ClassCat Warning >> No ROOT_PASSWORD specified."
  else
    echo -e "root:${ROOT_PASSWORD}" | chpasswd
    # echo -e "${password}\n${password}" | passwd root
  fi
}


function put_public_key() {
  if [ -z "$SSH_PUBLIC_KEY" ]; then
    echo "ClassCat Warning >> No SSH_PUBLIC_KEY specified."
  else
    mkdir -p /root/.ssh
    chmod 0700 /root/.ssh
    echo "${SSH_PUBLIC_KEY}" > /root/.ssh/authorized_keys
  fi
}


###############
### GANGLIA ###
###############

function config_ganglia_monitor() {

  mkdir -p /etc/ganglia/conf.d
  cat << _EOT_ > /etc/ganglia/conf.d/cc-gmond.conf
cluster { 
  name = "${CLUSTER_NAME}" 
  /* name = "unspecified" */
  owner = "unspecified" 
  latlong = "unspecified" 
  url = "unspecified" 
} 

host { 
  location = "unspecified" 
} 

/*
udp_send_channel { 
  mcast_join = 239.2.11.71
  host = ${HOST_TO_SEND}
  port = 8649 
  ttl = 1 
} */

udp_recv_channel { 
  /* mcast_join = 239.2.11.71  */
  port = 8649 
  /* bind = 239.2.11.71 */
} 

tcp_accept_channel { 
  port = 8649 
} 
_EOT_
}

function config_ganglia_gmetad() {
  cat << _EOT_ > /etc/ganglia/gmetad.conf
data_source "${CLUSTER_NAME}" 60 localhost

case_sensitive_hostnames 0
_EOT_
}


##################
### SUPERVISOR ###
##################
# See http://docs.docker.com/articles/using_supervisord/

function proc_supervisor () {
  cat > /etc/supervisor/conf.d/supervisord.conf <<EOF
[program:ssh]
command=/usr/sbin/sshd -D

[program:apache2]
command=/usr/sbin/apache2ctl -D FOREGROUND

[program:rsyslog]
command=/usr/sbin/rsyslogd -n
EOF
}


### ENTRY POINT ###

init
change_root_password
put_public_key
config_ganglia_monitor
config_ganglia_gmetad
proc_supervisor

# /usr/bin/supervisord -c /etc/supervisor/supervisord.conf

exit 0


### End of Script ###
