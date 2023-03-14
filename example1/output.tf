output "application_prefix" {
    value = "${lower(var.app_name)}-${lower(var.app_environment)}"
}

output "default_ssh_key_name" {
    value = var.ssh_key_name
}
