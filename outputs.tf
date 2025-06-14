output "instance_external_ips" {
  value = google_compute_instance.k0s_instances[*].network_interface.0.access_config.0.nat_ip
}
