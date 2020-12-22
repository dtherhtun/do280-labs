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
		echo -e "${YE}[*]${NC} Backed default configuration"
		oc get oauth cluster -o yaml > default.yaml
		echo -e "${YE}[*]${NC} Starting OAuth with users Lab ......"
		oc new-project opslab
		echo -e "${YE}[*]${NC} Objective \n- Create user: \n1.${OR}dd${NC} \n2.${OR}waiwai${NC} \n3.${OR}phyophyo${NC} \n4.${OR}yamin${NC} \n5.${OR}admin${NC} \n6.${OR}guest${NC} with password ${CY}redhat123${NC} using HTPasswd(name - HTpasswd_Provider) identify provider. \n- Give ${CY}admin${NC} permission to ${OR}dd${NC} and ${OR}admin${NC} users at ${GR}opslab${NC} project. \n- Create a group name ${CY}devops${NC} and add ${OR}waiwai${NC}, ${OR}phyophyo${NC}, ${OR}yamin${NC} to devops. \n- Give ${CY}edit${NC} permission to ${OR}devops${NC} group at opslab project. \n- Give ${CY}basic${NC} user(basic-users) permission to ${OR}guest${NC} user at opslab project. \n- Give ${CY}cluster admin${NC} permissions to ${OR}admin${NC} user. \n- Create deployment httpd using image ${BL}httpd:2.4${NC} in opslab project as an user in devops group."
		leave +0035
		;;
	grade)
		if [ $(oc get oauth cluster -o json |jq -r .spec.identityProviders[1].name) == "HTpasswd_Provider" ]
		then
			echo -e "${GR}[+]${NC} Success Identity Providers setup"
		else
			echo -e "${RE}[-]${NC} Failed Identity Providers setup"
		fi
		if [ $(oc auth can-i '*' '*' --as admin) == 'yes' ]
		then
			echo -e "${GR}[+]${NC} Success admin to give cluster admin role"
		else
			echo -e "${RE}[-]${NC} Failed admin to give cluster admin role"
		fi
		if [ $(oc auth can-i 'create' 'deployments' --namespace opslab --as dd) == 'yes' -a  $(oc auth can-i 'create' 'deployments' --all-namespaces --as dd) == 'no' ]
		then
			echo -e "${GR}[+]${NC} Success dd to give admin to opslab project"
		else
			echo -e "${RE}[-]${NC} Failed dd to give admin to opslab project"
		fi
		if [ $(oc auth can-i 'get' 'deployments' --namespace opslab --as guest) == 'no' -a $(oc auth can-i 'list' 'pod' --namespace opslab --as guest) == 'no' ]
		then
			echo -e "${GR}[+]${NC} Success guest user to give view only to opslab project"
		else
			echo -e "${RE}[-]${NC} Failed guest user to give view only to opslab project"
		fi
		if [ $(oc auth can-i create deployments --namespace opslab --as waiwai --as-group devops) == 'yes' -a $(oc auth can-i create deployments --all-namespaces --as waiwai --as-group devops) == 'no' -a $(oc auth can-i create deployments --namespace opslab --as phyophyo --as-group devops) == 'yes' -a $(oc auth can-i create deployments --all-namespaces --as phyophyo --as-group devops) == 'no' -a $(oc auth can-i create deployments --namespace opslab --as yamin --as-group devops) == 'yes' -a $(oc auth can-i create deployments --all-namespaces --as yamin --as-group devops) == 'no' ]
		then
			echo -e "${GR}[+]${NC} Success group and users permissions at opslab project"
		else
			echo -e "${RE}[-]${NC} Failed group and users permissions at opslab project"
		fi 
		#if [[ $(oc get $(oc get pod -o Name -n opslab 2>/dev/null) -n opslab -o json 2>/dev/null |jq -r .status.phase) == 'Running' ]]
		#then
		#	echo -e "${GR}[+]${NC} Success running application httpd"
		#else
		#	echo -e "${RE}[-]${NC} Failed running application httpd"
		#fi
		;;
	finish)
		echo -e "${RE}[-]${NC} delete user and identity"
		oc policy remove-role-from-group edit devops
		oc delete groups devops
		oc policy remove-role-from-user basic-users guest
		oc policy remove-role-from-user admin dd
		oc adm policy remove-cluster-role-from-user cluster-admin admin
		oc get users |grep HTpasswd_Provider | awk '{ print "oc delete user " $1 }' | bash
		oc get identities -o Name| grep HTpasswd_Provider | xargs oc delete
		echo -e "${RE}[-]${NC} remove httpasswd identity provider and secret"
		oc get oauth cluster -o json | jq -r .spec.identityProviders[1].htpasswd.fileData.name | xargs oc -n openshift-config delete secret
		oc get oauth cluster -o yaml > restore.yaml
		tac restore.yaml | sed "1,5{d}" | tac | oc replace -f -
		echo -e "${RE}[-]${NC} delete opslab project"
		oc delete project opslab
		echo -e "${YE}[*]${NC} Finished"
		;;
	*)
		echo "Usage: $0 start|grade|finish"
		;;
esac
