#! /bin/bash
#
# Install the DataDog agent
#
echo "Installing DataDog agent"

# be sure network is active (ping out to internet)
CONNECT=""
while [[ $CONNECT != "ok" ]] ; do
   CONNECT=$(ping -q -w 1 -c 1 8.8.8.8 > /dev/null && echo "ok" || echo "error")
   sleep 2
done

#
# Get DataDog API key
# 
docker exec consul consul kv get synergy/datadog > /tmp/dd-apikey

DD_API_KEY=$(cat /tmp/dd-apikey) bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/dd-agent/master/packaging/datadog-agent/source/install_agent.sh)"

sed -i "s/# tags:.*/tags: synergy:hybrid-k8s/" /etc/dd-agent/datadog.conf
mv /etc/dd-agent/conf.d/system_core.yaml.example /etc/dd-agent/conf.d/system_core.yaml
mv /etc/dd-agent/conf.d/docker_daemon.yaml.example /etc/dd-agent/conf.d/docker_daemon.yaml
rm /tmp/dd-apikey

#
# Exclude DataDog from logging (it is very chatty)
#
if [[ $(grep -c "DataDog" /etc/rsyslog.conf) -eq 0 ]] ; then
echo
echo "Inserting DataDog entries into rsyslog.conf"
sed -i '/RULES/a \
\#\ Do not log DataDog entries \
:programname, startswith, "dd.forwarder" ~ \
:programname, startswith, "dd.agent" ~ \
:programname, startswith, "dd.collector" ~ \
:programname, startswith, "dd.dogstatsd" ~' /etc/rsyslog.conf
fi

#
# Restart syslog daemon and DD agent
#
systemctl restart rsyslog

#
# Add datadog agent user to docker group
#
usermod -aG docker dd-agent

#
# Start the agent
#
/etc/init.d/datadog-agent restart

exit 0
