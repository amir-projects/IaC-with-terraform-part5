# resource "null_resource" "provision_ec2" {
#   depends_on = [module.ec2-instance, module.rds]

#   provisioner "remote-exec" {
#     inline = [
#       "set -e",
#       "sudo apt update && sudo apt upgrade -y",
#       "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -",
#       "sudo apt install -y nodejs git",
#       "sudo npm install pm2@latest -g",

#       "git clone https://github.com/amir-projects/full-stack-crud-project-with-react-node-mysql",
#       "cd full-stack-crud-project-with-react-node-mysql/server",
#       "npm install",
#       "cp .env.example .env",
#       "sed -i 's/^DB_HOST=.*/DB_HOST=${module.rds.db_instance_address}/' .env",
#       "sed -i 's/^DB_USER=.*/DB_USER=admin/' .env",
#       "sed -i 's/^DB_PASSWORD=.*/DB_PASSWORD=${local.db_credentials.password}/' .env",
#       "sed -i 's/^DB_DATABASE=.*/DB_DATABASE=crud_operations/' .env",
#       "PORT=3000 pm2 start index.js --name api-server --watch",

#       "cd ../frontend",
#       "npm install",
#       "cp .env.example .env",
#       "if grep -q '^VITE_API_URL=' .env; then sed -i 's|^VITE_API_URL=.*|VITE_API_URL=http://${module.ec2-instance.public_ip}:3000|' .env; else echo 'VITE_API_URL=http://${module.ec2-instance.public_ip}:3000' >> .env; fi",
#       "pm2 start \"npm run dev -- --host 0.0.0.0\" --name react-app"
#     ]

#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = file("${path.module}/ssh-keys/id_ed25519")
#       host        = module.ec2-instance.public_ip
#     }
#   }
# }




module "vpc" {
  source = "./modules/vpc"
}

module "ec2" {
  source         = "./modules/ec2"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
}

module "rds" {
  source                = "./modules/rds"
  vpc_id                = module.vpc.vpc_id
  private_subnets       = module.vpc.private_subnets
  vpc_cidr_block        = module.vpc.vpc_cidr_block
  ec2_security_group_id = module.ec2.security_group_id
}

