#!/usr/bin/env sh
sh
varnishd -j unix,user=varnish \
  -T :6082 \
  -a :6081 \
  -s malloc,1G \
  -F \
  -f /etc/varnish/default.vcl
