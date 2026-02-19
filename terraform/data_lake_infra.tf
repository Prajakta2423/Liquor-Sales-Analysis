
resource "aws_s3_bucket" "groups_raw_data" {
  bucket = "groups-raw-data"

  force_destroy = true
}

resource "aws_s3_bucket" "clean" {
  bucket = "group5-clean-data"
}

resource "aws_s3_bucket" "glue_scripts" {
  bucket = "liquor-glue-scripts"
}


