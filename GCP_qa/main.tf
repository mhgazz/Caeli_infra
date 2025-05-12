provider "google" {
  project = var.project_id
  region = var.region
  zone = var.zone
}

resource "google_compute_instance_template" "caeli-engine-template" {
  name="caeli-vm-engine-template"
  machine_type = var.vm_core_type
  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete = true
    boot = true
  }
  network_interface {
    network = "default"
    access_config {}
  }
  metadata_startup_script = <<-EOF
    #!/bin/bash
    echo "VM creada bajo el signo de $(date)" >> /var/log/coeli.log
    apt-get update && apt-get install -y apache2
    echo "<html><body><h1>VM bajo el signo de $(hostname)</h1></body></html>" > /var/www/html/index.html
  EOF
}

resource "google_compute_instance_group_manager" "caeli-engine-ig" {
  name = "caeli-engine-ig"
  base_instance_name = "caeli-engine-vm"
  zone = var.zone
  target_size = 1
  version {
    instance_template = google_compute_instance_template.caeli-engine-template.id
  }  
}

resource "google_compute_health_check" "caeli-engine-hc" {
  name = "caeli-engine-hc"
  http_health_check {
    port = 80
    request_path = "/"
  }
}

resource "google_compute_backend_service" "caeli-engine-bs" {
  name = "caeli-engine-bs"
  port_name = "http"
  protocol = "HTTP"
  timeout_sec = 10
  backend {
    group = google_compute_instance_group_manager.caeli-engine-ig.instance_group
  }
  health_checks = [google_compute_health_check.caeli-engine-hc.id]
}

resource "google_compute_url_map" "caeli-engine-url-map" {
  name="caeli-engine-url-map"
  default_service = google_compute_backend_service.caeli-engine-bs.id
}

resource "google_compute_target_http_proxy" "caeli-engine-proxy" {
  name = "caeli-engine-proxy" 
  url_map = google_compute_url_map.caeli-engine-url-map.id
  
}

resource "google_compute_global_forwarding_rule" "caeli-engine-forwarding-rule" {
  name = "caeli-engine-forwarding-rule"
  target = google_compute_target_http_proxy.caeli-engine-proxy.id
  port_range = "80"
  #network = "default"
}