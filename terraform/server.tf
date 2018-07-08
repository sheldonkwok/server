provider "aws" {
  region  = "us-east-2"
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
  availability_zone = "us-east-2a"
  default_for_az    = true
  vpc_id            = "${data.aws_vpc.default.id}"
}

# SSH access to instance
resource "aws_key_pair" "worklaptop" {
  key_name   = "worklaptop"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7Q8SBz2iMh5RBNlZ9uc+5WhxPdslTBlefqZzeZEGJok0LA7kAIVfjtIKG2Go2Zp1pmZNhwa21Ad9tHs/YUY2pxZYUI/29qHGZSnvsg6yWI/3hQ3gQc4frCDCTo3Kf87xZmuIdvhxnmZ9VQBvh9Pzrye73FciU2r6NF2qoX9vX9ZSqjvlgk7YMDly/83gki7fdV5W4aIUQxiguHAlR0cHjwnh9ppSq9ch4uhl8RG11dm2fEx0iZDrD7glMGSexDp18u3d88ZbFjNc+vO6V7Xisl3OEZAVv1j2pdeIpLCdFE1toL0GKNIDQYnomRyLTiRVt6qNaY11fyHlrY842VFGB24kH/2AKzSyJfILSYmAmF5d545QhSapVj6e8f2AUv4NyVthRI+WR3D/g0S0YjL/ehK5E0w4FlROKc/xaVJ0C8A4vWIpZU6Kh795xxt70F2XQsfATDDAqkOJFjVRhaq/e2dNfu5R3G4stqVyen0yE/O1LdT64pISqiAcrXxRufvKtNT7CqkvxIo0nEZl1ZWcriAWj2d6uXGDTKWQ3AREXgG0W7pTjPHeUO2aXqrl+uiHIW291Rpn1u5jnUCGjf40za4hFV1qGFUSqjVYc1+yJCZ40FEt/mQqLV5ciyV+MLdSgT8sjuuVzm7F1u/ZJgU1ZXyDrPktUaHzL3OrtwILVtQ== jonathanli@jonathan-macbookpro15.local"
}

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

resource "aws_instance" "server" {
  ami           = "ami-6a003c0f" # Base ubuntu image
  instance_type = "t2.micro"     # Free tier instance size

  subnet_id = "${data.aws_subnet.default_a.id}"
  key_name  = "${aws_key_pair.worklaptop.key_name}"

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
