#! /bin/bash

case "$1" in
	start) 
		echo -n "[*] Backed default configuration"
		oc get oauth cluster -o yaml > default.yaml
		echo -n "[*] Starting OAuth with users Lab ......"
		oc new-project opslab
		echo -e "[*] Objective \n- Create user: \n1.dd \n2.waiwai \n3.phyophyo \n4.yamin \n5.admin \n6.guest with password redhat123 using HTPasswd identify provider. \n- Give admin permission to dd and admin users at opslab project. \n- Create a group name devops and add waiwai, phyophyo, yamin to devops. \n- Give edit permission to devops group at opslab project. \n- Give basic user(basic-users) permission to guest user at opslab project. \n- Give cluster admin permissions to admin user. \n- Create deployment httpd using image httpd:2.4 in opslab project as an user in devops group."
		;;
	grade)
		if [ $(oc get oauth cluster -o json | jq -r .spec.identityProviders[1].name) == "HTpasswd_Provider" ]
		then
			echo "[+] Success Identity Providers setup"
		else
			echo "[-] Failed Identity Providers setup"
		fi
		if [ $(oc auth can-i '*' '*' --as admin) == 'yes' ]
		then
			echo "[+] Success admin to give cluster admin role"
		else
			echo "[-] Failed admin to give cluster admin role"
		fi
		if [ $(oc auth can-i 'create' 'deployments' --namespace opslab --as dd) == 'yes' -a  $(oc auth can-i 'create' 'deployments' --all-namespaces --as dd) == 'no' ]
		then
			echo "[+] Success dd to give admin to opslab project"
		else
			echo "[-] Failed dd to give admin to opslab project"
		fi
		if [ $(oc auth can-i 'create' 'deployments' --namespace opslab --as guest) == 'no' -a $(oc auth can-i 'list' 'pod' --namespace opslab --as guest) == 'yes' ]
		then
			echo "[+] Success guest user to give view only to opslab project"
		else
			echo "[-] Failed guest user to give view only to opslab project"
		fi
		if [ $(oc auth can-i create deployments --namespace opslab --as waiwai --as-group devops) == 'yes' -a $(oc auth can-i create deployments --all-namespaces --as waiwai --as-group devops) == 'no' -a $(oc auth can-i create deployments --namespace opslab --as phyophyo --as-group devops) == 'yes' -a $(oc auth can-i create deployments --all-namespaces --as phyophyo --as-group devops) == 'no' -a $(oc auth can-i create deployments --namespace opslab --as yamin --as-group devops) == 'yes' -a $(oc auth can-i create deployments --all-namespaces --as yamin --as-group devops) == 'no' ]
		then
			echo "[+] Success group and users permissions at opslab project"
		else
			echo "[-] Failed group and users permissions at opslab project"
		fi
		if [ $(oc get $(oc get pod -o Name -n opslab) -n opslab -o json | jq -r .status.phase) == 'Running' ]
		then
			echo "[+] Success running application httpd"
		else
			echo "[-] Failed running application httpd"
		fi
		;;
	finish)
		echo "[-] delete user and identity"
		oc policy remove-role-from-group edit devops
		oc delete groups devops
		oc policy remove-role-from-user basic-users guest
		oc policy remove-role-from-user admin dd
		oc adm policy remove-cluster-role-from-user cluster-admin admin
		oc get users |grep HTpasswd_Provider | awk '{ print "oc delete user " $1 }' | bash
		oc get identities -o Name| grep HTpasswd_Provider | xargs oc delete
		echo "[-] remove httpasswd identity provider and secret"
		oc get oauth cluster -o json | jq -r .spec.identityProviders[1].htpasswd.fileData.name | xargs oc -n openshift-config delete secret
		oc get oauth cluster -o yaml > restore.yaml
		tac restore.yaml | sed "1,6{d}" | tac | oc replace -f -
		echo "[-] delete opslab project"
		oc delete project opslab
		echo "[*] Finished"
		;;
	*)
		echo "Usage: $0 start|grade|finish"
		;;
esac
