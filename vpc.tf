variable "availability_zones" {
	description = "AZs in this region to use"
	default = ["us-east-1a", "us-east-1b", "us-east-1c"]
	type = list(string)
}

variable "public_subnet_cidrs" {
        default = ["20.0.0.0/28", "20.0.0.16/28"]
        type = list(string)
}

resource "aws_vpc" "main" {
        cidr_block = "20.0.0.0/24"
	enable_dns_hostnames = "true"

        tags = {
                Name = "${var.IC_NAME}_vpc"
        }
}

resource "aws_subnet" "public-subnet" {
        count = "${length(var.public_subnet_cidrs)}"
        vpc_id = "${aws_vpc.main.id}"
        cidr_block = "${var.public_subnet_cidrs[count.index]}"
        availability_zone = "${var.availability_zones[count.index]}"
        map_public_ip_on_launch = "true"

	tags = {
		Name = "${var.IC_NAME}_public_subnet"
	}
}

resource "aws_subnet" "private-subnet" {
        vpc_id = "${aws_vpc.main.id}"
        cidr_block = "20.0.0.32/28"
        availability_zone = "${var.availability_zones[1]}"
        map_public_ip_on_launch = "true"

	tags = {
		Name = "${var.IC_NAME}_private_subnet"
	}
}

resource "aws_internet_gateway" "main-vpc-igw" {
	vpc_id = "${aws_vpc.main.id}"

	tags = {
		Name = "${var.IC_NAME}_igw"
	}
}

resource "aws_route_table" "main-public-rt" {
	vpc_id = "${aws_vpc.main.id}"
	
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.main-vpc-igw.id}"
	}
	
	tags = {
		Name = "${var.IC_NAME}_public_rt"
	}
}

resource "aws_route_table" "main-private-rt" {
	vpc_id = "${aws_vpc.main.id}"

	tags = {
		Name = "${var.IC_NAME}_private_rt"
	}
}

resource "aws_route_table_association" "public" {
        count = "${length(var.public_subnet_cidrs)}"
        subnet_id = "${element(aws_subnet.public-subnet.*.id, count.index)}"
        route_table_id = "${aws_route_table.main-public-rt.id}"
}

resource "aws_route_table_association" "private" {
	subnet_id = "${aws_subnet.private-subnet.id}"
	route_table_id = "${aws_route_table.main-private-rt.id}"
}

resource "aws_security_group" "sg" {
	name = "sg"
	vpc_id = "${aws_vpc.main.id}"

	ingress {
		from_port = "12000"
		to_port = "12020"
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = "${var.IC_NAME}_security_group"
	}
}

resource "aws_security_group" "db_sg" {
        name = "db_sg"
        vpc_id = "${aws_vpc.main.id}"

        ingress {
                from_port = "3306"
                to_port = "3306"
                protocol = "tcp"
                cidr_blocks = ["20.0.0.0/20"]
        }

        egress {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
}

