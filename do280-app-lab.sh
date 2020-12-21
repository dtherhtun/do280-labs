#!/bin/bash

NC='\033[0m'
RE='\033[0;31m'
GR='\033[0;32m'
OR='\033[0;33m'
BL='\033[0;34m'
CY='\033[0;36m'
YE='\033[1;33m'


case "$1" in
	start)
		echo -e "${YE}[*]${NC} Starting Lab......"
		sleep 2
        for pj in dev qa stag prod; do oc new-project $pj 1>/dev/null; done
        echo -e "${YE}[*]${NC} Objective \n- Create an application name ${CY}cake${NC} in ${OR}dev${NC} using this https://github.com/sclorg/cakephp-ex sources and expose application to public.\n- Create an application name ${CY}cheese-cake${NC} in ${OR}qa${NC} project using same sources and expose application to public with service name ${BL}cake-qa${NC}.\n- Create an application name ${CY}choco-cake${NC} in ${OR}stag${NC} project using same sources and expose application to public with ${BL}choco-cake${NC} subdomain with ${CY}custom${NC} tls.\n- Create an application name ${CY}milk-cake${NC} in ${OR}prod${NC} project using same sources and create service account called ${CY}cake${NC} with edit role."
        ;;
    grade)
        echo hello
        ;;
    finish)
        echo world
        for pj in dev qa stag prod; do oc delete project $pj; done
        ;;
    *)
        echo "Usage: $0 start|grade|finish"
        ;;
esac