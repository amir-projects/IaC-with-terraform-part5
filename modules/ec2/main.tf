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

locals {
  db_host_cleaned = replace(var.rds_instance_endpoint, ":3306", "")
}

resource "null_resource" "provision_ec2" {
  depends_on = [module.ec2-instance]
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -",
      "sudo apt install -y nodejs git",
      "sudo npm install pm2@latest -g",
      "git clone https://github.com/amir-projects/full-stack-crud-project-with-react-node-mysql",
      "cd full-stack-crud-project-with-react-node-mysql/server",
      "npm install --quiet",
      "cp .env.example .env",
      "sed -i \"s|^DB_HOST=.*|DB_HOST=\\\"${local.db_host_cleaned}\\\"|\" .env",
      "sed -i \"s|^DB_USER=.*|DB_USER=\\\"admin\\\"|\" .env",
      "sed -i \"s|^DB_PASSWORD=.*|DB_PASSWORD=\\\"User12345random25!\\\"|\" .env",
      "if ! pm2 list | grep -q '^api-server'; then PORT=3000 pm2 start index.js --name api-server --watch; else echo 'pm2 api-server already running, skipping start'; fi",
      "cd ../frontend",
      "npm install --quiet",
      "cp .env.example .env",
      "if grep -q '^VITE_API_URL=' .env; then sed -i 's|^VITE_API_URL=.*|VITE_API_URL=http://${module.ec2-instance.public_ip}:3000|' .env; else echo 'VITE_API_URL=http://${module.ec2-instance.public_ip}:3000' >> .env; fi",
      "if ! pm2 list | grep -q '^react-app'; then pm2 start \"npm run dev -- --host 0.0.0.0\" --name react-app; else echo 'pm2 react-app already running, skipping start'; fi"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.root}/ssh-keys/id_ed25519")
      host        = module.ec2-instance.public_ip
    }
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}