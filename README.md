Steps to execute the files and some prerequisite. 

1)	Create a public key and private key – ssh is enabled to login to ec2 instance for maintenance
ssh-keygen -f mykey (Please use mykey as the name of the key)
2)	Terraform code is not tightly coupled with a specific AWS account, use below commands to deploy 
terraform init # Initializes terraform  
terraform plan # This will ask for AWS_ACCESS_KEY and AWS_SECRET_KEY (Both keys can be generated while giving programmatic access to a user) Please enter both keys
terraform apply # This will ask for AWS_ACCESS_KEY and AWS_SECRET_KEY, Please enter both keys

Once Terraform apply is completed, below are the resources which will be created in your AWS account. 

1)	Load balance with name classic-elb configured to perform health checks on ec2 instances for port 80 with threshold of 2 (if more than 2 times port 80 is not reachable, route traffic to other instance and mark current as unhealthy)
2)	VPC with two subnets which are in two different availability zones  (eu-west-1a, eu-west-1b) – High Availability 
3)	Two security groups 
		
		a)Name – myinstance with below rules 
				Inbound: 
					port 80 allowed only from elb (Tightly coupled)
	          			Port 22 allowed from everywhere (As we may need to login to instance for maintenance)
				Outbound: 
					All traffic allowed
		
		b)Name – elb with below rules
				Inbound: 
					port 80 allowed from everywhere (0.0.0.0/0)
				Outbound: 
					All traffic allowed
4)	Launch Configuration – Name – launchconfig which will create an ec2 instance as below

		a)Instance type = t2 micro 
		b)Image – latest AMI Linux image available
		c)Importing key created in perquisite
		d)Extra elb block device apart from root of 10Gb memory which Is encrypted. 
		e)User data for installing nginx and mounting extra volumes
		
5)	Autoscaling Group – Name - autoscaling – which will be created as below

		a)Allow to deploy ec2 instances in two different availability zones
		b)Minimum ec2 instance = 2
		c)Configured health check
		
6)	Mounted extra volume under /var/log with lvm – this enables us to increase the volume as per requirements. 
7)	Autoscaling Policy is configured to autoscale the instance with +1  if average CPU utilization is more than 40 for two consecutive periods and scale down to -1 if CPU utilization is less than 20 for two consecutive periods, Cloud watch alarm is created for both triggers, we can get email updates by creating a SNS topic and subscribing to the topic. 
8)	We can test High Availability and load balance by refreshing the URL of load balancer, it shows private IP of instance running on the availability zone in bottom of the html page – configured user data to extract private IP and redirect it to default home page of nginx.   

Below are the snapshots of Console 

![image](https://user-images.githubusercontent.com/27212853/116781919-b5b71d80-aaa3-11eb-8b6a-bb3f9269d3fa.png)

![image](https://user-images.githubusercontent.com/27212853/116781940-e26b3500-aaa3-11eb-8722-512a55392967.png)

![image](https://user-images.githubusercontent.com/27212853/116781945-e8611600-aaa3-11eb-8c6a-33285ccf260b.png)

![image](https://user-images.githubusercontent.com/27212853/116781950-edbe6080-aaa3-11eb-970b-32de1b7c3017.png)

![image](https://user-images.githubusercontent.com/27212853/116781958-f3b44180-aaa3-11eb-81f3-fbb9a468d1a7.png)

![image](https://user-images.githubusercontent.com/27212853/116781966-f9aa2280-aaa3-11eb-98c4-f5fe4a8bae05.png)

![image](https://user-images.githubusercontent.com/27212853/116783087-6d4f2e00-aaaa-11eb-9ee3-e309297e1b52.png)



