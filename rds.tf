# doesn't matter much as it will be rotated
resource "random_password" "password" {
  length           = 16
  override_special = "!#$%&*()-_=+[]{}<>:?"
  special          = true
}

# TODO - use var.security _groups
resource "aws_db_instance" "my-db-instance" {
  identifier        = "my-db-instance"
  allocated_storage = 10
  engine            = "postgres"
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html#Concepts.DBInstanceClass.Support
  instance_class = "db.t3.micro"
  username       = "postgres"
  # ... will this work on subsequent deploys? probably not
  password            = random_password.password.result
  skip_final_snapshot = true
  publicly_accessible = true
}
