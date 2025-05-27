#!/usr/bin/bash


bail() {
	echo "*** Health check failed: $1 ***" >&2
	exit 1
}


[ $(oc whoami) == system:admin ] || bail API

CONSOLE_HOST=$(oc get route console -n openshift-console -o jsonpath='{.spec.host}')

[ $(curl -s -o /dev/null -w '%{http_code}' https://${CONSOLE_HOST}) == 200 ] || bail CONSOLE
[ $(curl -L -s -o /dev/null -w '%{http_code}' https://${CONSOLE_HOST}/auth/login) == 200 ] || bail AUTH

[ $(oc get nodes | grep ' Ready' | wc -l) == 6 ] || bail NODES

# NOTE: This can fail if pods are in the process of restarting for some reason
[ $(oc get pods -A | grep -E -v '(NAMESPACE)|(Running)|(Completed)' | wc -l) == 0 ] || bail PODS
