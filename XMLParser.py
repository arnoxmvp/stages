"""
XMLParser for xxx v2
The script reads data on a text file containing all tags then searches their values in the xxx report
to pass the values to a broker using MQTT protocol.
Takes 2 parameters. 1st is the xml report to parse and 2nd is the list of tags to search in the report.
Script written by Arnaud Collart the 15/04/2021.
Documentations can be found on :  https://www.temporaryURL.com/doc/mydoc
"""

# Import Librabries
from xml.etree import ElementTree as eT
from paho.mqtt import publish as pb

#Create the variables 
tagsDict = {}
domain = "xxx"
file = 'path_to_file'
hostip = "mqtt_broker_ip"
textags = "path_to_file"

#Parse the XML File
tree = eT.parse(file)
root = tree.getroot()

#Search each tag given by the text file
with open(textags) as tagsFile:
    for line in tagsFile:
        line = line.rstrip("\n")
        tagsDict[line] = root.find(line).text
        print
        (tagsDict[line])

#Send the tag values over MQTT
        pb.single(topic, qos=0, auth=None, hostname=hostip)
