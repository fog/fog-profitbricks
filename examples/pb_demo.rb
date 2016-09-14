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
system_volume = {
  name: 'system',
  size: 5,
  image: image.id,
  image_password: 'volume2016',
  ssh_keys: [ 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCZTshTmxydYKikL9aHbXZj3HadTfT4MpmcxzuATe7aiqWZCqfig8IQf9zSnyz6/KmTHsAKgMD84mmiz5N2C1jtcJ+r/NM9O8GMeKw81Lh4b9oHsWK6g0Rh5qaIauAFHPxYBZ8oJ5cpAIoAWifUxsa78ye5P4Z8JIhzeYh1zHpJtkAntMq603oQr5nYfNdTMC2oZ8vC8+R62iDgol9BfP0/O07FqTaAmbbl25GWQsn8SEkA042aIRCta+8wYlS1k0l/G/k3uCGHg40dKexTFMU/QLf7+zpNqiZ9JCRm48cxqUM7EObQLpiMutExoLL/wM97mAMZvW3x2OtTB2dJ1zsH6fw34dI+oD7reHiGwD7FC/Wljvy193tig9JlKS16VD+Etwr7LWp9qCY+KJDUSIoikAHfhBC5IyFaX/Yed7RW9oJ/gb4b21vFeW2MXQW9bI8S8oHE2YplzNT+x6N0PUnq75XMHbcpLZEAJu7ix6pGfThlQklVBHlMEmhH7E3I55AHYet9khDFEW2wtXdkWzV15S6A1e8l0FXkxIEgwKS6OpE1VXd3U3PPQ/UqgsM9leJ9RL8LMGcg8jDoGiAffix3iAX7edaLl7b3MgEjmFTDeYJxBCtSEwpJ6wS3hZ4GVG39EU8Hn4OutFFrbW4fxRbF2sja8Met7DiN505978rizw==' ],
  type: 'HDD'
}

# Define public firewall rules.
fw1 = { name: 'Allow SSH', protocol: 'TCP', port_range_start: 22, port_range_end: 22 }
fw2 = { name: 'Allow Ping', protocol: 'ICMP', icmp_type: 8, icmp_code: 0 }

# Define public network interface.
public_nic = {
  name: 'public',
  lan: lan.id,
  dhcp: true,
  firewall_active: true,
  firewall_rules: [ fw1, fw2 ]
}

# Create a server with the above system volume and public network interface.
server1 = compute.servers.create(
  datacenter_id: datacenter.id,
  name: 'server1',
  cores: 1,
  cpu_family: 'AMD_OPTERON',
  ram: 2048,
  volumes: [system_volume],
  nics: [public_nic]
)
server1.wait_for { ready? }

# Change CPU family from AMD_OPTERON to INTEL_XEON.
server1.allow_reboot = true
server1.cpu_family = 'INTEL_XEON'
server1.update

# Create data volume.
data_volume = compute.volumes.create(datacenter_id: datacenter.id, name: 'data', size: 5, licence_type: 'OTHER', type: 'SSD')
data_volume.wait_for { ready? }

# Attach data volume to server1.
server1.attach_volume(data_volume.id)

# Connect a second network interface to server1.
private_nic = compute.nics.create(datacenter_id: datacenter.id, server_id: server1.id, name: 'private', dhcp: true, lan: 2)
private_nic.wait_for { ready? }

# Create a second server.
server2 = compute.servers.create(
  datacenter_id: datacenter.id,
  name: 'server2',
  cores: 1,
  cpu_family: 'AMD_OPTERON',
  ram: 2048,
  volumes: [system_volume]
)
server2.wait_for { ready? }

# Connect a private network interface to server2.
private_nic = compute.nics.create(datacenter_id: datacenter.id, server_id: server2.id, name: 'private', dhcp: true, lan: 2)
private_nic.wait_for { ready? }
