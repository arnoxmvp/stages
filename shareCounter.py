"""
shareCounter v1.2
The script reads data on a text file containing all shares their permissions to assess risks of unwanted access.
It counts the proportion of shares configured to allow access to everyone.
Data is then sent over MQTT protocol.
Script written by Arnaud Collart the 21/04/2021.
Documentations can be found on :  https://www.temporaryURL.com/doc/mydoc
"""

# importing dependecies
from paho.mqtt import publish
import argparse

# Args define
parser = argparse.ArgumentParser()
parser.add_argument("shareResult", help="File containing results")
parser.add_argument("hostip", help="IP of MQTT Broker")
parser.add_argument("domain", help="Domain you'd like to work one")
args = parser.parse_args()

# establishing variables
shares = open(args.shareResult, 'r')
openShares = 0
string = "True"
i = 0

# reading the file line by line to find specified string
for line in shares:
    i += 1
    if string in line:
        openShares += 1

shares.close()
print(openShares)
print(i-openShares)

# send counters value to the broker
publish.single("Security/ADDomain/" + args.domain + "/Pingcastle/openShares", openShares, hostname=args.hostip)
publish.single("Security/ADDomain/" + args.domain + "/Pingcastle/totalShares", i-openShares, hostname=args.hostip)
