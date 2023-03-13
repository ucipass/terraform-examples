output "mgmt_ip_public" {
    value = aws_eip.public_ip_mgmt.public_ip
}
output "eth1_ip_public" {
    value = aws_eip.public_ip_eth1.public_ip
}
