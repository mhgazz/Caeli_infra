provider "google" {
  project = var.project_id
  region = var.region
  zone = var.zone
}

resource "google_compute_instance" "caeli-engine" {
    name = var.vm_core_name
    machine_type = var.vm_core_type
    zone = var.zone

    boot_disk {
      initialize_params {
        image = "debian-cloud/debian-11"
      }
    }

    network_interface {
        network = "default"
        access_config { }
    }

    metadata = {
        "vm_id" = "core vm"
    }

    metadata_startup_script = <<-EOF
        #!/bin/bash
        echo "VM creada bajo el influjo de $(date)" >> /var/log/Caeli.log
        sudo su -
        apt-get update && apt-get install -y python3 && sudo apt-get install -y git
        echo "Git instalado: $(git --version)" >> /var/log/Caeli.log
        cd /
        git clone https://oauth2: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@github.com/mhgazz/Caeli_app.git
        cd Caeli_app
        git checkout dev_1.0
        git fetch origin
        python3 /Caeli_app/src/App.py >> /var/log/Caeli.log
    EOF

}