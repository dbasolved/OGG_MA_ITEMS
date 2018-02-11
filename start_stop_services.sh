#!/bin/sh
#
#Author: Bobby Curtis, eMBA
#Company: Oracle
#Dept: Oracle Data Integration - Oracle GoldenGate - Product Management
#Version: 12.3.0.1.x - Microservices
#
#Description: This script is used to start/stop a single extract and/or single replicat within an environment.
#
#Requirements: 
#
#Four JSON files needed:
#   1. start_extracts.json
#   2. start_replicat.json
#   3. stop_extract.json
#   4. stop_replicat.json
#
#These files can be changed as need.
#
#Function Variables
#The variable for "url" will need to be changed depending on the environment.  The settings in this
#script are used for my testing environment.
#
#
#Global Variables
USERNAME="oggadmin"
PASS="welcome1"
CONTENT_TYPE="Content-Type: application/json"
ACCEPTS="Accept: application/json"

function startExtract() {
    url="http://localhost:16001/services/v2/commands/execute"
    cmd="POST"
    f_name="start_extracts.json"

    #echo 'curl -u '${USERNAME}:${PASS}' -H "'${CONTENT_TYPE}'" -H "'${ACCEPTS}'" -X '$cmd $url '-d @'$f_name '| python -mjson'
    curl -u ${USERNAME}:${PASS} -H "${CONTENT_TYPE}" -H "${ACCEPTS}" -X $cmd $url -d \@$f_name 
}

function stopExtract() {
    url="http://localhost:16001/services/v2/commands/execute"
    cmd="POST"
    f_name="stop_extract.json"

    #echo 'curl -u '${USERNAME}:${PASS}' -H "'${CONTENT_TYPE}'" -H "'${ACCEPTS}'" -X '$cmd $url '-d @'$f_name '| python -mjson'
    curl -u ${USERNAME}:${PASS} -H "${CONTENT_TYPE}" -H "${ACCEPTS}" -X $cmd $url -d \@$f_name
}

function startReplicat() {
    url="http://localhost:17001/services/v2/commands/execute"
    cmd="POST"
    f_name="start_replicat.json"

    curl -u ${USERNAME}:${PASS} -H "${CONTENT_TYPE}" -H "${ACCEPTS}" -X $cmd $url -d \@$f_name 
}

function stopReplicat() {
    url="http://localhost:17001/services/v2/commands/execute"
    cmd="POST"
    f_name="stop_replicat.json"

    curl -u ${USERNAME}:${PASS} -H "${CONTENT_TYPE}" -H "${ACCEPTS}" -X $cmd $url -d \@$f_name
}

#Main Program
if [ $1 = "startAll" ];
then
    startExtract
    startReplicat
fi

if [ $1 = "stopAll" ];
then
    stopExtract
    stopReplicat
fi

if [ $1 = "startExtract" ];
then
    startExtract
fi

if [ $1 = "stopExtract" ];
then
    stopExtract
fi

if [ $1 = "startReplicat" ];
then
    startReplicat
fi

if [ $1 = "stopReplicat" ];
then
    stopReplicat
fi
