#!/bin/bash
#
#Author: Bobby Curtis, eMBA
#Company: Oracle
#Dept: Oracle Data Integration - Oracle GoldenGate - Product Management
#Version: 12.3.0.1.x and 18.1.0 - Microservices
#
#Description:
#This script is used to remove one or more deployments from the ServiceManager.
#Since this was a simple script, there are a few manual things that need to change.  These items are:
#1. Change the array variable (vDeployments) to provide all the deployments in the architecture
#2. Change the value of vHost0
#
#Usage:
#To run this script the command line needs to provide the password for the ServcieManager user login
#
# :> ./destroy_deployments.sh Welcome1 <deployment_name>
#
#Global Variables
vPass=$1
vAuth=`echo oggadmin:$vPass | base64`
vHost0=localhost:16000
vDeployments=($2)

#echo $vAuth

#Destory Deployments
function _destroyDeployment(){
     for i in "${vDeployments[@]}"
     do
          echo
          echo "Destorying deployment $i"
          echo
          curl -X DELETE \
            http://$vHost0/services/v2/deployments/$i \
           --user oggadmin:$vPass \
            -H 'Cache-Control: no-cache' | python -mjson.tool
     done
}

function _main() {
     _destroyDeployment
     echo
     echo "Done removing deployment(s)"
     echo
}

#Program
_main
