# Base image; setting platform because I'm on an M1 Mac which Tanuki doesn't like
# FROM --platform=linux/amd64 ubuntu:latest
FROM ubuntu:latest

# Set which version of mule to pull down and run
ENV MULE_VERSION=4.4.0
ENV MULE_HOME=/opt/mule
ENV STARTING_VERSION=2.1.10

# Install Java and utilities
RUN apt-get update
RUN apt-get install -qq openjdk-11-jdk-headless
RUN apt-get install -qq wget
RUN apt-get install -qq unzip
RUN apt-get install -qq maven
RUN apt-get install -qq curl

# Set our working directory
WORKDIR /opt

# Download mulesoft runtime and symlink the extracted folder to ${MULE_HOME}
RUN wget https://s3.amazonaws.com/new-mule-artifacts/mule-ee-distribution-standalone-${MULE_VERSION}.zip
RUN unzip mule-ee-distribution-standalone-${MULE_VERSION}.zip
RUN rm mule-ee-distribution-standalone-${MULE_VERSION}.zip
RUN ln -s /opt/mule-enterprise-standalone-${MULE_VERSION}/ ${MULE_HOME}

# Add support for M1 Macs by patching Tanuki.. 
RUN wget https://download.tanukisoftware.com/wrapper/3.5.49/wrapper-delta-pack-3.5.49.zip
RUN unzip wrapper-delta-pack-3.5.49.zip
RUN rm wrapper-delta-pack-3.5.49.zip
RUN cp ./wrapper-delta-pack-3.5.49/bin/* ${MULE_HOME}/lib/boot/exec/
RUN cp ./wrapper-delta-pack-3.5.49/lib/* ${MULE_HOME}/lib/boot/
# It isn't reading the arch correctly. This is easier than actually updating the mule file in bin
RUN cp ${MULE_HOME}/lib/boot/exec/wrapper-linux-arm-64 ${MULE_HOME}/lib/boot/exec/wrapper-linux-aarch64-
# This is pretty dirty but haven't spent the time yet to see where you configure the version of Tanuki to use
RUN cp ${MULE_HOME}/lib/boot/wrapper.jar ${MULE_HOME}/lib/boot/wrapper-3.5.45.jar

# Copy over Apps and Domains
COPY apps/ ${MULE_HOME}/apps/
COPY domains/ ${MULE_HOME}/domains/

EXPOSE 8081/tcp

# Setup mount points and folders for policy testing
RUN mkdir /opt/mule/policy-source/
VOLUME ["/opt/mule/apps", "/opt/mule/policies/offline-policies", "/opt/mule/policies/policy-templates", "/opt/mule/policy-source"]

# Copy over scripts and create bash alias
COPY start.sh /opt/mule/start.sh
RUN chmod +x /opt/mule/start.sh
COPY redeploy.sh /opt/mule/redeploy.sh
RUN chmod +x /opt/mule/redeploy.sh
RUN echo "alias update='${MULE_HOME}/redeploy.sh'" >> ~/.bash_aliases


#CMD ["/bin/bash"]
CMD ["sh", "-c", "/opt/mule/start.sh ; /opt/mule/bin/mule start -M-Danypoint.platform.gatekeeper=disabled ; /bin/bash"]