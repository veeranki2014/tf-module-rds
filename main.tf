resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = var.subnet_ids

  tags              = merge ({ Name = "${var.component}-${var.env}" }, var.tags )
}


resource "aws_rds_cluster" "main" {
  cluster_identifier      = "${var.component}-${var.env}"
  engine                  = var.engine
  engine_version          = var.engine_version
  database_name           = var.db_name
  #db_name                 = var.db_name
  master_username         = data.aws_ssm_parameter.username.value
  master_password         = data.aws_ssm_parameter.password.value
  db_subnet_group_name    = aws_db_subnet_group.main.name
  kms_key_id              = var.kms_key_arn
  storage_encrypted       = true
  skip_final_snapshot     = true
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = var.instance_count
  identifier         = "aurora-cluster-demo-${count.index}"
  cluster_identifier = "${aws_rds_cluster.main.id}"
  instance_class     = var.instance_class
  engine                  = var.engine
  engine_version          = var.engine_version
}

