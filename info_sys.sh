#!/bin/bash

echo "---infos generales sur le systeme---"
echo "Nom d'hote: $(hostname)"
echo "Uptime: $(uptme)"
echo ""

echo "--Infos sur l'OS---"
cat /etc/os-release
echo ""

echo "---Infos sur le noyau---"
echo "version du Noyau: $(uname -r)"echo "Toues les infos Uname: $(uname -a)"
echo " Details du fichier /proc/version:"
cat /proc/version
echo ""

echo " ---services actifs (Running)---"
systemctl list-unit-files --type=service --state=enabled --no-pager | grep -E '\.service' | awk '{print $1, $2}'
echo ""

echo "---Ports en Ecoute---"
ss -tulnp
echo ""
