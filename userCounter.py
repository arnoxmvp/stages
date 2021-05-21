"""
UserCounter v1.5
The script counts the number of personal accounts logged on a domain by parsing it and counting the matching searches.
The LogOn script generates a log file containing all logons generated on a monthly basis.
This log file is given by parameters using the argv method.
It searches the matches with a regular expression passed through argv and with a file containing numerous known logins.
Script written by Arnaud Collart the 16/04/2021.
Documentations can be found on :  https://www.temporaryURL.com/doc/mydoc
"""

# Module importations

from os import system
import re
import pandas as pd
import argparse

# Argparse
parser = argparse.ArgumentParser()
parser.add_argument("mosquitto", help="Mosquitto executable")
parser.add_argument("cafile", help="CA certificate")
parser.add_argument("certfile", help="Client certificate")
parser.add_argument("keyfile", help="Client key")
parser.add_argument("LogonLog", help="File containing logs")
parser.add_argument("LoginList", help="List of generic logins")
parser.add_argument("broker", help="CN of MQTT Broker")
parser.add_argument("domain", help="Domain you'd like to work on")
args = parser.parse_args()

# Creates Variables
counter = 0
i = 0
userDict = {}

genericUsers = open(args.LoginList, 'r')

for user in users:
    if user == "\n":
        break
    else:
        userDict[hash(user)] = user

# Open files
pattern = re.compile(regex_to_match)
logs = pd.read_csv(args.LogonLog, delimiter=";")

# Checks if the user login matches the expression nor the hashed userlogin is in the dictionary, counter +1 if true
while i < len(logs):
    result = re.match(pattern, str(logs["LoginName"][i]))
    if result:
        counter += 1
    elif hash(str(logs["LoginName"][i]) + "\n") not in userDict:
        counter += 1
    i += 1
print("Personnel :" + str(counter))
print("Generique :" + str(i-counter))

# Sends data over MQTT
system(args.mosquitto
    + " -p 8883 --cafile " + args.cafile
    + " --cert " + args.certfile
    + " --key " + args.keyfile
    + " -h " + args.broker
    + " -m " + str(i-counter)
    + " -t Security/ADDomain/" + args.domain + "/Usage/Generic")

system(args.mosquitto
    + " -p 8883 --cafile " + args.cafile
    + " --cert " + args.certfile
    + " --key " + args.keyfile
    + " -h " + args.broker
    + " -m " + str(counter)
    + " -t Security/ADDomain/" + args.domain + "/Usage/Personal")
