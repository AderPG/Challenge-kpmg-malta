#ID de Proyecto
variable "project_id" {
  default = "orion-ad-lab"
}

# Region
variable "region" {
  default = "us-central1"
}

# Zone List
#variable "zones" {
#  type = list
#  default = ["us-central1-b","us-central1-a","us-central1-c","us-central1-f"]
#}

variable "zones" {
  type = list
}







#  a revisar

# GKE Variables

variable "name_cluster" {
  default = "cluster-afg-mesos"
}

variable "secondary_ranges" {
  default = [{
    name = "range-pod"
    ipv4_cidr_block  = "10.80.0.0/20"
  },
  {
    name = "range-services"
    ipv4_cidr_block  = "10.80.18.0/23"
  }]  
}

variable "cluster_config" {
  type = list
  default = [{
   disable_public_endpoint = "true"     
    enable_private_nodes    = "true"
    master_ipv4_cidr_block  = "132.16.0.0/28"
    enable_shielded_nodes   = "true"
  },]  
}


### --- revisar cada atributo asd 
variable "node_pools" {
  type = list(map(string))
  default = [ {
      name_node_pool        = "mesos-pool-prod-1"
      name                  = "mesos-pool-prod-2"
      initial_node_count    = "3"
      image_type            = "COS_CONTAINERD"
      machine_type          = "n2-standard-2"
      disk_size_gb          = "100"
      disk_type             = "pd-ssd"
      preemptible           = "false"
      tags                  = "pool-nodos-prod"
    }
  ]
}

variable "node_pools_scopes" {
  default = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
  ]
  description = "list of OAuth scopes e.g.: https://www.googleapis.com/auth/compute], global per all node pools"
}