#! /usr/bin/python3.4
#
# Katreena Mullican
# HudsonAlpha Institute for Biotechnology
# This code is under the MIT license, view the complete file at https://github.com/HudsonAlpha/synergy/blob/master/LICENSE
#

import os
import sys
import argparse
import importlib
from pprint import pprint
from hpOneView.oneview_client import OneViewClient
from hpOneView.exceptions import HPOneViewException

#
# Load OneView credentials from a file
#
oneview_client = OneViewClient.from_json_file('/hpov/config.json')

#
# Arguments
#
parser = argparse.ArgumentParser(description='Provision node from ImageStreamer Deployment Plan')
parser.add_argument('CONFIG_FILE', help='name of the configuration file')
parser.add_argument('-v', '--verbosity', action='count', default=0,
                    help='increase output verbosity')
args = parser.parse_args()

#
# Parse config from file
#
config_module = os.path.splitext(args.CONFIG_FILE)[0]
config = importlib.import_module(config_module)

print('-------------------------------')
print('Enclosure name: %s' % config.ENCL_NAME)
print('Bay number: %s' % config.BAY_NUM)
print('Profile name: %s' % config.PROFILE_NAME)
print('Template name: %s' % config.TEMPLATE_NAME)
print('Server FQDN: %s' % config.SERVER_FQDN)
print('Consul FQDN: %s' % config.CONSUL_FQDN)
print('DataDog tag: %s' % config.DATADOG_TAG)
print('VLAN ID: %s' % config.VLAN_ID)
if config.TEMPLATE_NAME == 'OpenStack all-in-one' or config.TEMPLATE_NAME == 'OpenStack Compute':
   print('Server IP: %s' % config.SERVER_IP)
   print('Server netmask: %s' % config.SERVER_MASK)
   print('Server gateway: %s' % config.SERVER_GW)
   print('DNS IP: %s' % config.DNS_IP)
if config.TEMPLATE_NAME == 'OpenStack all-in-one':
   print('IP allocation pool start: %s' % config.IP_ALLOC_POOL_START)
   print('IP allocation pool end: %s' % config.IP_ALLOC_POOL_END)
   print('Neutron ext net CIDR: %s' % config.NEUTRON_EXT_CIDR)
   print('Neutron ext net GW: %s' % config.NEUTRON_EXT_GW)
if config.TEMPLATE_NAME == 'k8s-master-CentOS7.4' or config.TEMPLATE_NAME == 'k8s-worker-CentOS7.4':
   print('K8s cluster name: %s' % config.K8S_CLUSTER_NAME)
print('-------------------------------')

#
# Determine URIs
#
SRVR_HWARE_URI = oneview_client.enclosures.get_by('name', config.ENCL_NAME)[0]['deviceBays'][int(config.BAY_NUM)-1]['deviceUri']
TEMPLATE_URI = oneview_client.server_profile_templates.get_by_name(config.TEMPLATE_NAME)['uri']

#
# Create a server profile
#
print('Creating server profile with Image Streamer Deployment Plan')

try:
    new_profile = oneview_client.server_profile_templates.get_new_profile(TEMPLATE_URI)
except HPOneViewException as e:
    print(e.msg)
#
# Overwrite some values of the new profile, at a minimum the name and serverHardwareUri
#
try:
    new_profile['serverHardwareUri'] = SRVR_HWARE_URI
    new_profile['name'] = config.PROFILE_NAME
    #
    # Set custom attributes
    #
    if config.TEMPLATE_NAME == 'Docker CentOS 7.4' or config.TEMPLATE_NAME == 'Docker Fedora 27':
        new_profile['osDeploymentSettings']['osCustomAttributes'] = dict(name='SERVER_FQDN',value=config.SERVER_FQDN),dict(name='DATADOG_TAG',value=config.DATADOG_TAG),dict(name='VLAN_ID',value=config.VLAN_ID),dict(name='CONSUL_FQDN',value=config.CONSUL_FQDN)
    if config.TEMPLATE_NAME == 'k8s-master-CentOS7.4' or config.TEMPLATE_NAME == 'k8s-worker-CentOS7.4':
        new_profile['osDeploymentSettings']['osCustomAttributes'] = dict(name='SERVER_FQDN',value=config.SERVER_FQDN),dict(name='DATADOG_TAG',value=config.DATADOG_TAG),dict(name='VLAN_ID',value=config.VLAN_ID),dict(name='CONSUL_FQDN',value=config.CONSUL_FQDN),dict(name='K8S_CLUSTER_NAME',value=config.K8S_CLUSTER_NAME)
    if config.TEMPLATE_NAME == 'OpenStack all-in-one':
        new_profile['osDeploymentSettings']['osCustomAttributes'] = dict(name='SERVER_FQDN',value=config.SERVER_FQDN),dict(name='DATADOG_TAG',value=config.DATADOG_TAG),dict(name='VLAN_ID',value=config.VLAN_ID),dict(name='CONSUL_FQDN',value=config.CONSUL_FQDN),dict(name='SERVER_IP',value=config.SERVER_IP),dict(name='SERVER_MASK',value=config.SERVER_MASK),dict(name='SERVER_GW',value=config.SERVER_GW),dict(name='DNS_IP',value=config.DNS_IP),dict(name='IP_ALLOC_POOL_START',value=config.IP_ALLOC_POOL_START),dict(name='IP_ALLOC_POOL_END',value=config.IP_ALLOC_POOL_END),dict(name='NEUTRON_EXT_CIDR',value=config.NEUTRON_EXT_CIDR),dict(name='NEUTRON_EXT_GW',value=config.NEUTRON_EXT_GW)
    if config.TEMPLATE_NAME == 'OpenStack Compute':
        new_profile['osDeploymentSettings']['osCustomAttributes'] = dict(name='SERVER_FQDN',value=config.SERVER_FQDN),dict(name='DATADOG_TAG',value=config.DATADOG_TAG),dict(name='VLAN_ID',value=config.VLAN_ID),dict(name='CONSUL_FQDN',value=config.CONSUL_FQDN),dict(name='SERVER_IP',value=config.SERVER_IP),dict(name='SERVER_MASK',value=config.SERVER_MASK),dict(name='SERVER_GW',value=config.SERVER_GW),dict(name='DNS_IP',value=config.DNS_IP)
    oneview_client.server_profiles.update(resource=new_profile, id_or_uri=new_profile['uri'])
except HPOneViewException as e:
    print(e.msg)
try:
    created_profile = oneview_client.server_profiles.create(new_profile)
except HPOneViewException as e:
    print(e.msg)

if args.verbosity >= 2:
    pprint(new_profile)

#
# Power on the blade
#
try:
    configuration = {
        'powerState': 'On',
        'powerControl': 'MomentaryPress'
    }
    server_power = oneview_client.server_hardware.update_power_state(configuration, created_profile['serverHardwareUri'])
    print("Successfully changed the power state to '{powerState}'".format(**server_power))
except HPOneViewException as e:
    print(e.msg)
