# Description
This repository contains files needed to deploy a containerized blog app on AWS with fully integrated CI/CD and IaC

## Medium Publication


## Project Structure

- **app.py**: Contains the core Flask application logic (routes for login, signup, and dashboard). Manages the login process with AWS Cognito and renders the homepage for authenticated users.
  
- **templates/**: Contains HTML files rendered by Flask for the frontend.
  - **signup.html**: Handles user registration.
  - **login.html**: Handles user login.
  - **home.html**: Displays the blog content for authenticated users.
    
- **requirements.txt**: Specifies Python dependencies like Flask, boto3 (for AWS services), and any other libraries the app needs.
  
- **utils.py**: Includes helper functions like `authenticate_user()` and `register_user()` that interact with AWS Cognito for user authentication and sign-up.
  
- **config.py**: A configuration file that interacts with the AWS SSM Parameter store to fetch Cognito secrets, store environment variables and settings for the Flask application.
  
- **Dockerfile**: Contains instructions for building the Docker image (e.g., install dependencies, copy app code, run the app).
  
- **run.sh**: A shell script used to set environment variables (e.g., FLASK_APP, FLASK_ENV) and run the Flask application within the Docker container.
  
- **Jenkinsfile**: Defines the CI/CD pipeline, which automates pulling app files, building, testing, and deploying the app from GitHub, DockerHub to AWS using Jenkins and Terraform files.
  

## Terraform Setup

**terraform/**: Contains Terraform configuration files to provision AWS infrastructure.

Carefully plan how to declare and provision AWS resources. Basically, which resource should be provisioned first and which should come later. For this project, I followed this order:

1. **Main**: Create a `main.tf` file to store your providers and also select the VPC and subnets you will be using for this project.

2. **Cognito**: Cognito will be used for security and user authentication.
   
   - [AWS Terraform Cognito Configuration guide](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool)

3. **SSM Parameter Store**: We will store Cognito information and secrets in AWS SSM Parameter Store. This will be used by the app to authenticate users.
   
   - [AWS Terraform SSM Parameter Store Configuration guide](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter)

4. **Security Group**: Create security groups for application load balancer and EC2 instances. The EC2 security group should only accept traffic from the application load balancer.
   
   - [AWS Terraform Security Group Configuration guide](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)

5. **Application Load Balancer**: Create an application load balancer that will distribute traffic between all EC2 instances in the auto-scaling group.
    
   - [AWS Terraform Application Load Balancer Configuration guide](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb)
   - [AWS Terraform Target Group Configuration guide](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group)
     
   - We will create the target group of the application load balancer. Note that while creating the target group, we will not select any instance because that will be taken care of by the auto-scaling group.

6. **Auto Scaling Group & Launch Template**: Create an auto-scaling group that will scale the number of EC2 instances based on the policy used and change EC2 instance purchasing options. For this project, we will use step scaling policy to gradually add or remove instances from our auto-scaling group depending on the CPU utilization rate.
     - If CPU < 5%: 1 spot Instance
     - If CPU > 5%: Increase to maximum of 4 instances with a 50:50 split between Spot and On-Demand Instances.
    
   - [AWS Terraform Auto Scaling Group Configuration guide](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group)
   - [AWS Terraform EC2 Launch Template Configuration guide](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template)
     
   - We will create the EC2 launch template and attach a user data file. This file will contain all instructions that will run only at the launch of new instances.

7. **Cloud Watch Alarm**: Create CloudWatch alarms to trigger when CPU utilization levels are high. This will notify the auto-scaling group to switch or change purchasing options from spot instances (which incredibly reduces cost) to a mix of spot and on-demand instances for performance stability. The goal is cost optimization while ensuring high performance and availability.
   
   - [AWS Terraform Cloud Watch Alarm Configuration guide](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm)

9. **IAM Roles and Policies**: We need to create roles and attach policies to these roles.
   - Roles give permission/authority to AWS resources to carry out actions on our behalf.

   - Policies define what types of actions can be performed and on which AWS resource.

   - **EC2 Instance Role (ec2_instance_role)**: This role will be used inside the EC2 to grant the news blog application access to SSM parameter store

     - **SSM Access Policy (ssm_read_access)**: This policy will be attached to the ec2_instance_role. The blog application will be able to read parameters from the SSM Parameter Store.

   - Finally, generate an IAM instance profile for this role. This will be attached to the EC2 in the launch template.

   - [AWS Terraform IAM role policy Configuration guide](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)

## Dependencies

- Flask
- boto3
- Other dependencies specified in `requirements.txt`


## Architecture Diagram
![image](https://github.com/user-attachments/assets/de6f72f3-3493-45bd-aa73-cc5e0dcdb5ab)

## Contact

For any inquiries, please contact [eedunoh@gmail.com].
