
#Call VPC Module First to get the Subnet IDs
# module "bikalpa-vpc" {
#     source      = "../vpc"

#     ENVIRONMENT = var.ENVIRONMENT
#     AWS_REGION  = var.AWS_REGION
# }

#Define Subnet Group for RDS Service
resource "aws_db_subnet_group" "bikalpa-rds-subnet-group" {

    name          = "${var.ENVIRONMENT}-bikalpa-db-snet"
    description   = "Allowed subnets for DB cluster instances"
    subnet_ids    = [
      "${var.vpc_private_subnet1}",
      "${var.vpc_private_subnet2}",
    ]
    tags = {
        Name         = "${var.ENVIRONMENT}_bikalpa_db_subnet"
    }
}

#Define Security Groups for RDS Instances
resource "aws_security_group" "bikalpa-rds-sg" {

  name = "${var.ENVIRONMENT}-bikalpa-rds-sg"
  description = "Created by bikalpa"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["${var.RDS_CIDR}"]

  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
    Name = "${var.ENVIRONMENT}-bikalpa-rds-sg"
   }
}

resource "aws_db_instance" "bikalpa-rds" {
  identifier = "${var.ENVIRONMENT}-bikalpa-rds"
  allocated_storage = var.BIKALPA_RDS_ALLOCATED_STORAGE
  storage_type = "gp2"
  engine = "mysql"
  engine_version = "8.0.40"  
  instance_class = var.DB_INSTANCE_CLASS
  backup_retention_period = var.BACKUP_RETENTION_PERIOD
  publicly_accessible = var.PUBLICLY_ACCESSIBLE
  username = var.BIKALPA_RDS_USERNAME
  password = var.BIKALPA_RDS_PASSWORD
  vpc_security_group_ids = [aws_security_group.bikalpa-rds-sg.id]
  db_subnet_group_name = aws_db_subnet_group.bikalpa-rds-subnet-group.name
  multi_az = "false"
}

output "rds_prod_endpoint" {
  value = aws_db_instance.bikalpa-rds.endpoint
}