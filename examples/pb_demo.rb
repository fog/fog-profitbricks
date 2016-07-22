require 'fog/profitbricks'

Excon.defaults[:connection_timeout] = 200

compute = Fog::Compute.new(:provider => 'ProfitBricks')

# Find the Ubuntu 16 image in North America.
image = compute.images.all.find do |image|
  image.name =~ /Ubuntu-16/ &&
  image.location == 'us/las'
end

# Create datacenter.
datacenter = compute.datacenters.create(name: 'fog-demo', location: 'us/las', description: 'fog-profitbricks demo')
datacenter.wait_for { ready? }

# Rename datacenter.
datacenter.name = 'rename fog-demo'
datacenter.update

# Create public LAN.
lan = compute.lans.create(datacenter_id: datacenter.id, name: 'public', public: true)

# Define system volume.
volume = {
  name: 'system',
  size: 5,
  image: image.id,
  image_password: 'volume2016',
  ssh_keys: [ 'sshkey_example' ],
  type: 'HDD'
}

# Define public firewall rules.
fw1 = { name: 'Allow SSH', protocol: 'TCP', port_range_start: 22, port_range_end: 22 }
fw2 = { name: 'Allow Ping', protocol: 'ICMP', icmp_type: 8, icmp_code: 0 }

# Define public network interface.
nic = {
  name: 'public',
  lan: lan.id,
  dhcp: true,
  firewall_active: true,
  firewall_rules: [ fw1, fw2 ]
}

# Create a server with the above system volume and public network interface.
server = compute.servers.create(
  datacenter_id: datacenter.id,
  name: 'server1',
  cores: 1,
  ram: 2048,
  volumes: [volume],
  nics: [nic]
)
server.wait_for { ready? }

# Create data volume.
volume = compute.volumes.create(datacenter_id: datacenter.id, name: 'data', size: 5, licence_type: 'OTHER', type: 'SSD')
volume.wait_for { ready? }

# Attach data volume to server.
server.attach_volume(volume.id)

# Connect a second network interface to the server.
nic = compute.nics.create(datacenter_id: datacenter.id, server_id: server.id, name: 'private', dhcp: true, lan: 2)
nic.wait_for { ready? }
