#!/bin/bash
#
#Author: Bobby Curtis, eMBA
#Company: Oracle
#Dept: Oracle Data Integration - Oracle GoldenGate - Product Management
#Version: 12.3.0.1.x and 18.1.0 - Microservices
#
#Description:
#This script is used to update the Oracle GoldenGate home for the ServiceManager and associated deployments.
#Since this was a simple script, there are a few manual things that need to change.  These items are:
#1. Change the array variable (vDeployments) to provide all the deployments in the architecture
#2. Change the oggHome value in the cURL commands
#
#Usage:
#To run this script the command line needs to provide the password for the ServcieManager user login
#
# :> ./updateServiceManager.sh Welcome1
#
#Global Variables
vPass=$1
vAuth=`echo oggadmin:$vPass | base64`
vHost0=localhost:16000
vDeployments=(alpha charlie)

#echo $vAuth

#Update Binaries

function _updateServiceManager() {
     echo
     echo "Updating ServiceManager and restarting"
     echo
     curl -X PATCH \
       http://$vHost0/services/v2/deployments/ServiceManager \
       --user oggadmin:$vPass \
       -H 'Cache-Control: no-cache' \
       -d '{
         "oggHome":"/opt/app/oracle/product/18.1.0_RC2/oggcore_1", 
         "status":"restart"
     }' | python -mjson.tool
}

function _updateDeployment(){
     for i in "${vDeployments[@]}"
     do
          echo
          echo "Updating deployment $i and restarting"
          echo
          curl -X PATCH \
            http://$vHost0/services/v2/deployments/$i \
           --user oggadmin:$vPass \
            -H 'Cache-Control: no-cache' \
            -d '{
              "oggHome":"/opt/app/oracle/product/18.1.0_RC2/oggcore_1",
              "status":"restart"
          }' | python -mjson.tool
     done
}

function _main() {
     echo
     echo "Updating binaries for Oracle GoldenGate processes"
     echo
     _updateServiceManager
     sleep 10
     _updateDeployment
     echo
     echo "Done updating binaries"
     echo
}

#Program
_main
