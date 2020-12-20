#! /bin/bash

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
		for user in student1 student2 student3 student4; do oc create user $user; done
		echo -e "${YE}[*]${NC} Objective \n- Create a project called ${CY}opslab${NC}. \n- Create a group called ${CY}devops${NC} and add ${CY}student1${NC}, ${CY}student2${NC} and ${CY}student3${NC} to ${BL}devops${NC} group. \n- Grant admin access to the ${CY}devops${NC} group for the project ${BL}opslab${NC}. \n- Create a custom role ${CY}banana${NC} that only allows to get pod infromation from ${OR}opslab${NC}. \n- Assign the ${CY}banana${NC} role to ${OR}student4${NC} in ${CY}opslab${NC} project."
		;;
	grade)
		if [[ $(oc get project opslab -o json 2>/dev/null |jq -r .metadata.name ) == 'opslab' ]]
		then
			echo -e "${GR}[+]${NC} Success opslab project was created"
		else
			echo -e "${RE}[-]${NC} Failed to create opslab project"
		fi
		if [ $(oc get groups devops -o json 2>/dev/null |jq -r .metadata.name) == 'devops' ]
		then
			echo -e "${GR}[+]${NC} Success devops groups was created"
		else
			echo -e "${RE}[-]${NC} Failed to create devops groups"
		fi
		if [ $(oc auth can-i create deployments --namespace opslab --as student1 --as-group devops) == 'yes' -a $(oc auth can-i create deployments --all-namespaces --as student1 --as-group devops) == 'no' -a $(oc auth can-i create deployments --namespace opslab --as student2 --as-group devops) == 'yes' -a $(oc auth can-i create deployments --all-namespaces --as student2 --as-group devops) == 'no' -a $(oc auth can-i create deployments --namespace opslab --as student3 --as-group devops) == 'yes' -a $(oc auth can-i create deployments --all-namespaces --as student3 --as-group devops) == 'no' ]
		then
			echo -e "${GR}[+]${NC} Success group and users permissions at opslab project"
		else
			echo -e "${RE}[-]${NC} Failed group and users permissions at opslab project"
		fi
		if [ $(oc -n opslab get role banana -o json 2>/dev/null |jq -r .rules[].resources[]) == 'pods' -a $(oc -n opslab get role banana -o json 2>/dev/null |jq -r .rules[].verbs[]) == 'get' ]
		then
			echo -e "${GR}[+]${NC} Success role banana created for opslab"
		else
			echo -e "${RE}[-]${NC} Failed to create banana role for opslab"
		fi
		if [ $(oc auth can-i get pods --namespace opslab --as student4) == 'yes' -a $(oc auth can-i list pods --namespace opslab --as student4) == 'no' ]
		then
			echo -e "${GR}[+]${NC} Success assign student4 with role banana"
		else
			echo -e "${RE}[-]${NC} Failed to assign student4 with role banana in opslab project"
		fi
		;;
	finish)
		echo -e "${RE}[-]${NC} delete users, group, role, rolebinding and project..."
		sleep 2
		oc policy remove-role-from-group edit devops -n opslab
		oc delete group devops
		oc delete rolebinding banana -n opslab
		oc delete role banana -n opslab
		for user in student1 student2 student3 student4; do oc delete user $user; done
		oc delete project opslab
		;;
	*)
		echo "Usage: $0 start|grade|finish"
		;;
esac
