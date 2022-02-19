#!/bin/bash

POLICY_CONFIG=${MULE_HOME}/policy-source/policy-config.json
if [ ! -f "$POLICY_CONFIG" ]; then
  echo "You must create a policy-config.json file! See the readme for more information."
  exit 1
fi


# copy the policy over to a staging directory; we do this so that we ensure we aren't going to create any changes git might pick up when doing builds
cp -r ${MULE_HOME}/policy-source/* ${MULE_HOME}/policy-staging/
cd ${MULE_HOME}/policy-staging

# make sure the groupID matches the policy-config.json file
GROUP_ID=$(sed '3!d' policy-config.json | awk -F'"' '{print $4}')
sed -i "6s/<groupId>.*<\/groupId>/<groupId>$GROUP_ID<\/groupId>/" pom.xml

# update the version in the pom.xml
INITIAL_VERSION=$(sed '5!d' policy-config.json | awk -F'"' '{print $4}')
sed -i "8s/<version>.*<\/version>/<version>$INITIAL_VERSION<\/version>/" pom.xml

# remove the TRUSTSTORE place holder
sed -i "s/'{{ TRUSTSTORE }}'/<tls:trust-store insecure=\"true\" \/>/" src/main/mule/template.xml

export VERSION=${INITIAL_VERSION}
mvn clean package
cp ./target/*.jar ${MULE_HOME}/policies/policy-templates/
cp policy-config.json ${MULE_HOME}/policies/offline-policies/