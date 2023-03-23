######################################################
#                                                    #
# Proto Build. A basic shell for Starknet Protostar. #
# Version: 0.1 jan2023                               #
# By     : devnet0x                                  #
#                                                    #
######################################################
#!/bin/bash

if [[ ($# -lt 3) || ($1 != "devnet" && $1 != "testnet" && $1 != "testnet2") ]]
then
   echo "Usage: proto_build.sh <devnet|testnet|testnet2> <key_file> <json_compiled_file> [constructor parameters]"
   exit
fi

# Set environment parameters
if [ $1 == "devnet" ]
then
   ENVIRONMENT1="--gateway-url http://127.0.0.1:5050 --chain-id=1536727068981429685321"
   ENVIRONMENT2="--feeder_gateway_url http://127.0.0.1:5050"
   ENVIRONMENT_TESTNET2=""
fi

if [ $1 == "testnet" ]
then
   ENVIRONMENT1="--network testnet"
   ENVIRONMENT2="--network alpha-goerli"
   ENVIRONMENT_TESTNET2=""
fi

if [ $1 == "testnet2" ]
then
   ENVIRONMENT1=""
   ENVIRONMENT2="--network alpha-goerli2"
   ENVIRONMENT_TESTNET2="-p testnet2"
fi

# Set keys parameters
PUBLIC_KEY=`cat ${2} | awk 'FNR == 1 {print $1}'`
export PROTOSTAR_ACCOUNT_PRIVATE_KEY=`cat ${2} | awk 'FNR == 2 {print $1}'`


# Set contructor inputs
if [ $# -gt 3 ]
then
   INPUTS="--inputs ${@:4}"
fi

###################################################
#                                                 #
# Compile                                         #
#                                                 #
###################################################

# Start process
echo -e "\033[1;32mCompiling...\033[0m"
protostar build > build.tmp
if [ $? -ne 0 ]
then
   echo -e "\n\033[0;41mFAILED COMPILE.\033[0m"
   exit
fi

FILENAME=`basename $3 .json`
CLASS_HASH=`cat build.tmp | grep ${FILENAME} | awk 'FNR == 1 {print $6}'`

###################################################
#                                                 #
# Declare                                         #
#                                                 #
###################################################

echo -e "\033[1;32mDeclaring...\033[0m"
DECLARE_STATEMENT="protostar ${ENVIRONMENT_TESTNET2} declare ${3} ${ENVIRONMENT1} --account-address ${PUBLIC_KEY} --max-fee auto > build.tmp"
echo ${DECLARE_STATEMENT}
eval ${DECLARE_STATEMENT}
if [ $? -ne 0 ]
then
   echo -e "\n\033[0;41mFailed command:\033[0m\n"${DECLARE_STATEMENT}
   exit
fi

if [[ ($1 == "devnet") || ($1 == "testnet2") ]]
then
   TX_HASH=`cat build.tmp | awk 'FNR == 3 {print $3}'`
else
   TX_HASH=`cat build.tmp | awk 'FNR == 6 {print $3}'`
fi
TX_STATUS=`starknet tx_status ${ENVIRONMENT2} --hash ${TX_HASH} | awk 'FNR == 2 {print $2}'`

echo "Class Hash:" ${CLASS_HASH}
echo "Tx.Hash:" ${TX_HASH}

start=$SECONDS
while [[ (${TX_STATUS} == "\"RECEIVED\"") || (${TX_STATUS} == "\"PENDING\"") ]]
do
   echo -ne "${TX_STATUS} $(( SECONDS - start )) secs.\r"
   sleep 1
   TX_STATUS=`starknet tx_status ${ENVIRONMENT2} --hash ${TX_HASH} | awk 'FNR == 2 {print $2}'`
done
TX_STATUS=`starknet tx_status ${ENVIRONMENT2} --hash ${TX_HASH} | awk 'FNR == 3 {print $2}'`
echo -ne "${TX_STATUS} $(( SECONDS - start )) secs.\n"
if [ ${TX_STATUS} != "\"ACCEPTED_ON_L2\"" ]
then
   cat build.tmp
   echo -e '\033[0;41mFAILED DECLARE.\033[0m'
   exit
fi

###################################################
#                                                 #
# Deploy                                          #
#                                                 #
###################################################

echo -e "\033[1;32mDeploying...\033[0m"
DEPLOY_STATEMENT="protostar ${ENVIRONMENT_TESTNET2} deploy ${CLASS_HASH} ${ENVIRONMENT1} --max-fee auto --account-address ${PUBLIC_KEY} ${INPUTS} > build.tmp"
echo ${DEPLOY_STATEMENT}
eval ${DEPLOY_STATEMENT}
if [ $? -ne 0 ]
then
   echo -e "\n\033[0;41mFailed command:\033[0m\n"${DEPLOY_STATEMENT}
   exit
fi

CONTRACT_ADDRESS=`cat build.tmp | awk 'FNR == 2 {print $3}'`

if [[ ($1 == "devnet") || ($1 == "testnet2") ]]
then
   TX_HASH=`cat build.tmp | awk 'FNR == 3 {print $3}'`
else
   TX_HASH=`cat build.tmp | awk 'FNR == 6 {print $3}'`
fi

# Hash from dec to hex
#TX_HASH="echo 'obase=16;${TX_HASH}' | bc > build.tmp"
#eval ${TX_HASH}
#TX_HASH=`cat build.tmp | awk 'FNR == 1 {print $1}'`

TX_STATUS=`starknet tx_status ${ENVIRONMENT2} --hash ${TX_HASH} | awk 'FNR == 2 {print $2}'`

echo "Tx.Hash: 0x"${TX_HASH}

start=$SECONDS
while [[ (${TX_STATUS} == "\"RECEIVED\"") || (${TX_STATUS} == "\"PENDING\"") ]]
do
   echo -ne "${TX_STATUS} $(( SECONDS - start )) secs.\r"
   sleep 1
   TX_STATUS=`starknet tx_status ${ENVIRONMENT2} --hash ${TX_HASH} | awk 'FNR == 2 {print $2}'`
done
TX_STATUS=`starknet tx_status ${ENVIRONMENT2} --hash ${TX_HASH} | awk 'FNR == 3 {print $2}'`

echo -ne "${TX_STATUS} $(( SECONDS - start )) secs.\n"
if [ ${TX_STATUS} != "\"ACCEPTED_ON_L2\"" ]
then
   cat build.tmp
   echo -e '\033[0;41mFAILED DEPLOY.\033[0m'
   exit
fi

echo "Contract Address:" ${CONTRACT_ADDRESS}
rm build.tmp
