resource "aws_launch_configuration" "launchconfig" {
  name_prefix     = "launchconfig"
  image_id        = var.AMIS[var.AWS_REGION]
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.mykeypair.key_name
  security_groups = [aws_security_group.myinstance.id]
  
  user_data       = "#!/bin/bash\nsudo -s\nsudo amazon-linux-extras install nginx1\nsudo mkdir -p /var/www/html\nsudo touch /var/www/html/index.html\nMYIP=`ifconfig | grep -E '(inet 10)|(addr:10)' | awk '{ print $2 }' | cut -d ':' -f2`\necho 'this is: '$MYIP >> /usr/share/nginx/html/index.html\nsudo systemctl start nginx\nsudo pvcreate /dev/xvdb\nsudo vgcreate vol1 /dev/xvdb\nsudo lvcreate -n lv1 -l 100%FREE vol1\nsudo mkfs.ext4 /dev/vol1/lv1\nsudo mount /dev/vol1/lv1 /var/log"
  lifecycle {
    create_before_destroy = true

  }
  ebs_block_device { 
    device_name                 = "/dev/sdb"
    volume_type                 = "gp2"
    volume_size                 = 10
    iops                        = 200
    encrypted                   = "true"
  }
}



resource "aws_autoscaling_group" "autoscaling" {
  name                      = "autoscaling"
  vpc_zone_identifier       = [aws_subnet.main-subnet-1.id, aws_subnet.main-subnet-2.id]
  launch_configuration      = aws_launch_configuration.launchconfig.name
  min_size                  = 2
  max_size                  = 4
  health_check_grace_period = 300
  health_check_type         = "ELB"
  load_balancers            = [aws_elb.classic-elb.name]
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "ec2 instance"
    propagate_at_launch = true
  }
}

