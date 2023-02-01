module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 6.0"

    project_id   = var.project_id
    network_name = "vpc-terraform-kpmg"
    routing_mode = "GLOBAL"
    auto_create_subnetworks = false

    subnets = [
        {
            subnet_name           = "sub-terraform-001-private"
            subnet_ip             = "10.80.16.0/23"
            subnet_region         = var.region
            subnet_private_access = "true"
        },
                {
            subnet_name           = "sub-terraform-002-public"
            subnet_ip             = "10.90.16.0/23"
            subnet_region         = var.region
            subnet_private_access = "true"
        }
    ]

    secondary_ranges = {
        sub-terraform-001-private = [
            {
                range_name    = "range-pod"
                ip_cidr_range = "10.80.0.0/20"
            },
            {
                range_name    = "range-services"
                ip_cidr_range = "10.80.18.0/23"
            },
        ]

    }

    routes = [
        {
            name                   = "egress-internet"
            description            = "route through IGW to access internet"
            destination_range      = "0.0.0.0/0"
            tags                   = "egress-inet"
            next_hop_internet      = "true"
        },
    ]
}


module "cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 4.0"

  name    = "router"
  project = var.project_id
  region  = var.region
  network = module.vpc.network_name
  nats = [{
    name = "nat"
    nat_ip_allocate_option = "AUTO_ONLY"
    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
    subnetworks = [{
      name = "sub-terraform-001-private"
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }]
  }]
}








# module "vpc" {
#     source  = "../modules/network"
#     project_id   = var.project_id
#     network_name = "vpc-terraform-kpmg"
#     auto_create_subnetworks = false
#     shared_vpc_host = false
# }




### ------- VPC ------- ####
# resource "google_compute_network" "vpc-terraform-custom" {
#   name = "vpc-terraform-custom"
#   auto_create_subnetworks = false
# }
# output "custom" {
#     value = google_compute_network.vpc-terraform-custom.id
# }
  
### ------- SUBNET ------- ####
# resource "google_compute_subnetwork" "sub-terraform-001" {
#   name          = "sub-terraform-001"
#   ip_cidr_range = "10.80.16.0/23"
#   region        = var.region
#   network       = [module.network.network_id]
#   secondary_ip_range {
#         range_name    = "range-pod"
#         ip_cidr_range = "10.80.0.0/20"
#   }
#   secondary_ip_range {
#         range_name    = "range-services"
#         ip_cidr_range = "10.80.18.0/23"
#   }
#   private_ip_google_access = true
# }

### ------- FIREWALL RULE ------- ####
# resource "google_compute_firewall" "allow-ssh" {
#   project     = var.project_id
#   name        = "allow-ssh"
#   network     = google_compute_network.vpc-terraform-custom.id
#   description = "Creates firewall rule targeting tagged instances"

#   allow {
#     protocol  = "tcp"
#     ports     = ["22"]
#   }

#   source_ranges = ["0.0.0.0/0"]
#   target_tags = ["allow-ssh"]
# }

# resource "google_compute_firewall" "allow-http" {
#   project     = var.project_id
#   name        = "allow-http"
#   network     = google_compute_network.vpc-terraform-custom.id
#   description = "Creates firewall rule targeting tagged instances"

#   allow {
#     protocol  = "tcp"
#     ports     = ["8080"]
#   }

#   source_ranges = ["0.0.0.0/0"]
#   target_tags = ["allow-http"]
# }

/*
### ------- COMPUTE ENGINE ------- ####
resource "google_compute_instance" "bastion-xertica" {
  name         = "bastion-xertica"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  tags = ["allow-ssh"]

  boot_disk {
    initialize_params {
      image = "debian-9-stretch-v20210916"
      size = 20
    }
  }

  allow_stopping_for_update = true

  network_interface {
    subnetwork = google_compute_subnetwork.sub-terraform-001.id
    
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    project = "sandbox"
    billing = "Marketing"
  }

scheduling {
  preemptible = false
  automatic_restart = false
}
  service_account {
    email = "terraform-gcp@orion-ad-lab.iam.gserviceaccount.com"
    scopes = [ "cloud-platform"]
  }

  lifecycle {
    ignore_changes = [attached_disk]
  }
}

### ------- DISK ------- ####
resource "google_compute_disk" "disk-1" {
    name = "disk-1"
    size = 15
    zone = var.zones[1]
    type = "pd-ssd"
}

resource "google_compute_attached_disk" "disk-a" {
    disk = google_compute_disk.disk-1.id
    instance = google_compute_instance.bastion-xertica.id
}
/*

/*
### ------- CLOUD SQL ------- ####
resource "google_sql_database_instance" "mysql-terraform" {
    name = "mysql-terraform"
    database_version = "MYSQL_8_0"
    deletion_protection = false
    region = var.region

    settings {
        tier = "db-f1-micro"
    }
}

resource "google_sql_user" "myuser" {
    name = "xertica"
    password = "xertica@123"
    instance = google_sql_database_instance.mysql-terraform.name
}


### ------- BIG TABLE ------- ####
resource "google_bigtable_instance" "bigtable-tf" {

    name = "bigtable-tf"
    deletion_protection = false
    labels = {
        "env" = "testing"
    }
    cluster {
        cluster_id = "bigtable-tf-c1"
        num_nodes = 1
        storage_type = "SSD"
    }
}
*/

/*
module "gke" {
  source                    = "./modules/cluster/private-cluster-k8s/"
  project                   = var.project_id
  name                      = "cluster-afg-priv-1"
  name_cluster              = var.name_cluster
  #regional                  = true
  region                    = var.region
  zones                        = var.zones
  network                   = "projects/${var.project_id}/global/networks/vpc-terraform-custom"
  subnetwork                = "projects/${var.project_id}/regions/${var.region}/sub-terraform-001"
  cluster_config               = var.cluster_config
  node_pools_scopes            = var.node_pools_scopes
  secondary_ranges             = var.secondary_ranges
  #enable_private_endpoint   = true
  #enable_private_nodes      = true
  #master_ipv4_cidr_block    = "172.16.0.0/28"
  #default_max_pods_per_node = 20
  #remove_default_node_pool  = true
  node_count                   = "4"
  description                  = "Cluster privado proyecto mesos-dev"


  node_pools =  [
    {
      name              = "pool-01"
      min_count         = 1
      max_count         = 100
      local_ssd_count   = 0
      disk_size_gb      = 100
      disk_type         = "pd-standard"
      auto_repair       = true
      auto_upgrade      = true
      #service_account   = var.compute_engine_service_account
      preemptible       = false
      max_pods_per_node = 100
    }
  ]
  
}
*/


/*
module Cluster-gke-private {
   source                       = "./modules/cluster/cluster-private-k8s"
   node_pools                   = var.node_pools
   k8s_version                  = "1.18.17-gke.1900"
   name_cluster                 = "mesos-dev-cluster2"
   description                  = "Cluster privado proyecto mesos-dev"
   project                      = var.project_id
   zones                        = var.zones
   region                       = var.region
   network                      = "projects/${var.project_id}/global/networks/mesos-test-vpc"
   subnetwork                   = "projects/${var.project_id}/regions/${var.region}/mesos-test-subnet1"
   cluster_config               = var.cluster_config
   node_pools_scopes            = var.node_pools_scopes
   secondary_ranges             = var.secondary_ranges
   bastion_external_ip          = "10.161.2.0/24"
   node_count                   = "3" 
   name_bastion                 = "bastion-mesos-dev"
   #default_max_pods_per_node    = 30

   depends_on = [module.VPC_Network]
}
*/



# resource "google_compute_instance" "instance-imp" {
#   name = "instance-vm-imp"
#   machine_type = "e2-micro"
#   zone = "us-central1-a"

#   tags = ["project","weathergroup"]

#   boot_disk {
#         initialize_params {
#             image = "debian-cloud/debian-11"
#             size   = 10
#         }
#     }


#     network_interface {
#         network = "vpc-terraform-custom"
#         subnetwork = "sub-terraform-001"
#         access_config {
#             network_tier = "PREMIUM"
#         }
#     }
# }

# output "idsss" {
#   value = google_compute_instance.instance-imp.instance_id
# }

# # VM 2do
# resource "google_compute_instance" "instance-imp2" {
#   name = "instance-vm-imp2"
#   machine_type = "e2-micro"
#   zone = var.zones[1]

#   tags = ["project","weathergroup"]

#   boot_disk {
#         initialize_params {
#             image = "debian-cloud/debian-11"
#             size   = 10
#         }
#     }


#     network_interface {
#         network = "vpc-terraform-custom"
#         subnetwork = "sub-terraform-001"
#         access_config {
#             network_tier = "PREMIUM"
#         }
#     }
# }

# #cloud router
# resource "google_compute_router" "cloudrouterimport" {

#     encrypted_interconnect_router = false
#     name                          = "cloud-router-import"
#     network                       = "https://www.googleapis.com/compute/v1/projects/orion-ad-lab/global/networks/vpc-terraform-custom"
#     project                       = "orion-ad-lab"
#     region                        = "us-central1"

#     bgp {
#         advertise_mode    = "DEFAULT"
#         advertised_groups = []
#         asn               = 64514
#     }

#     timeouts {}
# }
