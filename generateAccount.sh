#!/bin/bash
if [ $# -eq 0 ]; then
  echo 'specify congregation name'
  exit

fi

name=$1
bucket="$name"-archives

# TODO : determine if account already exists, delete and recreate?

readWritePolicy="{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"s3ReadWritePolicy\",\"Effect\":\"Allow\",\"Action\":[\"s3:DeleteObject\",\"s3:GetObject\",\"s3:ListAllMyBuckets\",\"s3:ListBucket\",\"s3:PutObject\",\"s3:ListBucketMultipartUploads\",\"s3:ListMultipartUploadParts\",\"s3:AbortMultipartUpload\"],\"Resource\":[\"arn:aws:s3:::$name-archives\",\"arn:aws:s3:::$name-archives/*\"]}]}"
readOnlyPolicy="{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"s3ReadOnlyPolicy\",\"Effect\":\"Allow\",\"Action\":[\"s3:GetBucketLocation\",\"s3:GetObject\",\"s3:GetObjectVersion\",\"s3:ListAllMyBuckets\",\"s3:ListBucket\",\"s3:ListBucketMultipartUploads\",\"s3:ListBucketVersions\",\"s3:ListMultipartUploadParts\"],\"Resource\":[\"arn:aws:s3:::$name-archives\",\"arn:aws:s3:::$name-archives/*\"]}]}"

generateBucket() {
  bucketname="$1"

  echo "***************************"
  echo "> Generating s3 bucket $bucketname"
  echo "***************************"

  aws s3 mb s3://"$bucketname"
  aws s3api put-bucket-policy --bucket "$bucketname" --policy "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"AnonymousReadAccess\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"s3:GetObject\",\"Resource\":\"arn:aws:s3:::$bucketname/**\"}]}"

}

generateUser() {
  username="$1"
  policyName="$2"
  policyDocument="$3"

  echo "***************************"
  echo "> Generating user $username"
  echo "***************************"
  aws iam create-user --user-name "$username"
  aws iam put-user-policy --user-name "$username" --policy-name "$policyName-$username" --policy-document "$policyDocument"
  aws iam create-access-key --user-name "$username"

}

generateBucket "$name"-archives
generateUser "$name-read-write" "s3ReadWritePolicy" "$readWritePolicy"
generateUser "$name-read-only" "s3ReadOnlyPolicy" "$readOnlyPolicy"

aws s3api put-bucket-lifecycle-configuration --bucket "$name"-archives --lifecycle-configuration file://glacier.lifecycle.json
