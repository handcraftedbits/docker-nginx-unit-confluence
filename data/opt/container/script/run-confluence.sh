#!/bin/bash

. /opt/container/script/unit-utils.sh

# Check required environment variables and fix the NGINX unit configuration.

checkCommonRequiredVariables

notifyUnitLaunched

copyUnitConf nginx-unit-confluence > /dev/null

logUrlPrefix "confluence"

notifyUnitStarted

# Fix CONFLUENCE configuration.

confluence_config=/opt/confluence/conf/server.xml

cp /opt/container/template/server.xml.template ${confluence_config}

fileSubstitute ${confluence_config} NGINX_UNIT_HOSTS ${NGINX_UNIT_HOSTS}
fileSubstitute ${confluence_config} NGINX_URL_PREFIX `normalizeSlashesSingleSlashToEmpty ${NGINX_URL_PREFIX}`

# Import certificate (so we can integrate with other Atlassian product instances).

printf "changeit\nyes" | keytool -import -trustcacerts -alias root \
     -file /etc/letsencrypt/live/${NGINX_UNIT_HOSTS}/fullchain.pem -keystore ${JAVA_HOME}/jre/lib/security/cacerts

 # Start Confluence.

/opt/confluence/bin/start-confluence.sh -fg
