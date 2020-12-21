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
        oc new-project labops
        echo -e "${YE}[*]${NC} Objective \n- Create a project called ${CY}opslab${NC}. \n- Create a quota called ${CY}object-counts${NC} that include 4 pods, 2 GB ram, 500m cpu, 2 replicasets, and 6 services in opslab project.\n- Create resource limits called ${CY}compute-resources${NC} in labops that is limits 4 cpu, 4GB ram, 8GB ephemeral-storage and request 1 cpu, 1GB ram, 2GB ephemeral-storage and include 4 pods only."
        ;;
    grade)
        if [[ $(oc get project opslab -o json 2>/dev/null |jq -r .metadata.name ) == 'opslab' ]]
		then
			echo -e "${GR}[+]${NC} Success opslab project was created"
		else
			echo -e "${RE}[-]${NC} Failed to create opslab project"
		fi
        if [ $(oc -n opslab get quota object-counts -o json 2>/dev/null | jq -r '.spec.hard["count/replicasets.extensions"]') == '2' -a $( oc -n opslab get quota object-counts -o json 2>/dev/null | jq -r .spec.hard.cpu) == '500m' -a $( oc -n opslab get quota object-counts -o json 2>/dev/null | jq -r .spec.hard.memory) == '2Gi' -a $( oc -n opslab get quota object-counts -o json 2>/dev/null | jq -r .spec.hard.services) == '6' -a $( oc -n opslab get quota object-counts -o json 2>/dev/null | jq -r .spec.hard.pods) == '4' ]
        then
            echo -e "${GR}[+]${NC} Success object-counts quota was created in opslab project"
        else
            echo -e "${RE}[-]${NC} Failed to create object-counts quota in opslab project"
        fi
        if [ $(oc -n labops get quota compute-resources -o json 2>/dev/null | jq -r '.spec.hard["limits.cpu"]') == '4' -a $(oc -n labops get quota compute-resources -o json 2>/dev/null | jq -r '.spec.hard["limits.ephemeral-storage"]') == '8Gi' -a $(oc -n labops get quota compute-resources -o json 2>/dev/null | jq -r '.spec.hard["limits.memory"]') == '4Gi' -a $(oc -n labops get quota compute-resources -o json 2>/dev/null | jq -r '.spec.hard["requests.memory"]') == '1Gi' -a $(oc -n labops get quota compute-resources -o json 2>/dev/null | jq -r '.spec.hard["requests.cpu"]') == '1' -a $(oc -n labops get quota compute-resources -o json 2>/dev/null | jq -r '.spec.hard["requests.ephemeral-storage"]') == '2Gi' -a $(oc -n labops get quota compute-resources -o json 2>/dev/null | jq -r .spec.hard.pods) == '4' ]
        then
            echo -e "${GR}[+]${NC} Success compute-resources limits was created in labops project"
        else
            echo -e "${RE}[-]${NC} Failed to create compute-resources limits in labops project"
        fi
        ;;
    finish)
        echo -e "${RE}[-]${NC} delete quota and project..."
        sleep 2
        oc -n opslab delete quota object-counts
		oc -n labops delete quota compute-resources
        for pj in opslab labops; do oc delete project $pj; done
        ;;
    *)
        echo "Usage: $0 start|grade|finish"
		;;
esac

#sample
# kubectl create quota test --hard=count/deployments.extensions=2,count/replicasets.extensions=4,count/pods=3,count/secrets=4
