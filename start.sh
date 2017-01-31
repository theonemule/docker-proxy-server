#!/bin/bash

lighttpd -f /etc/lighttpd/lighttpd.conf
squid -N -d 1 -D