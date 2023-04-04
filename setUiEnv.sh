#!/usr/bin/env bash

for i in "$@"
do
  case $i in
    -f=*)
      ENV_FILE_PATH="${i#*=}"
    ;;
    -s=*)
      SOURCE_FILE_PATH="${i#*=}"
    ;;
    -c=*)
      CONTAINER_NAME="${i#*=}"
    ;;
    -w=*)
      WORKSPACE_NAME="${i#*=}"
    ;;
    -p=*)
      TARGET_PORT="${i#*=}"
    ;;
    -e=*)
      ENDPOINT_NAME="${i#*=}"
    ;;
    -v=*)
      ENV_VAR="${i#*=}"
    ;;
  esac
done

if [[ ! -f ${ENV_FILE_PATH} ]]
then
  cp ${SOURCE_FILE_PATH} ${ENV_FILE_PATH}
fi

WORKSPACE_ID=$(oc get devworkspace ${WORKSPACE_NAME} -o jsonpath={.status.devworkspaceId})
API_ROUTE=https://$(oc get route ${WORKSPACE_ID}-${CONTAINER_NAME}-${TARGET_PORT}-${ENDPOINT_NAME} -o jsonpath={.spec.host})
sed -i "s|${ENV_VAR}:.*|${ENV_VAR}: \'${API_ROUTE}\'|g" ${ENV_FILE_PATH}
