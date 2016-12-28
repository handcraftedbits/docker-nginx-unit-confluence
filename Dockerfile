FROM handcraftedbits/nginx-unit-java:8.112.15
MAINTAINER HandcraftedBits <opensource@handcraftedbits.com>

ARG CONFLUENCE_VERSION=6.0.3

COPY data /

RUN apk update && \
  apk add ca-certificates wget && \

  cd /opt && \
  wget https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONFLUENCE_VERSION}.tar.gz && \
  tar -xzvf atlassian-confluence-${CONFLUENCE_VERSION}.tar.gz && \
  rm atlassian-confluence-${CONFLUENCE_VERSION}.tar.gz && \
  mv atlassian-confluence-${CONFLUENCE_VERSION} confluence && \
  echo "confluence.home=/opt/data/confluence" > \
    /opt/confluence/confluence/WEB-INF/classes/confluence-init.properties && \

  apk del ca-certificates wget

EXPOSE 8090

CMD ["/bin/bash", "/opt/container/script/run-confluence.sh"]
