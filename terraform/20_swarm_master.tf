#
# MASTER
#
########################################################################################################################
resource "aws_instance" "swarm-master" {
  count         = "${var.swarm-master_count}"
  ami           = "${data.aws_ami.ubuntu.id}"
  key_name      = "${aws_key_pair.access.key_name}"
  instance_type = "t2.medium"
  user_data     = "${file("cloudinit.sh")}"

  associate_public_ip_address = true
  subnet_id                   = "${aws_subnet.swarm-master.id}"

  vpc_security_group_ids = [
    "${aws_security_group.allow_ssh.id}",
    "${aws_security_group.allow_prometheus.id}",
    "${aws_security_group.allow_vpc.id}",
    "${aws_security_group.allow_all.id}",
  ]

  tags {
    Name  = "${var.project_name} - swarm master ${count.index + 1}"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_route53_record" "swarm-master" {
  count   = "${var.swarm-master_count}"
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "swarm-master${count.index + 1}.private"
  type    = "A"
  ttl     = "300"

  records = [
    "${element(aws_instance.swarm-master.*.private_ip, count.index)}",
  ]
}

resource "aws_route53_record" "swarm-master-public" {
  count   = "${var.kubernetes-worker_count}"
  zone_id = "${data.aws_route53_zone.xebia_public_dns.id}"
  name    = "swarm-master${count.index + 1}.${var.public_subdomain}"
  type    = "A"
  ttl     = "300"

  records = [
    "${element(aws_instance.swarm-master.*.public_ip, count.index)}",
  ]
}

resource "aws_route_table_association" "swarm-master" {
  subnet_id      = "${aws_subnet.swarm-master.id}"
  route_table_id = "${aws_route_table.public.id}"
}

/* master subnet */
resource "aws_subnet" "swarm-master" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(aws_vpc.main.cidr_block, 8, 4)}"

  tags {
    Name  = "${var.project_name} - swarm master"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}
