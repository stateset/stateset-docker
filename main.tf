# Google Provider for Stateset

provider "google" {
  project = "stateset-28"
  region  = "us-central1"
  zone    = "us-central1-c"
}

# Cloud SQL Database 

resource "google_sql_database_instance" "master" {
  name             = "stateset-postgres"
  database_version = "POSTGRES_11"
  region           = "us-central1"

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
  }
}

# Kubernetes Cluster

resource "google_container_cluster" "primary" {
  name               = "stateset-cluster"
  zone               = "us-central1-c"
  initial_node_count = 3

}

  # The following outputs allow authentication and connectivity to the GKE Cluster.
output "client_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.primary.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
}



# Compute Resource

resource "google_compute_instance" "vm_instance" {
  name         = "stateset-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "stateset/stateset:latest"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network       = "${google_compute_network.vpc_network.self_link}"
    access_config = {
    }
  }
}

# Google Network 

resource "google_compute_network" "vpc_network" {
  name                    = "stateset-network"
  auto_create_subnetworks = "true"
}
