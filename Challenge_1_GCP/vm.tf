module "vm_instance_template-01" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "8.0.0"
  # insert the 1 required variable here
  name_prefix = "front"
  region = var.region
  subnetwork = "sub-terraform-001-private"
  service_account = {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = "665756770575-compute@developer.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}

output "template-name-front" {
    value = module.vm_instance_template-01.name
}


module "vm_instance_template-02" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "8.0.0"
  # insert the 1 required variable here
  name_prefix = "backend-template"
  region = var.region
  subnetwork = "sub-terraform-001-private"
  service_account = {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = "665756770575-compute@developer.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}

output "template-name-backend" {
    value = module.vm_instance_template-02.name
}


module "vm_mig-front" {
  source  = "terraform-google-modules/vm/google//modules/mig"
  version = "8.0.0"
  # insert the 2 required variables here
  mig_name = "front-mig"
  region = var.region
  instance_template = "${module.vm_instance_template-01.self_link}"
  
}


module "vm_mig-backend" {
  source  = "terraform-google-modules/vm/google//modules/mig"
  version = "8.0.0"
  # insert the 2 required variables here
  mig_name = "backend-mig"
  region = var.region
  instance_template = "${module.vm_instance_template-02.self_link}"
  
}