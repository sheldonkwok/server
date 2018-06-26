provider "aws" {
  region  = "us-west-2" # or us-east-2
  profile = "personal"
}

# Default network configuration
data "aws_vpc" "default" {
  default = true
}

# Default security access
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = "${data.aws_vpc.default.id}"
}

# Represents which datacenter in us-west-2 to pick
data "aws_subnet" "default_a" {
  availability_zone = "us-west-2a"
  default_for_az    = true
  vpc_id            = "${data.aws_vpc.default.id}"
}

# SSH access to instance
resource "aws_security_group_rule" "default_ingress" {
  type              = "ingress"
  description       = "Allow all incoming traffic"
  security_group_id = "${data.aws_security_group.default.id}"

  protocol = "all"

  # All ports
  from_port = 0
  to_port   = 65535

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_key_pair" "laptop" {
  key_name   = "laptop"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCjtsDiw9g5Q0LYNGo9O6Edx9HNJUpLIp7np1qogMCjTHf7m/+KAIuHs5KiODypTrYl+FxLiPVEGogKQmK6ASRSUZS8DERWx96wX61LW1+//5FvT0w0j787zzYVp+GE+7NZilEwUy5UsNKSMRPrEyLOolbvxTNUjm2u8WnIgiWYDp3gGVh/kiyjeWWl+F8cHYeJxOhZ/BdBPcpQLUB4m35OqVrf5CxR4gzaX0jqoWCTcQrdGqVuvl7L5RWaIBD/tsh00NM1VZyJcTjvTTM0vTAP7HKGZFTCaKoUsn0uRz2EENF+BFfVV8zZQf6tV+m/hBRfNjH0Ujilcbrryef8X7cMQto4x2x/O68aOoV33APBDvChgebqPti02ww78Jt/XNELqXk9ED9o4hDRi1z/vRNKmAzDdbttbff2eol39UtLMWcu1ZddE2wR9qexzG5kl1NXxa6rYJuRJuw03+T3wQ7O39SE3susPOCdt3UzXrBWBTe+sbNxLhaWs4yO4DYvXs5mIsc6Tbz1A7555otrK9LR2zlz/ZzeEctW8kAlwp9gjrqfovTuEPJuBMqkk4AVTsiPDdGUtPtCiPMvaHAAlsD4isMpqwcduYSbiT2S4uaQB1kDTdZE5noju3QDxVxCkGS7IOLBNt/gNMKWV5xgYwIdCbyL4L+JaLpCo/9+Pfcmmw=="
}

resource "aws_instance" "server" {
  ami           = "ami-db710fa3" # Base ubuntu image; us-east-2 ami: ami-6a003c0f
  instance_type = "t2.micro"     # Free tier instance size

  subnet_id = "${data.aws_subnet.default_a.id}"
  key_name  = "${aws_key_pair.laptop.key_name}"

  # Provision disk for instance
  root_block_device {
    volume_type = "gp2" # SSD
    volume_size = 30
  }

  tags {
    Name = "personal-server"
  }

  # Install python on our remote machine
  provisioner "remote-exec" {
    connection {
      user = "ubuntu"
    }

    inline = [
      "sleep 10",                   # Give machine a little longer to init
      "sudo apt update",            # Update list of packages on machine
      "sudo apt install -y python", # Install python
    ]
  }

  # Create inventory
  provisioner "local-exec" {
    command = "echo '[personal-server]\n${aws_instance.server.public_ip} ansible_ssh_user=ubuntu' > ../ansible/inventory"
  }
}
