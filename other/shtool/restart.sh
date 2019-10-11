#!/bin/sh
systemctl restart openvpn@server-udp.service;
systemctl restart fas.service;
systemctl restart iptables.service;
systemctl restart httpd.service;