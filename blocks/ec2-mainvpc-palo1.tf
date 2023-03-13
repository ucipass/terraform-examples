# Create PA VM-series instances
resource "aws_instance" "palo1" {

  ami                                  = "ami-04faf011af88eb8e7"
  instance_type                        = var.instance_type
  key_name                             = var.ssh_key_name
  iam_instance_profile                 = aws_iam_instance_profile.palo1.id
  disable_api_termination              = false
  ebs_optimized                        = true
  instance_initiated_shutdown_behavior = "stop"
  monitoring                           = false

  network_interface {
    network_interface_id = aws_network_interface.mgmt.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.eth1.id
    device_index         = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.eth2.id
    device_index         = 2
  }


  user_data = <<EOF
    vmseries-bootstrap-aws-s3bucket=tfdemo-dev-palo1
  EOF


  root_block_device {
    delete_on_termination = true
    encrypted             = false
  }
  tags = {
    Name        = "${lower(var.app_name)}-${var.app_environment}-palo1"
    Environment = var.app_environment
  }

}

# Create Elastic IP for the EC2 instance
resource "aws_eip" "palo-eip" {
  vpc  = true
  tags = {
    Name        = "${lower(var.app_name)}-${var.app_environment}-palo-eip"
    Environment = var.app_environment
  }
  
}





resource "aws_eip" "public_ip_mgmt" {
  vpc                       = true
  network_interface         = aws_network_interface.mgmt.id
  # associate_with_private_ip = "10.1.1.10"
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpcmain-palo1-mgmt"
    Environment = var.app_environment
  }
  depends_on = [
    aws_instance.palo1
  ]  

}

resource "aws_eip" "public_ip_eth1" {
  vpc                       = true
  network_interface         = aws_network_interface.eth1.id
  # associate_with_private_ip = "10.1.1.10"
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpcmain-palo1-eth1"
    Environment = var.app_environment
  }
  depends_on = [
    aws_instance.palo1
  ]  

}

resource "aws_network_interface" "mgmt" {
  subnet_id         = aws_subnet.vpcmain-public-subnet1.id
  # private_ips       = [ var.private_ip2 ]
  security_groups   =  [aws_security_group.aws-palo-sg.id]
  source_dest_check = false
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpcmain-palo1-mgmt"
    Environment = var.app_environment
  }
}

resource "aws_network_interface" "eth1" {
  subnet_id         = aws_subnet.vpcmain-public-subnet1.id
  # private_ips       = [ var.private_ip2 ]
  security_groups   =  [aws_security_group.aws-palo-sg.id]
  source_dest_check = false
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpcmain-palo1-eth1"
    Environment = var.app_environment
  }

}

resource "aws_network_interface" "eth2" {
  subnet_id         = aws_subnet.vpcmain_private-subnet1.id
  # private_ips       = [ var.private_ip2 ]
  security_groups   =  [aws_security_group.aws-palo-sg.id]
  source_dest_check = false
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpcmain-palo1-eth2"
    Environment = var.app_environment
  }

}




# Define the security group for the Palo Alto FIrewall
resource "aws_security_group" "aws-palo-sg" {
  name        = "${lower(var.app_name)}-${var.app_environment}-palo-sg"
  description = "Allow incoming HTTP connections"
  vpc_id      = aws_vpc.vpcmain.id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming ICMP connections"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTPS connections"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming SSH connections"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${lower(var.app_name)}-${var.app_environment}-palo-sg"
    Environment = var.app_environment
  }
}


###################################################
#
#
#  S3 Bootstrap Configuration
#
#
###################################################

resource "aws_s3_bucket" "s3_bucket_palo1" {
  bucket = "${lower(var.app_name)}-${lower(var.app_environment)}-palo1"

#   bucket = "${lower(var.app_name)}-${lower(var.app_environment)}-${lower(var.s3_bucket_prefix_palo1)}-${random_uuid.uuid.result}"
#   force_destroy = false
}

resource "aws_s3_bucket_object" "config" {
    bucket = aws_s3_bucket.s3_bucket_palo1.id
    acl    = "private"
    key    = "config/"
    source = "/dev/null"
}

resource "aws_s3_bucket_object" "content" {
    bucket = aws_s3_bucket.s3_bucket_palo1.id
    acl    = "private"
    key    = "content/"
    source = "/dev/null"
}

resource "aws_s3_bucket_object" "license" {
    bucket = aws_s3_bucket.s3_bucket_palo1.id
    acl    = "private"
    key    = "license/"
    source = "/dev/null"
}

resource "aws_s3_bucket_object" "software" {
    bucket = aws_s3_bucket.s3_bucket_palo1.id
    acl    = "private"
    key    = "software/"
    source = "/dev/null"
}

# Upload bootstrap
resource "aws_s3_bucket_object" "bootstrap" {
  bucket = aws_s3_bucket.s3_bucket_palo1.id
  key    = "/config/bootstrap.xml"
  acl    = "private" 
  source = "./bootstrap.xml"
  etag = filemd5("./bootstrap.xml")
}

# Upload bootstrap
resource "aws_s3_bucket_object" "initcfg" {
  bucket = aws_s3_bucket.s3_bucket_palo1.id
  key    = "/config/init-cfg.txt"
  acl    = "private" 
  source = "./init-cfg.txt"
  etag = filemd5("./init-cfg.txt")
}

resource "aws_s3_bucket_acl" "s3_bucket_palo1" {
  bucket = aws_s3_bucket.s3_bucket_palo1.id
  acl    = "private"
}

# resource "aws_s3_bucket_cors_configuration" "s3_bucket_palo1" {
#   bucket = aws_s3_bucket.s3_bucket_palo1.id

#   cors_rule {
#     allowed_headers = ["*"]
#     allowed_methods = ["GET","PUT","DELETE","HEAD", "POST"]
#     allowed_origins = ["*"]
#     expose_headers  = ["ETag"]
#     max_age_seconds = 3000
#   }  

# }

# resource "aws_s3_bucket_lifecycle_configuration" "s3_bucket_palo1" {
#   bucket = aws_s3_bucket.s3_bucket_palo1.id

#   rule {
#     id = "rule-1"
#     expiration {
#         days = 1
#     }
#     filter {}
#     status = "Enabled"
#   }
# }

resource "aws_iam_instance_profile" "palo1" {
  name = "palo1"
  role = aws_iam_role.palo1.name
}

resource "aws_iam_role" "palo1" {
  name = "${lower(var.app_name)}-${lower(var.app_environment)}-palo1"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            }
        }
    ]
}
EOF

}

resource "aws_iam_role_policy" "palo1" {
  name = "${lower(var.app_name)}-${lower(var.app_environment)}-palo1"
  role = aws_iam_role.palo1.id

  policy = <<EOF
{
   "Version": "2012-10-17", 
   "Statement": [ 
   { 
      "Effect": "Allow", 
      "Action": ["s3:ListBucket"], 
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.s3_bucket_palo1.id}"] 
   }, 
   { 
      "Effect": "Allow", 
      "Action": ["s3:GetObject"], 
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.s3_bucket_palo1.id}/*"] 
      } 
   ] 
}
EOF
}