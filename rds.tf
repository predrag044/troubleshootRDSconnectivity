resource "aws_db_subnet_group" "db_subnet_group1" {
        name = "db_subnet_group1"
        subnet_ids = "${aws_subnet.public-subnet.*.id}"
}

resource "aws_db_instance" "db" {
	allocated_storage = 20
	engine = "postgres"
	engine_version = "10.6"
	instance_class = "db.t2.small"
	name = "mydb"
	apply_immediately = "true"
	backup_retention_period = 7
	backup_window = "01:00-05:00"
	db_subnet_group_name = "${aws_db_subnet_group.db_subnet_group1.name}"
	multi_az = "false"
	storage_type = "gp2"
	username = "aurora"
	password = "Aurora123!#"
	identifier = "database"
	skip_final_snapshot = "true"
	vpc_security_group_ids = ["${aws_security_group.db_sg.id}"]
	
	tags = {
		Name = "${var.IC_NAME}_db"
	}
}

output "RDS_HOSTNAME" {
	value = "${aws_db_instance.db.address}"
}







