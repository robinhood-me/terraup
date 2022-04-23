//uppercase Name will name the EC2 instance
//lowercase name will just tag the instance

// ubuntu 18
// ami-074251216af698218

//rhel/aws linux
// ami-02b92c281a4d3dc79

provider "aws" {
region = "us-west-2"
}

resource "aws_instance" "example" {
ami = "ami-074251216af698218"
instance_type = "t2.micro"
key_name= "terr_id_rsa"

user_data = <<-EOF
            #!/bin/bash
            echo "*** Installing apache2"
            sudo apt update -y
            sudo apt install apache2 -y
            echo "*** Completed Installing apache2"
            EOF

provisioner "remote-exec" {
    inline = [
      "touch hello.txt",
      "echo helloworld remote provisioner >> hello.txt",
    ]
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("/Users/robinhood/.ssh/terr_id_rsa")
      timeout     = "4m"
    }
}

vpc_security_group_ids = ["${aws_security_group.instance.id}"]

tags = {
    Name = "terraform-example-robin"
  }
}

variable "server_http_port" {
    description = "The port the server will use for HTTP requests"
    default = 80
}

variable "server_https_port" {
    description = "The port the server will use for HTTPS requests"
    default = 443
}

variable "server_ssh_port" {
    description = "The port the server will use for SSH access"
    default = 22
}

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"
    ingress {
        description = "HTTP traffic"
        from_port = "${var.server_http_port}"
        to_port = "${var.server_http_port}"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "HTTPS traffic"
        from_port = "${var.server_https_port}"
        to_port = "${var.server_https_port}"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "SSH access"
        from_port = "${var.server_ssh_port}"
        to_port = "${var.server_ssh_port}"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        description = "any egress"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "public_ip" {
value = "${aws_instance.example.public_ip}"
}

resource "aws_key_pair" "deployer" {
  key_name   = "terr_id_rsa"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRp0sGG8PWRCGLig+GYOUFoGVRkYQyyKCa+jz7cEBWcK53uQBZ5iftdrxdhouQGRF31LCsHkfxMFMY0xqJ+Q3Pwu1pbwiHI3uukOA7HN3f2VejJ30HkOgbTKr38XmZtW/Dalq/zBn2HAWJzytcIIi9hX9zxMNlyZWCTJtkJrXSq/eNbF6CE/LjS0i10tneMcDKherz6ojOJqfcDthcAR++fon3TZqH0fumDXVNVz8HU9X2VXs1p8bUJG7kARPVjqPsDDVtV0nq1ibkdUJS8LiY0mVnqkdrvJhTVk6Wy39kl4aP6j0bppnIZFe5cFoXTAlu0fGJFneZ7atbSCdCKNdP"
}
