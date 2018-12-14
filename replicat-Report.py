import requests
from pprint import pprint

v_host=input("Where is Replicat running (Hostname or IP Address)? ")
type(v_host)
v_port=input("What port is the AdminService running on? ")
type(v_port)
v_replicat=input("Name of Replicat? ")
type(v_replicat)
v_user=input("Username? ")
type(v_user)
v_pwd=input("Password? ")
type(v_pwd)

url = "http://"+v_host+":"+v_port+"/services/v2/replicats/"+v_replicat+"/info/reports/"+v_replicat+".rpt"

payload = ""
headers = {
    'cache-control': "no-cache"
    }

response = requests.request("GET", url, data=payload, headers=headers, auth=(v_user,v_pwd))

v_response = response.json()

pprint(v_response)