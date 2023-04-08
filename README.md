# Summary
Terraform examples mainly for quick network and proof of concept setup. The modules directory has Terraform modules implementations:

# Modules
- key-pair: generate SSH key pair in case there is not one available for use.
- win2019: Windows 2019 module
- ubuntu: Ubuntu 20.04 module
- palo: Palo Alto EC2 instance with mgmt, eth1, eth2 interfaces with bootstrapping procedure.
- c8000v: Cisco Catalyst 8000v EC2 instance with mgmt, eth1, eth2 interfaces with bootstrapping procedure.
- tgw: Transit gateway attaching provided VPCs
- vpc: VPC with 2 available zones with each AZ havong 1 private and 1 public subnets.

# Examples
## AWS
- example1: AWS Single VPC with a Windows 2019 VM instance script installs IIS.
- example2: AWS Single VPC with a Linux Ubuntu 20.04 VM instance script installs nginx.
- example3: AWS Single VPC with a Cisco Catalyst 8000V.
- example4: AWS Single VPC with a Palo Alto VM instance demonstrating the bootstrap process.
- example5: AWS ECS Fargate with NGINX default webserver
- example6: AWS Lambda function deployed with API Gateway REST APIs
- example7: AWS Lambda function deployed with API Gateway HTTP APIs v2

## Azure
- example1: Azure Single  VNET with a Windows2019 instance script installs IIS.
- example2: Azure Single  VNET with an Ubuntu instance script installs NGINX.

