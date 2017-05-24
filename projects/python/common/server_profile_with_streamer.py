#! /usr/bin/env python
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
oneview_client = OneViewClient.from_json_file('/hpov/haconfig.json')

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
print('Provisioning %s' % config.DEPL_PLAN)
print('-------------------------------')
print('Enclosure name: %s' % config.ENCL_NAME)
print('Bay number: %s' % config.BAY_NUM)
print('Deployment plan: %s' % config.DEPL_PLAN)
print('Profile name: %s' % config.PROFILE_NAME)
print('Server FQDN: %s' % config.SERVER_FQDN)
print('Consul FQDN: %s' % config.CONSUL_FQDN)
print('DataDog tag: %s' % config.DATADOG_TAG)
print('Network set: %s' % config.NET_SET_NAME)
print('VLAN ID: %s' % config.VLAN_ID)
if (config.DEPL_PLAN == 'OpenStack all-in-one' or
        config.DEPL_PLAN == 'OpenStack Compute'):
    print('Server IP: %s' % config.SERVER_IP)
    print('Server netmask: %s' % config.SERVER_MASK)
    print('Server gateway: %s' % config.SERVER_GW)
    print('DNS IP: %s' % config.DNS_IP)
if config.DEPL_PLAN == 'OpenStack all-in-one':
    print('IP allocation pool start: %s' % config.IP_ALLOC_POOL_START)
    print('IP allocation pool end: %s' % config.IP_ALLOC_POOL_END)
    print('Neutron ext net CIDR: %s' % config.NEUTRON_EXT_CIDR)
    print('Neutron ext net GW: %s' % config.NEUTRON_EXT_GW)
print('-------------------------------')

#
# Determine URIs
#
ENCL_GROUP_URI = oneview_client.enclosures.get_by('name', config.ENCL_NAME)[0]['enclosureGroupUri']
SRVR_HWARE_URI = oneview_client.enclosures.get_by('name', config.ENCL_NAME)[0]['deviceBays'][int(config.BAY_NUM)-1]['deviceUri']
SRVR_HWARE_TYPE_URI = oneview_client.server_hardware.get(SRVR_HWARE_URI)['serverHardwareTypeUri']
DEPL_PLAN_URI = oneview_client.os_deployment_plans.get_by_name(config.DEPL_PLAN)['uri']
NET_URI = oneview_client.network_sets.get_by('name', config.NET_SET_NAME)[0]['uri']
DEPL_NET_URI = oneview_client.ethernet_networks.get_by('name', config.DEPL_NET_NAME)[0]['uri']

#
# Create a server profile
#
print('Creating server profile with Image Streamer Deployment Plan')

profile_config = importlib.import_module(os.path.splitext(config.PROFILE_DEFINITION)[0])

try:
    new_profile = oneview_client.server_profiles.create(profile_config.profile_def)
except HPOneViewException as e:
    print(e.msg)

if args.verbosity >= 2:
    pprint(new_profile)

#
# Re-apply the newly created profile, so NIC1 and NIC2 variables will be set
#
if args.verbosity >= 1:
    print('\nReapply NIC variables in newly created profile')

try:
    profile_to_update = oneview_client.server_profiles.get(new_profile['uri'])
except HPOneViewException as e:
    print(e.msg)

try:
    NIC1_MAC = profile_to_update['connections'][1]['mac']
except HPOneViewException as e:
    print(e.msg)

try:
    NIC2_MAC = profile_to_update['connections'][2]['mac']
except HPOneViewException as e:
    print(e.msg)

if config.DEPL_PLAN == 'Docker CentOS 7.3':
    try:
        profile_to_update['osDeploymentSettings']['osCustomAttributes'] = [
            dict(name='NIC1.connectionid', value='2'),
            dict(name='NIC1.constraint', value='userspecified'),
            dict(name='NIC1.mac', value=NIC1_MAC),
            dict(name='NIC2.connectionid', value='3'),
            dict(name='NIC2.constraint', value='userspecified'),
            dict(name='NIC2.mac', value=NIC2_MAC),
            dict(name='SERVER_FQDN', value=config.SERVER_FQDN),
            dict(name='CONSUL_FQDN', value=config.CONSUL_FQDN),
            dict(name='DATADOG_TAG', value=config.DATADOG_TAG),
            dict(name='VLAN_ID', value=config.VLAN_ID),
        ]
        #print('Profile has been created and applied.  Please wait while MAC settings are applied.')
    except HPOneViewException as e:
        print(e.msg)

if config.DEPL_PLAN == 'OpenStack all-in-one':
    try:
        profile_to_update['osDeploymentSettings']['osCustomAttributes'] = [
            dict(name='NIC1.connectionid', value='2'),
            dict(name='NIC1.constraint', value='userspecified'),
            dict(name='NIC1.mac', value=NIC1_MAC),
            dict(name='NIC2.connectionid', value='3'),
            dict(name='NIC2.constraint', value='userspecified'),
            dict(name='NIC2.mac', value=NIC2_MAC),
            dict(name='SERVER_FQDN', value=config.SERVER_FQDN),
            dict(name='CONSUL_FQDN', value=config.CONSUL_FQDN),
            dict(name='DATADOG_TAG', value=config.DATADOG_TAG),
            dict(name='VLAN_ID', value=config.VLAN_ID),
            dict(name='IP_ALLOC_POOL_START', value=config.IP_ALLOC_POOL_START),
            dict(name='IP_ALLOC_POOL_END', value=config.IP_ALLOC_POOL_END),
            dict(name='NEUTRON_EXT_CIDR', value=config.NEUTRON_EXT_CIDR),
            dict(name='NEUTRON_EXT_GW', value=config.NEUTRON_EXT_GW),
            dict(name='SERVER_IP', value=config.SERVER_IP),
            dict(name='SERVER_MASK', value=config.SERVER_MASK),
            dict(name='SERVER_GW', value=config.SERVER_GW),
            dict(name='DNS_IP', value=config.DNS_IP)
        ]
        #print('Profile has been created and applied.  Please wait while MAC settings are applied.')
    except HPOneViewException as e:
        print(e.msg)

if config.DEPL_PLAN == 'OpenStack Compute':
    try:
        profile_to_update['osDeploymentSettings']['osCustomAttributes'] = [
            dict(name='NIC1.connectionid', value='2'),
            dict(name='NIC1.constraint', value='userspecified'),
            dict(name='NIC1.mac', value=NIC1_MAC),
            dict(name='NIC2.connectionid', value='3'),
            dict(name='NIC2.constraint', value='userspecified'),
            dict(name='NIC2.mac', value=NIC2_MAC),
            dict(name='SERVER_FQDN', value=config.SERVER_FQDN),
            dict(name='CONSUL_FQDN', value=config.CONSUL_FQDN),
            dict(name='DATADOG_TAG', value=config.DATADOG_TAG),
            dict(name='VLAN_ID', value=config.VLAN_ID),
            dict(name='SERVER_IP', value=config.SERVER_IP),
            dict(name='SERVER_MASK', value=config.SERVER_MASK),
            dict(name='SERVER_GW', value=config.SERVER_GW),
            dict(name='DNS_IP', value=config.DNS_IP)
        ]
#        #print('Profile has been created and applied.  Please wait while MAC settings are applied.')
    except HPOneViewException as e:
        print(e.msg)


try:
    profile_updated = oneview_client.server_profiles.update(resource=profile_to_update, id_or_uri=profile_to_update['uri'])
    profile_updated_uri = profile_updated['uri']
#    print('Profile has been updated with MAC settings.')
    print('Profile %s has been created and applied.' % profile_updated_uri)
    if args.verbosity >= 2:
        pprint(profile_updated)
except HPOneViewException as e:
    print(e.msg)

#
# Power on the blade
#
try:
    configuration = {
        'powerState': 'On',
        'powerControl': 'MomentaryPress'
    }
    server_power = oneview_client.server_hardware.update_power_state(configuration, profile_updated['serverHardwareUri'])
    print("Successfully changed the power state to '{powerState}'".format(**server_power))
except HPOneViewException as e:
    print(e.msg)
