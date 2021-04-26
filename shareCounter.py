"""
shareCounter v1
The script reads data on a text file containing all shares their permissions to assess risks of unwanted access.
It counts the proportion of shares configured to allow access to everyone.
Data is then sent over MQTT protocol.
Script written by Arnaud Collart the 21/04/2021.
Documentations can be found on :  https://www.temporaryURL.com/doc/mydoc
"""

#importing dependecies
from paho.mqtt import publish

#establishing variables
domain = "xxx"
hostip = broker_address
shares = open('path_to_file','r')
openShares = 0
string = "True"
i = 0

#reading the file line by line to find specified string
for line in shares:
    i += 1
    if string in line:
        openShares += 1

shares.close()
print(openShares)
print(i)

#send counters value to the broker
publish.single(topic, openShares, hostip)
publish.single(topic, i, hostip)
