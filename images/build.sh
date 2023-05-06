#!/usr/bin/env bash

MAVEN_VERSION=${MAVEN_VERSION:=3.8.8}
QUARKUS_VERSION=${QUARKUS_VERSION:=2.16.1.Final}
NODE_VERSION=${NODE_VERSION:=v18.15.0}
MANDREL_VERSION=${MANDREL_VERSION:=22.3.0.1-Final}
KUBEDOCK_VERSION=${KUBEDOCK_VERSION:=0.9.2}
TOOLS_IMAGE_PATH=${TOOLS_IMAGE_PATH:=quay.io/cgruver0/che/dev-tools}
TOOLS_IMAGE_TAG=${TOOLS_IMAGE_TAG:=latest}
DEMO_IMAGE_PATH=${DEMO_IMAGE_PATH:=quay.io/cgruver0/che/che-demo-app}
DEMO_IMAGE_TAG=${DEMO_IMAGE_TAG:=latest}
TOOLS_DIR=${TOOLS_DIR:=./tools}

function getTools() {
  rm -rf ${TOOLS_DIR}
  mkdir -p ${TOOLS_DIR}/bin

  ## Install Apache Maven
  TEMP_DIR="$(mktemp -d)" 
    mkdir -p ${TOOLS_DIR}/maven ${TOOLS_DIR}/maven/ref 
    curl -fsSL -o ${TEMP_DIR}/apache-maven.tar.gz https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz 
    tar -xzf ${TEMP_DIR}/apache-maven.tar.gz -C ${TOOLS_DIR}/maven --strip-components=1  
  rm -rf "${TEMP_DIR}"

  ## Install Mandrel (GraalVM)
  TEMP_DIR="$(mktemp -d)"
    mkdir -p ${TOOLS_DIR}/graalvm 
    curl -fsSL -o ${TEMP_DIR}/mandrel-java11-linux-amd64-${MANDREL_VERSION}.tar.gz https://github.com/graalvm/mandrel/releases/download/mandrel-${MANDREL_VERSION}/mandrel-java17-linux-amd64-${MANDREL_VERSION}.tar.gz 
    tar xzf ${TEMP_DIR}/mandrel-java11-linux-amd64-${MANDREL_VERSION}.tar.gz -C ${TOOLS_DIR}/graalvm --strip-components=1 
  rm -rf "${TEMP_DIR}"

  ## Install YQ
  TEMP_DIR="$(mktemp -d)" 
    YQ_VER=$(basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/mikefarah/yq/releases/latest))
    curl -fsSL -o ${TEMP_DIR}/yq.tar.gz https://github.com/mikefarah/yq/releases/download/${YQ_VER}/yq_linux_amd64.tar.gz 
    tar -xzf ${TEMP_DIR}/yq.tar.gz -C ${TEMP_DIR} 
    cp ${TEMP_DIR}/yq_linux_amd64 ${TOOLS_DIR}/bin/yq 
    chmod +x ${TOOLS_DIR}/bin/yq 
  rm -rf "${TEMP_DIR}" 

  ## Install Quarkus CLI
  TEMP_DIR="$(mktemp -d)" 
    mkdir -p ${TOOLS_DIR}/quarkus-cli/lib 
    mkdir ${TOOLS_DIR}/quarkus-cli/bin 
    curl -fsSL -o ${TEMP_DIR}/quarkus-cli.tgz https://github.com/quarkusio/quarkus/releases/download/${QUARKUS_VERSION}/quarkus-cli-${QUARKUS_VERSION}.tar.gz 
    tar -xzf ${TEMP_DIR}/quarkus-cli.tgz -C ${TEMP_DIR} 
    cp ${TEMP_DIR}/quarkus-cli-${QUARKUS_VERSION}/bin/quarkus ${TOOLS_DIR}/quarkus-cli/bin 
    cp ${TEMP_DIR}/quarkus-cli-${QUARKUS_VERSION}/lib/quarkus-cli-${QUARKUS_VERSION}-runner.jar ${TOOLS_DIR}/quarkus-cli/lib 
    chmod +x ${TOOLS_DIR}/quarkus-cli/bin/quarkus  
  rm -rf "${TEMP_DIR}" 

  ## Install Kubedock
  TEMP_DIR="$(mktemp -d)" 
    curl -fsSL -o ${TEMP_DIR}/kubedock.tgz https://github.com/joyrex2001/kubedock/releases/download/${KUBEDOCK_VERSION}/kubedock_${KUBEDOCK_VERSION}_linux_amd64.tar.gz 
    tar -xzf ${TEMP_DIR}/kubedock.tgz  -C ${TEMP_DIR}
    cp ${TEMP_DIR}/kubedock ${TOOLS_DIR}/bin 
    chmod +x ${TOOLS_DIR}/bin/kubedock 
  rm -rf "${TEMP_DIR}"

  ## NodeJS
  TEMP_DIR="$(mktemp -d)"
  curl -fsSL -o ${TEMP_DIR}/node.tz https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.xz
  tar -x --no-auto-compress -f ${TEMP_DIR}/node.tz -C ${TEMP_DIR}
  mv ${TEMP_DIR}/node-${NODE_VERSION}-linux-x64 ${TOOLS_DIR}/node
  rm -rf "${TEMP_DIR}"

  ## Helm
  TEMP_DIR="$(mktemp -d)"
  HELM_VERSION=$(basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/helm/helm/releases/latest))
  curl -fsSL -o ${TEMP_DIR}/helm.tgz https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz
  tar -xzf ${TEMP_DIR}/helm.tgz -C ${TEMP_DIR}
  mv ${TEMP_DIR}/linux-amd64/helm ${TOOLS_DIR}/bin/helm
  chmod +x ${TOOLS_DIR}/bin/helm
  rm -rf "${TEMP_DIR}"

  ## Github CLI
  TEMP_DIR="$(mktemp -d)"
  GH_VERSION=$(basename $(curl -LsI -o /dev/null -w %{url_effective} https://github.com/cli/cli/releases/latest) | cut -d'v' -f2)
  GH_ARCH="linux_amd64"
  GH_TGZ_URL="https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_${GH_ARCH}.tar.gz"
  curl -fsSL -o ${TEMP_DIR}/gh.tgz "${GH_TGZ_URL}"
  tar -zxf ${TEMP_DIR}/gh.tgz -C ${TEMP_DIR}
  mv ${TEMP_DIR}/gh_${GH_VERSION}_${GH_ARCH}/bin/gh ${TOOLS_DIR}/bin/
  chmod +x ${TOOLS_DIR}/bin/gh
  rm -rf "${TEMP_DIR}"

  ## Create Symbolic Links to executables
  cd ${TOOLS_DIR}/bin
  ln -s ../quarkus-cli/bin/quarkus quarkus
  ln -s ../maven/bin/mvn mvn
  ln -s ../node/bin/node node
  ln -s ../node/bin/npm npm
  ln -s ../node/bin/corepack corepack
  ln -s ../node/bin/npx npx
  ln -s /projects/bin/oc oc
  ln -s /projects/bin/kubectl kubectl
  cd -
}

function buildToolsImage() {
  podman build -t ${TOOLS_IMAGE_PATH}:${TOOLS_IMAGE_TAG} -f dev-tools.Containerfile .
  podman push ${TOOLS_IMAGE_PATH}:${TOOLS_IMAGE_TAG}
}

function buildDevImage() {
  podman build -t ${DEMO_IMAGE_PATH}:${DEMO_IMAGE_TAG} --build-arg TOOLS_IMAGE_TAG=${TOOLS_IMAGE_TAG} -f che-demo-app.Containerfile .
  podman push ${DEMO_IMAGE_PATH}:${DEMO_IMAGE_TAG}
}

for i in "$@"
do
  case $i in
    -g)
      getTools
    ;;
    -t)
      buildToolsImage
    ;;
    -d)
      buildDevImage
    ;;
    *)
       # catch all
    ;;
  esac
done
