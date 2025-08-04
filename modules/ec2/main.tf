data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (official Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name        = "ec2-sg"
  vpc_id      = var.vpc_id
  description = "Security group for application vm"
  ingress_with_cidr_blocks = [
    {
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow access to frontend app"
    },
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow access to backend app"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow SSH"
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

# Generate SSH Keypairs
resource "aws_key_pair" "local_key" {
  key_name   = "three-tier-platform-vm-access-key"
  public_key = file("${path.root}/ssh-keys/id_ed25519.pub")
}


# Create ec2 instance
module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.0.2"

  ami                         = data.aws_ami.ubuntu_latest.id
  name                        = "three-tier-app-vm-terraform"
  instance_type               = "t3.small"
  monitoring                  = false
  key_name                    = aws_key_pair.local_key.key_name
  vpc_security_group_ids      = [module.security-group.security_group_id]
  subnet_id                   = element(var.public_subnets, 0)
  associate_public_ip_address = true
  create_security_group       = false

  root_block_device = {
    type      = "gp3"
    size      = 50
    encrypted = true
  }
}

resource "null_resource" "provision_ec2" {
  provisioner "local-exec" {
    command = "echo Hello, World!"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}