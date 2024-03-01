#DynamoDB table
resource "aws_dynamodb_table" "basic-dynamodb-table" {
   attribute {
    name = "Count"
    type = "N"
  }

  attribute {
    name = "id"
    type = "S"
  }

  billing_mode                = "PROVISIONED"
  deletion_protection_enabled = "false"

  global_secondary_index {
    hash_key        = "Count"
    name            = "Count-index"
    projection_type = "ALL"
    read_capacity   = "5"
    write_capacity  = "5"
  }

  hash_key = "id"
  name     = "Visitors"

  point_in_time_recovery {
    enabled = "false"
  }

  read_capacity  = "1"
  stream_enabled = "false"
  table_class    = "STANDARD"
  write_capacity = "1"
}
