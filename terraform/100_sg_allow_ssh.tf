resource "aws_security_group" "allow_ssh" {
  vpc_id      = "${aws_vpc.main.id}"
  name_prefix = "mesos-starter-sg"
  description = "Allow ssh inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.project_name} - public sg"
  }
}
