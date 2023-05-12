
resource "aws_iam_instance_profile" "palo" {
  name = "${lower(var.palo_name)}-palo"
  role = aws_iam_role.palo.name
}

resource "aws_iam_role" "palo" {
  name = "${lower(var.palo_name)}-palo"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            }
        }
    ]
}
EOF

}

resource "aws_iam_role_policy" "palo" {
  name = "${lower(var.palo_name)}-palo"
  role = aws_iam_role.palo.id

  policy = <<EOF
{
   "Version": "2012-10-17", 
   "Statement": [ 
   { 
      "Effect": "Allow", 
      "Action": ["s3:ListBucket"], 
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.s3_bucket_palo.id}"] 
   }, 
   { 
      "Effect": "Allow", 
      "Action": ["s3:GetObject"], 
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.s3_bucket_palo.id}/*"] 
      } 
   ] 
}
EOF
}