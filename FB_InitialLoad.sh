#!/bin/bash
#
# Date: 05/14/2018
#Title: FB_InitialLoad.sh
#Author: Bobby Curtis, eMBA; Director of Product Management
#Copy Right: Oracle 2018
#
#Description:
#This script is a simple script to demonstrate the usage of file-based initial load.  This script also show how using simple cURL commands can be used
#to orchestrate a simple two whole-table inital load process.  This does not show the steps of using CSN to load the table.
#

function _initReplicat() {
#Replicat
  curl -X POST \
  http://localhost:17001/services/v2/replicats/RLOAD \
  -H 'Authorization: Basic b2dnYWRtaW46d2VsY29tZTE=' \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -d '{
    "description": "Create an initial load replicat - File Based",
    "checkpoint": {
        "table": "ggate.checkpoint"
    } ,
    "config": [ 
        "Replicat RLOAD", 
        "UseridAlias TGGATE", 
        "sourcecatalog pdb1;", 
        "Map pdb1.inittest.sml_table, Target inittest.sml_table;",
        "Map pdb1.inittest.lrg_table, Target inittest.lrg_table;"
    ],
    "credentials": {
        "alias": "TGGATE"
    },
    "mode": {
        "parallel": false,
        "type": "nonintegrated"
    },
    "registration": "none",
    "source": {
        "name": "CB"
    }, 
    "status": "running"
}' | python -mjson.tool
}

function _stopReplicat(){
     curl -X POST \
       http://localhost:17001/services/v2/commands/execute \
       -H 'Authorization: Basic b2dnYWRtaW46d2VsY29tZTE=' \
       -H 'Cache-Control: no-cache' \
       -d '{
                "name":"stop",
                "processName":"RLOAD",
                "processType":"replicat"
            }' | python -mjson.tool
}

function _delReplicat(){
     curl -X DELETE \
       http://localhost:17001/services/v2/replicats/RLOAD \
       -H 'Authorization: Basic b2dnYWRtaW46d2VsY29tZTE=' \
       -H 'Cache-Control: no-cache' | python -mjson.tool
}

function _initDistroPath() {
#DistroPath
     curl -X POST \
       http://localhost:16002/services/v2/sources/INITLOAD \
       -H 'Authorization: Basic b2dnYWRtaW46d2VsY29tZTE=' \
       -H 'Cache-Control: no-cache' \
       -d '{
         "name": "INITLOAD",
         "status": "running",
         "source": {
             "uri": "trail://localhost:16002/services/v2/sources?trail=CA"
         },
         "target": {
             "uri": "ws://OracleGoldenGate+WSTARGET@localhost:17003/services/v2/targets?trail=CB"
         }
     }' | python -mjson.tool
}

function _stopDistroPath(){
 curl -X PATCH \
  http://localhost:16002/services/v2/sources/INITLOAD \
  -H 'Authorization: Basic b2dnYWRtaW46d2VsY29tZTE=' \
  -H 'Cache-Control: no-cache' \
  -d '{
	"status":"stopped"
    }' | python -mjson.tool
}

function _delDistroPath(){
     curl -X DELETE \
       http://localhost:16002/services/v2/sources/INITLOAD \
       -H 'Authorization: Basic b2dnYWRtaW46d2VsY29tZTE=' \
       -H 'Cache-Control: no-cache' \
       -d '{
              "distpath":"INITLOAD"
            }' | python -mjson.tool
}

function _initExtract() {
#Extract
curl -X POST \
  http://localhost:16001/services/v2/extracts/LOAD \
  -H 'Authorization: Basic b2dnYWRtaW46d2VsY29tZTE=' \
  -H 'Cache-Control: no-cache' \
  -d '{
          "description": "Create an initial load extract - File Based",
          "config": 
              [ 
                  "Extract LOAD", 
                  "UseridAlias SGGATE", 
                  "ExtFile CA Megabytes 250 Purge", 
                  "sourcecatalog pdb1", 
                  "Table inittest.sml_table, keycols(rid);",
                  "Table inittest.lrg_table, keycols(rid);"
              ], 
              "source": "tables", 
              "status": "running"
          }' | python -mjson.tool
}

function _startExtract(){
      curl -X POST \
      http://localhost:16001/services/v2/commands/execute \
      -H 'Authorization: Basic b2dnYWRtaW46d2VsY29tZTE=' \
      -H 'Cache-Control: no-cache' \
      -d '{
            "name":"start",
            "processName":"LOAD",
            "processType":"extract"
          }' | python -mjson.tool
}

function _stopExtract(){
      curl -X POST \
      http://localhost:16001/services/v2/commands/execute \
      -H 'Authorization: Basic b2dnYWRtaW46d2VsY29tZTE=' \
      -H 'Cache-Control: no-cache' \
      -d '{
              "name":"stop",
              "processName":"LOAD",
              "processType":"extract"
          }' | python -mjson.tool
}

function _delExtract(){
  curl -X DELETE \
  http://localhost:16001/services/v2/extracts/LOAD \
  -H 'Authorization: Basic b2dnYWRtaW46d2VsY29tZTE=' \
  -H 'Cache-Control: no-cache' | python -mjson.tool
}

function getSrcMinMax(){
    local SrcMinMax=$(echo "set feed off
    set pages 0
    select 'source large table -> '|| nvl(max(rid),0) from inittest.lrg_table;
    select 'source small table -> '|| nvl(max(rid),0) from inittest.sml_table;
    exit" | sqlplus -s system/welcome1@//localhost:1521/pdb1
    )
    echo $SrcMinMax
}

function getTgtMinMax(){
    local TgtMinMax=$(echo "set feed off
    set pages 0
    select 'target large table -> '|| nvl(max(rid),0) from inittest.lrg_table;
    select 'target small table -> '|| nvl(max(rid),0) from inittest.sml_table
    exit" | sqlplus -s system/welcome1@//localhost:1521/pdb2
    )
    echo $TgtMinMax
}

function _removeProcess(){
  _delExtract
  sleep 5
  _delDistroPath
  sleep 5
  _delReplicat
}


function _main() {
      v_result=$?
      if [ $v_result -eq 0 ];
      then
              echo "Source Table - Min/Max"
              getSrcMinMax
              sleep 15
              if [ $v_result -eq 0 ]
              then
                  _initReplicat
                  echo "Initial Load Replicat Built"
                  sleep 15
                  if [ $v_result -eq 0 ]
                  then
                      _initDistroPath
                      echo "Initial Load Path Built"
                      sleep 15
                      if [ $v_result -eq 0 ]
                      then
                          _initExtract
                          echo "Initial Load Extract Built"
                          echo "Loading Table ....."
                          sleep 15
                            if [ $v_result -eq 0 ];
                            then
                              _stopReplicat
                              echo "Initial Load Replicat Stopped"
                              sleep 15
                                if [ $v_result -eq 0 ];
                                then
                                _stopDistroPath
                                echo "Initial Load Distribution Path Stopped"
                                sleep 15
                                    if [ $v_result -eq 0 ];
                                    then
                                       _stopExtract
                                        echo "Initial Load Extract Stopped"
                                        sleep 15
                                        if [ $v_result -eq 0 ];
                                        then
                                          echo "Target Table - Min/Max"
                                          getSrcMinMax
                                          getTgtMinMax
                                          sleep 15
                                          echo "Removing Processes"
                                          _removeProcess
                                        else
                                          echo "Failed to run : _getTgtMinMax"
                                        fi #endif - getTgtMinMax
                                else
                                    echo "Failed to run : _stopExtract"
                                fi #endif - _stopExtract
                          else
                            echo "Failed to run : _stopDistoPath"
                          fi #endif - _stopDistroPath
                        else
                          echo "Failed to run : _stopReplicat"
                        fi #endif - _stopReplicat
                      else
                          echo "Failed to run : _initExtract"
                      fi #endif - _initExtract
                  else
                      echo "Failed to run : _initDistroPath"
                  fi #endif - _initDistroPath
              else
                  echo "Failed to run : _initReplicat"
              fi #endif - _initReplicat
      else
              echo "Failed to run : SrcMinMax"
      fi #endif - SrcMinMax
} #endFunction Main

#Program
_main


