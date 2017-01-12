#!/bin/bash -eu

# Dependencies
#   gettext (envsubst)

# Config
EASYRSA_DIR="/usr/local/EasyRSA"
PKI_DIR="${EASYRSA_DIR}/pki"
CLIENTS_DIR=`dirname $0`
WORK_DIR="${CLIENTS_DIR}/tmp"
TEMPLATE_FILE="${CLIENTS_DIR}/template.ovpn"
CONFIG_FILE="config.ovpn"

if [ $# -ne 1 ]; then
	echo -e "Usage:\n  ./create.sh common.name" 1>&2
	exit 1
fi

# クライアント用の秘密鍵/証明書を生成
CN=${1}
CLIENT_KEY="${PKI_DIR}/private/${CN}.key"
CLIENT_CRT="${PKI_DIR}/issued/${CN}.crt"
CLIENT_REQ="${PKI_DIR}/reqs/${CN}.req"

if [ -e ${CLIENT_CRT} ]; then
	echo "User \"${CN}\" already exists."
	exit 1
fi

set +e

cd ${EASYRSA_DIR}
./easyrsa build-client-full ${CN} nopass
RESULT=$?
cd - > /dev/null 

if [ ${RESULT} -ne 0 ]; then
	rm ${CLIENT_KEY} ${CLIENT_REQ}
	exit 1
fi

set -e

# 各種ファイルと設定ファイルを zip で固める
rm -rf ${WORK_DIR}
mkdir -p ${WORK_DIR}

cp ${PKI_DIR}/ca.crt ${WORK_DIR}
cp ${CLIENT_KEY} ${WORK_DIR}
cp ${CLIENT_CRT} ${WORK_DIR}

cat ${TEMPLATE_FILE} | CN=${CN} envsubst > ${WORK_DIR}/${CONFIG_FILE}

OUTPUT_FILE="${CLIENTS_DIR}/${CN}.zip" 

zip -j ${OUTPUT_FILE} ${WORK_DIR}/*

echo -e "\n${OUTPUT_FILE} generated.\n"

rm -rf ${WORK_DIR}
