"""
SMBParser v1.1
The script reads data on a text file containing all SMB shares configuration informations to find potential
vulnerabilities
as SMBv1 is an old protocol which isn't recommended anymore due to known vulnerabilities.
It then counts all shares where SMBv1 is enabled and sends the data to the broker via MQTT.
Script written by Arnaud Collart the 22/04/2021.
Documentations can be found on :  https://www.temporaryURL.com/doc/mydoc
"""

# importing libraries
import argparse
from paho.mqtt import publish
import pandas as pd

# Args define
parser = argparse.ArgumentParser()
parser.add_argument("csv", help="SMB report")
parser.add_argument("hostip", help="IP of MQTT broker")
parser.add_argument("domain", help="Domain you'd like to work on")
args = parser.parse_args()

# creating variables and instances
csv = args.csv
df = pd.read_csv(csv, delimiter="\t")
i = 0
counter = 0

# browsing the data to search specified string
while i < len(df):

    if str(df["SMB1 with dialect NT LM 0.12"][i]) == "Yes":
        counter += 1
    i += 1

print(counter)
print(i)

# publishing data via MQTT
publish.single("Security/ADDomain/" + args.domain + "/Pingcastle/smbv1enabled", counter, hostname=args.hostip)
publish.single("Security/ADDomain/" + args.domain + "/Pingcastle/smbtotal", i-counter, hostname=args.hostip)
