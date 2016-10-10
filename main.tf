# Configure the Docker provider
provider "docker" {
	host = "unix:///var/run/docker.sock"
}

resource "docker_image" "mysql" {
    name = "mysql:5.6"
}

resource "docker_image" "pdns" {
    name = "pdns4:latest"
}

resource "docker_container" "database" {
    image = "${docker_image.mysql.latest}"
    name = "powerdns-database"

    count = 1

    log_driver = "json-file"
    log_opts = {
        max-size = "1m"
        max-file = 2
    }

    env = ["MYSQL_ROOT_PASSWORD=secretrootpassword", "MYSQL_DATABASE=powerdns", "MYSQL_USER=powerdns", "MYSQL_PASSWORD=powerdns"]
}

resource "docker_container" "powerdns" {

    depends_on = ["docker_container.database"]

    image = "${docker_image.pdns.latest}"
    name = "powerdns"

    count = 1

    log_driver = "json-file"
    log_opts = {
        max-size = "1m"
        max-file = 2
    }

    links = ["powerdns-database:database"]

    env = ["MYSQL_ROOT_PASSWORD=secretrootpassword", "MYSQL_DATABASE=powerdns", "MYSQL_USER=powerdns", "MYSQL_PASSWORD=powerdns"]

    ports {
        internal = 80
        external = 8080
    }

    ports {
        internal = 53
        external = 53
        ip = "172.17.0.1"
    }

    ports {
        internal = 53
        external = 53
        protocol = "udp"
        ip = "172.17.0.1"
    }
}

/*
# Configure the PowerDNS provider
provider "powerdns" {
    api_key = "changeme"
    server_url = "http://${docker_container.powerdns.ip_address}"
}

# Add a record to the zone
resource "powerdns_record" "foobar" {

    depends_on = ["docker_container.powerdns"]

    zone = "crunchyapple.org"
    name = "api.crunchyapple.org."
    type = "A"
    ttl = 300
    records = ["8.8.8.8"]
}*/