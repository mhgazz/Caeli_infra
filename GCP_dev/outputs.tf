output "vm_ip" {
    description = "IP publica"
    value = google_compute_instance.caeli-engine.network_interface[0].access_config[0].nat_ip
}

output "Web-server-URL" {
 value = join("",["http://",google_compute_instance.caeli-engine.network_interface[0].access_config[0].nat_ip,":5000"])
}