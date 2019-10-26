#!/bin/bash

set -ev

printf "Executing generate_config.sh...\n\n"

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1
export CURRENT_DIR=$PWD

# 1. Create the channel

# docker exec \
# -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.ust.com/users/Admin@org1.ust.com/msp" \
# -e "CORE_PEER_ADDRESS=peer0.org1.ust.com:7051" \
# -e "CORE_PEER_LOCALMSPID=Org1MSP" \
# -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.ust.com/peers/peer0.org1.ust.com/tls/ca.crt" \
# cli peer channel create -o orderer0.ust.com:7050 -c channel0 -f ./channel-artifacts/channel0.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/ust.com/orderers/orderer0.ust.com/msp/tlscacerts/tlsca.ust.com-cert.pem

# Reduced Alternative (the environment variables are not neccesary because these variables are set in docker-compose in cli service)
docker exec cli peer channel create -o orderer0.ust.com:7050 -c channel0 -f ./channel-artifacts/channel0.tx --tls \
--cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/ust.com/orderers/orderer0.ust.com/msp/tlscacerts/tlsca.ust.com-cert.pem
sleep 2

printf "\nChannel Created!\n\n"

# 2. Join the channel

# NOTE: To join channel0 we don't need pass the next variables because these variables are set in docker-compose in cli-service
# CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.ust.com/users/Admin@org1.ust.com/msp
# CORE_PEER_ADDRESS=peer0.org1.ust.com:7051
# CORE_PEER_LOCALMSPID=Org1MSP
# CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.ust.com/peers/peer0.org1.ust.com/tls/ca.crt
# If you want to join another peers, provide this info is mandatory
#
# The option -b indicates the path to file containing genesis block
docker exec cli peer channel join -b channel0.block
sleep 2

printf "\nClient joined to the channel\n\n"

# 3. Update Anchor Peers

# Signs and sends the supplied configtx update file to the channel.

# NOTE: Idem case of use of environment variables
docker exec cli peer channel update -o orderer0.ust.com:7050 -c channel0 \
-f ./channel-artifacts/Org1MSPanchorsChannel0.tx --tls \
--cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/ust.com/orderers/orderer0.ust.com/msp/tlscacerts/tlsca.ust.com-cert.pem

printf "\nAnchor peer updated\n\n"
