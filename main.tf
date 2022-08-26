/**
 * ## Usage
 *
 * Creates a KMS key used to encrypt data-at-rest stored in ECR.
 *
 * ```hcl
 * module "ecr_kms_key" {
 *   source = "dod-iac/ecr-kms-key/aws"
 *
 *   tags = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 * ```
 *
 * ## Terraform Version
 *
 * Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to main branch.
 *
 * Terraform 0.11 and 0.12 are not supported.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

// See https://docs.aws.amazon.com/AmazonECR/latest/userguide/encryption-at-rest.html
data "aws_iam_policy_document" "ecr" {
  policy_id = "key-policy-ecr"
  statement {
    sid = "Enable IAM User Permissions"
    actions = [
      "kms:*",
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        format(
          "arn:%s:iam::%s:root",
          data.aws_partition.current.partition,
          data.aws_caller_identity.current.account_id
        )
      ]
    }
    resources = ["*"]
  }
}

resource "aws_kms_key" "ecr" {
  description             = var.description
  deletion_window_in_days = var.key_deletion_window_in_days
  enable_key_rotation     = "true"
  policy                  = data.aws_iam_policy_document.ecr.json
  tags                    = var.tags
}

resource "aws_kms_alias" "ecr" {
  name          = var.name
  target_key_id = aws_kms_key.ecr.key_id
}
