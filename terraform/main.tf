provider "google" {
  project = "<your-gcp-project>"
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_compute_instance" "jenkins_vm" {
  name         = "jenkins-server"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt update
    apt install -y openjdk-11-jre git docker.io ansible
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    apt update
    apt install -y jenkins
    systemctl enable jenkins
    systemctl start jenkins
    usermod -aG docker jenkins
  EOT

  tags = ["jenkins"]

  service_account {
    email  = "<your-service-account-email>"
    scopes = ["cloud-platform"]
  }
}
