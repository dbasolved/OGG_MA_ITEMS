#!/usr/bin python
# Copyright (c) 2018-2019 Oracle and/or its affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#
# Since:        March 2019
# Author:       Bobby Curtis <bobby.curtis@oracle.com>
# Description:  GoldenGate Self-Sign Certs
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#

import os

v_ogghome = '/opt/app/oracle/product/18.1.0/oggcore_1'
v_pwd = 'Welcome1'
v_root_dn = 'CN=Bobby,OU=GoldenGate,O=Oracle,L=Atlanta,ST=GA,C=US'

def create_wallet_directory():
    global gv_wallet_dir
    v_wallet_dir = raw_input("Create Oracle Wallet Directory? ")
    type(v_wallet_dir)
    gv_wallet_dir = v_wallet_dir
    os.system('mkdir -p ' + v_wallet_dir)

def create_root_seflsign():
      global gv_wallet_dir
      os.system(v_ogghome + '/bin/orapki wallet create -wallet ' + gv_wallet_dir + '/Root_CA -auto_login -pwd ' + v_pwd)
      os.system(v_ogghome + '/bin/orapki wallet add -wallet ' + gv_wallet_dir + '/Root_CA -dn ' + v_root_dn + ' -keysize 2048 -self_signed -validity 15000 -pwd ' + v_pwd)
      #DocBug: {need to file} - Missig the -wallet option in the example command
      os.system(v_ogghome + '/bin/orapki wallet display -wallet ' + gv_wallet_dir + '/Root_CA -pwd ' + v_pwd)
      os.system(v_ogghome +  '/bin/orapki wallet export -wallet ' + gv_wallet_dir + '/Root_CA -dn ' + v_root_dn + '  -cert ' + gv_wallet_dir + '/Root_CA.pem -pwd '+ v_pwd)
      print gv_wallet_dir + '\n'
      print v_pwd + '\n'
      print v_root_dn + '\n'

def create_server_certs():
      global gv_wallet_dir
      v_server_name = raw_input("What is the hostname of the server? ")
      type(v_server_name)
      v_server_dn = 'CN=' + v_server_name + ',L=Atlanta,ST=GA,C=US'
      os.system(v_ogghome + '/bin/orapki wallet create -wallet ' + gv_wallet_dir + '/' + v_server_name + ' -auto_login -pwd ' + v_pwd)
      os.system(v_ogghome + '/bin/orapki wallet add -wallet ' + gv_wallet_dir + '/' + v_server_name + ' -dn ' + v_server_dn + ' -keysize 2048 -pwd ' + v_pwd)
      os.system(v_ogghome + '/bin/orapki wallet export -wallet ' + gv_wallet_dir + '/' + v_server_name + ' -dn ' + v_server_dn + ' -request ' + gv_wallet_dir + '/' + v_server_name +'_req.pem -pwd ' + v_pwd)
      os.system(v_ogghome + '/bin/orapki cert create -wallet ' + gv_wallet_dir + '/Root_CA -request ' + gv_wallet_dir + '/' + v_server_name + '_req.pem -cert ' + gv_wallet_dir + '/' + v_server_name + '_Cert.pem -serial_num 20 -validity 15000')
      os.system(v_ogghome + '/bin/orapki cert display -cert ' + gv_wallet_dir + '/' + v_server_name + '_Cert.pem -complete')
      os.system(v_ogghome + '/bin/orapki wallet add -wallet ' + gv_wallet_dir + '/' + v_server_name + ' -trusted_cert -cert ' + gv_wallet_dir + '/' + 'Root_CA.pem -pwd ' + v_pwd)
      os.system(v_ogghome + '/bin/orapki wallet add -wallet ' + gv_wallet_dir + '/' + v_server_name + ' -user_cert  -cert '  + gv_wallet_dir + '/' + v_server_name + '_Cert.pem -pwd ' + v_pwd)
      print gv_wallet_dir + '\n'
      print v_pwd + '\n'
      print v_server_dn + '\n'

def create_distro_cert():
      global gv_wallet_dir
      v_distro_name = raw_input("What is the name of the distro client? ")
      type(v_distro_name)
      v_distro_dn = 'CN=' + v_distro_name + ',L=Atlanta,ST=GA,C=US'
      os.system(v_ogghome + '/bin/orapki wallet create -wallet ' + gv_wallet_dir + '/' + v_distro_name + ' -auto_login -pwd ' + v_pwd)
      os.system(v_ogghome + '/bin/orapki wallet add -wallet ' + gv_wallet_dir + '/' + v_distro_name + ' -dn ' + v_distro_dn + ' -keysize 2048 -pwd ' + v_pwd)
      os.system(v_ogghome + '/bin/orapki wallet export -wallet ' + gv_wallet_dir + '/' + v_distro_name + ' -dn ' + v_distro_dn + '  -request ' + gv_wallet_dir + '/' + v_distro_name + '_req.pem -pwd ' + v_pwd)
      os.system(v_ogghome + '/bin/orapki cert create -wallet ' + gv_wallet_dir + '/Root_CA -request ' + gv_wallet_dir + '/' + v_distro_name + '_req.pem -cert ' + gv_wallet_dir + '/' + v_distro_name + '_Cert.pem -serial_num 30 -validity 15000 -pwd ' + v_pwd)
      os.system(v_ogghome + '/bin/orapki wallet add -wallet ' + gv_wallet_dir + '/' + v_distro_name + ' -trusted_cert -cert ' + gv_wallet_dir + '/Root_CA.pem -pwd ' + v_pwd)
      os.system(v_ogghome + '/bin/orapki wallet add -wallet ' + gv_wallet_dir + '/' + v_distro_name + ' -user_cert -cert ' + gv_wallet_dir + '/' + v_distro_name + '_Cert.pem -pwd ' + v_pwd)
      print gv_wallet_dir + '\n'
      print v_pwd + '\n'
      print v_distro_dn + '\n'

def check_wallet():
   os.system(v_ogghome + '/bin/orapki wallet display -wallet ' + gv_wallet_dir + '/Root_CA -pwd ' + v_pwd)
 
if __name__ == '__main__':
   create_wallet_directory()
   create_root_seflsign()
   create_server_certs()
   create_distro_cert()
   check_wallet()
   

