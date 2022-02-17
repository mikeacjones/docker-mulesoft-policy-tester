#!/bin/bash
INITIAL_VERSION=$(sed '5!d' $MULE_HOME/policy-source/policy-config.json | awk -F'"' '{print $4}')
export VERSION=${INITIAL_VERSION}
cd ${MULE_HOME}/policy-source
mvn clean package
cp ./target/*.jar ${MULE_HOME}/policies/policy-templates/
cp policy-config.json ${MULE_HOME}/policies/offline-policies/

#${MULE_HOME}/bin/mule -M-Danypoint.platform.gatekeeper=disabled