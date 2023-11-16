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
    -v=*)
      ENV_VAR="${i#*=}"
    ;;
  esac
done

if [[ ! -f ${ENV_FILE_PATH} ]]
then
  cp ${SOURCE_FILE_PATH} ${ENV_FILE_PATH}
fi

echo "Enter the URL for the remote service:"

read API_ROUTE

sed -i "s|${ENV_VAR}:.*|${ENV_VAR}: \'${API_ROUTE}\'|g" ${ENV_FILE_PATH}