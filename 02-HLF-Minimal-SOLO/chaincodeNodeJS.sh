#!/bin/bash

set -ev

printf "Executing chaincodeNodeJS.sh...\n\n"

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1
export CURRENT_DIR=$PWD

# 1. Installing chain code in NodeJS

# NOTE: The chaincode is installed as volume in container as:
# volumes:
# - ./chaincode/:/opt/gopath/src/github.com/chaincode

docker exec cli peer chaincode install -n mycounter -v 1.0 -p /opt/gopath/src/github.com/chaincode/nodeJS/ -l node

printf "\nChaincode installed\n\n"

sleep 1

# 2. Checks the chaincodes installed in the channel

docker exec cli peer chaincode list -C channel0 --installed

printf "\nChecked if the chaincode is installed\n\n"

sleep 1

# 3. Instantiate the chaincode

docker exec cli peer chaincode instantiate \
--tls \
-o orderer0.ust.com:7050 \
--cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/ust.com/orderers/orderer0.ust.com/msp/tlscacerts/tlsca.ust.com-cert.pem \
-C channel0 \
-n mycounter \
-v 1.0 \
-c '{"Args":[""]}' \
-P "OR ('Org1MSP.member')" \
--collections-config /opt/gopath/src/github.com/chaincode/nodeJS/counter_config_ch0.json

printf "\nInstantiated the chaincode\n\n"

sleep 1

