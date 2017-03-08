resource "aws_instance" "prometheus" {
  count = "${var.monitoring_count}"
  ami = "${data.aws_ami.ubuntu.id}"
  key_name = "${aws_key_pair.access.key_name}"
  instance_type = "t2.medium"

  user_data = "${file("cloudinit.sh")}"

  associate_public_ip_address = true
  subnet_id = "${aws_subnet.monitoring.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]

  tags {
    Name = "${var.project_name} - prometheus ${count.index + 1}"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_route53_record" "prometheus" {
  count = "${var.monitoring_count}"
  zone_id = "${aws_route53_zone.private.zone_id}"
  name = "prometheus${count.index + 1}.private"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.prometheus.*.private_ip, count.index)}"]
}

resource "aws_subnet" "monitoring" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(aws_vpc.main.cidr_block, 8, 8)}"
  tags {
    Name = "${var.project_name} - monitoring"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_route_table_association" "monitoring" {
  subnet_id = "${aws_subnet.monitoring.id}"
  route_table_id = "${aws_route_table.public.id}"
}
