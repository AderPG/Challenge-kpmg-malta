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
    name = "kpmg"
    password = "kpmg@123"
    instance = google_sql_database_instance.mysql-terraform.name
}

