resource "aws_key_pair" "my-key" {
  key_name   = "devops21-tf-key"
  public_key = file("${path.module}/my_public_key.txt")

 

}
variable "region" {
    default = "us-east-1"
}

 

 resource "aws_instance" "function-ec2" {
  ami           = lookup(var.ami, var.region)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my-key.key_name
  tags = {
    "Name" = element(var.tags, 0)
  }
}

 

 variable "ingress_ports" {
  type    = list(any)
  default = [22, 80]
}

 

 variable "egress_ports" {
  type    = list(any)
  default = [0]
}

 

 resource "aws_security_group" "dynamic-sg" {
  name = "devops21-dynamic-sg"
  dynamic "ingress" {
    for_each = var.ingress_ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  dynamic "egress" {
    for_each = var.egress_ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.dynamic-sg.id
  network_interface_id = aws_instance.function-ec2.primary_network_interface_id
 }
 

locals {
  time = formatdate("DD MM YYYY hh:mm ZZZ", timestamp())
}
output "timestamp" {
  value = local.time
}


variable "ami" {
  type = map(any)
  default = {
    us-east-1 = "ami-087c17d1fe0178315"
    us-east-2 = "ami-00dfe2c7ce89a450b"
    us-west-1 = "ami-011996ff98de391d1"
    us-west-2 = "ami-0c2d06d50ce30b442"
  }
}

variable "tags" {
  type    = list(any)
  default = ["my-first-ec2", "my-second-ec2", "my-third-ec2"]
}