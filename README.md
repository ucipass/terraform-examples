# Summary
Terraform examples mainly for quick network and proof of concept setup. The modules directory has Terraform modules implementations:

# Examples
- example1: Single VPC with a Palo Alto VM instance demonstrating the bootstrap process.
- example2: Single VPC with a Linux Ubuntu 20.04 VM instance script installs nginx.
- example3: Single VPC with a Windows 2019 VM instance script installs IIS.
- example4: Single VPC with a Cisco Catalyst 8000V.
- example5: Single Azure VNET with a Windows2019 instance

# Modules
- key-pair: generate SSH key pair in case there is not one available for use.
- palo: Palo Alto EC2 instance with mgmt, eth1, eth2 interfaces with bootstrapping procedure.
- ubuntu: Ubuntu 20.04 module
- win2019: Windows 2019 module
- tgw: Transit gateway attaching provided VPCs
- vpc-2public-2private: VPC with 2 available zones with each AZ havong 1 private and 1 public subnets.

