terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.39.0"
    }
  }
}

provider "google" {
  project = var.gcp_project
}

resource "google_compute_network" "sandbox_network" {
  name = "sandbox-network"

  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "sandbox_subnet" {
  name          = "sandbox-subnet"
  ip_cidr_range = "10.0.0.0/16"
  network       = google_compute_network.sandbox_network.id
  region        = var.gcp_region
}

resource "google_compute_instance" "k0s_instances" {
  count = 3

  name         = "k0s-instance-${count.index}"
  machine_type = "e2-medium"
  zone         = var.gcp_zone

  tags = ["k0s", "instance-${count.index}"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-minimal-2204-lts"
      type  = "pd-standard"
      size  = 15
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.sandbox_subnet.id

    access_config {

    }
  }

  metadata = {
    ssh-keys = "vuchuc:${file("./instance_key.pub")}"
  }
}

resource "google_compute_firewall" "allow_ssh" {
  name = "allow-ssh"

  allow {
    ports    = ["22"]
    protocol = "tcp"
  }

  direction     = "INGRESS"
  network       = google_compute_network.sandbox_network.id
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_ping" {
  name = "allow-ping"

  allow {
    protocol = "icmp"
  }

  direction     = "INGRESS"
  network       = google_compute_network.sandbox_network.id
  source_ranges = ["10.0.0.0/16"]
}

resource "google_compute_firewall" "allow_ports" {
  name = "allow-ports"

  allow {
    ports    = ["9443", "2379-2380", "10250", "10259", "10257", "10250", "10256", "30000-32767"]
    protocol = "tcp"
  }

  allow {
    ports    = ["30000-32767"]
    protocol = "udp"
  }

  direction     = "INGRESS"
  network       = google_compute_network.sandbox_network.id
  source_ranges = ["10.0.0.0/16"]
}

resource "google_compute_firewall" "allow_public_ports" {
  name = "allow-public-ports"

  allow {
    ports    = ["6443"]
    protocol = "tcp"
  }

  direction     = "INGRESS"
  network       = google_compute_network.sandbox_network.id
  source_ranges = ["0.0.0.0/0"]
}
