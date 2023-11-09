FROM registry.access.redhat.com/ubi9/ubi-minimal as tools-builder

COPY fetch-tools.sh /fetch-tools.sh

RUN microdnf --disableplugin=subscription-manager install -y bash tar gzip zip xz unzip ; \
  chmod +x /fetch-tools.sh ; \
  /fetch-tools.sh

FROM registry.access.redhat.com/ubi9/ubi-minimal

ARG USER_HOME_DIR="/home/user"
ARG WORK_DIR="/projects"
ARG JAVA_PACKAGE=java-17-openjdk-devel
ENV HOME=${USER_HOME_DIR}
ENV BUILDAH_ISOLATION=chroot
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
ENV GRAALVM_HOME=/usr/local/tools/graalvm
ENV JAVA_HOME=/etc/alternatives/jre_17_openjdk
ENV PATH=${PATH}:/usr/local/tools/bin:/usr/local/tools/node/bin
ENV JBANG_DIR=/usr/local/tools/jbang
COPY --from=tools-builder /tools/ /usr/local/tools
COPY --chown=0:0 entrypoint.sh /
RUN microdnf --disableplugin=subscription-manager install -y procps-ng openssl compat-openssl11 libbrotli git tar gzip zip xz unzip which shadow-utils bash zsh vi wget jq podman buildah skopeo podman-docker glibc-devel zlib-devel gcc libffi-devel libstdc++-devel gcc-c++ glibc-langpack-en ca-certificates python3-pip python3-devel ${JAVA_PACKAGE}; \
  microdnf update -y ; \
  microdnf clean all ; \
  mkdir -p ${USER_HOME_DIR} ; \
  mkdir -p ${WORK_DIR} ; \
  mkdir -p /usr/local/bin ; \
  setcap cap_setuid+ep /usr/bin/newuidmap ; \
  setcap cap_setgid+ep /usr/bin/newgidmap ; \
  mkdir -p ${HOME}/.config/containers ; \
  touch /etc/subgid /etc/subuid ; \
  chmod -R g=u /etc/passwd /etc/group /etc/subuid /etc/subgid ; \
  npm install -g @angular/cli ; \
  npm install -g serverless ; \
  mkdir -p ${JBANG_DIR} ; \
  curl -Ls https://sh.jbang.dev | bash -s - app setup ; \
  ln -s ${JBANG_DIR}/bin/jbang /usr/local/tools/bin/jbang ; \
  chgrp -R 0 /home ; \
  chmod +x /entrypoint.sh ; \
  chmod -R g=u /home ${WORK_DIR}
USER 10001
WORKDIR ${WORK_DIR}
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "tail", "-f", "/dev/null" ]