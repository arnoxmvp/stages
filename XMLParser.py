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
import argparse

# Args define
parser = argparse.ArgumentParser()
parser.add_argument("xmlfile", help="File containing data")
parser.add_argument("textags", help="File containing tags")
parser.add_argument("hostip", help="IP of MQTT Broker")
parser.add_argument("domain", help="Domain you'd like to work one")
args = parser.parse_args()

# Create the variables
tagsDict = {}

# Parse the XML File
tree = eT.parse(args.xmlfile)
root = tree.getroot()

# Search each tag given by the text file
with open(args.textags) as tagsFile:
    for line in tagsFile:
        line = line.rstrip("\n")
        tagsDict[line] = root.find(line).text
        print(tagsDict[line])

# Send the tag values over MQTT
        pb.single("Security/ADDomain/" + args.domain + "/Pingcastle/" + line, tagsDict[line], hostname=args.hostip)
