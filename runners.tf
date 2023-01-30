resource "aws_instance" "gitlab_runner"{
    instance_type = "t2.medium"
    ami = "ami-0f7559f51d3a22167"
    key_name = "key"
    iam_instance_profile = "EC2Admin"

    tags = {
        Name = "gitlab-runner"
    }

    provisioner "file" {
      source = "scripts/setup_runners.sh"
      destination = "/tmp/setup_runners.sh"

      connection {
        type     = "ssh"
        user     = "ubuntu"
        private_key = file("~/Downloads/key.pem")
        host = self.public_ip
      }
    }
    provisioner "remote-exec" {
      connection {
        type     = "ssh"
        user     = "ubuntu"
        private_key = file("~/Downloads/key.pem")
        host = self.public_ip
      }

      inline = [
        "chmod +x /tmp/setup_runners.sh",
        "/tmp/setup_runners.sh"
      ]
    }
}