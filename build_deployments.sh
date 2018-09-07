#!/bin/bash
#
#Author: Bobby Curtis, eMBA
#Company: Oracle
#Dept: Oracle Data Integration - Oracle GoldenGate - Product Management
#Version: 12.3.0.1.x and 18.1.0 - Microservices
#
#Description:
#
#Usage:
#To run this script the command line needs to provide the password for the ServcieManager user login
#
# :> ./build_deployments.sh Welcome1 <deployment_name> <AdminService Port>
#
#Global Variables
vPass=$1
vAuth=`echo oggadmin:$vPass | base64`
vHost0=localhost:16000
vDeployments=($2)
vPort=$3

#Build Deployment(s)
function _buildDeployment(){
vService=(adminsrvr distsrvr recvsrvr pmsrvr)

     for i in "${vDeployments[@]}"
     do
          echo
          echo "Build deployment $i and starting"
          echo

          curl -X POST \
            http://$vHost0/services/v2/deployments/$i \
           --user oggadmin:$vPass \
            -H 'Cache-Control: no-cache' \
            -d '{
                    "environment": [
                         {
                           "name":"JAVA_HOME",
                           "value":"/opt/app/oracle/product/18.1.0_RC2/oggcore_1/jdk"
                         },
                         {
                           "name":"ORACLE_HOME",
                           "value":"/opt/app/oracle/product/18.3.0/dbhome_1"
                         },
                         {
                              "name":"ORACLE_SID",
                              "value":"orcl"
                         },
                         {
                              "name":"LD_LIBRARY_PATH",
                              "value":"/opt/app/oracle/product/18.3.0/dbhome_1/lib:/opt/app/oracle/product/18.1.0_RC2/oggcore_1/lib:/opt/app/oracle/product/18.1.0_RC2/oggcore_1/install/lib:/opt/app/oracle/product/18.1.0_RC2/oggcore_1/oui/lib/linux64:"
                         }
                    ] ,
                    "oggHome":"/opt/app/oracle/product/18.1.0_RC2/oggcore_1",
                    "oggEtcHome":"/opt/app/oracle/gg_deployments/'${i}'/etc",
                    "oggConfHome":"/opt/app/oracle/gg_deployments/'${i}'/etc/config",
                    "oggSslHome":"/opt/app/oracle/gg_deployments/'${i}'/etc/ssl",
                    "oggVarHome":"/opt/app/oracle/gg_deployments/'${i}'/var",
                    "oggDataHome":"/opt/app/oracle/gg_deployments/'${i}'/var/lib/data",
                    "enabled":true,
                    "status":"running"
               }' | python -mjson.tool
                    
       
          #Build AdminServer
          #authorizationEnabled:true cause problem with login screen - think this is something to do with SSL wallet (User 'oggadmin' is not registered with this service. (Thread 8))
          for z in "${vService[@]}"
          do

               echo
               echo "Building service $z for deployment $i"
               echo
               

                curl -X POST \
                      http://$vHost0/services/v2/deployments/$i/services/$z\
                     --user oggadmin:$vPass \
                      -H 'Cache-Control: no-cache' \
                      -d '{
                              "config":{
                                   "network":{
                                        "serviceListeningPort":'${vPort}'
                                   },
                                   "security":false,
                                   "authorizationEnabled":false,
                                   "asynchronousOperationEnabled":true,
                                   "defaultSynchronousWait":30,
                                   "legacyProtocolEnabled":true,
                                   "taskManagerEnabled":true
                              },
                              "enabled":true,
                              "status":"running"
                           }'  | python -mjson.tool
                              
                    vPort=$((vPort + 1))           
          done
     done
}

function _main() {
     _buildDeployment
     echo
     echo "Done building deployment(s)"
     echo
}

#Program
_main
