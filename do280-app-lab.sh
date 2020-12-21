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
        for pj in dev qa stag prod; do oc create project $pj; done
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