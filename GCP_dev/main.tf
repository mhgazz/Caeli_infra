provider "google" {
  project = var.project_id
  region = var.region
  zone = var.zone
}

resource "google_compute_network" "caeli-vpc" {
    name = "caeli-vpc"
    auto_create_subnetworks = false
    mtu = 1460
}

resource "google_compute_subnetwork" "caeli-subnet" {
    name = "caeli-subnet"
    ip_cidr_range = "10.0.1.0/24"
    region = var.region
    network = google_compute_network.caeli-vpc.id
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
        subnetwork = google_compute_subnetwork.caeli-subnet.id
        access_config { 

        }
    }

    metadata = {
        "vm_id" = "core vm"
    }

    metadata_startup_script = <<-EOF
        #!/bin/bash
        echo "VM creada bajo el influjo de $(date)" >> /var/log/Caeli.log
        sudo su -
        apt-get update && apt-get install -y python3 && sudo apt-get install -y git
        apt-get install -y python3 python3-pip git
        echo "Git instalado: $(git --version)" >> /var/log/Caeli.log
        cd /
        git clone https://oauth2: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@github.com/mhgazz/Caeli_app.git
        cd Caeli_app
        git checkout dev_1.0
        git fetch origin
        
        openssl s_client -showcerts -connect ssd.jpl.nasa.gov:443 < /dev/null | \awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/ {print}' > /Caeli_app/nasa_ca.pem
        apt-get install -y python3-venv >> /var/log/Caeli.log
        python3 -m venv .venv >> /var/log/Caeli.log
        source .venv/bin/activate >> /var/log/Caeli.log
        pip3 install -r /Caeli_app/src/requirements.txt >> /var/log/Caeli.log
        cp /Caeli_app/nasa_ca.pem /root/.venv/lib/python3.9/site-packages/certifi/cacert.pem >> /var/log/Caeli.log

        #pip3 install -r /Caeli_app/src/requirements.txt >> /var/log/Caeli.log
        echo "Python instalado: $(python3 --version)" >> /var/log/Caeli.log
        #openssl s_client -showcerts -connect ssd.jpl.nasa.gov:443 < /dev/null | \awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/ {print}' > nasa_ca.pem
        nohup python3 /Caeli_app/src/App.py >> /var/log/Caeli.log 2>&1 &
    EOF
}

resource "google_compute_firewall" "caeli-engine-firewall-tcp5000" {
  name = "allow-caeli"
  network = google_compute_network.caeli-vpc.id

  allow {
    protocol = "tcp"
    ports = ["5000"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "caeli-engine-firewall-ssh"{
  name="allow-ssh"
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  direction = "INGRESS"
  network = google_compute_network.caeli-vpc.id
  source_ranges = ["0.0.0.0/0"]
}

