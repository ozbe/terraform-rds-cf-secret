# RDS Secret

Rotate db instance password with Terraform and CloudFormation.

## Status

Was trying the `MySecretRotationSchedule` to rotate the password at creation, but it didn't take. 
This likely comes from a misunderstanding of mine of how the `SecretRDSInstanceAttachment` works.

My current thinking is you can't update the existing rds instance username and password w/o importing 
the RDS instance resource into stack. You could make the cluster outside stack and manage the instance 
and secret in CloudFormation, but, :shrug:, that wasn't the goal of getting the db instance managed by Terraform.

Even with the attachment working, I wouldn't be surprised if the password would be a problem on subsequent Terraform deploys. Possibly the key could be rotated to mitigate this reapplication, but rotating on deploy because of a technical limitation and not a choice seems like a smell.

## Setup
```
$ terraform init
```

Make `test.tfvars` the following variables and the default values for your account
```
security_groups = "sg-2449c669"
subnet_ids      = "subnet-3e69a358,subnet-0b216553,subnet-bee92ef6"
```

## Plan
```
$ terraform plan --var-file test.tfvars --out test_plan 
```

## Apply
```
$ terraform apply "test_plan"
```
