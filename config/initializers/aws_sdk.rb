require 'aws-sdk-s3'

Aws.config.update({
  region: 'us-west-1',
  credentials: Aws::Credentials.new(Rails.application.secrets.aws_access_key_id,
                                    Rails.application.secrets.aws_secret_access_key)
})
