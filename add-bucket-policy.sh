for bucket in `aws s3 ls | cut -d ' ' -f 3`; do
aws s3api put-bucket-policy --bucket $bucket --policy "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"AnonymousReadAccess\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"s3:GetObject\",\"Resource\":\"arn:aws:s3:::$bucket/**\"}]}"
done
