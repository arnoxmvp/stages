"""
UserCounter v1.1
The script counts the number of personnal accounts logged on a domain by parsing it and counting the matching searches.
The LogOn script generates a log file containing all logons generated on a monthly basis.
This log file is given by parameters using the argv method.
It searches the matches with a regular expression passed through argv and with a file containing numerous known logins.
Script written by Arnaud Collart the 16/04/2021.
Documentations can be found on :  https://www.temporaryURL.com/doc/mydoc
"""

# Module importations
from paho.mqtt import publish as pb
import pandas as pd

# Creates Variables
userDict = {}
userList = "genericLogins.txt"
loginList = "LogonLogs.csv"
counter = 0
i = 0


# Open files
users = open(userList, 'r')
logs = pd.read_csv(loginList, delimiter=";")

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
pb.single(topix,counter,host)
pb.single(topix,iterator,host)
