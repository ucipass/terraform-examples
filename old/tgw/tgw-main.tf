############################################
## Transit Gateway and Attachments        ##
############################################

# Create Transit Gateway
resource "aws_ec2_transit_gateway" "main_tgw" {
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name = var.tgw_name
  }
}


resource "aws_ec2_transit_gateway_route_table" "rt" {
  count    = length(var.vpc_ids)

  transit_gateway_id = aws_ec2_transit_gateway.main_tgw.id
  tags = {
    Name = "${var.tgw_name}-rt${count.index+1}"
  }
  depends_on = [aws_ec2_transit_gateway.main_tgw]
}


resource "aws_ec2_transit_gateway_vpc_attachment" "att" {
  count    = length(var.vpc_ids)

  vpc_id             = var.vpc_ids[count.index]
  subnet_ids         = var.subnet_ids[count.index]
  transit_gateway_id = aws_ec2_transit_gateway.main_tgw.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "${var.tgw_name}-att${count.index+1}"
  }
  depends_on = [aws_ec2_transit_gateway.main_tgw]
}

resource "aws_ec2_transit_gateway_route_table_association" "rt-assoc" {
  count    = length(var.vpc_ids)

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.att[count.index].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt[count.index].id
}


  # Nested loop over both lists, and flatten the result.
  locals {
    att_rt = distinct(flatten([
      for att in aws_ec2_transit_gateway_vpc_attachment.att : [
        for rt in aws_ec2_transit_gateway_route_table.rt : {
          att = att
          rt  = rt
        }
      ]
    ]))
  }

resource "aws_ec2_transit_gateway_route_table_propagation" "rt_prop" {
  count    = length(local.att_rt)

  transit_gateway_attachment_id  = local.att_rt[count.index].att.id
  transit_gateway_route_table_id = local.att_rt[count.index].rt.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.att, aws_ec2_transit_gateway_route_table.rt ]
}
