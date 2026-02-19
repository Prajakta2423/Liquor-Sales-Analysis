################################
# Glue IAM Role
################################
resource "aws_iam_role" "glue_role" {
  name = "glue-job-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "glue.amazonaws.com"
      }
    }]
  })
}


################################
# Attach AWS Managed Glue Service Role
################################
resource "aws_iam_role_policy_attachment" "glue_policy" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}


################################
#  CUSTOM S3 POLICY (managed policy — NOT inline)
################################
resource "aws_iam_policy" "glue_s3_access_policy" {
  name = "glue-s3-access-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          # Script bucket
          "arn:aws:s3:::liquor-glue-scripts",
          "arn:aws:s3:::liquor-glue-scripts/*",

          # Raw bucket
          "arn:aws:s3:::groups-raw-data",
          "arn:aws:s3:::groups-raw-data/*",

          # Clean bucket
          "arn:aws:s3:::group5-clean-data",
          "arn:aws:s3:::group5-clean-data/*"
        ]
      }
    ]
  })
}


################################
# Attach custom S3 policy to Glue role
################################
resource "aws_iam_role_policy_attachment" "glue_s3_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_s3_access_policy.arn
}


################################
# Glue Job
################################
resource "aws_glue_job" "transform_job" {
  name     = "data-clean-job"
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    script_location = "s3://liquor-glue-scripts/clean.py"
    python_version  = "3"
  }

  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 4

  default_arguments = {
    "--TempDir" = "s3://liquor-glue-scripts/temp/"
    "--RAW_S3_PATH"  = "s3://groups-raw-data/"
    "--CLEAN_S3_PATH" = "s3://group5-clean-data/"
  }
}
