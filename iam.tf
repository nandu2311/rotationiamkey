## IAM Role and Policy ###
## Allows Lambda Function to Describe, stop and start EC2 Instances

resource "aws_iam_role" "lambda_execution_role" {
  name = "rotate-access-keys-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_execution_policy" {
  name        = "rotate-access-keys-lambda-policy"
  description = "Policy for Lambda function to rotate access keys"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "iam:ListUsers",
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action   = "iam:ListAccessKeys",
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action   = "iam:CreateAccessKey",
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action   = "iam:UpdateAccessKey",
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action   = "iam:DeleteAccessKey",
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action  = "sns:*"
        Effect  = "Allow"
        Resource = "arn:aws:sns:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
  role       = aws_iam_role.lambda_execution_role.name
}

