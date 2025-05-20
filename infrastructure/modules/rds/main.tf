resource "aws_db_subnet_group" "postgres" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.db_identifier}-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier              = var.db_identifier
  engine                  = "postgres"
  engine_version          = "15.7"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_encrypted       = true
  username                = var.db_username
  password                = var.db_password
  db_name                 = var.db_name
  vpc_security_group_ids  = [var.db_sg_id]
  db_subnet_group_name    = aws_db_subnet_group.postgres.name
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  backup_retention_period = 1
  deletion_protection     = false
  apply_immediately       = true
  auto_minor_version_upgrade = true

  tags = {
    Environment = "production"
    Terraform   = "true"
  }
}