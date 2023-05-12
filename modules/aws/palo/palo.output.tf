output "mgmt_ip_public" {
    value = aws_eip.public_ip_mgmt.public_ip
}
output "eth1_ip_public" {
    value = aws_eip.public_ip_eth1.public_ip
}


output "mgmt_int_id" {
    value = aws_network_interface.mgmt.id
}
output "eth1_int_id" {
    value = aws_network_interface.eth1.id
}
output "eth2_int_id" {
    value = aws_network_interface.eth2.id
}


