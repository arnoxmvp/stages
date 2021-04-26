"""
SMBParser v1.1
The script reads data on a text file containing all SMB shares configuration informations to find potential vulnerabilities 
as SMBv1 is an old protocol which isn't recommended anymore due to known vulnerabilities.
It then counts all shares where SMBv1 is enabled and sends the data to the broker via MQTT.
Script written by Arnaud Collart the 22/04/2021.
Documentations can be found on :  https://www.temporaryURL.com/doc/mydoc
"""

#importing libraries
from paho.mqtt import client, publish
import pandas as pd

#creating variables and instances
hostip = 'broker_adress'
csv = "path_to_file" 
domain = "xxx"
df = pd.read_csv(csv, delimiter = "\t")
i = 0
counter = 0

#browsing the data to search specified string
while i < len(df):

    if str(df["SMB1 with dialect NT LM 0.12"][i]) == "Yes":
        counter += 1
    i += 1

print(counter)
print(i)

#publishing data via MQTT
publish.single(topic, counter, hostip)
publish.single(topic, i, hostip)
