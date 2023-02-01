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

