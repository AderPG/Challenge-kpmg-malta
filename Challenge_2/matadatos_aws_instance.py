import json
import os

# Data to be written

ami-id = os.system('curl http://169.254.169.254/latest/meta-data/ami-id')
ami-launch-index = os.system('curl http://169.254.169.254/latest/meta-data/ami-launch-index')
ami-manifest-path= os.system('curl http://169.254.169.254/latest/meta-data/ami-manifest-path')
events = os.system('curl http://169.254.169.254/latest/meta-data/events')
hostname = os.system('curl http://169.254.169.254/latest/meta-data/hostname')
iam = os.system('curl http://169.254.169.254/latest/meta-data/iam')
instance-id = os.system('curl http://169.254.169.254/latest/meta-data/instance-id')
instance-type = os.system('curl http://169.254.169.254/latest/meta-data/instance-type')
local-hostname = os.system('curl http://169.254.169.254/latest/meta-data/local-hostname')
local-ipv4 = os.system('curl http://169.254.169.254/latest/meta-data/local-ipv4')
network = os.system('curl http://169.254.169.254/latest/meta-data/network')
public-ipv4 = os.system('curl http://169.254.169.254/latest/meta-data/public-ipv4')


dictionary = {
	"ami-id": ami-id
	"ami-launch-index": ami-launch-index,
	"ami-manifest-path=": ami-manifest-path=,
	"events": events,
    "hostname": hostname,
    "iam": iam,
    "instance-id": instance-id,
    "instance-type": instance-type,
    "local-hostname": local-hostname
}

#It is possible to do it in a more automated way.
# first listing all metadata categories in a file 
#then iterating over each category until the list is finished
#and go printing in each iteration to a json file

# Serializing json
json_object = json.dumps(dictionary, indent=4)

# Writing to metadata_aws_instance.json
with open("metadata_aws_instance.json", "w") as outfile:
	outfile.write(json_object)
