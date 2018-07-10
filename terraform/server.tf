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

# git ignored to make cloning/forking easier
data "local_file" "public_key" {
  filename = "id_rsa.pub"
}

# SSH access to instance
resource "aws_key_pair" "worklaptop" {
  key_name   = "worklaptop"
  public_key = "${data.local_file.public_key.content}"
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
