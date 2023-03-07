# Palo Alto Variables

variable "vmseries_version" {
  description = <<-EOF
  VM-Series Firewall version to deploy.
  To list all available VM-Series versions, run the command provided below. 
  Please have in mind that the `product-code` may need to be updated - check the `vmseries_product_code` variable for more information.
  ```
  aws ec2 describe-images --region us-west-1 --filters "Name=product-code,Values=6njl1pau431dv1qxipg63mvah" "Name=name,Values=PA-VM-AWS*" --output json --query "Images[].Description" \| grep -o 'PA-VM-AWS-.*' \| sort
  ```
  EOF
  default     = "10.2.0"
  validation {
    error_message = "Must be valid semantic version."
    condition     = can(regex("^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$", var.vmseries_version))
  }
  type = string
}

variable "vmseries_product_code" {
  description = <<-EOF
  Product code corresponding to a chosen VM-Series license type model - by default - BYOL. 
  To check the available license type models and their codes, please refer to the
  [VM-Series documentation](https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/set-up-the-vm-series-firewall-on-aws/deploy-the-vm-series-firewall-on-aws/obtain-the-ami/get-amazon-machine-image-ids.html)
  EOF
  default     = "6njl1pau431dv1qxipg63mvah"
  type        = string
}


# PA VM AMI ID lookup based on version and license type (determined by product code)
data "aws_ami" "this" {
  count = var.vmseries_ami_id != null ? 0 : 1

  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["PA-VM-AWS-${var.vmseries_version}*"]
  }
  filter {
    name   = "product-code"
    values = [var.vmseries_product_code]
  }
}

# VM-Series version setup
variable "vmseries_ami_id" {
  description = <<-EOF
  Specific AMI ID to use for VM-Series instance.
  If `null` (the default), `vmseries_version` and `vmseries_product_code` vars are used to determine a public image to use.
  EOF
  default     = null
  validation {
    error_message = "Must be a valid AMI ID."
    condition     = var.vmseries_ami_id == null || can(regex("^ami-[a-z0-9]{17}$", var.vmseries_ami_id))
  }
  type = string
}

variable "instance_type" {
  description = "EC2 instance type."
  default     = "m5.xlarge"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of AWS keypair to associate with instances."
  default     = "AA"
  type        = string
}

variable "ebs_encrypted" {
  description = "Whether to enable EBS encryption on volumes."
  default     = true
  type        = bool
}

variable "bootstrap_options" {
  description = <<-EOF
  VM-Series bootstrap options to provide using instance user data. Contents determine type of bootstap method to use.
  If empty (the default), bootstrap process is not triggered at all.
  For more information on available methods, please refer to VM-Series documentation for specific version.
  For 10.0 docs are available [here](https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/bootstrap-the-vm-series-firewall.html).
  EOF
  default     = ""
  type        = string
}

variable "enable_imdsv2" {
  description = <<-EOF
  Whether to enable IMDSv2 on the EC2 instance.
  VM-Series version 10.2.0 or higher is required to install VM-Series Plugin 3.0.0. 
  This release of the plugin introduces enhanced Instance Metadata Service (IMDSv2) for securing instances AWS.
  https://docs.paloaltonetworks.com/plugins/vm-series-and-panorama-plugins-release-notes/vm-series-plugin/vm-series-plugin-30/vm-series-plugin-300#id126d0957-95d7-4b29-9147-fff20027986e
  EOF
  default     = true
  type        = string
}