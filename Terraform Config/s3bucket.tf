#S3 bucket
resource "aws_s3_bucket" "sscloudresume" {
  bucket = "sscloudresume" #give bucket new name

  tags = {
    Name = "sscloudresume" #give bucket new name
  }
}

#S3 bucket website configuration
resource "aws_s3_bucket_website_configuration" "sscloudresume" {
  bucket = aws_s3_bucket.sscloudresume.bucket #give bucket new name

  index_document {
    suffix = "index.html"
  }
}

#S3 object
resource "aws_s3_object" "sscloudresume" {
  bucket = aws_s3_bucket.sscloudresume.bucket #give bucket new name
  key    = "index.html"
  #source = "source to file" 
}
