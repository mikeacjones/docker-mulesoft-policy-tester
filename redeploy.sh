#!/bin/bash

# copy the policy over to a staging directory; we do this so that we ensure we aren't going to create any changes git might pick up when doing builds
rm -rf ${MULE_HOME}/policy-staging
mkdir ${MULE_HOME}/policy-staging
cp -r ${MULE_HOME}/policy-source/* ${MULE_HOME}/policy-staging/
cd ${MULE_HOME}/policy-staging

# make sure the groupID matches the policy-config.json file
GROUP_ID=$(sed '3!d' policy-config.json | awk -F'"' '{print $4}')
sed -i "6s/<groupId>.*<\/groupId>/<groupId>sec.noname<\/groupId>/" pom.xml

# update the version in the pom.xml
CURRENT_VERSION=$(sed '5!d' $MULE_HOME/policies/offline-policies/policy-config.json | awk -F'"' '{print $4}')
INITIAL_VERSION=$(sed '5!d' $MULE_HOME/policy-source/policy-config.json | awk -F'"' '{print $4}')
NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}')
sed -i "8s/<version>.*<\/version>/<version>$NEW_VERSION<\/version>/" pom.xml

# remove the TRUSTSTORE place holder
sed -i "s/'{{ TRUSTSTORE }}'/<tls:trust-store insecure=\"true\" \/>/" src/main/mule/template.xml

mvn clean package
cp ./target/*.jar ${MULE_HOME}/policies/policy-templates/

sed "5s/$INITIAL_VERSION/$NEW_VERSION/" ${MULE_HOME}/policy-source/policy-config.json > ${MULE_HOME}/policies/offline-policies/policy-config.json