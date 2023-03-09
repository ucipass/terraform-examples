############################################
## Transit Gateway and Attachments        ##
############################################

# Create Transit Gateway
resource "aws_ec2_transit_gateway" "main_tgw" {
  description                     = "Transit Gateway with 3 VPCs, 2 subnets each"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-main_tgw"
    Environment = var.app_environment
  }
}

resource "aws_ec2_transit_gateway_route_table" "main_tgw-vpcmain-rt" {
  transit_gateway_id = "${aws_ec2_transit_gateway.main_tgw.id}"
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-main_tgw_vpcmain_rt"
    Environment = var.app_environment
  }
  depends_on = [aws_ec2_transit_gateway.main_tgw]
}

resource "aws_ec2_transit_gateway_route_table" "main_tgw-vpc101-rt" {
  transit_gateway_id = "${aws_ec2_transit_gateway.main_tgw.id}"
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-main_tgw_vpc01_rt"
    Environment = var.app_environment
  }
  depends_on = [aws_ec2_transit_gateway.main_tgw]
}

resource "aws_ec2_transit_gateway_route_table" "main_tgw-vpc102-rt" {
  transit_gateway_id = "${aws_ec2_transit_gateway.main_tgw.id}"
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-main_tgw_vpc102_rt"
    Environment = var.app_environment
  }
  depends_on = [aws_ec2_transit_gateway.main_tgw]
}

resource "aws_ec2_transit_gateway_route_table_association" "main_tgw-vpcmain-rt-assoc" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpcmain.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.main_tgw-vpcmain-rt.id}"
}

resource "aws_ec2_transit_gateway_route_table_association" "main_tgw-vpc101-rt-assoc" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc101.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.main_tgw-vpc101-rt.id}"
}

resource "aws_ec2_transit_gateway_route_table_association" "main_tgw-vpc102-rt-assoc" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc102.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.main_tgw-vpc102-rt.id}"
}

# Transit gateway propagation

resource "aws_ec2_transit_gateway_route_table_propagation" "main_tgw_prop_vpc101_vpcmain" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpcmain.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.main_tgw-vpc101-rt.id}"
}

resource "aws_ec2_transit_gateway_route_table_propagation" "main_tgw_prop_vpc102_vpcmain" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpcmain.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.main_tgw-vpc102-rt.id}"
}

resource "aws_ec2_transit_gateway_route_table_propagation" "main_tgw_prop_vpcmain_vpc101" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc101.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.main_tgw-vpcmain-rt.id}"
}

resource "aws_ec2_transit_gateway_route_table_propagation" "main_tgw_prop_vpcmain_vpc102" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc102.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.main_tgw-vpcmain-rt.id}"
}


# VPC attachments vpcmain

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpcmain" {
  subnet_ids         = [aws_subnet.vpcmain_private-subnet1.id,aws_subnet.vpcmain_private-subnet2.id]
  transit_gateway_id = aws_ec2_transit_gateway.main_tgw.id
  vpc_id             = aws_vpc.vpcmain.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-main_tgw-att-vpcmain"
    Environment = var.app_environment
  }
  depends_on = [aws_ec2_transit_gateway.main_tgw]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc101" {
  subnet_ids         = [aws_subnet.vpc101_private-subnet1.id,aws_subnet.vpc101_private-subnet2.id]
  transit_gateway_id = aws_ec2_transit_gateway.main_tgw.id
  vpc_id             = aws_vpc.vpc101.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-main_tgw-att-vpc101"
    Environment = var.app_environment
  }
  depends_on = [aws_ec2_transit_gateway.main_tgw]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc102" {
  subnet_ids         = [aws_subnet.vpc102_private-subnet1.id,aws_subnet.vpc102_private-subnet2.id]
  transit_gateway_id = aws_ec2_transit_gateway.main_tgw.id
  vpc_id             = aws_vpc.vpc102.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-main_tgw-att-vpc102"
    Environment = var.app_environment
  }
  depends_on = [aws_ec2_transit_gateway.main_tgw]
}
