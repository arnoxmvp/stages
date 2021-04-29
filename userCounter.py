"""
UserCounter v1.3
The script counts the number of personal accounts logged on a domain by parsing it and counting the matching searches.
The LogOn script generates a log file containing all logons generated on a monthly basis.
This log file is given by parameters using the argv method.
It searches the matches with a regular expression passed through argv and with a file containing numerous known logins.
Script written by Arnaud Collart the 16/04/2021.
Documentations can be found on :  https://www.temporaryURL.com/doc/mydoc
"""

# Module importations
from paho.mqtt import publish as pb
import pandas as pd
import argparse

# Args define
parser = argparse.ArgumentParser()
parser.add_argument("LogonLog", help="File containing logs")
parser.add_argument("LoginList", help="List of generic logins")
parser.add_argument("hostip", help="IP of MQTT Broker")
parser.add_argument("domain", help="Domain you'd like to work on")
args = parser.parse_args()

# Creates Variables
userDict = {}
counter = 0
i = 0

# Compile th regEx


# Open files
users = open(args.LoginList, 'r')
logs = pd.read_csv(args.LogonLog, delimiter=";")

# Populates the dictionnary
for user in users:
    if user == "\n":
        break
    else:
        userDict[hash(user)] = user
print(userDict)

# Checks if the hashed username is in the dictionnary, counter +1 if a match is found
while i < len(logs):
    if hash(str(logs["LoginName"][i])+"\n") in userDict:
        counter += 1
    i += 1

# Sends data over MQTT
pb.single("Security/ADDomain/" + args.domain + "/Usage/Generic", counter, args.hostip)
pb.single("Security/ADDomain/" + args.domain + "/Usage/Personal", i-counter, args.hostip)
