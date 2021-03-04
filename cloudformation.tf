# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack
# https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-secretsmanager-secrettargetattachment.html#aws-resource-secretsmanager-secrettargetattachment--examples--Creating_a_Secret_on_a_RDS_Database_Instance
# https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-attribute-deletionpolicy.html
resource "aws_cloudformation_stack" "rds" {
  name = "rds-stack"

  capabilities = [
    "CAPABILITY_AUTO_EXPAND",
    "CAPABILITY_IAM",
  ]

  parameters = {
    MyDBInstance       = aws_db_instance.my-db-instance.arn
    MySecurityGroupIds = var.security_groups
    MySubnetIds        = var.subnet_ids
  }

  template_body = <<STACK
{
  "Transform": "AWS::SecretsManager-2020-07-23",
  "Parameters" : {
    "MyDBInstance" : {
      "Type" : "String",
      "Description" : "Enter the ARN for the RDS instance."
    },
    "MySecurityGroupIds" : {
      "Type" : "String",
      "Description" : "Enter the Security Group Ids for HostedRotationLambda."
    },
    "MySubnetIds" : {
      "Type" : "String",
      "Description" : "Enter the Subnet Ids for HostedRotationLambda."
    }
  },
  "Resources" : {
    "MyRDSSecret": {
        "Type": "AWS::SecretsManager::Secret",
        "Properties": {
            "Description": "This is a Secrets Manager secret for an RDS DB instance",
            "GenerateSecretString": {
                "SecretStringTemplate": "{\"username\": \"postgres\"}",
                "GenerateStringKey": "password",
                "PasswordLength": 16,
                "ExcludeCharacters": "\"@/\\"
            }
        },
        "DeletionPolicy" : "Retain"
    },
    "SecretRDSInstanceAttachment": {
        "Type": "AWS::SecretsManager::SecretTargetAttachment",
        "Properties": {
            "SecretId": {
                "Ref": "MyRDSSecret"
            },
            "TargetId": {
                "Ref": "MyDBInstance"
            },
            "TargetType": "AWS::RDS::DBInstance"
        }
    },
    "MySecretRotationSchedule": {
        "Type": "AWS::SecretsManager::RotationSchedule",
        "DependsOn": "SecretRDSInstanceAttachment",
        "Properties": {
            "SecretId": {
                "Ref": "MyRDSSecret"
            },
            "HostedRotationLambda": {
              "RotationType": "PostgreSQLSingleUser",
              "RotationLambdaName": "SecretsManagerRotation",
              "VpcSecurityGroupIds": {
                "Ref": "MySecurityGroupIds" 
              },
              "VpcSubnetIds": {
                "Ref": "MySubnetIds" 
              }
            }
        }
    }
  },
  "Outputs": {
    "SecretARN": {
      "Value" : { 
        "Ref": "MyRDSSecret" 
      }
    }
  }
}
STACK
}
