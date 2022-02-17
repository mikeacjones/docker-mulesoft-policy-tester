#!/bin/bash

cd ${MULE_HOME}/policy-source
CURRENT_VERSION=$(sed '5!d' $MULE_HOME/policies/offline-policies/policy-config.json | awk -F'"' '{print $4}')
INITIAL_VERSION=$(sed '5!d' $MULE_HOME/policy-source/policy-config.json | awk -F'"' '{print $4}')
NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}')

export VERSION=$NEW_VERSION
mvn clean package
cp ./target/*.jar ${MULE_HOME}/policies/policy-templates/

sed "5s/$INITIAL_VERSION/$NEW_VERSION/" ${MULE_HOME}/policy-source/policy-config.json > ${MULE_HOME}/policies/offline-policies/policy-config.json