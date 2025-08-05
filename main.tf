# main.tf

# Resource to manage your SSH public key within OpenStack.
# This uploads your public key so it can be injected into new servers.
resource "openstack_compute_keypair_v2" "ndj_ai_keypair" {
  name       = "ndj_ai_key"
  public_key = file("./ndj_ai_key.pub") # Reads your public key from the file
}

# Resource to define and create the virtual machine (compute instance).
resource "openstack_compute_instance_v2" "ndj_ai_instance" {
  name            = "ndj-ai-agentic"
  # You need to find a valid image name from your OpenStack cloud.
  # e.g., 'Ubuntu-22.04' or a specific ID.
  image_name      = "NeSI-FlexiHPC-Ubuntu-Jammy_22.04-rc"

  # You need to find a valid flavor name (instance size).
  # e.g., 'c1.c1r1'
  flavor_name     = "balanced1.1cpu2ram"

  # This links the SSH keypair we defined above.
  key_pair        = openstack_compute_keypair_v2.ndj_ai_keypair.name

  # You need to find the name of the network to attach to.
  # This is often 'private' or a specific project network name.
  network {
    name = "uoa-drai-sandbox"
  }

  # This is where you can specify the security groups for the instance.
  # The 'default' group is often created by OpenStack, but you can add more
  # specific groups as needed.
  # Here we are adding a custom security group for SSH access.
  security_groups = [
    "default", # It's good practice to keep the 'default' group
    openstack_networking_secgroup_v2.ssh_access.name
  ]

}

# Define a persistent data volume using the Cinder (Block Storage) service
resource "openstack_blockstorage_volume_v3" "ndj_ai_data_volume" {
  name = "${openstack_compute_instance_v2.ndj_ai_instance.name}-data-volume"
  size = 50 # The size of the volume in GB
  description = "Persistent data storage for ${openstack_compute_instance_v2.ndj_ai_instance.name}"
}

# Attach the volume to the instance
resource "openstack_compute_volume_attach_v2" "volume_attachment" {
  instance_id = openstack_compute_instance_v2.ndj_ai_instance.id
  volume_id   = openstack_blockstorage_volume_v3.ndj_ai_data_volume.id
}

# # Define a security group to allow SSH access to the instance
# resource "openstack_compute_secgroup_v2" "ssh_access" {
#   name        = "allow-ssh-access"
#   description = "A security group to allow SSH access"

#   rule {
#     from_port   = 22
#     to_port     = 22
#     ip_protocol = "tcp"
#     # This allows access from ANY IP address. For better security, you can
#     # replace "0.0.0.0/0" with your own IP address, like "203.0.113.55/32".
#     remote_ip_prefix = "0.0.0.0/0"
#   }
# }

# Create the security group "container" using the modern networking resource
resource "openstack_networking_secgroup_v2" "ssh_access" {
  name        = "allow-ssh-access-networking" # Giving it a slightly new name
  description = "A security group to allow SSH access (using Neutron)"
}

# Create the specific SSH rule and add it to the group we just defined
resource "openstack_networking_secgroup_rule_v2" "ssh_access_rule" {
  direction         = "ingress"  # Ingress means incoming traffic
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ssh_access.id # Links rule to the group
}

# Allocate a new Floating IP from a public pool
resource "openstack_networking_floatingip_v2" "my_fip" {
  # You need to know the name of the external network pool.
  # It's often 'public', 'ext-net', or 'provider'.
  # Find it by running: openstack network list --external
  pool = "external"
}

# Associate the Floating IP with your instance
resource "openstack_compute_floatingip_associate_v2" "my_fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.my_fip.address
  instance_id = openstack_compute_instance_v2.ndj_ai_instance.id
}

# Output the public IP address of the instance
# This will be useful to connect to your instance via SSH.
output "instance_floating_ip" {
  description = "The public floating IP address of the instance."
  value       = openstack_networking_floatingip_v2.my_fip.address
}