
# Grants permissions to the application in ec2 to access AWS services like SSM Parameter Store.

resource "aws_iam_role" "ec2_instance_role" {
  name = "EC2InstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}




# Policy to be attached to the role above.

resource "aws_iam_policy" "ssm_read_access" {
  name        = "ssmReadAccess"
  description = "Allows EC2 instance to read SSM parameters"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParameterHistory"],
      Resource = "*"
    },


    # This is the reason for this policy: we stored client secret in the parameter store as a "secured string", for the app to effectively use that string, it should be able to decrypt the string. 
    # This policy will aloow it do just that.
    {
        Effect   = "Allow",
        Action   = "kms:Decrypt",     # This allows the IAM role to decrypt values encrypted using a KMS key. It is required when retrieving SecureString values from SSM Parameter Store.
        Resource = "*"  # This means this role can decrypt any KMS key in the account (not recommended for security reasons). Replace this with your KMS key ARN if possible
      }
    ]
  })
}




# attching ssm_read_access policy to the ec2 instance role

resource "aws_iam_role_policy_attachment" "ec2_instance_policy_attachment" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.ssm_read_access.arn
}



# Creating an iam instance profile for the ec2 instance role. This will be attched in instance profile section of the launch template.

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.ec2_instance_role.name
}



output "iam_instance_profile_name" {
    value = aws_iam_instance_profile.ec2_instance_profile.name
}