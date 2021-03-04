variable "security_groups" {
  type        = string
  description = "Comma delimited Security Group Ids for HostedRotationLambda"
}

variable "subnet_ids" {
  type        = string
  description = "Comma delimited Subnet Ids for HostedRotationLambda"
}